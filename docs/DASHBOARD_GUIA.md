# 📊 Dashboard de Análisis - Dancor Sport Gym

## Descripción General

El **Dashboard** es una nueva pantalla de análisis visual que permite ver el estado financiero del gimnasio a través de múltiples gráficas interactivas y métricas clave.

---

## 🎯 Características Principales

### 1. **Selector de Periodo**
- **Última Semana**: Datos de los últimos 7 días
- **Últimas 2 Semanas**: Datos de los últimos 14 días
- **Último Mes**: Datos del último mes completo

### 2. **Resumen de Ganancias**
Card principal que muestra:
- ✅ **Total de Ingresos**: Suma de todos los ingresos del periodo
- ❌ **Total de Gastos**: Suma de todos los gastos del periodo
- 💰 **Ganancia Neta**: Diferencia entre ingresos y gastos (con indicador visual verde/rojo)

---

## 📈 Tipos de Gráficas

### 1. **Gráfica de Barras - Ingresos vs Gastos**
- **Tipo**: Barras verticales agrupadas
- **Propósito**: Comparar ingresos y gastos día por día
- **Colores**:
  - 🟢 Verde para ingresos
  - 🔴 Rojo para gastos
- **Interactividad**: Tooltip muestra fecha y monto al tocar cada barra
- **Leyenda**: Indica qué representa cada color

### 2. **Gráfica de Línea - Tendencia de Ganancias**
- **Tipo**: Línea curva con área rellena
- **Propósito**: Mostrar la evolución de la ganancia neta (ingresos - gastos)
- **Color**: 🟣 Púrpura
- **Características**:
  - Línea suavizada (curva)
  - Puntos en cada día
  - Área sombreada debajo de la línea
  - Tooltip con fecha y ganancia al tocar

### 3. **Gráfica Circular (Pastel) - Distribución de Ingresos**
- **Tipo**: Gráfica de pastel (pie chart)
- **Propósito**: Mostrar el porcentaje de cada tipo de ingreso
- **Categorías**:
  - 🔵 **Productos**: Venta de productos (bebidas, proteína, etc.)
  - 🟠 **Visitas**: Ingresos por visitas únicas
  - 🟢 **Suscripciones**: Semana, quincena, mensualidad
- **Características**:
  - Porcentaje mostrado en cada sección
  - Espacio central (donut chart)
  - Leyenda con monto total por categoría

### 4. **Gráfica de Área - Comparativa Acumulada**
- **Tipo**: Gráfica de línea con área rellena (dos series)
- **Propósito**: Comparar visualmente ingresos vs gastos con relleno
- **Colores**:
  - 🟢 Verde para ingresos (área sombreada)
  - 🔴 Rojo para gastos (área sombreada)
- **Características**:
  - Dos líneas superpuestas
  - Áreas con transparencia
  - Fácil identificación de días con más ingresos/gastos

---

## 📊 Métricas Adicionales

Card de métricas que muestra:

1. **💼 Promedio Diario de Ganancias**
   - Ganancia neta promedio por día del periodo
   - Color: Azul

2. **🧾 Total de Transacciones**
   - Suma de ingresos + gastos registrados
   - Color: Naranja

3. **📈 Promedio de Ingresos por Día**
   - Ingreso promedio diario
   - Color: Verde

4. **📉 Promedio de Gastos por Día**
   - Gasto promedio diario
   - Color: Rojo

---

## 🎨 Características de UI/UX

### Diseño
- **Cards elevados**: Cada gráfica en su propia tarjeta con sombra
- **Iconos descriptivos**: Cada sección tiene un icono que representa su contenido
- **Títulos y subtítulos**: Explicación clara de qué representa cada gráfica
- **Espaciado consistente**: 24px entre secciones

### Interactividad
- **Pull to Refresh**: Desliza hacia abajo para recargar datos
- **Tooltips**: Toca cualquier punto/barra para ver detalles
- **Menú de periodo**: Selector en el AppBar para cambiar el rango de fechas
- **Badge "NUEVO"**: Indicador en el drawer para destacar la funcionalidad

### Colores del Sistema
- **Verde** (`Colors.green`): Ingresos, ganancias positivas
- **Rojo** (`Colors.red`): Gastos, pérdidas
- **Púrpura** (`Colors.purple`): Tendencias, ganancia neta
- **Azul** (`Colors.blue`): Productos, métricas generales
- **Naranja** (`Colors.orange`): Visitas, transacciones
- **Teal** (`Colors.teal`): Gráficas de área
- **Índigo** (`Colors.indigo`): Métricas adicionales

---

## 🔢 Cálculos Realizados

### Totales
```dart
totalIngresos = Σ(monto de todos los ingresos del periodo)
totalGastos = Σ(monto de todos los gastos del periodo)
gananciaTotal = totalIngresos - totalGastos
```

### Promedios Diarios
```dart
promedioIngresosDia = totalIngresos / cantidadDías
promedioGastosDia = totalGastos / cantidadDías
promedioGananciasDia = gananciaTotal / cantidadDías
```

### Por Categoría
```dart
totalProducto = Σ(ingresos donde tipo == 'producto')
totalVisita = Σ(ingresos donde tipo == 'visita')
totalSuscripcion = Σ(ingresos donde tipo in ['semana', 'quincena', 'mensualidad'])
```

