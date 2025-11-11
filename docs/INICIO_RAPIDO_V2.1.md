# 🚀 INICIO RÁPIDO - Versión 2.1

## ✅ Todo está listo para usar

### 📱 Ejecutar la App

```powershell
cd c:\Users\ricky\Documents\Programacion\Flutter\dancorsportgym
flutter run
```

---

## 🎨 Generar Icono de la App

### Paso 1: Preparar imagen
Asegúrate de tener una imagen del logo en:
- **Ruta:** `assets/icons/app_icon.png`
- **Tamaño recomendado:** 1024x1024 px
- **Formato:** PNG con fondo transparente

### Paso 2: Ejecutar generador
```powershell
flutter pub run flutter_launcher_icons
```

---

## 📦 Compilar para Producción

### APK (Android):
```powershell
flutter build apk --release
```

El APK estará en:
`build/app/outputs/flutter-apk/app-release.apk`

### AAB (Google Play):
```powershell
flutter build appbundle --release
```

---

## 🎯 Nuevas Funcionalidades

### 1. **Menú Lateral (Drawer)**
- Desliza desde la izquierda o toca el icono ☰
- Opciones:
  - 📊 Ver Ingresos
  - 💸 Ver Gastos
  - 🎫 Ver Suscripciones
  - ⚠️ Próximos Vencimientos
  - 📈 Reportes

### 2. **Selector de Fecha en Suscripciones**
- Al agregar suscripción, toca la **tarjeta azul** de fecha
- Puedes elegir:
  - **Hoy** (por defecto)
  - **Fecha anterior** (hasta 1 año atrás)

### 3. **Vencimientos Automáticos**
- **Mensualidad:** Mismo día del mes siguiente
  - Ej: Paga 1 agosto → Vence 1 septiembre
- **Quincena:** +15 días
- **Semana:** +7 días

### 4. **Pantalla de Vencimientos**
- Abre el menú → "Próximos Vencimientos"
- Verás:
  - 🚨 Vencidas (rojo)
  - ⚠️ Por vencer en 7 días (naranja)
  - ✅ Activas (verde)
- Contador de días visible en cada suscripción

---

## 🐛 Solución de Problemas

### Error: "App icon not found"
1. Verifica que existe: `assets/icons/app_icon.png`
2. Si no existe, renombra `dancor logo.jpg` a `app_icon.png`
3. Ejecuta: `flutter pub run flutter_launcher_icons`

### Error: "Unable to load asset"
1. Verifica que `pubspec.yaml` tiene:
   ```yaml
   flutter:
     assets:
       - assets/icons/
   ```
2. Ejecuta: `flutter pub get`

### Error de compilación
1. Limpia el proyecto:
   ```powershell
   flutter clean
   flutter pub get
   ```
2. Intenta compilar de nuevo

---

## 📞 Contacto y Soporte

Si encuentras algún problema:
1. Revisa los logs: `flutter run --verbose`
2. Limpia y recompila: `flutter clean && flutter pub get`
3. Verifica versión de Flutter: `flutter doctor`

---

## 🎉 ¡Disfruta la nueva versión!

**Versión:** 2.1  
**Fecha:** Noviembre 2025  
**Características:** CRUD completo + Drawer + Vencimientos + Selector de fechas + Splash animado
