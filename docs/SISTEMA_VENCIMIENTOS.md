# 📅 Sistema de Control de Vencimientos - Dancor Sport Gym

## 🎯 Nuevos Campos en la Base de Datos

### Tabla `ingresos` - Campos Agregados:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `fecha_inicio` | DATE | Fecha en que inicia la suscripción |
| `fecha_vencimiento` | DATE | Fecha en que vence la suscripción |
| `incluye_inscripcion` | BOOLEAN | Si la mensualidad incluye inscripción ($150 extra) |
| `telefono` | TEXT | Teléfono de contacto del cliente |
| `notas` | TEXT | Notas adicionales sobre el cliente o pago |

## 📊 Lógica de Vencimientos

### Visita ($40)
- **Duración:** 1 día
- **fecha_inicio:** Fecha actual
- **fecha_vencimiento:** Mismo día
- **nombre:** No requerido

### Semana ($180)
- **Duración:** 7 días
- **fecha_inicio:** Fecha de registro
- **fecha_vencimiento:** fecha_inicio + 7 días
- **nombre:** REQUERIDO

### Quincena ($260)
- **Duración:** 15 días
- **fecha_inicio:** Fecha de registro
- **fecha_vencimiento:** fecha_inicio + 15 días
- **nombre:** REQUERIDO

### Mensualidad ($400 + $150 inscripción opcional)
- **Duración:** 30 días
- **fecha_inicio:** Fecha de registro
- **fecha_vencimiento:** fecha_inicio + 30 días
- **nombre:** REQUERIDO
- **incluye_inscripcion:** TRUE si pagó inscripción

### Otros (variable)
- **fecha_inicio:** NULL
- **fecha_vencimiento:** NULL
- **nombre:** Opcional

## 🔍 Consultas Útiles de Supabase

### 1. Ver Suscripciones Activas
```sql
SELECT 
    nombre, 
    tipo, 
    monto,
    fecha_inicio, 
    fecha_vencimiento, 
    telefono
FROM ingresos 
WHERE fecha_vencimiento >= CURRENT_DATE 
AND tipo IN ('semana', 'quincena', 'mensualidad')
ORDER BY fecha_vencimiento ASC;
```

### 2. Alertas de Vencimiento Próximo (3 días)
```sql
SELECT 
    nombre, 
    tipo, 
    fecha_vencimiento, 
    telefono,
    (fecha_vencimiento - CURRENT_DATE) as dias_restantes
FROM ingresos 
WHERE fecha_vencimiento BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '3 days'
AND tipo IN ('semana', 'quincena', 'mensualidad')
ORDER BY fecha_vencimiento ASC;
```

### 3. Suscripciones Vencidas
```sql
SELECT 
    nombre, 
    tipo, 
    fecha_vencimiento, 
    telefono,
    (CURRENT_DATE - fecha_vencimiento) as dias_vencidos
FROM ingresos 
WHERE fecha_vencimiento < CURRENT_DATE 
AND tipo IN ('semana', 'quincena', 'mensualidad')
ORDER BY fecha_vencimiento DESC;
```

### 4. Buscar Cliente por Nombre
```sql
SELECT * FROM ingresos 
WHERE nombre ILIKE '%juan%' 
ORDER BY fecha DESC;
```

### 5. Historial Completo de un Cliente
```sql
SELECT 
    concepto, 
    monto, 
    fecha, 
    fecha_inicio, 
    fecha_vencimiento, 
    tipo,
    incluye_inscripcion
FROM ingresos 
WHERE nombre = 'Juan Pérez'
ORDER BY fecha DESC;
```

### 6. Clientes con Suscripción Activa Hoy
```sql
SELECT 
    nombre,
    tipo,
    telefono,
    fecha_vencimiento
FROM ingresos
WHERE CURRENT_DATE BETWEEN fecha_inicio AND fecha_vencimiento
AND tipo IN ('semana', 'quincena', 'mensualidad')
ORDER BY nombre;
```

### 7. Renovaciones del Mes
```sql
SELECT 
    COUNT(*) as total_renovaciones,
    tipo,
    SUM(monto) as ingresos_totales
FROM ingresos
WHERE DATE_TRUNC('month', fecha) = DATE_TRUNC('month', CURRENT_TIMESTAMP)
AND tipo IN ('semana', 'quincena', 'mensualidad')
GROUP BY tipo;
```

