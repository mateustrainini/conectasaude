<?php
// ============================================================================
// CHATBOT HOSPITALAR - CONFIGURAÇÃO DE BANCO DE DADOS
// Fase 1: Conexão PDO
// ============================================================================

// Configurações do banco
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'chatbot_hospital');
define('DB_CHARSET', 'utf8mb4');

// Opções PDO
$opcoesPDO = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
];

// String de conexão
$dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;

try {
    $pdo = new PDO($dsn, DB_USER, DB_PASS, $opcoesPDO);
} catch (PDOException $e) {
    // Erro de conexão — não expor detalhes ao paciente
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erro ao conectar com o banco de dados. Tente novamente mais tarde.'
    ]);
    exit;
}

?>
