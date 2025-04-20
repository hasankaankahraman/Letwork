import 'package:bad_words/bad_words.dart';
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
  final _filter = Filter();
  int _rating = 5;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final commentText = _commentController.text;

      if (_filter.isProfane(commentText)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Yorumunuzda uygunsuz kelimeler tespit edildi."),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      context.read<ReviewCubit>().addOrUpdateReview(
        userId: widget.userId,
        businessId: widget.businessId,
        rating: _rating,
        comment: commentText,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Değerlendirme Ekle",
          style: TextStyle(color: Color(0xFFFF0000)),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: BlocConsumer<ReviewCubit, ReviewState>(
        listener: (context, state) {
          if (state is ReviewSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "İşletmeyi değerlendirin",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF0000),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Puanınız",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFFF0000),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final star = index + 1;
                          final isSelected = _rating >= star;

                          return GestureDetector(
                            onTap: () => setState(() => _rating = star),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: isSelected
                                  ? const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x99FFF700),
                                    blurRadius: 20,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              )
                                  : null,
                              child: Icon(
                                Icons.star_rounded,
                                size: 36,
                                color: isSelected ? const Color(0xFFFFE700) : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      "Yorumunuz",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFFF0000),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: "Deneyiminizi paylaşın...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: const Color(0xFFFF0000).withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: const Color(0xFFFF0000), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 5,
                      validator: (val) =>
                      val == null || val.isEmpty ? "Lütfen bir yorum giriniz" : null,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: state is ReviewLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF0000),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: state is ReviewLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          "Değerlendirmeyi Gönder",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
