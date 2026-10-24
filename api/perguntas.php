<?php
// ============================================================================
// CHATBOT HOSPITALAR - API: Obter Perguntas
// GET /api/perguntas.php?categoria_id=X
// GET /api/perguntas.php?pergunta_pai_id=Y
// ============================================================================

require __DIR__ . '/../config/db.php';
require __DIR__ . '/helpers.php';

if (!eh_get()) {
    resposta_json(false, [], 'Método não permitido');
}

// ============================================================================
// RECEBER PARÂMETROS
// ============================================================================

$categoria_id = obter_get('categoria_id');
$pergunta_pai_id = obter_get('pergunta_pai_id');

// Validar que um dos dois foi fornecido
if (!$categoria_id && !$pergunta_pai_id) {
    resposta_json(false, [], 'Forneça categoria_id ou pergunta_pai_id');
}

try {
    if ($categoria_id) {
        // ====================================================================
        // PERGUNTAS RAIZ DA CATEGORIA
        // ====================================================================

        $categoria_id = validar_categoria_id($categoria_id);
        if (!$categoria_id) {
            resposta_json(false, [], 'Categoria inválida');
        }

        // Verificar se categoria existe
        $stmt = $pdo->prepare("SELECT id FROM categorias WHERE id = ? AND ativo = 1");
        $stmt->execute([$categoria_id]);
        if (!$stmt->fetch()) {
            resposta_json(false, [], 'Categoria não encontrada');
        }

        // Obter perguntas raiz
        $stmt = $pdo->prepare("
            SELECT id, pergunta 
            FROM perguntas 
            WHERE categoria_id = ? AND pergunta_pai_id IS NULL AND ativo = 1
            ORDER BY ordem ASC
        ");
        $stmt->execute([$categoria_id]);
        $perguntas = $stmt->fetchAll();

        resposta_json(true, [
            'perguntas' => $perguntas
        ]);

    } else {
        // ====================================================================
        // PERGUNTAS FILHAS DE UMA PERGUNTA
        // ====================================================================

        $pergunta_pai_id = validar_pergunta_id($pergunta_pai_id);
        if (!$pergunta_pai_id) {
            resposta_json(false, [], 'Pergunta inválida');
        }

        // Verificar se pergunta pai existe
        $stmt = $pdo->prepare("SELECT id FROM perguntas WHERE id = ? AND ativo = 1");
        $stmt->execute([$pergunta_pai_id]);
        if (!$stmt->fetch()) {
            resposta_json(false, [], 'Pergunta não encontrada');
        }

        // Obter filhos
        $stmt = $pdo->prepare("
            SELECT id, pergunta 
            FROM perguntas 
            WHERE pergunta_pai_id = ? AND ativo = 1
            ORDER BY ordem ASC
        ");
        $stmt->execute([$pergunta_pai_id]);
        $perguntas = $stmt->fetchAll();

        resposta_json(true, [
            'perguntas' => $perguntas
        ]);
    }

} catch (PDOException $e) {
    log_erro("Erro ao obter perguntas: " . $e->getMessage());
    resposta_json(false, [], 'Erro ao obter perguntas');
}

?>
