#!/bin/bash
# ============================================================
# EasyPark — Script de despliegue en VPS
# Uso: ./deploy.sh
# ============================================================
set -e

echo "🚀 Iniciando despliegue de EasyPark..."

# 1. Actualizar código
echo "📥 Actualizando código..."
git pull origin main

# 2. Copiar SSL certs al directorio esperado por Nginx
echo "🔒 Verificando certificados SSL..."
if [ ! -f ./ssl/fullchain.pem ]; then
    mkdir -p ./ssl
    cp /etc/letsencrypt/live/tudominio.com/fullchain.pem ./ssl/
    cp /etc/letsencrypt/live/tudominio.com/privkey.pem   ./ssl/
    echo "✅ Certificados copiados"
fi

# 3. Build y levantar en producción
echo "🔨 Construyendo imágenes Docker..."
docker compose --profile production build --no-cache

echo "▶️  Levantando servicios..."
docker compose --profile production up -d

# 4. Esperar a que MySQL esté listo
echo "⏳ Esperando MySQL..."
sleep 20

# 5. Verificar servicios activos
echo "🔍 Estado de contenedores:"
docker compose ps

echo ""
echo "✅ Despliegue completado!"
echo "   Owner App  → https://owner.tudominio.com"
echo "   Admin App  → https://admin.tudominio.com"
echo "   API        → https://api.tudominio.com"
echo "   Eureka     → http://<ip_servidor>:8761"
