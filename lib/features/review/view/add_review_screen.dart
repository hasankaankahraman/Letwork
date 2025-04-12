import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/review/cubit/review_cubit.dart';

class AddReviewScreen extends StatefulWidget {
  final String businessId;
  final String userId;

  const AddReviewScreen({
    super.key,
    required this.businessId,
    required this.userId,
  });

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 5;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<ReviewCubit>().addOrUpdateReview(
        userId: widget.userId,
        businessId: widget.businessId,
        rating: _rating,
        comment: _commentController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yorum Yap")),
      body: BlocConsumer<ReviewCubit, ReviewState>(
        listener: (context, state) {
          if (state is ReviewSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context, true); // Ekleme sonrası geri dön
          } else if (state is ReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text("Puan", style: TextStyle(fontSize: 16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        onPressed: () => setState(() => _rating = star),
                        icon: Icon(
                          Icons.star,
                          color: _rating >= star ? Colors.amber : Colors.grey,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: "Yorumunuz",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    validator: (val) =>
                    val == null || val.isEmpty ? "Yorum giriniz" : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    child: state is ReviewLoading
                        ? const CircularProgressIndicator()
                        : const Text("Gönder"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
