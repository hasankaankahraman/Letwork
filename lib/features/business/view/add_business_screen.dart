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
  final _scrollController = ScrollController();

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
  bool _isLoading = false;

  String? selectedCategoryGroup;
  String? selectedSubCategory;
  List<Map<String, dynamic>> categoryGroups = [];

  List<Map<String, String>> services = [{"name": "", "price": ""}];

  final ImagePicker _picker = ImagePicker();

  final Map<String, bool> _formProgress = {
    'businessInfo': false,
    'location': false,
    'images': false,
    'services': false,
  };

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    openController.dispose();
    closeController.dispose();
    addressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final repo = CategoryRepository();
      final result = await repo.getCategories();
      setState(() {
        categoryGroups = List<Map<String, dynamic>>.from(result);
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Kategoriler alınamadı"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _updateProgress() {
    setState(() {
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
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _updateProgress();

      if (!_formProgress.values.every((completed) => completed)) {
        final firstIncomplete = _formProgress.entries
            .firstWhere((entry) => !entry.value, orElse: () => const MapEntry('', true));

        String message = switch (firstIncomplete.key) {
          'businessInfo' => "Lütfen işletme bilgilerini eksiksiz doldurun",
          'location' => "Lütfen işletme konumunu belirleyin",
          'images' => "Lütfen profil fotoğrafı ve en az 3 detay fotoğrafı ekleyin",
          'services' => "Lütfen en az bir hizmet ekleyin ve fiyatlandırın",
          _ => "Lütfen tüm alanları eksiksiz doldurun",
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BusinessDetailScreen(businessId: state.businessId),
              ),
            );
          } else if (state is AddBusinessError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red.shade700),
            );
          }
        },
        builder: (context, state) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📊 İlerleme göstergesi
                  _buildProgressSection(),

                  const SizedBox(height: 16),

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
                  PostImagesSection(
                    profileImage: profileImage,
                    detailImages: detailImages,
                    existingProfileImage: null, // Add this
                    existingDetailImages: const [], // Add this
                    onPickProfile: (file) => setState(() => profileImage = file),
                    onPickDetails: (files) => setState(() => detailImages = files),
                    onRemoveDetailImage: (index) => setState(() => detailImages.removeAt(index)),
                    onRemoveExistingDetailImage: (index) {}, // Add this callback
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
                      backgroundColor: Color(0xFFFF0000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state is AddBusinessLoading
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        ),
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

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("İşletme Ekleme Durumu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _formProgress.values.where((completed) => completed).length / _formProgress.length,
            backgroundColor: Colors.grey.shade200,
            color: Color(0xFFFF0000),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressIndicator("İşletme\nBilgileri", Icons.business, _formProgress['businessInfo']!),
              _buildProgressIndicator("Konum", Icons.location_on, _formProgress['location']!),
              _buildProgressIndicator("Fotoğraflar", Icons.image, _formProgress['images']!),
              _buildProgressIndicator("Hizmetler", Icons.room_service, _formProgress['services']!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, IconData icon, bool completed) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: completed ? Colors.green.shade50 : Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(
              color: completed ? Colors.green : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Icon(
            completed ? Icons.check : icon,
            color: completed ? Colors.green : Colors.grey.shade500,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: completed ? Colors.green.shade700 : Colors.grey.shade700,
            fontWeight: completed ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
