<?php
// ============================================================================
// CHATBOT HOSPITALAR - FUNÇÕES AUXILIARES
// Fase 3: Validação, resposta JSON, tratamento de erros
// ============================================================================

// Header JSON
header('Content-Type: application/json; charset=utf-8');

// ============================================================================
// RESPOSTA JSON
// ============================================================================

function resposta_json($success, $data = [], $message = '') {
    $resposta = [
        'success' => $success
    ];

    if ($message) {
        $resposta['message'] = $message;
    }

    // Mesclar dados adicionais
    if (is_array($data) && !empty($data)) {
        $resposta = array_merge($resposta, $data);
    }

    http_response_code($success ? 200 : 400);
    echo json_encode($resposta, JSON_UNESCAPED_UNICODE);
    exit;
}

// ============================================================================
// VALIDAÇÃO
// ============================================================================

function validar_nome($nome) {
    $nome = trim($nome);
    if (empty($nome) || strlen($nome) < 2 || strlen($nome) > 255) {
        return false;
    }
    return $nome;
}

function validar_data($data) {
    // Formato: YYYY-MM-DD
    if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $data)) {
        return false;
    }
    
    // Verificar se é uma data válida
    $partes = explode('-', $data);
    if (!checkdate($partes[1], $partes[2], $partes[0])) {
        return false;
    }
    
    // Não permitir data no futuro
    if (strtotime($data) > time()) {
        return false;
    }
    
    return $data;
}

function validar_conversa_id($conversa_id) {
    if (empty($conversa_id) || !is_string($conversa_id) || strlen($conversa_id) > 100) {
        return false;
    }
    return $conversa_id;
}

function validar_pergunta_id($id) {
    if (!is_numeric($id) || $id <= 0) {
        return false;
    }
    return (int)$id;
}

function validar_categoria_id($id) {
    if (!is_numeric($id) || $id <= 0) {
        return false;
    }
    return (int)$id;
}

// ============================================================================
// MÉTODO HTTP
// ============================================================================

function obter_metodo_http() {
    return $_SERVER['REQUEST_METHOD'];
}

function eh_post() {
    return obter_metodo_http() === 'POST';
}

function eh_get() {
    return obter_metodo_http() === 'GET';
}

// ============================================================================
// INPUT
// ============================================================================

function obter_post($chave, $padrao = null) {
    return isset($_POST[$chave]) ? $_POST[$chave] : $padrao;
}

function obter_get($chave, $padrao = null) {
    return isset($_GET[$chave]) ? $_GET[$chave] : $padrao;
}

// ============================================================================
// LOGGING (opcional, para debug)
// ============================================================================

function log_erro($mensagem) {
    $arquivo = __DIR__ . '/logs/erros.log';
    
    // Criar pasta se não existir
    if (!is_dir(__DIR__ . '/logs')) {
        mkdir(__DIR__ . '/logs', 0755, true);
    }
    
    $timestamp = date('Y-m-d H:i:s');
    file_put_contents($arquivo, "[$timestamp] $mensagem\n", FILE_APPEND);
}

// ============================================================================
// SANITIZAÇÃO PARA OUTPUT
// ============================================================================

function sanitizar_output($texto) {
    return htmlspecialchars($texto, ENT_QUOTES, 'UTF-8');
}

?>
