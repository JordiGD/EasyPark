# EasyPark Driver App

Aplicación Flutter para registrar conductores en el sistema EasyPark.

## Características

- ✅ Registro de conductores con validación
- ✅ Visualización de lista de conductores
- ✅ Integración con API REST del backend
- ✅ Manejo de estados con Provider
- ✅ Validación de correo electrónico y contraseña
- ✅ Interfaz responsiva y moderna

## Requisitos

- Flutter 3.0 o superior
- Dart 3.0 o superior
- Android SDK (para desarrollo Android)

## Instalación

1. **Clona el proyecto:**
```bash
cd driver_app
```

2. **Instala las dependencias:**
```bash
flutter pub get
```

3. **Configura la URL del servidor:**
   - Abre el archivo `lib/services/driver_service.dart`
   - Modifica la constante `baseUrl` según tu configuración:
     - Para emulador: `http://10.0.2.2:8080`
     - Para dispositivo físico: `http://TU_IP_LOCAL:8080`

## Ejecución

### En emulador Android:
```bash
flutter run
```

### En dispositivo físico:
```bash
flutter run -d <device_id>
```

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/
│   └── driver.dart          # Modelo de datos del conductor
├── services/
│   └── driver_service.dart  # Servicio para comunicarse con la API
├── providers/
│   └── driver_provider.dart # Manejo de estado con Provider
├── screens/
│   ├── driver_registration_screen.dart  # Pantalla de registro
│   └── drivers_list_screen.dart        # Pantalla de lista
└── widgets/
    └── custom_text_field.dart          # Widget personalizado de campo de texto
```

## Flujo de la Aplicación

1. **Pantalla de Registro**: El usuario puede registrar un nuevo conductor llenando un formulario
2. **Validación**: Los datos se validan antes de enviarlos al servidor
3. **Envío de datos**: Los datos se envían al backend mediante la API REST
4. **Lista de Conductores**: Se puede ver la lista de todos los conductores registrados

## Configuración del Backend

Asegúrate de que el servidor backend esté en ejecución:

```bash
cd driver
./mvnw spring-boot:run
```

El servidor debe estar escuchando en el puerto 8080.

## Dependencias

- **http**: Para realizar peticiones HTTP
- **provider**: Manejo de estado
- **email_validator**: Validación de correos electrónicos
- **intl**: Internacionalización

## Notas Importantes

1. **URL del servidor**: La URL por defecto está configurada para emulador (`10.0.2.2`). Cambiar para dispositivo físico.
2. **Permisos Android**: Asegúrate de tener permisos de internet en `android/app/src/AndroidManifest.xml`
3. **HTTPS**: Para producción, considera usar HTTPS en lugar de HTTP

## Solución de Problemas

### La aplicación no puede conectar al backend

- Verifica que el servidor esté corriendo en `http://localhost:8080`
- Asegúrate de usar la URL correcta según estés en emulador o dispositivo
- Revisa los logs en Android Studio

### Error de validación de correo

- Verifica que el formato del correo sea válido (ejemplo@correo.com)

### Las contraseñas no coinciden

- Asegúrate de escribir la misma contraseña en ambos campos

## Próximas Mejoras Sugeridas

- [ ] Autenticación de usuarios
- [ ] Editar conductores existentes
- [ ] Eliminar conductores
- [ ] Búsqueda y filtrado de conductores
- [ ] Almacenamiento local con SQLite
- [ ] Interfaz oscura (Dark Mode)
- [ ] Internacionalización (i18n)

