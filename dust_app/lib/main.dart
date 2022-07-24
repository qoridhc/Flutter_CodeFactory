import 'package:dust_app/model/stat_model.dart';
import 'package:dust_app/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {

  await Hive.initFlutter();

  Hive.registerAdapter<StatModel>(StatModelAdapter()); // 앞으로  StatModel을 사용할경우 StatModelAdapter를 통하면 된다고 하이브에게 알려주는것
  Hive.registerAdapter<ItemCode>(ItemCodeAdapter());

  for(ItemCode itemCode in ItemCode.values){
    await Hive.openBox<StatModel>(itemCode.name);
  }

  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: 'sunflower',
      ),
      home: HomeScreen(),
    ),
  );
}
