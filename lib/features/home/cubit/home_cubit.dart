import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/features/home/repository/home_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;

  HomeCubit(this.repository) : super(HomeInitial());

  void loadBusinesses() async {
    try {
      emit(HomeLoading());
      final businesses = await repository.fetchBusinesses();
      emit(HomeLoaded(businesses));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
