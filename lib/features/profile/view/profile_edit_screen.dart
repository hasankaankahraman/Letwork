import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:letwork/features/profile/cubit/profile_cubit.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('fullname') ?? '';
    _usernameController.text = prefs.getString('username') ?? '';
    _emailController.text = prefs.getString('email') ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFFFF0000);

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) async {
        if (state is ProfileUpdated) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profil güncellendi. Lütfen tekrar giriş yapın."),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profili Düzenle"),
          centerTitle: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFEEEEEE),
                      child: Icon(Icons.person_outline_rounded, size: 50, color: primaryColor),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt_outlined, size: 16, color: primaryColor),
                      label: const Text("Fotoğrafı Değiştir", style: TextStyle(color: primaryColor)),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      controller: _nameController,
                      label: "Ad Soyad",
                      icon: Icons.person_outline,
                      validator: (val) => val == null || val.isEmpty ? "Lütfen adınızı giriniz" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _usernameController,
                      label: "Kullanıcı Adı",
                      icon: Icons.alternate_email,
                      validator: (val) => val == null || val.isEmpty ? "Lütfen kullanıcı adınızı giriniz" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: "E-posta",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Lütfen e-posta adresinizi giriniz";
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return "Geçerli bir e-posta giriniz";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Yeni Şifre (opsiyonel)",
                        prefixIcon: const Icon(Icons.lock_outline, color: primaryColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (val) {
                        if (val != null && val.isNotEmpty && val.length < 6) {
                          return "Şifre en az 6 karakter olmalı";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, state) {
                        final isLoading = state is ProfileUpdating;
                        return SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<ProfileCubit>().updateUserProfile(
                                  fullname: _nameController.text,
                                  username: _usernameController.text,
                                  email: _emailController.text,
                                  password: _passwordController.text.isEmpty
                                      ? null
                                      : _passwordController.text,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: isLoading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : const Text("KAYDET", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF0000)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
    );
  }
}
