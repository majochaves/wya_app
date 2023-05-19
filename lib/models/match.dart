import 'package:wya_final/models/shared_event.dart';
import 'package:wya_final/models/user_data.dart';

import 'event.dart';

class Match{
  final SharedEvent friendEvent;
  final Event userEvent;

  Match({required this.friendEvent, required this.userEvent});
}