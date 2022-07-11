import 'package:calender_scheduler_app/database/drift_database.dart';
import 'package:calender_scheduler_app/model/categoty_color.dart';
import 'package:calender_scheduler_app/screen/home_screen.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

const DEFAULT_COLORS = {
  'F44336', // 빨
  'FF9800', // 주
  'FFEB3B', // 노
  'FCAF50', // 초
  '2196F3', // 파
  '3F51B5', // 남
  '9C37B0', // 보
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 플러터가 준비가 될 때 가지 기다려준다.
  //원래는 runApp을 실행하면 자동으로 실행이 되는 코드지만
  //만약 runApp을 실행하기전에 다른코드를 실행한다면 플러터가 준비된 상태인지 확인해주기위해 따로 실행해주어야함

  await initializeDateFormatting(); // intl패키지 안에 있는 모든 언어 사용 가능

  final database = LocalDataBase();

  GetIt.I.registerSingleton<LocalDataBase>(database);
  // 어디에서든 database를 가져올 수 있게 된다.

  // 선언한 쿼리들 사용 가능
  final colors = await database.getCategoryColors();

  if(colors.isEmpty){
    for(String hexCode in DEFAULT_COLORS){
      await database.createCategoryColor(
        CategoryColorsCompanion(
          hexCode: Value(hexCode), // Value타입을 받으므로 감싸줘야함
        ),
      );
    }
  }
  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: 'NotoSans',
    ),
    home: HomeScreen(),
  ));
}
