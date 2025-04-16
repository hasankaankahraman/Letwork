import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';  // BlocProvider'ı import ediyoruz.
import 'package:letwork/features/chat/cubit/chat_cubit.dart';  // ChatCubit'i import ediyoruz.
import 'package:letwork/features/chat/repository/chat_repository.dart';  // ChatRepository'i import ediyoruz.
import 'package:letwork/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/view/login_screen.dart';
import 'features/main_wrapper/main_wrapper_screen.dart';

void main() {
  runApp(const LetWorkApp());
}

class LetWorkApp extends StatelessWidget {
  const LetWorkApp({super.key});

  // Kullanıcının giriş yapıp yapmadığını kontrol eden asenkron fonksiyon
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false; // 'isLoggedIn' key'ini kullanarak login durumunu kontrol ediyoruz
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Diğer BlocProvider'lar
        BlocProvider(create: (context) => ChatCubit(ChatRepository())),  // ChatCubit'i burada sağlıyoruz
      ],
      child: MaterialApp(
        title: 'LetWork',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,  // Material3 kullanımı
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/', // Başlangıçta hangi route'un kullanılacağını belirtiyoruz
        onGenerateRoute: AppRouter.generateRoute, // Tüm route'ları AppRouter sınıfı ile yönetiyoruz
        home: FutureBuilder<bool>(
          future: checkLoginStatus(),  // Kullanıcının login durumunu kontrol ediyoruz
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); // Veriler yüklenirken gösterilecek ekran
            } else if (snapshot.hasData && snapshot.data == true) {
              return const MainWrapperScreen(); // Kullanıcı giriş yapmışsa MainWrapperScreen'e yönlendiriyoruz
            } else {
              return const LoginScreen(); // Kullanıcı giriş yapmamışsa LoginScreen'e yönlendiriyoruz
            }
          },
        ),
      ),
    );
  }
}
