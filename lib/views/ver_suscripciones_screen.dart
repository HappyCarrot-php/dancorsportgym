import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/transaccion_controller.dart';
import '../models/ingreso.dart';
import '../utils/constants.dart';
import 'editar_ingreso_screen.dart';

/// Pantalla para ver suscripciones activas con CRUD
class VerSuscripcionesScreen extends StatefulWidget {
  const VerSuscripcionesScreen({Key? key}) : super(key: key);

  @override
  State<VerSuscripcionesScreen> createState() => _VerSuscripcionesScreenState();
}

class _VerSuscripcionesScreenState extends State<VerSuscripcionesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Suscripciones'),
      ),
      body: FutureBuilder<List<Ingreso>>(
        future: Provider.of<TransaccionController>(context, listen: false).obtenerTodosLosIngresos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Filtrar solo suscripciones
          final suscripciones = (snapshot.data ?? []).where((i) => 
            i.tipo == 'semana' || i.tipo == 'quincena' || i.tipo == 'mensualidad'
          ).toList();

          // Ordenar por vencimiento
          suscripciones.sort((a, b) {
            if (a.fechaVencimiento == null) return 1;
            if (b.fechaVencimiento == null) return -1;
            return a.fechaVencimiento!.compareTo(b.fechaVencimiento!);
          });

          if (suscripciones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_membership,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay suscripciones activas',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: suscripciones.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final suscripcion = suscripciones[index];
                final diasRestantes = suscripcion.fechaVencimiento != null
                    ? suscripcion.fechaVencimiento!.difference(DateTime.now()).inDays
                    : 0;

                return Card(
                  elevation: 3,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _obtenerColorEstado(diasRestantes),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      suscripcion.nombre ?? 'Sin nombre',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppConstants.obtenerNombreTipoIngreso(suscripcion.tipo)),
                        const SizedBox(height: 4),
                        Text(
                          'Vence: ${AppConstants.formatearFechaConMes(suscripcion.fechaVencimiento!)}',
                          style: TextStyle(
                            color: _obtenerColorEstado(diasRestantes),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$diasRestantes días restantes',
                          style: TextStyle(
                            color: _obtenerColorEstado(diasRestantes),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        final controller = Provider.of<TransaccionController>(context, listen: false);
                        if (value == 'editar') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditarIngresoScreen(ingreso: suscripcion),
                            ),
                          );
                          setState(() {}); // Recargar después de editar
                        } else if (value == 'eliminar') {
                          await _confirmarEliminar(context, controller, suscripcion);
                          setState(() {}); // Recargar después de eliminar
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'editar', child: Text('Editar')),
                        const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetalle('Teléfono', suscripcion.telefono ?? 'No registrado'),
                            _buildDetalle('Monto', AppConstants.formatearMoneda(suscripcion.monto)),
                            _buildDetalle('Fecha de inicio', AppConstants.formatearFechaCorta(suscripcion.fechaInicio!)),
                            if (suscripcion.notas?.isNotEmpty ?? false)
                              _buildDetalle('Notas', suscripcion.notas!),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetalle(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _obtenerColorEstado(int diasRestantes) {
    if (diasRestantes <= 0) return Colors.red;
    if (diasRestantes <= 3) return Colors.orange;
    if (diasRestantes <= 7) return Colors.yellow[700]!;
    return Colors.green;
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    TransaccionController controller,
    Ingreso suscripcion,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar Eliminación'),
        content: Text('¿Eliminar suscripción de ${suscripcion.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      final exitoso = await controller.eliminarIngreso(suscripcion.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exitoso ? '✅ Suscripción eliminada' : '❌ Error'),
            backgroundColor: exitoso ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
