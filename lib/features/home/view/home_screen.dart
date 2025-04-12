import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/data/services/category_service.dart';
import 'package:letwork/features/home/cubit/home_cubit.dart';
import 'package:letwork/features/home/widgets/business_card.dart';
import 'package:letwork/features/home/widgets/category_row.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCity = "Konya";
  String selectedCategory = "";
  List<String> categoryList = [];

  final List<String> cityList = ['Konya', 'Ankara', 'İstanbul', 'İzmir'];

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

  void _selectCity() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: cityList.map((city) {
          return ListTile(
            title: Text(city),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                selectedCity = city;
              });
              context.read<HomeCubit>().loadBusinesses(
                city: selectedCity,
                category: selectedCategory,
              );
            },
          );
        }).toList(),
      ),
    );
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
        title: GestureDetector(
          onTap: _selectCity,
          child: Row(
            children: [
              const Icon(Icons.location_on),
              const SizedBox(width: 4),
              Text(selectedCity),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeError) {
            return Center(child: Text("Hata: ${state.message}"));
          } else if (state is HomeLoaded) {
            final businesses = state.businesses;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeCubit>().loadBusinesses(
                  city: selectedCity,
                  category: selectedCategory,
                );
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  if (categoryList.isNotEmpty)
                    CategoryRow(
                      selected: selectedCategory,
                      categories: categoryList,
                      onSelected: _onCategorySelected,
                    ),
                  const SizedBox(height: 12),
                  if (businesses.isEmpty)
                    const Center(child: Text("İşletme bulunamadı")),
                  ...businesses.map((b) => BusinessCard(bModel: b)).toList(),
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
}
