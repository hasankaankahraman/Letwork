import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/business/view/add_business_screen.dart';
import 'package:letwork/features/chat/cubit/chat_cubit.dart';  // ChatCubit'i import ediyoruz.
import 'package:letwork/features/chat/repository/chat_repository.dart';  // ChatRepository'i import ediyoruz.
import 'package:letwork/features/business/cubit/add_business_cubit.dart';
import 'package:letwork/features/chat/view/chat_list_screen.dart';
import 'package:letwork/features/favorites/cubit/favorites_cubit.dart';
import 'package:letwork/features/favorites/view/favorites_screen.dart';
import 'package:letwork/features/home/cubit/home_cubit.dart';
import 'package:letwork/features/home/repository/home_repository.dart';
import 'package:letwork/features/favorites/repository/favorites_repository.dart';
import 'package:letwork/features/home/view/home_screen.dart';
import 'package:letwork/features/main_wrapper/custom_bottom_navbar.dart';
import 'package:letwork/features/profile/view/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';  // MainWrapperScreen'i import ediyoruz.

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  int _currentIndex = 0;
  String? userId;
  late FavoritesCubit _favoritesCubit;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt("userId")?.toString();
    if (mounted) {
      setState(() {
        userId = id;
      });
    }
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });

      // If switching to Favorites tab (index 3), refresh favorites
      if (index == 3 && userId != null) {
        // Add a small delay to ensure the tab has switched first
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _favoritesCubit.loadFavorites(userId!);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeCubit(HomeRepository())),
        BlocProvider(create: (_) => AddBusinessCubit()),
        BlocProvider(
          create: (context) {
            _favoritesCubit = FavoritesCubit(FavoritesRepository());
            // Only load favorites initially if we start on the favorites tab
            if (_currentIndex == 3) {
              _favoritesCubit.loadFavorites(userId!);
            }
            return _favoritesCubit;
          },
        ),
        // Add the ChatCubit provider here
        BlocProvider(create: (_) => ChatCubit(ChatRepository())),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomeScreen(),
            ChatListScreen(),  // ChatListScreen'i buraya ekliyoruz
            AddBusinessScreen(),
            FavoritesScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }
}
