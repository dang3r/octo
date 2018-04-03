#!/usr/bin/env bash
#
# Entrypoint for an octo reverse-proxy instance

if [ -z "${OCTO_SECRET}" ]; then
  echo "Need to set OCTO_SECRET!"
  exit 1
fi

if [ -z "${TARGET_URL}" ]; then
  echo "Need to set PROXY_URL"
  exit 1
fi

mkdir -p /etc/ssl/octo
openssl req \
  -subj '/CN=octo.com/O=Octo/C=US/ST=California' \
  -new \
  -newkey rsa:4096 \
  -days 365 \
  -nodes \
  -x509 \
  -keyout /etc/ssl/octo/key.ssl \
  -out /etc/ssl/octo/cert.ssl

NGINX_CONF="/etc/nginx/nginx.conf"
NGINX_CONF_ENV="${NGINX_CONF}.env"
envsubst '$OCTO_SECRET $TARGET_URL' < ${NGINX_CONF_ENV} > ${NGINX_CONF}
nginx -g "daemon off;"
