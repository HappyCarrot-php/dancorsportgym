import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ingreso.dart';
import '../models/gasto.dart';
import '../models/cierre_dia.dart';

/// Servicio para gestionar la base de datos en Supabase
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  /// Obtiene el cliente de Supabase
  SupabaseClient get _client => Supabase.instance.client;

  // ============ INGRESOS ============

  /// Inserta un nuevo ingreso
  Future<int> insertarIngreso(Ingreso ingreso) async {
    try {
      final map = ingreso.toMap();
      print('Insertando ingreso: $map');
      final data = await _client
          .from('ingresos')
          .insert(map)
          .select('id')
          .single();
      print('Ingreso insertado con id: ${data['id']}');
      return data['id'] as int;
    } catch (e) {
      print('ERROR al insertar ingreso: $e');
      rethrow;
    }
  }

  /// Obtiene todos los ingresos
  Future<List<Ingreso>> obtenerIngresos() async {
    try {
      final response = await _client
          .from('ingresos')
          .select()
          .order('fecha', ascending: false);
      print('Ingresos obtenidos: ${response.length} registros');
      return (response as List).map((e) => Ingreso.fromMap(e)).toList();
    } catch (e) {
      print('ERROR al obtener ingresos: $e');
      rethrow;
    }
  }

  /// Obtiene ingresos de una fecha específica
  Future<List<Ingreso>> obtenerIngresosPorFecha(DateTime fecha) async {
    final fechaStr = fecha.toIso8601String().split('T')[0];
    final response = await _client
        .from('ingresos')
        .select()
        .gte('fecha', '$fechaStr 00:00:00')
        .lte('fecha', '$fechaStr 23:59:59')
        .order('fecha', ascending: false);
    return (response as List).map((e) => Ingreso.fromMap(e)).toList();
  }

  /// Actualiza un ingreso existente
  Future<int> actualizarIngreso(Ingreso ingreso) async {
    await _client
        .from('ingresos')
        .update(ingreso.toMap())
        .eq('id', ingreso.id!);
    return 1;
  }

  /// Elimina un ingreso
  Future<int> eliminarIngreso(int id) async {
    await _client
        .from('ingresos')
        .delete()
        .eq('id', id);
    return 1;
  }

  /// Calcula el total de ingresos de una fecha
  Future<double> calcularTotalIngresos(DateTime fecha) async {
    final ingresos = await obtenerIngresosPorFecha(fecha);
    return ingresos.fold<double>(0.0, (sum, ingreso) => sum + ingreso.monto);
  }

  // ============ GASTOS ============

  /// Inserta un nuevo gasto
  Future<int> insertarGasto(Gasto gasto) async {
    try {
      final map = gasto.toMap();
      print('Insertando gasto: $map');
      final data = await _client
          .from('gastos')
          .insert(map)
          .select('id')
          .single();
      print('Gasto insertado con id: ${data['id']}');
      return data['id'] as int;
    } catch (e) {
      print('ERROR al insertar gasto: $e');
      rethrow;
    }
  }

  /// Obtiene todos los gastos
  Future<List<Gasto>> obtenerGastos() async {
    final response = await _client
        .from('gastos')
        .select()
        .order('fecha', ascending: false);
    return (response as List).map((e) => Gasto.fromMap(e)).toList();
  }

  /// Obtiene gastos de una fecha específica
  Future<List<Gasto>> obtenerGastosPorFecha(DateTime fecha) async {
    final fechaStr = fecha.toIso8601String().split('T')[0];
    final response = await _client
        .from('gastos')
        .select()
        .gte('fecha', '$fechaStr 00:00:00')
        .lte('fecha', '$fechaStr 23:59:59')
        .order('fecha', ascending: false);
    return (response as List).map((e) => Gasto.fromMap(e)).toList();
  }

  /// Actualiza un gasto existente
  Future<int> actualizarGasto(Gasto gasto) async {
    await _client
        .from('gastos')
        .update(gasto.toMap())
        .eq('id', gasto.id!);
    return 1;
  }

  /// Elimina un gasto
  Future<int> eliminarGasto(int id) async {
    await _client
        .from('gastos')
        .delete()
        .eq('id', id);
    return 1;
  }

  /// Calcula el total de gastos de una fecha
  Future<double> calcularTotalGastos(DateTime fecha) async {
    final gastos = await obtenerGastosPorFecha(fecha);
    return gastos.fold<double>(0.0, (sum, gasto) => sum + gasto.monto);
  }

  // ============ CIERRES DIARIOS ============

  /// Inserta o actualiza un cierre diario
  Future<int> guardarCierreDiario(CierreDia cierre) async {
    try {
      final fechaStr = cierre.fecha.toIso8601String().split('T')[0];
      print('Guardando cierre para fecha: $fechaStr');

      // Verificar si ya existe un cierre para esta fecha
      final existing = await _client
          .from('cierres_diarios')
          .select('id')
          .gte('fecha', '$fechaStr 00:00:00')
          .lte('fecha', '$fechaStr 23:59:59')
          .maybeSingle();

      if (existing != null) {
        print('Cierre ya existe, actualizando id: ${existing['id']}');
        // Actualizar cierre existente
        await _client
            .from('cierres_diarios')
            .update(cierre.toMap())
            .eq('id', existing['id']);
        return existing['id'] as int;
      } else {
        print('Creando nuevo cierre');
        // Insertar nuevo cierre
        final map = cierre.toMap();
        print('Map a insertar: $map');
        final data = await _client
            .from('cierres_diarios')
            .insert(map)
            .select('id')
            .single();
        print('Cierre insertado con id: ${data['id']}');
        return data['id'] as int;
      }
    } catch (e) {
      print('ERROR al guardar cierre: $e');
      rethrow;
    }
  }

  /// Obtiene todos los cierres diarios
  Future<List<CierreDia>> obtenerCierresDiarios() async {
    try {
      final response = await _client
          .from('cierres_diarios')
          .select()
          .order('fecha', ascending: false);
      print('Cierres obtenidos: ${response.length} registros');
      return (response as List).map((e) => CierreDia.fromMap(e)).toList();
    } catch (e) {
      print('ERROR al obtener cierres: $e');
      rethrow;
    }
  }

  /// Obtiene el cierre de una fecha específica
  Future<CierreDia?> obtenerCierrePorFecha(DateTime fecha) async {
    final fechaStr = fecha.toIso8601String().split('T')[0];
    final response = await _client
        .from('cierres_diarios')
        .select()
        .gte('fecha', '$fechaStr 00:00:00')
        .lte('fecha', '$fechaStr 23:59:59')
        .maybeSingle();

    if (response == null) return null;
    return CierreDia.fromMap(response);
  }

  /// Crea automáticamente el cierre del día con los datos actuales
  Future<CierreDia> crearCierreDiario(DateTime fecha) async {
    try {
      final ingresosTotales = await calcularTotalIngresos(fecha);
      final gastosTotales = await calcularTotalGastos(fecha);
      final resultadoFinal = ingresosTotales - gastosTotales;

      print('Creando cierre: ingresos=$ingresosTotales, gastos=$gastosTotales, resultado=$resultadoFinal');

      final cierre = CierreDia(
        fecha: fecha,
        ingresosTotales: ingresosTotales,
        gastosTotales: gastosTotales,
        resultadoFinal: resultadoFinal,
      );

      final id = await guardarCierreDiario(cierre);
      print('Cierre guardado con id: $id');
      return cierre.copyWith(id: id);
    } catch (e) {
      print('ERROR al crear cierre: $e');
      rethrow;
    }
  }

  /// Actualiza un cierre existente
  Future<void> actualizarCierreDiario(CierreDia cierre) async {
    await _client
        .from('cierres_diarios')
        .update(cierre.toMap())
        .eq('id', cierre.id!);
  }

  /// Elimina un cierre diario
  Future<void> eliminarCierreDiario(int id) async {
    await _client
        .from('cierres_diarios')
        .delete()
        .eq('id', id);
  }
}
