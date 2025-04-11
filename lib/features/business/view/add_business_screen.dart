import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
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
  String? selectedCategory;

  File? profileImage;
  List<File> detailImages = [];
  double? latitude;
  double? longitude;

  final ImagePicker _picker = ImagePicker();
  List<String> allCategories = [];
  List<Map<String, String>> services = [
    {"name": "", "price": ""}
  ];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final repo = CategoryRepository();
      final result = await repo.getCategories();
      setState(() {
        allCategories = result
            .expand((group) => List<String>.from(group['items']))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kategoriler alınamadı")),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
      });
    }
  }

  Future<void> _pickDetailImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        detailImages = picked.map((e) => File(e.path)).take(3).toList();
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapLocationPickerScreen(),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        latitude = result.latitude;
        longitude = result.longitude;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (profileImage == null ||
          detailImages.length < 3 ||
          selectedCategory == null ||
          latitude == null ||
          longitude == null ||
          services.any((s) => s['name']!.isEmpty || s['price']!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen tüm alanları eksiksiz doldurun.")),
        );
        return;
      }

      final formData = {
        'name': nameController.text,
        'description': descController.text,
        'open_time': openController.text,
        'close_time': closeController.text,
        'category': selectedCategory,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'profile_image': MultipartFile.fromFileSync(profileImage!.path),
        'user_id': 1, // TODO: SharedPreferences'tan alınacak
        for (int i = 0; i < detailImages.length; i++)
          'detail_image_$i': MultipartFile.fromFileSync(detailImages[i].path),
      };

      for (int i = 0; i < services.length; i++) {
        formData['services[$i][name]'] = services[i]['name']!;
        formData['services[$i][price]'] = services[i]['price']!;
      }

      context.read<AddBusinessCubit>().addBusiness(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddBusinessCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text("İşletme Ekle")),
        body: BlocConsumer<AddBusinessCubit, AddBusinessState>(
          listener: (context, state) {
            if (state is AddBusinessSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              Navigator.pop(context);
            } else if (state is AddBusinessError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "İşletme Adı"),
                      validator: (val) => val == null || val.isEmpty ? "Zorunlu" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: "Açıklama"),
                      maxLines: 3,
                      validator: (val) => val == null || val.isEmpty ? "Zorunlu" : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: openController,
                            decoration: const InputDecoration(labelText: "Açılış Saati"),
                            validator: (val) => val == null || val.isEmpty ? "Zorunlu" : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: closeController,
                            decoration: const InputDecoration(labelText: "Kapanış Saati"),
                            validator: (val) => val == null || val.isEmpty ? "Zorunlu" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: "Kategori"),
                      items: allCategories
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedCategory = val),
                      validator: (val) => val == null ? "Kategori seçin" : null,
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _pickLocation,
                      icon: const Icon(Icons.map),
                      label: const Text("Konum Seç"),
                    ),
                    if (latitude != null && longitude != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text("📍 Seçilen Konum: ($latitude, $longitude)"),
                      ),
                    const SizedBox(height: 16),
                    const Text("Verilen Hizmetler", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: entry.value['price'],
                              decoration: const InputDecoration(labelText: "Fiyat (₺)"),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => services[index]['price'] = val,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                services.removeAt(index);
                              });
                            },
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                          )
                        ],
                      );
                    }),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          services.add({"name": "", "price": ""});
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Hizmet Ekle"),
                    ),
                    const SizedBox(height: 24),
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
      ),
    );
  }
}
