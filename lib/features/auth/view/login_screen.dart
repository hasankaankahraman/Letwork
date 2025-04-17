import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/main_wrapper/main_wrapper_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubit/login_cubit.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().login(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );
    }
  }

  Future<void> _saveUserSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", true);
    await prefs.setInt("userId", userData['id']);
    await prefs.setString("fullname", userData['fullname']);
    await prefs.setString("username", userData['username']);
    await prefs.setString("email", userData['email']);
  }

  @override
  Widget build(BuildContext context) {
    // Ana tema rengi olarak FF0000 (kırmızı) kullanılıyor
    final themeColor = Color(0xFFFF0000);

    return BlocProvider(
      create: (_) => LoginCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              _saveUserSession(state.userData).then((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainWrapperScreen(),
                  ),
                );
              });
            } else if (state is LoginError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: themeColor,
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    const SizedBox(height: 40),
                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/Letwork_Logo.png',
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Hoşgeldiniz metni
                    Text(
                      'Hoş Geldiniz',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Hesabınıza giriş yapın',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Kullanıcı adı alanı
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: "Kullanıcı Adı",
                        prefixIcon: Icon(Icons.person, color: themeColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        floatingLabelStyle: TextStyle(color: themeColor),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Kullanıcı adı giriniz";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Şifre alanı
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Şifre",
                        prefixIcon: Icon(Icons.lock, color: themeColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: themeColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        floatingLabelStyle: TextStyle(color: themeColor),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return "Şifre en az 6 karakter olmalı";
                        }
                        return null;
                      },
                    ),
                    // Şifremi unuttum linki
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Şifremi unuttum sayfasına yönlendirme
                        },
                        child: Text(
                          "Şifremi Unuttum",
                          style: TextStyle(color: themeColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Giriş yap butonu
                    state is LoginLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF0000),
                      ),
                    )
                        : ElevatedButton(
                      onPressed: () => _login(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Giriş Yap",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Kayıt ol linki
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Hesabınız yok mu?",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Kayıt olun",
                            style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}