import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  static const Color lavender = Color(0xFFEFBBFF);
  static const Color lightPurple = Color(0xFFD896FF);
  static const Color brightPurple = Color(0xFFBE29EC);
  static const Color purple = Color(0xFF800080);
  static const Color darkPurple = Color(0xFF660066);
  static const Color deepBlack = Color(0xFF0A0A0A);
  static const Color cardBlack = Color(0xFF141414);
  static const Color surfaceGrey = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: deepBlack,
        colorScheme: const ColorScheme.dark(
          primary: brightPurple,
          secondary: lightPurple,
          surface: cardBlack,
          onSurface: lavender,
          onSurfaceVariant: Color(0xFFB0B0B0),
          error: Colors.redAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: lavender,
            letterSpacing: 1.2,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: lavender,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: lavender,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFFB0B0B0),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFFB0B0B0),
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            color: Color(0xFF888888),
          ),
        ),
        iconTheme: const IconThemeData(color: lightPurple),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: purple,
            foregroundColor: lavender,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 0,
          ),
        ),
        cardTheme: const CardThemeData(
          color: cardBlack,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: lightPurple,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: brightPurple,
          linearTrackColor: Color(0xFF333333),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: brightPurple,
          inactiveTrackColor: const Color(0xFF333333),
          thumbColor: lavender,
          overlayColor: brightPurple.withValues(alpha: 0.2),
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
