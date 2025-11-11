import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget reutilizable para tarjetas de resumen
class ResumenCard extends StatelessWidget {
  final String titulo;
  final double monto;
  final Color color;
  final IconData icono;

  const ResumenCard({
    super.key,
    required this.titulo,
    required this.monto,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  icono,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppConstants.formatearMoneda(monto),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
