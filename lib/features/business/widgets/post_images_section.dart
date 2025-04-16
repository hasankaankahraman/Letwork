import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostImagesSection extends StatelessWidget {
  final File? profileImage;
  final List<File> detailImages;
  // Yeni eklenen parametreler
  final String? existingProfileImage;
  final List<String> existingDetailImages;
  final Function(File) onPickProfile;
  final Function(List<File>) onPickDetails;
  final Function(int) onRemoveDetailImage;
  // Yeni eklenen callback
  final Function(int) onRemoveExistingDetailImage;

  const PostImagesSection({
    super.key,
    required this.profileImage,
    required this.detailImages,
    // Yeni parametreler eklendi
    this.existingProfileImage,
    this.existingDetailImages = const [],
    required this.onPickProfile,
    required this.onPickDetails,
    required this.onRemoveDetailImage,
    // Yeni callback eklendi
    required this.onRemoveExistingDetailImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "İşletme Fotoğrafları",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Profil Fotoğrafı Bölümü
          Text("Profil Fotoğrafı", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(
            "İşletmenizi en iyi şekilde temsil eden bir fotoğraf seçin",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          _buildProfileImagePicker(context),

          const SizedBox(height: 24),

          // Detay Fotoğrafları Bölümü
          Text("Detay Fotoğrafları", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(
            "İşletmenizin ortamını göstermek için en az 3 detay fotoğrafı yükleyin",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          _buildDetailImagesPicker(context),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickProfileImage(context),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: profileImage != null
        // Yeni profil resmi seçildi
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            profileImage!,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        )
        // Varolan profil resmi var mı diye kontrol et
            : existingProfileImage != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            existingProfileImage!,
            fit: BoxFit.cover,
            width: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade400, size: 36),
                    const SizedBox(height: 8),
                    Text("Resim yüklenemedi", style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              );
            },
          ),
        )
        // Hiç resim yok, "Ekle" görünümü göster
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade500),
              const SizedBox(height: 12),
              Text(
                "Profil Fotoğrafı Ekle",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailImagesPicker(BuildContext context) {
    // Tüm görsellerin toplam sayısı (yeni + varolan)
    final totalImages = detailImages.length + existingDetailImages.length;

    return Column(
      children: [
        // Eğer hiç resim yoksa, büyük "ekle" butonu göster
        if (totalImages == 0)
          GestureDetector(
            onTap: () => _pickDetailImages(context),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey.shade500),
                  const SizedBox(height: 12),
                  Text(
                    "Detay Fotoğrafları Ekle",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  // Mevcut detay resimleri göster
                  ...existingDetailImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final imageUrl = entry.value;
                    return _buildExistingDetailImage(index, imageUrl);
                  }),

                  // Yeni eklenen detay resimlerini göster
                  ...detailImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return _buildNewDetailImage(index, file);
                  }),

                  // Daha fazla resim eklemek için buton (maksimum 9 resim)
                  if (totalImages < 9)
                    GestureDetector(
                      onTap: () => _pickDetailImages(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                ],
              ),

              // "Daha fazla ekle" butonu (grid'in dışında)
              if (totalImages < 9)
                TextButton.icon(
                  onPressed: () => _pickDetailImages(context),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("Daha Fazla Fotoğraf Ekle"),
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFFFF0000),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  // Yeni eklenen detay görseli
  Widget _buildNewDetailImage(int index, File image) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => onRemoveDetailImage(index),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Varolan detay görseli
  Widget _buildExistingDetailImage(int index, String imageUrl) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => onRemoveExistingDetailImage(index),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _pickProfileImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      onPickProfile(File(image.path));
    }
  }

  void _pickDetailImages(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 80);

    if (images.isNotEmpty) {
      final newImages = images.map((image) => File(image.path)).toList();
      // Mevcut ve yeni resimleri birleştir
      onPickDetails([...detailImages, ...newImages]);
    }
  }
}