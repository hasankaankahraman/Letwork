import 'package:meta/meta.dart';

@immutable
abstract class UpdateBusinessState {}

class UpdateBusinessInitial extends UpdateBusinessState {}

class BusinessDetailsLoading extends UpdateBusinessState {}

class BusinessDetailsLoaded extends UpdateBusinessState {
  final dynamic business;

  BusinessDetailsLoaded(this.business);
}

class UpdateBusinessLoading extends UpdateBusinessState {}

class UpdateBusinessSuccess extends UpdateBusinessState {
  final String message;
  final int businessId;

  UpdateBusinessSuccess(this.message, this.businessId);
}

class UpdateBusinessError extends UpdateBusinessState {
  final String message;

  UpdateBusinessError(this.message);
}