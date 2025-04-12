import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/business/view/business_detail_screen.dart';
import 'package:letwork/features/home/cubit/home_cubit.dart';
import 'package:letwork/features/home/repository/home_repository.dart';
import 'package:letwork/data/model/business_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(HomeRepository())..loadBusinesses(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("İşletmeler"),
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeLoaded) {
              return ListView.builder(
                itemCount: state.businesses.length,
                itemBuilder: (context, index) {
                  final BusinessModel bModel = state.businesses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: bModel.profileImage.isNotEmpty
                          ? Image.network(
                        "https://letwork.hasankaan.com/${bModel.profileImage}",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.store),
                      title: Text(bModel.name),
                      subtitle: Text(bModel.category),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => BusinessDetailScreen(businessId: bModel.id),
                            transitionsBuilder: (_, anim, __, child) {
                              return FadeTransition(opacity: anim, child: child);
                            },
                          ),
                        );
                      },

                    ),
                  );
                },
              );
            } else if (state is HomeError) {
              return Center(child: Text("Hata: ${state.message}"));
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
