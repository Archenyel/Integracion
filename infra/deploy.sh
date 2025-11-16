#!/bin/bash

# Definir variables
# Si no viene de una variable de entorno, usa la imagen por defecto
IMAGE_NAME="${IMAGE_NAME:-ghcr.io/TU_USUARIO_GITHUB/mi-proyecto-node:latest}"
# Convertir a minúsculas para evitar errores de Docker
IMAGE_NAME=$(echo "$IMAGE_NAME" | tr '[:upper:]' '[:lower:]')

DIR_BASE="/root/despliegue"
BLUE_PORT=3001
GREEN_PORT=3002
NGINX_CONF="/etc/nginx/nginx.conf"
TEMPLATE_CONF="$DIR_BASE/nginx.conf.template"

echo "--- INICIO DEPLOY (GHCR) ---"
echo "Imagen objetivo: $IMAGE_NAME"

# 1. Descargar imagen (Login debe haberse hecho previamente si es privado)
docker pull $IMAGE_NAME

# 2. Detectar color actual
CURRENT_COLOR=$(docker ps --format '{{.Names}}' | grep -E "^(blue|green)$")

if [ "$CURRENT_COLOR" == "blue" ]; then
  NEW_COLOR="green"
  NEW_PORT=$GREEN_PORT
  OLD_COLOR="blue"
else
  NEW_COLOR="blue"
  NEW_PORT=$BLUE_PORT
  OLD_COLOR="green"
fi

echo "Switching: $CURRENT_COLOR -> $NEW_COLOR ($NEW_PORT)"

# 3. Levantar nuevo contenedor
docker rm -f $NEW_COLOR 2>/dev/null || true

docker run -d --name $NEW_COLOR \
  -p $NEW_PORT:3000 \
  -e COLOR=$NEW_COLOR \
  $IMAGE_NAME

# 4. Health Check
echo "Esperando health check..."
sleep 5
# (Opcional: agregar curl aquí para validar)

# 5. Actualizar Nginx
sed "s/{{PORT}}/$NEW_PORT/g" $TEMPLATE_CONF > temp_nginx.conf
mv temp_nginx.conf $NGINX_CONF

# 6. Recargar
nginx -s reload

# 7. Limpiar viejo
if [ ! -z "$CURRENT_COLOR" ]; then
  docker stop $OLD_COLOR
  docker rm $OLD_COLOR
fi

echo "--- FIN EXITOSO ---"