// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker_fork/flutter_cupertino_date_picker_fork.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/event_category.dart';
import 'package:wya_final/src/utils/constants.dart';
import 'package:wya_final/src/utils/string_formatter.dart';

import 'package:wya_final/event.dart';
import '../app_state.dart';
import '../chat_info.dart';
import '../group.dart';
import '../shared_event.dart';
import '../user_data.dart';
import 'package:wya_final/match.dart' as model;
import 'package:wya_final/notification.dart' as model;

import 'notification_user_event.dart';

class Header extends StatelessWidget {
  const Header(this.heading, {super.key});
  final String heading;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          heading,
          style: const TextStyle(fontSize: 24),
        ),
      );
}

class Paragraph extends StatelessWidget {
  const Paragraph(this.content, {super.key});
  final String content;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          content,
          style: const TextStyle(fontSize: 18),
        ),
      );
}

class IconAndDetail extends StatelessWidget {
  const IconAndDetail(this.icon, this.detail, {super.key});
  final IconData icon;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              detail,
              style: const TextStyle(fontSize: 18),
            )
          ],
        ),
      );
}

///Buttons

class StyledButton extends StatelessWidget {
  const StyledButton({required this.child, required this.onPressed, super.key});
  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.deepPurple)),
        onPressed: onPressed,
        child: child,
      );
}

class CustomPaddingButton extends StatelessWidget {
  final Color color;
  final String text;
  final double height;
  final double width;
  final VoidCallback onPress;

  const CustomPaddingButton(
      {super.key,
      required this.text,
      required this.color,
      required this.onPress,
      required this.height,
      required this.width});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(30.0),
      child: MaterialButton(
        onPressed: onPress,
        height: height,
        minWidth: width,
        child: Text(
          text,
        ),
      ),
    );
  }
}

class SquareButton extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  const SquareButton(
      {Key? key,
      required this.color,
      required this.textColor,
      required this.text,
      required this.onTap,
      required this.isLoading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: ShapeDecoration(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          color: color,
        ),
        child: !isLoading
            ? Text(
                text,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 14),
              )
            : CircularProgressIndicator(
                color: color,
              ),
      ),
    );
  }
}

class SquareIconButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String pushTo;

  const SquareIconButton(
      {Key? key, required this.color, required this.icon, required this.pushTo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: RoundedIcon(
        icon: Icons.add,
        iconColor: Colors.black,
        backgroundColor: color,
      ),
      onTap: () {
        context.push(pushTo);
      },
    );
  }
}

class FollowButton extends StatelessWidget {
  final Function()? function;
  final Color backgroundColor;
  final Color borderColor;
  final String text;
  final Color textColor;
  const FollowButton(
      {Key? key,
      required this.backgroundColor,
      required this.borderColor,
      required this.text,
      required this.textColor,
      this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: function,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          width: 250,
          height: 27,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class PaddingButton extends StatelessWidget {
  final Color color;
  final String text;
  final VoidCallback onPress;

  const PaddingButton(
      {super.key,
      required this.text,
      required this.color,
      required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPress,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            text,
          ),
        ),
      ),
    );
  }
}

///Images

class CircleAvi extends StatelessWidget {
  final ImageProvider imageSrc;
  final double size;

  const CircleAvi({super.key, required this.imageSrc, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      width: size,
      height: size,
      decoration: BoxDecoration(
        image: DecorationImage(fit: BoxFit.cover, image: imageSrc),
        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
        color: Colors.redAccent,
      ),
    );
  }
}

///Cards

class MatchCard extends StatelessWidget {
  final model.Match match;
  final Color cardColor;
  final Color iconColor;

  const MatchCard(
      {Key? key,
      required this.cardColor,
      required this.iconColor,
      required this.match})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      child: SizedBox(
        width: 150,
        height: 100,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CircleAvi(
                  imageSrc: NetworkImage(match.friendEvent.user.photoUrl),
                  size: 40),
            ),
            Expanded(child: Text(match.friendEvent.user.name)),
            Expanded(
                child: Text(
                    '${StringFormatter.getTimeString(match.friendEvent.event.startsAt)}-'
                    '${StringFormatter.getTimeString(match.friendEvent.event.endsAt)}')),
          ],
        )),
      ),
    );
  }
}

