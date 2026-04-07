# 🅿️ EasyPark - Sistema de Gestión de Parqueaderos

Plataforma completa para gestionar parqueaderos con aplicaciones para conductores, propietarios y administradores.

## 📱 Aplicaciones

- **Driver App** - Aplicación móvil (Flutter) para conductores
- **Owner App** - Aplicación web (React) para propietarios de parqueaderos
- **Admin App** - Panel de administración (React) para gestionar el sistema
- **Backend API** - Servicios centralizados (Spring Boot)

## 🛠️ Tecnologías

| Componente | Tecnología |
|-----------|-----------|
| Mobile | Flutter 3.0+ |
| Web | React 18 |
| Backend | Spring Boot 3.0+ |
| Base de datos | MySQL 8.0 |
| Orquestación | Docker Compose |

## 🚀 Montaje Rápido con Docker

### Requisitos
- Docker Desktop instalado
- 4GB+ de RAM disponible
- Puertos libres: 3000, 3001, 8080, 3306

### 1. Iniciar servicios

**Windows (PowerShell):**
```powershell
docker-compose up -d
```

**Mac/Linux:**
```bash
docker-compose up -d
```

### 2. Acceder a las aplicaciones

| Aplicación | URL | Usuario | Contraseña |
|-----------|-----|--------|-----------|
| Owner App | http://localhost:3000 | owner@easypark.com | password123 |
| Admin App | http://localhost:3001 | admin@easypark.com | password123 |
| Backend API | http://localhost:8080 | - | - |

### 3. Detener servicios

```bash
docker-compose down
```

## 📊 Base de datos

**Credenciales:** 
- Usuario: `easypark_user`
- Contraseña: `easypark_pass123`
- Base de datos: `easypark_db`

**Conectar:**
```bash
docker-compose exec mysql mysql -u easypark_user -peasypark_pass123 easypark_db
```

---

## 📁 Estructura de Carpetas

```
EasyPark/
├── user/           → Backend (Spring Boot)
├── owner-app/      → App web propietarios (React)
├── admin-app/      → App web administración (React)
├── driver_app/     → App móvil conductores (Flutter)
└── docker-compose.yml
```

---

## 🔗 Enlaces Rápidos

- [SETUP_GUIDE.md](./SETUP_GUIDE.md) - Guía detallada
- [API_REFERENCE.md](./API_REFERENCE.md) - Endpoints disponibles
- [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) - Resumen del proyecto
- Fácil de mantener

---

## 🆘 PROBLEMAS COMUNES

### Error de Conexión
→ Verifica que el backend esté corriendo en puerto 8080

### Puerto en Uso
→ Cambia el puerto en `package.json` o cierra la aplicación que lo usa

### Dependencias No Instaladas
→ Ejecuta `npm install` en la carpeta de la app React

### Flutter No Funciona
→ Verifica que Flutter está instalado: `flutter --version`

Consulta [SETUP_GUIDE.md](./SETUP_GUIDE.md) para más troubleshooting.

---

## 📊 RESUMEN TÉCNICO

**Lenguajes:** Dart, JavaScript/JSX, Java  
**Frameworks:** Flutter, React, Spring Boot  
**Base de Datos:** MySQL/PostgreSQL (definida en backend)  
**APIs:** REST JSON  
**Autenticación:** JWT (a implemetar completamente)  

---

## 📞 AYUDA

1. Lee el [SETUP_GUIDE.md](./SETUP_GUIDE.md) primero
2. Consulta [API_REFERENCE.md](./API_REFERENCE.md) para endpoints
3. Revisa la carpeta README.md de cada app
4. Verifica [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) para details técnicos

---

## 🎉 ¡YA ESTÁ TODO LISTO!

El proyecto está completamente implementado y conectado.  
Solo necesitas instalar dependencias y ejecutar los comandos de arriba.

**Happy Coding! 🚀**

---

**Versión:** 1.0.0  
**Última actualización:** Abril 2024  
**Estado:** ✅ LISTO PARA USAR
