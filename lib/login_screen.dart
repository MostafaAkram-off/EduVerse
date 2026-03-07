import 'package:flutter/material.dart';
import 'main_layout.dart & home_screen.dart'; // سنقوم بإنشائها لاحقاً

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Logo Section
            const Icon(
              Icons.shield_moon, // رمز مؤقت للوجو (الدرع)
              size: 80,
              color: Color(0xFF3F51B5),
            ),
            const SizedBox(height: 16),
            const Text(
              'EduVerse',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F51B5),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Training Center Management System',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 48),

            // 2. Inputs
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: const Icon(Icons.visibility_off),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Login Button
            ElevatedButton(
              onPressed: () {
                // الانتقال للشاشة الرئيسية
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainLayout()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'LOGIN',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}