import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/data/services/favorites_service.dart';

class FavoritesRepository {
  final FavoritesService _service = FavoritesService();

  Future<List<BusinessModel>> getUserFavorites(String userId) {
    return _service.fetchUserFavorites(userId);
  }
  Future<void> removeFromFavorites(String userId, String businessId) {
    return _service.removeFromFavorites(userId, businessId);
  }

}
