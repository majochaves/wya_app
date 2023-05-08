import 'package:firebase_ui_auth/firebase_ui_auth.dart'; // new
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';               // new
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';                 // new
import 'package:wya_final/profile_page.dart';
import 'package:wya_final/search_page.dart';
import 'package:wya_final/src/event_creator.dart';
import 'package:wya_final/src/event_editor.dart';
import 'package:wya_final/src/friends_page.dart';
import 'package:wya_final/src/events_page.dart';
import 'package:wya_final/src/event_viewer.dart';
import 'package:wya_final/src/settings_page.dart';
import 'package:wya_final/src/shared_event_viewer.dart';

import 'account_page.dart';
import 'app_state.dart';                                 // new
import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const App()),
  ));
}
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (context, state) {
            return SignInScreen(
              actions: [
                ForgotPasswordAction(((context, email) {
                  final uri = Uri(
                    path: '/sign-in/forgot-password',
                    queryParameters: <String, String?>{
                      'email': email,
                    },
                  );
                  context.push(uri.toString());
                })),
                AuthStateChangeAction(((context, state) {
                  if (state is SignedIn || state is UserCreated) {
                    var user = (state is SignedIn)
                        ? state.user
                        : (state as UserCreated).credential.user;
                    if (user == null) {
                      return;
                    }
                    if (state is UserCreated) {
                      user.updateDisplayName(user.email!.split('@')[0]);
                    }
                    if (!user.emailVerified) {
                      user.sendEmailVerification();
                      const snackBar = SnackBar(
                          content: Text(
                              'Please check your email to verify your email address'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                    context.pushReplacement('/');
                  }
                })),
              ],
            );
          },
          routes: [
            GoRoute(
              path: 'forgot-password',
              builder: (context, state) {
                final arguments = state.queryParameters;
                return ForgotPasswordScreen(
                  email: arguments['email'],
                  headerMaxExtent: 200,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'profile-screen',
          builder: (context, state) {
            return ProfileScreen(
              providers: const [],
              actions: [
                SignedOutAction((context) {
                  context.pushReplacement('/');
                }),
              ],
            );
          },
        ),
        GoRoute(
          path: 'search',
          builder: (context, state) {
            return const SearchPage();
          },
        ),
        GoRoute(
          path: 'account',
          builder: (context, state) {
            return const AccountPage();
          },
        ),
        GoRoute(
          path: 'friends',
          builder: (context, state) {
            return const FriendsPage();
          },
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) {
            return const SettingsPage();
          },
        ),
        GoRoute(
          path: 'events',
          builder: (context, state) {
            return const EventsPage();
          },
        ),
        GoRoute(
          path: 'newEvent',
          builder: (context, state) {
            return const EventCreator();
          },
        ),
        GoRoute(
          path: 'viewEvent',
          builder: (context, state) {
            return const EventViewer();
          },
        ),
        GoRoute(
          path: 'editEvent',
          builder: (context, state) {
            return const EventEditor();
          },
        ),
        GoRoute(
          path: 'viewSharedEvent',
          builder: (context, state) {
            return const SharedEventViewer();
          },
        ),
        GoRoute(
          path: 'profile:userId',
          builder: (context, state) {
            return ProfilePage(
              uid: state.pathParameters['userId']
            );
          },
        ),
      ],
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WYA',
      theme: ThemeData(
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
          highlightColor: Colors.deepPurple,
        ),
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      routerConfig: _router, // new
    );
  }
}
