<?php
// ============================================================================
// CHATBOT HOSPITALAR - API: Responder Pergunta
// POST /api/responder.php
// ============================================================================

require __DIR__ . '/config/db.php';
require __DIR__ . '/helpers.php';

if (!eh_post()) {
    resposta_json(false, [], 'Método não permitido');
}

// ============================================================================
// RECEBER DADOS
// ============================================================================

$conversa_id = validar_conversa_id(obter_post('conversa_id'));
$pergunta_id = validar_pergunta_id(obter_post('pergunta_id'));

if (!$conversa_id || !$pergunta_id) {
    resposta_json(false, [], 'Dados inválidos');
}

try {
    // ========================================================================
    // VERIFICAR SE CONVERSA EXISTE E ESTÁ ATIVA
    // ========================================================================

    $stmt = $pdo->prepare("
        SELECT id FROM conversas 
        WHERE id = ? AND status = 'ativa'
        LIMIT 1
    ");
    $stmt->execute([$conversa_id]);
    if (!$stmt->fetch()) {
        resposta_json(false, [], 'Conversa não encontrada ou encerrada');
    }

    // ========================================================================
    // OBTER PERGUNTA E RESPOSTA
    // ========================================================================

    $stmt = $pdo->prepare("
        SELECT id, pergunta, resposta, categoria_id
        FROM perguntas 
        WHERE id = ? AND ativo = 1
        LIMIT 1
    ");
    $stmt->execute([$pergunta_id]);
    $pergunta = $stmt->fetch();

    if (!$pergunta) {
        resposta_json(false, [], 'Pergunta não encontrada');
    }

    // ========================================================================
    // REGISTRAR INTERAÇÃO NO HISTÓRICO
    // ========================================================================

    $stmt = $pdo->prepare("
        INSERT INTO historico (conversa_id, pergunta_id) 
        VALUES (?, ?)
    ");
    $stmt->execute([$conversa_id, $pergunta_id]);

    // ========================================================================
    // OBTER PRÓXIMAS OPÇÕES (FILHOS)
    // ========================================================================

    $stmt = $pdo->prepare("
        SELECT id, pergunta 
        FROM perguntas 
        WHERE pergunta_pai_id = ? AND ativo = 1
        ORDER BY ordem ASC
    ");
    $stmt->execute([$pergunta_id]);
    $opcoes = $stmt->fetchAll();

    // ========================================================================
    // RETORNAR RESPOSTA
    // ========================================================================

    resposta_json(true, [
        'pergunta' => sanitizar_output($pergunta['pergunta']),
        'resposta' => sanitizar_output($pergunta['resposta']),
        'opcoes' => $opcoes
    ]);

} catch (PDOException $e) {
    log_erro("Erro ao responder pergunta: " . $e->getMessage());
    resposta_json(false, [], 'Erro ao processar pergunta');
}

?>
