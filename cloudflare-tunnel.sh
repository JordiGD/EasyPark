#!/bin/bash
# Instala cloudflared y crea túneles HTTPS gratuitos sin dominio propio

# Instalar cloudflared (ARM64 para Oracle A1)
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 \
     -o /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared

echo "✅ cloudflared instalado"
echo ""
echo "Ejecuta en terminales separadas (o usa tmux):"
echo ""
echo "  # Owner App:"
echo "  cloudflared tunnel --url http://localhost:3000"
echo ""
echo "  # Admin App:"
echo "  cloudflared tunnel --url http://localhost:3001"
echo ""
echo "  # API (para MercadoPago webhook):"
echo "  cloudflared tunnel --url http://localhost:8085"
echo ""
echo "Cada comando te da una URL como: https://xxxx.trycloudflare.com"
echo "Usa esa URL en el .env como PAYMENT_SUCCESS_URL etc."
