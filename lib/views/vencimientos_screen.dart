import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/transaccion_controller.dart';
import '../models/ingreso.dart';
import '../utils/constants.dart';

/// Pantalla para ver próximos vencimientos de suscripciones
class VencimientosScreen extends StatefulWidget {
  const VencimientosScreen({Key? key}) : super(key: key);

  @override
  State<VencimientosScreen> createState() => _VencimientosScreenState();
}

class _VencimientosScreenState extends State<VencimientosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Próximos Vencimientos'),
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

          final now = DateTime.now();
          
          // Obtener suscripciones activas
          final suscripciones = (snapshot.data ?? [])
              .where((i) => 
                  i.fechaVencimiento != null &&
                  (i.tipo == 'semana' || i.tipo == 'quincena' || i.tipo == 'mensualidad'))
              .toList();

          // Separar en categorías
          final vencidas = suscripciones
              .where((s) => s.fechaVencimiento!.isBefore(now))
              .toList();
          
          final proximasVencer = suscripciones
              .where((s) => 
                  s.fechaVencimiento!.isAfter(now) &&
                  s.fechaVencimiento!.difference(now).inDays <= 7)
              .toList();
          
          final activas = suscripciones
              .where((s) => 
                  s.fechaVencimiento!.isAfter(now) &&
                  s.fechaVencimiento!.difference(now).inDays > 7)
              .toList();

          // Ordenar por fecha de vencimiento
          vencidas.sort((a, b) => a.fechaVencimiento!.compareTo(b.fechaVencimiento!));
          proximasVencer.sort((a, b) => a.fechaVencimiento!.compareTo(b.fechaVencimiento!));
          activas.sort((a, b) => a.fechaVencimiento!.compareTo(b.fechaVencimiento!));

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Resumen
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard('Vencidas', vencidas.length, Colors.red),
                            _buildStatCard('Por Vencer', proximasVencer.length, Colors.orange),
                            _buildStatCard('Activas', activas.length, Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Suscripciones vencidas
                if (vencidas.isNotEmpty) ...[
                  _buildSeccionHeader('🚨 Vencidas', Colors.red),
                  ...vencidas.map((s) => _buildSuscripcionCard(s, now, context)),
                  const SizedBox(height: 20),
                ],

                // Próximas a vencer (7 días o menos)
                if (proximasVencer.isNotEmpty) ...[
                  _buildSeccionHeader('⚠️ Próximas a Vencer', Colors.orange),
                  ...proximasVencer.map((s) => _buildSuscripcionCard(s, now, context)),
                  const SizedBox(height: 20),
                ],

                // Activas
                if (activas.isNotEmpty) ...[
                  _buildSeccionHeader('✅ Activas', Colors.green),
                  ...activas.map((s) => _buildSuscripcionCard(s, now, context)),
                ],

                if (vencidas.isEmpty && proximasVencer.isEmpty && activas.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, size: 80, color: Colors.green[200]),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay suscripciones registradas',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, int cantidad, Color color) {
    return Column(
      children: [
        Text(
          '$cantidad',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionHeader(String titulo, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuscripcionCard(Ingreso suscripcion, DateTime now, BuildContext context) {
    final diasRestantes = suscripcion.fechaVencimiento!.difference(now).inDays;
    final Color color;
    final String estado;

    if (diasRestantes < 0) {
      color = Colors.red;
      estado = 'Vencida hace ${-diasRestantes} día(s)';
    } else if (diasRestantes == 0) {
      color = Colors.orange;
      estado = '¡Vence HOY!';
    } else if (diasRestantes <= 3) {
      color = Colors.orange;
      estado = 'Vence en $diasRestantes día(s)';
    } else if (diasRestantes <= 7) {
      color = Colors.yellow[700]!;
      estado = 'Vence en $diasRestantes días';
    } else {
      color = Colors.green;
      estado = 'Vence en $diasRestantes días';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            '$diasRestantes',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
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
            Text(
              estado,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppConstants.formatearFechaCorta(suscripcion.fechaVencimiento!),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              AppConstants.formatearMoneda(suscripcion.monto),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        onTap: () {
          // Mostrar detalles
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(suscripcion.nombre ?? 'Suscripción'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetalle('Tipo', AppConstants.obtenerNombreTipoIngreso(suscripcion.tipo)),
                  _buildDetalle('Teléfono', suscripcion.telefono ?? 'No registrado'),
                  _buildDetalle('Monto', AppConstants.formatearMoneda(suscripcion.monto)),
                  _buildDetalle('Inició', AppConstants.formatearFechaCorta(suscripcion.fechaInicio!)),
                  _buildDetalle('Vence', AppConstants.formatearFechaCorta(suscripcion.fechaVencimiento!)),
                  _buildDetalle('Días restantes', '$diasRestantes'),
                  if (suscripcion.notas?.isNotEmpty ?? false)
                    _buildDetalle('Notas', suscripcion.notas!),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
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
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