class SharedEventCard extends StatelessWidget {
  final SharedEvent sharedEvent;
  final Color cardColor;
  final Color iconColor;
  final Function setSelectedSharedEvent;

  SharedEventCard({
    Key? key,
    required this.cardColor,
    required this.iconColor,
    required this.sharedEvent,
    required this.setSelectedSharedEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setSelectedSharedEvent(sharedEvent);
        context.go('/viewSharedEvent');
      },
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40), // if you need this
          side: BorderSide(
            color: iconColor,
            width: 1,
          ),
        ),
        child: SizedBox(
          width: 150,
          height: 100,
          child: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Center(
                child: Text(
                  StringFormatter.getTimeString(sharedEvent.event.startsAt),
                  style: kSubtitleTextStyle,
                ),
              )),
              Expanded(
                flex: 2,
                child: ListTile(
                  title: Text(
                    EventCategory.getCategoryById(sharedEvent.event.category)
                        .name,
                    style: kMatchCardTextStyle,
                  ),
                  subtitle: Text(
                    sharedEvent.event.description,
                    style: kMatchCardTextStyle,
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvi(
                      imageSrc: NetworkImage(sharedEvent.user.photoUrl),
                      size: 40),
                  Text(sharedEvent.user.name),
                ],
              ))
            ],
          )),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final Function setSelectedEvent;
  final Color cardColor;
  final Color iconColor;

  const EventCard({
    Key? key,
    required this.cardColor,
    required this.iconColor,
    required this.event,
    required this.setSelectedEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setSelectedEvent(event);
        context.go('/viewEvent');
      },
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // if you need this
          side: BorderSide(
            color: iconColor,
            width: 1,
          ),
        ),
        child: SizedBox(
          width: 150,
          height: 100,
          child: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 70,
                width: 5,
                child: Container(color: iconColor),
              ),
              Expanded(
                  child: Center(
                child: Text(
                  '${StringFormatter.getTimeString(event.startsAt)}-\n${StringFormatter.getTimeString(event.endsAt)}',
                  style: kSubtitleTextStyle,
                ),
              )),
              Expanded(
                flex: 2,
                child: ListTile(
                  title: Text(
                    EventCategory.getCategoryById(event.category).name,
                    style: kMatchCardTextStyle,
                  ),
                  subtitle: Text(
                    event.description,
                    style: kMatchCardTextStyle,
                  ),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}

///Chips
class EventCategoryChip extends StatelessWidget {
  final String categoryName;
  final int index;
  final bool isSelected;
  final Function selectEventCategoryCallback;
  final Image? icon;

  const EventCategoryChip({
    Key? key,
    required this.isSelected,
    required this.selectEventCategoryCallback,
    required this.categoryName,
    required this.index,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (index == 0 || index == 1)
        ? InputChip(
            backgroundColor: kPastelBlue,
            selectedColor: kPastelPink,
            disabledColor: kPastelBlue,
            label: Container(
              //color: backgroundColor,
              child: Text(
                categoryName,
                textAlign: TextAlign.center,
              ),
            ),
            selected: isSelected,
            onSelected: (bool selected) {
              selectEventCategoryCallback(index, selected);
            },
          )
        : InputChip(
            avatar: CircleAvatar(
                backgroundColor: isSelected ? kPastelPink : kPastelBlue,
                child: icon),
            backgroundColor: kPastelBlue,
            selectedColor: kPastelPink,
            disabledColor: kPastelBlue,
            label: Container(
              //color: backgroundColor,
              child: Text(
                categoryName,
                textAlign: TextAlign.center,
              ),
            ),
            selected: isSelected,
            onSelected: (bool selected) {
              selectEventCategoryCallback(index, selected);
            },
          );
  }
}

class GroupChip extends StatelessWidget {
  final String groupName;
  final int groupIndex;
  final bool isSelected;
  final Function selectGroupCallback;

  const GroupChip(
      {Key? key,
      required this.groupName,
      required this.groupIndex,
      required this.isSelected,
      required this.selectGroupCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(groupName),
      selected: isSelected,
      onSelected: (bool selected) {
        selectGroupCallback(groupIndex, selected);
      },
    );
  }
}

class MemberOrGroupChip extends StatelessWidget {
  final String name;

  const MemberOrGroupChip({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(name),
    );
  }
}

class YesNoChip extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final Function selectEventTypeCallback;

  const YesNoChip({
    Key? key,
    required this.isSelected,
    required this.selectEventTypeCallback,
    required this.label,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputChip(
      backgroundColor: kPastelBlue,
      selectedColor: kPastelPink,
      disabledColor: kPastelBlue,
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Text(
          label,
          textAlign: TextAlign.center,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        selectEventTypeCallback(index, selected);
      },
    );
  }
}

class ChatPreviewer extends StatelessWidget {
  final ChatInfo chat;
  const ChatPreviewer({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
        builder: (context, appState, _) => InkWell(
              onTap: () {
                appState.selectedChat = chat;
                context.go('/viewChat');
              },
              child: ListTile(
                leading: CircleAvi(
                  imageSrc: NetworkImage(chat.user.photoUrl),
                  size: 30,
                ),
                title: Text(chat.user.name, style:
                (chat.messages.last.senderId != appState.userData.uid &&
                    chat.messages.last.isRead == false) ?
                    const TextStyle(fontWeight: FontWeight.bold) : null,),
                subtitle: Text(chat.messages.last.text, style:
                (chat.messages.last.senderId != appState.userData.uid &&
                    chat.messages.last.isRead == false) ?
                const TextStyle(fontWeight: FontWeight.bold) : null,),
                trailing: Text(StringFormatter.getTimeString(
                    chat.chat.lastMessageSentAt!)),),
            ));
  }
}

/// Containers

class RoundedContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double padding;
  const RoundedContainer(
      {Key? key,
      required this.child,
      required this.backgroundColor,
      required this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(40))),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }
}

