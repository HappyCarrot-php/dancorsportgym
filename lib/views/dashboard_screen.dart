import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/transaccion_controller.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _periodoSeleccionado = 'semana'; // semana, 2semanas, mes
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Dashboard'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _periodoSeleccionado,
            onSelected: (value) {
              setState(() {
                _periodoSeleccionado = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'semana',
                child: Text('Última Semana'),
              ),
              const PopupMenuItem(
                value: '2semanas',
                child: Text('Últimas 2 Semanas'),
              ),
              const PopupMenuItem(
                value: 'mes',
                child: Text('Último Mes'),
              ),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _cargarDatosDashboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          
          final datos = snapshot.data!;
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen de ganancias
                  _buildResumenGanancias(datos),
                  const SizedBox(height: 24),
                  
                  // Gráfica de barras: Ingresos vs Gastos
                  _buildGraficaBarras(datos),
                  const SizedBox(height: 24),
                  
                  // Gráfica de línea: Tendencia de ganancias
                  _buildGraficaLinea(datos),
                  const SizedBox(height: 24),
                  
                  // Gráfica circular: Distribución de ingresos
                  _buildGraficaCircularIngresos(datos),
                  const SizedBox(height: 24),
                  
                  // Gráfica de área: Comparativa semanal
                  _buildGraficaArea(datos),
                  const SizedBox(height: 24),
                  
                  // Métricas adicionales
                  _buildMetricasAdicionales(datos),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Future<Map<String, dynamic>> _cargarDatosDashboard() async {
    final controller = Provider.of<TransaccionController>(context, listen: false);
    
    // Calcular fecha de inicio según periodo seleccionado
    final ahora = DateTime.now();
    DateTime fechaInicio;
    
    switch (_periodoSeleccionado) {
      case 'semana':
        fechaInicio = ahora.subtract(const Duration(days: 7));
        break;
      case '2semanas':
        fechaInicio = ahora.subtract(const Duration(days: 14));
        break;
      case 'mes':
        fechaInicio = DateTime(ahora.year, ahora.month - 1, ahora.day);
        break;
      default:
        fechaInicio = ahora.subtract(const Duration(days: 7));
    }
    
    // Cargar todos los ingresos y gastos
    final todosIngresos = await controller.obtenerTodosLosIngresos();
    final todosGastos = await controller.obtenerTodosLosGastos();
    
    // Filtrar por periodo
    final ingresosPeriodo = todosIngresos.where((i) {
      return i.fecha.isAfter(fechaInicio) && i.fecha.isBefore(ahora.add(const Duration(days: 1)));
    }).toList();
    
    final gastosPeriodo = todosGastos.where((g) {
      return g.fecha.isAfter(fechaInicio) && g.fecha.isBefore(ahora.add(const Duration(days: 1)));
    }).toList();
    
    // Calcular totales
    final totalIngresos = ingresosPeriodo.fold<double>(
      0, (sum, item) => sum + item.monto
    );
    final totalGastos = gastosPeriodo.fold<double>(
      0, (sum, item) => sum + item.monto
    );
    final gananciaTotal = totalIngresos - totalGastos;
    
    // Separar ingresos por tipo
    final ingresosProducto = ingresosPeriodo.where((i) => i.tipo == 'producto').toList();
    final ingresosVisita = ingresosPeriodo.where((i) => i.tipo == 'visita').toList();
    final ingresosSuscripcion = ingresosPeriodo.where((i) => 
      i.tipo == 'semana' || i.tipo == 'quincena' || i.tipo == 'mensualidad'
    ).toList();
    
    // Calcular totales por tipo
    final totalProducto = ingresosProducto.fold<double>(0, (sum, item) => sum + item.monto);
    final totalVisita = ingresosVisita.fold<double>(0, (sum, item) => sum + item.monto);
    final totalSuscripcion = ingresosSuscripcion.fold<double>(0, (sum, item) => sum + item.monto);
    
    // Datos por día para gráficas de tendencia
    final datosPorDia = <DateTime, Map<String, double>>{};
    
    for (final ingreso in ingresosPeriodo) {
      final fechaSinHora = DateTime(ingreso.fecha.year, ingreso.fecha.month, ingreso.fecha.day);
      
      if (!datosPorDia.containsKey(fechaSinHora)) {
        datosPorDia[fechaSinHora] = {'ingresos': 0, 'gastos': 0};
      }
      datosPorDia[fechaSinHora]!['ingresos'] = 
        datosPorDia[fechaSinHora]!['ingresos']! + ingreso.monto;
    }
    
    for (final gasto in gastosPeriodo) {
      final fechaSinHora = DateTime(gasto.fecha.year, gasto.fecha.month, gasto.fecha.day);
      
      if (!datosPorDia.containsKey(fechaSinHora)) {
        datosPorDia[fechaSinHora] = {'ingresos': 0, 'gastos': 0};
      }
      datosPorDia[fechaSinHora]!['gastos'] = 
        datosPorDia[fechaSinHora]!['gastos']! + gasto.monto;
    }
    
    // Calcular promedios
    final dias = datosPorDia.length > 0 ? datosPorDia.length : 1;
    final promedioIngresosDia = totalIngresos / dias;
    final promedioGastosDia = totalGastos / dias;
    final promedioGananciasDia = gananciaTotal / dias;
    
    return {
      'totalIngresos': totalIngresos,
      'totalGastos': totalGastos,
      'gananciaTotal': gananciaTotal,
      'totalProducto': totalProducto,
      'totalVisita': totalVisita,
      'totalSuscripcion': totalSuscripcion,
      'datosPorDia': datosPorDia,
      'promedioIngresosDia': promedioIngresosDia,
      'promedioGastosDia': promedioGastosDia,
      'promedioGananciasDia': promedioGananciasDia,
      'cantidadIngresos': ingresosPeriodo.length,
      'cantidadGastos': gastosPeriodo.length,
      'fechaInicio': fechaInicio,
      'fechaFin': ahora,
    };
  }
  
  Widget _buildResumenGanancias(Map<String, dynamic> datos) {
    final formatoMoneda = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Resumen de Ganancias',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResumenItem(
                  'Total Ingresos',
                  formatoMoneda.format(datos['totalIngresos']),
                  Colors.green,
                  Icons.arrow_upward,
                ),
                _buildResumenItem(
                  'Total Gastos',
                  formatoMoneda.format(datos['totalGastos']),
                  Colors.red,
                  Icons.arrow_downward,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: datos['gananciaTotal'] >= 0 
                  ? Colors.green.shade50 
                  : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: datos['gananciaTotal'] >= 0 
                    ? Colors.green 
                    : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    datos['gananciaTotal'] >= 0 
                      ? Icons.check_circle 
                      : Icons.error,
                    color: datos['gananciaTotal'] >= 0 
                      ? Colors.green 
                      : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ganancia Neta',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        formatoMoneda.format(datos['gananciaTotal']),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: datos['gananciaTotal'] >= 0 
                            ? Colors.green 
                            : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResumenItem(String label, String valor, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGraficaBarras(Map<String, dynamic> datos) {
    final datosPorDia = datos['datosPorDia'] as Map<DateTime, Map<String, double>>;
    final fechasOrdenadas = datosPorDia.keys.toList()..sort();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Ingresos vs Gastos (Barras)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Comparación diaria de ingresos y gastos',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calcularMaxY(datosPorDia),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final fecha = fechasOrdenadas[group.x.toInt()];
                        final tipo = rodIndex == 0 ? 'Ingresos' : 'Gastos';
                        return BarTooltipItem(
                          '${DateFormat('dd/MMM').format(fecha)}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '$tipo: \$${rod.toY.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= fechasOrdenadas.length) {
                            return const SizedBox();
                          }
                          final fecha = fechasOrdenadas[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('dd').format(fecha),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: fechasOrdenadas.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final fecha = entry.value;
                    final valores = datosPorDia[fecha]!;
                    
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: valores['ingresos']!,
                          color: Colors.green,
                          width: 12,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: valores['gastos']!,
                          color: Colors.red,
                          width: 12,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLeyenda('Ingresos', Colors.green),
                const SizedBox(width: 24),
                _buildLeyenda('Gastos', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGraficaLinea(Map<String, dynamic> datos) {
    final datosPorDia = datos['datosPorDia'] as Map<DateTime, Map<String, double>>;
    final fechasOrdenadas = datosPorDia.keys.toList()..sort();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Tendencia de Ganancias (Línea)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Evolución de la ganancia neta diaria',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 100,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= fechasOrdenadas.length) {
                            return const SizedBox();
                          }
                          final fecha = fechasOrdenadas[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('dd/MMM').format(fecha),
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: fechasOrdenadas.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final fecha = entry.value;
                        final valores = datosPorDia[fecha]!;
                        final ganancia = valores['ingresos']! - valores['gastos']!;
                        return FlSpot(idx.toDouble(), ganancia);
                      }).toList(),
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.purple,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.purple.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final fecha = fechasOrdenadas[spot.x.toInt()];
                          return LineTooltipItem(
                            '${DateFormat('dd/MMM').format(fecha)}\nGanancia: \$${spot.y.toStringAsFixed(2)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGraficaCircularIngresos(Map<String, dynamic> datos) {
    final totalProducto = datos['totalProducto'] as double;
    final totalVisita = datos['totalVisita'] as double;
    final totalSuscripcion = datos['totalSuscripcion'] as double;
    final total = totalProducto + totalVisita + totalSuscripcion;
    
    if (total == 0) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.pie_chart, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Sin datos de ingresos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Distribución de Ingresos (Pastel)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Porcentaje de ingresos por categoría',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    if (totalProducto > 0)
                      PieChartSectionData(
                        color: Colors.blue,
                        value: totalProducto,
                        title: '${((totalProducto / total) * 100).toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (totalVisita > 0)
                      PieChartSectionData(
                        color: Colors.orange,
                        value: totalVisita,
                        title: '${((totalVisita / total) * 100).toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (totalSuscripcion > 0)
                      PieChartSectionData(
                        color: Colors.green,
                        value: totalSuscripcion,
                        title: '${((totalSuscripcion / total) * 100).toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                if (totalProducto > 0)
                  _buildLeyendaConValor(
                    'Productos',
                    Colors.blue,
                    NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(totalProducto),
                  ),
                if (totalVisita > 0)
                  _buildLeyendaConValor(
                    'Visitas',
                    Colors.orange,
                    NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(totalVisita),
                  ),
                if (totalSuscripcion > 0)
                  _buildLeyendaConValor(
                    'Suscripciones',
                    Colors.green,
                    NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(totalSuscripcion),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGraficaArea(Map<String, dynamic> datos) {
    final datosPorDia = datos['datosPorDia'] as Map<DateTime, Map<String, double>>;
    final fechasOrdenadas = datosPorDia.keys.toList()..sort();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.area_chart, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Comparativa Acumulada (Área)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Visualización de ingresos y gastos con relleno',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= fechasOrdenadas.length) {
                            return const SizedBox();
                          }
                          final fecha = fechasOrdenadas[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('dd').format(fecha),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    // Línea de ingresos
                    LineChartBarData(
                      spots: fechasOrdenadas.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final fecha = entry.value;
                        final valores = datosPorDia[fecha]!;
                        return FlSpot(idx.toDouble(), valores['ingresos']!);
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                    // Línea de gastos
                    LineChartBarData(
                      spots: fechasOrdenadas.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final fecha = entry.value;
                        final valores = datosPorDia[fecha]!;
                        return FlSpot(idx.toDouble(), valores['gastos']!);
                      }).toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLeyenda('Ingresos', Colors.green),
                const SizedBox(width: 24),
                _buildLeyenda('Gastos', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricasAdicionales(Map<String, dynamic> datos) {
    final formatoMoneda = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'Métricas Adicionales',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildMetricaCard(
                    'Promedio Diario',
                    formatoMoneda.format(datos['promedioGananciasDia']),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricaCard(
                    'Transacciones',
                    '${datos['cantidadIngresos'] + datos['cantidadGastos']}',
                    Icons.receipt_long,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricaCard(
                    'Ing/Día',
                    formatoMoneda.format(datos['promedioIngresosDia']),
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricaCard(
                    'Gas/Día',
                    formatoMoneda.format(datos['promedioGastosDia']),
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricaCard(String titulo, String valor, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLeyenda(String texto, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(texto),
      ],
    );
  }
  
  Widget _buildLeyendaConValor(String texto, Color color, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(texto),
            ],
          ),
          Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  double _calcularMaxY(Map<DateTime, Map<String, double>> datosPorDia) {
    double max = 0;
    for (final valores in datosPorDia.values) {
      final maxValor = valores['ingresos']! > valores['gastos']! 
        ? valores['ingresos']! 
        : valores['gastos']!;
      if (maxValor > max) max = maxValor;
    }
    return (max * 1.2).ceilToDouble();
  }
}
