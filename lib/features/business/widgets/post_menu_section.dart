import 'package:flutter/material.dart';

class PostMenuSection extends StatelessWidget {
  final List<Map<String, String>> services;
  final VoidCallback onAddService;
  final void Function(int index) onRemoveService;
  final void Function(int index, String key, String value) onUpdateService;

  const PostMenuSection({
    super.key,
    required this.services,
    required this.onAddService,
    required this.onRemoveService,
    required this.onUpdateService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Verilen Hizmetler", style: TextStyle(fontWeight: FontWeight.bold)),
        ...services.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item['name'],
                  decoration: const InputDecoration(labelText: "Hizmet"),
                  onChanged: (val) => onUpdateService(index, 'name', val),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: item['price'],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Fiyat"),
                  onChanged: (val) => onUpdateService(index, 'price', val),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => onRemoveService(index),
              ),
            ],
          );
        }),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: onAddService,
          icon: const Icon(Icons.add),
          label: const Text("Hizmet Ekle"),
        ),
      ],
    );
  }
}
