import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'utils/app_colors.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try initializing Firebase (Safe for Web and Native)
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    NotificationService().initNotifications();
  } on Object catch (e) {
    debugPrint("⚠️ Firebase initialization notice: $e");
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Light icons (white time/wifi/battery) for dark header
      statusBarBrightness: Brightness.dark,      // For iOS light text
      systemNavigationBarColor: AppColors.deepNavy,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ApeBaasApp());
}

class ApeBaasApp extends StatelessWidget {
  const ApeBaasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'අපේ බාස්',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.deepNavy,
          primary: AppColors.deepNavy,
          secondary: AppColors.navyLight,
          surface: AppColors.surfaceBg,
        ),
        scaffoldBackgroundColor: AppColors.surfaceBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.deepNavy,
          foregroundColor: Colors.white,
          toolbarHeight: 64,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepNavy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}