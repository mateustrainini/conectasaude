# Fase 5 — Dashboard

A Fase 5 foi adicionada sobre a administração já criada na Fase 4, sem alterar o fluxo do chatbot.

## O que foi implementado

O dashboard em `adm/index.php` agora consulta os dados reais do banco e apresenta:

- atendimentos iniciados hoje;
- atendimentos iniciados no mês atual;
- quantidade total de pacientes cadastrados;
- quantidade de conversas ainda ativas;
- volume de atendimentos dos últimos 7 dias;
- 5 perguntas mais acessadas;
- 5 categorias mais acessadas;
- 5 faixas de horário com maior número de atendimentos.

## Como as estatísticas são calculadas

### Atendimentos

São calculados a partir da tabela `conversas` e do campo `inicio`.

### Perguntas populares

São calculadas pelos registros da tabela `historico`, agrupados por `pergunta_id`.

### Categorias populares

Cada interação registrada em `historico` é relacionada à pergunta e, em seguida, à categoria dessa pergunta. Assim é possível contar quantas interações cada categoria recebeu sem criar uma tabela nova.

### Horários de maior movimento

As conversas são agrupadas pela hora do campo `conversas.inicio`.

### Últimos 7 dias

O banco retorna o total de conversas por dia. Dias sem atendimento são completados com zero no PHP para o gráfico sempre mostrar os sete dias.

## Arquivos alterados

- `adm/index.php`: dashboard completo e consultas estatísticas.
- `assets/css/adm.css`: cards, rankings, gráfico simples e responsividade do dashboard.

## Banco de dados

Nenhuma tabela nova é necessária para a Fase 5. As estatísticas usam `pacientes`, `conversas`, `historico`, `perguntas` e `categorias`, que já fazem parte do projeto.

## Teste recomendado

1. Entre no chatbot como pacientes fictícios e gere algumas conversas.
2. Clique em perguntas de categorias diferentes.
3. Encerre algumas conversas e deixe pelo menos uma ativa.
4. Entre em `adm/`.
5. Confira se os cards e rankings refletem as interações realizadas.

Os rankings só terão dados depois que existirem registros reais na tabela `historico`.

## Fase concluída

- [x] atendimentos hoje;
- [x] atendimentos no mês;
- [x] perguntas populares;
- [x] categorias populares;
- [x] quantidade de pacientes;
- [x] horários com maior número de atendimentos;
- [x] volume recente de atendimentos;
- [x] layout responsivo;
- [x] sem dependência de framework ou biblioteca de gráficos.

A próxima etapa planejada é a **Fase 6 — IA**, mas ela não foi iniciada neste pacote.
