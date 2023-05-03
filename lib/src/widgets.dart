// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker_fork/flutter_cupertino_date_picker_fork.dart';
import 'package:go_router/go_router.dart';
import 'package:wya_final/src/utils/constants.dart';
import 'package:wya_final/src/utils/string_formatter.dart';

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

  const CustomPaddingButton({super.key, required this.text, required this.color, required this.onPress, required this.height, required this.width});

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
  const SquareButton({Key? key, required this.color, required this.textColor, required this.text, required this.onTap, required this.isLoading}) : super(key: key);

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
        child:
        ! isLoading ?
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14),
        ) :
        CircularProgressIndicator(
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

  const SquareIconButton({Key? key, required this.color, required this.icon, required this.pushTo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: RoundedIcon(icon: Icons.add, iconColor: Colors.black, backgroundColor: color,),
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

  const PaddingButton({super.key, required this.text, required this.color, required this.onPress});

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
        image: DecorationImage(
            fit: BoxFit.cover, image: imageSrc),
        borderRadius: const BorderRadius.all(Radius.circular(100.0)),
        color: Colors.redAccent,
      ),
    );
  }
}

///Cards

class MatchCard extends StatelessWidget {

  final ImageProvider userPicture;
  final DateTime time;
  final String userName;
  final Color cardColor;
  final Color iconColor;

  const MatchCard({Key? key, required this.userPicture, required this.time, required this.userName, required this.cardColor, required this.iconColor}) : super(key: key);

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
                ListTile(
                  leading: CircleAvi(imageSrc: userPicture, size: 40),
                  title: Text(StringFormatter.getTimeString(time), style: kMatchCardTextStyle,),
                  subtitle: Text(userName, style: kMatchCardTextStyle,),
                ),
                Icon(Icons.send, color: iconColor,)
              ],
            )
        ),
      ),
    );
  }
}

class SharedEventCard extends StatelessWidget {

  final ImageProvider userPicture;
  final DateTime time;
  final String eventTitle;
  final String eventDescription;
  final String userName;
  final Color cardColor;
  final Color iconColor;

  const SharedEventCard({Key? key, required this.userPicture, required this.time, required this.userName, required this.cardColor, required this.iconColor, required this.eventTitle, required this.eventDescription}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
                Expanded(child: Center(child: Text(StringFormatter.getTimeString(time), style: kSubtitleTextStyle,),)),
                Expanded(
                  flex: 3,
                  child: ListTile(
                    title: Text(eventTitle, style: kMatchCardTextStyle,),
                    subtitle: Text(eventDescription, style: kMatchCardTextStyle,),
                  ),
                ),
                Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CircleAvi(imageSrc: userPicture, size: 40),
                  Text(userName),
                ],))
              ],
            )
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final String eventTitle;
  final String eventDescription;
  final Color cardColor;
  final Color iconColor;

  const EventCard({Key? key, required this.cardColor, required this.iconColor, required this.eventTitle, required this.eventDescription, required this.startTime, required this.endTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
                SizedBox(height: 100, width: 5, child: Container(color: iconColor),),
                Expanded(child: Center(child: Text('${StringFormatter.getTimeString(startTime)}-${StringFormatter.getTimeString(endTime)}', style: kSubtitleTextStyle,),)),
                Expanded(
                  flex: 3,
                  child: ListTile(
                    title: Text(eventTitle, style: kMatchCardTextStyle,),
                    subtitle: Text(eventDescription, style: kMatchCardTextStyle,),
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }
}

/// Containers

class RoundedContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double padding;
  const RoundedContainer({Key? key, required this.child, required this.backgroundColor, required this.padding}) : super(key: key);

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
          borderRadius: BorderRadius.circular(10),
          color: kPastelOrangeYellow
      ),
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
  const ChipsField({Key? key, required this.title, required this.height, required this.flex1, required this.flex2, required this.chips}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              flex: flex1,
              child: title
          ),
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
  const StatColumn({Key? key, required this.num, required this.label, required this.pushTo}) : super(key: key);

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

class TitleDescriptionColumn extends StatelessWidget {
  final String title;
  final String description;
  const TitleDescriptionColumn({Key? key, required this.title, required this.description}) : super(key: key);

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

class DatetimePicker extends StatelessWidget {
  final DateTime minDate;
  final DateTime maxDate;
  final DateTime initDate;
  final Function toggleChangeDatetime;
  final bool time;

  const DatetimePicker({super.key, required this.minDate, required this.maxDate, required this.initDate, required this.time, required this.toggleChangeDatetime,});

  final DateTimePickerLocale _locale = DateTimePickerLocale.en_us;
  final String _dateFormat = 'dd/MM/yyyy';
  final String _timeFormat = 'HH:mm';

  String _toDoubleDigits(int number){
    if(number > 9){
      return number.toString();
    }else{
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
        toggleChangeDatetime(dt);
      },
      onConfirm: (dt, List<int> index) {
        toggleChangeDatetime(dt);
      },
    );
  }

  ///Datetime

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
        toggleChangeDatetime(dt);
      },
      onConfirm: (dt, List<int> index) {
        toggleChangeDatetime(dt);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {time ? _showTimePicker(context) : _showDatePicker(context);},
      child: time
          ? Text('${_toDoubleDigits(initDate.hour)}:${_toDoubleDigits(initDate.minute)}')
          : Text('${_toDoubleDigits(initDate.day)}/${_toDoubleDigits(initDate.month)}/${_toDoubleDigits(initDate.year)}'),
      //trailing: widget.time ? const Icon(Icons.access_time, size: 0,) : const Icon(Icons.calendar_month)
    );
  }
}

