import 'package:flutter/material.dart';
import 'package:letwork/data/model/business_detail_model.dart';

class PhotosSection extends StatelessWidget {
  final BusinessDetailModel business;

  const PhotosSection({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final images = business.images;

    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Fotoğraflar",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF0000), // Kırmızı tema
              ),
            ),
            if (images.length > 3)
              TextButton(
                onPressed: () {
                  _showAllPhotos(context, images);
                },
                child: const Text(
                  "Tümünü Gör",
                  style: TextStyle(
                    color: Color(0xFFFF0000), // Kırmızı tema
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imageUrl = images[index]['image_url'];
              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 160,
                child: GestureDetector(
                  onTap: () {
                    _showFullImage(
                      context,
                      "https://letwork.hasankaan.com/$imageUrl",
                      index,
                      images,
                    );
                  },
                  child: Hero(
                    tag: "image_$index",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        "https://letwork.hasankaan.com/$imageUrl",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFullImage(BuildContext context, String imageUrl, int initialIndex, List<dynamic> images) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imgUrl = "https://letwork.hasankaan.com/${images[index]['image_url']}";
                return GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Hero(
                    tag: "image_$index",
                    child: InteractiveViewer(
                      child: Center(
                        child: Image.network(imgUrl),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllPhotos(BuildContext context, List<dynamic> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Tüm Fotoğraflar")),
          body: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imageUrl = images[index]['image_url'];
              return GestureDetector(
                onTap: () {
                  _showFullImage(
                    context,
                    "https://letwork.hasankaan.com/$imageUrl",
                    index,
                    images,
                  );
                },
                child: Hero(
                  tag: "image_$index",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "https://letwork.hasankaan.com/$imageUrl",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
