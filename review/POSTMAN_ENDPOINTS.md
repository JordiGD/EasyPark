# Endpoints de Review Service para Postman

## Base URL
```
http://localhost:8083
```

## Endpoints Disponibles

### 1. Obtener TODAS las reseñas (Sin información de usuario)
```
GET /api/reviews
```
**Descripción:** Obtiene todas las reseñas del sistema.
**Respuesta:** Array de objetos ReviewDTO

**Ejemplo en Postman:**
- Method: GET
- URL: `http://localhost:8083/api/reviews`
- Headers: `Content-Type: application/json`

---

### 2. Obtener TODAS las reseñas CON INFORMACIÓN DEL USUARIO (RECOMENDADO)
```
GET /api/reviews/all
```
**Descripción:** Obtiene todas las reseñas con el nombre del conductor enriquecido desde el user-service.
**Respuesta:** Array de objetos ReviewWithUserDTO

**Ejemplo en Postman:**
- Method: GET
- URL: `http://localhost:8083/api/reviews/all`
- Headers: `Content-Type: application/json`

**Ejemplo de respuesta:**
```json
[
  {
    "id": 1,
    "parkingId": 1,
    "driverId": 2,
    "driverName": "Default DRIVER",
    "rating": 5,
    "comment": "Excelente parqueadero",
    "createdAt": "2026-05-20T10:30:00",
    "updatedAt": "2026-05-20T10:30:00"
  },
  {
    "id": 2,
    "parkingId": 1,
    "driverId": 3,
    "driverName": "Juan García",
    "rating": 4,
    "comment": "Buen servicio",
    "createdAt": "2026-05-20T11:15:00",
    "updatedAt": "2026-05-20T11:15:00"
  }
]
```

---

### 3. Crear una nueva reseña
```
POST /api/reviews
```
**Descripción:** Crea una nueva reseña para un parqueadero.

**Comportamiento:** Si el usuario ya tiene una reseña para el mismo `parkingId`, el endpoint realizará un *upsert* (actualiza la reseña existente). No se crearán duplicados.

**Request Body:**
```json
{
  "parkingId": 1,
  "driverId": 2,
  "rating": 5,
  "comment": "Excelente parqueadero, muy limpio"
}
```

**Ejemplo en Postman:**
- Method: POST
- URL: `http://localhost:8083/api/reviews`
- Headers: `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "parkingId": 1,
  "driverId": 2,
  "rating": 5,
  "comment": "Excelente parqueadero"
}
```

**Respuesta:** `ReviewWithUserDTO` (incluye `driverName`)

**Ejemplo de respuesta:**
```json
{
  "id": 10,
  "parkingId": 1,
  "driverId": 2,
  "driverName": "Juan García",
  "rating": 5,
  "comment": "Excelente parqueadero",
  "createdAt": "2026-05-20T12:00:00",
  "updatedAt": "2026-05-20T12:00:00"
}
```

---

### 4. Obtener reseñas por parqueadero (CON INFORMACIÓN DEL USUARIO)
```
GET /api/reviews/parking/{parkingId}
```
**Descripción:** Obtiene todas las reseñas de un parqueadero específico con información del usuario.

**Parámetros:**
- `parkingId` (path): ID del parqueadero

**Ejemplo en Postman:**
- Method: GET
- URL: `http://localhost:8083/api/reviews/parking/1`

**Ejemplo de respuesta:**
```json
[
  {
    "id": 1,
    "parkingId": 1,
    "driverId": 2,
    "driverName": "Default DRIVER",
    "rating": 5,
    "comment": "Excelente",
    "createdAt": "2026-05-20T10:30:00",
    "updatedAt": "2026-05-20T10:30:00"
  }
]
```

---

### 5. Obtener calificación promedio de un parqueadero
```
GET /api/reviews/parking/{parkingId}/average
```
**Descripción:** Obtiene la calificación promedio de un parqueadero.

**Parámetros:**
- `parkingId` (path): ID del parqueadero

**Ejemplo en Postman:**
- Method: GET
- URL: `http://localhost:8083/api/reviews/parking/1/average`

**Ejemplo de respuesta:**
```json
4.5
```

---

### 6. Obtener reseña por ID
```
GET /api/reviews/{id}
```
**Descripción:** Obtiene una reseña específica por su ID.

**Parámetros:**
- `id` (path): ID de la reseña

**Ejemplo en Postman:**
- Method: GET
- URL: `http://localhost:8083/api/reviews/1`

---

### 7. Obtener reseñas por conductor
```
GET /api/reviews/driver/{driverId}
```
**Descripción:** Obtiene todas las reseñas hechas por un conductor específico.

**Parámetros:**
- `driverId` (path): ID del conductor

**Ejemplo en Postman:**
- Method: GET
- URL: `http://localhost:8083/api/reviews/driver/2`

---

### 8. Actualizar una reseña
```
PUT /api/reviews/{id}
```
**Descripción:** Actualiza una reseña existente.

**Parámetros:**
- `id` (path): ID de la reseña

**Request Body:**
```json
{
  "rating": 4,
  "comment": "Actualizado - Buen servicio"
}
```

**Ejemplo en Postman:**
- Method: PUT
- URL: `http://localhost:8083/api/reviews/1`
- Body (raw JSON):
```json
{
  "rating": 4,
  "comment": "Actualizado"
}
```

---

### 9. Eliminar una reseña
```
DELETE /api/reviews/{id}
```
**Descripción:** Elimina una reseña existente.

**Parámetros:**
- `id` (path): ID de la reseña

**Ejemplo en Postman:**
- Method: DELETE
- URL: `http://localhost:8083/api/reviews/1`

---

## Verificación de Datos

Para verificar que las reseñas se están guardando correctamente:

1. **Usa el endpoint `GET /api/reviews/all`** para ver todas las reseñas con nombres de usuarios
2. **Crea una reseña** con `POST /api/reviews` y verifica que aparezca con el nombre del usuario
3. **Consulta por parqueadero** con `GET /api/reviews/parking/{parkingId}` para asegurarte de que se están guardando correctamente

## Problemas Comunes

- **Error 500:** Asegúrate de que el user-service esté corriendo en `http://localhost:8080`
- **No se muestran nombres de usuario:** El fallback mostrará `Usuario #X` si el user-service no está disponible
- **CORS errors:** El servicio ya tiene `@CrossOrigin(origins = "*")` habilitado
