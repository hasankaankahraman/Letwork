import 'package:flutter/material.dart';
import 'package:letwork/features/business/view/map_location_picker_screen.dart';  // MapLocationPickerScreen'i import ediyoruz.
import 'package:letwork/features/business/view/add_business_screen.dart'; // AddBusinessScreen'i import ediyoruz.
import 'package:letwork/features/auth/view/login_screen.dart'; // LoginScreen'i import ediyoruz.
import 'package:letwork/features/main_wrapper/main_wrapper_screen.dart'; // MainWrapperScreen'i import ediyoruz.

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Route'larımıza göre işlemler yapıyoruz
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MainWrapperScreen());  // Ana ekran
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());  // Login ekranı
      case '/map':
        return MaterialPageRoute(builder: (_) => const MapLocationPickerScreen());  // Harita ekranı
      case '/add_business':
        return MaterialPageRoute(builder: (_) => const AddBusinessScreen());  // İşletme ekleme ekranı
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());  // Tanımlanamayan route'lar için default olarak LoginScreen
    }
  }
}
