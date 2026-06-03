# Subscription Service - Microservicio de Suscripciones

Microservicio responsable de gestionar planes de suscripción mensual para conductores y sus transacciones de pago.

## Características

- ✅ Planes de suscripción flexibles (precio, descuento, límites de horas)
- ✅ Gestión de suscripciones por conductor
- ✅ Historial de transacciones de pago
- ✅ Cálculo automático de descuentos
- ✅ Validación de límites de reserva según plan
- ✅ Renovación automática configurable
- ✅ CORS habilitado para Flutter Web
- ✅ Integración con Eureka Service Discovery

## Endpoints

### Planes de Suscripción

```
GET    /api/subscriptions/plans              - Obtener todos los planes activos
GET    /api/subscriptions/plans/all          - Obtener todos los planes
GET    /api/subscriptions/plans/{id}         - Obtener un plan específico
POST   /api/subscriptions/plans              - Crear nuevo plan
PUT    /api/subscriptions/plans/{id}         - Actualizar un plan
DELETE /api/subscriptions/plans/{id}         - Desactivar un plan
```

### Suscripciones del Conductor

```
POST   /api/subscriptions                         - Crear nueva suscripción
GET    /api/subscriptions/driver/{driverId}      - Obtener suscripciones del conductor
GET    /api/subscriptions/driver/{driverId}/active - Obtener suscripción activa
GET    /api/subscriptions/driver/{driverId}/discount - Obtener descuento aplicable
GET    /api/subscriptions/driver/{driverId}/can-reserve - Verificar disponibilidad
POST   /api/subscriptions/{id}/renew             - Renovar suscripción
PUT    /api/subscriptions/{id}/cancel            - Cancelar suscripción
PUT    /api/subscriptions/{id}/pause             - Pausar suscripción
```

## Base de Datos

**subscription_db:**
- `subscription_plans` - Planes disponibles
- `driver_subscriptions` - Suscripciones activas por conductor
- `subscription_transactions` - Historial de transacciones

## Puerto

**8083** (configurable via `SERVER_PORT`)

## Variables de Entorno

```
DB_HOST=localhost
DB_PORT=3306
DB_USER=subscription_user
DB_PASSWORD=subscription_pass123
SERVER_PORT=8083
EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://localhost:8761/eureka/
```

## Compilación

```bash
mvn clean package
```

## Ejecución

```bash
java -jar target/subscription-0.0.1-SNAPSHOT.jar
```

## Docker

```bash
docker build -t subscription-service .
docker run -p 8083:8083 subscription-service
```
