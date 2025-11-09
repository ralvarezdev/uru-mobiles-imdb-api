FROM alpine:latest

RUN apk add --no-cache curl jq bash

ENTRYPOINT ["sh", "/docker-entrypoint-initdb.d/setup.sh"]