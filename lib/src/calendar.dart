import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wya_final/event.dart';

import 'event_mapper.dart';

class Calendar extends StatefulWidget {
  final List<Event> events;
  final DateTime? selectedDay;
  final Function onSelectDay;
  final bool monthView;
  const Calendar({Key? key, required this.selectedDay, required this.onSelectDay, required this.monthView, required this.events}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  var kFirstDay = DateTime(DateTime.now().year, DateTime.now().month - 3, DateTime.now().day);

  var kLastDay = DateTime(DateTime.now().year, DateTime.now().month + 3, DateTime.now().day);

  DateTime _focusedDay = DateTime.now();

  DateTime? _selectedDay;

  CalendarFormat _calendarFormat = CalendarFormat.month;

  late EventMapper eventMapper;

  @override
  initState(){
    super.initState();
    eventMapper = EventMapper(widget.events);
    eventMapper.getEventsLinkedMap();
    _selectedDay = widget.selectedDay;
    _calendarFormat = widget.monthView ? CalendarFormat.month : CalendarFormat.week;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!EventMapper.isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      widget.onSelectDay(selectedDay);
    }
  }

  List<Event> getEventsForDay(DateTime day){
    return eventMapper.getEventsForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar<Event>(
      firstDay: kFirstDay,
      lastDay: kLastDay,
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: _calendarFormat,
      eventLoader: getEventsForDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: const CalendarStyle(
        // Use `CalendarStyle` to customize the UI
        outsideDaysVisible: false,
      ),
      onDaySelected: _onDaySelected,
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }
}
