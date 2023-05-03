import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'src/utils/constants.dart';
import 'src/widgets.dart';

class WelcomePage extends StatefulWidget {

  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBGColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SvgPicture.asset('assets/images/wya_logo.svg', height: 150, width: 150,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  'wya',
                  style: TextStyle(
                    fontFamily: 'Roboto Slab',
                    fontSize: 70.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 48.0,
            ),
            SquareButton(textColor: Colors.white, color: kDeepBlue, isLoading: false, text: 'Log In', onTap: (){
              context.push('/sign-in');
            }),
          ],
        ),
      ),
    );
  }
}


