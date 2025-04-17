import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:letwork/core/utils/image_utils.dart';
import 'package:letwork/core/widgets/loading_button.dart';
import 'package:letwork/data/model/business_detail_model.dart';
import 'package:letwork/features/business/cubit/update_business_cubit.dart';
import 'package:letwork/features/business/cubit/update_business_state.dart';
import 'package:letwork/features/business/view/business_detail_screen.dart';
import 'package:letwork/features/business/widgets/post_businessinfo_section.dart';
import 'package:letwork/features/business/widgets/post_images_section.dart';
import 'package:letwork/features/business/widgets/post_map_section.dart';
import 'package:letwork/features/business/widgets/post_menu_section.dart';

class UpdateBusinessScreen extends StatefulWidget {
  final String businessId;

  const UpdateBusinessScreen({
    super.key,
    required this.businessId,
  });

  @override
  State<UpdateBusinessScreen> createState() => _UpdateBusinessScreenState();
}

class _UpdateBusinessScreenState extends State<UpdateBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Text controllers
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final openController = TextEditingController();
  final closeController = TextEditingController();

  // Images
  File? profileImage;
  List<File> detailImages = [];
  String? existingProfileImage;
  List<String> existingDetailImages = [];

  // Location data
  double? latitude;
  double? longitude;
  String? address;

  // Business type
  bool isCorporate = false;

  // Loading state
  bool _isLoading = true;

  // Category data
  String? selectedCategoryGroup;
  String? selectedSubCategory;
  List<Map<String, dynamic>> categoryGroups = [];

  // Menu/Services
  List<Map<String, dynamic>> services = [{"name": "", "price": ""}];

  // Business data
  BusinessDetailModel? businessData;
  int? userId;

  // For tracking form progress
  final Map<String, bool> _formProgress = {
    'businessInfo': false,
    'location': false,
    'images': false,
    'services': false,
  };

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
    _fetchCategories();
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    openController.dispose();
    closeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinessData() async {
    if (!mounted) return;
    context.read<UpdateBusinessCubit>().fetchBusinessDetails(int.parse(widget.businessId));
  }

  Future<void> _fetchCategories() async {
    // This would normally fetch categories from your repository
    // For now we'll simulate it with some sample data
    if (!mounted) return;

    setState(() {
      categoryGroups = [
        {
          "group": "Kuaför & Güzellik",
          "items": ["Kadın Kuaförü", "Erkek Kuaförü", "Güzellik Salonu", "Manikür & Pedikür"]
        },
        {
          "group": "Sağlık & Bakım",
          "items": ["Diyetisyen", "Masaj Salonu", "Fitness", "Yoga"]
        },
        {
          "group": "Eğitim & Kurs",
          "items": ["Dil Kursu", "Müzik Eğitimi", "Spor Eğitimi", "Hobi Kursu"]
        }
      ];
    });
  }

  void _updateFormWithBusinessData(BusinessDetailModel business) {
    if (!mounted) return;

    setState(() {
      nameController.text = business.name;
      descController.text = business.description;
      openController.text = business.openTime;
      closeController.text = business.closeTime;

      latitude = business.latitude;
      longitude = business.longitude;
      address = business.address;

      isCorporate = business.isCorporate;

      selectedCategoryGroup = business.category;
      selectedSubCategory = business.subCategory;

      existingProfileImage = business.profileImageUrl.isNotEmpty
          ? (business.profileImageUrl.startsWith('http')
          ? business.profileImageUrl
          : "https://letwork.hasankaan.com/${business.profileImageUrl}")
          : null;

      existingDetailImages = business.detailImages.map((url) =>
      url.startsWith('http') ? url : "https://letwork.hasankaan.com/$url").toList();

      if (business.services.isNotEmpty) {
        services = List<Map<String, dynamic>>.from(business.services.map((service) => {
          "name": service['service_name'] ?? '',
          "price": service['price'] ?? ''
        }));
      }

      userId = int.tryParse(business.userId);
      businessData = business;
      _isLoading = false;
    });

    _updateProgress();
  }

  void _updateProgress() {
    if (!mounted) return;
    setState(() {
      _formProgress['businessInfo'] = nameController.text.isNotEmpty &&
          descController.text.isNotEmpty &&
          openController.text.isNotEmpty &&
          closeController.text.isNotEmpty &&
          selectedCategoryGroup != null &&
          selectedSubCategory != null;

      _formProgress['location'] = latitude != null && longitude != null && address != null;

      _formProgress['images'] = (profileImage != null || existingProfileImage != null) &&
          (detailImages.length + existingDetailImages.length >= 3);

      _formProgress['services'] = services.isNotEmpty &&
          !services.any((s) => s['name'].toString().isEmpty || s['price'].toString().isEmpty);
    });
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
      );
      return;
    }

    // Convert images to MultipartFile objects
    MultipartFile? profileMultipart;
    List<MultipartFile>? detailMultiparts;

    if (profileImage != null) {
      profileMultipart = await ImageUtils.convertFileToMultipart(profileImage!);
    }

    if (detailImages.isNotEmpty) {
      detailMultiparts = await ImageUtils.convertFilesToMultipart(detailImages);
    }

    // ✅ Hizmetleri String tipine dönüştür
    List<Map<String, String>> formattedServices = services.map((service) => {
      'name': service['name'].toString(),
      'price': service['price'].toString(),
    }).toList();

    // ✅ Doğru tipte gönderim yapılacak
    if (userId != null) {
      await context.read<UpdateBusinessCubit>().updateBusinessFull(
        businessId: int.parse(widget.businessId),
        userId: userId!,
        name: nameController.text,
        description: descController.text,
        category: selectedCategoryGroup!,
        subCategory: selectedSubCategory!,
        isCorporate: isCorporate,
        openTime: openController.text,
        closeTime: closeController.text,
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
        address: address ?? '',
        services: formattedServices,
        profileImage: profileMultipart,
        detailImages: detailMultiparts,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("İşletme Düzenle", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocConsumer<UpdateBusinessCubit, UpdateBusinessState>(
        listener: (context, state) {
          if (state is BusinessDetailsLoaded) {
            _updateFormWithBusinessData(state.business);
          } else if (state is UpdateBusinessSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green.shade700),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BusinessDetailScreen(businessId: widget.businessId),
              ),
            );
          } else if (state is UpdateBusinessError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red.shade700),
            );
          }
        },
        builder: (context, state) {
          if (state is BusinessDetailsLoading || _isLoading) {
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
                  _buildProgressSection(),
                  const SizedBox(height: 16),
                  PostBusinessInfoSection(
                    nameController: nameController,
                    descController: descController,
                    openController: openController,
                    closeController: closeController,
                    isCorporate: isCorporate,
                    onCorporateChanged: (val) => setState(() {
                      isCorporate = val;
                      _updateProgress();
                    }),
                    categoryGroups: categoryGroups,
                    selectedCategoryGroup: selectedCategoryGroup,
                    selectedSubCategory: selectedSubCategory,
                    onCategoryGroupChanged: (val) {
                      setState(() {
                        selectedCategoryGroup = val;
                        selectedSubCategory = null;
                        _updateProgress();
                      });
                    },
                    onSubCategoryChanged: (val) {
                      setState(() {
                        selectedSubCategory = val;
                        _updateProgress();
                      });
                    },
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
                        _updateProgress();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  PostImagesSection(
                    profileImage: profileImage,
                    detailImages: detailImages,
                    existingProfileImage: existingProfileImage,
                    existingDetailImages: existingDetailImages,
                    onPickProfile: (file) => setState(() {
                      profileImage = file;
                      _updateProgress();
                    }),
                    onPickDetails: (files) => setState(() {
                      detailImages = files;
                      _updateProgress();
                    }),
                    onRemoveDetailImage: (index) => setState(() {
                      if (index < detailImages.length) {
                        detailImages.removeAt(index);
                        _updateProgress();
                      }
                    }),
                    onRemoveExistingDetailImage: (index) => setState(() {
                      if (index < existingDetailImages.length) {
                        existingDetailImages.removeAt(index);
                        _updateProgress();
                      }
                    }),
                  ),
                  const SizedBox(height: 16),
                  PostMenuSection(
                    services: services.map((service) => {
                      'name': service['name'].toString(),
                      'price': service['price'].toString(),
                    }).toList(),
                    onAddService: () => setState(() {
                      services.add({"name": "", "price": ""});
                      _updateProgress();
                    }),
                    onRemoveService: (index) => setState(() {
                      if (index < services.length) {
                        services.removeAt(index);
                        if (services.isEmpty) {
                          services.add({"name": "", "price": ""});
                        }
                        _updateProgress();
                      }
                    }),
                    onUpdateService: (index, key, value) {
                      setState(() {
                        if (index < services.length) {
                          services[index][key] = value;
                          _updateProgress();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  LoadingButton(
                    text: "İşletmeyi Güncelle",
                    isLoading: state is UpdateBusinessLoading,
                    onPressed: _submitUpdate,
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
          const Text("İşletme Güncelleme Durumu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _formProgress.values.where((completed) => completed).length / _formProgress.length,
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFFFF0000),
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