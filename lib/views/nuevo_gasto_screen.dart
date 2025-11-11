import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/transaccion_controller.dart';
import '../models/gasto.dart';
import '../utils/constants.dart';
import '../widgets/boton_primario.dart';

/// Pantalla para registrar un nuevo gasto
class NuevoGastoScreen extends StatefulWidget {
  const NuevoGastoScreen({super.key});

  @override
  State<NuevoGastoScreen> createState() => _NuevoGastoScreenState();
}

class _NuevoGastoScreenState extends State<NuevoGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conceptoController = TextEditingController();
  final _montoController = TextEditingController();

  bool _isLoading = false;

  // Conceptos sugeridos comunes
  final List<String> _conceptosSugeridos = [
    'Compra de bebidas',
    'Compra de agua',
    'Material de limpieza',
    'Pago de servicios',
    'Mantenimiento',
    'Papelería',
    'Reparaciones',
  ];

  @override
  void dispose() {
    _conceptoController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Gasto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Conceptos sugeridos
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conceptos frecuentes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _conceptosSugeridos.map((concepto) {
                          return ActionChip(
                            label: Text(concepto),
                            onPressed: () {
                              _conceptoController.text = concepto;
                            },
                            backgroundColor: const Color(AppConstants.colorFondo),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Campo de concepto
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _conceptoController,
                    decoration: const InputDecoration(
                      labelText: 'Concepto *',
                      hintText: 'Ej: Compra de bebidas',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                      helperText: 'Describe el gasto realizado',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    maxLines: 2,
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
                      helperText: 'Ingresa el monto del gasto',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
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

              const SizedBox(height: 24),

              // Información adicional
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'El gasto se registrará con la fecha y hora actual.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botón guardar
              BotonPrimario(
                texto: 'Guardar Gasto',
                icono: Icons.save,
                color: const Color(AppConstants.colorGasto),
                isLoading: _isLoading,
                onPressed: _guardarGasto,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardarGasto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final gasto = Gasto(
      concepto: _conceptoController.text.trim(),
      monto: double.parse(_montoController.text),
      fecha: DateTime.now(),
    );

    final controller = Provider.of<TransaccionController>(context, listen: false);
    final exito = await controller.agregarGasto(gasto);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gasto guardado exitosamente'),
            backgroundColor: Color(AppConstants.colorGasto),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el gasto'),
            backgroundColor: Color(AppConstants.colorGasto),
          ),
        );
      }
    }
  }
}
