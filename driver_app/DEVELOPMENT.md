# INSTRUCCIONES DE DESARROLLO - EasyPark Driver App

## Requisitos Previos

- **Flutter**: 3.0 o superior
- **Dart**: 3.0 o superior
- **Android Studio** o **VS Code** con extensiones de Flutter
- **Java**: 11 o superior
- **Git**

## Configuración Inicial

### 1. Instalar Flutter

```bash
# En Windows, descargar desde: https://flutter.dev/docs/get-started/install/windows

# Agregar Flutter al PATH (Windows)
# C:\flutter\bin
```

### 2. Verificar Instalación

```bash
flutter --version
dart --version
flutter doctor
```

### 3. Clonar y Configurar el Proyecto

```bash
cd driver_app
flutter pub get
```

## Preparar el Backend

### Iniciar el Servidor Spring Boot

```bash
cd ../driver
./mvnw spring-boot:run
```

El servidor debe estar en: `http://localhost:8080`

## Configurar Conexión a la API

### Para Emulador Android:
```dart
// lib/services/driver_service.dart
static const String baseUrl = 'http://10.0.2.2:8080';
```

### Para Dispositivo Físico:
```dart
// lib/services/driver_service.dart
// 1. Encuentra tu IP local: ipconfig (Windows) o ifconfig (Linux/Mac)
// 2. Actualiza la URL:
static const String baseUrl = 'http://192.168.x.x:8080'; // Reemplazar con tu IP
```

## Ejecutar la Aplicación

### Listar dispositivos disponibles:
```bash
flutter devices
```

### Ejecutar en emulador:
```bash
flutter run
```

### Ejecutar en dispositivo específico:
```bash
flutter run -d <device_id>
```

## Estructura del Proyecto

```
driver_app/
├── lib/
│   ├── main.dart                      # Punto de entrada
│   ├── models/
│   │   └── driver.dart                # Modelo de datos
│   ├── services/
│   │   └── driver_service.dart        # Servicios HTTP
│   ├── providers/
│   │   └── driver_provider.dart       # Manejo de estado
│   ├── screens/
│   │   ├── driver_registration_screen.dart
│   │   └── drivers_list_screen.dart
│   └── widgets/
│       └── custom_text_field.dart
├── pubspec.yaml                       # Dependencias
├── analysis_options.yaml              # Linting
└── android/
    └── app/
        └── build.gradle               # Configuración Android
```

## Desarrollo

### Hot Reload
```bash
flutter run
# Prensa 'r' en la terminal para hot reload
# Prensa 'R' para hot restart
```

### Análisis de Código
```bash
flutter analyze
```

### Formatea el Código
```bash
flutter format lib/
```

## Debugging

### Ver logs en tiempo real:
```bash
flutter logs
```

### Conectar con DevTools:
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Debugger en VS Code:
1. Abre VS Code
2. Instala la extensión "Flutter"
3. Presiona F5 para iniciar debugging

## Tests

### Ejecutar tests unitarios:
```bash
flutter test
```

### Ejecutar tests de integración:
```bash
flutter test integration_test/
```

## Permisos Android

Verificar `android/app/src/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Construcción de APK

### Debug APK:
```bash
flutter build apk
# Ubicación: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK:
```bash
flutter build apk --release
# Ubicación: build/app/outputs/flutter-apk/app-release.apk
```

### Release AAB (Para Google Play):
```bash
flutter build appbundle --release
# Ubicación: build/app/outputs/bundle/release/app-release.aab
```

## Solución de Problemas

### Problema: "Unable to locate Android SDK"
**Solución:**
```bash
flutter config --android-sdk /path/to/android/sdk
```

### Problema: Conexión rechazada al API
**Solución:**
1. Verifica que el backend está corriendo
2. Verifica la URL en `driver_service.dart`
3. Verifica los permisos de internet en AndroidManifest.xml

### Problema: Hot reload no funciona
**Solución:**
```bash
flutter clean
flutter pub get
flutter run
```

### Problema: Emulador no inicia
**Solución:**
```bash
flutter emulators
flutter emulators launch <emulator_id>
```

## Commits y Control de Versiones

```bash
# Ver cambios
git status

# Agregar cambios
git add .

# Commit
git commit -m "feat: agregar pantalla de registro"

# Push
git push origin main
```

## Convenciones de Código

- **Nombres de archivos**: snake_case (driver_service.dart)
- **Nombres de clases**: PascalCase (DriverService)
- **Nombres de variables**: camelCase (driverName)
- **Nombres de constantes**: camelCase (baseUrl)
- **Indentación**: 2 espacios

## Recursos Útiles

- [Documentación official de Flutter](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [HTTP Package](https://pub.dev/packages/http)

## Contacto y Soporte

Para preguntas o problemas, contacta al equipo de desarrollo.

