/// Modelo de datos para el cierre diario del gimnasio
class CierreDia {
  final int? id;
  final DateTime fecha;
  final double ingresosTotales;
  final double gastosTotales;
  final double resultadoFinal;

  CierreDia({
    this.id,
    required this.fecha,
    required this.ingresosTotales,
    required this.gastosTotales,
    required this.resultadoFinal,
  });

  /// Convierte el modelo a un mapa para Supabase
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'fecha': fecha.toIso8601String(),
      'ingresos_totales': ingresosTotales,
      'gastos_totales': gastosTotales,
      'resultado_final': resultadoFinal,
    };
    // Solo incluir id si existe (para updates)
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Crea una instancia desde un mapa de SQLite
  factory CierreDia.fromMap(Map<String, dynamic> map) {
    return CierreDia(
      id: map['id'] as int?,
      fecha: DateTime.parse(map['fecha'] as String),
      ingresosTotales: (map['ingresos_totales'] as num).toDouble(),
      gastosTotales: (map['gastos_totales'] as num).toDouble(),
      resultadoFinal: (map['resultado_final'] as num).toDouble(),
    );
  }

  /// Crea una copia del cierre con campos modificados
  CierreDia copyWith({
    int? id,
    DateTime? fecha,
    double? ingresosTotales,
    double? gastosTotales,
    double? resultadoFinal,
  }) {
    return CierreDia(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      ingresosTotales: ingresosTotales ?? this.ingresosTotales,
      gastosTotales: gastosTotales ?? this.gastosTotales,
      resultadoFinal: resultadoFinal ?? this.resultadoFinal,
    );
  }
}
