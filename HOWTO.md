# FreeAiOps - Guia de Utilização

## Pré-requisitos

- **Go 1.18+** instalado
- **MySQL 5.7+** instalado e rodando
- **Git** para clonar o repositório

---

## 1. Configuração do Ambiente

### 1.1 Clonar o Repositório

```bash
git clone https://github.com/FreeAiOps/FreeAiOps.git
cd FreeAiOps
```

### 1.2 Configurar o Banco de Dados

Edite o arquivo `config/config.yaml`:

```yaml
mysql:
  path: 'localhost'        # Host do MySQL
  port: '3306'            # Porta do MySQL
  db-name: 'freeaiops'    # Nome do banco (crie antes se necessário)
  username: 'root'        # Usuário MySQL
  password: '123456'      # Senha do MySQL
```

### 1.3 Criar o Banco de Dados

```bash
mysql -u root -p -e "CREATE DATABASE freeaiops CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

---

## 2. Executando a Aplicação

### 2.1 Executar as Migrações (Primeira vez)

Este comando cria as tabelas no banco de dados:

```bash
go run cmd/migrate/main.go
```

**Saída esperada:**
```
2026/05/10 10:00:00 Database connection successful
```

### 2.2 Iniciar o Servidor

```bash
go run cmd/main.go
```

O servidor will start na porta **8080**.

**Saída esperada:**
```
Gorm configuration loaded successfully
Database connection successful
Server starting on :8080
```

---

## 3. Acessando a Aplicação

### 3.1 Interface Web Administrativa

Abra no navegador:

```
http://localhost:8080/admin
```

- **Login**: Redireciona para `/admin/login`
- **Registro**: Acesse `/admin/register`

### 3.2 Health Check

```
GET http://localhost:8080/health
```

Resposta: `"ok..."`

---

## 4. API RESTful

### 4.1 Estrutura Base

**URL Base:** `http://localhost:8080/api/v1`

### 4.2 Endpoints de Recursos

Para cada recurso (ex: apps), os seguintes endpoints estão disponíveis:

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/v1/<recurso>` | Listar todos (com paginação) |
| GET | `/api/v1/<recurso>/:id` | Obter um item |
| POST | `/api/v1/<recurso>` | Criar novo item |
| PUT | `/api/v1/<recurso>/:id` | Atualizar item |
| DELETE | `/api/v1/<recurso>/:id` | Excluir item |

### 4.3 Parâmetros de Paginação

```
GET /api/v1/<recurso>?size=10&current=1
```

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| size | int | 10 | Itens por página |
| current | int | 1 | Página atual |

### 4.4 Autenticação JWT

A API utiliza tokens JWT para autenticação.

#### Login (Obter Token)

```bash
curl -X POST http://localhost:8080/admin/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin123"
```

O token será armazenado em um cookie `token`.

#### Configurações JWT (config/config.yaml)

```yaml
jwt:
  signing-key: 'freeaiops'        # Chave de assinatura
  expires-time: 604800000         # Tempo de expiração (ms) - 7 dias
  buffer-time: 86400000           # Tempo de buffer (ms) - 1 dia
  issuer: 'freeaiops'             # Emissor do token
```

---

## 5. Recursos Disponíveis

### 5.1 Apps (Aplicações)

Exemplo de como criar um app via API:

```bash
curl -X POST http://localhost:8080/api/v1/apps \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Application",
    "description": "Application description",
    "level": "S1",
    "type": "web"
  }'
