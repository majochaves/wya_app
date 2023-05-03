import 'package:flutter/material.dart';
import 'utils/string_formatter.dart';
import 'utils/constants.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDay;
  final Function toggleCalendar;
  const DateSelector({Key? key, required this.selectedDay, required this.toggleCalendar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            StringFormatter.getDayTitle(selectedDay),
            style: kH2TextStyle,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.add,
            color: kHotPink,
          ),
          onPressed: () {
            //Navigator.of(context)
            //.pushReplacement(MaterialPageRoute(
            //builder: (context) => LocationLoadingScreen(
            //uid: uid,
            //edit: false,
            //eventId: '',
            //date: _selectedDay,
            //),
            //));
          },
        ),
        IconButton(icon: const Icon(Icons.calendar_month, color: kDeepBlue,), onPressed: () {toggleCalendar();},),
      ],
    );
  }
}
