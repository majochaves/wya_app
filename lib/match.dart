import 'package:wya_final/user_data.dart';

import 'event.dart';

class Match{
  final UserData friend;
  final Event friendEvent;
  final Event userEvent;

  Match(this.friend, this.friendEvent, this.userEvent);
}