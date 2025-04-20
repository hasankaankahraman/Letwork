import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/features/favorites/repository/favorites_repository.dart';
import 'package:letwork/features/favorites/cubit/favorites_state.dart';
import 'package:letwork/data/model/business_model.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesCubit(this._repository) : super(FavoritesInitial());

  Future<void> loadFavorites(String userId) async {
    if (isClosed) return;
    emit(FavoritesLoading());

    try {
      final data = await _repository.getUserFavorites(userId);

      if (!isClosed) {
        emit(FavoritesLoaded(favorites: data));
      }
    } catch (e) {
      if (!isClosed) {
        emit(FavoritesError(message: e.toString()));
      }
    }
  }

  Future<void> addFavorite(String userId, BusinessModel business) async {
    try {
      await _repository.addToFavorites(userId, business.id);

      if (isClosed) return;

      final currentState = state;
      if (currentState is FavoritesLoaded) {
        final updatedList = [...currentState.favorites, business];
        emit(FavoritesLoaded(favorites: updatedList));
      }
    } catch (e) {
      if (!isClosed) {
        emit(FavoritesError(message: "Favoriye ekleme başarısız: $e"));
      }
    }
  }

  Future<void> removeFavorite(String userId, String businessId) async {
    try {
      await _repository.removeFromFavorites(userId, businessId);

      if (isClosed) return;

      final currentState = state;
      if (currentState is FavoritesLoaded) {
        final updatedList = currentState.favorites
            .where((b) => b.id != businessId)
            .toList();

        emit(FavoritesLoaded(favorites: updatedList));
      }
    } catch (e) {
      if (!isClosed) {
        emit(FavoritesError(message: "Favoriden çıkarma başarısız: $e"));
      }
    }
  }
}
