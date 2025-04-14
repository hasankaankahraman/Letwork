import 'package:letwork/data/model/business_model.dart';

abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<BusinessModel> favorites;

  FavoritesLoaded({required this.favorites});
}

class FavoritesError extends FavoritesState {
  final String message;

  FavoritesError({required this.message});
}
