import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ingreso.dart';
import '../controllers/transaccion_controller.dart';
import '../widgets/boton_primario.dart';

/// Pantalla para registrar venta de visita ($40)
class NuevoVisitaScreen extends StatelessWidget {
  const NuevoVisitaScreen({Key? key}) : super(key: key);

  static const double PRECIO_VISITA = 40.0;

  Future<void> _guardarVisita(BuildContext context) async {
    try {
      final ingreso = Ingreso(
        concepto: 'Visita de 1 día',
        monto: PRECIO_VISITA,
        fecha: DateTime.now(),
        tipo: 'visita',
      );

      await Provider.of<TransaccionController>(context, listen: false)
          .agregarIngreso(ingreso);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Visita registrada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venta Visita'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 30),
              const Text(
                'Visita de 1 día',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                ),
                child: const Text(
                  '\$40.00',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Acceso por 1 día',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const Text(
                'No requiere datos del cliente',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: BotonPrimario(
                  texto: 'Registrar Visita',
                  icono: Icons.check_circle,
                  onPressed: () => _guardarVisita(context),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
