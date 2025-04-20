import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/chat/cubit/chat_cubit.dart';
import 'package:letwork/features/chat/repository/chat_repository.dart';
import 'package:letwork/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart'; // ← bunu ekledik
import 'features/auth/view/login_screen.dart';
import 'features/main_wrapper/main_wrapper_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // async işlemlerden önce gerekli
  await initializeDateFormatting('tr_TR', null); // ← locale yüklemesi
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChatCubit(ChatRepository())),
      ],
      child: MaterialApp(
        title: 'LetWork',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
        home: FutureBuilder<bool>(
          future: checkLoginStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data == true) {
              return const MainWrapperScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
