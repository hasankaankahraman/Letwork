import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextFormField(
            controller: nameController,
            labelText: "İşletme Adı",
            hintText: "İşletmenizin adını girin",
            prefixIcon: Icons.business,
            validator: (val) => val == null || val.isEmpty ? "Zorunlu" : null,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: descController,
            labelText: "Açıklama",
            hintText: "İşletmeniz hakkında kısa bir açıklama yazın",
            prefixIcon: Icons.description,
            maxLines: 3,
            validator: (val) => val == null || val.isEmpty ? "Zorunlu" : null,
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              "Çalışma Saatleri",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildTimePickerField(
                  context: context,
                  controller: openController,
                  labelText: "Açılış Saati",
                  hintText: "Seçin",
                  prefixIcon: Icons.access_time,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePickerField(
                  context: context,
                  controller: closeController,
                  labelText: "Kapanış Saati",
                  hintText: "Seçin",
                  prefixIcon: Icons.access_time_filled,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              "İşletme Türü",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          _buildBusinessTypeSelector(),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              "Kategori Bilgileri",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          _buildDropdownField(
            value: selectedCategoryGroup,
            labelText: "Kategori",
            hintText: "Bir kategori seçin",
            prefixIcon: Icons.category,
            items: categoryGroups.map((cat) {
              return DropdownMenuItem<String>(
                value: cat['group'],
                child: Text(cat['group']),
              );
            }).toList(),
            onChanged: onCategoryGroupChanged,
            validator: (val) => val == null ? "Kategori seçin" : null,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            value: selectedSubCategory,
            labelText: "Alt Kategori",
            hintText: "Bir alt kategori seçin",
            prefixIcon: Icons.view_list,
            items: (selectedGroup['items'] as List).map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onSubCategoryChanged,
            validator: (val) => val == null ? "Alt kategori seçin" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Color(0xFFFF0000)) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFFF0000), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildTimePickerField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
  }) {
    return GestureDetector(
      onTap: () => _showTimePicker(context, controller),
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Color(0xFFFF0000)) : null,
            suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF0000)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFFF0000), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (val) => val == null || val.isEmpty ? "Zorunlu" : null,
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context, TextEditingController controller) {
    DateTime initialTime = DateTime.now();
    int minute = initialTime.minute;
    int roundedMinute = (minute / 5).round() * 5;
    if (roundedMinute == 60) {
      initialTime = DateTime(initialTime.year, initialTime.month, initialTime.day, initialTime.hour + 1, 0);
    } else {
      initialTime = DateTime(initialTime.year, initialTime.month, initialTime.day, initialTime.hour, roundedMinute);
    }

    if (controller.text.isNotEmpty) {
      try {
        List<String> timeParts = controller.text.split(':');
        if (timeParts.length == 2) {
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1]);
          minute = (minute / 5).round() * 5;
          if (minute == 60) {
            hour = (hour + 1) % 24;
            minute = 0;
          }
          initialTime = DateTime(initialTime.year, initialTime.month, initialTime.day, hour, minute);
        }
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        DateTime selectedTime = initialTime;
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("İptal", style: TextStyle(color: Colors.red)),
                  ),
                  const Text(
                    "Saat Seçin",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF0000),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final hour = selectedTime.hour.toString().padLeft(2, '0');
                      final minute = selectedTime.minute.toString().padLeft(2, '0');
                      controller.text = "$hour:$minute";
                      Navigator.pop(context);
                    },
                    child: const Text("Tamam", style: TextStyle(color: Color(0xFFFF0000))),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(color: Colors.black87, fontSize: 22),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: initialTime,
                    minuteInterval: 5,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime time) {
                      selectedTime = time;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBusinessTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => onCorporateChanged(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: !isCorporate ? Color(0xFFFF0000) : Colors.transparent,
                foregroundColor: !isCorporate ? Colors.white : Colors.grey.shade700,
                elevation: !isCorporate ? 2 : 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Bireysel", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () => onCorporateChanged(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorporate ? Color(0xFFFF0000) : Colors.transparent,
                foregroundColor: isCorporate ? Colors.white : Colors.grey.shade700,
                elevation: isCorporate ? 2 : 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Kurumsal", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Color(0xFFFF0000)) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFFF0000), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF0000)),
      isExpanded: true,
      dropdownColor: Colors.white,
    );
  }
}