```

**Campos:**

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| name | string | Sim | Nome do app |
| description | string | Sim | Descrição |
| level | string | Sim | Nível (S1-S5) |
| type | string | Sim | Tipo (container, web, mini) |

---

## 6. Interface Administrativa

### 6.1 Funcionalidades

A interface admin permite:

- **Home**: Dashboard com todos os modelos cadastrados
- **Listar**: Visualizar registros de cada modelo
- **Adicionar**: Criar novos registros via formulário
- **Editar**: Modificar registros existentes
- **Excluir**: Remover registros

### 6.2 Modelos Cadastrados

| Modelo | Descrição |
|--------|-----------|
| BaseUser | Usuários do sistema |
| App | Aplicações |

### 6.3 URL da Interface Admin

| Página | URL |
|--------|-----|
| Home | `/admin` |
| Login | `/admin/login` |
| Registro | `/admin/register` |
| Listar modelo X | `/admin/<model>` |
| Adicionar modelo X | `/admin/<model>/add` |
| Editar item | `/admin/<model>/:id` |

---

## 7. Configurações Avançadas

### 7.1 Alterar Porta do Servidor

No arquivo `cmd/main.go`, linha 19:

```go
address := ":8080"  // Altere para ":9090" por exemplo
```

### 7.2 Configurações de Banco (config/config.yaml)

```yaml
mysql:
  prefix: "t_"                    # Prefixo das tabelas
  singular: false                # Usar singular em tabelas
  engine: "InnoDB"              # Engine do MySQL
  max-idle-conns: 10             # Conexões ociosas
  max-open-conns: 100           # Conexões abertas
  log-mode: true                # Log de queries
  log-zap: false                # Usar Zap para logs
```

### 7.3 Configurações de Log (config/config.yaml)

```yaml
zap:
  level: info                    # Nível de log (debug, info, warn, error)
  prefix: '[freeaiops/server]'  # Prefixo das mensagens
  format: json                  # Formato (json, console)
  director: log                 # Diretório dos logs
  show_line: true               # Mostrar linha do código
  log_in_console: true          # Log no console
```

### 7.4 Autenticação Admin (config/config.yaml)

```yaml
admin:
  enable: true                  # Habilitar admin
  auth: true                    # Requerer autenticação
```

Para desabilitar a autenticação temporariamente:

```yaml
admin:
  auth: false
```

---

## 8. Solução de Problemas

### 8.1 "Database connection failed"

Verifique:
- MySQL está rodando
- Credenciais corretas em `config/config.yaml`
- Banco de dados `freeaiops` existe

```bash
# Testar conexão MySQL
mysql -u root -p -e "SHOW DATABASES;"
```

### 8.2 "Port already in use"

Outro processo está usando a porta 8080:

```bash
# Linux/Mac
lsof -i :8080

# Parar o processo
kill <PID>
```

Ou altere a porta no `cmd/main.go`.

### 8.3 "Token expired"

O token JWT expirou. Faça login novamente para obter um novo token.

### 8.4 "User not found"

O usuário não existe no banco. Crie um novo usuário em `/admin/register`.

---

## 9. Variáveis de Ambiente (Recomendado)

Para produção, use variáveis de ambiente em vez de hardcoded no config.yaml:

```bash
export DB_HOST=localhost
export DB_PORT=3306
export DB_USER=root
export DB_PASS=sua_senha
export DB_NAME=freeaiops
export JWT_KEY=sua_chave_jwt_secreta
```

*(Nota: O projeto atualmente não suporta variáveis de ambiente nativamente - melhoria recomendada)*

---

## 10. Estrutura de Arquivos Importantes

| Arquivo | Descrição |
|---------|-----------|
| `cmd/main.go` | Ponto de entrada da aplicação |
| `cmd/migrate/main.go` | Migrações do banco de dados |
| `config/config.yaml` | Arquivo de configuração principal |
| `pkg/api/api.go` | Implementação da API genérica |
| `pkg/auth/user.go` | Autenticação de usuários |
| `pkg/model/mapper.go` | Acesso ao banco de dados |
| `middleware/logger.go` | Log de requisições |
| `utils/jwt.go` | Manipulação de tokens JWT |

---

## 11. Próximos Passos

1. ✅ Configurar banco de dados
2. ✅ Executar migrações
3. ✅ Iniciar servidor
4. ✅ Acessar interface admin
5. 🔄 Criar usuário administrador
6. 🔄 Explorar API RESTful
7. 🔄 Adicionar novos modelos

Para adicionar novos modelos, consulte a estrutura em `internal/app/` como referência.

---

*Guia gerado automaticamente em: 2026-05-10*