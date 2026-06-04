#!/bin/bash
# Ejecutar en el servidor Oracle para abrir los puertos necesarios

# Abrir puertos en el firewall del SO (iptables/ufw)
apt install -y ufw
ufw allow 22    # SSH
ufw allow 80    # HTTP
ufw allow 443   # HTTPS
ufw allow 3000  # Owner App (opcional, solo si no usas Nginx)
ufw allow 3001  # Admin App  (opcional)
ufw --force enable

echo "✅ Firewall configurado"
echo ""
echo "⚠️  IMPORTANTE: También debes abrir estos puertos en la"
echo "   Consola de Oracle Cloud:"
echo "   Networking → VCN → Security Lists → Ingress Rules"
echo "   Agregar: TCP 80, 443, 3000, 3001"
