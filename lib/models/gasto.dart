/// Modelo de datos para un gasto del gimnasio
class Gasto {
  final int? id;
  final String concepto;
  final double monto;
  final DateTime fecha;

  Gasto({
    this.id,
    required this.concepto,
    required this.monto,
    required this.fecha,
  });

  /// Convierte el modelo a un mapa para Supabase
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'concepto': concepto,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
    };
    // Solo incluir id si existe (para updates)
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Crea una instancia desde un mapa de SQLite
  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'] as int?,
      concepto: map['concepto'] as String,
      monto: (map['monto'] as num).toDouble(),
      fecha: DateTime.parse(map['fecha'] as String),
    );
  }

  /// Crea una copia del gasto con campos modificados
  Gasto copyWith({
    int? id,
    String? concepto,
    double? monto,
    DateTime? fecha,
  }) {
    return Gasto(
      id: id ?? this.id,
      concepto: concepto ?? this.concepto,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
    );
  }
}
