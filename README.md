# 🅿️ EasyPark - Sistema de Gestión de Parqueaderos

Plataforma completa para gestionar parqueaderos con arquitectura de microservicios. Incluye aplicaciones para conductores, propietarios de estacionamientos y administradores del sistema.

## Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                  FRONTEND APPLICATIONS                   │
│  ┌───────────────┐  ┌───────────────┐  ┌──────────────┐ │
│  │ Driver App    │  │ Owner App     │  │ Admin App    │ │
│  │ (Flutter)     │  │ (React)       │  │ (React)      │ │
│  │ Port 5000     │  │ Port 3000     │  │ Port 3001    │ │
│  └───────────────┘  └───────────────┘  └──────────────┘ │
└──────────────────────────┬──────────────────────────────┘
                           │
                HTTP/REST API
                           │
            ┌──────────────┴──────────────┐
            │                             │
      ┌─────▼──────┐            ┌────────▼────────┐
      │User Service│            │Parking Service  │
      │(Port 8080) │            │(Port 8081)      │
      └──────┬──────┘            └────────┬────────┘
             │                           │
      ┌──────▼─────────────────────────┐ │
      │   MySQL Database               │ │
      │  ┌──────────────────────────┐  │ │
      │  │ easypark_db (Users)      │  │ │
      │  │ parking_db (Parkings)    │  │ │
      │  └──────────────────────────┘  │ │
      └────────────────────────────────┘ │
             │                           │
      ┌──────v─────────────────────┐    │
      │ Eureka Service Discovery   │    │
      │ (Port 8761)                │    │
      └────────────────────────────┘    │
```

## 📱 Aplicaciones

| Aplicación | Tipo | Tecnología | Propósito |
|-----------|------|-----------|----------|
| **Driver App** | Móvil | Flutter | Conductores: buscar y reservar espacios |
| **Owner App** | Web | React | Propietarios: crear y gestionar estacionamientos |
| **Admin App** | Web | React | Administradores: gestionar usuarios y sistema |

## 🛠️ Tecnologías

| Componente | Tecnología | Versión |
|-----------|-----------|---------|
| **Frontend** | React | 18+ |
| **Mobile** | Flutter | 3.0+ |
| **Backend** | Spring Boot | 4.0.4 - 4.0.5 |
| **Java** | OpenJDK | 21 |
| **Database** | MySQL | 8.0 |
| **Service Discovery** | Netflix Eureka | 2025.1.1 |
| **Container** | Docker | Latest |

## Requisitos Previos

- ✅ Docker Desktop instalado ([descargar](https://www.docker.com/products/docker-desktop))
- ✅ 6GB+ de RAM disponible
- ✅ Puertos libres: **3000, 3001, 5000, 8080, 8081, 8761, 3306**

## Inicio Rápido

### 1. Clonar o descargar el proyecto

```bash
git clone https://github.com/JordiGD/EasyPark.git
```

### 2. Preparar el entorno

#### Destruir volúmenes anteriores (primera vez o si hay problemas)
```powershell
docker-compose down -v
```

#### Construir imágenes
```powershell
docker-compose build --no-cache
```

### 3. Iniciar servicios

**Windows (PowerShell):**
```powershell
docker-compose up -d
```

**Mac/Linux:**
```bash
docker-compose up -d
```

### 4. Verificar estado de servicios

```powershell
docker-compose ps
```

Estado esperado:
```
CONTAINER ID   IMAGE                    STATUS
xxxxxxxxxx     mysql:8.0                Up X seconds (healthy)
xxxxxxxxxx     easypark-eureka          Up X seconds (healthy)
xxxxxxxxxx     easypark-user-service    Up X seconds
xxxxxxxxxx     easypark-parking-service Up X seconds
xxxxxxxxxx     easypark-owner-app       Up X seconds
xxxxxxxxxx     easypark-admin-app       Up X seconds
```

### 5. Esperar 30-40 segundos a que todos los servicios estén listos

## Acceder a las Aplicaciones

### Frontend Apps

| Aplicación | URL | Credenciales | Rol |
|-----------|-----|--------------|-----|
| **Owner App** | http://localhost:3000 | owner@easypark.com / password123 | Propietario |
| **Admin App** | http://localhost:3001 | admin@easypark.com / password123 | Administrador |
| **Driver App** | `flutter run -d chrome` | driver@easypark.com / password123 | Conductor |

### Backend Services

| Servicio | URL | Propósito |
|---------|-----|----------|
| **User Service** | http://localhost:8080 | Gestión de usuarios, autenticación |
| **Parking Service** | http://localhost:8081 | Gestión de parqueaderos y espacios |
| **Eureka Server** | http://localhost:8761/eureka | Service discovery/registry |

## Bases de Datos

### easypark_db (User Service)
```sql
-- Credenciales
Usuario: easypark_user
Contraseña: easypark_pass123

-- Tablas
- user (usuarios del sistema)
- driver (información de conductores)
- owner (información de propietarios)
```

### parking_db (Parking Service)
```sql
-- Credenciales
Usuario: parking_user
Contraseña: parking_pass123

