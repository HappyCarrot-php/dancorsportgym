import 'package:flutter/material.dart';
import '../models/ingreso.dart';
import '../models/gasto.dart';
import '../utils/constants.dart';

/// Widget para mostrar un item de transacción (ingreso o gasto)
class TransaccionItem extends StatelessWidget {
  final dynamic transaccion; // Puede ser Ingreso o Gasto
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TransaccionItem({
    super.key,
    required this.transaccion,
    this.onDelete,
    this.onEdit,
  });

  bool get esIngreso => transaccion is Ingreso;

  @override
  Widget build(BuildContext context) {
    final color = esIngreso
        ? const Color(AppConstants.colorIngreso)
        : const Color(AppConstants.colorGasto);

    final concepto = esIngreso
        ? (transaccion as Ingreso).concepto
        : (transaccion as Gasto).concepto;

    final monto = esIngreso
        ? (transaccion as Ingreso).monto
        : (transaccion as Gasto).monto;

    final fecha = esIngreso
        ? (transaccion as Ingreso).fecha
        : (transaccion as Gasto).fecha;

    final nombre = esIngreso ? (transaccion as Ingreso).nombre : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            esIngreso ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
          ),
        ),
        title: Text(
          concepto,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nombre != null && nombre.isNotEmpty)
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              AppConstants.formatearHora(fecha),
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
                  AppConstants.formatearMoneda(monto),
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (esIngreso && (transaccion as Ingreso).fechaVencimiento != null)
                  Text(
                    'Vence: ${AppConstants.formatearFechaCorta((transaccion as Ingreso).fechaVencimiento!)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) {
                    onEdit!();
                  } else if (value == 'delete' && onDelete != null) {
                    _mostrarConfirmacionEliminacion(context);
                  }
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _mostrarConfirmacionEliminacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
            '¿Estás seguro de que deseas eliminar este ${esIngreso ? 'ingreso' : 'gasto'}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
