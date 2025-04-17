import 'package:letwork/data/model/business_detail_model.dart';

abstract class UpdateBusinessState {}

class UpdateBusinessInitial extends UpdateBusinessState {}

class BusinessDetailsLoading extends UpdateBusinessState {}

class BusinessDetailsLoaded extends UpdateBusinessState {
  final BusinessDetailModel business;

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