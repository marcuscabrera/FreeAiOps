# FreeAiOps - Guia de Configuração Docker

Este guia detalha como executar o FreeAiOps em ambiente Docker utilizando Docker Compose.

---

## Pré-requisitos

- **Docker** 20.10+ instalado
- **Docker Compose** V2 (incluído no Docker Desktop) ou V1
- **Git** para clonar o repositório

### Verificando a Instalação

```bash
# Verificar versão do Docker
docker --version

# Verificar versão do Docker Compose
docker compose version   # V2
# ou
docker-compose --version # V1
```

---

## 1. Estrutura dos Arquivos Docker

O projeto contém os seguintes arquivos Docker:

| Arquivo | Descrição |
|---------|-----------|
| `Dockerfile` | Definição da imagem da aplicação Go |
| `docker-compose.yml` | Orchestração dos serviços |
| `.env.example` | Template de variáveis de ambiente |
| `docker/mysql/conf.d/custom.cnf` | Configurações do MySQL |
| `docker/mysql/init/01-init.sql` | Script de inicialização do banco |
| `docker/phpmyadmin/config.user.inc.php` | Configurações do PhpMyAdmin |

---

## 2. Configuração do Ambiente

### 2.1 Clonar o Repositório

```bash
git clone https://github.com/FreeAiOps/FreeAiOps.git
cd FreeAiOps
```

### 2.2 Criar Arquivo de Variáveis de Ambiente

```bash
# Copiar o template
cp .env.example .env
```

### 2.3 Variáveis de Ambiente (`.env`)

Edite o arquivo `.env` com suas configurações:

```bash
# ============================================================================
# Configuração do Banco de Dados
# ============================================================================
DB_HOST=mysql
DB_PORT=3306
DB_NAME=freeaiops
DB_USER=freeaiops
DB_PASSWORD=freeaiops123

# ============================================================================
# Configuração da Aplicação
# ============================================================================
APP_PORT=8080
APP_DOMAIN=localhost

# ============================================================================
# Configuração JWT (IMPORTANTE: Altere em produção!)
# ============================================================================
JWT_SIGNING_KEY=freeaiops-secret-key-change-in-production
JWT_EXPIRES_TIME=604800000

# ============================================================================
# Configuração de Logs
# ============================================================================
LOG_LEVEL=info
LOG_FORMAT=json

# ============================================================================
# Configuração Admin
# ============================================================================
ADMIN_AUTH=true

# ============================================================================
# PhpMyAdmin (Opcional)
# ============================================================================
PHPMYADMIN_PORT=8081
```

---

## 3. Construção das Imagens

### 3.1 Construir Imagem da Aplicação

```bash
# Construir a imagem Docker
docker build -t freeaiops/app:latest .
```

**Tempo estimado:** 3-5 minutos (primeira vez, depende do cache)

### 3.2 Verificar Imagem Criada

```bash
# Listar imagens
docker images freeaiops

# Saída esperada:
# REPOSITORY    TAG       IMAGE ID       CREATED          SIZE
# freeaiops     latest    abc123def456   10 seconds ago   150MB
```

---

## 4. Iniciar o Ambiente

### 4.1 Iniciar Todos os Serviços

```bash
# Iniciar os serviços em background
docker compose up -d

# Ou se usando Docker Compose V1:
docker-compose up -d
```

### 4.2 Verificar Status dos Serviços

```bash
# Ver status dos containers
docker compose ps

# Saída esperada:
# NAME                 IMAGE                STATUS          PORTS
# freeaiops-mysql      mysql:8.0            Up (healthy)    0.0.0.0:3306->3306/tcp
# freeaiops-app        freeaiops/app:latest Up (healthy)   0.0.0.0:8080->8080/tcp
# freeaiops-phpmyadmin phpmyadmin:5.2.1     Up             0.0.0.0:8081->80/tcp
```

---

## 5. Acessando a Aplicação

### 5.1 Interface Web

| Serviço | URL |
|---------|-----|
| **Aplicação FreeAiOps** | http://localhost:8080 |
| **Admin** | http://localhost:8080/admin |
| **Login** | http://localhost:8080/admin/login |
| **Registro** | http://localhost:8080/admin/register |
| **Health Check** | http://localhost:8080/health |

### 5.2 PhpMyAdmin (Interface do Banco)

| Serviço | URL |
|---------|-----|
| **PhpMyAdmin** | http://localhost:8081 |
| **Usuário** | root |
| **Senha** | (veja no arquivo .env, padrão: rootpassword) |

