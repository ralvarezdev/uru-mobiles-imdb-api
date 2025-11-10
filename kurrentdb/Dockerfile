# Use 'latest' as the default (usually x86/amd64).
ARG BASE_TAG=latest

# Use the ARG in the FROM instruction.
FROM kurrentplatform/kurrentdb:${BASE_TAG}

USER root

# Install CA certificates
RUN apt-get update && apt-get install -y ca-certificates

# Copy custom CA certificates
COPY ./certs/*.crt /usr/local/share/ca-certificates/

RUN update-ca-certificates