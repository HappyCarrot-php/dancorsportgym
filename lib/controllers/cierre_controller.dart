import 'package:flutter/material.dart';
import '../models/cierre_dia.dart';
import '../services/database_service.dart';

/// Controller para gestionar los cierres diarios
class CierreController extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<CierreDia> _cierres = [];
  bool _isLoading = false;

  List<CierreDia> get cierres => _cierres;
  bool get isLoading => _isLoading;

  CierreController() {
    cargarCierres();
  }

  /// Carga todos los cierres diarios
  Future<void> cargarCierres() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cierres = await _db.obtenerCierresDiarios();
    } catch (e) {
      debugPrint('Error al cargar cierres: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene el cierre de una fecha específica
  Future<CierreDia?> obtenerCierrePorFecha(DateTime fecha) async {
    try {
      return await _db.obtenerCierrePorFecha(fecha);
    } catch (e) {
      debugPrint('Error al obtener cierre: $e');
      return null;
    }
  }

  /// Crea un cierre diario
  Future<bool> crearCierre(DateTime fecha) async {
    try {
      await _db.crearCierreDiario(fecha);
      await cargarCierres();
      return true;
    } catch (e) {
      debugPrint('Error al crear cierre: $e');
      return false;
    }
  }

  /// Actualiza un cierre existente
  Future<bool> actualizarCierre(CierreDia cierre) async {
    try {
      await _db.actualizarCierreDiario(cierre);
      await cargarCierres();
      return true;
    } catch (e) {
      debugPrint('Error al actualizar cierre: $e');
      return false;
    }
  }

  /// Elimina un cierre
  Future<bool> eliminarCierre(int id) async {
    try {
      await _db.eliminarCierreDiario(id);
      await cargarCierres();
      return true;
    } catch (e) {
      debugPrint('Error al eliminar cierre: $e');
      return false;
    }
  }
}
