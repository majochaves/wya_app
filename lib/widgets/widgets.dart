import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker_fork/flutter_cupertino_date_picker_fork.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wya_final/providers/user_provider.dart';
import 'package:wya_final/utils/constants.dart';
import 'package:wya_final/utils/string_formatter.dart';

import '../models/chat_info.dart';
import '../models/group.dart';
import '../models/user_data.dart';

import '../providers/chat_provider.dart';

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
                style: GoogleFonts.spaceMono(textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 25),
              ),)
            : CircularProgressIndicator(
                color: color,
              ),
      ),
    );
  }
}

class SpecialWYAButton extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  const SpecialWYAButton(
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
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: ShapeDecoration(
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.white, width: 4),
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          color: color,
        ),
        child: !isLoading
            ? Text(
          text,
          style: GoogleFonts.pattaya(textStyle: TextStyle(
              color: textColor,
              fontSize: 25),
          ),)
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
      height: size,
      width: size,
      decoration: BoxDecoration(
        image: DecorationImage(fit: BoxFit.cover, image: imageSrc),
        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
        color: Colors.redAccent,
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
  final SvgPicture? icon;

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
    return InputChip(
            avatar: CircleAvatar(
                backgroundColor: isSelected ? kPastelPink : kPastelBlue,
                child: icon),
            backgroundColor: kPastelBlue,
            selectedColor: kPastelPink,
            disabledColor: kPastelBlue,
            label: Text(
              categoryName,
              textAlign: TextAlign.center,
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
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    return InkWell(
      onTap: () {
        chatProvider.selectedChat = chat;
        context.go('/viewChat');
      },
      child: ListTile(
        leading: CircleAvi(
          imageSrc: NetworkImage(chat.user.photoUrl),
          size: 30,
        ),
        title: Text(chat.user.name, style:
        (chat.messages.last.senderId != userProvider.uid! &&
            chat.messages.last.isRead == false) ?
            const TextStyle(fontWeight: FontWeight.bold) : null,),
        subtitle: Text(chat.messages.last.text, style:
        (chat.messages.last.senderId != userProvider.uid! &&
            chat.messages.last.isRead == false) ?
        const TextStyle(fontWeight: FontWeight.bold) : null,),
        trailing: isSameDay(DateTime.now(), chat.chat.lastMessageSentAt!) ? Text(StringFormatter.getTimeString(
            chat.chat.lastMessageSentAt!)) : Text(StringFormatter.getDayTitle(chat.chat.lastMessageSentAt!))),
    );
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
  final String pushTo;
  final bool isEnabled;
  const StatColumn(
      {Key? key, required this.num, required this.label, required this.pushTo, required this.isEnabled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if(isEnabled){
          context.go(pushTo);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  const DateChooser({
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
        padding: const EdgeInsets.all(10),
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
        padding: const EdgeInsets.all(7),
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

class UserInkWellListTiles extends StatelessWidget {
  final List<UserData> users;
  final Function onPressed;
  const UserInkWellListTiles(
      {Key? key,
        required this.users,
        required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: users.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {onPressed(users[index]);},
            child: ListTile(
              leading: CircleAvi(
                imageSrc: NetworkImage(
                  users[index].photoUrl,
                ),
                size: 40,
              ),
              title: Text(users[index].username),
            ),
          );
        });
  }
}

class GroupListTiles extends StatelessWidget {
  final List<Group> groups;
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
            title: Text(groups.elementAt(index).name),
            trailing: IconButton(
              icon: Icon(icon),
              onPressed: () {
                onPressed(groups.elementAt(index));
              },
            ),
          );
        });
  }
}

class AppBarCustom extends StatelessWidget with PreferredSizeWidget{
  const AppBarCustom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kWYATeal,
      title: Image(image: Image.asset('assets/images/wyatextorange.png').image, width: 80,),);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
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
          backgroundColor: kWYAOrange,
          icon: iconData,
          iconColor: Colors.white,
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
class CustomDivider extends StatelessWidget {
  const CustomDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: const [
      SizedBox(height: 20),
      Divider(height: 5, thickness: 3, color: kWYAOrange,),
      SizedBox(height: 20),
    ],);
  }
}


///App bars

class CustomBottomAppBar extends StatelessWidget {
  final String current;

  const CustomBottomAppBar({Key? key, required this.current}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.black,
      shape: const CircularNotchedRectangle(),
      child: Container(
      decoration: const BoxDecoration(
        color: kWYATeal
      ),
        height: 60.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () {
                  context.go('/');
                },
                child: IconButton(
                  iconSize: 30,
                  tooltip: 'Home',
                  icon: current == 'home'
                      ? const Icon(Icons.home, color: Colors.white, size: 30,)
                      : const Icon(Icons.home_outlined, color: Colors.white, size: 30,),
                  onPressed: () {
                    context.go('/');
                  },
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  context.go('/search');
                },
                child: IconButton(
                  iconSize: 30,
                  tooltip: 'Search',
                  icon: current == 'search'
                      ? const Icon(Icons.search, color: Colors.white, size: 30,)
                      : const Icon(Icons.search_outlined, color: Colors.white, size: 30,),
                  onPressed: () {
                    context.go('/search');
                  },
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  context.pop();
                  context.go('/events');
                },
                child: IconButton(
                  iconSize: 30,
                  tooltip: 'Events',
                  icon: current == 'events'
                      ? const Icon(Icons.calendar_month, color: Colors.white, size: 30,)
                      : const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 30,),
                  onPressed: () {
                    context.go('/events');
                  },
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  context.go('/account');
                },
                child: IconButton(
                  iconSize: 30,
                  tooltip: 'Profile',
                  icon: current == 'account'
                      ? const Icon(Icons.person, color: Colors.white, size: 30,)
                      : const Icon(Icons.person_outlined, color: Colors.white, size: 30,),
                  onPressed: () {
                    context.go('/account');
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
