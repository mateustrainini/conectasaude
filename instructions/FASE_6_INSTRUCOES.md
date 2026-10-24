# Fase 6 — Inteligência Artificial

Nesta fase foi mantido o chatbot por botões/FAQs e acrescentado o primeiro canal de texto livre com IA.

## O que foi implementado

- Campo `Digite sua dúvida...` dentro do chat.
- Novo endpoint `api/chatIA.php`.
- Integração PHP -> OpenAI Responses API usando cURL.
- A API Key permanece somente no servidor.
- As FAQs ativas do MySQL são enviadas como fonte oficial da resposta.
- A IA recebe regras para não inventar informações hospitalares.
- Perguntas clínicas não devem gerar diagnóstico ou prescrição.
- Possíveis emergências recebem orientação para atendimento de emergência.
- O sistema continua funcionando normalmente pelos botões mesmo se a IA não estiver configurada.

## Arquivos novos

### `config/ia.php`
Lê a chave da variável de ambiente `OPENAI_API_KEY` e permite configurar o modelo com `OPENAI_MODEL`.

### `api/chatIA.php`
Valida a conversa e a mensagem, lê as FAQs ativas, monta as instruções da IA, chama a Responses API e devolve JSON ao JavaScript.

## Arquivos alterados

- `index.php`: campo de texto e botão Enviar.
- `assets/js/chatbot.js`: envio da pergunta por Fetch e exibição da resposta.
- `assets/css/chatbot.css`: estilo responsivo do campo da IA.

## Configuração local no WAMP

A chave NÃO deve ser escrita no JavaScript, no Git ou diretamente no arquivo do projeto.

Antes de testar, configure no ambiente do Apache/PHP:

```text
OPENAI_API_KEY=sua_chave_aqui
```

Opcionalmente:

```text
OPENAI_MODEL=gpt-6-luna
```

Depois reinicie o Apache.

Também confirme que a extensão PHP `curl` está habilitada.

## Importante: ainda não é RAG

Na Fase 6 todas as FAQs ativas são fornecidas à IA como contexto. A busca semântica/recuperação apenas dos trechos relevantes fica para a Fase 7, conforme o planejamento original.

## Testes sugeridos

1. Inicie uma conversa normalmente.
2. Teste os botões de FAQ e confirme que continuam funcionando.
3. Digite uma pergunta equivalente a uma FAQ, por exemplo: `Que horas posso visitar um paciente?`.
4. Digite algo não cadastrado e confirme que a IA não inventa uma resposta.
5. Teste uma pergunta clínica e confirme que o sistema não tenta diagnosticar.
6. Remova temporariamente a variável `OPENAI_API_KEY` e confirme que o chatbot por botões continua funcionando.

## Próxima fase

Fase 7: RAG — base de conhecimento, busca de conteúdo relevante e envio apenas das fontes recuperadas para a IA.
