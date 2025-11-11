import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/transaccion_controller.dart';
import '../controllers/cierre_controller.dart';
import '../models/ingreso.dart';
import '../models/gasto.dart';
import '../utils/constants.dart';
import '../widgets/resumen_card.dart';
import '../widgets/transaccion_item.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_drawer.dart';
import 'seleccionar_ingreso_screen.dart';
import 'nuevo_gasto_screen.dart';
import 'reporte_screen.dart';
import 'editar_ingreso_screen.dart';
import 'editar_gasto_screen.dart';

/// Pantalla principal del dashboard
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppConstants.nombreApp,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              AppConstants.subtituloApp,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            tooltip: 'Ver reportes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReporteScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Seleccionar fecha',
            onPressed: () => _seleccionarFecha(context),
          ),
        ],
      ),
      body: Consumer<TransaccionController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.cargarDatos,
            child: CustomScrollView(
              slivers: [
                // Header con fecha
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: const Color(AppConstants.colorFondo),
                    child: Column(
                      children: [
                        Text(
                          AppConstants.esHoy(controller.fechaSeleccionada)
                              ? 'Hoy'
                              : AppConstants.formatearFechaLarga(
                                  controller.fechaSeleccionada),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!AppConstants.esHoy(controller.fechaSeleccionada))
                          TextButton.icon(
                            onPressed: () {
                              controller.cambiarFecha(DateTime.now());
                            },
                            icon: const Icon(Icons.today),
                            label: const Text('Volver a hoy'),
                          ),
                      ],
                    ),
                  ),
                ),

                // Tarjetas de resumen
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ResumenCard(
                          titulo: 'Ingresos',
                          monto: controller.totalIngresos,
                          color: const Color(AppConstants.colorIngreso),
                          icono: Icons.trending_up,
                        ),
                        const SizedBox(height: 12),
                        ResumenCard(
                          titulo: 'Gastos',
                          monto: controller.totalGastos,
                          color: const Color(AppConstants.colorGasto),
                          icono: Icons.trending_down,
                        ),
                        const SizedBox(height: 12),
                        ResumenCard(
                          titulo: 'Resultado del día',
                          monto: controller.resultadoDia,
                          color: controller.resultadoDia >= 0
                              ? const Color(AppConstants.colorSecundario)
                              : const Color(AppConstants.colorGasto),
                          icono: controller.resultadoDia >= 0
                              ? Icons.check_circle
                              : Icons.warning,
                        ),
                      ],
                    ),
                  ),
                ),

                // Botón finalizar día
                if (AppConstants.esHoy(controller.fechaSeleccionada))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: () => _finalizarDia(context, controller),
                        icon: const Icon(Icons.check),
                        label: const Text('Finalizar Día'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(AppConstants.colorSecundario),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Título de movimientos
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Movimientos del día',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),

                // Lista de movimientos
                if (controller.ingresos.isEmpty && controller.gastos.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyState(
                      mensaje:
                          'No hay movimientos registrados para este día.\n\n¡Comienza agregando un ingreso o gasto!',
                      icono: Icons.receipt_long,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Combinar y ordenar ingresos y gastos
                        final List<dynamic> movimientos = [];
                        movimientos.addAll(controller.ingresos);
                        movimientos.addAll(controller.gastos);
                        
                        // Ordenar por fecha (más reciente primero), y si es igual por id (más reciente primero)
                        movimientos.sort((a, b) {
                          final fechaA = a is Ingreso ? a.fecha : (a as Gasto).fecha;
                          final fechaB = b is Ingreso ? b.fecha : (b as Gasto).fecha;
                          final comparacionFecha = fechaB.compareTo(fechaA);
                          
                          if (comparacionFecha != 0) {
                            return comparacionFecha;
                          }
                          
                          // Si las fechas son iguales, ordenar por ID (más reciente primero)
                          final idA = a is Ingreso ? (a.id ?? 0) : (a as Gasto).id ?? 0;
                          final idB = b is Ingreso ? (b.id ?? 0) : (b as Gasto).id ?? 0;
                          return idB.compareTo(idA);
                        });

                        final movimiento = movimientos[index];

                        return TransaccionItem(
                          transaccion: movimiento,
                          onEdit: () {
                            if (movimiento is Ingreso) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditarIngresoScreen(
                                    ingreso: movimiento,
                                  ),
                                ),
                              );
                            } else if (movimiento is Gasto) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditarGastoScreen(
                                    gasto: movimiento,
                                  ),
                                ),
                              );
                            }
                          },
                          onDelete: () async {
                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('⚠️ Confirmar Eliminación'),
                                content: Text(
                                  '¿Estás seguro de eliminar este ${movimiento is Ingreso ? 'ingreso' : 'gasto'}?\n\n'
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

                            if (confirmar == true) {
                              final exitoso = movimiento is Ingreso
                                  ? await controller.eliminarIngreso(movimiento.id!)
                                  : await controller.eliminarGasto(movimiento.id!);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      exitoso
                                          ? '✅ ${movimiento is Ingreso ? 'Ingreso' : 'Gasto'} eliminado'
                                          : '❌ Error al eliminar',
                                    ),
                                    backgroundColor: exitoso ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                      childCount: controller.ingresos.length +
                          controller.gastos.length,
                    ),
                  ),

                // Espaciado inferior
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SeleccionarIngresoScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Ingreso'),
            backgroundColor: const Color(AppConstants.colorIngreso),
            heroTag: 'ingreso',
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NuevoGastoScreen(),
                ),
              );
            },
            icon: const Icon(Icons.remove),
            label: const Text('Gasto'),
            backgroundColor: const Color(AppConstants.colorGasto),
            heroTag: 'gasto',
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final controller = Provider.of<TransaccionController>(context, listen: false);
    
    final fecha = await showDatePicker(
      context: context,
      initialDate: controller.fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (fecha != null) {
      controller.cambiarFecha(fecha);
    }
  }

  Future<void> _finalizarDia(
    BuildContext context,
    TransaccionController controller,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Finalizar día'),
          content: Text(
            '¿Deseas finalizar el día?\n\n'
            'Se guardará el siguiente resumen:\n'
            'Ingresos: ${AppConstants.formatearMoneda(controller.totalIngresos)}\n'
            'Gastos: ${AppConstants.formatearMoneda(controller.totalGastos)}\n'
            'Resultado: ${AppConstants.formatearMoneda(controller.resultadoDia)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      final exito = await controller.finalizarDia();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              exito
                  ? '✅ Cierre guardado. Puedes seguir agregando movimientos.'
                  : '❌ Error al finalizar el día',
            ),
            backgroundColor:
                exito ? Colors.green : const Color(AppConstants.colorGasto),
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Recargar el controller de cierres si está disponible
        if (exito) {
          try {
            final cierreController = Provider.of<CierreController>(context, listen: false);
            await cierreController.cargarCierres();
          } catch (e) {
            debugPrint('No se pudo recargar cierres: $e');
          }
        }
      }
    }
  }
}
