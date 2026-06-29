import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:mock_repository/mock_repository.dart';

class LocalDbService {
  static LocalDbService? _instance;
  static Database? _database;

  LocalDbService._();

  static Future<LocalDbService> init() async {
    if (_instance == null) {
      _instance = LocalDbService._();
      await _instance!._initDb();
    }
    return _instance!;
  }

  static LocalDbService get instance {
    assert(_instance != null, 'LocalDbService instance not initialized!');
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'route_craft_local.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Routes Table (simplified — now part of Travel)
    await db.execute('''
      CREATE TABLE routes(
        id TEXT PRIMARY KEY,
        startDate TEXT,
        endDate TEXT,
        startLocation TEXT,
        destination TEXT
      )
    ''');

    // Interest Points Table
    await db.execute('''
      CREATE TABLE interest_points(
        id TEXT PRIMARY KEY,
        routeId TEXT,
        name TEXT,
        description TEXT,
        FOREIGN KEY (routeId) REFERENCES routes (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Saves a RoutePlan locally with a generated routeId for local tracking.
  Future<void> saveRouteLocally(String routeId, RoutePlan route) async {
    final db = await database;

    await db.insert(
      'routes',
      {
        'id': routeId,
        'startDate': route.startDate.toIso8601String(),
        'endDate': route.endDate.toIso8601String(),
        'startLocation': route.startLocation,
        'destination': route.destination,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert interest points
    for (var poi in route.interestsList) {
      await db.insert(
        'interest_points',
        {
          'id': poi.id,
          'routeId': routeId,
          'name': poi.name,
          'description': poi.description,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<RoutePlan>> getLocalRoutes() async {
    final db = await database;
    final List<Map<String, dynamic>> routeMaps = await db.query('routes');
    final List<Map<String, dynamic>> poiMaps =
        await db.query('interest_points');

    List<RoutePlan> routes = [];

    for (var map in routeMaps) {
      final routeId = map['id'] as String;

      final localPois = poiMaps
          .where((p) => p['routeId'] == routeId)
          .map((p) => InterestPoint(
                id: p['id'] as String,
                name: p['name'] as String,
                description: p['description'] as String,
              ))
          .toList();

      routes.add(RoutePlan(
        startDate: DateTime.parse(map['startDate'] as String),
        endDate: DateTime.parse(map['endDate'] as String),
        startLocation: map['startLocation'] as String,
        destination: map['destination'] as String,
        interestsList: localPois,
      ));
    }

    return routes;
  }
}
