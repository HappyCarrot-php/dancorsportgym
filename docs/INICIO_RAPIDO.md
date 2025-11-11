# 🚀 Guía Rápida de Inicio - Dancor Sport Gym

## ⚡ Inicio Rápido (3 pasos)

### 1️⃣ Instalar Dependencias
```powershell
flutter pub get
```

### 2️⃣ Ejecutar la App
```powershell
# Con dispositivo Android conectado o emulador abierto
flutter run
```

### 3️⃣ ¡Listo! 🎉
La aplicación se abrirá en tu dispositivo y estará lista para usar.

---

## 📱 Compilar APK para Instalar en Android

### Opción 1: APK Simple (más fácil)
```powershell
flutter build apk --release
```
**Ubicación del APK:** `build\app\outputs\flutter-apk\app-release.apk`

### Opción 2: APK Optimizado (recomendado)
```powershell
flutter build apk --split-per-abi --release
```
**Ubicación:** `build\app\outputs\flutter-apk\`
- `app-armeabi-v7a-release.apk` (para dispositivos ARM de 32 bits)
- `app-arm64-v8a-release.apk` (para dispositivos ARM de 64 bits) ⭐ **MÁS COMÚN**
- `app-x86_64-release.apk` (para emuladores)

### ¿Cuál APK instalar?
- **La mayoría de dispositivos modernos:** Usa `app-arm64-v8a-release.apk`
- **Si no funciona:** Prueba con `app-armeabi-v7a-release.apk`
- **Si no sabes:** Usa el APK simple del paso anterior (funciona en todos)

---

## 📲 Instalar el APK en tu Dispositivo

1. Copia el APK a tu teléfono
2. Abre el archivo APK en tu teléfono
3. Permite instalar desde "fuentes desconocidas" si se solicita
4. Presiona "Instalar"
5. ¡Listo! La app estará en tu menú de aplicaciones

---

## 🎯 Uso Básico de la Aplicación

### Pantalla Principal
- **Tarjetas de resumen:** Muestran ingresos, gastos y resultado del día
- **Lista de movimientos:** Muestra todos los ingresos y gastos del día
- **Botón verde (+):** Agregar nuevo ingreso
- **Botón rojo (+):** Agregar nuevo gasto

### Agregar Ingreso
1. Presiona el botón verde flotante "Ingreso"
2. Selecciona el tipo:
   - **Visita:** $40 (automático)
   - **Semana:** $180 (requiere nombre)
   - **Quincena:** $260 (requiere nombre)
   - **Mensualidad:** $400 (requiere nombre, +$150 con inscripción)
   - **Otros:** Monto personalizado
3. Completa los campos
4. Presiona "Guardar Ingreso"

### Agregar Gasto
1. Presiona el botón rojo flotante "Gasto"
2. Escribe el concepto o selecciona uno sugerido
3. Ingresa el monto
4. Presiona "Guardar Gasto"

### Ver Otros Días
- Presiona el icono de **calendario** en la parte superior
- Selecciona la fecha que deseas consultar

### Finalizar el Día
- Presiona el botón **"Finalizar Día"**
- Confirma la acción
- Se guardará un resumen del día en los reportes

### Ver Reportes
- Presiona el icono de **reportes** (barras) en la parte superior
- Verás el historial de todos los cierres diarios
- Toca cualquier día para ver el desglose completo

---

## ❓ Solución de Problemas

### Error al compilar
```powershell
# Limpia y vuelve a intentar
flutter clean
flutter pub get
flutter build apk --release
```

### La app no abre
- Verifica que tu dispositivo tenga Android 10 (API 30) o superior
- Asegúrate de haber habilitado "Fuentes desconocidas" en la configuración

### Los datos no se guardan
- Verifica que la app tenga permisos de almacenamiento
- Reinstala la aplicación

---

## 📞 Comandos Útiles

```powershell
# Ver dispositivos conectados
flutter devices

# Ver logs en tiempo real
flutter logs

# Verificar problemas
flutter doctor

# Analizar código
flutter analyze

# Limpiar caché
flutter clean
```

---

## 💡 Consejos

1. **Backup:** La app guarda todo localmente. Haz respaldos periódicos del dispositivo.
2. **Finalizar día:** No olvides finalizar el día para tener un registro en reportes.
3. **Edición:** Si cometes un error, puedes eliminar el movimiento y agregarlo nuevamente.
4. **Fechas:** Puedes consultar cualquier día anterior usando el calendario.

---

## 🎉 ¡Listo para Usar!

La aplicación está completamente funcional y lista para ayudarte a gestionar tu gimnasio.

**Recuerda:**
- ✅ No necesitas internet
- ✅ Los datos se guardan automáticamente
- ✅ Puedes consultar días anteriores
- ✅ Los reportes se crean al finalizar el día

**¡Éxito con tu gimnasio! 💪**
