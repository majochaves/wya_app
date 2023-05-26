import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/providers/auth_provider.dart';
import 'package:wya_final/utils/constants.dart';
import 'package:wya_final/widgets/widgets.dart';

typedef OAuthSignIn = void Function();


enum AuthMode { login, register}

class AuthScreen extends StatefulWidget {
  final String mode;
  const AuthScreen({Key? key, required this.mode}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

  AuthMode mode = AuthMode.login;

  bool isLoading = false;

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  late Map<Buttons, OAuthSignIn> authButtons;

  @override
  void initState() {
    super.initState();
    if (widget.mode == 'register') {
      mode = AuthMode.register;
    }
    authButtons = {
      Buttons.Google: () =>
          _handleMultiFactorException(
            _signInWithGoogle,
          ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context);
    return GestureDetector(
      onTap: FocusScope
          .of(context)
          .unfocus,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SafeArea(
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: error.isNotEmpty,
                            child: MaterialBanner(
                              backgroundColor:
                              Theme
                                  .of(context)
                                  .colorScheme
                                  .error,
                              content: SelectableText(error),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      error = '';
                                    });
                                  },
                                  child: const Text(
                                    'dismiss',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                              contentTextStyle:
                              const TextStyle(color: Colors.white),
                              padding: const EdgeInsets.all(10),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                mode == AuthMode.login ? 'Login' : 'Register',
                                style: kH1PattayaTextStyle,
                                textAlign: TextAlign.center,),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              Visibility(visible: mode == AuthMode.register,
                                  child: Column(children: [
                                    TextFormField(
                                      controller: usernameController,
                                      decoration: const InputDecoration(
                                        hintText: 'Username',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.text,
                                      onChanged: (value) async {
                                        if (await authProvider.usernameIsUnique(
                                            value) == false) {
                                          setState(() {
                                            error = 'Username already exists';
                                          });
                                        } else {
                                          setState(() {
                                            error = '';
                                          });
                                        }
                                      },
                                      validator: (value) =>
                                      value != null && value.isNotEmpty
                                          ? null
                                          : 'Required',
                                    ),
                                    const SizedBox(height: 20),
                                  ],)),
                              TextFormField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  hintText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                validator: (value) =>
                                value != null && value.isNotEmpty
                                    ? null
                                    : 'Required',
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: 'Password',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                value != null && value.isNotEmpty
                                    ? null
                                    : 'Required',
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: SpecialWYAButton(
                              color: kWYATeal,
                              textColor: Colors.white,
                              text: mode == AuthMode.login
                                  ? 'login'
                                  : 'register',
                              isLoading: isLoading,
                              onTap: mode == AuthMode.login
                                  ? _emailAndPassword
                                  : _registerUser,
                            ),
                          ),
                          TextButton(
                            onPressed: _resetPassword,
                            child: const Text('Forgot password?'),
                          ),
                          ...authButtons.keys
                              .map(
                                (button) =>
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 5),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: isLoading
                                        ? Container(
                                      color: Colors.grey[200],
                                      height: 50,
                                      width: double.infinity,
                                    )
                                        : SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: SignInButton(
                                        button,
                                        onPressed: authButtons[button]!,
                                      ),
                                    ),
                                  ),
                                ),
                          )
                              .toList(),
                          const SizedBox(height: 20),
                          RichText(
                            text: TextSpan(
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyLarge,
                              children: [
                                TextSpan(
                                  text: mode == AuthMode.login
                                      ? "Don't have an account? "
                                      : 'You have an account? ',
                                ),
                                TextSpan(
                                  text: mode == AuthMode.login
                                      ? 'Register now'
                                      : 'Click to login',
                                  style: const TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      setState(() {
                                        mode = mode == AuthMode.login
                                            ? AuthMode.register
                                            : AuthMode.login;
                                      });
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _resetPassword() async {
    String? email;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email'),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
              ),
            ],
          ),
        );
      },
    );

    if (email != null) {
      try {
        await auth.sendPasswordResetEmail(email: email!);
        ScaffoldSnackbar.of(context).show('Password reset email is sent');
      } catch (e) {
        ScaffoldSnackbar.of(context).show('Error resetting');
      }
    }
  }

  Future<void> _handleMultiFactorException(
      Future<void> Function() authFunction,) async {
    setIsLoading();
    try {
      await authFunction();
    } on FirebaseAuthMultiFactorException catch (e) {
      setState(() {
        error = '${e.message}';
      });
      final firstHint = e.resolver.hints.first;
      if (firstHint is! PhoneMultiFactorInfo) {
        return;
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } catch (e) {
      setState(() {
        error = '$e';
      });
    }
    setIsLoading();
  }

  Future<void> _emailAndPassword() async {
    setState(() {
      isLoading = true;
    });
    if ((formKey.currentState?.validate() ?? false) && error.isEmpty) {
      final authProvider = Provider.of<Auth>(context, listen: false);
      String res = await authProvider.loginUser(
          emailController.text, passwordController.text);
      if (res == 'success') {
        context.go('/');
      } else {
        setState(() {
          error = res;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _registerUser() async {
    setState(() {
      isLoading = true;
    });
    if ((formKey.currentState?.validate() ?? false) && error.isEmpty) {
      final authProvider = Provider.of<Auth>(context, listen: false);
      String res = await authProvider.registerUser(
          emailController.text, usernameController.text,
          passwordController.text);
      if (res == 'success') {
        context.go('/');
      } else {
        setState(() {
          error = res;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    final authProvider = Provider.of<Auth>(context, listen: false);
    String res = await authProvider.loginUserWithGoogle();
    if (res == 'success') {
      context.go('/');
    } else {
      setState(() {
        error = res;
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}

class ScaffoldSnackbar {
  ScaffoldSnackbar(this._context);

  factory ScaffoldSnackbar.of(BuildContext context) {
    return ScaffoldSnackbar(context);
  }

  final BuildContext _context;

  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
