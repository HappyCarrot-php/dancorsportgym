import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/cierre_controller.dart';
import '../models/cierre_dia.dart';
import '../utils/constants.dart';
import '../widgets/empty_state.dart';

/// Pantalla de reportes y cierres diarios
class ReporteScreen extends StatelessWidget {
  const ReporteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes Diarios'),
      ),
      body: Consumer<CierreController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.cierres.isEmpty) {
            return const EmptyState(
              mensaje:
                  'No hay cierres diarios registrados.\n\nLos cierres aparecerán aquí cuando finalices un día.',
              icono: Icons.description,
            );
          }

          return RefreshIndicator(
            onRefresh: controller.cargarCierres,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.cierres.length,
              itemBuilder: (context, index) {
                final cierre = controller.cierres[index];
                return _CierreCard(cierre: cierre);
              },
            ),
          );
        },
      ),
    );
  }
}

class _CierreCard extends StatelessWidget {
  final CierreDia cierre;

  const _CierreCard({required this.cierre});

  Future<void> _editarCierre(BuildContext context) async {
    final controller = Provider.of<CierreController>(context, listen: false);
    final ingresosTotalesController = TextEditingController(
      text: cierre.ingresosTotales.toStringAsFixed(2),
    );
    final gastosTotalesController = TextEditingController(
      text: cierre.gastosTotales.toStringAsFixed(2),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Cierre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ingresosTotalesController,
              decoration: const InputDecoration(
                labelText: 'Ingresos Totales',
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: gastosTotalesController,
              decoration: const InputDecoration(
                labelText: 'Gastos Totales',
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final ingresos = double.tryParse(ingresosTotalesController.text) ?? 0;
              final gastos = double.tryParse(gastosTotalesController.text) ?? 0;
              final resultado = ingresos - gastos;

              final cierreActualizado = cierre.copyWith(
                ingresosTotales: ingresos,
                gastosTotales: gastos,
                resultadoFinal: resultado,
              );

              await controller.actualizarCierre(cierreActualizado);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Cierre actualizado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarCierre(BuildContext context) async {
    final controller = Provider.of<CierreController>(context, listen: false);
    
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar Eliminación'),
        content: Text(
          '¿Eliminar el cierre del día ${AppConstants.formatearFechaCorta(cierre.fecha)}?',
        ),
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
      await controller.eliminarCierre(cierre.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cierre eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esPositivo = cierre.resultadoFinal >= 0;
    final colorResultado = esPositivo
        ? const Color(AppConstants.colorIngreso)
        : const Color(AppConstants.colorGasto);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          AppConstants.formatearFechaCorta(cierre.fecha),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          AppConstants.formatearFechaLarga(cierre.fecha),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorResultado.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppConstants.formatearMoneda(cierre.resultadoFinal),
                style: TextStyle(
                  color: colorResultado,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'editar') {
                  _editarCierre(context);
                } else if (value == 'eliminar') {
                  _eliminarCierre(context);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetalleFila(
                  'Ingresos Totales',
                  cierre.ingresosTotales,
                  const Color(AppConstants.colorIngreso),
                  Icons.trending_up,
                ),
                const SizedBox(height: 12),
                _buildDetalleFila(
                  'Gastos Totales',
                  cierre.gastosTotales,
                  const Color(AppConstants.colorGasto),
                  Icons.trending_down,
                ),
                const Divider(height: 24),
                _buildDetalleFila(
                  'Resultado Final',
                  cierre.resultadoFinal,
                  colorResultado,
                  esPositivo ? Icons.check_circle : Icons.warning,
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleFila(
    String titulo,
    double monto,
    Color color,
    IconData icono, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icono,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: isBold ? 16 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        Text(
          AppConstants.formatearMoneda(monto),
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
