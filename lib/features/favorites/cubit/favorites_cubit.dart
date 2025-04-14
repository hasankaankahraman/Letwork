import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/favorites/repository/favorites_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesCubit(this._repository) : super(FavoritesInitial());

  Future<void> loadFavorites(String userId) async {
    emit(FavoritesLoading());

    try {
      final data = await _repository.getUserFavorites(userId);
      emit(FavoritesLoaded(favorites: data));
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }
  Future<void> removeFavorite(String userId, String businessId) async {
    try {
      await _repository.removeFromFavorites(userId, businessId);

      // Güncel listeyi al
      final currentState = state;
      if (currentState is FavoritesLoaded) {
        final updatedList = currentState.favorites
            .where((b) => b.id != businessId)
            .toList();

        emit(FavoritesLoaded(favorites: updatedList));
      }
    } catch (e) {
      emit(FavoritesError(message: "Favoriden çıkarma başarısız: $e"));
    }
  }

}
