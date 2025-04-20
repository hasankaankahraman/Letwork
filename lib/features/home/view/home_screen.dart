import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:letwork/data/services/category_service.dart';
import 'package:letwork/features/home/cubit/home_cubit.dart';
import 'package:letwork/features/home/widgets/category_row.dart';
import 'package:letwork/features/home/widgets/city_selector_modal.dart';
import 'package:letwork/features/home/widgets/business_list.dart';
import 'package:letwork/features/home/widgets/section_header.dart';
import 'package:letwork/features/search/cubit/search_cubit.dart';
import 'package:letwork/features/search/repository/search_repository.dart';
import 'package:letwork/features/search/view/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCity = "Konya";
  String selectedCategory = "";
  List<String> categoryList = [];
  bool isLoadingLocation = false;
  TextEditingController searchController = TextEditingController();
  String? userId;

  final List<String> majorCities = [
    'İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Adana',
    'Konya', 'Antalya', 'Gaziantep', 'Kocaeli', 'Mersin'
  ];

  final List<String> allCities = [
    'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya', 'Ankara', 'Antalya',
    'Artvin', 'Aydın', 'Balıkesir', 'Bilecik', 'Bingöl', 'Bitlis', 'Bolu',
    'Burdur', 'Bursa', 'Çanakkale', 'Çankırı', 'Çorum', 'Denizli', 'Diyarbakır',
    'Edirne', 'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir', 'Gaziantep', 'Giresun',
    'Gümüşhane', 'Hakkari', 'Hatay', 'Isparta', 'Mersin', 'İstanbul', 'İzmir',
    'Kars', 'Kastamonu', 'Kayseri', 'Kırklareli', 'Kırşehir', 'Kocaeli', 'Konya',
    'Kütahya', 'Malatya', 'Manisa', 'Kahramanmaraş', 'Mardin', 'Muğla', 'Muş',
    'Nevşehir', 'Niğde', 'Ordu', 'Rize', 'Sakarya', 'Samsun', 'Siirt', 'Sinop',
    'Sivas', 'Tekirdağ', 'Tokat', 'Trabzon', 'Tunceli', 'Şanlıurfa', 'Uşak',
    'Van', 'Yozgat', 'Zonguldak', 'Aksaray', 'Bayburt', 'Karaman', 'Kırıkkale',
    'Batman', 'Şırnak', 'Bartın', 'Ardahan', 'Iğdır', 'Yalova', 'Karabük',
    'Kilis', 'Osmaniye', 'Düzce'
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt("userId")?.toString();
    if (id == null) return;

    setState(() => userId = id);

    final cats = await CategoryService().fetchFlatCategories();
    setState(() => categoryList = cats);

    context.read<HomeCubit>().loadBusinesses(
      userId: userId!,
      city: selectedCity,
      category: selectedCategory,
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => isLoadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Konum izni reddedildi');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Konum izinleri kalıcı olarak reddedildi');
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      // 🔥 SADECE şehir adı çekiyoruz (city > town > village)
      final url = "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}";
      final response = await Dio().get(url);
      final address = response.data['address'];
      final city = address?['city'] ?? address?['town'] ?? address?['village'];

      if (city != null && city.isNotEmpty) {
        Navigator.pop(context);
        setState(() => selectedCity = city);

        context.read<HomeCubit>().loadBusinesses(
          userId: userId!,
          city: selectedCity,
          category: selectedCategory,
        );
      } else {
        _showSnackBar('Şehir bilgisi alınamadı');
      }
    } catch (e) {
      _showSnackBar('Konum alınamadı: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingLocation = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _selectCity() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CitySelectorModal(
        selectedCity: selectedCity,
        onCitySelected: (city) {
          setState(() => selectedCity = city);
          context.read<HomeCubit>().loadBusinesses(
            userId: userId!,
            city: city,
            category: selectedCategory,
          );
        },
        onUseCurrentLocation: _getCurrentLocation,
        majorCities: majorCities,
        allCities: allCities,
        searchController: searchController,
        isLoadingLocation: isLoadingLocation,
      ),
    );
  }

  void _onCategorySelected(String cat) {
    setState(() => selectedCategory = cat);
    context.read<HomeCubit>().loadBusinesses(
      userId: userId!,
      city: selectedCity,
      category: selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0000))));
          } else if (state is HomeError) {
            return _buildError(state.message);
          } else if (state is HomeLoaded) {
            return RefreshIndicator(
              color: const Color(0xFFFF0000),
              onRefresh: () async {
                context.read<HomeCubit>().loadBusinesses(
                  userId: userId!,
                  city: selectedCity,
                  category: selectedCategory,
                );
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 20),
                  if (categoryList.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kategoriler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        CategoryRow(
                          selected: selectedCategory,
                          categories: categoryList,
                          onSelected: _onCategorySelected,
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: selectedCategory.isNotEmpty ? '$selectedCategory İşletmeleri' : 'İşletmeler',
                    onFilterTap: () {},
                  ),
                  const SizedBox(height: 16),
                  BusinessList(businesses: state.businesses),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0, // Bu satırı ekleyin
      elevation: 0,
      backgroundColor: Colors.white,
      leadingWidth: 120,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Image.asset('assets/Letwork_Logo.png', fit: BoxFit.contain),
      ),
      title: GestureDetector(
        onTap: _selectCity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, color: Color(0xFFFF0000), size: 18),
              const SizedBox(width: 4),
              Text(selectedCity, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: Colors.black54, size: 20),
            ],
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black87, size: 26),
              onPressed: () {},
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF0000),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchField() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => SearchCubit(SearchRepository()),
              child: const SearchScreen(),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: const [
            Icon(Icons.search, color: Color(0xFFFF0000)),
            SizedBox(width: 10),
            Text('İşletme ara...', style: TextStyle(color: Colors.black54, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF0000), size: 48),
          const SizedBox(height: 16),
          Text("Hata: $message", style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF0000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              context.read<HomeCubit>().loadBusinesses(
                userId: userId!,
                city: selectedCity,
                category: selectedCategory,
              );
            },
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
