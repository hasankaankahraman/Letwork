part of 'profile_cubit.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUpdating extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final List<BusinessModel> businesses;

  ProfileLoaded(this.businesses);
}

class ProfileUpdated extends ProfileState {
  final String message;

  ProfileUpdated({required this.message});
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
