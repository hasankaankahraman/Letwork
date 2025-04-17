import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/features/home/repository/home_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;
  bool _isLoading = false;

  HomeCubit(this.repository) : super(HomeInitial());

  Future<void> loadBusinesses({
    required String userId,
    required String city,
    required String category,
  }) async {
    if (_isLoading || isClosed) return;

    _isLoading = true;
    emit(HomeLoading());

    try {
      final allBusinesses = await repository.fetchBusinesses(
        city: city,
        category: category,
        userId: userId,
      );

      // Filtreleme işlemini kaldırdık çünkü backend'de filtreleme zaten yapılıyor
      if (!isClosed) {
        emit(HomeLoaded(allBusinesses));
      }
    } catch (e) {
      if (!isClosed) {
        emit(HomeError("İşletmeler getirilemedi: $e"));
      }
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<void> close() {
    _isLoading = false;
    return super.close();
  }
}
