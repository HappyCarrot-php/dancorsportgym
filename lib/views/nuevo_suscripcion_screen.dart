import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/ingreso.dart';
import '../controllers/transaccion_controller.dart';
import '../widgets/boton_primario.dart';

/// Pantalla para registrar suscripciones (Semana, Quincena, Mensualidad)
class NuevoSuscripcionScreen extends StatefulWidget {
  const NuevoSuscripcionScreen({Key? key}) : super(key: key);

  @override
  State<NuevoSuscripcionScreen> createState() => _NuevoSuscripcionScreenState();
}

class _NuevoSuscripcionScreenState extends State<NuevoSuscripcionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _notasController = TextEditingController();
  
  String _tipoSeleccionado = 'semana';
  bool _incluyeInscripcion = false;
  DateTime _fechaPago = DateTime.now(); // Fecha de pago seleccionada
  bool _usarFechaHoy = true; // Opción para usar fecha de hoy

  // Precios de suscripciones
  static const Map<String, double> PRECIOS = {
    'semana': 180.0,
    'quincena': 260.0,
    'mensualidad': 400.0,
  };

  static const Map<String, int> DURACION_DIAS = {
    'semana': 7,
    'quincena': 15,
    'mensualidad': 30,
  };

  static const double PRECIO_INSCRIPCION = 150.0;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  double get _montoTotal {
    double monto = PRECIOS[_tipoSeleccionado] ?? 0;
    if (_incluyeInscripcion) {
      monto += PRECIO_INSCRIPCION;
    }
    return monto;
  }

  String get _duracionTexto {
    final dias = DURACION_DIAS[_tipoSeleccionado] ?? 0;
    return '$dias días';
  }

  Future<void> _guardarSuscripcion() async {
    if (_formKey.currentState!.validate()) {
      try {
        final fechaInicio = _fechaPago;
        // Calcular vencimiento basado en el día del mes
        final fechaVencimiento = _calcularFechaVencimiento(fechaInicio, _tipoSeleccionado);

        String concepto = 'Suscripción ${_tipoSeleccionado.capitalize()}';
        if (_incluyeInscripcion) {
          concepto += ' + Inscripción';
        }

        final ingreso = Ingreso(
          concepto: concepto,
          monto: _montoTotal,
          fecha: fechaInicio,
          nombre: _nombreController.text.trim(),
          tipo: _tipoSeleccionado,
          fechaInicio: fechaInicio,
          fechaVencimiento: fechaVencimiento,
          incluyeInscripcion: _incluyeInscripcion,
          telefono: _telefonoController.text.trim(),
          notas: _notasController.text.trim(),
        );

        await Provider.of<TransaccionController>(context, listen: false)
            .agregarIngreso(ingreso);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Suscripción registrada\nVence: ${_formatearFecha(fechaVencimiento)}',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  /// Calcula la fecha de vencimiento basada en el día del mes
  /// Ej: Si paga el 1 de agosto, vence el 1 de septiembre
  DateTime _calcularFechaVencimiento(DateTime fechaInicio, String tipo) {
    final int dias;
    
    switch (tipo) {
      case 'semana':
        dias = 7;
        break;
      case 'quincena':
        dias = 15;
        break;
      case 'mensualidad':
        // Para mensualidad, calcular basándose en el mismo día del siguiente mes
        final mes = fechaInicio.month + 1;
        final anio = mes > 12 ? fechaInicio.year + 1 : fechaInicio.year;
        final mesAjustado = mes > 12 ? 1 : mes;
        
        // Manejar casos donde el día no existe en el mes siguiente (ej: 31 de enero -> 28/29 de febrero)
        final diasEnMes = DateTime(anio, mesAjustado + 1, 0).day;
        final dia = fechaInicio.day > diasEnMes ? diasEnMes : fechaInicio.day;
        
        return DateTime(anio, mesAjustado, dia);
      default:
        dias = 7;
    }
    
    // Para semana y quincena, simplemente agregar los días
    return fechaInicio.add(Duration(days: dias));
  }

  Future<void> _seleccionarFechaPago() async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaPago,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      helpText: 'Seleccionar fecha de pago',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaPago = fechaSeleccionada;
        _usarFechaHoy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Suscripción'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.card_membership,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              const Text(
                'Registrar Suscripción',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Nombre del cliente
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Cliente *',
                  hintText: 'Ej: Juan Pérez',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Teléfono (opcional)
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (Opcional)',
                  hintText: 'Ej: 6441234567',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              const SizedBox(height: 20),

              // Fecha de pago
              Card(
                elevation: 2,
                child: InkWell(
                  onTap: _seleccionarFechaPago,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.blue),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fecha de Pago',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _usarFechaHoy 
                                    ? 'Hoy - ${_formatearFecha(_fechaPago)}' 
                                    : _formatearFecha(_fechaPago),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!_usarFechaHoy)
                          IconButton(
                            icon: const Icon(Icons.today, color: Colors.orange),
                            tooltip: 'Usar fecha de hoy',
                            onPressed: () {
                              setState(() {
                                _fechaPago = DateTime.now();
                                _usarFechaHoy = true;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tipo de suscripción
              const Text(
                'Tipo de Suscripción *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildOpcionSuscripcion(
                      'semana',
                      'Semana',
                      PRECIOS['semana']!,
                      '7 días',
                    ),
                    const Divider(height: 1),
                    _buildOpcionSuscripcion(
                      'quincena',
                      'Quincena',
                      PRECIOS['quincena']!,
                      '15 días',
                    ),
                    const Divider(height: 1),
                    _buildOpcionSuscripcion(
                      'mensualidad',
                      'Mensualidad',
                      PRECIOS['mensualidad']!,
                      '30 días',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Incluye inscripción
              Card(
                color: _incluyeInscripcion 
                    ? Colors.orange.withOpacity(0.1) 
                    : null,
                child: CheckboxListTile(
                  title: const Text(
                    'Incluir Inscripción',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('\$150.00 adicionales'),
                  secondary: const Icon(Icons.add_card),
                  value: _incluyeInscripcion,
                  onChanged: (value) {
                    setState(() {
                      _incluyeInscripcion = value ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Notas
              TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(
                  labelText: 'Notas (Opcional)',
                  hintText: 'Información adicional',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 30),

              // Resumen
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Duración:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          _duracionTexto,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total a pagar:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${_montoTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Botón Guardar
              BotonPrimario(
                texto: 'Registrar Suscripción',
                icono: Icons.save,
                onPressed: _guardarSuscripcion,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpcionSuscripcion(
    String valor,
    String titulo,
    double precio,
    String duracion,
  ) {
    final seleccionado = _tipoSeleccionado == valor;
    return InkWell(
      onTap: () {
        setState(() {
          _tipoSeleccionado = valor;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: seleccionado ? Colors.orange.withOpacity(0.1) : null,
        child: Row(
          children: [
            Radio<String>(
              value: valor,
              groupValue: _tipoSeleccionado,
              onChanged: (value) {
                setState(() {
                  _tipoSeleccionado = value!;
                });
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    duracion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\$${precio.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: seleccionado ? Colors.orange : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
