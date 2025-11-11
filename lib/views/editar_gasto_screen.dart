import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/gasto.dart';
import '../controllers/transaccion_controller.dart';
import '../widgets/boton_primario.dart';

/// Pantalla para editar un gasto existente
class EditarGastoScreen extends StatefulWidget {
  final Gasto gasto;

  const EditarGastoScreen({
    Key? key,
    required this.gasto,
  }) : super(key: key);

  @override
  State<EditarGastoScreen> createState() => _EditarGastoScreenState();
}

class _EditarGastoScreenState extends State<EditarGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _conceptoController;
  late TextEditingController _montoController;

  @override
  void initState() {
    super.initState();
    _conceptoController = TextEditingController(text: widget.gasto.concepto);
    _montoController = TextEditingController(text: widget.gasto.monto.toString());
  }

  @override
  void dispose() {
    _conceptoController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      try {
        final gastoActualizado = widget.gasto.copyWith(
          concepto: _conceptoController.text.trim(),
          monto: double.parse(_montoController.text),
        );

        final exitoso = await Provider.of<TransaccionController>(
          context,
          listen: false,
        ).actualizarGasto(gastoActualizado);

        if (mounted) {
          if (exitoso) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Gasto actualizado correctamente'),
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
        title: const Text('Editar Gasto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.edit,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              const Text(
                'Editar Gasto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Fecha (solo lectura)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    const Text('Fecha: '),
                    Text(
                      '${widget.gasto.fecha.day}/${widget.gasto.fecha.month}/${widget.gasto.fecha.year} ${widget.gasto.fecha.hour}:${widget.gasto.fecha.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Concepto
              TextFormField(
                controller: _conceptoController,
                decoration: const InputDecoration(
                  labelText: 'Concepto del Gasto',
                  hintText: 'Ej: Pago de luz, Compra de equipo',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El concepto es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Monto
              TextFormField(
                controller: _montoController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
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
                    return 'El monto es obligatorio';
                  }
                  final monto = double.tryParse(value);
                  if (monto == null || monto <= 0) {
                    return 'Ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Mensaje informativo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Solo puedes editar el concepto y el monto.\nLa fecha de registro no se puede modificar.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
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
