# Fase 4 — Administração

A Fase 4 foi integrada ao projeto existente sem frameworks.

## Arquivos principais

- `adm/login.php`: autenticação do administrador com `password_verify()` e regeneração do ID da sessão.
- `adm/logout.php`: encerra a sessão administrativa.
- `adm/index.php`: página inicial da administração. Os indicadores atuais são apenas apoio visual; a expansão estatística completa pertence à Fase 5.
- `adm/categorias.php`: cadastro, edição, ordenação e desativação de categorias.
- `adm/perguntas.php`: cadastro, edição, hierarquia, ordenação e desativação de perguntas/respostas.
- `adm/conversas.php`: lista as últimas conversas e permite visualizar o histórico de cada atendimento.
- `adm/sessao.php`: protege as páginas administrativas.
- `assets/css/adm.css`: estilos do painel.

## Acesso

1. Importe/atualize `config/schema.sql`.
2. Configure `config/db.php`.
3. Acesse `http://localhost/chat/adm/login.php` (ajuste `chat` ao nome da pasta local).

O `schema.sql` contém um administrador fictício para desenvolvimento. Em ambiente real, substitua-o e use uma senha forte gerada com `password_hash()`.

## Observação sobre a estrutura

O ZIP recebido tinha arquivos das fases anteriores espalhados entre `api/` e `views/`, enquanto os próprios links internos já esperavam a estrutura `adm/` e `assets/`. A estrutura funcional foi normalizada na raiz, mantendo os arquivos antigos no ZIP como referência para não apagar o trabalho anterior.

## Checklist da Fase 4

- [x] autenticação administrativa;
- [x] proteção por sessão;
- [x] CRUD lógico de categorias (`ativo = 0` em vez de exclusão física);
- [x] CRUD lógico de perguntas/respostas;
- [x] definição de pergunta pai;
- [x] ordenação;
- [x] visualização de conversas;
- [x] visualização do histórico de uma conversa.

Antes da Fase 5, teste login, criação/edição/desativação de categoria, criação/edição/desativação de pergunta e abertura do histórico de uma conversa real gerada pelo chatbot.
