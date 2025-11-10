FROM kurrentplatform/kurrentdb:latest

USER root

# Install CA certificates
RUN apt-get update && apt-get install -y ca-certificates

# Copy custom CA certificates
COPY ./certs/*.crt /usr/local/share/ca-certificates/

RUN update-ca-certificates