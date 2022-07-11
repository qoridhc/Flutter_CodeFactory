import 'package:calender_scheduler_app/const/const.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  final DateTime? selectedDay;
  final DateTime focusedDay;
  final OnDaySelected onDaySelected;

  const Calendar({
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultBoxDeco = BoxDecoration(
      // 날짜들은 컨테이너안에 들어가게되는데, 그 컨테이너의 데코레이션을 지정 단, 주말은 제외
      borderRadius: BorderRadius.circular(6),
      color: Colors.grey[200],
    );

    final defaultTextStyle = TextStyle(
      color: Colors.grey[600],
      fontWeight: FontWeight.w700,
    );

    return TableCalendar(

      locale: 'ko_KR',
      focusedDay: focusedDay,
      // 지금 화면에서 보고있는 날짜(몇월을 보여줄지)
      firstDay: DateTime(1800),
      // 선택 가능한 제일 과거 날짜
      lastDay: DateTime(3000),
      // 선택 가능한 제일 미래의 날짜
      headerStyle: const HeaderStyle(
        formatButtonVisible: false, // 상단에 2Week 버튼 (몇주 단위로 달력을 볼지 정할수있는 버튼) 삭제
        titleCentered: true, // 타이틀 가운데 정렬
        titleTextStyle: TextStyle(
          // 타이틀 스타일 적용
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      calendarStyle: CalendarStyle(
          // 캘린더의 바디를 전박적으로 스타일링
          isTodayHighlighted: false,
          // 오늘 날짜 하이라이트를 없애준다.
          defaultDecoration: defaultBoxDeco,
          // 기본 데코레이션 (주말은 제외)
          weekendDecoration: defaultBoxDeco,
          // 주말 데코레이션
          selectedDecoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: PRIMARY_COLOR,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          outsideDecoration: BoxDecoration(
            shape: BoxShape.rectangle,
          ),
          defaultTextStyle: defaultTextStyle,
          // 기본 텍스트 스타일 (주말 제외)
          weekendTextStyle: defaultTextStyle,
          // 주말 텍스트 스타일
          selectedTextStyle: defaultTextStyle.copyWith(
            // defaultTextStyle을 그대로 사용하되, copyWith안에 넣은 값들은 덮어쓰기
            color: PRIMARY_COLOR,
          )),
      onDaySelected: onDaySelected,
      selectedDayPredicate: (DateTime date) {
        // 화면에서 보고있는 모든 날짜들에 대해서 함수를 실행
        if (selectedDay == null) {
          return false;
        }
        return date.year == selectedDay!.year &&
            date.month == selectedDay!.month &&
            date.day == selectedDay!.day;
        // 따라서 조건에 부합하여 true가 반환된 날짜가 선택한 날짜라는것을 인식하고 화면에 표시해준다.
        // 만약 date == selectedDay 이렇게 하면 시,분,초 까지 모두 같게 조건이 걸리므로 X
      },
    );
  }
}
