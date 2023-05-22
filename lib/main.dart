import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wya_final/screens/welcome_screen.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/event_provider.dart';
import 'providers/group_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/user_provider.dart';

import 'screens/auth_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/event_editing_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/events_screen.dart';
import 'screens/event_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/event_widgets/shared_event_viewer.dart';
import 'screens/groups_screen.dart';
import 'screens/account_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/chats_screen.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (context) => Auth(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProxyProvider<UserProvider, GroupProvider>(
          create: (context) => GroupProvider(),
            update: (_, userProvider, groupProvider){
              groupProvider?.update(userProvider);
              return groupProvider!;
            }
        ),
        ChangeNotifierProxyProvider<UserProvider, EventProvider>(
          create: (context) => EventProvider(),
          update: (_, userProvider, eventProvider){
            eventProvider?.update(userProvider);
            return eventProvider!;
          }
        ),
        ChangeNotifierProxyProvider<EventProvider, NotificationProvider>(
          create: (context) => NotificationProvider(),
          update: (_, eventProvider, notificationProvider){
            notificationProvider?.update(eventProvider);
            return notificationProvider!;
          }
        ),

        ChangeNotifierProxyProvider<UserProvider, ChatProvider>(
          create: (context) => ChatProvider(),
          update: (_, userProvider, chatProvider){
            chatProvider?.update(userProvider);
            return chatProvider!;
          }
        ),
      ],
      child: const App(),
    ),
  );
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => FirebaseAuth.instance.currentUser == null ? const WelcomeScreen() : const HomeScreen(),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (context, state) {
            return const AuthScreen();
          },
        ),
        GoRoute(
          path: 'search',
          builder: (context, state) {
            return const SearchScreen();
          },
        ),
        GoRoute(
          path: 'notifications',
          builder: (context, state) {
            return const NotificationsScreen();
          },
        ),
        GoRoute(
          path: 'chats',
          builder: (context, state) {
            return const ChatsScreen();
          },
        ),
        GoRoute(
          path: 'viewChat',
          builder: (context, state) {
            return const ChatScreen();
          },
        ),
        GoRoute(
          path: 'account',
          builder: (context, state) {
            return const AccountScreen();
          },
        ),
        GoRoute(
          path: 'friends',
          builder: (context, state) {
            return const FriendsScreen();
          },
        ),
        GoRoute(
          path: 'groups',
          builder: (context, state) {
            return const GroupsScreen();
          },
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) {
            return const SettingsScreen();
          },
        ),
        GoRoute(
          path: 'events',
          builder: (context, state) {
            return const EventsScreen();
          },
        ),
        GoRoute(
          path: 'eventEditor',
          builder: (context, state) {
            return const EventEditingScreen();
          },
        ),
        GoRoute(
          path: 'viewEvent',
          builder: (context, state) {
            return const EventScreen();
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
            return ProfileScreen(
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
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print('Error');
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
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

        // Otherwise, show something whilst waiting for initialization to complete
        return const Center(child:CircularProgressIndicator());
      },
    );
  }
}
