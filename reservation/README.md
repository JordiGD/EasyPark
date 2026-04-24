# Reservation Microservice

Microservicio de reservas para el sistema EasyPark.

## Descripción

Este servicio gestiona las reservas de espacios de parqueo. Permite a los conductores hacer reservas, consultar disponibilidad, cancelar y completar reservas.

## Endpoints Principales

- `POST /api/reservations` - Crear nueva reserva
- `GET /api/reservations/{id}` - Obtener reserva por ID
- `GET /api/reservations/driver/{driverId}` - Obtener reservas de un conductor
- `GET /api/reservations/driver/{driverId}/active` - Obtener reservas activas de un conductor
- `GET /api/reservations/parking/{parkingId}` - Obtener reservas de un parqueadero
- `GET /api/reservations/space/{spaceId}` - Obtener reservas de un espacio
- `PUT /api/reservations/{id}/cancel` - Cancelar una reserva
- `PUT /api/reservations/{id}/complete` - Completar una reserva

## Configuración

Puerto: 8082
Base de datos: reservation_db
Usuario: reservation_user
Contraseña: reservation_pass123

## Construcción

```bash
mvn clean package
```

## Docker

```bash
docker build -t easypark-reservation .
```