### 5.3 API REST

```bash
# Health check da API
curl http://localhost:8080/health
# Resposta: "ok..."

# Listar apps (após autenticação)
curl http://localhost:8080/api/v1/apps
```

---

## 6. Verificando os Serviços

### 6.1 Verificar Logs da Aplicação

```bash
# Logs da aplicação (em tempo real)
docker compose logs -f app

# Últimas 50 linhas
docker compose logs --tail=50 app

# Filtrar erros apenas
docker compose logs app | grep -i error
```

### 6.2 Verificar Logs do MySQL

```bash
# Logs do MySQL
docker compose logs -f mysql
```

### 6.3 Verificar Todos os Logs

```bash
# Todos os serviços
docker compose logs -f

# Ou todos os logs combinados
docker compose logs
```

### 6.4 Verificar Saúde dos Containers

```bash
# Ver status detalhado
docker compose ps

# Testar saúde da aplicação
curl http://localhost:8080/health

# Testar saúde do MySQL
docker exec -it freeaiops-mysql mysqladmin ping -h localhost -u root -p
```

---

## 7. Configuração Segura de Variáveis de Ambiente

### 7.1 Em Produção

Para produção, **NUNCA** versione o arquivo `.env`:

```bash
#确保 .env está no .gitignore
echo ".env" >> .gitignore
```

### 7.2 Alternativas Seguras

#### Opção A: Docker Secrets (Swarm)

```yaml
# docker-compose.yml (exemplo para Swarm)
services:
  app:
    secrets:
      - db_password
      - jwt_key

secrets:
  db_password:
    external: true
  jwt_key:
    external: true
```

#### Opção B: Variáveis de Ambiente do Sistema

```bash
# Linux/Mac
export DB_PASSWORD="senha_segura"
export JWT_KEY="jwt_key_segura"

# Windows (PowerShell)
$env:DB_PASSWORD="senha_segura"
```

#### Opção C: .env com Arquivo Diferente por Ambiente

```bash
# Desenvolvimento
cp .env .env.development

# Produção
cp .env .env.production
```

### 7.3 Credenciais Recomendadas

| Variável | Padrão Desenvolvimento | Padrão Produção |
|----------|----------------------|-----------------|
| `DB_PASSWORD` | freeaiops123 | Gere uma senha forte |
| `JWT_SIGNING_KEY` | freeaiops-secret-key | Gere uma chave única |
| `DB_ROOT_PASSWORD` | rootpassword | Gere uma senha forte |

**Gere senhas fortes:**
```bash
# Linux/Mac
openssl rand -base64 32

# Python
python3 -c "import secrets; print(secrets.token_hex(32))"
```

---

## 8. Parar e Remover o Ambiente

### 8.1 Parar os Serviços

```bash
# Parar os containers (mantém volumes)
docker compose stop

# Parar um serviço específico
docker compose stop app
```

### 8.2 Remover os Serviços

```bash
# Parar e remover containers, redes
docker compose down

# Remover também volumes (CUIDADO: apaga os dados!)
docker compose down -v

# Remover imagens (opcional)
docker compose down --rmi local
```

### 8.3 Comandos Úteis

```bash
# Reiniciar um serviço
docker compose restart app

# Rebuild (após mudanças no código)
docker compose up -d --build

# Ver recursos usados
docker stats

# Limpar recursos não usados
docker system prune -a
```

---

## 9. Backup e Restore do Banco de Dados

### 9.1 Backup do Banco de Dados

#### Método 1: Usando mysqldump (recomendado)

```bash
# Criar diretório para backups
mkdir -p backups

# Criar backup
docker exec freeaiops-mysql mysqldump \
  -u root \
  -p"rootpassword" \
  --single-transaction \
  --quick \
  --lock-tables=false \
  freeaiops > backups/backup_$(date +%Y%m%d_%H%M%S).sql

# Verificar backup criado
ls -la backups/
```

#### Método 2: Compactado

```bash
# Backup compactado
docker exec freeaiops-mysql mysqldump \
  -u root \
  -p"rootpassword" \
  freeaiops | gzip > backups/backup_$(date +%Y%m%d).sql.gz
```

#### Método 3: Usando o Container da Aplicação

```bash
# Backup através do container app
docker exec freeaiops-app sh -c '
  mysqldump -h mysql -u root -p"$DB_PASSWORD" freeaiops
' > backups/backup.sql
```

### 9.2 Restaurar o Banco de Dados

#### Método 1: Restaurar de arquivo SQL

