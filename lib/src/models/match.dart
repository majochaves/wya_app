import 'package:wya_final/src/models/shared_event.dart';
import 'package:wya_final/src/models/user_data.dart';

import 'event.dart';

class Match{
  final SharedEvent friendEvent;
  final Event userEvent;

  Match({required this.friendEvent, required this.userEvent});
}