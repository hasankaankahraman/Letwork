import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostImagesSection extends StatelessWidget {
  final File? profileImage;
  final List<File> detailImages;
  final void Function(File) onPickProfile;
  final void Function(List<File>) onPickDetails;
  final void Function(int index) onRemoveDetailImage;

  const PostImagesSection({
    super.key,
    required this.profileImage,
    required this.detailImages,
    required this.onPickProfile,
    required this.onPickDetails,
    required this.onRemoveDetailImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            final file = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (file != null) onPickProfile(File(file.path));
          },
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
          onPressed: () async {
            final files = await ImagePicker().pickMultiImage();
            onPickDetails(files.map((e) => File(e.path)).toList());
          },
          icon: const Icon(Icons.photo_library),
          label: const Text("Detay Fotoğrafları Seç"),
        ),
        if (detailImages.isNotEmpty)
          Wrap(
            spacing: 8,
            children: List.generate(detailImages.length, (index) {
              final file = detailImages[index];
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(file, height: 80, width: 80, fit: BoxFit.cover),
                  ),
                  IconButton(
                    onPressed: () => onRemoveDetailImage(index),
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              );
            }),
          ),
      ],
    );
  }
}
