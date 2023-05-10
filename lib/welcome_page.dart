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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/linkwaveWAVEYbg.png').image,
            fit: BoxFit.cover
          )
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 550.0,
              ),
              Image(image: Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/lynkwave_text.png').image),
              const SizedBox(
                height: 20.0,
              ),
              SquareButton(textColor: Colors.white, color: kLinkPink, isLoading: false, text: 'Log In', onTap: (){
                context.push('/sign-in');
              }),
            ],
          ),
        ),
      ),
    );
  }
}


