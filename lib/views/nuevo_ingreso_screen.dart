import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/transaccion_controller.dart';
import '../models/ingreso.dart';
import '../utils/constants.dart';
import '../widgets/boton_primario.dart';

/// Pantalla para registrar un nuevo ingreso
class NuevoIngresoScreen extends StatefulWidget {
  const NuevoIngresoScreen({super.key});

  @override
  State<NuevoIngresoScreen> createState() => _NuevoIngresoScreenState();
}

class _NuevoIngresoScreenState extends State<NuevoIngresoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conceptoController = TextEditingController();
  final _montoController = TextEditingController();
  final _nombreController = TextEditingController();

  String _tipoSeleccionado = AppConstants.tipoVisita;
  bool _incluirInscripcion = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _actualizarMontoPorTipo();
  }

  @override
  void dispose() {
    _conceptoController.dispose();
    _montoController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  void _actualizarMontoPorTipo() {
    double monto;
    String concepto;

    switch (_tipoSeleccionado) {
      case AppConstants.tipoVisita:
        monto = AppConstants.montoVisita;
        concepto = 'Visita';
        break;
      case AppConstants.tipoSemana:
        monto = AppConstants.montoSemana;
        concepto = 'Semana';
        break;
      case AppConstants.tipoQuincena:
        monto = AppConstants.montoQuincena;
        concepto = 'Quincena';
        break;
      case AppConstants.tipoMensualidad:
        monto = AppConstants.montoMensualidad;
        if (_incluirInscripcion) {
          monto += AppConstants.montoInscripcion;
        }
        concepto = _incluirInscripcion ? 'Mensualidad + Inscripción' : 'Mensualidad';
        break;
      default:
        _montoController.clear();
        _conceptoController.clear();
        return;
    }

    _montoController.text = monto.toString();
    _conceptoController.text = concepto;
  }

  bool _requiereNombre() {
    return _tipoSeleccionado == AppConstants.tipoSemana ||
        _tipoSeleccionado == AppConstants.tipoQuincena ||
        _tipoSeleccionado == AppConstants.tipoMensualidad;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Ingreso'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector de tipo
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de ingreso',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _tipoSeleccionado,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: AppConstants.tipoVisita,
                            child: Text('Visita (\$40)'),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.tipoSemana,
                            child: Text('Semana (\$180)'),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.tipoQuincena,
                            child: Text('Quincena (\$260)'),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.tipoMensualidad,
                            child: Text('Mensualidad (\$400)'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _tipoSeleccionado = value!;
                            _incluirInscripcion = false;
                            _actualizarMontoPorTipo();
                          });
                        },
                      ),
                      
                      // Checkbox de inscripción
                      if (_tipoSeleccionado == AppConstants.tipoMensualidad)
                        CheckboxListTile(
                          title: const Text('Incluir inscripción (+\$150)'),
                          value: _incluirInscripcion,
                          onChanged: (value) {
                            setState(() {
                              _incluirInscripcion = value ?? false;
                              _actualizarMontoPorTipo();
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Campo de nombre (solo para semana, quincena, mensualidad)
              if (_requiereNombre())
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del cliente *',
                        hintText: 'Ej: Juan Pérez',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (_requiereNombre() && (value == null || value.isEmpty)) {
                          return 'El nombre es requerido para este tipo de ingreso';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

              if (_requiereNombre()) const SizedBox(height: 16),

              // Campo de concepto
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _conceptoController,
                    decoration: const InputDecoration(
                      labelText: 'Concepto *',
                      hintText: 'Ej: Visita, Venta de agua',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El concepto es requerido';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Campo de monto
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _montoController,
                    decoration: const InputDecoration(
                      labelText: 'Monto *',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El monto es requerido';
                      }
                      final monto = double.tryParse(value);
                      if (monto == null || monto <= 0) {
                        return 'Ingresa un monto válido';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botón guardar
              BotonPrimario(
                texto: 'Guardar Ingreso',
                icono: Icons.save,
                color: const Color(AppConstants.colorIngreso),
                isLoading: _isLoading,
                onPressed: _guardarIngreso,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardarIngreso() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final ingreso = Ingreso(
      concepto: _conceptoController.text.trim(),
      monto: double.parse(_montoController.text),
      fecha: DateTime.now(),
      nombre: _requiereNombre() ? _nombreController.text.trim() : null,
      tipo: _tipoSeleccionado,
    );

    final controller = Provider.of<TransaccionController>(context, listen: false);
    final exito = await controller.agregarIngreso(ingreso);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ingreso guardado exitosamente'),
            backgroundColor: Color(AppConstants.colorIngreso),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el ingreso'),
            backgroundColor: Color(AppConstants.colorGasto),
          ),
        );
      }
    }
  }
}
