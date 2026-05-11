# ============================================================================
# Dockerfile - FreeAiOps Application
# ============================================================================
# Imagem base: Go 1.18-alpine para imagem leve
FROM golang:1.18-alpine AS builder

# Definir variáveis de ambiente
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# Instalar dependências do build
RUN apk add --no-cache git

# Definir diretório de trabalho
WORKDIR /app

# Copiar arquivos de dependências primeiro (para cache de camadas)
COPY go.mod go.sum ./
RUN go mod download

# Copiar código fonte
COPY . .

# Build da aplicação
RUN go build -o freeaiops cmd/main.go

# Build das migrações
RUN go build -o migrate cmd/migrate/main.go

# ============================================================================
# Imagem final - Alpine Linux
# ============================================================================
FROM alpine:3.18

# Instalar dependências运行时
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    mysql-client

# Definir variáveis de ambiente
ENV TZ=America/Sao_Paulo \
    APP_PORT=8080

# Criar diretórios necessários
RUN mkdir -p /app/log /app/config

# Copiarbinários do stage anterior
COPY --from=builder /app/freeaiops /app/
COPY --from=builder /app/migrate /app/
COPY --from=builder /app/config/config.yaml /app/config/
COPY --from=builder /app/templates /app/templates
COPY --from=builder /app/utils /app/utils
COPY --from=builder /app/pkg /app/pkg
COPY --from=builder /app/middleware /app/middleware
COPY --from=builder /app/internal /app/internal
COPY --from=builder /app/initialize /app/initialize

# Definir diretório de trabalho
WORKDIR /app

# Expor porta da aplicação
EXPOSE 8080

# Criar script de entrypoint com wait for database
RUN echo '#!/bin/sh\n\
set -e\n\
\n\
echo "==========================================="\n\
echo "  FreeAiOps - Starting Application"\n\
echo "==========================================="\n\
\n\
# Configurações do banco\n\
DB_HOST=${DB_HOST:-mysql}\n\
DB_PORT=${DB_PORT:-3306}\n\
DB_USER=${DB_USER:-root}\n\
DB_PASSWORD=${DB_PASSWORD:-rootpassword}\n\
\n\
echo "Waiting for database..."\n\
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do\n\
    if mysqladmin ping -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" --silent 2>/dev/null; then\n\
        echo "Database is ready!"\n\
        break\n\
    fi\n\
    echo "Waiting for database... ($i/20)"\n\
    sleep 3\n\
done\n\
\n\
echo "Running database migrations..."\n\
/app/migrate\n\
\n\
echo "Starting FreeAiOps server..."\n\
exec /app/freeaiops' > /entrypoint.sh && chmod +x /entrypoint.sh

# ponto de entrada
ENTRYPOINT ["/entrypoint.sh"]

# Comandos padrão
CMD ["freeaiops"]