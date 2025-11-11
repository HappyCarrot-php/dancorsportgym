import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/transaccion_controller.dart';
import '../models/ingreso.dart';
import '../utils/constants.dart';
import 'editar_ingreso_screen.dart';

/// Pantalla para ver todos los ingresos registrados con CRUD
class VerIngresosScreen extends StatefulWidget {
  const VerIngresosScreen({Key? key}) : super(key: key);

  @override
  State<VerIngresosScreen> createState() => _VerIngresosScreenState();
}

class _VerIngresosScreenState extends State<VerIngresosScreen> {
  String _filtroTipo = 'todos'; // todos, producto, visita, suscripciones
  String _ordenamiento = 'reciente'; // reciente, antiguo, monto_mayor, monto_menor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Ingresos'),
        actions: [
          // Filtro por tipo
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar',
            onSelected: (value) {
              setState(() {
                _filtroTipo = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'todos',
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 20),
                    SizedBox(width: 10),
                    Text('Todos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'producto',
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag, size: 20, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Productos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'visita',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Visitas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'suscripciones',
                child: Row(
                  children: [
                    Icon(Icons.card_membership, size: 20, color: Colors.orange),
                    SizedBox(width: 10),
                    Text('Suscripciones'),
                  ],
                ),
              ),
            ],
          ),
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

          // Obtener todos los ingresos
          List<Ingreso> ingresos = snapshot.data ?? [];

          // Aplicar filtro
          ingresos = _aplicarFiltro(ingresos);

          // Aplicar ordenamiento
          ingresos = _aplicarOrdenamiento(ingresos);

          if (ingresos.isEmpty) {
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
                    'No hay ingresos registrados',
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
          final total = ingresos.fold<double>(
            0,
            (sum, ingreso) => sum + ingreso.monto,
          );

          return Column(
            children: [
              // Banner de resumen
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ingresos.length} ingresos',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _obtenerTextoFiltro(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Lista de ingresos
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: ingresos.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ingreso = ingresos[index];
                      final controller = Provider.of<TransaccionController>(context, listen: false);
                      return _IngresoCard(
                        ingreso: ingreso,
                        onEdit: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditarIngresoScreen(
                                ingreso: ingreso,
                              ),
                            ),
                          );
                          setState(() {}); // Recargar después de editar
                        },
                        onDelete: () async {
                          await _confirmarEliminar(context, controller, ingreso);
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

  List<Ingreso> _aplicarFiltro(List<Ingreso> ingresos) {
    if (_filtroTipo == 'todos') return ingresos;
    
    if (_filtroTipo == 'suscripciones') {
      return ingresos.where((i) => 
        i.tipo == 'semana' || i.tipo == 'quincena' || i.tipo == 'mensualidad'
      ).toList();
    }
    
    return ingresos.where((i) => i.tipo == _filtroTipo).toList();
  }

  List<Ingreso> _aplicarOrdenamiento(List<Ingreso> ingresos) {
    final List<Ingreso> ordenados = List.from(ingresos);
    
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

  String _obtenerTextoFiltro() {
    switch (_filtroTipo) {
      case 'producto':
        return 'Filtrado por: Productos';
      case 'visita':
        return 'Filtrado por: Visitas';
      case 'suscripciones':
        return 'Filtrado por: Suscripciones';
      default:
        return 'Mostrando todos';
    }
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    TransaccionController controller,
    Ingreso ingreso,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de eliminar este ingreso?\n\n'
          '${ingreso.concepto}\n'
          '${AppConstants.formatearMoneda(ingreso.monto)}\n\n'
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
      final exitoso = await controller.eliminarIngreso(ingreso.id!);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              exitoso ? '✅ Ingreso eliminado' : '❌ Error al eliminar',
            ),
            backgroundColor: exitoso ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

/// Widget de tarjeta para mostrar un ingreso
class _IngresoCard extends StatelessWidget {
  final Ingreso ingreso;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _IngresoCard({
    required this.ingreso,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final esSuscripcion = ingreso.fechaVencimiento != null;

    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _obtenerColor().withOpacity(0.2),
          child: Icon(
            _obtenerIcono(),
            color: _obtenerColor(),
          ),
        ),
        title: Text(
          ingreso.concepto,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              AppConstants.formatearFechaLarga(ingreso.fecha),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (ingreso.nombre != null) ...[
              const SizedBox(height: 4),
              Text(
                '👤 ${ingreso.nombre}',
                style: const TextStyle(fontSize: 13),
              ),
            ],
            if (esSuscripcion) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 12, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Vence: ${AppConstants.formatearFechaCorta(ingreso.fechaVencimiento!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
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
                  AppConstants.formatearMoneda(ingreso.monto),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _obtenerColor(),
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

  IconData _obtenerIcono() {
    switch (ingreso.tipo) {
      case 'producto':
        return Icons.shopping_bag;
      case 'visita':
        return Icons.person;
      case 'semana':
      case 'quincena':
      case 'mensualidad':
        return Icons.card_membership;
      default:
        return Icons.attach_money;
    }
  }

  Color _obtenerColor() {
    switch (ingreso.tipo) {
      case 'producto':
        return Colors.green;
      case 'visita':
        return Colors.blue;
      case 'semana':
      case 'quincena':
      case 'mensualidad':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }
}
