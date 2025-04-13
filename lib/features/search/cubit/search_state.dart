import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:letwork/data/model/business_model.dart';

class SearchState extends Equatable {
  final List<BusinessModel> businesses;
  final BusinessModel? selectedBusiness;
  final String? selectedCategory;
  final bool isLoading;
  final String? error;
  final LatLng? mapCenter;

  const SearchState({
    this.businesses = const [],
    this.selectedBusiness,
    this.selectedCategory,
    this.isLoading = false,
    this.error,
    this.mapCenter,
  });

  SearchState copyWith({
    List<BusinessModel>? businesses,
    BusinessModel? selectedBusiness,
    String? selectedCategory,
    bool? isLoading,
    String? error,
    LatLng? mapCenter,
  }) {
    return SearchState(
      businesses: businesses ?? this.businesses,
      selectedBusiness: selectedBusiness ?? this.selectedBusiness,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      mapCenter: mapCenter ?? this.mapCenter,
    );
  }

  @override
  List<Object?> get props => [
    businesses,
    selectedBusiness,
    selectedCategory,
    isLoading,
    error,
    mapCenter,
  ];
}
