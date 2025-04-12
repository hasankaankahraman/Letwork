import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/core/utils/location_helper.dart'; // Bunu unutma abi
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/features/home/repository/home_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;

  HomeCubit(this.repository) : super(HomeInitial());

  void loadBusinesses({String? city, String? category}) async {
    try {
      emit(HomeLoading());

      final allBusinesses = await repository.fetchBusinesses(); // tüm işletmeleri çek

      List<BusinessModel> filtered = [];

      for (final business in allBusinesses) {
        final detectedCity = await LocationHelper.getCityFromCoordinates(
          business.latitude,
          business.longitude,
        );

        final cityMatch = city == null ||
            (detectedCity != null &&
                detectedCity.toLowerCase().contains(city.toLowerCase()));

        final categoryMatch = category == null ||
            category.isEmpty ||
            business.subCategory == category;

        if (cityMatch && categoryMatch) {
          filtered.add(business);
        }
      }

      emit(HomeLoaded(filtered));
    } catch (e) {
      emit(HomeError("İşletmeler getirilemedi: $e"));
    }
  }
}
