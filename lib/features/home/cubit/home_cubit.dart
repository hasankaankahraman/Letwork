import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/core/utils/location_helper.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/features/home/repository/home_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;
  bool _isLoading = false;

  HomeCubit(this.repository) : super(HomeInitial());

  Future<void> loadBusinesses({String? city, String? category}) async {
    // Eğer zaten yükleniyorsa veya Cubit kapatıldıysa işlemi iptal et
    if (_isLoading || isClosed) return;

    _isLoading = true;
    emit(HomeLoading());

    try {
      final allBusinesses = await repository.fetchBusinesses();
      final filtered = await _filterBusinesses(allBusinesses, city, category);

      if (!isClosed) {
        emit(HomeLoaded(filtered));
      }
    } catch (e) {
      if (!isClosed) {
        emit(HomeError("İşletmeler getirilemedi: $e"));
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<List<BusinessModel>> _filterBusinesses(
      List<BusinessModel> businesses,
      String? city,
      String? category,
      ) async {
    final filtered = <BusinessModel>[];

    for (final business in businesses) {
      // Cubit kapatıldıysa döngüyü sonlandır
      if (isClosed) break;

      try {
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
      } catch (e) {
        // Şehir bulunamazsa bu işletmeyi atla
        continue;
      }
    }

    return filtered;
  }

  @override
  Future<void> close() {
    // Cubit kapatılırken temizlik yap
    _isLoading = false;
    return super.close();
  }
}