-- Tablas
- parking (estacionamientos)
- space (espacios de parqueo)
```

### Conectar a MySQL

**⚠️ IMPORTANTE:** El nombre del servicio en docker-compose es `dbUser`, no `mysql`

```bash
# Acceder a MySQL dentro del contenedor (COMANDO CORRECTO)
docker compose exec dbUser mysql -u easypark_user -peasypark_pass123 easypark_db

# Una vez dentro, comandos útiles:
SHOW TABLES;                 -- Listar todas las tablas
SELECT * FROM user;          -- Ver usuarios
SELECT * FROM driver;        -- Ver conductores
SELECT * FROM owner;         -- Ver propietarios
EXIT;                        -- Salir de MySQL
```

**Para conectar a parking_db:**
```bash
docker compose exec dbUser mysql -u parking_user -pparking_pass123 parking_db
```

## API Endpoints

### User Service (8080)

```
POST   /user/saveUser        → Registrar usuario
POST   /user/login           → Login
POST   /user/updateUser      → Actualizar usuario
POST   /driver/saveVehicule  → Registrar vehículo
POST   /driver/updateVehicule → Actualizar vehículo
GET    /owner/getOwnerById   → Obtener propietario
```

### Parking Service (8081)

```
POST   /api/parkings         → Crear parqueadero
GET    /api/parkings         → Obtener todos
GET    /api/parkings/{id}    → Obtener detalles
GET    /api/parkings/owner/{ownerId} → Parqueaderos del propietario
PUT    /api/parkings/{id}    → Actualizar parqueadero
GET    /api/parkings/{id}/status → Estado de ocupación

POST   /api/spaces/create/{parkingId}  → Crear espacio
GET    /api/spaces/parking/{parkingId} → Espacios del parqueadero
GET    /api/spaces/{id}/status         → Estado del espacio
```

## Integración con Apps

### Owner App (React) - Configuración
```bash
# .env
REACT_APP_API_URL=http://localhost:8080
REACT_APP_PARKING_API_URL=http://localhost:8081
```

### Driver App (Flutter) - Configuración
```dart
// En driver_service.dart
static const String baseUrl = 'http://10.0.2.2:8080';        // User Service
static const String parkingApiUrl = 'http://10.0.2.2:8081';  // Parking Service
```

## Estructura de Carpetas

```
EasyPark/
├── user/                    # User Microservice (Spring Boot)
│   ├── src/
│   │   ├── main/java/       # Código fuente
│   │   └── resources/       # application.yml, properties
│   └── pom.xml
│
├── parking/                 # Parking Microservice (Spring Boot)
│   ├── src/
│   │   ├── main/java/       # Código fuente
│   │   └── resources/       # application.yml, properties
│   └── pom.xml
│
├── eurekaserver/            # Service Discovery
│   ├── src/
│   └── pom.xml
│
├── owner-app/               # Owner Application (React)
│   ├── src/
│   │   ├── pages/           # Páginas principales
│   │   ├── services/        # API services
│   │   └── components/      # Componentes React
│   └── package.json
│
├── admin-app/               # Admin Application (React)
│   ├── src/
│   ├── pages/
│   └── package.json
│
├── driver_app/              # Driver Application (Flutter)
│   ├── lib/
│   │   ├── screens/         # Pantallas Flutter
│   │   ├── services/        # Servicios HTTP
│   │   └── models/          # Modelos de datos
│   └── pubspec.yaml
│
├── mysql-init.sql           # Script de inicialización de BD
├── docker-compose.yml       # Orquestación de contenedores
├── nginx.conf              # Configuración del proxy
└── README.md
```


## Documentación Adicional

- [API Interfaces Documentation](./API_INTERFACES.md) - Referencia completa de endpoints
- [Apps Integration Guide](./APPS_INTEGRATION.md) - Cómo usar servicios desde apps
- [User Service Architecture](./user/Diagrama.md) - Arquitectura interna
- [Parking Service Architecture](./parking/Diagrama.md) - Arquitectura interna

## Datos de Acceso por Defecto

### Usuarios de Prueba
```
Administrador:
  Email: admin@easypark.com
  Contraseña: password123 (o la configurada en mysql-init.sql)
  Rol: ADMIN

Propietario:
  Email: owner@easypark.com
  Contraseña: password123
  Rol: OWNER

Conductor:
  Email: driver@easypark.com
  Contraseña: password123
  Rol: DRIVER
```

### Credenciales de Base de Datos
```
User Service DB:
  Usuario: easypark_user
  Contraseña: easypark_pass123
  Base de datos: easypark_db

Parking Service DB:
  Usuario: parking_user
  Contraseña: parking_pass123
  Base de datos: parking_db

MySQL Root:
  Usuario: root
  Contraseña: rootpassword
```

**Versión:** 1.0.0  
**Última actualización:** Abril 2026  
**Estado:** ✅ PRODUCCIÓN  
**Ambiente:** Docker Compose + Spring Boot Microservices
