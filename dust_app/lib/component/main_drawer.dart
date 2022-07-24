import 'package:dust_app/const/regions.dart';
import 'package:flutter/material.dart';

typedef OnRegionTap = void Function(String region);

class MainDrawer extends StatelessWidget {
  final OnRegionTap onRegionTap;
  final String selectedRegion;
  final Color darkColor;
  final Color lightColor;

  const MainDrawer({
    required this.onRegionTap,
    required this.selectedRegion,
    required this.darkColor,
    required this.lightColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: darkColor,
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              '지역 선택',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          ...regions
              .map((e) => ListTile(
                    textColor: Colors.white,
                    selectedTileColor: lightColor,
                    // 선택된 상태일때 색
                    selectedColor: Colors.black,
                    // 선택이 됬을때 글자 색
                    selected: e == selectedRegion,
                    onTap: () {
                      onRegionTap(e);
                    },
                    title: Text(
                      e,
                    ),
                  ))
              .toList()
        ],
      ),
    );
  }
}
