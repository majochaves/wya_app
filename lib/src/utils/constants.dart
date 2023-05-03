import 'package:flutter/material.dart';

//Colors
//PASTEL BLUE COLOR
const kPastelBlue = Color(0xFFE4F6F9);
const kPastelOrangeYellow = Color(0xFFFCF4DB);
const kPastelPink = Color(0xFFF9DEF7);
const kPastelPurple = Color(0xFFEEF0FF);
const kPastelGreen = Color(0xFFE5EFBE);
const kPastelYellow = Color(0xFFFEEFE2);
const kPastelRed = Color(0xFFFFFFD1);

//OTHER COLORS
const kDeepBlue = Color(0xFF23BAFF);
const kHotPink = Color(0xFFF70088);
const kOrange = Color(0xFFFF9425);
const kGreen = Color(0xFFBDF66F);
const kPurple = Color(0xFF8758FF);
const kDeeperBlue = Color(0xAB0076DC);
const kDeepPurpleRed = Color(0xFF9C1562);
const kOffWhite = Color(0xFFFAFFEA);
const kAlmostBlack = Color(0xFF212121);

const kMainBGColor = Colors.white;
const kIconDefaultColor = kOrange;

const kBodyTextStyle = TextStyle(fontFamily: 'Source Sans Pro',);

const kTitleTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Roboto Slab',
  fontWeight: FontWeight.w600,
  fontSize: 40.0,
);

const kH1TextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Roboto Slab',
  fontSize: 40.0,
  fontWeight: FontWeight.w900,
);

const kH2TextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Roboto Slab',
  fontSize: 30.0,
  fontWeight: FontWeight.w700,
);

const kH3TextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Roboto Slab',
  fontSize: 20.0,
  fontWeight: FontWeight.w700,
);

const kSubtitleTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Source Sans Pro',
  fontWeight: FontWeight.w700,
  fontSize: 20.0,
);

const kMiniTitleTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Roboto Slab',
  fontWeight: FontWeight.w700,
  fontSize: 15.0,
);

const kWeekDayTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Bebas Neue',
  fontWeight: FontWeight.w100,
  fontSize: 40.0,
);
const kDateTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Bebas Neue',
  fontWeight: FontWeight.w100,
  fontSize: 15.0,
);

const kEventFieldTitleTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Source Sans Pro',
  fontWeight: FontWeight.w700,
  fontSize: 20.0,
);

const kWeekTitleTextStyle = TextStyle(
    fontFamily: 'Source Sans Pro', fontSize: 20.0, color: Colors.white);

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  hintText: '',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kHandleTextStyle = TextStyle(
  fontFamily: 'Bebas Neue',
  fontSize: 30,
);

const kNameStyle = TextStyle(
  fontFamily: 'Bebas Neue',
  fontSize: 15,
);

//MATCH CARDS
const kMatchCardTextStyle = TextStyle(fontFamily: 'Source Sans Pro');