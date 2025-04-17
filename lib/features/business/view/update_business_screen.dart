import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:letwork/core/utils/image_utils.dart';
import 'package:letwork/core/widgets/loading_button.dart';
import 'package:letwork/data/model/business_detail_model.dart';
import 'package:letwork/features/business/view/business_detail_screen.dart';
import 'package:letwork/features/business/widgets/post_businessinfo_section.dart';
import 'package:letwork/features/business/widgets/post_images_section.dart';
import 'package:letwork/features/business/widgets/post_map_section.dart';
import 'package:letwork/features/business/widgets/post_menu_section.dart';
import 'package:letwork/features/business/cubit/update_business_cubit.dart';
import 'package:letwork/features/business/cubit/update_business_state.dart';

class UpdateBusinessScreen extends StatefulWidget {
  final String businessId;

  const UpdateBusinessScreen({super.key, required this.businessId});

  @override
  State<UpdateBusinessScreen> createState() => _UpdateBusinessScreenState();
}

class _UpdateBusinessScreenState extends State<UpdateBusinessScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final openController = TextEditingController();
  final closeController = TextEditingController();

  bool isCorporate = false;
  String? selectedCategoryGroup;
  String? selectedSubCategory;
  double? latitude;
  double? longitude;
  String? address;

  File? profileImage;
  List<File> detailImages = [];
  String? existingProfileImage;
  List<String> existingDetailImages = [];
  List<Map<String, String>> services = [{"name": "", "price": ""}];

  int? userId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    context.read<UpdateBusinessCubit>().fetchInitialData(int.parse(widget.businessId));
  }

  void _populateForm(BusinessDetailModel business, List<Map<String, dynamic>> categoryGroups) {
    nameController.text = business.name;
    descController.text = business.description;
    openController.text = business.openTime;
    closeController.text = business.closeTime;
    isCorporate = business.isCorporate;

    latitude = business.latitude;
    longitude = business.longitude;
    address = business.address;

    userId = int.tryParse(business.userId);
    existingProfileImage = business.profileImageUrl;
    existingDetailImages = business.detailImages.map((url) =>
    url.startsWith('http') ? url : "https://letwork.hasankaan.com/$url"
    ).toList();

    // Menü veya servis verisiyle formu doldur
    if (business.menu.isNotEmpty) {
      services = business.menu.map<Map<String, String>>((item) => {
        "name": item["name"]?.toString() ?? "",
        "price": item["price"]?.toString() ?? "",
      }).toList();
    } else if (business.services.isNotEmpty) {
      services = business.services.map<Map<String, String>>((s) => {
        "name": s["service_name"]?.toString() ?? '',
        "price": s["price"]?.toString() ?? '',
      }).toList();
    } else {
      services = [{"name": "", "price": ""}];
    }

    final validGroup = categoryGroups.any((g) => g['group'] == business.category);
    selectedCategoryGroup = validGroup ? business.category : null;

    final group = categoryGroups.firstWhere(
          (g) => g['group'] == selectedCategoryGroup,
      orElse: () => {"items": []},
    );

    final validSub = group['items'].contains(business.subCategory);
    selectedSubCategory = validSub ? business.subCategory : null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategoryGroup == null || selectedSubCategory == null) {
      _showError("Lütfen kategori ve alt kategori seçin");
      return;
    }

    if ((profileImage == null && existingProfileImage == null) ||
        (detailImages.length + existingDetailImages.length < 3)) {
      _showError("Lütfen profil ve en az 3 detay fotoğrafı ekleyin");
      return;
    }

    if (services.any((s) => s['name']!.isEmpty || s['price']!.isEmpty)) {
      _showError("Lütfen tüm hizmetleri doldurun");
      return;
    }

    setState(() => _isSubmitting = true);

    MultipartFile? profileMultipart;
    List<MultipartFile>? detailMultipart;

    if (profileImage != null) {
      profileMultipart = await ImageUtils.convertFileToMultipart(profileImage!);
    }

    if (detailImages.isNotEmpty) {
      detailMultipart = await ImageUtils.convertFilesToMultipart(detailImages);
    }

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
      latitude: latitude ?? 0,
      longitude: longitude ?? 0,
      address: address ?? '',
      services: services,
      profileImage: profileMultipart,
      detailImages: detailMultipart,
    );

    setState(() => _isSubmitting = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateBusinessCubit, UpdateBusinessState>(
      listener: (context, state) {
        if (state is UpdateBusinessSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BusinessDetailScreen(businessId: widget.businessId)),
          );
        } else if (state is UpdateBusinessError) {
          _showError(state.message);
        } else if (state is BusinessDetailsLoaded) {
          _populateForm(state.business, context.read<UpdateBusinessCubit>().categories);
        }
      },
      builder: (context, state) {
        if (state is BusinessDetailsLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final categories = context.read<UpdateBusinessCubit>().categories;

        return Scaffold(
          appBar: AppBar(
            title: const Text("İşletme Güncelle"),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: SingleChildScrollView(
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
                    categoryGroups: categories,
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
                    existingProfileImage: existingProfileImage,
                    existingDetailImages: existingDetailImages,
                    onPickProfile: (file) => setState(() => profileImage = file),
                    onPickDetails: (files) => setState(() => detailImages = files),
                    onRemoveDetailImage: (index) => setState(() => detailImages.removeAt(index)),
                    onRemoveExistingDetailImage: (index) => setState(() => existingDetailImages.removeAt(index)),
                  ),
                  const SizedBox(height: 16),
                  PostMenuSection(
                    services: services,
                    onAddService: () => setState(() => services.add({"name": "", "price": ""})),
                    onRemoveService: (index) {
                      setState(() {
                        services.removeAt(index);
                        if (services.isEmpty) {
                          services.add({"name": "", "price": ""});
                        }
                      });
                    },
                    onUpdateService: (index, key, value) {
                      setState(() => services[index][key] = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  LoadingButton(
                    text: "İşletmeyi Güncelle",
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
