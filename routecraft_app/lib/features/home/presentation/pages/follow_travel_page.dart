import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';
import 'package:routecraft_app/shared/widgets/app_button.dart';
import 'package:routecraft_app/shared/widgets/app_text_field.dart';

class FollowTravelPage extends StatefulWidget {
  final Travel? travel;
  const FollowTravelPage({super.key, this.travel});

  @override
  State<FollowTravelPage> createState() => _FollowTravelPageState();
}

class _FollowTravelPageState extends State<FollowTravelPage> {
  final TextEditingController _travelIdController = TextEditingController();

  @override
  void dispose() {
    _travelIdController.dispose();
    super.dispose();
  }

  void _followTravel() {
    final travelId = _travelIdController.text.trim();
    if (travelId.isNotEmpty) {
      // Mock follow action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Following Travel ID: $travelId')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Follow Travel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: widget.travel == null ? _buildSearchState() : _buildFollowingState(),
      ),
    );
  }

  Widget _buildSearchState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter the Travel ID to follow a specific route and its itinerary.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        AppTextField(
          controller: _travelIdController,
          labelText: 'Travel ID',
          prefixIcon: const Icon(Icons.search),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _followTravel(),
        ),
        const SizedBox(height: 32),
        AppButton(
          onPressed: _followTravel,
          child: const Text('Follow Travel', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildFollowingState() {
    final t = widget.travel!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle_outline, color: TravelAppColors.success, size: 64),
        const SizedBox(height: 16),
        Text(
          'Following: ${t.travelName}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${t.routePlan.startLocation} ➔ ${t.routePlan.destination}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: TravelAppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Travel Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Status: ${t.travelStatus.name}'),
                Text('Has Itinerary: ${t.hasItinerary ? 'Yes' : 'No'}'),
                Text('Travelers: ${t.participantsList.length}'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
