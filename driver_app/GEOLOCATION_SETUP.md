# Configuración de Geolocalización - EasyPark Driver App

## Pasos de Instalación

### 1. Instalar Dependencias
Ejecuta desde la carpeta `driver_app`:
```bash
flutter pub get
```

### 2. Configuración Android

#### AndroidManifest.xml
Edita `android/app/src/main/AndroidManifest.xml` y agrega estos permisos:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

Añade también el servicio de ubicación en la etiqueta de aplicación:
```xml
<application
    ...
    android:usesCleartextTraffic="true">
    ...
</application>
```

#### Configurar Google Maps API Key
1. Edita `android/app/src/main/AndroidManifest.xml`
2. Agrega dentro de la etiqueta `<application>` (antes de `</application>`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_GOOGLE_MAPS_API_KEY"/>
```

3. Obtén tu API Key:
   - Ve a [Google Cloud Console](https://console.cloud.google.com)
   - Crea un nuevo proyecto
   - Habilita las APIs:
     - Maps SDK for Android
     - Maps SDK for Web (si lo necesitas)
   - Crea una credencial de tipo "API Key"
   - Restringe la clave a solo Android y agrega tu huella SHA-1

#### Conseguir SHA-1 de tu app
```bash
# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 3. Configuración iOS

#### Podfile
Edita `ios/Podfile` y asegúrate de que `platform` sea al menos iOS 11:
```ruby
platform :ios, '12.0'
```

#### Info.plist
Edita `ios/Runner/Info.plist` y agrega:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>EasyPark necesita acceso a tu ubicación para mostrar parqueaderos cercanos</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>EasyPark necesita acceso a tu ubicación para mostrar parqueaderos cercanos</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>EasyPark necesita acceso a tu ubicación para mostrar parqueaderos cercanos</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

#### Configurar Google Maps API Key (iOS)
En `ios/Runner/GeneratedPluginRegistrant.m`, iOS configurará automáticamente con tu API key:

Alternativa: Edita `ios/Podfile` y agrega:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_LOCATION=1',
      ]
    end
  end
end
```

### 4. Ejecutar la Aplicación

```bash
flutter run

# O para modo release
flutter run --release
```

### 5. Puntos Importantes

#### Servidor Backend
Asegúrate de que los endpoints estén disponibles:
- GET `/api/parkings/map/all` - Obtiene todos los parqueaderos
- GET `/api/parkings/nearby?latitude=X&longitude=Y&radiusKm=Z` - Obtiene parqueaderos cercanos

#### URL Base en Producción
En `lib/services/geolocation_service.dart`, actualiza la URL:
```dart
// Desarrollo (localhost)
GeolocationService({this.baseUrl = 'http://localhost:8081'});

// Producción
GeolocationService({this.baseUrl = 'https://tu-dominio.com'});
```

#### Permisos en Tiempo de Ejecución
La app solicita permisos automáticamente cuando:
1. El usuario accede a la pantalla del mapa
2. A través del widget `GeolocationProvider`

#### Limitaciones de Emulador
En emuladores de Android, puedes simular ubicación:
1. Abre Android Studio
2. Ve a la pestaña Extended controls
3. Simula ubicación usando Google Maps

## Estructura de Respuesta API

### GET /api/parkings/map/all
Retorna:
```json
[
  {
    "id": 1,
    "ownerId": 1,
    "name": "Parking Centro",
    "address": "Calle Principal 123",
    "phone": "+57 123 456 7890",
    "description": "Parqueadero seguro",
    "totalSpaces": 50,
    "occupiedSpaces": 30,
    "pricePerHour": 5.5,
    "latitude": 4.7110,
    "longitude": -74.0721,
    "availability": true
  }
]
```

## Troubleshooting

### Google Maps no aparece
- Verificar que la API Key está correctamente configurada
- Verificar que Maps SDK for Android está habilitada en Google Cloud Console
- Verificar permisos en `AndroidManifest.xml`

### Ubicación no se obtiene
- Verificar que app tiene permisos de ubicación en el dispositivo
- Verificar que LocationAccuracy es HIGH (no LOWEST)
- En emulador, simular ubicación en Extended controls

### Errores de conexión al API
- Verificar que el servidor está corriendo
- Verificar la URL base en `GeolocationService`
- Para HTTP en Android: agregar `android:usesCleartextTraffic="true"`

## Mejoras Futuras

1. Caché de parqueaderos para reducir llamadas API
2. Persistencia de ubicación del usuario
3. Notificaciones cuando nuevos parqueaderos están disponibles
4. Rutas optimizadas al parqueadero
5. Integración con payment para reservar espacio
