import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/features/search/cubit/search_state.dart';
import 'package:letwork/features/search/repository/search_repository.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository repository;

  SearchCubit(this.repository) : super(SearchInitial());

  Future<void> search(String query) async {
    emit(SearchLoading());
    try {
      final results = await repository.searchBusinesses(query: query);
      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> fetchBusinessesByRadius({
    required double latitude,
    required double longitude,
  }) async {
    try {
      emit(SearchLoading());
      final results = await repository.fetchBusinessesByRadius(
        latitude: latitude,
        longitude: longitude,
      );
      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

}
