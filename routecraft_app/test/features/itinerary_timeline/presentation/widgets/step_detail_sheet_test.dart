import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/itinerary_timeline/presentation/widgets/step_detail_sheet.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary_step.dart';
import 'package:routecraft_app/features/travels/domain/entities/transport.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

Widget _wrap(ItineraryStep step) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: StepDetailSheet(step: step)),
  );
}

void main() {
  group('StepDetailSheet', () {
    testWidgets('Stop shows name, description and experiences', (tester) async {
      await tester.pumpWidget(_wrap(ItineraryStep.newStop(
        domainId: 's1',
        backEndId: 's1',
        title: 'Trilha do Sono',
        startDate: DateTime(2026, 10, 13, 9),
        finishDate: DateTime(2026, 10, 13, 13),
        finished: false,
        name: 'Trilha do Sono',
        description: 'Trilha guiada pela mata.',
        experiences: const ['Cachoeira', 'Mirante'],
      )));

      expect(find.text('Stop'), findsOneWidget);
      expect(find.text('Trilha do Sono'), findsOneWidget);
      expect(find.text('Trilha guiada pela mata.'), findsOneWidget);
      expect(find.text('Cachoeira, Mirante'), findsOneWidget);
    });

    testWidgets('Stop with empty description and experiences shows only the name tile', (tester) async {
      await tester.pumpWidget(_wrap(ItineraryStep.newStop(
        domainId: 's2',
        backEndId: 's2',
        title: 'Parada',
        startDate: DateTime(2026, 10, 13, 9),
        finishDate: DateTime(2026, 10, 13, 10),
        finished: false,
        name: 'Parada',
        description: '',
        experiences: const [],
      )));

      expect(find.byType(Text), findsNWidgets(3)); // subtype caption + label + value, no extra tiles
      expect(find.text('Description'), findsNothing);
      expect(find.text('Experiences'), findsNothing);
    });

    testWidgets('Hosting shows address, check-in and check-out', (tester) async {
      await tester.pumpWidget(_wrap(ItineraryStep.newHosting(
        domainId: 'h1',
        backEndId: 'h1',
        title: 'Pousada Vila do Porto',
        startDate: DateTime(2026, 10, 12, 16),
        finishDate: DateTime(2026, 10, 14, 11),
        finished: false,
        name: 'Pousada Vila do Porto',
        address: 'Rua das Flores, 123',
        checkIn: DateTime(2026, 10, 12, 16),
        checkOut: DateTime(2026, 10, 14, 11),
      )));

      expect(find.text('Hosting'), findsOneWidget);
      expect(find.text('Rua das Flores, 123'), findsOneWidget);
      expect(find.text('12 Oct · 16:00'), findsOneWidget);
      expect(find.text('14 Oct · 11:00'), findsOneWidget);
    });

    testWidgets('PlaceholderStep with a description shows only that tile, without breaking layout', (tester) async {
      await tester.pumpWidget(_wrap(ItineraryStep.newPlaceholder(
        domainId: 'p1',
        backEndId: 'p1',
        title: 'A definir',
        description: 'Detalhes ainda não confirmados pelo agente.',
        startDate: DateTime(2026, 10, 15, 9),
        finishDate: DateTime(2026, 10, 15, 10),
        finished: false,
      )));

      expect(find.text('Placeholder'), findsOneWidget);
      expect(find.text('Detalhes ainda não confirmados pelo agente.'), findsOneWidget);
    });

    testWidgets('PlaceholderStep with no description renders without error and without a leftover label', (tester) async {
      await tester.pumpWidget(_wrap(ItineraryStep.newPlaceholder(
        domainId: 'p2',
        backEndId: 'p2',
        title: 'A definir',
        description: '',
        startDate: DateTime(2026, 10, 15, 9),
        finishDate: DateTime(2026, 10, 15, 10),
        finished: false,
      )));

      expect(find.text('Placeholder'), findsOneWidget);
      expect(find.text('Description'), findsNothing);
    });

    testWidgets('TravelSegment/Airplane shows origin, destination and flight fields', (tester) async {
      await tester.pumpWidget(_wrap(ItineraryStep.newTravelSegment(
        domainId: 't1',
        backEndId: 't1',
        title: 'Voo GRU → SDU',
        startDate: DateTime(2026, 10, 12, 7, 40),
        finishDate: DateTime(2026, 10, 12, 8, 45),
        finished: false,
        startPoint: 'GRU',
        finishPoint: 'SDU',
        transport: Transport.newAirplane(
          domainId: 'tr1',
          backEndId: 'tr1',
          flightNumber: 'LA3421',
          flightCompany: 'LATAM',
          flightDate: DateTime(2026, 10, 12, 7, 40),
          departureGate: '24',
          departureAirport: 'GRU',
          arrivalAirport: 'SDU',
        ),
      )));

      expect(find.text('Travel segment · Airplane'), findsOneWidget);
      expect(find.text('GRU'), findsOneWidget);
      expect(find.text('SDU'), findsOneWidget);
      expect(find.text('LA3421 · LATAM'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.text('GRU → SDU'), findsOneWidget);
    });

    testWidgets('TravelSegment/Bus shows bus line, gate, station and departure time', (tester) async {
      await tester.pumpWidget(_wrap(ItineraryStep.newTravelSegment(
        domainId: 't2',
        backEndId: 't2',
        title: 'Transfer até Paraty',
        startDate: DateTime(2026, 10, 12, 11, 30),
        finishDate: DateTime(2026, 10, 12, 15, 30),
        finished: false,
        startPoint: 'São Paulo',
        finishPoint: 'Paraty',
        transport: Transport.newBus(
          domainId: 'tr2',
          backEndId: 'tr2',
          travelNumber: '512',
          travelCompany: 'Reunidas',
          departureGate: '8',
          departureDateTime: DateTime(2026, 10, 12, 11, 30),
          busStationName: 'Terminal Tietê',
          description: 'Ônibus executivo',
          details: null,
        ),
      )));

      expect(find.text('Travel segment · Bus'), findsOneWidget);
      expect(find.text('512 · Reunidas'), findsOneWidget);
      expect(find.text('Terminal Tietê'), findsOneWidget);
      expect(find.text('12 Oct · 11:30'), findsOneWidget);
    });

    testWidgets('TravelSegment/RentalCar shows model, plate, company and pick-up/drop-off', (tester) async {
      await tester.pumpWidget(_wrap(ItineraryStep.newTravelSegment(
        domainId: 't3',
        backEndId: 't3',
        title: 'Carro alugado',
        startDate: DateTime(2026, 10, 12, 11, 30),
        finishDate: DateTime(2026, 10, 14, 11, 30),
        finished: false,
        startPoint: 'Paraty',
        finishPoint: 'Paraty',
        transport: Transport.newRentalCar(
          domainId: 'tr3',
          backEndId: 'tr3',
          vehicleModelName: 'Fiat Mobi',
          vehicleLicensePlate: 'ABC1D23',
          companyName: 'Localiza',
          checkInDate: DateTime(2026, 10, 12, 11, 30),
          checkOutDate: DateTime(2026, 10, 14, 11, 30),
        ),
      )));

      expect(find.text('Travel segment · Rental car'), findsOneWidget);
      expect(find.text('Fiat Mobi'), findsOneWidget);
      expect(find.text('ABC1D23'), findsOneWidget);
      expect(find.text('Localiza'), findsOneWidget);
    });

    testWidgets('TravelSegment/PlaceholderTransport shows only origin/destination, no transport tiles', (tester) async {
      await tester.pumpWidget(_wrap(ItineraryStep.newTravelSegment(
        domainId: 't4',
        backEndId: 't4',
        title: 'Trecho a definir',
        startDate: DateTime(2026, 10, 12, 11, 30),
        finishDate: DateTime(2026, 10, 12, 12, 30),
        finished: false,
        startPoint: 'A',
        finishPoint: 'B',
        transport: Transport.newPlaceholder(domainId: 'tr4', backEndId: 'tr4', description: 'A definir'),
      )));

      expect(find.text('Travel segment'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });
  });
}
