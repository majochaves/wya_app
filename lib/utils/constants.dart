import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


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

//LINKWAVE COLORS
const kLinkPink = Color(0xFFDE60BE);
const kLinkPurple = Color(0xFF9E42C7);
const kLinkLightPurple = Color(0xFFB9B7FF);
const kLinkBlue = Color(0xFF158CCE);
const kLinkHotPink = Color(0xFFF70088);
const kLinkYellow = Color(0xFFFAFF4D);
const kLinkAquamarine = Color(0xFF4DF0F8);
const kLinkLightBlue = Color(0xFF6FDBF6);

//WYA COLORS
const kWYATeal = Color(0xFF41BFA8);
const kWYABlack = Color(0xFF232526);
const kWYAGreen = Color(0xFF60BF66);
const kWYACamoGreen = Color(0xFFA5BF7E);
const kWYAOrange = Color(0xFFF28B66);
const kWYALightCamoGreen = Color(0xFFEEFED7);
const kWYALightOrange = Color(0xFFFAFF4D);

//LINKWAVE TEXT
TextStyle kH1SpaceMonoTextStyle = GoogleFonts.pattaya(textStyle: const TextStyle(fontSize: 40, color: Colors.black,
fontWeight: FontWeight.bold));
TextStyle kH3RubikTextStyle = GoogleFonts.rubik(textStyle: const TextStyle(fontSize: 25, color: Colors.black,
    fontWeight: FontWeight.w500));

TextStyle kH6RubikTextStyle = GoogleFonts.rubik(textStyle: const TextStyle(fontSize: 15, color: Colors.black,
    fontWeight: FontWeight.w500));

TextStyle kBodyTextStyle = GoogleFonts.sourceSansPro(textStyle: const TextStyle(fontSize: 15, color: Colors.black,));
TextStyle kBodyTextStyleWhiteBold = GoogleFonts.sourceSansPro(textStyle: const TextStyle(fontSize: 20, color: Colors.white,
fontWeight: FontWeight.bold));

TextStyle sharedEventCardText = GoogleFonts.bebasNeue(textStyle: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold));
TextStyle matchUsernameText = GoogleFonts.rubik(textStyle: const TextStyle(fontSize: 15, color: Colors.black,));


const kTitleTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Roboto Slab',
  fontWeight: FontWeight.w600,
  fontSize: 40.0,
);

const kH1RobotoTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Roboto Slab',
  fontSize: 40.0,
  fontWeight: FontWeight.w900,
);

const kH2RobotoTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Roboto Slab',
  fontSize: 30.0,
  fontWeight: FontWeight.w700,
);

const kH3RobotoTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Roboto Slab',
  fontSize: 20.0,
  fontWeight: FontWeight.w500,
);

const kH4RobotoTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Roboto Slab',
  fontSize: 15.0,
  fontWeight: FontWeight.w300,
);

const kH1SourceSansTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Source Sans Pro',
  fontSize: 40.0,
  fontWeight: FontWeight.w900,
);

const kH2SourceSansTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Source Sans Pro',
  fontSize: 30.0,
  fontWeight: FontWeight.w700,
);

const kH3SourceSansTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Source Sans Pro',
  fontSize: 20.0,
  fontWeight: FontWeight.w500,
);

const kH4SourceSansTextStyle = TextStyle(
  color: kAlmostBlack,
  fontFamily: 'Source Sans Pro',
  fontSize: 15.0,
  fontWeight: FontWeight.w500,
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