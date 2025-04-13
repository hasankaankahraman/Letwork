import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/features/search/cubit/search_state.dart';
import 'package:letwork/features/search/repository/search_repository.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository repository;

  SearchCubit(this.repository) : super(const SearchState());

  void updateCategory(String? category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void updateMapCenter(LatLng center) {
    emit(state.copyWith(mapCenter: center));
  }

  void selectBusiness(BusinessModel business) {
    emit(state.copyWith(selectedBusiness: business));
  }

  Future<void> fetchBusinessesByRadius({
    required double latitude,
    required double longitude,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final results = await repository.fetchBusinessesByRadius(
        latitude: latitude,
        longitude: longitude,
        // radius sabit olabilir ya da repository default ile çözebilir
        radiusKm: 5.0,
        category: state.selectedCategory,
      );

      emit(state.copyWith(
        businesses: results,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> search(String query) async {
    emit(state.copyWith(isLoading: true));

    try {
      final results = await repository.searchBusinesses(query: query);
      emit(state.copyWith(businesses: results, isLoading: false, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
