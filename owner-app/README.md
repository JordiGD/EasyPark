# Owner App - EasyPark

Plataforma web para propietarios de parqueaderos en EasyPark.

## Características

- 🔐 Autenticación y registro de propietarios
- 🅿️ Gestión de parqueaderos
- 📊 Dashboard con estadísticas
- 💰 Gestión de precios y tarifas
- 📱 Interfaz responsiva

## Instalación

```bash
npm install
```

## Desarrollo

```bash
npm start
```

Abre [http://localhost:3000](http://localhost:3000) en tu navegador.

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
