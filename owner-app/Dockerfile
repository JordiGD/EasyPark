# Dockerfile para Owner App (React)
FROM node:18-alpine AS builder

WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm ci

# Copiar código fuente
COPY . .

# Build de la aplicación
RUN npm run build

# Stage de runtime
FROM node:18-alpine

WORKDIR /app

# Instalar serve para servir la app estática
RUN npm install -g serve

# Copiar build desde el builder
COPY --from=builder /app/build ./build

# Copiar package.json para dependencies mínimas
COPY package*.json ./
RUN npm ci --only=production || true

# Exponer puerto
EXPOSE 3000

# Comando para ejecutar la app
CMD ["serve", "-s", "build", "-l", "3000"]
