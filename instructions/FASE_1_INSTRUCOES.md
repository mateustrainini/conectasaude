# FASE 1: Banco de Dados — Instruções

## 1. Criar banco e tabelas

### Via MySQL CLI

```bash
mysql -u root -p < config/schema.sql
```

Ou, se não tiver senha:

```bash
mysql -u root < config/schema.sql
```

### Via phpMyAdmin

1. Copie o conteúdo de `schema.sql`
2. Vá para **SQL** no phpMyAdmin
3. Cole e execute

## 2. Ajustar credenciais (se necessário)

Abra `db.php` e altere:

```php
define('DB_USER', 'seu_usuario');
define('DB_PASS', 'sua_senha');
```

## 3. Testar conexão

Crie um arquivo `teste_conexao.php` na raiz do projeto:

```php
<?php
require 'db.php';

try {
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM pacientes");
    $resultado = $stmt->fetch();
    
    echo "✓ Conexão OK\n";
    echo "Pacientes no banco: " . $resultado['total'] . "\n";
} catch (PDOException $e) {
    echo "✗ Erro: " . $e->getMessage();
}
?>
```

Acesse pelo navegador ou rode:

```bash
php teste_conexao.php
```

## 4. O que foi criado

### Banco: `conecta_saude`

**Tabelas:**

- `pacientes` — 4 pacientes fictícios de exemplo
- `categorias` — 5 categorias (Internação, Exames, Convênios, Consultas, Contato)
- `perguntas` — ~20 perguntas em árvore (ex: Internação > Visitas > Qual o horário?)
- `conversas` — vazia, será preenchida quando pacientes usarem
- `historico` — vazia, registrará cada clique
- `administradores` — 1 admin de teste

### Dados fictícios

**Pacientes:**
- João Silva (15/05/1980)
- Maria Santos (22/08/1975)
- Pedro Oliveira (10/03/1990)
- Ana Costa (28/12/1985)

**Categorias:**
- 🏥 Internação
- 🧪 Exames
- 💳 Convênios
- 👨‍⚕️ Consultas
- 📞 Contato

**Exemplo de árvore (Internação):**

```
Internação
├── Visitas
│   ├── Qual o horário de visitas?
│   ├── Quantos visitantes podem entrar?
│   └── Menores de idade podem visitar?
├── Acompanhantes
│   ├── Quem pode ser acompanhante?
│   └── Existe limite de idade para acompanhante?
└── Documentos
    ├── Quais documentos devo levar?
    └── Preciso levar roupa?
```

(Mesma estrutura para Exames e Convênios.)

### Admin de teste

- Email: `admin@hospital.local`
- Senha: `admin123`

(Hash: `$2y$10$PQwMT8RJ4m/fnKTKH3GnBelJZEDjrRt1M7tKvmcqg4Q8LkUwzQfxy`)

## 5. Próxima etapa (Fase 2)

Com o banco pronto, partiremos para a **interface do chatbot** (HTML, CSS, JS).

Ele será construído como uma tela de identificação + chat responsivo, usando dados fictícios ou chamadas à API (que faremos na Fase 3).

## 6. Arquivos da Fase 1

```
schema.sql          — criação do banco e dados
db.php              — conexão PDO
FASE_1_INSTRUCOES.md — este arquivo
```

Coloque `db.php` em um lugar seguro (ex: pasta `config/`) onde a API PHP possa incluí-lo com `require 'config/db.php'`.

## Portal de demonstração

O arquivo único `config/schema.sql` cria ou atualiza as tabelas e inclui os
dados fictícios do portal. Execute o mesmo comando acima tanto em uma
instalação nova quanto no banco existente; a criação das tabelas e a inserção
dos exemplos são idempotentes.

O portal também inclui uma lista de espera demonstrativa. A classificação por
cor pode mudar conforme a quantidade de dias de espera. As cores são fictícias
e não representam critérios de triagem ou orientação médica.

Os dados inseridos são fictícios. A API pública do portal só retorna pacientes
marcados com `dados_demonstracao = 1`; não use esse modo sem autenticação com
dados reais. Abra `http://localhost/conectasaude/assets/index.html` pelo Apache
para que o navegador consiga chamar a API PHP.
