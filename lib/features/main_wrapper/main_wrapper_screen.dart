import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/business/cubit/add_business_cubit.dart';
import 'package:letwork/features/business/view/add_business_screen.dart';
import 'package:letwork/features/chat/view/chat_list_screen.dart';
import 'package:letwork/features/favorites/view/favorites_screen.dart';
import 'package:letwork/features/home/cubit/home_cubit.dart';
import 'package:letwork/features/home/repository/home_repository.dart';
import 'package:letwork/features/home/view/home_screen.dart';
import 'package:letwork/features/profile/view/profile_screen.dart';
import 'custom_bottom_navbar.dart';

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    BlocProvider(
      create: (_) => HomeCubit(HomeRepository()),
      child: const HomeScreen(),
    ),
    const ChatScreen(),
    BlocProvider(
      create: (_) => AddBusinessCubit(),
      child: const AddBusinessScreen(),
    ),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