class BioBox extends StatelessWidget {
  final String content;
  const BioBox({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: kPastelOrangeYellow),
      alignment: Alignment.center,
      padding: const EdgeInsets.only(
        top: 1,
      ),
      child: Text(
        content,
      ),
    );
  }
}

class ChipsField extends StatelessWidget {
  final Widget title;
  final double height;
  final int flex1;
  final int flex2;
  final List<Widget> chips;
  const ChipsField(
      {Key? key,
      required this.title,
      required this.height,
      required this.flex1,
      required this.flex2,
      required this.chips})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(flex: flex1, child: title),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              flex: flex2,
              child: Wrap(
                spacing: 10.0,
                children: chips,
              )),
        ],
      ),
    );
  }
}

class StatColumn extends StatelessWidget {
  final int num;
  final String label;
  final Function pushTo;
  const StatColumn(
      {Key? key, required this.num, required this.label, required this.pushTo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        pushTo;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            num.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsBuilder extends StatefulWidget {
  final List<model.Notification> notifications;
  const NotificationsBuilder({Key? key, required this.notifications})
      : super(key: key);

  @override
  State<NotificationsBuilder> createState() => _NotificationsBuilderState();
}

class _NotificationsBuilderState extends State<NotificationsBuilder> {
  List<NotificationUserEvent> notificationInfo = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = Provider.of<ApplicationState>(context, listen: false);
      notificationInfo =
          await appState.getNotificationInfo(widget.notifications);
      isLoading = false;
    });
  }

  List<Widget> getNotificationTiles() {
    List<Widget> notificationTiles = [];
    for (NotificationUserEvent n in notificationInfo) {
      if (n.notification.type == 0) {
        notificationTiles.add(NotificationType0(
          notification: n,
        ));
      } else if (n.notification.type == 1) {
        notificationTiles.add(NotificationType1(
          notification: n,
        ));
      } else if (n.notification.type == 2) {
        notificationTiles.add(NotificationType2(
          notification: n,
        ));
      } else if (n.notification.type == 3) {
        notificationTiles.add(NotificationType3(
          notification: n,
        ));
      } else {
        notificationTiles.add(NotificationType4(
          notification: n,
        ));
      }
    }
    return notificationTiles;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : notificationInfo.isEmpty
            ? const Center(child: Text('You have no notifications'))
            : ListView(
                children: getNotificationTiles(),
              );
  }
}

