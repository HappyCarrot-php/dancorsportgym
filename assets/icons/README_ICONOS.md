# 🎨 Iconos de la Aplicación

## 📍 Ubicación de los Iconos

Coloca los archivos del icono de la aplicación en esta carpeta:

```
assets/icons/
├── app_icon.png          (1024x1024 px - Icono principal)
├── app_icon_android.png  (512x512 px - Para Android)
└── app_icon_ios.png      (1024x1024 px - Para iOS)
```

## 📐 Especificaciones del Icono

### Dimensiones Recomendadas
- **Icono principal:** 1024x1024 px
- **Android:** 512x512 px mínimo
- **iOS:** 1024x1024 px

### Formato
- **Formato de archivo:** PNG con transparencia
- **Fondo:** Transparente o con color sólido
- **Estilo:** Minimalista, claro y reconocible

### Diseño Sugerido para "Dancor Sport Gym"
- Colores del gimnasio (azul #1976D2, verde #4CAF50)
- Puede incluir:
  - Iniciales "DG"
  - Icono de pesa o gimnasio
  - Símbolo de dinero/caja ($)
- Esquinas redondeadas (Android las redondea automáticamente)

## 🔧 Configurar el Icono en Flutter

### Opción 1: Manual (Android)

1. Genera los iconos en diferentes tamaños:
   - mipmap-mdpi: 48x48 px
   - mipmap-hdpi: 72x72 px
   - mipmap-xhdpi: 96x96 px
   - mipmap-xxhdpi: 144x144 px
   - mipmap-xxxhdpi: 192x192 px

2. Coloca los archivos en:
```
android/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png
├── mipmap-hdpi/ic_launcher.png
├── mipmap-xhdpi/ic_launcher.png
├── mipmap-xxhdpi/ic_launcher.png
└── mipmap-xxxhdpi/ic_launcher.png
```

### Opción 2: Automática (Recomendado) - flutter_launcher_icons

1. **Agregar dependencia:**

Abre `pubspec.yaml` y agrega:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#1976D2"  # Color de fondo (azul del gym)
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"  # Opcional
```

2. **Generar iconos:**

```powershell
flutter pub get
flutter pub run flutter_launcher_icons
```

3. **Listo!** Los iconos se generarán automáticamente.

## 🎯 Herramientas para Crear Iconos

### Online (Gratis)
- **Icon Kitchen:** https://icon.kitchen/
- **App Icon Generator:** https://appicon.co/
- **Canva:** https://www.canva.com/ (templates de app icons)

### Software
- **Adobe Illustrator / Photoshop**
- **Figma** (gratis)
- **GIMP** (gratis)
- **Inkscape** (gratis)

## 📱 Ejemplo de Configuración Completa

### pubspec.yaml (después de tener el icono)

```yaml
flutter:
  uses-material-design: true
  
  # Agregar la carpeta de assets
  assets:
    - assets/icons/

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.13.1

# Configuración del icono
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  min_sdk_android: 30  # Android 11+
  adaptive_icon_background: "#1976D2"
  adaptive_icon_foreground: "assets/icons/app_icon.png"
```

### Ejecutar generación

```powershell
# 1. Agregar el icono a assets/icons/app_icon.png
# 2. Actualizar pubspec.yaml con la configuración
# 3. Ejecutar:
flutter pub get
flutter pub run flutter_launcher_icons
```

## 🎨 Plantilla de Diseño Sugerida

### Opción 1: Minimalista
```
┌─────────────────┐
│                 │
│       DG        │  <- Iniciales en bold
│    ────────     │  <- Línea debajo
│     💰 🏋️      │  <- Iconos pequeños
│                 │
└─────────────────┘
Fondo: Degradado azul (#1976D2 a #00897B)
Texto: Blanco
```

### Opción 2: Icono Representativo
```
┌─────────────────┐
│                 │
│      🏋️‍♂️       │  <- Pesa estilizada
│       💵        │  <- Dinero/caja debajo
│                 │
└─────────────────┘
Fondo: Azul (#1976D2)
Iconos: Blanco con sombra
```

### Opción 3: Letras
```
┌─────────────────┐
│                 │
│       D         │
│   ┌───────┐     │
│   │   G   │     │  <- G dentro de una caja
│   └───────┘     │
│                 │
└─────────────────┘
Fondo: Degradado verde (#4CAF50 a #00897B)
Texto: Blanco con borde
```

## ✅ Checklist

- [ ] Diseñar el icono (1024x1024 px)
- [ ] Guardar como `app_icon.png` en `assets/icons/`
- [ ] Agregar configuración en `pubspec.yaml`
- [ ] Instalar `flutter_launcher_icons`
- [ ] Ejecutar generador de iconos
- [ ] Compilar la app y verificar
- [ ] Probar en dispositivo real

## 🚀 Después de Agregar el Icono

```powershell
# Limpiar y recompilar
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
flutter build apk --release
```

## 💡 Consejos

1. **Simplicidad:** Diseños simples se ven mejor en tamaños pequeños
2. **Contraste:** Asegúrate de que se vea bien en fondos claros y oscuros
3. **Sin texto pequeño:** El texto debe ser grande y legible
4. **Prueba en dispositivo:** Verifica cómo se ve en un teléfono real
5. **Versiones:** Guarda versiones en diferentes formatos (SVG, PNG, etc.)

---

**Nota:** Una vez que agregues el icono aquí, ejecuta los comandos de configuración para aplicarlo a la aplicación.
