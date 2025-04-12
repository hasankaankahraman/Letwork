import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:letwork/features/business/view/business_detail_screen.dart';
import 'package:letwork/features/business/widgets/post_businessinfo_section.dart';
import 'package:letwork/features/business/widgets/post_images_section.dart';
import 'package:letwork/features/business/widgets/post_map_section.dart';
import 'package:letwork/features/business/widgets/post_menu_section.dart';
import '../../../data/repositories/category_repository.dart';
import '../cubit/add_business_cubit.dart';

class AddBusinessScreen extends StatefulWidget {
  const AddBusinessScreen({super.key});

  @override
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final openController = TextEditingController();
  final closeController = TextEditingController();
  final addressController = TextEditingController();

  File? profileImage;
  List<File> detailImages = [];

  double? latitude;
  double? longitude;
  String? address;

  bool isCorporate = false;

  String? selectedCategoryGroup;
  String? selectedSubCategory;
  List<Map<String, dynamic>> categoryGroups = [];

  List<Map<String, String>> services = [{"name": "", "price": ""}];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final repo = CategoryRepository();
      final result = await repo.getCategories();
      setState(() => categoryGroups = List<Map<String, dynamic>>.from(result));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kategoriler alınamadı")),
      );
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (profileImage == null ||
          detailImages.length < 3 ||
          selectedCategoryGroup == null ||
          selectedSubCategory == null ||
          latitude == null ||
          longitude == null ||
          services.any((s) => s['name']!.isEmpty || s['price']!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen tüm alanları eksiksiz doldurun.")),
        );
        return;
      }

      final formData = FormData();

      formData.fields.addAll([
        MapEntry('user_id', '1'),
        MapEntry('name', nameController.text),
        MapEntry('description', descController.text),
        MapEntry('open_time', openController.text),
        MapEntry('close_time', closeController.text),
        MapEntry('address', address ?? ""),
        MapEntry('category', selectedCategoryGroup!),
        MapEntry('sub_category', selectedSubCategory!),
        MapEntry('is_corporate', isCorporate ? '1' : '0'),
        MapEntry('latitude', latitude.toString()),
        MapEntry('longitude', longitude.toString()),
        MapEntry('menu', jsonEncode(services)),
      ]);

      formData.files.add(MapEntry(
        'profile_image',
        await MultipartFile.fromFile(profileImage!.path),
      ));

      for (var file in detailImages) {
        formData.files.add(MapEntry(
          'detail_images[]',
          await MultipartFile.fromFile(file.path),
        ));
      }

      context.read<AddBusinessCubit>().addBusiness(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("İşletme Ekle")),
      body: BlocConsumer<AddBusinessCubit, AddBusinessState>(
        listener: (context, state) {
          if (state is AddBusinessSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BusinessDetailScreen(businessId: state.businessId),
              ),
            );
          } else if (state is AddBusinessError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 🧾 İşletme Bilgileri
                  PostBusinessInfoSection(
                    nameController: nameController,
                    descController: descController,
                    openController: openController,
                    closeController: closeController,
                    isCorporate: isCorporate,
                    onCorporateChanged: (val) => setState(() => isCorporate = val),
                    categoryGroups: categoryGroups,
                    selectedCategoryGroup: selectedCategoryGroup,
                    selectedSubCategory: selectedSubCategory,
                    onCategoryGroupChanged: (val) {
                      setState(() {
                        selectedCategoryGroup = val;
                        selectedSubCategory = null;
                      });
                    },
                    onSubCategoryChanged: (val) {
                      setState(() => selectedSubCategory = val);
                    },
                  ),

                  const SizedBox(height: 16),

                  // 📍 Konum ve Adres
                  PostMapSection(
                    latitude: latitude,
                    longitude: longitude,
                    address: address,
                    onPickLocation: (LatLng latlng, String? address) {
                      setState(() {
                        latitude = latlng.latitude;
                        longitude = latlng.longitude;
                        this.address = address;
                      });
                    },
                  ),


                  const SizedBox(height: 16),

                  // 📸 Görseller
                  PostImagesSection(
                    profileImage: profileImage,
                    detailImages: detailImages,
                    onPickProfile: (file) => setState(() => profileImage = file),
                    onPickDetails: (files) => setState(() => detailImages = files),
                    onRemoveDetailImage: (index) => setState(() => detailImages.removeAt(index)),
                  ),

                  const SizedBox(height: 16),

                  // 🧾 Hizmetler
                  PostMenuSection(
                    services: services,
                    onAddService: () => setState(() => services.add({"name": "", "price": ""})),
                    onRemoveService: (index) => setState(() => services.removeAt(index)),
                    onUpdateService: (index, key, value) {
                      setState(() => services[index][key] = value);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Kaydet
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save),
                    label: state is AddBusinessLoading
                        ? const CircularProgressIndicator()
                        : const Text("İşletmeyi Kaydet"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
