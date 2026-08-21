import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_itinerary.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/build/itinerary_build_controller.dart';

class _MockCrudItinerary extends Mock implements CrudItinerary {}

void main() {
  late _MockCrudItinerary crudItinerary;
  late CreateItineraryController controller;

  setUpAll(() {
    registerFallbackValue('travel-1');
    registerFallbackValue(
      Itinerary(domainId: 'fallback', backEndId: null, agentName: '', itinerarySteps: []),
    );
  });

  setUp(() {
    crudItinerary = _MockCrudItinerary();
    controller = CreateItineraryController(crudItinerary: crudItinerary);
  });

  test('maps the raw itinerary data to the domain entity and delegates to CrudItinerary.upsert', () async {
    when(() => crudItinerary.upsert(any(), any())).thenAnswer(
      (invocation) async => Result.success(invocation.positionalArguments[1] as Itinerary),
    );

    final success = await controller.createItinerary('travel-1', {
      'agentName': 'Agent Smith',
      'steps': [],
    });

    expect(success, isTrue);
    expect(controller.isLoading, isFalse);
    expect(controller.error, isNull);
    final captured = verify(() => crudItinerary.upsert('travel-1', captureAny())).captured.single as Itinerary;
    expect(captured.agentName, 'Agent Smith');
  });

  test('surfaces the repository error message on failure', () async {
    when(() => crudItinerary.upsert(any(), any()))
        .thenAnswer((_) async => const Result.failure('Could not save itinerary.'));

    final success = await controller.createItinerary('travel-1', {'agentName': 'Agent Smith', 'steps': []});

    expect(success, isFalse);
    expect(controller.error, 'Could not save itinerary.');
  });
}
