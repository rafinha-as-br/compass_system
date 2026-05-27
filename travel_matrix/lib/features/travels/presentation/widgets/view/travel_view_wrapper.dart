import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/core/services/compass_service/compass_service.dart';
import 'package:travel_matrix/features/travels/data/dtos/travel_dto.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/travel_view_page.dart';

class TravelViewWrapper extends StatefulWidget {
  final String travelId;
  final TravelViewModel? initialTravel;
  final TravelsController? initialController;

  const TravelViewWrapper({
    super.key,
    required this.travelId,
    this.initialTravel,
    this.initialController,
  });

  @override
  State<TravelViewWrapper> createState() => _TravelViewWrapperState();
}

class _TravelViewWrapperState extends State<TravelViewWrapper> {
  late Future<TravelViewModel?> _travelFuture;
  late final TravelsController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.initialController == null;
    _controller = widget.initialController ?? TravelsController();
    
    if (widget.initialTravel != null) {
      _travelFuture = Future.value(widget.initialTravel);
    } else {
      _travelFuture = _fetchTravelById(widget.travelId);
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<TravelViewModel?> _fetchTravelById(String id) async {
    final token = await AuthStorageService.instance.getToken();
    if (token == null) return null;
    
    final response = await CompassService.instance.getTravel(token, id);
    if (response['status'] == 'success') {
      final dto = TravelDTO.fromJson(response['data'] as Map<String, dynamic>);
      return TravelViewModel.fromDomain(dto.toDomain());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: FutureBuilder<TravelViewModel?>(
        future: _travelFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Travel Not Found')),
              body: const Center(
                child: Text('The requested travel could not be found.'),
              ),
            );
          }
          
          return TravelViewPage(travel: snapshot.data!);
        },
      ),
    );
  }
}
