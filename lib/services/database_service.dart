import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/ingreso.dart';
import '../models/gasto.dart';
import '../models/cierre_dia.dart';

/// Servicio para gestionar la base de datos SQLite local
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  /// Obtiene la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'dancor_sport_gym.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crea las tablas de la base de datos
  Future<void> _onCreate(Database db, int version) async {
    // Tabla de ingresos
    await db.execute('''
      CREATE TABLE ingresos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        concepto TEXT NOT NULL,
        monto REAL NOT NULL,
        fecha TEXT NOT NULL,
        nombre TEXT,
        tipo TEXT NOT NULL,
        fecha_inicio TEXT,
        fecha_vencimiento TEXT,
        incluye_inscripcion INTEGER DEFAULT 0,
        telefono TEXT,
        notas TEXT
      )
    ''');

    // Tabla de gastos
    await db.execute('''
      CREATE TABLE gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        concepto TEXT NOT NULL,
        monto REAL NOT NULL,
        fecha TEXT NOT NULL
      )
    ''');

    // Tabla de cierres diarios
    await db.execute('''
      CREATE TABLE cierres_diarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL UNIQUE,
        ingresos_totales REAL NOT NULL,
        gastos_totales REAL NOT NULL,
        resultado_final REAL NOT NULL
      )
    ''');
  }

  /// Actualiza la base de datos a versiones nuevas
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar nuevos campos a la tabla ingresos
      await db.execute('ALTER TABLE ingresos ADD COLUMN fecha_inicio TEXT');
      await db.execute('ALTER TABLE ingresos ADD COLUMN fecha_vencimiento TEXT');
      await db.execute('ALTER TABLE ingresos ADD COLUMN incluye_inscripcion INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE ingresos ADD COLUMN telefono TEXT');
      await db.execute('ALTER TABLE ingresos ADD COLUMN notas TEXT');
    }
  }

  // ============ INGRESOS ============

  /// Inserta un nuevo ingreso
  Future<int> insertarIngreso(Ingreso ingreso) async {
    final db = await database;
    return await db.insert('ingresos', ingreso.toMap());
  }

  /// Obtiene todos los ingresos
  Future<List<Ingreso>> obtenerIngresos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ingresos',
      orderBy: 'fecha DESC',
    );
    return List.generate(maps.length, (i) => Ingreso.fromMap(maps[i]));
  }

  /// Obtiene ingresos de una fecha específica
  Future<List<Ingreso>> obtenerIngresosPorFecha(DateTime fecha) async {
    final db = await database;
    final fechaStr = fecha.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'ingresos',
      where: 'date(fecha) = ?',
      whereArgs: [fechaStr],
      orderBy: 'fecha DESC',
    );
    return List.generate(maps.length, (i) => Ingreso.fromMap(maps[i]));
  }

  /// Actualiza un ingreso existente
  Future<int> actualizarIngreso(Ingreso ingreso) async {
    final db = await database;
    return await db.update(
      'ingresos',
      ingreso.toMap(),
      where: 'id = ?',
      whereArgs: [ingreso.id],
    );
  }

  /// Elimina un ingreso
  Future<int> eliminarIngreso(int id) async {
    final db = await database;
    return await db.delete(
      'ingresos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Calcula el total de ingresos de una fecha
  Future<double> calcularTotalIngresos(DateTime fecha) async {
    final ingresos = await obtenerIngresosPorFecha(fecha);
    return ingresos.fold<double>(0.0, (sum, ingreso) => sum + ingreso.monto);
  }

  // ============ GASTOS ============

  /// Inserta un nuevo gasto
  Future<int> insertarGasto(Gasto gasto) async {
    final db = await database;
    return await db.insert('gastos', gasto.toMap());
  }

  /// Obtiene todos los gastos
  Future<List<Gasto>> obtenerGastos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gastos',
      orderBy: 'fecha DESC',
    );
    return List.generate(maps.length, (i) => Gasto.fromMap(maps[i]));
  }

  /// Obtiene gastos de una fecha específica
  Future<List<Gasto>> obtenerGastosPorFecha(DateTime fecha) async {
    final db = await database;
    final fechaStr = fecha.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'gastos',
      where: 'date(fecha) = ?',
      whereArgs: [fechaStr],
      orderBy: 'fecha DESC',
    );
    return List.generate(maps.length, (i) => Gasto.fromMap(maps[i]));
  }

  /// Actualiza un gasto existente
  Future<int> actualizarGasto(Gasto gasto) async {
    final db = await database;
    return await db.update(
      'gastos',
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  /// Elimina un gasto
  Future<int> eliminarGasto(int id) async {
    final db = await database;
    return await db.delete(
      'gastos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Calcula el total de gastos de una fecha
  Future<double> calcularTotalGastos(DateTime fecha) async {
    final gastos = await obtenerGastosPorFecha(fecha);
    return gastos.fold<double>(0.0, (sum, gasto) => sum + gasto.monto);
  }

  // ============ CIERRES DIARIOS ============

  /// Inserta o actualiza un cierre diario
  Future<int> guardarCierreDiario(CierreDia cierre) async {
    final db = await database;
    final fechaStr = cierre.fecha.toIso8601String().split('T')[0];

    // Verificar si ya existe un cierre para esta fecha
    final List<Map<String, dynamic>> existing = await db.query(
      'cierres_diarios',
      where: 'date(fecha) = ?',
      whereArgs: [fechaStr],
    );

    if (existing.isNotEmpty) {
      // Actualizar cierre existente
      return await db.update(
        'cierres_diarios',
        cierre.toMap(),
        where: 'date(fecha) = ?',
        whereArgs: [fechaStr],
      );
    } else {
      // Insertar nuevo cierre
      return await db.insert('cierres_diarios', cierre.toMap());
    }
  }

  /// Obtiene todos los cierres diarios
  Future<List<CierreDia>> obtenerCierresDiarios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cierres_diarios',
      orderBy: 'fecha DESC',
    );
    return List.generate(maps.length, (i) => CierreDia.fromMap(maps[i]));
  }

  /// Obtiene el cierre de una fecha específica
  Future<CierreDia?> obtenerCierrePorFecha(DateTime fecha) async {
    final db = await database;
    final fechaStr = fecha.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'cierres_diarios',
      where: 'date(fecha) = ?',
      whereArgs: [fechaStr],
    );

    if (maps.isEmpty) return null;
    return CierreDia.fromMap(maps.first);
  }

  /// Crea automáticamente el cierre del día con los datos actuales
  Future<CierreDia> crearCierreDiario(DateTime fecha) async {
    final ingresosTotales = await calcularTotalIngresos(fecha);
    final gastosTotales = await calcularTotalGastos(fecha);
    final resultadoFinal = ingresosTotales - gastosTotales;

    final cierre = CierreDia(
      fecha: fecha,
      ingresosTotales: ingresosTotales,
      gastosTotales: gastosTotales,
      resultadoFinal: resultadoFinal,
    );

    await guardarCierreDiario(cierre);
    return cierre;
  }

  /// Actualiza un cierre existente
  Future<void> actualizarCierreDiario(CierreDia cierre) async {
    final db = await database;
    await db.update(
      'cierres_diarios',
      cierre.toMap(),
      where: 'id = ?',
      whereArgs: [cierre.id],
    );
  }

  /// Elimina un cierre diario
  Future<void> eliminarCierreDiario(int id) async {
    final db = await database;
    await db.delete(
      'cierres_diarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Cierra la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