```bash
# Restaurar de arquivo
docker exec -i freeaiops-mysql mysql \
  -u root \
  -p"rootpassword" \
  freeaiops < backups/backup_20250101_120000.sql
```

#### Método 2: Restaurar de arquivo compactado

```bash
# Restaurar de arquivo compactado
gunzip < backups/backup_20250101.sql.gz | docker exec -i \
  freeaiops-mysql mysql -u root -p"rootpassword" freeaiops
```

#### Método 3: PhpMyAdmin

1. Acesse http://localhost:8081
2. Selecione o banco `freeaiops`
3. Vá em "Importar"
4. Selecione o arquivo SQL
5. Clique em "Executar"

### 9.3 Automatizar Backups (Cron)

```bash
# Editar crontab
crontab -e

# Adicionar linha para backup diário às 3h da manhã
0 3 * * * cd /caminho/para/FreeAiOps && docker exec freeaiops-mysql mysqldump -u root -p"rootpassword" freeaiops > backups/backup_$(date +\%Y\%m\%d).sql
```

---

## 10. Solução de Problemas

### 10.1 "Connection refused" ao MySQL

**Problema:** O app inicia antes do MySQL estar pronto.

**Solução:**
```bash
# Verificar status do MySQL
docker compose ps mysql

# Se não estiver healthy, aguarde e tente novamente
docker compose restart app

# Ver logs do MySQL
docker compose logs mysql
```

### 10.2 "Access denied" no Banco

**Problema:** Credenciais incorretas.

**Solução:**
```bash
# Verificar variáveis de ambiente
cat .env | grep DB_

# Testar conexão manualmente
docker exec -it freeaiops-mysql mysql -u root -p
```

### 10.3 Porta já em Uso

**Problema:** Porta 8080 ou 3306 já está em uso.

**Solução:**
```bash
# Alterar porta no .env
APP_PORT=8081
PHPMYADMIN_PORT=8082

# Reiniciar
docker compose down
docker compose up -d
```

### 10.4 Dados Perdidos

**Problema:** Dados sumiram após restart.

**Solução:**
```bash
# Verificar se volumes existem
docker volume ls | grep freeaiops

# Inspecionar volume
docker volume inspect freeaiops-mysql-data
```

### 10.5 Limpar Tudo e Recomeçar

```bash
# PARAR TUDO E REMOVER (incluindo dados!)
docker compose down -v

# Remover imagens
docker rmi freeaiops-app:latest

# Limpar cache
docker builder prune -af

# Iniciar novamente
docker compose up -d
```

---

## 11. Configurações Avançadas

### 11.1 Recursos dos Containers

Edite `docker-compose.yml` para ajustar recursos:

```yaml
services:
  mysql:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G

  app:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
```

### 11.2 Rede Personalizada

As redes já estão configuradas, mas você pode adicionar mais:

```yaml
networks:
  freeaiops-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16
```

### 11.3 Volume Personalizado para Logs

```yaml
volumes:
  app_logs:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /var/log/freeaiops
```

---

## 12. Checklist de Segurança

- [ ] Alterar senhas padrão no `.env`
- [ ] Alterar chave JWT em produção
- [ ] Não versionar `.env` (adicionar ao .gitignore)
- [ ] Usar HTTPS em produção (configure reverse proxy)
- [ ] Configurar firewall para portas necessárias
- [ ] Monitorar logs regularmente
- [ ] Fazer backups regulares
- [ ] Atualizar imagens regularmente

---

## 13. Comandos Rápidos de Referência

```bash
# Iniciar ambiente
docker compose up -d

# Parar ambiente
docker compose down

# Ver logs
docker compose logs -f

# Reiniciar serviço
docker compose restart app

# Acessar container
docker exec -it freeaiops-app sh

# Verificar saúde
docker compose ps

# Backup
docker exec freeaiops-mysql mysqldump -u root -p"rootpassword" freeaiops > backup.sql

# Restore
docker exec -i freeaiops-mysql mysql -u root -p"rootpassword" freeaiops < backup.sql
```

---

## 14. Próximos Passos

1. ✅ Configurar variáveis de ambiente
2. ✅ Construir imagens Docker
3. ✅ Iniciar ambiente com Docker Compose
4. ✅ Acessar aplicação web
5. 🔄 Configurar backup automático
6. 🔄 Configurar SSL/HTTPS (produção)
7. 🔄 Configurar monitoramento

---

*Guia Docker criado em: 2026-05-10*
*Versão do Docker: Compatível com Docker 20.10+ e Docker Compose V2*