#!/usr/bin/env sh

cleanup() {
  echo "caught Signal ... stopping nginx ..."

  nginx -s stop

  echo "done."
  exit 0
}

trap cleanup HUP INT QUIT TERM

renew() {
  for domain in $(ls /renew-routines); do
    ./renew-routines/${domain}
  done
}

renew_maintainer() {
  renew
  while sleep 30d; do
    renew
  done
}

secure_ssl_files() {
  chown -R root:root /ssl-cert
  chmod -R 600 /ssl-cert
}

if [[ -z "$@" ]]; then
  mkdir -p -m 600 /etc/nginx/ssl
  openssl ecparam -name secp384r1 > /etc/nginx/ssl/ecparam.pem
  echo -e ".\n.\n.\n\n.\n.\n.\n" | openssl req -x509 -newkey ec:/etc/nginx/ssl/ecparam.pem -nodes -days 365 -out /etc/nginx/ssl/cert.pem -keyout /etc/nginx/ssl/privkey.pem
  echo
  secure_ssl_files

  nginx

  renew_maintainer &

  while sleep 30s; do
    ps | grep nginx | grep -q -v grep
    nginx=$?

    if [[ $nginx != 0 ]]; then
      echo "nginx stopped working!"
      exit 1
    fi
  done
elif [[ "$@" == "reload" ]]; then
  secure_ssl_files
  nginx -s reload
  exit $?
elif [[ "$@" == "renew" ]]; then
  renew
  exit $?
fi

exec "$@"
