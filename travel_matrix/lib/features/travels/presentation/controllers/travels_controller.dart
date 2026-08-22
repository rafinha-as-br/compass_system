import 'package:flutter/material.dart';
import 'package:travel_matrix/core/services/compass_service/api_response_status.dart';
import 'package:travel_matrix/core/services/compass_service/compass_service.dart';
import 'package:travel_matrix/features/travels/data/dtos/travel_dto.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';

import '../../../../core/services/auth_storage_service.dart';
import '../models/view_models/travel_view_model.dart';

class TravelsState {
  final bool isLoading;
  final List<TravelViewModel> travels;
  final String? errorMessage;

  const TravelsState({
    this.isLoading = true,
    this.travels = const [],
    this.errorMessage,
  });
}

class TravelsController extends ChangeNotifier {
  TravelsState _state = const TravelsState();
  TravelsState get state => _state;

  TravelsController() {
    fetchTravels();
  }

  Future<void> fetchTravels() async {
    _state = const TravelsState(isLoading: true);
    notifyListeners();

    try {
      final token = await AuthStorageService.instance.getToken();
      if (token == null) {
        _state = const TravelsState(
            isLoading: false,
            errorMessage: 'Not authenticated.');
        notifyListeners();
        return;
      }

      final response = await CompassService.instance.getAllTravels(token);

      if (response['status'] == kApiSuccessStatus) {
        final data = response['data'] as List<dynamic>;
        final travels = data
            .map((e) => TravelDTO.fromJson(e as Map<String, dynamic>).toDomain())
            .map((t) => TravelViewModel.fromDomain(t))
            .toList();
        _state = TravelsState(isLoading: false, travels: travels);
      } else {
        _state = TravelsState(
          isLoading: false,
          errorMessage: response['message'] as String?,
        );
      }
      notifyListeners();
    } catch (e) {
      _state = TravelsState(
        isLoading: false,
        errorMessage: 'Failed to fetch travels: $e',
      );
      notifyListeners();
    }
  }

  Future<bool> createTravel(Map<String, dynamic> travelData) async {
    try {
      final token = await AuthStorageService.instance.getToken();
      if (token == null) return false;

      final response =
          await CompassService.instance.createTravel(token, travelData);
      if (response['status'] == kApiSuccessStatus) {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTravel(String travelId) async {
    try {
      final token = await AuthStorageService.instance.getToken();
      if (token == null) return false;

      final response =
          await CompassService.instance.deleteTravel(token, travelId);
      if (response['status'] == kApiSuccessStatus) {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateRoute(
      String travelId, Map<String, dynamic> routeData) async {
    try {
      final token = await AuthStorageService.instance.getToken();
      if (token == null) return false;

      final response = await CompassService.instance
          .updateRoute(token, travelId, routeData);
      if (response['status'] == kApiSuccessStatus) {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createItinerary(
      String travelId, Map<String, dynamic> itineraryData) async {
    try {
      final token = await AuthStorageService.instance.getToken();
      if (token == null) return false;

      final response = await CompassService.instance
          .createItinerary(token, travelId, itineraryData);
      if (response['status'] == kApiSuccessStatus) {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateItinerary(
      String travelId, Map<String, dynamic> itineraryData) async {
    try {
      final token = await AuthStorageService.instance.getToken();
      if (token == null) return false;

      final response = await CompassService.instance
          .updateItinerary(token, travelId, itineraryData);
      if (response['status'] == kApiSuccessStatus) {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markTravelAsReady(String travelId) async {
    try {
      final token = await AuthStorageService.instance.getToken();
      if (token == null) return false;

      final getResponse = await CompassService.instance.getTravel(token, travelId);
      if (getResponse['status'] != kApiSuccessStatus) return false;

      final travelData = getResponse['data'] as Map<String, dynamic>;
      travelData['travelStatus'] = TravelStatus.itineraryCreated.toApiValue();

      final updateResponse = await CompassService.instance.updateTravel(token, travelId, travelData);

      if (updateResponse['status'] == kApiSuccessStatus) {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
