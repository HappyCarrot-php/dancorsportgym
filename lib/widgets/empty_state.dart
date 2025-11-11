import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget para mostrar el estado vacío cuando no hay datos
class EmptyState extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  final String? botonTexto;
  final VoidCallback? onBotonPressed;

  const EmptyState({
    super.key,
    required this.mensaje,
    required this.icono,
    this.botonTexto,
    this.onBotonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (botonTexto != null && onBotonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onBotonPressed,
                icon: const Icon(Icons.add),
                label: Text(botonTexto!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.colorPrimario),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
