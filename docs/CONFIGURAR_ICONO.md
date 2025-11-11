# 🔧 Guía de Configuración del Icono

## Paso a Paso Rápido

### 1. Preparar el Icono
- Diseña o consigue un icono de 1024x1024 px
- Guárdalo como `app_icon.png`
- Colócalo en: `assets/icons/app_icon.png`

### 2. Instalar Flutter Launcher Icons

Agrega al final de `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.13.1  # <-- Agregar esta línea

# Configuración del icono
flutter_launcher_icons:
  android: true
  ios: false  # Cambiar a true si necesitas iOS
  image_path: "assets/icons/app_icon.png"
  min_sdk_android: 30
  adaptive_icon_background: "#1976D2"  # Color azul del gimnasio
  adaptive_icon_foreground: "assets/icons/app_icon.png"
```

### 3. Ejecutar Comandos

```powershell
flutter pub get
flutter pub run flutter_launcher_icons
```

### 4. Verificar

```powershell
flutter clean
flutter build apk --release
```

¡Listo! Tu app tendrá el icono personalizado.

---

## Si No Tienes un Icono Todavía

### Opción 1: Usar un Generador Online

1. Ve a https://icon.kitchen/
2. Sube una imagen o crea un icono simple
3. Descarga el resultado
4. Guárdalo como `app_icon.png` en `assets/icons/`

### Opción 2: Crear uno Básico en Canva

1. Ve a https://www.canva.com/
2. Crea un diseño de 1024x1024 px
3. Usa las iniciales "DG" con fondo azul
4. Descarga como PNG
5. Guárdalo en `assets/icons/`

### Opción 3: Usar un Placeholder Temporal

Mientras diseñas el icono final, puedes usar uno temporal:

```powershell
# Dejar el icono por defecto de Flutter por ahora
# La app funcionará normalmente con el icono de Flutter
```

---

## Configuración Completa para Copiar/Pegar

Abre `pubspec.yaml` y reemplaza la sección `dev_dependencies` con:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icons/app_icon.png"
  min_sdk_android: 30
  adaptive_icon_background: "#1976D2"
  adaptive_icon_foreground: "assets/icons/app_icon.png"
  remove_alpha_ios: true
```

Luego ejecuta:

```powershell
flutter pub get
flutter pub run flutter_launcher_icons
flutter build apk --release
```

---

**Importante:** El archivo `app_icon.png` debe estar en `assets/icons/` antes de ejecutar los comandos.