class NotificationType0 extends StatelessWidget {
  final NotificationUserEvent notification;
  const NotificationType0({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.go('/friends');
      },
      child: ListTile(
        leading: CircleAvi(
          imageSrc: NetworkImage(notification.user.photoUrl),
          size: 30,
        ),
        title: Text('${notification.user.username} sent you a follow request'),
      ),
    );
  }
}

class NotificationType1 extends StatelessWidget {
  final NotificationUserEvent notification;
  const NotificationType1({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.go('/friends');
      },
      child: ListTile(
        leading: CircleAvi(
          imageSrc: NetworkImage(notification.user.photoUrl),
          size: 30,
        ),
        title:
            Text('${notification.user.username} accepted your follow request'),
      ),
    );
  }
}

class NotificationType2 extends StatelessWidget {
  final NotificationUserEvent notification;
  const NotificationType2({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
        builder: (context, appState, _) => InkWell(
              onTap: () {
                appState.selectedEvent = notification.event;
                context.go('/viewEvent');
              },
              child: ListTile(
                leading: CircleAvi(
                  imageSrc: NetworkImage(notification.user.photoUrl),
                  size: 30,
                ),
                title: Text(
                    '${notification.user.username} has requested to join your event'),
              ),
            ));
  }
}

class NotificationType3 extends StatelessWidget {
  final NotificationUserEvent notification;
  const NotificationType3({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
        builder: (context, appState, _) => InkWell(
              onTap: () {
                appState.selectedSharedEvent =
                    SharedEvent(notification.event!, notification.user);
                context.go('/viewSharedEvent');
              },
              child: ListTile(
                leading: CircleAvi(
                  imageSrc: NetworkImage(notification.user.photoUrl),
                  size: 30,
                ),
                title: Text(
                    '${notification.user.username} accepted your request to join their event'),
              ),
            ));
  }
}

class NotificationType4 extends StatelessWidget {
  final NotificationUserEvent notification;
  const NotificationType4({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
        builder: (context, appState, _) => InkWell(
              onTap: () {
                appState.selectedEvent = notification.event;
                context.go('/viewEvent');
              },
              child: ListTile(
                leading: CircleAvi(
                  imageSrc: NetworkImage(notification.user.photoUrl),
                  size: 30,
                ),
                title:
                    Text('${notification.user.username} has joined your event'),
              ),
            ));
  }
}

class OptionSwitch extends StatelessWidget {
  final bool boolValue;
  final Function onChanged;
  OptionSwitch({Key? key, required this.boolValue, required this.onChanged})
      : super(key: key);

  final MaterialStateProperty<Color?> trackColor =
      MaterialStateProperty.resolveWith<Color?>(
    (Set<MaterialState> states) {
      // Track color when the switch is selected.
      if (states.contains(MaterialState.selected)) {
        return kDeepBlue;
      }
      // Otherwise return null to set default track color
      // for remaining states such as when the switch is
      // hovered, focused, or disabled.
      return null;
    },
  );
  final MaterialStateProperty<Color?> overlayColor =
      MaterialStateProperty.resolveWith<Color?>(
    (Set<MaterialState> states) {
      // Material color when switch is selected.
      if (states.contains(MaterialState.selected)) {
        return kDeepBlue.withOpacity(0.54);
      }
      // Material color when switch is disabled.
      if (states.contains(MaterialState.disabled)) {
        return Colors.grey.shade400;
      }
      // Otherwise return null to set default material color
      // for remaining states such as when the switch is
      // hovered, or focused.
      return null;
    },
  );

  @override
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
      value: boolValue,
      overlayColor: overlayColor,
      trackColor: trackColor,
      thumbColor: const MaterialStatePropertyAll<Color>(Colors.black),
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        onChanged(value);
      },
    );
  }
}

