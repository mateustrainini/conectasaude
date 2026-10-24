<?php
// Configuração da IA via OpenRouter.
// A chave deve ficar somente no servidor, nunca no JavaScript.
$iaCarregarEnv = static function (): array {
    $arquivo = dirname(__DIR__) . DIRECTORY_SEPARATOR . '.env';
    if (!is_readable($arquivo)) {
        return [];
    }

    $variaveis = [];
    $linhas = file($arquivo, FILE_IGNORE_NEW_LINES);
    if ($linhas === false) {
        return [];
    }

    foreach ($linhas as $indice => $linha) {
        if ($indice === 0) {
            $linha = preg_replace('/^\xEF\xBB\xBF/', '', $linha);
        }
        $linha = trim($linha);
        if ($linha === '' || strpos($linha, '#') === 0) {
            continue;
        }

        if (strpos($linha, 'export ') === 0) {
            $linha = substr($linha, 7);
        }

        $separador = strpos($linha, '=');
        if ($separador === false) {
            continue;
        }

        $nome = trim(substr($linha, 0, $separador));
        if (!preg_match('/^[A-Z0-9_]+$/i', $nome)) {
            continue;
        }

        $valor = trim(substr($linha, $separador + 1));
        if (strlen($valor) >= 2) {
            $aspasInicio = $valor[0];
            $aspasFim = substr($valor, -1);
            if (($aspasInicio === '"' || $aspasInicio === "'") && $aspasFim === $aspasInicio) {
                $valor = substr($valor, 1, -1);
            }
        }

        $variaveis[$nome] = $valor;
    }

    return $variaveis;
};

$iaEnvLocal = $iaCarregarEnv();
$iaObterVariavel = static function (string $nome, string $padrao = '') use ($iaEnvLocal): string {
    $valor = getenv($nome);
    if ($valor !== false && trim($valor) !== '') {
        return trim($valor);
    }

    foreach ([$_SERVER, $_ENV] as $origem) {
        if (isset($origem[$nome]) && trim((string) $origem[$nome]) !== '') {
            return trim((string) $origem[$nome]);
        }
    }

    $valorLocal = $iaEnvLocal[$nome] ?? '';
    return trim($valorLocal) !== '' ? $valorLocal : $padrao;
};

define('IA_PROVEDOR', 'openrouter');
define(
    'IA_API_KEY',
    $iaObterVariavel('OPENROUTER_API_KEY', '')
);

define(
    'IA_MODEL',
    $iaObterVariavel(
        'OPENROUTER_MODEL',
        'google/gemma-3-27b-it:free'
    )
);
define('IA_API_URL', 'https://openrouter.ai/api/v1/chat/completions');
?>
