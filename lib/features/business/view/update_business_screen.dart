import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/business/cubit/update_business_cubit.dart';
import 'package:letwork/features/business/cubit/update_business_state.dart';

class UpdateBusinessScreen extends StatefulWidget {
  final int businessId;

  const UpdateBusinessScreen({
    super.key,
    required this.businessId,
  });

  @override
  State<UpdateBusinessScreen> createState() => _UpdateBusinessScreenState();
}

class _UpdateBusinessScreenState extends State<UpdateBusinessScreen> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch business details when screen initializes
    context.read<UpdateBusinessCubit>().fetchBusinessDetails(widget.businessId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İşletme Güncelle"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocConsumer<UpdateBusinessCubit, UpdateBusinessState>(
        listener: (context, state) {
          if (state is UpdateBusinessSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("İşletme başarıyla güncellendi"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is UpdateBusinessError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Hata: ${state.message}"),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is BusinessDetailsLoaded) {
            // Pre-fill form fields with existing data
            _nameController.text = state.business.name ?? '';
            _descriptionController.text = state.business.description ?? '';
            _addressController.text = state.business.address ?? '';
            _phoneController.text = state.business.phone ?? '';
            _emailController.text = state.business.email ?? '';
            _websiteController.text = state.business.website ?? '';
          }
        },
        builder: (context, state) {
          if (state is BusinessDetailsLoading || state is UpdateBusinessInitial) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF0000)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form fields
                _buildFormField(
                  controller: _nameController,
                  label: "İşletme Adı",
                  icon: Icons.business,
                ),
                _buildFormField(
                  controller: _descriptionController,
                  label: "Açıklama",
                  icon: Icons.description,
                  maxLines: 3,
                ),
                _buildFormField(
                  controller: _addressController,
                  label: "Adres",
                  icon: Icons.location_on,
                  maxLines: 2,
                ),
                _buildFormField(
                  controller: _phoneController,
                  label: "Telefon",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                _buildFormField(
                  controller: _emailController,
                  label: "E-posta",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildFormField(
                  controller: _websiteController,
                  label: "Web Sitesi",
                  icon: Icons.web,
                  keyboardType: TextInputType.url,
                ),

                const SizedBox(height: 20),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is UpdateBusinessLoading
                        ? null
                        : () {
                      context.read<UpdateBusinessCubit>().updateBusiness(
                        businessId: widget.businessId,
                        name: _nameController.text,
                        description: _descriptionController.text,
                        address: _addressController.text,
                        phone: _phoneController.text,
                        email: _emailController.text,
                        website: _websiteController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: state is UpdateBusinessLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text("İşletmeyi Güncelle"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF0000)),
          ),
        ),
      ),
    );
  }
}