class TitleDescriptionColumn extends StatelessWidget {
  final String title;
  final String description;
  const TitleDescriptionColumn(
      {Key? key, required this.title, required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: kEventFieldTitleTextStyle,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          description,
          style: kBodyTextStyle,
        ),
      ],
    );
  }
}

class DateChooser extends StatelessWidget {
  final DateTime minDate;
  final DateTime maxDate;
  final DateTime initDate;
  final Function toggleChangeDate;

  DateChooser({
    super.key,
    required this.initDate,
    required this.toggleChangeDate,
    required this.minDate,
    required this.maxDate,
  });

  final DateTimePickerLocale _locale = DateTimePickerLocale.en_us;

  final String _dateFormat = 'dd/MM/yyyy';

  String _toDoubleDigits(int number) {
    if (number > 9) {
      return number.toString();
    } else {
      return '0$number';
    }
  }

  void _showDatePicker(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      onMonthChangeStartWithFirstDate: true,
      pickerTheme: const DateTimePickerTheme(
        showTitle: true,
        confirm: Text('Done', style: TextStyle(color: Colors.blue)),
      ),
      minDateTime: minDate,
      maxDateTime: maxDate,
      initialDateTime: initDate,
      dateFormat: _dateFormat,
      locale: _locale,
      onClose: () {},
      onCancel: () {},
      onChange: (dt, List<int> index) {
        toggleChangeDate(dt);
      },
      onConfirm: (dt, List<int> index) {
        toggleChangeDate(dt);
      },
    );
  }

  ///Datetime

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showDatePicker(context);
      },
      child: Text(
          '${_toDoubleDigits(initDate.day)}/${_toDoubleDigits(initDate.month)}/${_toDoubleDigits(initDate.year)}'),
      //trailing: widget.time ? const Icon(Icons.access_time, size: 0,) : const Icon(Icons.calendar_month)
    );
  }
}

class TimeChooser extends StatelessWidget {
  final DateTime minDate;
  final DateTime maxDate;
  final DateTime initDate;
  final Function toggleChangeTime;
  const TimeChooser(
      {Key? key,
      required this.initDate,
      required this.toggleChangeTime,
      required this.minDate,
      required this.maxDate})
      : super(key: key);

  final String _timeFormat = 'HH:mm';

  String _toDoubleDigits(int number) {
    if (number > 9) {
      return number.toString();
    } else {
      return '0$number';
    }
  }

  void _showTimePicker(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      minDateTime: minDate,
      maxDateTime: maxDate,
      initialDateTime: initDate,
      dateFormat: _timeFormat,
      pickerMode: DateTimePickerMode.time, // show TimePicker
      pickerTheme: DateTimePickerTheme(
        title: Container(
          decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
          width: double.infinity,
          height: 56.0,
          alignment: Alignment.center,
          child: const Text(
            'Select time:',
            style: TextStyle(color: Colors.black54, fontSize: 20.0),
          ),
        ),
        titleHeight: 56.0,
      ),
      onCancel: () {
        debugPrint('onCancel');
      },
      onChange: (dt, List<int> index) {
        toggleChangeTime(dt);
      },
      onConfirm: (dt, List<int> index) {
        toggleChangeTime(dt);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          _showTimePicker(context);
        },
        child: Text(
            '${_toDoubleDigits(initDate.hour)}:${_toDoubleDigits(initDate.minute)}'));
  }
}

