# 🚀 GUÍA COMPLETA DE ACTUALIZACIÓN - Gestor de Caja

## ✅ PASO 1: Ejecutar Script SQL en Supabase

### Opción A: Copiar y Pegar el Script
1. Abre tu proyecto en [Supabase Dashboard](https://supabase.com)
2. Ve a **SQL Editor** en el menú lateral
3. Abre el archivo `MIGRATION_ADD_FIELDS.sql` de este proyecto
4. Copia todo el contenido
5. Pégalo en el editor SQL de Supabase
6. Haz clic en **Run** o presiona `Ctrl + Enter`
7. Verifica que aparezca: ✅ **Migración completada exitosamente!**

### Verificar que se Crearon los Campos:
```sql
-- Ejecuta esto en Supabase para verificar
SELECT 
    column_name, 
    data_type 
FROM information_schema.columns
WHERE table_name = 'ingresos'
ORDER BY ordinal_position;
```

Deberías ver estas columnas nuevas:
- ✅ `fecha_inicio` (date)
- ✅ `fecha_vencimiento` (date)
- ✅ `incluye_inscripcion` (boolean)
- ✅ `telefono` (text)
- ✅ `notas` (text)

---

## 📱 PASO 2: Configurar el Icono de la App

### 1. Preparar tu Imagen
- Crea un icono cuadrado (mínimo 1024x1024 px)
- Formato: PNG con fondo transparente
- Diseño simple y reconocible
- Colores: Azul (#1976D2) para mantener la paleta

### 2. Guardar el Icono
Coloca tu archivo de imagen en:
```
assets/icons/app_icon.png
```

### 3. Generar los Iconos
Abre una terminal en el proyecto y ejecuta:
```powershell
flutter pub get
flutter pub run flutter_launcher_icons
```

Esto generará automáticamente todos los tamaños de iconos para Android e iOS.

---

## 🔄 PASO 3: Actualizar la Base de Datos Local (SQLite)

La app actualizará automáticamente la base de datos local cuando la abras por primera vez después de estos cambios.

**¿Qué hace automáticamente?**
- Agrega los campos de suscripción a la tabla `ingresos`
- Preserva todos tus datos existentes
- Versión de BD: 1 → 2

**Si necesitas forzar la actualización:**
```powershell
# Desinstala la app del dispositivo/emulador
flutter clean
flutter pub get
flutter run
```

---

## 🎨 PASO 4: Nuevas Funcionalidades de la App

### Pantalla de Selección de Ingreso
Al presionar el botón **"+ Ingreso"** ahora verás 3 opciones:

#### 1. **Venta Producto** 💼
- Para registrar ventas de suplementos, bebidas, etc.
- **Campos:**
  - Nombre del producto
  - Precio
- **NO requiere:** nombre de cliente, fechas de vencimiento

#### 2. **Venta Visita** ⏰
- Acceso de 1 día al gimnasio
- **Precio fijo:** $40.00
- **Solo 1 clic** para registrar
- **NO requiere:** datos del cliente

#### 3. **Suscripción** 💳
- Opciones con radio buttons:
  - 🗓️ **Semana:** $180 (7 días)
  - 📅 **Quincena:** $260 (15 días)
  - 📆 **Mensualidad:** $400 (30 días)
- **Campos obligatorios:**
  - ✅ Nombre del cliente
- **Campos opcionales:**
  - 📞 Teléfono (10 dígitos)
  - 📝 Notas
  - ☑️ Incluir inscripción (+$150)

### Cálculo Automático de Fechas
La app ahora calcula automáticamente:
- **Fecha de inicio:** Fecha actual
- **Fecha de vencimiento:** Inicio + duración del plan
- **Ejemplo:**
  - Cliente se registra hoy (11/11/2025)
  - Elige **Semana**
  - Vence: 18/11/2025

---

## 📊 PASO 5: Consultas Útiles en Supabase

### Ver Clientes con Suscripción Activa Hoy
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

### Alerta: Renovaciones Próximas (3 días)
```sql
SELECT 
    nombre,
    tipo,
    telefono,
    fecha_vencimiento,
    (fecha_vencimiento - CURRENT_DATE) as dias_restantes
FROM ingresos
WHERE fecha_vencimiento BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '3 days'
AND tipo IN ('semana', 'quincena', 'mensualidad')
ORDER BY fecha_vencimiento;
```

### Suscripciones Vencidas
```sql
SELECT 
    nombre,
    tipo,
    telefono,
    fecha_vencimiento,
    (CURRENT_DATE - fecha_vencimiento) as dias_vencidos
FROM ingresos
WHERE fecha_vencimiento < CURRENT_DATE
AND tipo IN ('semana', 'quincena', 'mensualidad')
ORDER BY fecha_vencimiento DESC;
```

---

## 🛠️ PASO 6: Compilar la App

### Limpiar y Compilar
```powershell
# Limpiar proyecto
flutter clean

# Instalar dependencias
flutter pub get

# Compilar APK de debug para probar
flutter build apk --debug

# Compilar APK de release para producción
flutter build apk --release
```

### Ubicación del APK:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🎯 RESUMEN DE CAMBIOS

### Base de Datos ✅
- ✅ Campos de suscripción agregados
- ✅ Índices para búsquedas rápidas
- ✅ Migración automática de SQLite

### Interfaz de Usuario ✅
- ✅ 4 botones de ingreso diferentes
- ✅ Validación de campos según tipo
- ✅ Cálculo automático de vencimientos
- ✅ Diseño modular y limpio

### Funcionalidad ✅
- ✅ Visita no guarda datos del cliente
- ✅ Productos tienen precio variable
- ✅ Suscripciones guardan toda la información
- ✅ Fechas de vencimiento automáticas

### Branding ✅
- ✅ Nombre de app cambiado a **"Gestor de Caja"**
- ✅ Subtítulo: **"Dancor Sport Gym"**
- ✅ Icono personalizable

---

## 🐛 Solución de Problemas

### Error: "Column already exists"
**Solución:** Los campos ya están agregados. Puedes continuar sin problemas.

### Error: La app no muestra los nuevos campos
**Solución:**
```powershell
# Desinstala la app del dispositivo
adb uninstall com.example.dancorsportgym

# Reinstala
flutter run
```

### Error: Icono no cambia
**Solución:**
```powershell
flutter pub run flutter_launcher_icons
flutter clean
flutter run
```

### Error al compilar
**Solución:**
```powershell
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📞 Precios Actuales del Sistema

| Tipo | Precio | Duración | Requiere Nombre |
|------|--------|----------|-----------------|
| **Producto** | Variable | - | ❌ |
| **Visita** | $40 | 1 día | ❌ |
| **Semana** | $180 | 7 días | ✅ |
| **Quincena** | $260 | 15 días | ✅ |
| **Mensualidad** | $400 | 30 días | ✅ |
| **Inscripción** | +$150 | - | ✅ |

---

## ✅ Checklist Final

- [ ] Script SQL ejecutado en Supabase
- [ ] Campos verificados en la BD
- [ ] Icono de app configurado (`app_icon.png`)
- [ ] `flutter pub get` ejecutado
- [ ] `flutter_launcher_icons` ejecutado
- [ ] App compilada sin errores
- [ ] APK generado
- [ ] Probado registro de producto
- [ ] Probado registro de visita
- [ ] Probado registro de suscripción
- [ ] Verificado cálculo de fechas

---

## 🎉 ¡Listo!

Tu app **Gestor de Caja** está completamente actualizada con:
- ✅ Control de vencimientos de suscripciones
- ✅ Datos de clientes organizados
- ✅ 4 tipos diferentes de ingresos
- ✅ Interfaz moderna y funcional
- ✅ Base de datos sincronizada con Supabase

**¡A gestionar tu caja como un profesional! 💪**
