import 'dart:io';
import 'dart:convert'; // dosyanın en üstüne bunu ekle
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:letwork/features/business/view/business_detail_screen.dart';
import '../../../data/repositories/category_repository.dart';
import '../cubit/add_business_cubit.dart';
import 'map_location_picker_screen.dart';

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
  bool isCorporate = false;

  String? selectedCategoryGroup;
  String? selectedSubCategory;
  List<Map<String, dynamic>> categoryGroups = [];

  final ImagePicker _picker = ImagePicker();
  List<Map<String, String>> services = [{"name": "", "price": ""}];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final repo = CategoryRepository();
      final result = await repo.getCategories();
      setState(() => categoryGroups = List<Map<String, dynamic>>.from(result));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kategoriler alınamadı")),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  Future<void> _pickDetailImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => detailImages = picked.map((e) => File(e.path)).take(3).toList());
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapLocationPickerScreen()),
    );

    if (result is LatLng) {
      setState(() {
        latitude = result.latitude;
        longitude = result.longitude;
      });
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
        MapEntry('address', addressController.text),
        MapEntry('category', selectedCategoryGroup!),
        MapEntry('sub_category', selectedSubCategory!),
        MapEntry('is_corporate', isCorporate ? '1' : '0'),
        MapEntry('latitude', latitude.toString()),
        MapEntry('longitude', longitude.toString()),
      ]);

      formData.files.add(MapEntry(
        'profile_image',
        await MultipartFile.fromFile(profileImage!.path),
      ));

      for (int i = 0; i < detailImages.length; i++) {
        formData.files.add(MapEntry(
          'detail_images[]',
          await MultipartFile.fromFile(detailImages[i].path),
        ));
      }

      // JSON olarak tüm menu alanını tek seferde gönderiyoruz
      formData.fields.add(MapEntry('menu', jsonEncode(services)));

      context.read<AddBusinessCubit>().addBusiness(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedGroup = categoryGroups.firstWhere(
          (group) => group['group'] == selectedCategoryGroup,
      orElse: () => {'items': []},
    );

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
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "İşletme Adı"),
                    validator: (val) => val!.isEmpty ? "Zorunlu" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: "Açıklama"),
                    maxLines: 3,
                    validator: (val) => val!.isEmpty ? "Zorunlu" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: "Adres"),
                    validator: (val) => val!.isEmpty ? "Zorunlu" : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: openController,
                          decoration: const InputDecoration(labelText: "Açılış Saati"),
                          validator: (val) => val!.isEmpty ? "Zorunlu" : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: closeController,
                          decoration: const InputDecoration(labelText: "Kapanış Saati"),
                          validator: (val) => val!.isEmpty ? "Zorunlu" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Kurumsal Hesap mı?", style: TextStyle(fontSize: 16)),
                      Switch(
                        value: isCorporate,
                        onChanged: (val) {
                          setState(() {
                            isCorporate = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategoryGroup,
                    decoration: const InputDecoration(labelText: "Kategori"),
                    items: categoryGroups
                        .map((cat) => DropdownMenuItem(
                      value: cat['group'] as String,
                      child: Text(cat['group']),
                    ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCategoryGroup = val;
                        selectedSubCategory = null;
                      });
                    },
                    validator: (val) => val == null ? "Kategori seçin" : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedSubCategory,
                    decoration: const InputDecoration(labelText: "Alt Kategori"),
                    items: (selectedGroup['items'] as List)
                        .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ))
                        .toList(),
                    onChanged: (val) => setState(() => selectedSubCategory = val),
                    validator: (val) => val == null ? "Alt kategori seçin" : null,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickProfileImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Profil Fotoğrafı Seç"),
                  ),
                  if (profileImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Image.file(profileImage!, height: 100),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickDetailImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Detay Fotoğrafları Seç (3)"),
                  ),
                  if (detailImages.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: detailImages
                          .map((file) => Image.file(file, height: 80, width: 80, fit: BoxFit.cover))
                          .toList(),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickLocation,
                    icon: const Icon(Icons.map),
                    label: const Text("Konum Seç"),
                  ),
                  if (latitude != null && longitude != null)
                    Text("📍 Seçilen Konum: ($latitude, $longitude)"),
                  const SizedBox(height: 20),
                  const Text("Verilen Hizmetler", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...services.asMap().entries.map((entry) {
                    int index = entry.key;
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: entry.value['name'],
                            decoration: const InputDecoration(labelText: "Hizmet Adı"),
                            onChanged: (val) => services[index]['name'] = val,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            initialValue: entry.value['price'],
                            decoration: const InputDecoration(labelText: "Fiyat (₺)"),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => services[index]['price'] = val,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => services.removeAt(index)),
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                        ),
                      ],
                    );
                  }),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => services.add({"name": "", "price": ""})),
                    icon: const Icon(Icons.add),
                    label: const Text("Hizmet Ekle"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    child: state is AddBusinessLoading
                        ? const CircularProgressIndicator()
                        : const Text("İşletmeyi Ekle"),
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
