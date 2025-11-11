import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/transaccion_controller.dart';
import '../utils/constants.dart';

/// Drawer principal con menú de navegación
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del drawer
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(AppConstants.colorPrimario),
                  Color(AppConstants.colorSecundario),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/icons/dansporticon.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.fitness_center,
                          size: 40,
                          color: Color(AppConstants.colorPrimario),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Gestor de Caja',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Dancor Sport Gym',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Opción: Inicio
          ListTile(
            leading: const Icon(Icons.home, color: Color(AppConstants.colorPrimario)),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context); // Cerrar drawer
              // Regresar a la pantalla de inicio
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
          ),

          const Divider(),

          // Sección: Análisis
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'ANÁLISIS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),

          // Opción: Dashboard
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.purple),
            title: const Text('Dashboard'),
            subtitle: const Text('Estadísticas y gráficas'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: const Text(
                'NUEVO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/dashboard');
            },
          ),

          const Divider(),

          // Sección: Movimientos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'MOVIMIENTOS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),

          // Opción: Ver Ingresos
          ListTile(
            leading: const Icon(Icons.trending_up, color: Colors.green),
            title: const Text('Ver Ingresos'),
            subtitle: const Text('Todos los ingresos registrados'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ver-ingresos');
            },
          ),

          // Opción: Ver Gastos
          ListTile(
            leading: const Icon(Icons.trending_down, color: Colors.red),
            title: const Text('Ver Gastos'),
            subtitle: const Text('Todos los gastos registrados'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ver-gastos');
            },
          ),

          // Opción: Ver Suscripciones
          ListTile(
            leading: const Icon(Icons.card_membership, color: Colors.orange),
            title: const Text('Ver Suscripciones'),
            subtitle: const Text('Suscripciones activas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ver-suscripciones');
            },
          ),

          const Divider(),

          // Sección: Vencimientos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'RECORDATORIOS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),

          // Opción: Vencimientos
          Consumer<TransaccionController>(
            builder: (context, controller, child) {
              // Calcular suscripciones próximas a vencer
              final now = DateTime.now();
              final proximasVencer = controller.ingresos
                  .where((i) => 
                      i.fechaVencimiento != null &&
                      i.fechaVencimiento!.isAfter(now) &&
                      i.fechaVencimiento!.difference(now).inDays <= 7)
                  .length;

              return ListTile(
                leading: Badge(
                  label: Text('$proximasVencer'),
                  isLabelVisible: proximasVencer > 0,
                  child: const Icon(Icons.notification_important, color: Colors.deepOrange),
                ),
                title: const Text('Próximos Vencimientos'),
                subtitle: proximasVencer > 0
                    ? Text('$proximasVencer suscripciones por vencer')
                    : const Text('Ver calendario de vencimientos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/vencimientos');
                },
              );
            },
          ),

          const Divider(),

          // Opción: Reportes
          ListTile(
            leading: const Icon(Icons.assessment, color: Colors.blue),
            title: const Text('Reportes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/reportes');
            },
          ),

          const Divider(),

          // Versión de la app
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Versión 2.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
