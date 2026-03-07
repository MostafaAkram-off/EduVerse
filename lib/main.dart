import 'package:flutter/material.dart';
import 'login_screen.dart'; // سنقوم بإنشائها في الخطوة التالية

void main() {
  runApp(const EduVerseApp());
}

class EduVerseApp extends StatelessWidget {
  const EduVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduVerse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // الألوان الأساسية حسب الهوية البصرية المقترحة
        primaryColor: const Color(0xFF3F51B5), // Indigo Blue
        scaffoldBackgroundColor: const Color(0xFFF5F5F7), // Grey White background
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF3F51B5),
          secondary: const Color(0xFFFF6F61), // Coral Orange for Actions
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        fontFamily: 'Roboto', // يفضل استخدام خط مثل "Cairo" للعربي
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}