# Configuración de Conexión entre Flutter y Backend

## Importante: Configurar la URL del Servidor

La conexión entre la aplicación Flutter y el backend Spring Boot debe estar correctamente configurada para que funcione.

## Paso 1: Identificar tu Entorno

### A. Para Emulador Android
Si estás usando el emulador de Android de Android Studio:

**URL:** `http://10.0.2.2:8080`

*Nota: 10.0.2.2 es la dirección especial del emulador para acceder a localhost*

### B. Para Dispositivo Físico Android
Si estás usando un dispositivo Android real:

1. Obtén tu IP local:
   - **Windows**: Abre CMD y ejecuta `ipconfig`
   - **Linux/Mac**: Abre terminal y ejecuta `ifconfig` o `hostname -I`
   - Busca "IPv4 Address" (algo como 192.168.x.x)

2. **URL:** `http://TU_IP_LOCAL:8080`
   - Ejemplo: `http://192.168.1.100:8080`

## Paso 2: Actualizar la URL en el Código

Abre el archivo: `lib/services/driver_service.dart`

Localiza la línea:
```dart
static const String baseUrl = 'http://10.0.2.2:8080';
```

Reemplázala con tu URL según tu entorno.

## Paso 3: Verificar el Backend

Asegúrate de que el servidor Spring Boot esté corriendo:

```bash
cd ../driver
./mvnw spring-boot:run
```

Deberías ver en la consola:
```
Started DriverApplication in X seconds
```

Verifica que esté escuchando en el puerto 8080 visitando en tu navegador:
- Para emulador: No es posible, pero la app lo hará
- Para dispositivo/pc: `http://localhost:8080/actuator/health`

Deberías ver: `{"status":"UP"}`

## Paso 4: Verificar Permisos Android

Abre `android/app/src/AndroidManifest.xml` y verifica que contenga:

```xml
<manifest ...>
    <!-- Permisos -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    ...
</manifest>
```

## Paso 5: Ejecutar la Aplicación

Después de configurar todo:

```bash
flutter clean
flutter pub get
flutter run
```

## Debugging de Conexión

### Si recibe error "Connection refused"

1. **Verifica que el backend esté corriendo:**
   ```bash
   # En otra terminal
   cd ../driver
   ./mvnw spring-boot:run
   ```

2. **Verifica la URL configurada:**
   - Revisa el archivo `driver_service.dart`
   - Asegúrate de que coincide con tu entorno

3. **Para emulador:**
   - Reinicia el emulador
   - Limpia la aplicación: `flutter clean`

### Si recibe error "Network unreachable"

1. **Dispositivo físico:**
   - Verifica que el dispositivo esté conectado a la misma red que la PC
   - Verifica la IP local correcta con `ipconfig`

2. **Para desarrollo en la misma máquina:**
   - Asegúrate de que el firewall no bloquee el puerto 8080
   - Prueba: `netstat -an | findstr :8080` (Windows)

### Verificar logs de la aplicación

```bash
flutter logs
```

Busca mensajes de error relacionados con la conexión HTTP.

## Configuración Adicional (Opcional)

### Variables de Entorno

Para cambiar dinámicamente la URL según el entorno, puedes usar:

1. **Variables de compilación:**
   ```bash
   flutter run --dart-define=API_URL=http://192.168.1.100:8080
   ```

2. **Archivo de configuración:**
   - Crear `lib/config/api_config.dart`
   - Leer la configuración según el entorno

### Ejemplo de Configuración Dinámica

```dart
// lib/config/api_config.dart

class ApiConfig {
  static const String emulatorBaseUrl = 'http://10.0.2.2:8080';
  static const String deviceBaseUrl = 'http://192.168.1.100:8080';
  
  static String getBaseUrl() {
    // Aquí podrías detectar si está en emulador o dispositivo
    return emulatorBaseUrl;
  }
}

// Luego en driver_service.dart:
final String baseUrl = ApiConfig.getBaseUrl();
```

## Pruebas de Conectividad

### Desde la aplicación Flutter

Puedes crear una pantalla de prueba para verificar la conexión:

```dart
ElevatedButton(
  onPressed: () async {
    try {
      final response = await http.get(
        Uri.parse('${DriverService.baseUrl}/driver/alldrivers'),
      );
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
    } catch (e) {
      print('Error: $e');
    }
  },
  child: const Text('Probar Conexión'),
),
```

## Tabla de Referencia Rápida

| Entorno | URL | Descripción |
|---------|-----|-------------|
| Emulador Android | `http://10.0.2.2:8080` | Dirección especial del emulador |
| Dispositivo local | `http://192.168.x.x:8080` | Cambiar x.x por tu IP local |
| Máquina remota | `http://dns.remoto.com:8080` | URL del servidor remoto |
| Desarrollo | `http://localhost:8080` | Solo en PC sin emulador |

## Próximos Pasos

Una vez configurado correctamente:

1. Abre la aplicación
2. Llena el formulario de registro
3. Haz clic en "Registrar Conductor"
4. Deberías ver un mensaje de éxito
5. Navega a "Ver Lista de Conductores" para verificar

¡Listo! Tu aplicación Flutter está conectada al backend.

