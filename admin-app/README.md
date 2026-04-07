# Admin App - EasyPark

Panel de administración para gestionar usuarios y conductores en EasyPark.

## Características

- 🔐 Autenticación admin
- 👥 Gestión de usuarios
- 🚗 Gestión de conductores
- 🅿️ Gestión de propietarios
- 📊 Reportes y estadísticas
- 🔧 Configuración del sistema

## Instalación

```bash
npm install
```

## Desarrollo

```bash
npm start
```

Abre [http://localhost:3001](http://localhost:3001) en tu navegador.

## Compilación

```bash
npm run build
```

## API Connection

Por defecto, la aplicación se conecta a:
- **URL Base**: `http://localhost:8080`

Para cambiar la URL, edita el archivo `src/services/api.js`

## Estructura del Proyecto

```
src/
├── components/       # Componentes reutilizables
├── pages/           # Páginas principales
├── services/        # Servicios API
├── hooks/           # Custom hooks
├── context/         # Context API
├── styles/          # Estilos CSS
└── App.jsx          # Componente principal
```
