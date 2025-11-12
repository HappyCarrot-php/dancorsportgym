import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

class _CierreCard extends StatefulWidget {
  final CierreDia cierre;

  const _CierreCard({required this.cierre});

  @override
  State<_CierreCard> createState() => _CierreCardState();
}

class _CierreCardState extends State<_CierreCard> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _capturando = false;

  Future<void> _guardarImagen() async {
    if (_capturando) return;
    
    setState(() {
      _capturando = true;
    });

    try {
      // Solicitar permisos según la versión de Android
      if (Platform.isAndroid) {
        // Para Android 13+ (API 33+) usar READ_MEDIA_IMAGES
        // Para Android 10-12 (API 29-32) usar WRITE_EXTERNAL_STORAGE
        PermissionStatus status;
        
        // Intentar primero con photos (Android 13+)
        status = await Permission.photos.request();
        
        // Si no está disponible o denegado, intentar con storage (Android 10-12)
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        
        // Si aún está denegado, verificar si está permanentemente denegado
        if (!status.isGranted) {
          if (status.isPermanentlyDenied) {
            // Mostrar diálogo para abrir configuración
            if (mounted) {
              final openSettings = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('📸 Permiso Requerido'),
                  content: const Text(
                    'Se necesita permiso para guardar imágenes en la galería.\n\n'
                    '¿Deseas abrir la configuración para habilitarlo?'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Abrir Configuración'),
                    ),
                  ],
                ),
              );
              
              if (openSettings == true) {
                await openAppSettings();
              }
            }
            throw 'Permiso de almacenamiento denegado. Habilítalo en Configuración.';
          } else {
            throw 'Permiso de almacenamiento denegado';
          }
        }
      }

      // Esperar a que el widget se renderice completamente
      await Future.delayed(const Duration(milliseconds: 300));

      // Validar que el contexto exista
      if (_repaintKey.currentContext == null) {
        throw 'No se pudo capturar la imagen. Intenta abrir el reporte primero.';
      }

      // Capturar screenshot usando RepaintBoundary
      RenderObject? renderObject = _repaintKey.currentContext!.findRenderObject();
      if (renderObject == null || renderObject is! RenderRepaintBoundary) {
        throw 'Error al preparar la captura. Intenta nuevamente.';
      }

      RenderRepaintBoundary boundary = renderObject;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw 'Error al procesar la imagen';
      
      Uint8List pngBytes = byteData.buffer.asUint8List();

      // Guardar en galería
      final directory = Platform.isAndroid
          ? Directory('/storage/emulated/0/Pictures/GestorDeCaja')
          : await getApplicationDocumentsDirectory();

      if (Platform.isAndroid && !await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fecha = AppConstants.formatearFechaCorta(widget.cierre.fecha).replaceAll('/', '-');
      final fileName = 'cierre_$fecha.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Imagen guardada en: ${directory.path}/$fileName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Ver Carpeta',
              textColor: Colors.white,
              onPressed: () {
                // Aquí podrías abrir el explorador de archivos si deseas
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _capturando = false;
        });
      }
    }
  }

  Future<void> _editarCierre(BuildContext context) async {
    final controller = Provider.of<CierreController>(context, listen: false);
    final ingresosTotalesController = TextEditingController(
      text: widget.cierre.ingresosTotales.toStringAsFixed(2),
    );
    final gastosTotalesController = TextEditingController(
      text: widget.cierre.gastosTotales.toStringAsFixed(2),
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

              final cierreActualizado = widget.cierre.copyWith(
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
          '¿Eliminar el cierre del día ${AppConstants.formatearFechaCorta(widget.cierre.fecha)}?',
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
      await controller.eliminarCierre(widget.cierre.id!);
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
    final esPositivo = widget.cierre.resultadoFinal >= 0;
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
          AppConstants.formatearFechaCorta(widget.cierre.fecha),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          AppConstants.formatearFechaLarga(widget.cierre.fecha),
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
                AppConstants.formatearMoneda(widget.cierre.resultadoFinal),
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
                } else if (value == 'descargar') {
                  _guardarImagen();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'descargar',
                  child: Row(
                    children: [
                      Icon(Icons.download, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('Descargar reporte como imagen'),
                    ],
                  ),
                ),
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
          // Contenido capturable
          RepaintBoundary(
            key: _repaintKey,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetalleFila(
                    'Ingresos Totales',
                    widget.cierre.ingresosTotales,
                    const Color(AppConstants.colorIngreso),
                    Icons.trending_up,
                  ),
                  const SizedBox(height: 12),
                  _buildDetalleFila(
                    'Gastos Totales',
                    widget.cierre.gastosTotales,
                    const Color(AppConstants.colorGasto),
                    Icons.trending_down,
                  ),
                  const Divider(height: 24),
                  _buildDetalleFila(
                    'Resultado Final',
                    widget.cierre.resultadoFinal,
                    colorResultado,
                    esPositivo ? Icons.check_circle : Icons.warning,
                    isBold: true,
                  ),
                ],
              ),
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
