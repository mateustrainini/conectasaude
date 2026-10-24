<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/rag.php';

if (!eh_post()) resposta_json(false, [], 'Método não permitido');
$mensagem = trim((string) obter_post('mensagem', ''));
if (mb_strlen($mensagem) < 2 || mb_strlen($mensagem) > 1000) resposta_json(false, [], 'Pergunta inválida');

try {
    $fontes = buscar_conhecimentos($pdo, $mensagem, 4);
    resposta_json(true, ['fontes' => $fontes, 'quantidade' => count($fontes)]);
} catch (Throwable $e) {
    log_erro('Erro na recuperação RAG: ' . $e->getMessage());
    resposta_json(false, [], 'Não foi possível pesquisar a base de conhecimento');
}
