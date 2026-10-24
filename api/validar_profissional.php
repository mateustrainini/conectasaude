<?php
header('Cache-Control: no-store, private');
header('X-Content-Type-Options: nosniff');
require __DIR__ . '/helpers.php';
require __DIR__ . '/../config/db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Allow: POST');
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Este endpoint permite somente validação por POST.',
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$cpfInput = $_POST['cpf'] ?? '';
$corenInput = $_POST['coren'] ?? '';
if (!is_string($cpfInput) || !is_string($corenInput)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Informe um CPF e um COREN válidos.',
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$cpf = preg_replace('/\D/', '', $cpfInput);
$coren = strtoupper(preg_replace('/\s+/', '', trim($corenInput)));

if (strlen($cpf) !== 11 || !preg_match('/^[A-Z0-9.\/-]{4,30}$/', $coren)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Informe um CPF com 11 dígitos e um COREN válido.',
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $statement = $pdo->prepare("
        SELECT nome, coren
        FROM profissionais_saude
        WHERE cpf = ? AND coren = ? AND ativo = 1
        LIMIT 1
    ");
    $statement->execute([$cpf, $coren]);
    $professional = $statement->fetch();

    echo json_encode([
        'success' => true,
        'valid' => $professional !== false,
        'professional' => $professional ?: null,
        'message' => $professional
            ? 'Profissional encontrado no cadastro de demonstração.'
            : 'CPF e COREN não correspondem a um cadastro ativo.',
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $error) {
    log_erro('Erro ao validar profissional de demonstração: ' . $error->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Não foi possível validar o profissional. Tente novamente.',
    ], JSON_UNESCAPED_UNICODE);
}