/// Icons
class CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const CircleIcon({Key? key, required this.icon, required this.backgroundColor, required this.iconColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        //border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(100),
      ),
      child:Padding(
        padding: EdgeInsets.all(10),
        child: Icon(icon, color: iconColor,),
      ),
    );
  }
}

class RoundedIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const RoundedIcon({Key? key, required this.icon, required this.backgroundColor, required this.iconColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        //border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child:Padding(
        padding: EdgeInsets.all(7),
        child: Icon(icon, color: iconColor,),
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
  const SearchInput({
    Key? key,
    required this.hintText,
    required this.textEditingController,
    required this.iconColor, required this.onSearch
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Icon(Icons.search, color: iconColor,)),
        Expanded(
          flex: 6,
          child: Form(
            child: TextFormField(
              controller: textEditingController,
              decoration: InputDecoration(hintText: hintText, contentPadding: const EdgeInsets.all(8)),
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
  const TextFieldInput({
    Key? key,
    required this.hintText,
    this.isPass = false,
    required this.textEditingController,
    required this.textInputType
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context)
    );
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
  const TextFieldInputWithIcon({
    Key? key,
    required this.hintText,
    this.isPass = false,
    required this.textEditingController,
    required this.textInputType,
    required this.icon, required this.iconColor
  }) : super(key: key);

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
        const Expanded(child: SizedBox(),),
        Expanded(
          flex: 15,
          child: TextField(
            controller: widget.textEditingController,
            decoration: InputDecoration(
              hintText: widget.hintText,
              contentPadding: const EdgeInsets.all(8),
              prefixIcon: Icon(widget.icon, color: kOrange,),
              suffixIcon: widget.isPass ? IconButton(
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
              ): null,
            ),
            keyboardType: widget.textInputType,
            obscureText: !_passwordVisible,
          ),
        ),
        const Expanded(child: SizedBox(),),
      ],
    );
  }
}

/// List tiles
class OptionTile extends StatelessWidget {

  final IconData iconData;
  final String title;
  final String pushTo;

  const OptionTile({Key? key, required this.iconData, required this.title, required this.pushTo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ListTile(
        leading: RoundedIcon(backgroundColor: Colors.white, icon: iconData, iconColor: Colors.black,),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold),),
        trailing: const Icon(Icons.navigate_next, color: Colors.black,),
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
                onTap: () {context.push('/');},
                child: IconButton(
                  iconSize: 30,
                  tooltip: 'Home',
                  icon: current == 'home' ? const Icon(Icons.home) : const Icon(Icons.home_outlined),
                  onPressed: () {
                    context.push('/');
                  },
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {context.push('/search');},
                child: IconButton(
                  iconSize: 30,
                  tooltip: 'Search',
                  icon: current == 'search' ? const Icon(Icons.search) : const Icon(Icons.search_outlined),
                  onPressed: () {
                    context.push('/search');
                  },
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {context.push('/account');},
                child: IconButton(
                  iconSize: 30,
                  tooltip: 'Profile',
                  icon: current == 'account' ? const Icon(Icons.person): const Icon(Icons.person_outlined),
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