import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'controllers/transaccion_controller.dart';
import 'controllers/cierre_controller.dart';
import 'views/splash_screen.dart';
import 'views/home_screen.dart';
import 'views/ver_ingresos_screen.dart';
import 'views/ver_gastos_screen.dart';
import 'views/ver_suscripciones_screen.dart';
import 'views/vencimientos_screen.dart';
import 'views/reporte_screen.dart';
import 'views/dashboard_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(const GestorDeCajaApp());
}

class GestorDeCajaApp extends StatelessWidget {
  const GestorDeCajaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransaccionController()),
        ChangeNotifierProvider(create: (_) => CierreController()),
      ],
      child: MaterialApp(
        title: AppConstants.nombreApp,
        debugShowCheckedModeBanner: false,
        
        // Localization delegates
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
        ],
        locale: const Locale('es', 'ES'),
        
        // Tema de la aplicación
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(AppConstants.colorPrimario),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.white,
          
          // AppBar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(AppConstants.colorPrimario),
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: false,
          ),
          
          // Card theme
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          // FloatingActionButton theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
            foregroundColor: Colors.white,
          ),
          
          // InputDecoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(AppConstants.colorPrimario),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
        
        // Rutas con nombre
        routes: {
          '/home': (context) => const HomeScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/ver-ingresos': (context) => const VerIngresosScreen(),
          '/ver-gastos': (context) => const VerGastosScreen(),
          '/ver-suscripciones': (context) => const VerSuscripcionesScreen(),
          '/vencimientos': (context) => const VencimientosScreen(),
          '/reportes': (context) => const ReporteScreen(),
        },
        
        home: const SplashScreen(),
      ),
    );
  }
}