/// Icons
class CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const CircleIcon(
      {Key? key,
      required this.icon,
      required this.backgroundColor,
      required this.iconColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        //border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }
}

class RoundedIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const RoundedIcon(
      {Key? key,
      required this.icon,
      required this.backgroundColor,
      required this.iconColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        //border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(7),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }
}

///Inputs

class SearchInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final Color iconColor;
  final String hintText;
  final Function onSearch;
  const SearchInput(
      {Key? key,
      required this.hintText,
      required this.textEditingController,
      required this.iconColor,
      required this.onSearch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Icon(
          Icons.search,
          color: iconColor,
        )),
        Expanded(
          flex: 6,
          child: Form(
            child: TextFormField(
              controller: textEditingController,
              decoration: InputDecoration(
                  hintText: hintText, contentPadding: const EdgeInsets.all(8)),
              onFieldSubmitted: (String _) {
                onSearch();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  const TextFieldInput(
      {Key? key,
      required this.hintText,
      this.isPass = false,
      required this.textEditingController,
      required this.textInputType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}

class TextFieldInputWithIcon extends StatefulWidget {
  final TextEditingController textEditingController;
  final IconData icon;
  final Color iconColor;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  const TextFieldInputWithIcon(
      {Key? key,
      required this.hintText,
      this.isPass = false,
      required this.textEditingController,
      required this.textInputType,
      required this.icon,
      required this.iconColor})
      : super(key: key);

  @override
  State<TextFieldInputWithIcon> createState() => _TextFieldInputWithIconState();
}

class _TextFieldInputWithIconState extends State<TextFieldInputWithIcon> {
  late bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = widget.isPass ? false : true;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: SizedBox(),
        ),
        Expanded(
          flex: 15,
          child: TextField(
            controller: widget.textEditingController,
            decoration: InputDecoration(
              hintText: widget.hintText,
              contentPadding: const EdgeInsets.all(8),
              prefixIcon: Icon(
                widget.icon,
                color: kOrange,
              ),
              suffixIcon: widget.isPass
                  ? IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: widget.iconColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    )
                  : null,
            ),
            keyboardType: widget.textInputType,
            obscureText: !_passwordVisible,
          ),
        ),
        const Expanded(
          child: SizedBox(),
        ),
      ],
    );
  }
}

class UserListTiles extends StatelessWidget {
  final List<UserData> users;
  final IconData icon;
  final Function onPressed;
  const UserListTiles(
      {Key? key,
      required this.users,
      required this.icon,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvi(
              imageSrc: NetworkImage(
                users[index].photoUrl,
              ),
              size: 40,
            ),
            title: Text(users[index].username),
            trailing: IconButton(
              icon: Icon(icon),
              onPressed: () {
                onPressed(users[index]);
              },
            ),
          );
        });
  }
}

class GroupListTiles extends StatelessWidget {
  final Map<Group, List<UserData>> groups;
  final IconData icon;
  final Function onPressed;
  const GroupListTiles(
      {Key? key,
      required this.groups,
      required this.icon,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(groups.keys.elementAt(index).name),
            trailing: IconButton(
              icon: Icon(icon),
              onPressed: () {
                onPressed(groups.entries.elementAt(index));
              },
            ),
          );
        });
  }
}

/// List tiles
class OptionTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String pushTo;

  const OptionTile(
      {Key? key,
      required this.iconData,
      required this.title,
      required this.pushTo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ListTile(
        leading: RoundedIcon(
          backgroundColor: Colors.white,
          icon: iconData,
          iconColor: Colors.black,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(
          Icons.navigate_next,
          color: Colors.black,
        ),
      ),
      onTap: () {
        context.push(pushTo);
      },
    );
  }
}

///Scrolling
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

///App bars

class BottomAppBarCustom extends StatelessWidget {
  final String current;

  const BottomAppBarCustom({Key? key, required this.current}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 100.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () {
                  context.push('/');
                },
                child: IconButton(
                  iconSize: 30,
                  tooltip: 'Home',
                  icon: current == 'home'
                      ? const Icon(Icons.home)
                      : const Icon(Icons.home_outlined),
                  onPressed: () {
                    context.push('/');
                  },
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  context.push('/search');
                },
                child: IconButton(
                  iconSize: 30,
                  tooltip: 'Search',
                  icon: current == 'search'
                      ? const Icon(Icons.search)
                      : const Icon(Icons.search_outlined),
                  onPressed: () {
                    context.push('/search');
                  },
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  context.push('/account');
                },
                child: IconButton(
                  iconSize: 30,
                  tooltip: 'Profile',
                  icon: current == 'account'
                      ? const Icon(Icons.person)
                      : const Icon(Icons.person_outlined),
                  onPressed: () {
                    context.push('/account');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
