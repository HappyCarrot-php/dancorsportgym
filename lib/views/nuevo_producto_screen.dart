import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/ingreso.dart';
import '../controllers/transaccion_controller.dart';
import '../widgets/boton_primario.dart';

/// Pantalla para registrar venta de productos
class NuevoProductoScreen extends StatefulWidget {
  const NuevoProductoScreen({Key? key}) : super(key: key);

  @override
  State<NuevoProductoScreen> createState() => _NuevoProductoScreenState();
}

class _NuevoProductoScreenState extends State<NuevoProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conceptoController = TextEditingController();
  final _montoController = TextEditingController();

  @override
  void dispose() {
    _conceptoController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _guardarProducto() async {
    if (_formKey.currentState!.validate()) {
      try {
        final ingreso = Ingreso(
          concepto: _conceptoController.text.trim(),
          monto: double.parse(_montoController.text),
          fecha: DateTime.now(),
          tipo: 'producto',
        );

        await Provider.of<TransaccionController>(context, listen: false)
            .agregarIngreso(ingreso);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Venta de producto registrada'),
              backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venta Producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.shopping_bag,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Registrar Venta de Producto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Campo Concepto
              TextFormField(
                controller: _conceptoController,
                decoration: const InputDecoration(
                  labelText: 'Producto',
                  hintText: 'Ej: Proteína, Creatina, Bebida',
                  prefixIcon: Icon(Icons.shopping_basket),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre del producto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo Monto
              TextFormField(
                controller: _montoController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
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
                    return 'Ingresa el precio';
                  }
                  final monto = double.tryParse(value);
                  if (monto == null || monto <= 0) {
                    return 'Ingresa un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Botón Guardar
              BotonPrimario(
                texto: 'Guardar Venta',
                icono: Icons.save,
                onPressed: _guardarProducto,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
