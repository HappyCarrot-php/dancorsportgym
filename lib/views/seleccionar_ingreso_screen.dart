import 'package:flutter/material.dart';
import 'nuevo_producto_screen.dart';
import 'nuevo_visita_screen.dart';
import 'nuevo_suscripcion_screen.dart';

/// Pantalla para seleccionar el tipo de ingreso a registrar
class SeleccionarIngresoScreen extends StatelessWidget {
  const SeleccionarIngresoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Ingreso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              '¿Qué deseas registrar?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Botón Venta Producto
            _buildOptionCard(
              context,
              icon: Icons.shopping_bag,
              title: 'Venta Producto',
              subtitle: 'Suplementos, bebidas, etc.',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NuevoProductoScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Botón Venta Visita
            _buildOptionCard(
              context,
              icon: Icons.access_time,
              title: 'Venta Visita',
              subtitle: '\$40.00 - Un día',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NuevoVisitaScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Botón Suscripción
            _buildOptionCard(
              context,
              icon: Icons.card_membership,
              title: 'Suscripción',
              subtitle: 'Semana, Quincena, Mensualidad',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NuevoSuscripcionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
