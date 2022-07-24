import 'package:dust_app/component/card_title.dart';
import 'package:dust_app/component/main_card.dart';
import 'package:dust_app/component/main_stat.dart';
import 'package:dust_app/const/colors.dart';
import 'package:dust_app/model/stat_and_status_model.dart';
import 'package:dust_app/model/stat_model.dart';
import 'package:dust_app/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CategoryCard extends StatelessWidget {
  final String region;
  final Color darkColor;
  final Color lightColor;

  const CategoryCard({
    required this.region,
    required this.darkColor,
    required this.lightColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: MainCard(
        backgroundColor: lightColor,
        child: LayoutBuilder(builder: (context, constraint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(
                title: '종류별 통계',
                backgroundColor: darkColor,
              ),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal, // 좌우로 스크롤
                  physics: PageScrollPhysics(),
                  children: ItemCode.values
                      .map((ItemCode itemCode) => ValueListenableBuilder<Box>(
                            valueListenable:
                                Hive.box<StatModel>(itemCode.name).listenable(),
                            builder: (context, box, widget) {
                              final stat = (box.values.last as StatModel);
                              final status =
                                  DataUtils.getStatusFromItemCodeAndValue(
                                value: stat.getLevelFromRegion(region),
                                itemCode: itemCode,
                              );

                              return MainStat(
                                category: DataUtils.getItemCodeKrString(
                                  itemCode: itemCode,
                                ),
                                imgPath: status.imagePath,
                                level: status.label,
                                stat: '${stat.getLevelFromRegion(
                                  region,
                                )}${DataUtils.getUnitFromItemCode(
                                  itemCode: itemCode,
                                )}',
                                width: constraint.maxWidth / 3,
                              );
                            },
                          ))
                      .toList(),
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
