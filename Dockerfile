# syntax=docker/dockerfile:1.4

FROM alpine AS stage1
RUN apk add --no-cache openssh git

# Dodanie znanego hosta GitHub (ważne dla SSH)
RUN mkdir -p ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Użycie SSH do pobrania repo
RUN --mount=type=ssh \
    git clone git@github.com:kkkaxia/pawcho6.git /src

# Kompilacja aplikacji Go
FROM golang:alpine AS builder

WORKDIR /app
COPY --from=stage1 /src/main.go .

RUN go mod init myapp
ARG VERSION=0.1.0
ENV CGO_ENABLED=0
RUN go build -o app -ldflags "-X main.version=$VERSION"

# Serwer HTTP z NGINX
FROM nginx:alpine

COPY --from=builder /app/app /usr/share/nginx/html/index.html

HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost || exit 1