### Datos por Día
Para cada día del periodo:
```dart
datosPorDia[fecha] = {
  'ingresos': Σ(monto de ingresos en esa fecha),
  'gastos': Σ(monto de gastos en esa fecha)
}
```

---

## 📱 Acceso al Dashboard

### Desde el Drawer
1. Abre el menú lateral (hamburguesa ☰)
2. En la sección **ANÁLISIS**
3. Toca **"Dashboard"** con badge "NUEVO"

### Desde Rutas
```dart
Navigator.pushNamed(context, '/dashboard');
```

---

## 🔄 Actualización de Datos

- **Automática**: Al cambiar el periodo seleccionado
- **Manual**: Pull-to-refresh (deslizar hacia abajo)
- **Reactiva**: Usa FutureBuilder para cargar datos asíncronos

---

## 📦 Dependencias Utilizadas

### fl_chart ^0.69.0
- Librería profesional para gráficas en Flutter
- Soporta: Barras, Líneas, Pastel, Área, etc.
- Altamente personalizable
- Interactiva (tooltips, gestos)

### intl ^0.20.2
- Formateo de fechas: `DateFormat('dd/MMM')`
- Formateo de moneda: `NumberFormat.currency(symbol: '\$', decimalDigits: 2)`

---

## 🎯 Casos de Uso

### Para el Administrador
- ✅ Ver rápidamente si el gimnasio está siendo rentable
- ✅ Identificar días con más/menos actividad
- ✅ Entender qué fuente de ingresos es más importante
- ✅ Detectar tendencias (¿están aumentando las ganancias?)
- ✅ Comparar ingresos vs gastos visualmente

### Para Toma de Decisiones
- 📊 Si los productos no generan ingresos, considerar cambiar el inventario
- 📊 Si las visitas son altas, promocionar suscripciones
- 📊 Si los gastos están muy altos, buscar formas de reducirlos
- 📊 Si hay tendencia a la baja, implementar estrategias de marketing

---

## 🚀 Mejoras Futuras Sugeridas

1. **Filtros Avanzados**
   - Por tipo específico (solo productos, solo suscripciones)
   - Por rango de fechas personalizado

2. **Exportar Reportes**
   - Generar PDF con las gráficas
   - Compartir por WhatsApp/Email

3. **Comparativas**
   - Comparar este mes vs mes anterior
   - Comparar con mismo periodo del año pasado

4. **Predicciones**
   - Proyección de ingresos para el próximo mes
   - Alertas de tendencias negativas

5. **Más Gráficas**
   - Gráfica de radar (comparar múltiples métricas)
   - Gráfica de burbujas (3 dimensiones de datos)
   - Heatmap de días más/menos activos

---

## 🐛 Solución de Problemas

### "No hay datos para mostrar"
- ✅ Verifica que hay transacciones en el periodo seleccionado
- ✅ Cambia el periodo a uno más amplio (ej: último mes)

### "La gráfica circular está vacía"
- ✅ Verifica que hay ingresos registrados
- ✅ Asegúrate de que los ingresos tienen tipos válidos

### "Los números no coinciden"
- ✅ Pull-to-refresh para recargar datos
- ✅ Verifica que la BD está actualizada

---

## 💡 Tips de Uso

1. **Usa el periodo correcto**: 
   - Semana para análisis rápido
   - Mes para tendencias generales

2. **Observa las áreas rellenas**:
   - En la gráfica de área, si el verde está por encima del rojo = ¡Estás ganando!

3. **Revisa los promedios diarios**:
   - Te dicen cuánto necesitas ganar cada día para mantener el negocio

4. **Combina con otros reportes**:
   - Usa el Dashboard para visión general
   - Usa "Ver Ingresos/Gastos" para detalles específicos

---

## 📝 Ejemplo de Interpretación

### Escenario: Dashboard de la Última Semana

**Resumen de Ganancias:**
- Total Ingresos: $5,450.00
- Total Gastos: $1,200.00
- Ganancia Neta: $4,250.00 ✅ (Verde = Positivo)

**Gráfica de Barras:**
- Lunes: Ingresos altos, pocos gastos
- Martes: Día flojo
- Viernes: Pico de ingresos (día de pago)

**Gráfica Circular:**
- Suscripciones: 65% ($3,542.50) ← Principal fuente
- Visitas: 25% ($1,362.50)
- Productos: 10% ($545.00) ← Oportunidad de mejora

**Métricas:**
- Promedio Diario: $607.14/día
- 47 Transacciones totales
- Promedio Ingresos/Día: $778.57
- Promedio Gastos/Día: $171.43

**Conclusión:**
✅ El negocio es rentable
✅ Las suscripciones son el motor principal
⚠️ Los productos generan poco ingreso (considerar promociones)

---

## 🎓 Tecnologías y Conceptos

- **FutureBuilder**: Carga asíncrona de datos
- **Provider**: Acceso al TransaccionController
- **StatefulWidget**: Manejo de estado del periodo seleccionado
- **fl_chart**: Librería de gráficas profesional
- **Material Design 3**: Cards, colores, elevaciones
- **Responsive**: Se adapta a diferentes tamaños de pantalla

---

**Versión:** 2.1  
**Fecha:** Noviembre 2024  
**Autor:** Dancor Sport Gym Development Team
