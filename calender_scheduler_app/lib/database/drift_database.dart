import 'dart:io';
import 'package:calender_scheduler_app/model/categoty_color.dart';
import 'package:calender_scheduler_app/model/schedule_with_color.dart';
import 'package:calender_scheduler_app/model/schedules.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'drift_database.g.dart';
// import와 비슷하지만 좀더 넓은 기능 -> import는 private 불러올 수 없는데 part는 private값까지 다가져온다. Drift가 자동 생성해줌

@DriftDatabase(
  tables: [
    Schedules,
    CategoryColors,
    // 어떤 클래스들을 database로 쓸지 정의
  ],
)
class LocalDataBase extends _$LocalDataBase {
  // 실제로 db를 형성할 클래스 _$LocalDataBase는 클래스 이름을보고 drift가 drift_database.g.dart 안에 자동으로 만들어줌
  LocalDataBase() : super(_openConnection());

  Future<Schedule> getScheduleById(int id) => (select(schedules)
        ..where(
          (tbl) => tbl.id.equals(id),
        ))
      .getSingle();

  //Schedule DB에 insert하기
  Future<int> createSchedule(SchedulesCompanion data) =>
      into(schedules).insert(data);

  // insert하면 id값을 리턴받을수 있음

  Future<int> createCategoryColor(CategoryColorsCompanion data) =>
      into(categoryColors).insert(data);

  // id같이 같은 스케줄 삭제
  Future<int> removeSchedule(int id) =>
      (delete(schedules)..where((tbl) => tbl.id.equals(id))).go();

  // 테이블의 id가 함수의 id와 같으면 data값으로 해당 테이블 데이터를 변경
  Future<int> updateScheduleById(int id, SchedulesCompanion data) =>
      (update(schedules)..where((tbl) => tbl.id.equals(id))).write(data);

  Future<List<CategoryColor>> getCategoryColors() =>
      select(categoryColors).get();

  Stream<List<ScheduleWithColor>> watchSchedules(DateTime date) {
    final query = select(schedules).join([
      innerJoin(categoryColors, categoryColors.id.equalsExp(schedules.colorId))
      //categoryColors와 schedules와 조인을 하는데 categoryColors와.id가 schedules.colorId와 같은것만 조인
    ]);

    query.where(schedules.date.equals(date));
    query.orderBy(
      [OrderingTerm.asc(schedules.startTime)],
    );

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => ScheduleWithColor(
                  schedule: row.readTable(schedules),
                  categoryColor: row.readTable(categoryColors),
                ),
              )
              .toList(),
        );
  }

// .. 이후함수를 실행하되, .. 이전함수를 리턴해줌 -> 결과적으로 schedules에 watch를 할 수 있음

// final query = select(schedules);
// query.where((tbl) => tbl.date.equals(date));
// return query.watch();

  @override
  int get schemaVersion => 1; // 테이블 구조가 업데이트되면 버전도 없데이트 해줘야함. 시작은 1

}

LazyDatabase _openConnection() {
  // 어떤 위치에 저장할지 명시
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    // 앱을 특정 기기에 설치했을때 앱 전용으로 사용할 폴더 위치를 가져올수 있다.(OS에서 정해줌)
    final file =
        File(p.join(dbFolder.path, 'db.sqlite')); // 파일을 생성하고 싶은 위치 지정, 원하는 이름
    return NativeDatabase(file);
    // -> 배정받은 dbFolder 안에 db.sqlite파일안에 @DriftDatabse에 정의한 테이블 정보들 담은 sql파일을 생성
  });
}
