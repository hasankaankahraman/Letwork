import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/core/utils/location_helper.dart';
import 'package:letwork/data/services/category_service.dart';
import 'package:letwork/features/home/cubit/home_cubit.dart';
import 'package:letwork/features/home/widgets/business_card.dart';
import 'package:letwork/features/home/widgets/category_row.dart';
import 'package:geolocator/geolocator.dart';

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

  // Büyükşehirler listesi
  final List<String> majorCities = [
    'İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Adana',
    'Konya', 'Antalya', 'Gaziantep', 'Kocaeli', 'Mersin'
  ];

  // Türkiye'deki tüm şehirler (arama için)
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

    // Kategorileri çek
    CategoryService().fetchFlatCategories().then((list) {
      setState(() {
        categoryList = list;
      });
    });

    // İşletmeleri çek
    context.read<HomeCubit>().loadBusinesses(
      city: selectedCity,
      category: selectedCategory,
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      // Konum izni kontrolü
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konum izni reddedildi')),
          );
          setState(() {
            isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konum izinleri kalıcı olarak reddedildi')),
        );
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      // Konumu al
      final position = await Geolocator.getCurrentPosition();
      final city = await LocationHelper.getCityFromCoordinates(
          position.latitude,
          position.longitude
      );

      if (city != null && city.isNotEmpty) {
        Navigator.pop(context);
        setState(() {
          selectedCity = city;
          isLoadingLocation = false;
        });

        // Ana context'ten HomeCubit'e erişiyoruz
        if (mounted) {
          context.read<HomeCubit>().loadBusinesses(
            city: selectedCity,
            category: selectedCategory,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şehir bilgisi alınamadı')),
        );
        setState(() {
          isLoadingLocation = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konum alınamadı: $e')),
      );
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  void _selectCity() {
    // Modal içinde kullanılacak HomeCubit referansını önceden alıyoruz
    final homeCubit = context.read<HomeCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(modalContext).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Şehir Seçin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Arama Kutusu
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Şehir ara...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFFF0000)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (_) => setModalState(() {}),
                ),
                const SizedBox(height: 16),

                // Konumumu Kullan Butonu
                InkWell(
                  onTap: () {
                    setModalState(() {
                      isLoadingLocation = true;
                    });
                    _getCurrentLocation();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.my_location,
                          color: const Color(0xFFFF0000),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Konumumu Kullan',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        if (isLoadingLocation)
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFFFF0000),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Büyükşehirler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Büyükşehirler Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: majorCities.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(modalContext);
                        setState(() {
                          selectedCity = majorCities[index];
                        });
                        // Ana context yerine önceden alınan HomeCubit referansını kullanıyoruz
                        homeCubit.loadBusinesses(
                          city: selectedCity,
                          category: selectedCategory,
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: majorCities[index] == selectedCity
                              ? const Color(0xFFFF0000)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          majorCities[index],
                          style: TextStyle(
                            color: majorCities[index] == selectedCity
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
                const Text(
                  'Diğer Şehirler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Filtered Cities List
                Expanded(
                  child: ListView.builder(
                    itemCount: _getFilteredCities().length,
                    itemBuilder: (context, index) {
                      final city = _getFilteredCities()[index];
                      return ListTile(
                        title: Text(city),
                        tileColor: city == selectedCity ? Colors.red.shade50 : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onTap: () {
                          Navigator.pop(modalContext);
                          setState(() {
                            selectedCity = city;
                          });
                          // Ana context yerine önceden alınan HomeCubit referansını kullanıyoruz
                          homeCubit.loadBusinesses(
                            city: selectedCity,
                            category: selectedCategory,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _getFilteredCities() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      return allCities
          .where((city) => !majorCities.contains(city))
          .toList();
    }
    return allCities
        .where((city) => city.toLowerCase().contains(query))
        .toList();
  }

  void _onCategorySelected(String cat) {
    setState(() {
      selectedCategory = cat;
    });
    context.read<HomeCubit>().loadBusinesses(
      city: selectedCity,
      category: selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/Letwork_Logo.png',
            fit: BoxFit.contain,
          ),
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
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFFF0000),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  selectedCity,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black54,
                  size: 20,
                ),
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
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.black87,
                  size: 26,
                ),
                onPressed: () {
                  // Bildirimler ekranına git
                },
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
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)),
              ),
            );
          } else if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFFF0000),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Hata: ${state.message}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0000),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      context.read<HomeCubit>().loadBusinesses(
                        city: selectedCity,
                        category: selectedCategory,
                      );
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          } else if (state is HomeLoaded) {
            final businesses = state.businesses;

            return RefreshIndicator(
              color: const Color(0xFFFF0000),
              onRefresh: () async {
                context.read<HomeCubit>().loadBusinesses(
                  city: selectedCity,
                  category: selectedCategory,
                );
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                children: [
                  // Arama Kutusu
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'İşletme ara...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFFF0000),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Kategoriler
                  if (categoryList.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kategoriler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CategoryRow(
                          selected: selectedCategory,
                          categories: categoryList,
                          onSelected: _onCategorySelected,
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // İşletmeler Başlığı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedCategory.isNotEmpty
                            ? '$selectedCategory İşletmeleri'
                            : 'İşletmeler',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.filter_list,
                              size: 16,
                              color: Color(0xFFFF0000),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Filtrele',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // İşletme Listesi
                  if (businesses.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Icon(
                            Icons.store_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "İşletme bulunamadı",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...businesses.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: BusinessCard(bModel: b),
                    )).toList(),
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}