## 📱 Implementación en Flutter

### Ejemplo de Cómo Guardar con Vencimiento:

```dart
Future<void> agregarIngresoConVencimiento(Ingreso ingreso) async {
  DateTime fechaInicio = DateTime.now();
  DateTime fechaVencimiento;
  
  // Calcular fecha de vencimiento según el tipo
  switch (ingreso.tipo) {
    case 'visita':
      fechaVencimiento = fechaInicio;
      break;
    case 'semana':
      fechaVencimiento = fechaInicio.add(Duration(days: 7));
      break;
    case 'quincena':
      fechaVencimiento = fechaInicio.add(Duration(days: 15));
      break;
    case 'mensualidad':
      fechaVencimiento = fechaInicio.add(Duration(days: 30));
      break;
    default:
      fechaVencimiento = fechaInicio; // Para "otros"
  }
  
  // Guardar en Supabase con las fechas calculadas
  await supabase.from('ingresos').insert({
    'concepto': ingreso.concepto,
    'monto': ingreso.monto,
    'fecha': fechaInicio.toIso8601String(),
    'nombre': ingreso.nombre,
    'tipo': ingreso.tipo,
    'fecha_inicio': fechaInicio.toIso8601String().split('T')[0],
    'fecha_vencimiento': fechaVencimiento.toIso8601String().split('T')[0],
    'incluye_inscripcion': ingreso.incluirInscripcion,
    'telefono': ingreso.telefono,
  });
}
```

## 🎨 Ideas para la Interfaz de Usuario

### 1. Panel de Clientes Activos
- Lista de clientes con suscripción vigente
- Badge mostrando días restantes
- Color verde: más de 7 días
- Color amarillo: 3-7 días
- Color rojo: menos de 3 días

### 2. Alertas de Vencimiento
- Notificación diaria de vencimientos próximos
- Lista de clientes a renovar
- Botón rápido para llamar (usando el teléfono guardado)

### 3. Historial de Cliente
- Buscar por nombre
- Ver todas sus suscripciones anteriores
- Total gastado
- Última renovación

### 4. Estadísticas
- Clientes activos hoy
- Renovaciones del mes
- Tasa de renovación
- Ingresos por tipo de suscripción

## 📝 Recomendaciones

1. **Recordatorios Automáticos:**
   - Crear una vista/función que muestre vencimientos del día
   - Agregar una pantalla de "Renovaciones Pendientes"

2. **Historial de Cliente:**
   - Poder ver cuántas veces ha renovado un cliente
   - Calcular cliente más frecuente

3. **Reportes:**
   - Clientes que no han renovado
   - Promedio de renovaciones por cliente
   - Ingresos por tipo de suscripción

4. **Funcionalidades Futuras:**
   - Sistema de notificaciones push
   - Envío de SMS de recordatorio
   - Descuentos por renovación anticipada
   - Paquetes especiales

## 🔔 Ejemplo de Sistema de Alertas

### Función para Obtener Vencimientos del Día:
```sql
CREATE OR REPLACE FUNCTION vencimientos_hoy()
RETURNS TABLE(
    nombre TEXT,
    tipo TEXT,
    telefono TEXT,
    fecha_vencimiento DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT i.nombre, i.tipo, i.telefono, i.fecha_vencimiento
    FROM ingresos i
    WHERE i.fecha_vencimiento = CURRENT_DATE
    AND i.tipo IN ('semana', 'quincena', 'mensualidad')
    ORDER BY i.nombre;
END;
$$ LANGUAGE plpgsql;

-- Uso: SELECT * FROM vencimientos_hoy();
```

## ✅ Checklist de Implementación

- [x] Agregar campos de vencimiento a la BD
- [x] Crear índices para búsquedas rápidas
- [x] Documentar consultas útiles
- [ ] Actualizar modelos de Flutter
- [ ] Implementar cálculo automático de vencimientos
- [ ] Crear pantalla de clientes activos
- [ ] Implementar sistema de alertas
- [ ] Agregar búsqueda de clientes
- [ ] Crear reportes de renovaciones

---

**Nota:** Con estos cambios ahora puedes:
1. Saber exactamente cuándo vence cada suscripción
2. Ver qué clientes tienen acceso activo al gimnasio
3. Recibir alertas de renovaciones próximas
4. Llevar un historial completo de cada cliente
5. Contactar clientes usando el teléfono guardado
