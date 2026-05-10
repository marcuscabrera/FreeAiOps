# AGENTS.md - FreeAiOps Development Guide

## Project Overview
- **Language**: Go 1.18
- **Framework**: Gin + GORM
- **Config**: Viper (YAML)
- **Port**: 8080 (default)
- **Database**: MySQL

## Run Commands

```bash
# Run the main application
go run cmd/main.go

# Run database migrations (creates tables)
go run cmd/migrate/main.go
```

## Key Directories

| Directory | Purpose |
|-----------|---------|
| `cmd/` | Entry points: main.go (app), migrate/main.go (DB setup) |
| `config/` | Configuration + autoload (db, jwt, zap, admin) |
| `initialize/` | Startup sequence: viper → zap → gorm → router → admin |
| `pkg/api/` | REST API handlers with generic CRUD |
| `pkg/model/` | Database models |
| `pkg/service/` | Business logic layer |
| `pkg/router/` | Route binding helpers |
| `middleware/` | Recovery + Logger |
| `utils/` | Helpers (json, jwt, cache, hash, etc.) |

## Configuration

Edit `config/config.yaml`:
- Database: MySQL connection (default: root/123456@localhost:3306/freeaiops)
- JWT: signing-key, expiration
- Log: level, format (json/console), output dir (default: `log/`)

## API Structure

- Base path: `/api/v1`
- Health check: `GET /health`
- CRUD pattern: `GET/POST/PUT/DELETE` on `/api/v1/<resource>` and `/api/v1/<resource>/:id`
- Swagger: Available (swaggo)

## Development Notes

1. **AutoMigrate**: Tables auto-created via `initialize.RegisterTables()` - currently registers `auth.BaseUser{}` and `app.App{}`
2. **No Makefile**: Build/run manually with `go run`
3. **No tests**: No test files in this repo
4. **Templates**: HTML templates in `templates/` for server-rendered pages
5. **JWT**: Token-based auth, configured in `config/autoload/jwt.go`

## Gotchas

- Config loading is mandatory before any init - see `cmd/main.go` initialization order
- Gorm must be initialized before router (db connection required for model binding)
- `utils.CheckError()` panics on error - not for production error handling
- Git origin: git@github.com:marcuscabrera/FreeAiOps.git

## Existing Skills (in .agents/skills/)

The repo contains custom OpenCode skills in `.agents/skills/`:
- `bash-*`, `cloud-*`, `python-*`, `prompt-*`, `skill-*` etc.
- These are project-specific skills for agent orchestration