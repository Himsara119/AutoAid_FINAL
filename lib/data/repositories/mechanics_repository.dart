import '../../features/mechanics/models/mechanic_entity.dart';

abstract class MechanicsApi {
  Future<List<MechanicPlace>> search(String query, {double? lat, double? lng});
}

class MechanicsRepository {
  final MechanicsApi api;
  MechanicsRepository(this.api);

  Future<List<MechanicPlace>> find(String query, {double? lat, double? lng}) =>
      api.search(query, lat: lat, lng: lng);
}
