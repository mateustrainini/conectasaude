<?php
// ============================================================================
// CHATBOT HOSPITALAR - API: Finalizar Conversa
// POST /api/finalizarConversa.php
// ============================================================================

require __DIR__ . '/../config/db.php';
require __DIR__ . '/helpers.php';

if (!eh_post()) {
    resposta_json(false, [], 'Método não permitido');
}

// ============================================================================
// RECEBER DADOS
// ============================================================================

$conversa_id = validar_conversa_id(obter_post('conversa_id'));

if (!$conversa_id) {
    resposta_json(false, [], 'Conversa inválida');
}

try {
    // ========================================================================
    // ATUALIZAR STATUS DA CONVERSA
    // ========================================================================

    $stmt = $pdo->prepare("
        UPDATE conversas 
        SET status = 'encerrada', fim = CURRENT_TIMESTAMP
        WHERE id = ? AND status = 'ativa'
    ");
    $stmt->execute([$conversa_id]);

    if ($stmt->rowCount() === 0) {
        resposta_json(false, [], 'Conversa não encontrada ou já encerrada');
    }

    // ========================================================================
    // RETORNAR SUCESSO
    // ========================================================================

    resposta_json(true, [
        'mensagem' => 'Conversa encerrada com sucesso'
    ]);

} catch (PDOException $e) {
    log_erro("Erro ao finalizar conversa: " . $e->getMessage());
    resposta_json(false, [], 'Erro ao finalizar conversa');
}

?>
