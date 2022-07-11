import 'package:calender_scheduler_app/database/drift_database.dart';
import 'package:calender_scheduler_app/model/categoty_color.dart';

class ScheduleWithColor{
  final Schedule schedule;
  final CategoryColor categoryColor;

  ScheduleWithColor({
    required this.schedule,
    required this.categoryColor,
});
}