import 'package:drift/drift.dart';
// 특정 기능을 실행해주면 drift가 알아서 sqlite와 연동해서 명시해둔 구조대로 테이블을 만들어줌
class Schedules extends Table {
  // PRIMARY KEY
  // 함수가 리턴되므로 한번더 ()로 실행시켜줘야함
  IntColumn get id => integer().autoIncrement()();
  // insert 할때 따로 넣어주지 않아도 자동적으로 넣어준다 -> PRIMARY KEY는 중복되면 안되므로 항상 autoIncrement해주는게 좋다

  // 내용
  TextColumn get content => text()();

  // 일정 날짜
  DateTimeColumn get date => dateTime()();

  //시작 시간
  IntColumn get startTime => integer()();

  //끝 시간
  IntColumn get endTime => integer()();

  // Category Color Table ID
  IntColumn get colorId => integer()();

  // 생성 날짜
  DateTimeColumn get createdAt => dateTime().clientDefault(
        () => DateTime.now(),
      )();
  // 생선날짠는 항상 현재 시간이므로 clientDefault를 사용해서 DateTime.now()를 기본값으로 지정해준다.
  // -> 만약 직접 임의의 값을 넣어주면 그 값으로 대체된다.
}
