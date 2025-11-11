import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/ingreso.dart';
import '../controllers/transaccion_controller.dart';
import '../widgets/boton_primario.dart';

/// Pantalla para editar un ingreso existente
class EditarIngresoScreen extends StatefulWidget {
  final Ingreso ingreso;

  const EditarIngresoScreen({
    Key? key,
    required this.ingreso,
  }) : super(key: key);

  @override
  State<EditarIngresoScreen> createState() => _EditarIngresoScreenState();
}

class _EditarIngresoScreenState extends State<EditarIngresoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _conceptoController;
  late TextEditingController _montoController;
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _notasController;
  late bool _incluyeInscripcion;
  late DateTime _fechaInicio;
  late DateTime? _fechaVencimiento;

  @override
  void initState() {
    super.initState();
    _conceptoController = TextEditingController(text: widget.ingreso.concepto);
    _montoController = TextEditingController(text: widget.ingreso.monto.toString());
    _nombreController = TextEditingController(text: widget.ingreso.nombre ?? '');
    _telefonoController = TextEditingController(text: widget.ingreso.telefono ?? '');
    _notasController = TextEditingController(text: widget.ingreso.notas ?? '');
    _incluyeInscripcion = widget.ingreso.incluyeInscripcion;
    _fechaInicio = widget.ingreso.fechaInicio ?? widget.ingreso.fecha;
    _fechaVencimiento = widget.ingreso.fechaVencimiento;
  }

  @override
  void dispose() {
    _conceptoController.dispose();
    _montoController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  bool _esSuscripcion() {
    return widget.ingreso.tipo == 'semana' ||
        widget.ingreso.tipo == 'quincena' ||
        widget.ingreso.tipo == 'mensualidad';
  }

  Future<void> _seleccionarFechaInicio() async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaInicio = fechaSeleccionada;
        // Recalcular vencimiento
        _fechaVencimiento = _calcularFechaVencimiento(_fechaInicio, widget.ingreso.tipo);
      });
    }
  }

  Future<void> _seleccionarFechaVencimiento() async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento ?? DateTime.now(),
      firstDate: _fechaInicio,
      lastDate: DateTime.now().add(const Duration(days: 730)),
      locale: const Locale('es', 'ES'),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaVencimiento = fechaSeleccionada;
      });
    }
  }

  DateTime _calcularFechaVencimiento(DateTime fechaInicio, String tipo) {
    switch (tipo) {
      case 'semana':
        return fechaInicio.add(const Duration(days: 7));
      case 'quincena':
        return fechaInicio.add(const Duration(days: 15));
      case 'mensualidad':
        final mes = fechaInicio.month + 1;
        final anio = mes > 12 ? fechaInicio.year + 1 : fechaInicio.year;
        final mesAjustado = mes > 12 ? 1 : mes;
        final diasEnMes = DateTime(anio, mesAjustado + 1, 0).day;
        final dia = fechaInicio.day > diasEnMes ? diasEnMes : fechaInicio.day;
        return DateTime(anio, mesAjustado, dia);
      default:
        return fechaInicio;
    }
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      try {
        final ingresoActualizado = widget.ingreso.copyWith(
          concepto: _conceptoController.text.trim().isEmpty 
              ? widget.ingreso.concepto 
              : _conceptoController.text.trim(),
          monto: double.parse(_montoController.text),
          nombre: _nombreController.text.trim().isNotEmpty 
              ? _nombreController.text.trim() 
              : null,
          telefono: _telefonoController.text.trim().isNotEmpty 
              ? _telefonoController.text.trim() 
              : null,
          notas: _notasController.text.trim().isNotEmpty 
              ? _notasController.text.trim() 
              : null,
          incluyeInscripcion: _incluyeInscripcion,
          fechaInicio: _fechaInicio,
          fechaVencimiento: _fechaVencimiento,
        );

        final exitoso = await Provider.of<TransaccionController>(
          context,
          listen: false,
        ).actualizarIngreso(ingresoActualizado);

        if (mounted) {
          if (exitoso) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Ingreso actualizado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Error al actualizar'),
                backgroundColor: Colors.red,
              ),
            );
          }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Ingreso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('💡 Información'),
                  content: const Text(
                    'Puedes editar:\n'
                    '• Concepto y monto\n'
                    '• Datos del cliente (nombre, teléfono, notas)\n'
                    '• Fechas de inicio y vencimiento (toca para cambiar)\n\n'
                    'Al cambiar la fecha de inicio, el vencimiento se recalcula automáticamente según el tipo de suscripción.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tipo de ingreso (solo lectura)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.label, color: Colors.blue),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tipo:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          widget.ingreso.tipo.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Concepto
              TextFormField(
                controller: _conceptoController,
                decoration: const InputDecoration(
                  labelText: 'Concepto',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El concepto es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Monto
              TextFormField(
                controller: _montoController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El monto es obligatorio';
                  }
                  final monto = double.tryParse(value);
                  if (monto == null || monto <= 0) {
                    return 'Ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campos de suscripción
              if (_esSuscripcion()) ...[
                const Divider(),
                const Text(
                  'Datos del Cliente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (_esSuscripcion() && (value == null || value.trim().isEmpty)) {
                      return 'El nombre es obligatorio para suscripciones';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Teléfono
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                    hintText: '6441234567',
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                const SizedBox(height: 16),

                // Notas
                TextFormField(
                  controller: _notasController,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),

                // Incluye inscripción
                if (widget.ingreso.tipo == 'mensualidad')
                  Card(
                    color: _incluyeInscripcion 
                        ? Colors.orange.withOpacity(0.1) 
                        : null,
                    child: CheckboxListTile(
                      title: const Text('Incluye Inscripción'),
                      subtitle: const Text('\$150.00'),
                      value: _incluyeInscripcion,
                      onChanged: (value) {
                        setState(() {
                          _incluyeInscripcion = value ?? false;
                        });
                      },
                    ),
                  ),
                const SizedBox(height: 16),

                // Fechas (editables)
                const Text(
                  'Fechas de Suscripción',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Fecha de Inicio
                InkWell(
                  onTap: _seleccionarFechaInicio,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.blue),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fecha de Inicio',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.edit, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Fecha de Vencimiento
                if (_fechaVencimiento != null)
                  InkWell(
                    onTap: _seleccionarFechaVencimiento,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_busy, color: Colors.orange),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fecha de Vencimiento',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${_fechaVencimiento!.day}/${_fechaVencimiento!.month}/${_fechaVencimiento!.year}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.edit, color: Colors.orange),
                        ],
                      ),
                    ),
                  ),
              ],

              const SizedBox(height: 30),

              // Botón Guardar
              BotonPrimario(
                texto: 'Guardar Cambios',
                icono: Icons.save,
                onPressed: _guardarCambios,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
