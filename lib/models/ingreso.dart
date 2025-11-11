/// Modelo de datos para un ingreso del gimnasio
class Ingreso {
  final int? id;
  final String concepto;
  final double monto;
  final DateTime fecha;
  final String? nombre; // Requerido para suscripciones
  final String tipo; // 'producto', 'visita', 'semana', 'quincena', 'mensualidad'
  final DateTime? fechaInicio; // Fecha de inicio de suscripción
  final DateTime? fechaVencimiento; // Fecha de vencimiento de suscripción
  final bool incluyeInscripcion; // Si incluye inscripción ($150)
  final String? telefono; // Teléfono del cliente
  final String? notas; // Notas adicionales

  Ingreso({
    this.id,
    required this.concepto,
    required this.monto,
    required this.fecha,
    this.nombre,
    required this.tipo,
    this.fechaInicio,
    this.fechaVencimiento,
    this.incluyeInscripcion = false,
    this.telefono,
    this.notas,
  });

  /// Convierte el modelo a un mapa para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'concepto': concepto,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
      'nombre': nombre,
      'tipo': tipo,
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_vencimiento': fechaVencimiento?.toIso8601String(),
      'incluye_inscripcion': incluyeInscripcion ? 1 : 0,
      'telefono': telefono,
      'notas': notas,
    };
  }

  /// Crea una instancia desde un mapa de SQLite
  factory Ingreso.fromMap(Map<String, dynamic> map) {
    return Ingreso(
      id: map['id'] as int?,
      concepto: map['concepto'] as String,
      monto: (map['monto'] as num).toDouble(),
      fecha: DateTime.parse(map['fecha'] as String),
      nombre: map['nombre'] as String?,
      tipo: map['tipo'] as String,
      fechaInicio: map['fecha_inicio'] != null 
          ? DateTime.parse(map['fecha_inicio'] as String) 
          : null,
      fechaVencimiento: map['fecha_vencimiento'] != null 
          ? DateTime.parse(map['fecha_vencimiento'] as String) 
          : null,
      incluyeInscripcion: map['incluye_inscripcion'] == 1,
      telefono: map['telefono'] as String?,
      notas: map['notas'] as String?,
    );
  }

  /// Crea una copia del ingreso con campos modificados
  Ingreso copyWith({
    int? id,
    String? concepto,
    double? monto,
    DateTime? fecha,
    String? nombre,
    String? tipo,
    DateTime? fechaInicio,
    DateTime? fechaVencimiento,
    bool? incluyeInscripcion,
    String? telefono,
    String? notas,
  }) {
    return Ingreso(
      id: id ?? this.id,
      concepto: concepto ?? this.concepto,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      incluyeInscripcion: incluyeInscripcion ?? this.incluyeInscripcion,
      telefono: telefono ?? this.telefono,
      notas: notas ?? this.notas,
    );
  }
}
