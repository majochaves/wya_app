import 'package:wya_final/src/models/event.dart';
import 'package:wya_final/src/models/user_data.dart';

class SharedEvent{
  final Event event;
  final UserData user;

  SharedEvent(this.event, this.user);
}