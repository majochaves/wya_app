import 'package:firebase_ui_auth/firebase_ui_auth.dart'; // new
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';               // new
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';                 // new
import 'package:wya_final/src/pages/auth.dart';
import 'package:wya_final/src/pages/profile_page.dart';
import 'package:wya_final/src/pages/search_page.dart';
import 'package:wya_final/src/pages/event_creator.dart';
import 'package:wya_final/src/pages/event_editor.dart';
import 'package:wya_final/src/pages/friends_page.dart';
import 'package:wya_final/src/pages/events_page.dart';
import 'package:wya_final/src/pages/event_viewer.dart';
import 'package:wya_final/src/pages/settings_page.dart';
import 'package:wya_final/src/pages/shared_event_viewer.dart';
import 'package:wya_final/src/pages/groups_viewer.dart';

import '/src/pages/account_page.dart';
import 'app_state.dart';                                 // new
import 'src/pages/chat_viewer.dart';
import '/src/pages/chats_page.dart';
import '/src/pages/home_page.dart';
import '/src/pages/notifications_page.dart';

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
            return const AuthGate();
          },
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
          path: 'notifications',
          builder: (context, state) {
            return const NotificationsPage();
          },
        ),
        GoRoute(
          path: 'chats',
          builder: (context, state) {
            return const ChatsPage();
          },
        ),
        GoRoute(
          path: 'viewChat',
          builder: (context, state) {
            return const ChatViewer();
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
          path: 'groups',
          builder: (context, state) {
            return const GroupsViewer();
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
          highlightColor: Colors.lightGreen,
        ),
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: false,
      ),
      routerConfig: _router, // new
    );
  }
}
