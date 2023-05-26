import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/providers/event_provider.dart';
import '../../utils/string_formatter.dart';
import '../../utils/constants.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDay;
  final Function toggleCalendar;
  const DateSelector({Key? key, required this.selectedDay, required this.toggleCalendar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              StringFormatter.getDayTitle(selectedDay),
              style: kH1PattayaTextStyle,
            ),
          ),
        ),
        Expanded(child: Container()),
        IconButton(
          icon: const Icon(
            Icons.add, color: kWYAOrange,
            size: 30,
          ),
          onPressed: () {
            eventProvider.newEvent();
            context.go('/eventEditor');
          },
        ),
        IconButton(icon: const Icon(Icons.calendar_month, color: kWYAOrange,
          size: 30,), onPressed: () {toggleCalendar();},),
      ],
    );
  }
}
