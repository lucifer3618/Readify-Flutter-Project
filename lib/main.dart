import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:readify/features/home_screen/home_screen.dart';
import 'package:readify/features/message_screen/chat_page.dart';
import 'package:readify/features/notification_screen/notification_screen.dart';
import 'package:readify/features/onboarding_screen/onboarding_screen.dart';
import 'package:readify/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readify/providers/user_provider.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/services/helper_function.dart';
import 'package:readify/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Functions to listen to background notifications
Future _firebaseBackgorundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    log("Some message recived");
  }
}

void _onMessageReceived(RemoteMessage message) {
  if (message.data.isNotEmpty) {
    log("Message data: ${message.data}");
  }
}

void main() async {
  // Initialize firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  // Initialize .env
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!, anonKey: dotenv.env['SUPABASE_ANNOKEY']!);

  // Listen to fcm token refresh event and update db
  FirebaseMessaging.instance.onTokenRefresh.listen(
    (newToken) {
      DatabaseService().setFMCTocken(newToken);
    },
  );

  // Initialize notification Services
  await NotificationService.initNotifications();
  await NotificationService.initLocalNotifications();

  // Listen to firebase notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgorundMessage);
  FirebaseMessaging.onMessage.listen(_onMessageReceived);

  // Change route accroding to background message
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    if (message.data["type"] == "chat") {
      Map<String, dynamic> user = await DatabaseService().getUserById(message.data["sender_id"]);
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => ChatPage(
          reiciverData: user,
        ),
      ));
    } else {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
      ));
    }
  });

  // Check for login
  bool isLoggedIn = await HelperFunction.getUserLoginStatus() ?? false;
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => UserProvider()),
    ],
    child: MyApp(
      isLoggedIn: isLoggedIn,
    ),
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      debugShowCheckedModeBanner: false,
      title: "Onboarding Screen",
      home: isLoggedIn ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
