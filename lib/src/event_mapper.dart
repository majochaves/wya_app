import 'dart:collection';

import '../event.dart';

class EventMapper{
  final List<Event> events;

  EventMapper(this.events);

  LinkedHashMap<DateTime, List<Event>> eventsLinkedMap = LinkedHashMap();

  Map<DateTime, List<Event>> getEventsMap(){
    Map<DateTime, List<Event>> eventsMap = <DateTime, List<Event>>{};
    for (var event in events) {
      eventsMap.putIfAbsent(event.startsAt, () =>
          events.where((element) => element.startsAt == event.startsAt)
              .toList());
    }
    return eventsMap;
  }

  void getEventsLinkedMap(){
    Map<DateTime, List<Event>> eventsMap = getEventsMap();

    eventsLinkedMap = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )
      ..addAll(eventsMap);
  }

  List<Event> getEventsForDay(DateTime day){
    return eventsLinkedMap[day] ?? [];
  }

  static int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}