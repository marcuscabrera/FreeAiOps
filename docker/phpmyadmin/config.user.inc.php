<?php
/**
 * Configurações personalizadas do PhpMyAdmin
 */

// Configuração de upload
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';

// Configurações de tampilan
$cfg['DefaultLang'] = 'pt_BR';
$cfg['DefaultConnectionCollation'] = 'utf8mb4_unicode_ci';

// Segurança
$cfg['AllowUserDropDatabase'] = false;
$cfg['DisableWarningCheck'] = false;

// Sessões
$cfg['SessionSavePath'] = '/sessions';

// Tema
$cfg['ThemeManager'] = true;
$cfg['ThemeDefault'] = 'pmahomme';

// Número de registros por página
$cfg['MaxRows'] = 50;

// Exportação
$cfg['Export']['method'] = 'quick';
$cfg['Export']['charset'] = 'utf8mb4';