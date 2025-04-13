import 'package:flutter/material.dart';

class CitySelectorModal extends StatefulWidget {
  final String selectedCity;
  final Function(String) onCitySelected;
  final VoidCallback onUseCurrentLocation;
  final List<String> majorCities;
  final List<String> allCities;
  final TextEditingController searchController;
  final bool isLoadingLocation;

  const CitySelectorModal({
    super.key,
    required this.selectedCity,
    required this.onCitySelected,
    required this.onUseCurrentLocation,
    required this.majorCities,
    required this.allCities,
    required this.searchController,
    required this.isLoadingLocation,
  });

  @override
  State<CitySelectorModal> createState() => _CitySelectorModalState();
}

class _CitySelectorModalState extends State<CitySelectorModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve kapatma butonu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Şehir Seçin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Arama kutusu
          TextField(
            controller: widget.searchController,
            decoration: InputDecoration(
              hintText: 'Şehir ara...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFFFF0000)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Konumumu Kullan Butonu
          InkWell(
            onTap: widget.onUseCurrentLocation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location, color: Color(0xFFFF0000), size: 22),
                  const SizedBox(width: 12),
                  const Text(
                    'Konumumu Kullan',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  const Spacer(),
                  if (widget.isLoadingLocation)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Büyükşehirler',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Büyükşehirler Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: widget.majorCities.length,
            itemBuilder: (context, index) {
              final city = widget.majorCities[index];
              final isSelected = city == widget.selectedCity;

              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  widget.onCitySelected(city);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFF0000) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    city,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          const Text(
            'Diğer Şehirler',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Diğer şehirler listesi
          Expanded(
            child: ListView.builder(
              itemCount: _getFilteredCities().length,
              itemBuilder: (context, index) {
                final city = _getFilteredCities()[index];
                final isSelected = city == widget.selectedCity;

                return ListTile(
                  title: Text(city),
                  tileColor: isSelected ? Colors.red.shade50 : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onCitySelected(city);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getFilteredCities() {
    final query = widget.searchController.text.toLowerCase();
    if (query.isEmpty) {
      return widget.allCities
          .where((city) => !widget.majorCities.contains(city))
          .toList();
    }
    return widget.allCities
        .where((city) => city.toLowerCase().contains(query))
        .toList();
  }
}
