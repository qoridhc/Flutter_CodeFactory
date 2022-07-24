import 'package:dust_app/const/colors.dart';
import 'package:dust_app/model/stat_model.dart';
import 'package:dust_app/model/status_model.dart';
import 'package:dust_app/utils/data_utils.dart';
import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget {
  final String region;
  final StatusModel status;
  final StatModel stat;
  final DateTime dateTime;
  final bool isExpanded;

  const MainAppBar({
    required this.region,
    required this.status,
    required this.stat,
    required this.dateTime,
    required this.isExpanded,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ts = TextStyle(
      color: Colors.white,
      fontSize: 30,
    );

    return SliverAppBar(
      expandedHeight: 500,
      backgroundColor: status.primaryColor,
      pinned: true,
      title: isExpanded
          ? null
          : Text(
              '$region ${DataUtils.getTimeFromDateTime(dateTime: dateTime)}'),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Container(
            margin: EdgeInsets.only(top: kToolbarHeight), // AppBar의 크기를 받아오는 변수
            child: Column(
              children: [
                Text(
                  region,
                  style: ts.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  DataUtils.getTimeFromDateTime(dateTime: stat.dataTime),
                  style: ts.copyWith(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 20),
                Image.asset(
                  status.imagePath,
                  width: MediaQuery.of(context).size.width / 2, // 전체화면의 절반
                ),
                SizedBox(height: 20),
                Text(
                  status.label,
                  style: ts.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  status.comment,
                  style: ts.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
