-- ============================================================================
# Script de Inicialização do Banco de Dados
# Executado automaticamente na primeira inicialização do MySQL
# ============================================================================

-- Criar usuário específico da aplicação (se não existir)
CREATE USER IF NOT EXISTS 'freeaiops'@'%' IDENTIFIED BY 'freeaiops123';
GRANT ALL PRIVILEGES ON *.* TO 'freeaiops'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- Garantir que o banco existe
CREATE DATABASE IF NOT EXISTS freeaiops CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Selecionar o banco
USE freeaiops;

-- ============================================================================
# Configurações adicionais podem ser adicionadas aqui
# Exemplo: Procedures, triggers, dados iniciais, etc.
# ============================================================================

-- Exemplo: Criar tabela de versão do banco
CREATE TABLE IF NOT EXISTS schema_version (
    version INT PRIMARY KEY,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(255)
);

INSERT INTO schema_version (version, description) VALUES (1, 'Initial schema');

-- Commit das alterações
COMMIT;