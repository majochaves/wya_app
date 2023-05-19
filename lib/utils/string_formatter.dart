import 'package:table_calendar/table_calendar.dart';

class StringFormatter{

  static String getTimeString(DateTime time){
    String hour;
    String ampm;
    if(time.hour > 12){
      int newHour = time.hour - 12;
      hour = newHour.toString();
      ampm = 'pm';
    }else{
      hour = (time.hour).toString();
      ampm = 'am';
    }
    String minutes;
    if(time.minute == 0){
      return '$hour$ampm';
    }else{
      if(time.minute < 10){
        minutes = '0${time.minute}';
      }else{
        minutes = (time.minute).toString();
      }
      return '$hour:$minutes$ampm';
    }
  }

  static String getDayTitle(DateTime day) {
    DateTime now = DateTime.now();
    if(isSameDay(day, now)){
      return 'Today';
    }else if(isSameDay(day, DateTime(now.year, now.month, now.day - 1))){
      return 'Yesterday';
    }else if(isSameDay(day, DateTime(now.year, now.month, now.day + 1))){
      return 'Tomorrow';
    }else{
      String weekDay = '';
      switch(day.weekday){
        case DateTime.monday : {
          weekDay = 'Monday';
        }
        break;
        case DateTime.tuesday : {
          weekDay = 'Tuesday';
        }
        break;
        case DateTime.wednesday : {
          weekDay = 'Wednesday';
        }
        break;
        case DateTime.thursday : {
          weekDay = 'Thursday';
        }
        break;
        case DateTime.friday : {
          weekDay = 'Friday';
        }
        break;
        case DateTime.saturday : {
          weekDay = 'Saturday';
        }
        break;
        case DateTime.sunday : {
          weekDay = 'Sunday';
        }
      }
      String dayString = day.day.toString();
      if(day.day < 10){
        dayString = '0${day.day.toString()}';
      }
      String monthString = day.month.toString();
      if(day.month < 10){
        monthString = '0${day.month.toString()}';
      }

      return '$dayString/$monthString/${day.year.toString()}';
    }
  }

  static getDayText(DateTime selectedDay) {
    return isSameDay(selectedDay, DateTime.now()) ? 'today' : 'this day';
  }
}