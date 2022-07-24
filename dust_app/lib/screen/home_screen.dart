import 'package:dio/dio.dart';
import 'package:dust_app/container/category_card.dart';
import 'package:dust_app/component/main_app_bar.dart';
import 'package:dust_app/component/main_drawer.dart';
import 'package:dust_app/const/regions.dart';
import 'package:dust_app/model/stat_model.dart';
import 'package:dust_app/repository/stat_repository.dart';
import 'package:dust_app/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../container/hourly_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String region = regions[0];
  bool isExpanded = true;
  ScrollController scrollController = ScrollController();

  @override
  initState() {
    super.initState();

    scrollController.addListener(scrollListener);
    fetchData();
    // 스크롤할때마다 scrollListener가 실행된다.
  }

  @override
  dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final now = DateTime.now();

      final fetchTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour + 9,
      );

      final box = Hive.box<StatModel>(ItemCode.PM10.name);
      if (box.values.isNotEmpty &&
          (box.values.last as StatModel).dataTime.isAtSameMomentAs(fetchTime)) {
        print('이미 최신 데이터가 있습니다.');
        return;
      }

      List<Future> futures = [];

      for (ItemCode itemCode in ItemCode.values) {
        futures.add(
          StatRepository.fetchData(
            itemCode: itemCode,
          ),
        );
      }

      // List안의 Future값이 끝날때 까지 한번에 기다린다
      final results = await Future.wait(futures);

      // Hive에 데이터 넣기
      for (int i = 0; i < results.length; i++) {
        // ItemCode
        final key = ItemCode.values[i];
        // List<StatModel>
        final value = results[i];

        final box = Hive.box<StatModel>(key.name);

        for (StatModel stat in value) {
          box.put(stat.dataTime.toString(), stat);
        }

        final allKeys = box.keys.toList();

        if (allKeys.length > 24) {
          // 데이터의 길이가 24개보다 많아지면 삭제해주기
          // start - 시작 인덱스
          // end - 끝 인덱스
          // ['red' , 'orange' , 'yellow' , 'blue']
          // .sublist(1,3)
          // ['orange' , 'yellow'] -> 마지막 인덱스 이전구간까지 가져옴
          final deleteKeys = allKeys.sublist(0, allKeys.length - 24);

          box.deleteAll(deleteKeys);
        }
      }
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        '인터넷 연결이 원활하지 않습니다.',
      )));
    }
  }

  scrollListener() {
    bool isExpanded = scrollController.offset < 500 - kToolbarHeight;
    // offset : 스크롤을 얼만큼 했는지 알수잇음

    if (isExpanded != this.isExpanded) {
      setState(() {
        this.isExpanded = isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box<StatModel>(ItemCode.PM10.name).listenable(),
      builder: (context, box, widget) {
        if (box.values.isEmpty) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        // PM10 (미세먼지)
        // box.value.toList().last
        final recentStat =
            box.values.toList().last as StatModel; // StatModel 형태로 받아옴

        final status = DataUtils.getStatusFromItemCodeAndValue(
          // 미세먼지 최근 데이터의 현재 상태 받아오기
          value: recentStat.getLevelFromRegion(region),
          itemCode: ItemCode.PM10,
        );

        return Scaffold(
          drawer: MainDrawer(
            darkColor: status.darkColor,
            lightColor: status.lightColor,
            selectedRegion: region,
            onRegionTap: (String region) {
              setState(() {
                this.region = region;
              });
              Navigator.of(context).pop();
            },
          ),
          body: Container(
            color: status.primaryColor,
            child: RefreshIndicator(
              onRefresh: () async {
                await fetchData();
              },
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  MainAppBar(
                    region: region,
                    stat: recentStat,
                    status: status,
                    dateTime: recentStat.dataTime,
                    isExpanded: isExpanded,
                  ),
                  // SliverToBoxAdapter : Sliver는 원래 Sliver위젯들만 넣을수 있는데, 일반 위젯도 사용할수 있게끔 해준다.
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CategoryCard(
                          region: region,
                          darkColor: status.darkColor,
                          lightColor: status.lightColor,
                        ),
                        const SizedBox(height: 16),
                        ...ItemCode.values.map((itemCode) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: HourlyCard(
                              darkColor: status.darkColor,
                              lightColor: status.lightColor,
                              region: region,
                              itemCode: itemCode,
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
