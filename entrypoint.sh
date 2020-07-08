#!/usr/bin/env bash

cleanup() {
  echo "caught Signal ... stopping nginx ..."

  nginx -s stop

  echo "done."
  exit 0
}

trap cleanup HUP INT QUIT TERM

renew() {
  touch do_not_stop
  nginx -s quit

  for domain in $(ls /renew-routines); do
    ./renew-routines/${domain}
  done

  nginx
  rm do_not_stop
}

renew_maintainer() {
  renew
  while sleep 7d; do
    renew
  done
}

secure_ssl_files() {
  chown -R root:root /ssl-cert
  chmod -R 600 /ssl-cert
}

if [[ -z "$@" ]]; then
  # https://gist.github.com/tsaarni/14f31312315b46f06e0f1ecc37146bf3
  mkdir -p -m 600 /etc/nginx/ssl
  echo -e ".\n.\n.\n\n.\n.\n.\n" | openssl req -x509 -newkey ec:<(openssl ecparam -name secp384r1) -nodes -days 365 -out /etc/nginx/ssl/cert.pem -keyout /etc/nginx/ssl/privkey.pem
  echo
  secure_ssl_files

  nginx

  renew_maintainer &

  while sleep 30s; do
    ps | grep nginx | grep -q -v grep
    nginx=$?

    if [[ ! -f ./do_not_stop && $nginx != 0 ]]; then
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
