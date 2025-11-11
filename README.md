# 💰 Gestor de Caja - Dancor Sport Gym



<div align="center">Aplicación móvil Flutter para la gestión completa de ingresos y gastos del gimnasio Dancor Sport Gym.



![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue?logo=flutter)## 📋 Descripción

![Dart](https://img.shields.io/badge/Dart-3.0-blue?logo=dart)

![License](https://img.shields.io/badge/License-Private-green)

**Dancor Sport Gym - Control de Caja** es una aplicación móvil desarrollada en Flutter que permite al dueño del gimnasio llevar un control detallado de todos los ingresos y gastos diarios. La aplicación es completamente funcional sin necesidad de conexión a internet, almacenando todos los datos localmente en el dispositivo mediante SQLite.



**Aplicación móvil profesional para control completo de ingresos y gastos de gimnasios**## ✨ Características Principales



[📱 Características](#-características-principales) • [🚀 Instalación](#-instalación-rápida) • [💡 Uso](#-cómo-usar) • [📚 Docs](#-documentación)### 📈 Gestión de Ingresos

- **Tipos de ingreso predefinidos:**

</div>  - Visita: $40 (por 1 día)

  - Semana: $180

---  - Quincena: $260

  - Mensualidad: $400 (con opción de agregar inscripción de $150)

## 📱 Descripción  - Otros ingresos variables (ventas varias)



**Gestor de Caja** es una aplicación Flutter completa y profesional para gestionar las finanzas diarias de tu gimnasio. Controla ventas de productos, visitas, suscripciones con vencimientos automáticos, gastos y genera reportes detallados.- **Registro de información:**

  - Concepto

### ✨ Características Principales  - Monto

  - Fecha y hora automática

#### 💳 **4 Tipos de Ingresos**  - Nombre del cliente (requerido para semana, quincena y mensualidad)

- **🛍️ Venta de Productos** - Suplementos, bebidas (precio variable)

- **⏰ Venta de Visitas** - Acceso de 1 día ($40) - Registro en 1 clic### 📉 Gestión de Gastos

- **💪 Suscripciones** - Control completo con fechas de vencimiento automáticas:- Registro de gastos con concepto libre

  - 📅 Semana: $180 (7 días)- Conceptos frecuentes sugeridos (bebidas, limpieza, mantenimiento, etc.)

  - 📆 Quincena: $260 (15 días)- Monto personalizable

  - 🗓️ Mensualidad: $400 (30 días) + Inscripción $150 opcional- Fecha y hora automática de registro

- **📝 Gastos** - Control de egresos del negocio

### 📊 Dashboard Principal

#### 🔧 **CRUD Completo e Intuitivo** ⭐ NUEVO- **Resumen del día actual:**

- ✅ **Crear** - Registra transacciones con formularios claros  - Total de ingresos

- ✏️ **Editar** - Modifica ingresos/gastos fácilmente  - Total de gastos

- 🗑️ **Eliminar** - Borra con confirmación de seguridad  - Resultado del día (ingresos - gastos)

- 👁️ **Ver** - Lista visual con todos los detalles

- 📋 **Menú contextual** - Acciones rápidas con 3 puntos (⋮)- **Lista de movimientos:**

  - Visualización clara de todos los ingresos (verde) y gastos (rojo)

#### 📊 **Control de Suscripciones Inteligente**  - Detalles completos de cada transacción

- ✅ Cálculo automático de fechas de vencimiento  - Opción para eliminar movimientos

- ✅ Almacena datos del cliente (nombre, teléfono, notas)

- ✅ Visualización de fecha de vencimiento en cada registro- **Funcionalidades adicionales:**

- ✅ Consultas SQL para alertas de renovación  - Selección de fecha para consultar días anteriores

- ✅ Historial completo por cliente  - Botón "Finalizar Día" para crear cierres diarios

  - Actualización en tiempo real

#### 💾 **Base de Datos Dual**

- **Local:** SQLite para funcionamiento 100% offline### 📑 Reportes Diarios

- **Nube:** Integración con Supabase (PostgreSQL) opcional- Listado de todos los cierres diarios

- **Migración:** Scripts SQL incluidos y documentados- Vista expandible con desglose completo:

- **Versión:** Actualización automática de schema  - Ingresos totales del día

  - Gastos totales del día

#### 📈 **Reportes y Cierres**  - Resultado final

- Resumen diario con totales visuales- Indicadores visuales de resultados positivos/negativos

- Cierres de caja automáticos

- Navegación por fechas## 🏗️ Arquitectura del Proyecto

- Indicadores de resultado positivo/negativo

El proyecto sigue una arquitectura modular tipo MVC/MVVM:

---

```

## 🚀 Instalación Rápidalib/

├── models/              # Modelos de datos

### Requisitos│   ├── ingreso.dart

- Flutter SDK 3.9.2 o superior│   ├── gasto.dart

- Dart 3.0+│   └── cierre_dia.dart

- Android Studio / VS Code├── services/            # Capa de datos

- Dispositivo Android (API 21+) o emulador│   └── database_service.dart

├── controllers/         # Lógica de negocio

### Pasos│   ├── transaccion_controller.dart

│   └── cierre_controller.dart

```bash├── views/              # Pantallas de la aplicación

# 1. Clonar repositorio│   ├── home_screen.dart

git clone https://github.com/tu-usuario/dancorsportgym.git│   ├── nuevo_ingreso_screen.dart

cd dancorsportgym│   ├── nuevo_gasto_screen.dart

│   └── reporte_screen.dart

# 2. Instalar dependencias├── widgets/            # Componentes reutilizables

flutter pub get│   ├── resumen_card.dart

│   ├── transaccion_item.dart

# 3. Ejecutar│   ├── boton_primario.dart

flutter run│   └── empty_state.dart

├── utils/              # Utilidades y constantes

# 4. Compilar APK (producción)│   └── constants.dart

flutter build apk --release└── main.dart           # Punto de entrada

``````



📦 **APK generado en:** `build/app/outputs/flutter-apk/app-release.apk`## 🛠️ Tecnologías Utilizadas



---- **Flutter 3.x** - Framework de desarrollo

- **Dart** - Lenguaje de programación

## 💡 Cómo Usar- **SQLite** - Base de datos local (sqflite)

- **Provider** - Gestión de estado

### 🆕 Registrar Transacciones- **intl** - Formateo de fechas y monedas



| Acción | Pasos |## 📱 Requisitos

|--------|-------|

| **Venta Producto** | **+ Ingreso** → 🛍️ Venta Producto → Ingresar nombre y precio → Guardar |- Flutter SDK 3.9.2 o superior

| **Visita ($40)** | **+ Ingreso** → ⏰ Venta Visita → **Registrar** (1 clic) |- Dart SDK 3.9.2 o superior

| **Suscripción** | **+ Ingreso** → 💳 Suscripción → Datos del cliente → Tipo (Semana/Quincena/Mes) → ☑️ Inscripción (opcional) → Guardar |- Android Studio / VS Code

| **Gasto** | **+ Gasto** → Concepto y monto → Guardar |- Dispositivo Android con API 30+ o emulador



### ✏️ Editar/Eliminar Transacciones ⭐ NUEVO## 🚀 Instalación y Configuración



1. En la lista, localiza la transacción### 1. Clonar el repositorio (si aplica)

2. Toca los **tres puntos (⋮)** al lado derecho```bash

3. Selecciona:git clone [url-del-repositorio]

   - **✏️ Editar** - Modificar concepto, monto, datos del clientecd dancorsportgym

   - **🗑️ Eliminar** - Borrar con confirmación```



### 📊 Ver Reportes### 2. Instalar dependencias

```powershell

1. Toca el ícono **📊** en la barra superiorflutter pub get

2. Revisa cierres diarios anteriores```

3. Toca cualquier fecha para ver desglose completo

### 3. Verificar la instalación

---```powershell

flutter doctor

## 📊 Estructura del Proyecto```



```### 4. Ejecutar en modo desarrollo

lib/```powershell

├── models/              # Modelos de datos# En un emulador o dispositivo conectado

│   ├── ingreso.dart    # Ingreso con suscripcionesflutter run

│   ├── gasto.dart      # Gasto```

│   └── cierre_dia.dart # Cierre diario

│## 📦 Compilar para Producción

├── views/              # Pantallas (UI)

│   ├── home_screen.dart               # Dashboard principal### Generar APK para Android

│   ├── seleccionar_ingreso_screen.dart  # Selector de tipo```powershell

│   ├── nuevo_producto_screen.dart       # Producto# APK de producción

│   ├── nuevo_visita_screen.dart         # Visitaflutter build apk --release

│   ├── nuevo_suscripcion_screen.dart    # Suscripción

│   ├── editar_ingreso_screen.dart       # ⭐ Editar ingreso# APK dividido por arquitectura (recomendado)

│   ├── editar_gasto_screen.dart         # ⭐ Editar gastoflutter build apk --split-per-abi --release

│   ├── nuevo_gasto_screen.dart          # Gasto```

│   └── reporte_screen.dart              # Reportes

│El APK generado se encontrará en:

├── controllers/        # Lógica de negocio```

│   ├── transaccion_controller.dart  # ⭐ Con CRUD completobuild/app/outputs/flutter-apk/app-release.apk

│   └── cierre_controller.dart       # Cierres```

│

├── services/           # Capa de datos### Generar App Bundle (para Google Play)

│   └── database_service.dart  # SQLite (v2)```powershell

│flutter build appbundle --release

├── widgets/            # Componentes reutilizables```

│   ├── resumen_card.dart       # Tarjeta de resumen

│   ├── transaccion_item.dart   # ⭐ Item con editar/eliminar## 🎨 Diseño de la Interfaz

│   ├── boton_primario.dart     # Botón personalizado

│   └── empty_state.dart        # Estado vacíoLa aplicación cuenta con:

│- **Diseño Material 3** moderno y limpio

├── utils/              # Utilidades- **Colores intuitivos:**

│   └── constants.dart   # Constantes, precios, formateo  - Verde para ingresos

│  - Rojo para gastos

└── main.dart           # Punto de entrada  - Azul como color principal

- **Tipografía legible** y tamaños de fuente apropiados

docs/                   # 📚 Documentación organizada ⭐- **Iconos claros** que facilitan la navegación

├── GUIA_ACTUALIZACION.md      # Guía completa- **Botones grandes** para facilitar la interacción

├── SISTEMA_VENCIMIENTOS.md    # Fechas de vencimiento- **Feedback visual** en todas las acciones

├── RESUMEN_VISUAL.md          # Mockups de UI

├── CAMBIOS_COMPLETADOS.md     # Changelog detallado## 💾 Base de Datos

├── IMPLEMENTACION.md          # Detalles técnicos

├── INICIO_RAPIDO.md           # Quick start### Estructura de Tablas

└── CONFIGURAR_ICONO.md        # Setup del icono

```#### Tabla: ingresos

```sql

---- id (INTEGER PRIMARY KEY AUTOINCREMENT)

- concepto (TEXT NOT NULL)

## 🗄️ Base de Datos- monto (REAL NOT NULL)

- fecha (TEXT NOT NULL)

### SQLite Local (v2)- nombre (TEXT)

- tipo (TEXT NOT NULL)

**Tabla `ingresos`:**```

```sql

id, concepto, monto, fecha, nombre, tipo,#### Tabla: gastos

fecha_inicio, fecha_vencimiento, incluye_inscripcion,```sql

telefono, notas- id (INTEGER PRIMARY KEY AUTOINCREMENT)

```- concepto (TEXT NOT NULL)

- monto (REAL NOT NULL)

**Tabla `gastos`:**- fecha (TEXT NOT NULL)

```sql```

id, concepto, monto, fecha

```#### Tabla: cierres_diarios

```sql

**Tabla `cierres_diarios`:**- id (INTEGER PRIMARY KEY AUTOINCREMENT)

```sql- fecha (TEXT NOT NULL UNIQUE)

id, fecha, ingresos_totales, gastos_totales, resultado_final- ingresos_totales (REAL NOT NULL)

```- gastos_totales (REAL NOT NULL)

- resultado_final (REAL NOT NULL)

### Supabase (Opcional)```



Para sincronizar con la nube:## 📖 Uso de la Aplicación



1. Crea proyecto en [Supabase](https://supabase.com)### Pantalla Principal (Dashboard)

2. SQL Editor → Ejecuta `MIGRATION_ADD_FIELDS.sql`1. Visualiza el resumen del día actual

3. Configura credenciales2. Consulta la lista de todos los movimientos

3. Usa el botón flotante "+" para agregar ingresos o gastos

Ver: [`docs/GUIA_ACTUALIZACION.md`](docs/GUIA_ACTUALIZACION.md)4. Selecciona otra fecha con el icono de calendario

5. Finaliza el día con el botón "Finalizar Día"

---

### Registrar un Ingreso

## 🎨 Tecnologías1. Presiona el botón flotante "Ingreso" (verde)

2. Selecciona el tipo de ingreso

| Dependencia | Versión | Uso |3. Completa los campos requeridos (nombre si aplica)

|-------------|---------|-----|4. El monto se ajusta automáticamente según el tipo

| **Flutter** | 3.9.2+ | Framework |5. Presiona "Guardar Ingreso"

| **sqflite** | ^2.3.0 | SQLite local |

| **provider** | ^6.1.1 | Estado |### Registrar un Gasto

| **intl** | ^0.19.0 | Formateo |1. Presiona el botón flotante "Gasto" (rojo)

| **path_provider** | ^2.1.1 | Archivos |2. Escribe el concepto o selecciona uno sugerido

3. Ingresa el monto

---4. Presiona "Guardar Gasto"



## 📚 Documentación### Ver Reportes

1. Presiona el icono de reportes en la barra superior

📁 **Carpeta [`docs/`](docs/):**2. Explora los cierres diarios guardados

3. Toca cualquier fecha para ver el desglose completo

| Archivo | Contenido |

|---------|-----------|## 🔧 Mantenimiento y Soporte

| [`GUIA_ACTUALIZACION.md`](docs/GUIA_ACTUALIZACION.md) | ⭐ Guía paso a paso completa |

| [`SISTEMA_VENCIMIENTOS.md`](docs/SISTEMA_VENCIMIENTOS.md) | Explicación de fechas automáticas |### Logs y Depuración

| [`RESUMEN_VISUAL.md`](docs/RESUMEN_VISUAL.md) | Mockups de todas las pantallas |```powershell

| [`CAMBIOS_COMPLETADOS.md`](docs/CAMBIOS_COMPLETADOS.md) | Changelog detallado v2.0 |# Ver logs en tiempo real

| [`INICIO_RAPIDO.md`](docs/INICIO_RAPIDO.md) | Quick start |flutter logs

| [`CONFIGURAR_ICONO.md`](docs/CONFIGURAR_ICONO.md) | Personalizar icono |

# Analizar el código

---flutter analyze

```

## 🆕 Novedades v2.0

### Limpiar caché

### ✏️ **CRUD Completo**```powershell

- ✅ Editar cualquier ingreso o gastoflutter clean

- ✅ Eliminar con doble confirmaciónflutter pub get

- ✅ Validación de datos```

- ✅ Mensajes visuales de éxito/error

## 📄 Licencia

### 🎯 **Mejoras UX**

- ✅ Menú contextual (⋮) en cada transacciónEste proyecto es de uso privado para el gimnasio Dancor Sport Gym.

- ✅ Fecha de vencimiento visible en lista

- ✅ Iconos grandes y colores intuitivos## 👨‍💻 Desarrollo

- ✅ Confirmaciones claras antes de eliminar

- ✅ Tooltips de ayudaDesarrollado con ❤️ usando Flutter



### 📁 **Organización**---

- ✅ Docs reorganizados en carpeta `docs/`

- ✅ README profesional y completo**Nota:** Esta aplicación no requiere conexión a internet y todos los datos se almacenan localmente en el dispositivo. Se recomienda realizar respaldos periódicos de los datos importantes

- ✅ Código limpio y documentado

## Getting Started

---

This project is a starting point for a Flutter application.

## 🐛 Solución de Problemas

A few resources to get you started if this is your first Flutter project:

### Error: Base de datos desactualizada

```bash- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)

flutter clean- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

flutter run

# La app actualizará automáticamente de v1 a v2For help getting started with Flutter development, view the

```[online documentation](https://docs.flutter.dev/), which offers tutorials,

samples, guidance on mobile development, and a full API reference.

### Error: No se pueden editar transacciones
**Causa:** Transacción sin ID  
**Solución:** Solo se pueden editar registros guardados

### Fechas de vencimiento incorrectas
**Solución:** Ejecuta `MIGRATION_ADD_FIELDS.sql` en Supabase

---

## 📄 Licencia

Proyecto privado - Dancor Sport Gym  
Todos los derechos reservados

---

## 👨‍💻 Contacto

📧 Email: [contacto@dancorsportgym.com](mailto:contacto@dancorsportgym.com)  
🏋️ Gym: Dancor Sport Gym  

---

<div align="center">

## 🎉 ¡Gracias por usar Gestor de Caja!

**Gestiona tu gimnasio como un profesional 💪**

[⬆️ Volver arriba](#-gestor-de-caja---dancor-sport-gym)

</div>
