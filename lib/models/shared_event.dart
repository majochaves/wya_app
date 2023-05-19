import 'package:wya_final/models/event.dart';
import 'package:wya_final/models/user_data.dart';

class SharedEvent{
  final Event event;
  final UserData user;

  SharedEvent(this.event, this.user);
}