part of 'add_business_cubit.dart';

@immutable
abstract class AddBusinessState {}

class AddBusinessInitial extends AddBusinessState {}

class AddBusinessLoading extends AddBusinessState {}

class AddBusinessSuccess extends AddBusinessState {
  final String message;
  final String businessId;

  AddBusinessSuccess({required this.message, required this.businessId});
}

class AddBusinessError extends AddBusinessState {
  final String message;

  AddBusinessError({required this.message});
}
