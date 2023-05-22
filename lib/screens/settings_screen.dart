import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/providers/user_provider.dart';
import 'package:wya_final/utils/constants.dart';
import '../providers/auth_provider.dart';
import '/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:email_validator/email_validator.dart';

import 'welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameFormKey = GlobalKey<FormState>(debugLabel: '_SettingsPageStateNameForm');
  final _usernameFormKey = GlobalKey<FormState>(debugLabel: '_SettingsPageStateUsernameForm');
  final _emailFormKey = GlobalKey<FormState>(debugLabel: '_SettingsPageStateEmailForm');
  final TextEditingController usernameTextEditingController = TextEditingController();
  final TextEditingController nameTextEditingController = TextEditingController();
  final TextEditingController emailTextEditingController = TextEditingController();

  Uint8List? _image;
  bool isLoading = true;

  void changeProfilePic() async{
    WidgetsBinding.instance.addPostFrameCallback((_){
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if(_image != null){
        userProvider.changeProfilePicture(_image!);
      }
    });
  }

  Future pickImage(Function changeProfilePicture) async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        _image = imageTemp.readAsBytesSync();
        changeProfilePicture(_image);
      }
      );
    } on PlatformException catch(e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData(){
    WidgetsBinding.instance.addPostFrameCallback((_){
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      usernameTextEditingController.text = userProvider.username!;
      nameTextEditingController.text = userProvider.name!;
      emailTextEditingController.text = userProvider.email!;
    });
    isLoading = false;
  }

  Future<void> showChangeUsernameWindow() async {
    String error = '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, _) => AlertDialog(
            title: const Text('Change your username'),
            content: Form(
              key: _usernameFormKey,
              child: SizedBox(height:70, width: 300,
                  child:
                  Column(
                    children: [
                      TextFormField(
                        controller: usernameTextEditingController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your username',
                        ),
                        validator: (value) {
                          if (value == userProvider.username!){
                            return null;
                          }else if(value == null || value.isEmpty){
                            return 'Please enter a username.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10, child:
                      Text(error),
                      )
                    ],
                  )),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  usernameTextEditingController.text = userProvider.username!;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Done'),
                onPressed: () async {
                  bool isUnique = await userProvider.usernameIsUnique(usernameTextEditingController.text);
                  if (isUnique && _usernameFormKey.currentState!.validate()) {
                    error = '';
                    await userProvider.changeUsername(usernameTextEditingController.text);
                    Navigator.of(context).pop();
                  }else{
                    error = 'Sorry, that username already exists.';
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showChangeNameWindow() async {
    String error = '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, _) => AlertDialog(
            title: const Text('Change your name'),
            content: Form(
              key: _nameFormKey,
              child: SizedBox(height:70, width: 300,
                  child:
                  Column(
                    children: [
                      TextFormField(
                        controller: nameTextEditingController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                        ),
                        validator: (value) {
                          if (value == userProvider.name!){
                            return null;
                          }else if(value == null || value.isEmpty){
                            return 'Please enter a name.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10, child:
                      Text(error),
                      )
                    ],
                  )),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  nameTextEditingController.text = userProvider.name!;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Done'),
                onPressed: () async {
                  if (_nameFormKey.currentState!.validate()) {
                    await userProvider.changeName(nameTextEditingController.text);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showChangeEmailWindow() async {
    String error = '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, _) => AlertDialog(
            title: const Text('Change your email'),
            content: Form(
              key: _emailFormKey,
              child: SizedBox(height:70, width: 300,
                  child:
                  Column(
                    children: [
                      TextFormField(
                        controller: emailTextEditingController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your email',
                        ),
                        validator: (value) {
                          if (value == userProvider.email){
                            return null;
                          }else if(value == null || value.isEmpty){
                            return 'Please enter an email.';
                          }else if(!EmailValidator.validate(value)) {
                            return 'Please enter a valid email address';
                          }return null;
                        },
                      ),
                      SizedBox(height: 10, child:
                      Text(error),
                      )
                    ],
                  )),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  emailTextEditingController.text = userProvider.email!;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Done'),
                onPressed: () async {
                  bool isUnique = await userProvider.emailIsUnique(emailTextEditingController.text);
                  if(!isUnique){
                    error = 'Sorry, that email is already linked to another account. ';
                  }else{
                    if (_emailFormKey.currentState!.validate()) {
                      await userProvider.changeEmail(emailTextEditingController.text);
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context);
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) => authProvider.loggedIn ? Scaffold(
        appBar: const AppBarCustom(),
        body: SafeArea(
          child: isLoading ? const Center(child: CircularProgressIndicator(color: kDeepBlue,),) : Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: Row(mainAxisSize:MainAxisSize.max,
                  children: const [
                    Text('Settings', style: kH2SourceSansTextStyle,),
                    Icon(Icons.settings),
                  ],
                ),),
                Expanded(child: Text('Profile settings: ', style: kH3SourceSansTextStyle.copyWith(decoration: TextDecoration.underline),),),
                Expanded(child: Row(mainAxisSize:MainAxisSize.max, children: [
                  const Expanded(child: Text('Profile picture:'), flex: 2,),
                  Expanded(
                    child: Stack(children: [
                      _image != null
                          ? CircleAvatar(
                        radius: 35,
                        backgroundImage: MemoryImage(_image!),
                      )
                          : CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(userProvider.photoUrl!)
                      ),
                      Positioned(
                        bottom: -10,
                        left: 45,
                        child: IconButton(
                          onPressed: () async {await pickImage(userProvider.changeProfilePicture);},
                          icon: const Icon(Icons.add_a_photo,),
                        ),
                      ),
                    ]),
                  ),
                ],)),
                Expanded(child: Row(mainAxisSize:MainAxisSize.max,
                  children: [
                    const Expanded(child: Text('Username: ')),
                    Expanded(
                      flex: 2,
                      child: InkWell(onTap: showChangeUsernameWindow, child:
                        TextField(
                          enabled: false,
                          readOnly: true,
                          controller: usernameTextEditingController,
                          decoration: const InputDecoration(
                          hoverColor: kPastelBlue,
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: kDeepBlue))
                        ),),),
                    ),
                  ],
                )),
                Expanded(child: Row(mainAxisSize:MainAxisSize.max,
                  children: [
                    const Expanded(child: Text('Name: ')),
                    Expanded(
                      flex: 2,
                      child: InkWell(onTap: showChangeNameWindow, child:
                      TextField(
                        enabled: false,
                        readOnly: true,
                        controller: nameTextEditingController,
                        decoration: const InputDecoration(
                            hoverColor: kPastelBlue,
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: kDeepBlue))
                        ),),),
                    ),
                  ],
                )),
                Expanded(child: Row(mainAxisSize:MainAxisSize.max,
                  children: [
                    const Expanded(child: Text('Email: ')),
                    Expanded(
                      flex: 2,
                      child: InkWell(onTap: showChangeEmailWindow, child:
                      TextField(
                        enabled: false,
                        readOnly: true,
                        controller: emailTextEditingController,
                        decoration: const InputDecoration(
                            hoverColor: kPastelBlue,
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: kDeepBlue))
                        ),),),
                    ),
                  ],
                )),
                const SizedBox(height: 20,),
                Expanded(child: Text('Event settings: ', style: kH3SourceSansTextStyle.copyWith(decoration: TextDecoration.underline),),),
                Expanded(child: Row(mainAxisSize:MainAxisSize.max,
                  children: [
                    const Expanded(child: Text('Allow to be added to events automatically: ')),
                    Expanded(
                      child: OptionSwitch(boolValue: userProvider.allowAdd!, onChanged: (value) => userProvider.changeAllowAdd(value),),
                    ),
                  ],
                )),
                const SizedBox(height: 20,),
                Expanded(child: Text('Match settings: ', style: kH3SourceSansTextStyle.copyWith(decoration: TextDecoration.underline),),),
                Expanded(child: Text('Maximum distance for matches: ${userProvider.maxMatchDistance!}km')),
                Expanded(child: Slider(
                  value: userProvider.maxMatchDistance!.toDouble(),
                  min: 1,
                  max: 200,
                  divisions: 20,
                  label: userProvider.maxMatchDistance!.toDouble().toString(),
                  onChanged: (double value) => userProvider.changeMaxMatchDistance(value.toInt()),
                ),),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomAppBar(current: 'account',),
      ) : const WelcomeScreen(),
    );
  }
}
