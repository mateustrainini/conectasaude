# Fase 7 — RAG / Base de conhecimento

## O que foi implementado
- tabela `conhecimentos`;
- migration segura em `config/fase7_migracao.sql`;
- painel `adm/conhecimentos.php` para cadastrar, editar e desativar conteúdo oficial;
- importação inicial das FAQs para a base de conhecimento;
- `api/rag.php`, responsável por recuperar apenas os conteúdos relacionados à pergunta;
- `api/buscarConhecimento.php`, endpoint para testar a recuperação sem depender de uma IA;
- `api/chatIA.php` agora executa a recuperação antes de qualquer chamada ao modelo;
- configuração de IA tornou-se neutra em relação ao provedor.

## Importante sobre Claude
A integração OpenAI da Fase 6 foi removida. O projeto não chama mais a API da OpenAI.
O conector de geração foi propositalmente deixado pendente até ser definida a API/chave de Claude que será usada.

## Atualizar um banco que já existe
Não execute o `schema.sql` inteiro novamente. Importe somente:

`config/fase7_migracao.sql`

Ele cria a tabela nova e copia as FAQs ativas como conteúdo inicial sem duplicar registros idênticos.

## Como testar a recuperação
Faça POST para `api/buscarConhecimento.php` com:

`mensagem=qual o horário de visitas?`

O JSON deve retornar somente os conhecimentos considerados relevantes.

## Estado do RAG
O fluxo agora é:

Pergunta -> recuperação -> poucos conteúdos relevantes -> IA (conector Claude pendente) -> resposta

A recuperação atual é textual e ponderada por título, palavras-chave, categoria e conteúdo. A busca vetorial/embeddings, necessária para uma busca semântica real, deve ser ligada quando for definido o provedor/modelo de embeddings. Isso evita amarrar a arquitetura à OpenAI.
