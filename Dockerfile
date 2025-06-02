# syntax=docker/dockerfile:1.4

# Etap 1 - pobieramy kod źródłowy przez git+ssh
FROM alpine/git AS clone
WORKDIR /src
RUN apk add --no-cache openssh
RUN mkdir -p ~/.ssh && chmod 700 ~/.ssh
# dodajemy klucz hosta GitHub, żeby uniknąć promptu przy klonowaniu
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts

# Upewnij się, że agent ssh z kluczem jest dostępny przy budowie (patrz: komenda build)
RUN --mount=type=ssh git clone git@github.com:<TWOJ_LOGIN>/pawcho6.git .

# Etap 2 - budowanie aplikacji w Go
FROM golang:alpine AS builder
ENV CGO_ENABLED=0
ARG VERSION=0.1.0

WORKDIR /app
COPY --from=clone /src/main.go .

RUN go mod init myapp
RUN go build -o app -ldflags "-X main.version=$VERSION"

# Etap 3 - obraz końcowy z nginx
FROM nginx:alpine
COPY --from=builder /app/app /usr/share/nginx/html/index.html

HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost || exit 1
