import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/constants.dart';
import '/widgets/widgets.dart';

class WelcomeScreen extends StatefulWidget {

  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBGColor,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset('assets/images/welcomescreenbg.png').image,
            fit: BoxFit.cover
          )
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(flex: 5,child: Container(),),
              Expanded(flex: 5,child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image(image: Image.asset('assets/images/locationpin.png').image, width: 50,),
              ),),
              Expanded(flex: 5,child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image(image: Image.asset('assets/images/wyatext.png').image),
              ),),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SpecialWYAButton(textColor: Colors.white, color: kWYATeal, isLoading: false, text: 'login', onTap: (){
                    context.push('/sign-in');
                  }),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SpecialWYAButton(textColor: Colors.white, color: kWYAOrange, isLoading: false, text: 'register', onTap: (){
                    context.push('/register');
                  }),
                ),
              ),
              Expanded(flex: 2,child: Container(),),
            ],
          ),
        ),
      ),
    );
  }
}


