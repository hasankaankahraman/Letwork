import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/repositories/category_repository.dart';
import '../cubit/add_business_cubit.dart';
import '../../main_wrapper/main_wrapper_screen.dart';
import '../widgets/post_businessinfo_section.dart';
import '../widgets/post_images_section.dart';
import '../widgets/post_map_section.dart';
import '../widgets/post_menu_section.dart';

class AddBusinessScreen extends StatefulWidget {
  const AddBusinessScreen({super.key});

  @override
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final openController = TextEditingController();
  final closeController = TextEditingController();

  File? profileImage;
  List<File> detailImages = [];

  double? latitude;
  double? longitude;
  String? address;

  bool isCorporate = false;
  bool _isLoading = false;
  int? userId;

  String? selectedCategoryGroup;
  String? selectedSubCategory;
  List<Map<String, dynamic>> categoryGroups = [];

  List<Map<String, String>> services = [{"name": "", "price": ""}];

  final Map<String, bool> _formProgress = {
    'businessInfo': false,
    'location': false,
    'images': false,
    'services': false,
  };

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _fetchUserId();
    await _fetchCategories();
  }

  Future<void> _fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final repo = CategoryRepository();
      final result = await repo.getCategories();
      categoryGroups = List<Map<String, dynamic>>.from(result);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Kategoriler alınamadı"), backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateProgress() {
    _formProgress['businessInfo'] = nameController.text.isNotEmpty &&
        descController.text.isNotEmpty &&
        openController.text.isNotEmpty &&
        closeController.text.isNotEmpty &&
        selectedCategoryGroup != null &&
        selectedSubCategory != null;

    _formProgress['location'] = latitude != null && longitude != null;
    _formProgress['images'] = profileImage != null && detailImages.length >= 3;
    _formProgress['services'] = services.isNotEmpty &&
        !services.any((s) => s['name']!.isEmpty || s['price']!.isEmpty);
  }

  Future<void> _submit() async {
    _updateProgress();
    if (!_formKey.currentState!.validate()) return;

    if (userId == null) {
      _showError("Kullanıcı bilgisi alınamadı");
      return;
    }

    if (!_formProgress.values.every((v) => v)) {
      final incomplete = _formProgress.entries.firstWhere((e) => !e.value).key;
      final message = switch (incomplete) {
        'businessInfo' => "Lütfen işletme bilgilerini eksiksiz doldurun",
        'location' => "Lütfen işletme konumunu belirleyin",
        'images' => "Lütfen profil fotoğrafı ve en az 3 detay fotoğrafı ekleyin",
        'services' => "Lütfen en az bir hizmet ekleyin ve fiyatlandırın",
        _ => "Lütfen tüm alanları eksiksiz doldurun"
      };
      _showError(message);
      return;
    }

    final formData = FormData.fromMap({
      'user_id': userId.toString(),
      'name': nameController.text,
      'description': descController.text,
      'open_time': openController.text,
      'close_time': closeController.text,
      'address': address ?? '',
      'category': selectedCategoryGroup!,
      'sub_category': selectedSubCategory!,
      'is_corporate': isCorporate ? '1' : '0',
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'menu': jsonEncode(services),
      'profile_image': await MultipartFile.fromFile(profileImage!.path),
      'detail_images[]': await Future.wait(detailImages.map((f) => MultipartFile.fromFile(f.path))),
    });

    context.read<AddBusinessCubit>().addBusiness(formData);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    _updateProgress();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("İşletme Ekle", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocConsumer<AddBusinessCubit, AddBusinessState>(
        listener: (context, state) {
          if (state is AddBusinessSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green.shade700),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainWrapperScreen()),
                  (route) => false,
            );
          } else if (state is AddBusinessError) {
            _showError(state.message);
          }
        },
        builder: (context, state) {
          if (_isLoading) return const Center(child: CircularProgressIndicator());

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
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
                    onSubCategoryChanged: (val) => setState(() => selectedSubCategory = val),
                  ),
                  const SizedBox(height: 16),
                  PostMapSection(
                    latitude: latitude,
                    longitude: longitude,
                    address: address,
                    onPickLocation: (LatLng latlng, String? addr) {
                      setState(() {
                        latitude = latlng.latitude;
                        longitude = latlng.longitude;
                        address = addr;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  PostImagesSection(
                    profileImage: profileImage,
                    detailImages: detailImages,
                    existingProfileImage: null,
                    existingDetailImages: const [],
                    onPickProfile: (file) => setState(() => profileImage = file),
                    onPickDetails: (files) => setState(() => detailImages = files),
                    onRemoveDetailImage: (index) => setState(() => detailImages.removeAt(index)),
                    onRemoveExistingDetailImage: (_) {},
                  ),
                  const SizedBox(height: 16),
                  PostMenuSection(
                    services: services,
                    onAddService: () => setState(() => services.add({"name": "", "price": ""})),
                    onRemoveService: (index) => setState(() => services.removeAt(index)),
                    onUpdateService: (index, key, value) {
                      setState(() => services[index][key] = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state is AddBusinessLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: state is AddBusinessLoading
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)),
                        SizedBox(width: 12),
                        Text("İşletme Kaydediliyor...", style: TextStyle(fontSize: 16)),
                      ],
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text("İşletmeyi Kaydet", style: TextStyle(fontSize: 16)),
                      ],
                    ),
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
