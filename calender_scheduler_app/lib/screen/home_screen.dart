import 'package:calender_scheduler_app/component/calendar.dart';
import 'package:calender_scheduler_app/component/schedule_bottom_sheet.dart';
import 'package:calender_scheduler_app/component/schedule_card.dart';
import 'package:calender_scheduler_app/component/today_banner.dart';
import 'package:calender_scheduler_app/const/const.dart';
import 'package:calender_scheduler_app/database/drift_database.dart';
import 'package:calender_scheduler_app/model/schedule_with_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: renderfloatingActionButton(), // 오른쪽 아래 플로팅 버튼
      body: SafeArea(
        child: Column(
          children: [
            Calendar(
              selectedDay: selectedDay,
              focusedDay: focusedDay,
              onDaySelected: onDaySelected,
            ),
            SizedBox(height: 8),
            TodayBanner(
              selectedDay: selectedDay,
            ),
            SizedBox(height: 8),
            _ScheduleList(
              selectedDate: selectedDay,
            ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton renderfloatingActionButton() {
    // 오른쪽 아래 플로팅 버튼
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          // 버튼을 울럿을때 BottomSheet 띄우기
          context: context,
          isScrollControlled: true,
          builder: (_) {
            return ScheduleBottomSheet(
              selectedDate: selectedDay,
            );
          },
        );
      },
      backgroundColor: PRIMARY_COLOR,
      child: Icon(
        Icons.add,
      ),
    );
  }

  onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      this.selectedDay = selectedDay; // 클릭한 날짜 State에 저장
      this.focusedDay = selectedDay; // 전월, 다음월 날짜를 클릭했을경우 해당 월로 이동
    });
  }
}

class _ScheduleList extends StatelessWidget {
  final DateTime selectedDate;

  const _ScheduleList({
    required this.selectedDate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // ListView가 어느정도 사이즈를 차지해야하는지 모르기때문에 명시해주기 위해 Expanded로 감싸준다.
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: StreamBuilder<List<ScheduleWithColor>>(
            stream: GetIt.I<LocalDataBase>().watchSchedules(selectedDate),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Center(
                  child: Text('스케줄이 없습니다.'),
                );
              }

              return ListView.separated(
                itemCount: snapshot.data!.length, // 리턴할 위젯의 갯수
                separatorBuilder: (context, index) {
                  // itemBuilder가 실행된 다음 실행됨 -> 각각 아이템 사이에 들어갈 아이템을 그려줄때 사용
                  return SizedBox(
                    height: 8,
                  );
                },
                itemBuilder: (context, index) {
                  final scheduleWithColor = snapshot.data![index];

                  return Dismissible(
                    // 왼쪽, 오른쪽 스와이프 액션 만들수 있음
                    key: ObjectKey(scheduleWithColor.schedule.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (DismissDirection direction) {
                      GetIt.I<LocalDataBase>()
                          .removeSchedule((scheduleWithColor.schedule.id));
                    },
                    child: GestureDetector(
                      onTap: (){
                        showModalBottomSheet(
                          // 버튼을 울럿을때 BottomSheet 띄우기
                          context: context,
                          isScrollControlled: true,
                          builder: (_) {
                            return ScheduleBottomSheet(
                              selectedDate: selectedDate,
                              scheduleId: scheduleWithColor.schedule.id,
                            );
                          },
                        );
                      },
                      child: ScheduleCard(
                        startTime: scheduleWithColor.schedule.startTime,
                        endTime: scheduleWithColor.schedule.endTime,
                        content: scheduleWithColor.schedule.content,
                        color: Color(
                          int.parse(
                            'FF${scheduleWithColor.categoryColor.hexCode}',
                            radix: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
      ),
    );
  }
}
