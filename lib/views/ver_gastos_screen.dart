import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/transaccion_controller.dart';
import '../models/gasto.dart';
import '../utils/constants.dart';
import 'editar_gasto_screen.dart';

/// Pantalla para ver todos los gastos registrados con CRUD
class VerGastosScreen extends StatefulWidget {
  const VerGastosScreen({Key? key}) : super(key: key);

  @override
  State<VerGastosScreen> createState() => _VerGastosScreenState();
}

class _VerGastosScreenState extends State<VerGastosScreen> {
  String _ordenamiento = 'reciente'; // reciente, antiguo, monto_mayor, monto_menor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Gastos'),
        actions: [
          // Ordenamiento
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
            onSelected: (value) {
              setState(() {
                _ordenamiento = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reciente',
                child: Text('Más reciente'),
              ),
              const PopupMenuItem(
                value: 'antiguo',
                child: Text('Más antiguo'),
              ),
              const PopupMenuItem(
                value: 'monto_mayor',
                child: Text('Monto mayor'),
              ),
              const PopupMenuItem(
                value: 'monto_menor',
                child: Text('Monto menor'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Gasto>>(
        future: Provider.of<TransaccionController>(context, listen: false).obtenerTodosLosGastos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Obtener todos los gastos
          List<Gasto> gastos = snapshot.data ?? [];

          // Aplicar ordenamiento
          gastos = _aplicarOrdenamiento(gastos);

          if (gastos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay gastos registrados',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // Calcular total
          final total = gastos.fold<double>(
            0,
            (sum, gasto) => sum + gasto.monto,
          );

          return Column(
            children: [
              // Banner de resumen
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${gastos.length} gastos',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          AppConstants.formatearMoneda(total),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Lista de gastos
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: gastos.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final gasto = gastos[index];
                      final controller = Provider.of<TransaccionController>(context, listen: false);
                      return _GastoCard(
                        gasto: gasto,
                        onEdit: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditarGastoScreen(
                                gasto: gasto,
                              ),
                            ),
                          );
                          setState(() {}); // Recargar después de editar
                        },
                        onDelete: () async {
                          await _confirmarEliminar(context, controller, gasto);
                          setState(() {}); // Recargar después de eliminar
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Gasto> _aplicarOrdenamiento(List<Gasto> gastos) {
    final List<Gasto> ordenados = List.from(gastos);
    
    switch (_ordenamiento) {
      case 'reciente':
        ordenados.sort((a, b) => b.fecha.compareTo(a.fecha));
        break;
      case 'antiguo':
        ordenados.sort((a, b) => a.fecha.compareTo(b.fecha));
        break;
      case 'monto_mayor':
        ordenados.sort((a, b) => b.monto.compareTo(a.monto));
        break;
      case 'monto_menor':
        ordenados.sort((a, b) => a.monto.compareTo(b.monto));
        break;
    }
    
    return ordenados;
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    TransaccionController controller,
    Gasto gasto,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de eliminar este gasto?\n\n'
          '${gasto.concepto}\n'
          '${AppConstants.formatearMoneda(gasto.monto)}\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      final exitoso = await controller.eliminarGasto(gasto.id!);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              exitoso ? '✅ Gasto eliminado' : '❌ Error al eliminar',
            ),
            backgroundColor: exitoso ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

/// Widget de tarjeta para mostrar un gasto
class _GastoCard extends StatelessWidget {
  final Gasto gasto;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GastoCard({
    required this.gasto,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFEBEE),
          child: Icon(
            Icons.trending_down,
            color: Colors.red,
          ),
        ),
        title: Text(
          gasto.concepto,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              AppConstants.formatearFechaLarga(gasto.fecha),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppConstants.formatearMoneda(gasto.monto),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'editar') {
                  onEdit();
                } else if (value == 'eliminar') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: Colors.blue),
                      SizedBox(width: 10),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Eliminar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
