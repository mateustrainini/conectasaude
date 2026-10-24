<?php
// Recuperação da Fase 7. Independente do provedor de IA.

function normalizar_texto_rag(string $texto): string {
    $texto = mb_strtolower($texto, 'UTF-8');
    $mapa = ['á'=>'a','à'=>'a','ã'=>'a','â'=>'a','ä'=>'a','é'=>'e','è'=>'e','ê'=>'e','ë'=>'e','í'=>'i','ì'=>'i','î'=>'i','ï'=>'i','ó'=>'o','ò'=>'o','õ'=>'o','ô'=>'o','ö'=>'o','ú'=>'u','ù'=>'u','û'=>'u','ü'=>'u','ç'=>'c'];
    $texto = strtr($texto, $mapa);
    return trim((string) preg_replace('/[^a-z0-9\s]/u', ' ', $texto));
}

function termos_rag(string $texto): array {
    $ignoradas = ['a','o','as','os','de','da','do','das','dos','e','em','no','na','nos','nas','um','uma','para','por','com','que','qual','quais','como','me','eu','meu','minha','tem','ter','posso','pode'];
    $partes = preg_split('/\s+/', normalizar_texto_rag($texto), -1, PREG_SPLIT_NO_EMPTY);
    $termos = [];
    foreach ($partes as $termo) {
        if (mb_strlen($termo) >= 3 && !in_array($termo, $ignoradas, true)) {
            $termos[$termo] = true;
        }
    }
    return array_keys($termos);
}

function buscar_conhecimentos(PDO $pdo, string $pergunta, int $limite = 4): array {
    $stmt = $pdo->query("\n        SELECT k.id, k.titulo, k.conteudo, k.palavras_chave, c.nome AS categoria\n        FROM conhecimentos k\n        LEFT JOIN categorias c ON c.id = k.categoria_id\n        WHERE k.ativo = 1 AND (c.ativo = 1 OR k.categoria_id IS NULL)\n        ORDER BY k.data_atualizacao DESC, k.id DESC\n    ");
    $itens = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $termos = termos_rag($pergunta);
    if (!$termos) return [];

    foreach ($itens as &$item) {
        $titulo = normalizar_texto_rag($item['titulo']);
        $chaves = normalizar_texto_rag((string) $item['palavras_chave']);
        $conteudo = normalizar_texto_rag($item['conteudo']);
        $categoria = normalizar_texto_rag((string) $item['categoria']);
        $pontos = 0;
        foreach ($termos as $termo) {
            if (str_contains($titulo, $termo)) $pontos += 5;
            if ($chaves !== '' && str_contains($chaves, $termo)) $pontos += 4;
            if ($categoria !== '' && str_contains($categoria, $termo)) $pontos += 3;
            if (str_contains($conteudo, $termo)) $pontos += 1;
        }
        $item['relevancia'] = $pontos;
    }
    unset($item);

    $itens = array_values(array_filter($itens, fn($item) => $item['relevancia'] > 0));
    usort($itens, fn($a, $b) => $b['relevancia'] <=> $a['relevancia']);
    return array_slice($itens, 0, max(1, min($limite, 8)));
}
