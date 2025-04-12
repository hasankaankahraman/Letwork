import 'package:flutter/material.dart';

class PostBusinessInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController openController;
  final TextEditingController closeController;
  final bool isCorporate;
  final Function(bool) onCorporateChanged;
  final String? selectedCategoryGroup;
  final String? selectedSubCategory;
  final List<Map<String, dynamic>> categoryGroups;
  final Function(String?) onCategoryGroupChanged;
  final Function(String?) onSubCategoryChanged;

  const PostBusinessInfoSection({
    super.key,
    required this.nameController,
    required this.descController,
    required this.openController,
    required this.closeController,
    required this.isCorporate,
    required this.onCorporateChanged,
    required this.selectedCategoryGroup,
    required this.selectedSubCategory,
    required this.categoryGroups,
    required this.onCategoryGroupChanged,
    required this.onSubCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedGroup = categoryGroups.firstWhere(
          (group) => group['group'] == selectedCategoryGroup,
      orElse: () => {'items': []},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            Switch(value: isCorporate, onChanged: onCorporateChanged),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: selectedCategoryGroup,
          decoration: const InputDecoration(labelText: "Kategori"),
          items: categoryGroups
              .map((cat) => DropdownMenuItem<String>(
            value: cat['group'],
            child: Text(cat['group']),
          ))
              .toList(),
          onChanged: onCategoryGroupChanged,
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
          onChanged: onSubCategoryChanged,
          validator: (val) => val == null ? "Alt kategori seçin" : null,
        ),
      ],
    );
  }
}
