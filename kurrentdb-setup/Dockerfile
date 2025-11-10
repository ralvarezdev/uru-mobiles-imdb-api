FROM alpine:latest

# Install dependencies
RUN apk add --no-cache curl jq bash ca-certificates

USER root

# Copy custom CA certificates
COPY ./certs/*.crt /usr/local/share/ca-certificates/

RUN update-ca-certificates

ENTRYPOINT ["sh", "/docker-entrypoint-initdb.d/setup.sh"]