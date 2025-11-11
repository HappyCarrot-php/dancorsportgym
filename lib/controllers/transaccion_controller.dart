import 'package:flutter/material.dart';
import '../models/ingreso.dart';
import '../models/gasto.dart';
import '../services/database_service.dart';

/// Controller para gestionar ingresos y gastos
class TransaccionController extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<Ingreso> _ingresos = [];
  List<Gasto> _gastos = [];
  DateTime _fechaSeleccionada = DateTime.now();
  bool _isLoading = false;

  List<Ingreso> get ingresos => _ingresos;
  List<Gasto> get gastos => _gastos;
  DateTime get fechaSeleccionada => _fechaSeleccionada;
  bool get isLoading => _isLoading;

  double get totalIngresos =>
      _ingresos.fold(0.0, (sum, ingreso) => sum + ingreso.monto);

  double get totalGastos => _gastos.fold(0.0, (sum, gasto) => sum + gasto.monto);

  double get resultadoDia => totalIngresos - totalGastos;

  TransaccionController() {
    cargarDatos();
  }

  /// Carga los datos de ingresos y gastos de la fecha seleccionada
  Future<void> cargarDatos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _ingresos = await _db.obtenerIngresosPorFecha(_fechaSeleccionada);
      _gastos = await _db.obtenerGastosPorFecha(_fechaSeleccionada);
    } catch (e) {
      debugPrint('Error al cargar datos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cambia la fecha seleccionada y recarga los datos
  Future<void> cambiarFecha(DateTime nuevaFecha) async {
    _fechaSeleccionada = nuevaFecha;
    await cargarDatos();
  }

  /// Agrega un nuevo ingreso
  Future<bool> agregarIngreso(Ingreso ingreso) async {
    try {
      await _db.insertarIngreso(ingreso);
      await cargarDatos();
      return true;
    } catch (e) {
      debugPrint('Error al agregar ingreso: $e');
      return false;
    }
  }

  /// Agrega un nuevo gasto
  Future<bool> agregarGasto(Gasto gasto) async {
    try {
      await _db.insertarGasto(gasto);
      await cargarDatos();
      return true;
    } catch (e) {
      debugPrint('Error al agregar gasto: $e');
      return false;
    }
  }

  /// Actualiza un ingreso
  Future<bool> actualizarIngreso(Ingreso ingreso) async {
    try {
      await _db.actualizarIngreso(ingreso);
      await cargarDatos();
      return true;
    } catch (e) {
      debugPrint('Error al actualizar ingreso: $e');
      return false;
    }
  }

  /// Actualiza un gasto
  Future<bool> actualizarGasto(Gasto gasto) async {
    try {
      await _db.actualizarGasto(gasto);
      await cargarDatos();
      return true;
    } catch (e) {
      debugPrint('Error al actualizar gasto: $e');
      return false;
    }
  }

  /// Elimina un ingreso
  Future<bool> eliminarIngreso(int id) async {
    try {
      await _db.eliminarIngreso(id);
      await cargarDatos();
      return true;
    } catch (e) {
      debugPrint('Error al eliminar ingreso: $e');
      return false;
    }
  }

  /// Elimina un gasto
  Future<bool> eliminarGasto(int id) async {
    try {
      await _db.eliminarGasto(id);
      await cargarDatos();
      return true;
    } catch (e) {
      debugPrint('Error al eliminar gasto: $e');
      return false;
    }
  }

  /// Finaliza el día creando un cierre diario
  Future<bool> finalizarDia() async {
    try {
      await _db.crearCierreDiario(_fechaSeleccionada);
      return true;
    } catch (e) {
      debugPrint('Error al finalizar día: $e');
      return false;
    }
  }

  /// Obtiene TODOS los ingresos (sin filtro de fecha)
  Future<List<Ingreso>> obtenerTodosLosIngresos() async {
    try {
      return await _db.obtenerIngresos();
    } catch (e) {
      debugPrint('Error al obtener todos los ingresos: $e');
      return [];
    }
  }

  /// Obtiene TODOS los gastos (sin filtro de fecha)
  Future<List<Gasto>> obtenerTodosLosGastos() async {
    try {
      return await _db.obtenerGastos();
    } catch (e) {
      debugPrint('Error al obtener todos los gastos: $e');
      return [];
    }
  }
}
