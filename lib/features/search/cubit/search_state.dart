import 'package:equatable/equatable.dart';
import 'package:letwork/data/model/business_model.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<BusinessModel> businesses;

  const SearchLoaded(this.businesses);

  @override
  List<Object?> get props => [businesses];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
