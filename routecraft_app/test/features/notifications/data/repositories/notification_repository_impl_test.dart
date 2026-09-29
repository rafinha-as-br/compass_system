import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/clients/notification_api_client.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/features/notifications/data/datasources/notification_data_source.dart';
import 'package:routecraft_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';

Map<String, dynamic> _notificationJson({String id = 'n1', String type = 'ITINERARY_PUBLISHED', bool read = false}) => {
      'id': id,
      'travelId': 't1',
      'type': type,
      'createdAt': '2026-09-01T10:00:00Z',
      'read': read,
    };

NotificationRepositoryImpl _repositoryWith(MockClient mockClient) {
  final httpClient = HttpApiClient.forTesting(mockClient);
  final dataSource = NotificationDataSource(
    client: NotificationApiClient(httpClient),
    getToken: () async => 'test-token',
  );
  return NotificationRepositoryImpl(dataSource: dataSource);
}

void main() {
  group('NotificationRepositoryImpl.getNotifications', () {
    test('returns Success with the mapped notifications and hasMore=true when not the last page', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(
          jsonEncode({
            'content': [_notificationJson(id: 'n1'), _notificationJson(id: 'n2', type: 'ITINERARY_STEP_CHANGED')],
            'last': false,
          }),
          200,
        );
      }));

      final result = await repository.getNotifications(page: 0, size: 20);

      expect(result.isSuccess, isTrue);
      final (items, hasMore) = (result as Success<(List<TravelNotification>, bool)>).data;
      expect(items, hasLength(2));
      expect(items[0].type, TravelNotificationType.itineraryPublished);
      expect(items[1].type, TravelNotificationType.itineraryChanged);
      expect(hasMore, isTrue);
    });

    test('returns hasMore=false on the last page', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode({'content': <Map<String, dynamic>>[], 'last': true}), 200);
      }));

      final result = await repository.getNotifications(page: 1, size: 20);

      final (items, hasMore) = (result as Success<(List<TravelNotification>, bool)>).data;
      expect(items, isEmpty);
      expect(hasMore, isFalse);
    });

    test('falls back to unknown for an unrecognized type instead of crashing', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(
          jsonEncode({
            'content': [_notificationJson(type: 'SOMETHING_NEW')],
            'last': true,
          }),
          200,
        );
      }));

      final result = await repository.getNotifications(page: 0, size: 20);

      final (items, _) = (result as Success<(List<TravelNotification>, bool)>).data;
      expect(items.single.type, TravelNotificationType.unknown);
    });

    test('returns a connectivity Failure on a network error', () async {
      final repository = _repositoryWith(MockClient((request) async {
        throw http.ClientException('connection refused');
      }));

      final result = await repository.getNotifications(page: 0, size: 20);

      expect(result.isSuccess, isFalse);
      expect((result as Failure<(List<TravelNotification>, bool)>).isConnectivityError, isTrue);
    });
  });

  group('NotificationRepositoryImpl.getUnreadCount', () {
    test('returns Success with the count on a 200 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode({'count': 3}), 200);
      }));

      final result = await repository.getUnreadCount();

      expect((result as Success<int>).data, 3);
    });

    test('returns a connectivity Failure on a network error', () async {
      final repository = _repositoryWith(MockClient((request) async {
        throw http.ClientException('connection refused');
      }));

      final result = await repository.getUnreadCount();

      expect(result.isSuccess, isFalse);
    });
  });

  group('NotificationRepositoryImpl.markAllAsRead', () {
    test('returns Success on a 204 response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response('', 204);
      }));

      final result = await repository.markAllAsRead();

      expect(result.isSuccess, isTrue);
    });

    test('returns Failure with the server message on an error response', () async {
      final repository = _repositoryWith(MockClient((request) async {
        return http.Response(jsonEncode({'message': 'Não autorizado'}), 401);
      }));

      final result = await repository.markAllAsRead();

      expect(result.isSuccess, isFalse);
      expect((result as Failure<void>).message, 'Não autorizado');
    });
  });
}
