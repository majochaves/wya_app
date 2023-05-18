import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../utils/constants.dart';
import '/src/widgets/widgets.dart';
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
            image: Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/welcomescreenbg.png').image,
            fit: BoxFit.cover
          )
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: Container(), flex: 10,),
              Expanded(child: Image(image: Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/locationpin.png').image, width: 50,),
              flex: 5,),
              Expanded(child: Container(), flex: 1,),
              Expanded(child: Image(image: Image.asset('/Users/majochaves/StudioProjects/wya_app/assets/images/wyatext.png').image),
              flex: 4,),
              Expanded(child: Container(), flex: 1,),
              Expanded(
                child: SpecialWYAButton(textColor: Colors.white, color: kWYATeal, isLoading: false, text: 'login', onTap: (){
                  context.push('/sign-in');
                }), flex: 2,
              ),
              Expanded(child: Container(), flex: 3,),
            ],
          ),
        ),
      ),
    );
  }
}


