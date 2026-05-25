
import 'package:travel_matrix/core/services/auth_service.dart';
import 'package:travel_matrix/core/services/compass_service/clients/travel_api_client.dart';
import 'package:travel_matrix/features/travels/data/dtos/travel_dto.dart';

class TravelDataSource{
  final _travelService = TravelApiClient.instance;
  final _authService = AuthService.instance;

  Future<TravelDTO> getTravel(String id) async{

    final token = await _authService.getToken();
    final result = await _travelService.getTravel(token!, id);
    return TravelDTO.fromJson(result);

  }

  Future<List<PersonDTO>> getPersons(List<String> ids) async{
    final token = await _authService.getToken();
    final result = await Future.wait(ids.map((id) => _travelService.getPersons(token!, id)));
    return result.map((e) => PersonDTO.fromJson(e)).toList();
  }


}