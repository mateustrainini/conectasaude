# OpenRouter — configuração da IA

O chatbot agora usa o endpoint `https://openrouter.ai/api/v1/chat/completions`.

## 1. Configurar a chave no WAMP (Windows)

A chave não deve ser colocada no JavaScript nem enviada ao navegador.

### Opção recomendada para desenvolvimento local

Crie um arquivo `.env` na pasta raiz do projeto (ao lado de `index.php`):

```dotenv
OPENROUTER_API_KEY=sk-or-v1-sua-chave
OPENROUTER_MODEL=google/gemma-4-31b-it:free
OPENROUTER_FALLBACK_MODELS=liquid/lfm-2.5-2.6b:free
```

O `.env` já é ignorado pelo Git e a aplicação o lê diretamente a cada requisição. O arquivo não deve ser enviado ao repositório. O `.htaccess` bloqueia seu acesso via navegador.

Se o modelo principal estiver indisponível ou limitado, o OpenRouter tenta os modelos alternativos na ordem configurada. Para evitar cobranças inesperadas, o modelo principal e todos os alternativos precisam terminar em `:free`; a API rejeita a configuração se algum não for gratuito. Os modelos gratuitos disponíveis podem mudar; confirme os IDs atuais no catálogo do OpenRouter.

### Variáveis de ambiente do Windows/servidor

Também é possível configurar as variáveis no ambiente do servidor:

- Nome: `OPENROUTER_API_KEY`
- Valor: sua chave `sk-or-v1-...`

Opcionalmente crie também:

- Nome: `OPENROUTER_MODEL`
- Valor: o slug do modelo que você quer usar no OpenRouter.

Variáveis disponibilizadas ao processo PHP têm prioridade sobre o `.env`. Ao alterar variáveis de ambiente do Windows, reinicie o serviço do Apache/WAMP para que ele herde os novos valores.

Se `OPENROUTER_MODEL` não estiver definido em nenhuma dessas fontes, o projeto usa por padrão:

`google/gemma-4-31b-it:free`

Depois de alterar variáveis de ambiente, reinicie completamente o WAMP/Apache.

## 2. Verificar cURL

No `php.ini` utilizado pelo Apache, a extensão cURL precisa estar habilitada. No WAMP ela normalmente pode ser habilitada pelo menu PHP > PHP extensions > curl.

Se o log mostrar `SSL certificate problem: unable to get local issuer certificate`, configure também o arquivo de certificados CA no `php.ini` do Apache:

```ini
curl.cainfo = "C:\caminho\para\cacert.pem"
```

Use um bundle CA confiável e existente na máquina. No WAMP, confirme o `php.ini` do Apache pelo menu PHP; não confunda com o `php.ini` do terminal. Reinicie o Apache depois de alterar a configuração. Não desative a verificação SSL (`CURLOPT_SSL_VERIFYPEER`).

## 3. Arquivos alterados

### `config/ia.php`
Define OpenRouter como provedor, lê as variáveis de ambiente e o `.env` local, lê os modelos principal e alternativos e configura o endpoint do OpenRouter.

### `api/chatIA.php`
O fluxo agora é:

Pergunta -> RAG -> conhecimentos relevantes -> OpenRouter -> modelo escolhido -> resposta

A chave nunca é devolvida ao frontend.

## 4. Trocar o modelo

Não é necessário alterar `chatIA.php`. Troque apenas a variável `OPENROUTER_MODEL`.

O valor precisa ser o ID/slug exato exibido pelo OpenRouter, por exemplo um modelo `anthropic/...`.

## 5. Teste

1. Inicie uma conversa normalmente no chatbot.
2. Faça uma pergunta cuja resposta exista na Base de Conhecimento.
3. O `api/chatIA.php` recuperará até 4 conhecimentos relevantes.
4. Esses conteúdos e a pergunta serão enviados ao OpenRouter.
5. A resposta será exibida no chat.

Se a pergunta não encontrar conteúdo no RAG, nenhuma chamada à IA é feita.
Falhas temporárias (limitação, indisponibilidade ou erro de conexão) recebem uma nova tentativa. A resposta da IA foi limitada a 250 tokens para reduzir o uso de créditos.

## Segurança

Nunca coloque a chave em `assets/js/chatbot.js`, `index.php` ou qualquer HTML enviado ao navegador. Em produção, configure `OPENROUTER_API_KEY` diretamente no ambiente do servidor/hospedagem.
