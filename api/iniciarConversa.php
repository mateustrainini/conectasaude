<?php
// ============================================================================
// CHATBOT HOSPITALAR - API: Iniciar Conversa
// POST /api/iniciarConversa.php
// ============================================================================

require __DIR__ . '/../config/db.php';
require __DIR__ . '/helpers.php';

if (!eh_post()) {
    resposta_json(false, [], 'Método não permitido');
}

// ============================================================================
// RECEBER DADOS
// ============================================================================

$nome = validar_nome(obter_post('nome'));
$data_nascimento = validar_data(obter_post('data_nascimento'));

if (!$nome || !$data_nascimento) {
    resposta_json(false, [], 'Nome ou data de nascimento inválidos');
}

// ============================================================================
// PROCURAR OU CRIAR PACIENTE
// ============================================================================

try {
    // Procurar paciente existente
    $stmt = $pdo->prepare("
        SELECT id FROM pacientes 
        WHERE nome = ? AND data_nascimento = ?
        LIMIT 1
    ");
    $stmt->execute([$nome, $data_nascimento]);
    $paciente = $stmt->fetch();

    if ($paciente) {
        $paciente_id = $paciente['id'];
    } else {
        // Criar novo paciente
        $stmt = $pdo->prepare("
            INSERT INTO pacientes (nome, data_nascimento) 
            VALUES (?, ?)
        ");
        $stmt->execute([$nome, $data_nascimento]);
        $paciente_id = $pdo->lastInsertId();
    }

    // ========================================================================
    // CRIAR CONVERSA
    // ========================================================================

    $stmt = $pdo->prepare("
        INSERT INTO conversas (paciente_id, status) 
        VALUES (?, 'ativa')
    ");
    $stmt->execute([$paciente_id]);
    $conversa_id = $pdo->lastInsertId();

    // ========================================================================
    // RETORNAR SUCESSO
    // ========================================================================

    resposta_json(true, [
        'paciente_id' => (int)$paciente_id,
        'conversa_id' => (int)$conversa_id,
        'paciente_nome' => $nome
    ]);

} catch (PDOException $e) {
    log_erro("Erro ao iniciar conversa: " . $e->getMessage());
    resposta_json(false, [], 'Erro ao iniciar conversa');
}

?>
