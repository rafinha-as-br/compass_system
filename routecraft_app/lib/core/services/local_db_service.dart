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
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Routes Table
    await db.execute('''
      CREATE TABLE routes(
        id TEXT PRIMARY KEY,
        clientId TEXT,
        tripName TEXT,
        startDate TEXT,
        endDate TEXT,
        startLocation TEXT,
        destination TEXT,
        interestsList TEXT
      )
    ''');

    // Points of Interest Table
    await db.execute('''
      CREATE TABLE interest_points(
        id TEXT PRIMARY KEY,
        routeId TEXT,
        name TEXT,
        description TEXT,
        geographicLocation TEXT,
        FOREIGN KEY (routeId) REFERENCES routes (id) ON DELETE CASCADE
      )
    ''');
  }

  // Example CRUD for Route
  Future<void> saveRouteLocally(RoutePlan route) async {
    final db = await database;
    
    // Insert Route
    await db.insert(
      'routes',
      {
        'id': route.id,
        'clientId': route.clientId,
        'tripName': route.tripName,
        'startDate': route.startDate.toIso8601String(),
        'endDate': route.endDate.toIso8601String(),
        'startLocation': route.startLocation,
        'destination': route.destination,
        'interestsList': route.interestsList.join(','),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert POIs
    for (var poi in route.pointsOfInterest) {
      await db.insert(
        'interest_points',
        {
          'id': poi.id,
          'routeId': poi.routeId,
          'name': poi.name,
          'description': poi.description,
          'geographicLocation': poi.geographicLocation,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<RoutePlan>> getLocalRoutes() async {
    final db = await database;
    final List<Map<String, dynamic>> routeMaps = await db.query('routes');
    final List<Map<String, dynamic>> poiMaps = await db.query('interest_points');

    List<RoutePlan> routes = [];

    for (var map in routeMaps) {
      final routeId = map['id'] as String;
      
      // Filter POIs
      final localPois = poiMaps.where((p) => p['routeId'] == routeId).map((p) => InterestPoint(
        id: p['id'] as String,
        routeId: p['routeId'] as String,
        name: p['name'] as String,
        description: p['description'] as String,
        geographicLocation: p['geographicLocation'] as String,
      )).toList();

      routes.add(RoutePlan(
        id: routeId,
        clientId: map['clientId'] as String,
        tripName: map['tripName'] as String,
        startDate: DateTime.parse(map['startDate'] as String),
        endDate: DateTime.parse(map['endDate'] as String),
        startLocation: map['startLocation'] as String,
        destination: map['destination'] as String,
        interestsList: (map['interestsList'] as String).split(','),
        pointsOfInterest: localPois,
      ));
    }

    return routes;
  }
}
