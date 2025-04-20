// lib/features/chat/widgets/chat_app_bar.dart
import 'package:flutter/material.dart';
import 'package:letwork/data/model/business_model.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Future<BusinessModel>? businessDetails;
  final bool isInitialized;
  final Color themeColor;
  final VoidCallback onRefresh;
  final bool isRefreshing;

  const ChatAppBar({
    super.key,
    required this.businessDetails,
    required this.isInitialized,
    required this.themeColor,
    required this.onRefresh,
    required this.isRefreshing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: themeColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: themeColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: isInitialized
          ? FutureBuilder<BusinessModel>(
        future: businessDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          } else if (snapshot.hasError) {
            return Text(
              'Hata oluştu',
              style: TextStyle(color: themeColor, fontSize: 14),
            );
          } else if (snapshot.hasData) {
            return _buildBusinessHeader(snapshot.data!);
          } else {
            return const Text(
              'İşletme Bulunamadı',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            );
          }
        },
      )
          : _buildLoadingIndicator(),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          height: 1.0,
          color: themeColor,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: themeColor),
          onPressed: isRefreshing ? null : onRefresh,
        ),
        _buildMenuButton(context),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: themeColor,
        ),
      ),
    );
  }

  Widget _buildBusinessHeader(BusinessModel business) {
    return Row(
      children: [
        Hero(
          tag: 'business-${business.id}',
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(color: themeColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: _buildBusinessImage(business),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                business.name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Çevrimiçi',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessImage(BusinessModel business) {
    return Image.network(
      business.profileImage.isNotEmpty
          ? "https://letwork.hasankaan.com/${business.profileImage}"
          : "https://letwork.hasankaan.com/assets/default_profile.png",
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.store, color: Colors.grey),
      ),
      loadingBuilder: (_, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: themeColor),
      onSelected: (value) {
        switch (value) {
          case 'profile':
          // İşletme profilini göster
            break;
          case 'block':
          // İşletmeyi engelle
            break;
          case 'report':
          // İşletmeyi şikayet et
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.store, size: 18, color: themeColor),
              const SizedBox(width: 8),
              const Text('İşletme Profili'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'block',
          child: Row(
            children: [
              Icon(Icons.block, size: 18, color: themeColor),
              const SizedBox(width: 8),
              const Text('İşletmeyi Engelle'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.flag, size: 18, color: themeColor),
              const SizedBox(width: 8),
              const Text('Şikayet Et'),
            ],
          ),
        ),
      ],
    );
  }
}