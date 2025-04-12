import 'package:flutter/material.dart';
import 'package:letwork/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/view/login_screen.dart';
import 'features/main_wrapper/main_wrapper_screen.dart';

void main() {
  runApp(const LetWorkApp());
}

class LetWorkApp extends StatelessWidget {
  const LetWorkApp({super.key});

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LetWork',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Başlangıç route'u
      onGenerateRoute: AppRouter.generateRoute, // Route'ları AppRouter ile yönetiyoruz
      home: FutureBuilder<bool>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            return const MainWrapperScreen(); // ✅ Oturum varsa tab bar ekranı
          } else {
            return const LoginScreen(); // ❌ Oturum yoksa login ekranı
          }
        },
      ),
    );
  }
}
