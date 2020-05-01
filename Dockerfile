FROM nginx:1.18-alpine

RUN apk update \
 && apk add openssl socat \
 && wget https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh -O acme.sh \
 && chmod +x acme.sh

ENTRYPOINT ["./entrypoint.sh"]
