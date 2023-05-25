import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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
  final _nameFormKey =
      GlobalKey<FormState>(debugLabel: '_SettingsPageStateNameForm');
  final _usernameFormKey =
      GlobalKey<FormState>(debugLabel: '_SettingsPageStateUsernameForm');
  final _emailFormKey =
      GlobalKey<FormState>(debugLabel: '_SettingsPageStateEmailForm');
  final TextEditingController usernameTextEditingController =
      TextEditingController();
  final TextEditingController nameTextEditingController =
      TextEditingController();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController errorTextEditingController =
      TextEditingController();

  Uint8List? _image;
  bool isLoading = true;
  bool deleteIsLoading = false;
  bool imageIsLoading = false;
  bool usernameIsLoading = false;
  bool nameIsLoading = false;
  bool emailIsLoading = false;

  void changeProfilePic() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (_image != null) {
        userProvider.changeProfilePicture(_image!);
      }
    });
  }

  Future pickImage(Function changeProfilePicture) async {
    try {
      final XFile? image =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        _image = imageTemp.readAsBytesSync();
        setState(() {
          imageIsLoading = true;
        });
        changeProfilePicture(_image);
        setState((){
          imageIsLoading = false;
        });
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      usernameTextEditingController.text = userProvider.username!;
      nameTextEditingController.text = userProvider.name!;
      emailTextEditingController.text = userProvider.email!;
    });
    isLoading = false;
  }

  Future<void> showChangeUsernameWindow() async {
    errorTextEditingController.text = '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, _) => AlertDialog(
            title: const Text('Change your username'),
            content: Form(
              key: _usernameFormKey,
              child: SizedBox(
                  height: 70,
                  width: 300,
                  child: usernameIsLoading ? const Center(child: CircularProgressIndicator(color: kWYATeal,)) : Column(
                    children: [
                      TextFormField(
                        controller: usernameTextEditingController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your username',
                        ),
                        validator: (value) {
                          if (value == userProvider.username!) {
                            return null;
                          } else if (value == null || value.isEmpty) {
                            return 'Please enter a username.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                        child: TextFormField(
                          controller: errorTextEditingController,
                          readOnly: true,
                          enabled: false,
                          decoration: const InputDecoration(border: InputBorder.none,),
                        ),
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
                  if(usernameTextEditingController.text != userProvider.username){
                    bool isUnique = await userProvider
                        .usernameIsUnique(usernameTextEditingController.text);
                    if (isUnique && _usernameFormKey.currentState!.validate()) {
                      errorTextEditingController.text = '';
                      setState(() {
                        usernameIsLoading = true;
                      });
                      await userProvider
                          .changeUsername(usernameTextEditingController.text);
                      setState(() {
                        usernameIsLoading = false;
                      });
                      Navigator.of(context).pop();
                    } else {
                      errorTextEditingController.text = 'Sorry, that username already exists.';
                    }
                  }else{
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

  Future<void> showChangeNameWindow() async {
    errorTextEditingController.text = '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, _) => AlertDialog(
            title: const Text('Change your name'),
            content: Form(
              key: _nameFormKey,
              child: SizedBox(
                  height: 70,
                  width: 300,
                  child: nameIsLoading ? const Center(child: CircularProgressIndicator(color: kWYATeal,)) : Column(
                    children: [
                      TextFormField(
                        controller: nameTextEditingController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                        ),
                        validator: (value) {
                          if (value == userProvider.name!) {
                            return null;
                          } else if (value == null || value.isEmpty) {
                            return 'Please enter a name.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                        child: TextFormField(
                          controller: errorTextEditingController,
                          readOnly: true,
                          enabled: false,
                          decoration: const InputDecoration(border: InputBorder.none,),
                        ),
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
                  if(nameTextEditingController.text != userProvider.name){
                    if (_nameFormKey.currentState!.validate()) {
                      errorTextEditingController.text = '';
                      setState(() {
                        nameIsLoading = true;
                      });
                      await userProvider
                          .changeName(nameTextEditingController.text);
                      setState(() {
                        nameIsLoading = false;
                      });
                      Navigator.of(context).pop();
                    }
                  }else{
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
    errorTextEditingController.text = '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, _) => AlertDialog(
            title: const Text('Change your email'),
            content: Form(
              key: _emailFormKey,
              child: SizedBox(
                  height: 70,
                  width: 300,
                  child: emailIsLoading ? const Center(child: CircularProgressIndicator(color: kWYATeal,)) : Column(
                    children: [
                      TextFormField(
                        controller: emailTextEditingController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your email',
                        ),
                        validator: (value) {
                          if (value == userProvider.email) {
                            return null;
                          } else if (value == null || value.isEmpty) {
                            return 'Please enter an email.';
                          } else if (!EmailValidator.validate(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                        child: TextFormField(
                          controller: errorTextEditingController,
                          readOnly: true,
                          enabled: false,
                          decoration: const InputDecoration(border: InputBorder.none,),
                        ),
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
                  if(emailTextEditingController.text != userProvider.email){
                    bool isUnique = await userProvider
                        .emailIsUnique(emailTextEditingController.text);
                    if (!isUnique) {
                    errorTextEditingController.text =
                    'Sorry, that email is already linked to another account. ';
                    } else {
                      if (_emailFormKey.currentState!.validate()) {
                        errorTextEditingController.text = '';
                        setState(() {
                          emailIsLoading = true;
                        });
                        await userProvider
                            .changeEmail(emailTextEditingController.text);
                        setState(() {
                          emailIsLoading = false;
                        });
                        Navigator.of(context).pop();
                      }
                    }
                  }else{
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context);
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) => authProvider.loggedIn
          ? Scaffold(
              appBar: const AppBarCustom(),
              body: SafeArea(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: kDeepBlue,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: const [
                                  Text(
                                    'Settings',
                                    style: kH2SourceSansTextStyle,
                                  ),
                                  Icon(Icons.settings),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Profile settings: ',
                                style: kH3SourceSansTextStyle.copyWith(
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                                child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Text('Profile picture:', style: TextStyle(fontWeight: FontWeight.bold),),
                                ),
                                Expanded(
                                  child: Stack(children: [
                                     imageIsLoading ? const CircleAvatar(backgroundColor: Colors.white, radius: 35,child: CircularProgressIndicator(color: kWYATeal,),) :
                                     _image != null
                                         ? CircleAvatar(
                                            radius: 35,
                                            backgroundImage:
                                                MemoryImage(_image!),
                                          )
                                        : CircleAvatar(
                                            radius: 35,
                                            backgroundImage: NetworkImage(
                                                userProvider.photoUrl!)),
                                    Positioned(
                                      bottom: -10,
                                      left: 45,
                                      child: IconButton(
                                        onPressed: () async {
                                          await pickImage(userProvider
                                              .changeProfilePicture);
                                        },
                                        icon: const Icon(
                                          Icons.add_a_photo,
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ],
                            )),
                            Expanded(
                                child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Expanded(child: Text('Username: ', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: showChangeUsernameWindow,
                                    child: TextField(
                                      enabled: false,
                                      readOnly: true,
                                      controller: usernameTextEditingController,
                                      decoration: const InputDecoration(
                                          hoverColor: kPastelBlue,
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: kDeepBlue))),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            Expanded(
                                child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Expanded(child: Text('Name: ', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: showChangeNameWindow,
                                    child: TextField(
                                      enabled: false,
                                      readOnly: true,
                                      controller: nameTextEditingController,
                                      decoration: const InputDecoration(
                                          hoverColor: kPastelBlue,
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: kDeepBlue))),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            Expanded(
                                child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Expanded(child: Text('Email: ', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: showChangeEmailWindow,
                                    child: TextField(
                                      enabled: false,
                                      readOnly: true,
                                      controller: emailTextEditingController,
                                      decoration: const InputDecoration(
                                          hoverColor: kPastelBlue,
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: kDeepBlue))),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            const SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: Text(
                                'Event settings: ',
                                style: kH3SourceSansTextStyle.copyWith(
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                            Expanded(
                                child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Expanded(
                                    child: Text(
                                        'Allow to be added to events automatically: ')),
                                Expanded(
                                  child: OptionSwitch(
                                    boolValue: userProvider.allowAdd!,
                                    onChanged: (value) =>
                                        userProvider.changeAllowAdd(value),
                                  ),
                                ),
                              ],
                            )),
                            const SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: Text(
                                'Match settings: ',
                                style: kH3SourceSansTextStyle.copyWith(
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                            Expanded(
                                child: Text(
                                    'Maximum distance for matches: ${userProvider.maxMatchDistance!}km')),
                            Expanded(
                              child: Slider(
                                value:
                                    userProvider.maxMatchDistance!.toDouble(),
                                min: 1,
                                max: 200,
                                divisions: 20,
                                label: userProvider.maxMatchDistance!
                                    .toDouble()
                                    .toString(),
                                onChanged: (double value) => userProvider
                                    .changeMaxMatchDistance(value.toInt()),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    'Danger zone: ',
                                    style: kH3SourceSansTextStyle.copyWith(
                                        decoration: TextDecoration.underline),
                                  ),
                                  const Icon(
                                    Icons.warning_amber,
                                    color: Colors.amber,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        deleteIsLoading = true;
                                      });
                                      await userProvider.deleteAccount();
                                      setState(() {
                                        deleteIsLoading = false;
                                      });
                                      context.go('/');
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.redAccent)),
                                    child: deleteIsLoading ? const CircularProgressIndicator(color: Colors.white,) : const Text(
                                      'Delete my account',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              bottomNavigationBar: const CustomBottomAppBar(
                current: 'account',
              ),
            )
          : const WelcomeScreen(),
    );
  }
}
