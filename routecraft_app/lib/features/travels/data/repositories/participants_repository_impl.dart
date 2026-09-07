import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/api_exception.dart';
import 'package:routecraft_app/features/travels/data/datasources/participants_data_source.dart';
import 'package:routecraft_app/features/travels/data/dtos/travel_dto.dart';
import 'package:routecraft_app/features/travels/domain/entities/person.dart';
import 'package:routecraft_app/features/travels/domain/repositories/participants_repository.dart';

class ParticipantsRepositoryImpl implements ParticipantsRepository {
  final ParticipantsDataSource _dataSource;

  ParticipantsRepositoryImpl({ParticipantsDataSource? dataSource}) : _dataSource = dataSource ?? ParticipantsDataSource();

  @override
  Future<Result<List<Person>>> updateParticipants(String travelId, List<Person> participants) async {
    try {
      final updated = await _dataSource.updateParticipants(travelId, participants.map(PersonDTO.fromDomain).toList());
      return Result.success(updated.map((dto) => dto.toDomain()).toList());
    } on ApiException catch (e) {
      return Result.failure(e.message, isConnectivityError: e.isConnectivityError);
    } catch (_) {
      return const Result.failure('Não foi possível atualizar os participantes.', isConnectivityError: true);
    }
  }
}
