import 'package:intl/intl.dart';

/// Clase con constantes y utilidades generales de la aplicación
class AppConstants {
  // Colores
  static const int colorPrimario = 0xFF1976D2; // Azul
  static const int colorSecundario = 0xFF00897B; // Verde azulado
  static const int colorIngreso = 0xFF4CAF50; // Verde
  static const int colorGasto = 0xFFE53935; // Rojo
  static const int colorFondo = 0xFFF5F5F5; // Gris claro

  // Tipos de ingreso y sus montos predeterminados
  static const String tipoProducto = 'producto';
  static const String tipoVisita = 'visita';
  static const String tipoSemana = 'semana';
  static const String tipoQuincena = 'quincena';
  static const String tipoMensualidad = 'mensualidad';

  static const double montoVisita = 40.0;
  static const double montoSemana = 180.0;
  static const double montoQuincena = 260.0;
  static const double montoMensualidad = 400.0;
  static const double montoInscripcion = 150.0;

  // Textos
  static const String nombreApp = 'Gestor de Caja';
  static const String subtituloApp = 'Dancor Sport Gym';

  // Formatos
  static final formatoMoneda = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
    locale: 'es_MX',
  );

  static final formatoFechaCorta = DateFormat('dd/MM/yyyy', 'es');
  static final formatoFechaLarga = DateFormat('EEEE, dd MMMM yyyy', 'es');
  static final formatoHora = DateFormat('HH:mm', 'es');

  /// Formatea un monto como moneda
  static String formatearMoneda(double monto) {
    return formatoMoneda.format(monto);
  }

  /// Formatea una fecha en formato corto
  static String formatearFechaCorta(DateTime fecha) {
    return formatoFechaCorta.format(fecha);
  }

  /// Formatea una fecha en formato largo
  static String formatearFechaLarga(DateTime fecha) {
    return formatoFechaLarga.format(fecha);
  }

  /// Formatea una hora
  static String formatearHora(DateTime fecha) {
    return formatoHora.format(fecha);
  }

  /// Obtiene el nombre del tipo de ingreso
  static String obtenerNombreTipoIngreso(String tipo) {
    switch (tipo) {
      case tipoProducto:
        return 'Producto';
      case tipoVisita:
        return 'Visita';
      case tipoSemana:
        return 'Semana';
      case tipoQuincena:
        return 'Quincena';
      case tipoMensualidad:
        return 'Mensualidad';
      default:
        return tipo;
    }
  }

  /// Verifica si una fecha es hoy
  static bool esHoy(DateTime fecha) {
    final hoy = DateTime.now();
    return fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day;
  }

  /// Normaliza una fecha a medianoche
  static DateTime normalizarFecha(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }
}
