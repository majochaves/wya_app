import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/event_provider.dart';
import 'providers/group_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/user_provider.dart';

import 'pages/auth.dart';
import 'pages/profile_page.dart';
import 'pages/search_page.dart';
import 'pages/event_creator.dart';
import 'pages/event_editor.dart';
import 'pages/friends_page.dart';
import 'pages/events_page.dart';
import 'pages/event_viewer.dart';
import 'pages/settings_page.dart';
import 'pages/shared_event_viewer.dart';
import 'pages/groups_viewer.dart';
import 'pages/account_page.dart';
import 'pages/chat_viewer.dart';
import 'pages/chats_page.dart';
import 'pages/home_page.dart';
import 'pages/notifications_page.dart';

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
      child:  const App(),
    ),
  );
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
