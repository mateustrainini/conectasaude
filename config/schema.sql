-- ============================================================================
-- CHATBOT HOSPITALAR - SCHEMA
-- Fase 1: Banco de dados
-- ============================================================================
CREATE DATABASE IF NOT EXISTS conecta_saude
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE conecta_saude;

-- ============================================================================
-- TABELA: unidades_saude
-- ============================================================================

CREATE TABLE IF NOT EXISTS unidades_saude (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    tipo ENUM('ubs', 'hospital', 'clinica', 'laboratorio') NOT NULL,
    endereco VARCHAR(500) NULL,
    latitude DECIMAL(10, 7) NULL,
    longitude DECIMAL(10, 7) NULL,
    horario_atendimento VARCHAR(255) NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_unidade_tipo_ativo (tipo, ativo),
    INDEX idx_unidade_nome (nome)
);

-- ============================================================================
-- TABELA: pacientes
-- ============================================================================

CREATE TABLE IF NOT EXISTS pacientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    data_nascimento DATE NOT NULL,
    cpf CHAR(11) NULL,
    cns CHAR(15) NULL,
    sexo ENUM('feminino', 'masculino', 'nao_informado') NOT NULL DEFAULT 'nao_informado',
    telefone VARCHAR(30) NULL,
    endereco VARCHAR(500) NULL,
    unidade_saude_id INT NULL,
    portal_acesso_status ENUM('pendente', 'liberado', 'revogado') NOT NULL DEFAULT 'pendente',
    dados_demonstracao TINYINT(1) NOT NULL DEFAULT 0,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uk_paciente_cpf (cpf),
    UNIQUE KEY uk_paciente_cns (cns),
    INDEX idx_paciente_unidade (unidade_saude_id),
    INDEX idx_nome_data (nome, data_nascimento),
    CONSTRAINT fk_paciente_unidade
        FOREIGN KEY (unidade_saude_id) REFERENCES unidades_saude(id) ON DELETE SET NULL
);

-- Cadastro fictício para validar o fluxo de encaminhamento do portal.
CREATE TABLE IF NOT EXISTS profissionais_saude (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cpf CHAR(11) NOT NULL,
    coren VARCHAR(30) NOT NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    dados_demonstracao TINYINT(1) NOT NULL DEFAULT 0,

    UNIQUE KEY uk_profissional_cpf (cpf),
    UNIQUE KEY uk_profissional_coren (coren)
);

-- Completa a tabela de pacientes em bancos criados com uma versão anterior.
SET @portal_sql = IF(
    (SELECT COUNT(*) FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pacientes' AND COLUMN_NAME = 'cpf') = 0,
    'ALTER TABLE pacientes ADD COLUMN cpf CHAR(11) NULL',
    'SELECT 1'
);
PREPARE portal_stmt FROM @portal_sql;
EXECUTE portal_stmt;
DEALLOCATE PREPARE portal_stmt;

SET @portal_sql = IF(
    (SELECT COUNT(*) FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pacientes' AND COLUMN_NAME = 'cns') = 0,
    'ALTER TABLE pacientes ADD COLUMN cns CHAR(15) NULL',
    'SELECT 1'
);
PREPARE portal_stmt FROM @portal_sql;
EXECUTE portal_stmt;
DEALLOCATE PREPARE portal_stmt;

SET @portal_sql = IF(
    (SELECT COUNT(*) FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pacientes' AND COLUMN_NAME = 'sexo') = 0,
    'ALTER TABLE pacientes ADD COLUMN sexo ENUM(''feminino'', ''masculino'', ''nao_informado'') NOT NULL DEFAULT ''nao_informado''',
    'SELECT 1'
);
PREPARE portal_stmt FROM @portal_sql;
EXECUTE portal_stmt;
DEALLOCATE PREPARE portal_stmt;

SET @portal_sql = IF(
    (SELECT COUNT(*) FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pacientes' AND COLUMN_NAME = 'telefone') = 0,
    'ALTER TABLE pacientes ADD COLUMN telefone VARCHAR(30) NULL',
    'SELECT 1'
);
PREPARE portal_stmt FROM @portal_sql;
EXECUTE portal_stmt;
DEALLOCATE PREPARE portal_stmt;

SET @portal_sql = IF(
    (SELECT COUNT(*) FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pacientes' AND COLUMN_NAME = 'endereco') = 0,
    'ALTER TABLE pacientes ADD COLUMN endereco VARCHAR(500) NULL',
    'SELECT 1'
);
PREPARE portal_stmt FROM @portal_sql;
EXECUTE portal_stmt;
DEALLOCATE PREPARE portal_stmt;

SET @portal_sql = IF(
    (SELECT COUNT(*) FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pacientes' AND COLUMN_NAME = 'unidade_saude_id') = 0,
    'ALTER TABLE pacientes ADD COLUMN unidade_saude_id INT NULL',
    'SELECT 1'
);
PREPARE portal_stmt FROM @portal_sql;
EXECUTE portal_stmt;
DEALLOCATE PREPARE portal_stmt;

SET @portal_sql = IF(
    (SELECT COUNT(*) FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pacientes' AND COLUMN_NAME = 'portal_acesso_status') = 0,
    'ALTER TABLE pacientes ADD COLUMN portal_acesso_status ENUM(''pendente'', ''liberado'', ''revogado'') NOT NULL DEFAULT ''pendente''',
    'SELECT 1'
);
PREPARE portal_stmt FROM @portal_sql;
EXECUTE portal_stmt;
DEALLOCATE PREPARE portal_stmt;

SET @portal_sql = IF(
    (SELECT COUNT(*) FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pacientes' AND COLUMN_NAME = 'dados_demonstracao') = 0,
    'ALTER TABLE pacientes ADD COLUMN dados_demonstracao TINYINT(1) NOT NULL DEFAULT 0',
    'SELECT 1'
);
PREPARE portal_stmt FROM @portal_sql;
EXECUTE portal_stmt;
DEALLOCATE PREPARE portal_stmt;

SET @portal_sql = IF(
    (SELECT COUNT(*) FROM information_schema.STATISTICS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pacientes' AND INDEX_NAME = 'uk_paciente_cpf') = 0,
    'ALTER TABLE pacientes ADD UNIQUE KEY uk_paciente_cpf (cpf)',
    'SELECT 1'
);
PREPARE portal_stmt FROM @portal_sql;
EXECUTE portal_stmt;
DEALLOCATE PREPARE portal_stmt;

SET @portal_sql = IF(
    (SELECT COUNT(*) FROM information_schema.STATISTICS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pacientes' AND INDEX_NAME = 'uk_paciente_cns') = 0,
    'ALTER TABLE pacientes ADD UNIQUE KEY uk_paciente_cns (cns)',
    'SELECT 1'
);
PREPARE portal_stmt FROM @portal_sql;
EXECUTE portal_stmt;
DEALLOCATE PREPARE portal_stmt;

SET @portal_sql = IF(
    (SELECT COUNT(*) FROM information_schema.STATISTICS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pacientes' AND INDEX_NAME = 'idx_paciente_unidade') = 0,
    'ALTER TABLE pacientes ADD INDEX idx_paciente_unidade (unidade_saude_id)',
    'SELECT 1'
);
PREPARE portal_stmt FROM @portal_sql;
EXECUTE portal_stmt;
DEALLOCATE PREPARE portal_stmt;

SET @portal_sql = IF(
    (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
     WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'pacientes'
       AND CONSTRAINT_NAME = 'fk_paciente_unidade') = 0,
    'ALTER TABLE pacientes ADD CONSTRAINT fk_paciente_unidade FOREIGN KEY (unidade_saude_id) REFERENCES unidades_saude(id) ON DELETE SET NULL',
    'SELECT 1'
);
PREPARE portal_stmt FROM @portal_sql;
EXECUTE portal_stmt;
DEALLOCATE PREPARE portal_stmt;

-- ============================================================================
-- DADOS CLÍNICOS DO PORTAL DO PACIENTE
-- ============================================================================

CREATE TABLE IF NOT EXISTS registros_clinicos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    unidade_saude_id INT NULL,
    tipo ENUM(
        'consulta',
        'exame',
        'internacao',
        'alta',
        'encaminhamento',
        'acompanhamento'
    ) NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    detalhes LONGTEXT NULL,
    origem VARCHAR(150) NULL,
    ocorrido_em DATETIME NOT NULL,
    documento_url VARCHAR(2048) NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_registro_paciente
        FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE,
    CONSTRAINT fk_registro_unidade
        FOREIGN KEY (unidade_saude_id) REFERENCES unidades_saude(id) ON DELETE SET NULL,
    INDEX idx_registro_paciente_data (paciente_id, ocorrido_em),
    INDEX idx_registro_tipo (tipo)
);

CREATE TABLE IF NOT EXISTS vacinas_paciente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    dose VARCHAR(100) NULL,
    status ENUM('pendente', 'aplicada') NOT NULL DEFAULT 'pendente',
    aplicada_em DATE NULL,
    proxima_dose_em DATE NULL,
    observacoes TEXT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_vacina_paciente
        FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE,
    INDEX idx_vacina_paciente_status (paciente_id, status),
    INDEX idx_vacina_proxima_dose (proxima_dose_em)
);

CREATE TABLE IF NOT EXISTS exames_paciente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    unidade_solicitante_id INT NULL,
    unidade_executora_id INT NULL,
    nome VARCHAR(255) NOT NULL,
    solicitante VARCHAR(255) NULL,
    status ENUM('solicitado', 'agendado', 'concluido') NOT NULL DEFAULT 'solicitado',
    solicitado_em DATETIME NOT NULL,
    agendado_para DATETIME NULL,
    instrucoes TEXT NULL,
    resultado_resumo LONGTEXT NULL,
    documento_url VARCHAR(2048) NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_exame_paciente
        FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE,
    CONSTRAINT fk_exame_unidade_solicitante
        FOREIGN KEY (unidade_solicitante_id) REFERENCES unidades_saude(id) ON DELETE SET NULL,
    CONSTRAINT fk_exame_unidade_executora
        FOREIGN KEY (unidade_executora_id) REFERENCES unidades_saude(id) ON DELETE SET NULL,
    INDEX idx_exame_paciente_status_data (paciente_id, status, solicitado_em),
    INDEX idx_exame_agendado (agendado_para)
);

CREATE TABLE IF NOT EXISTS consultas_agendadas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    unidade_saude_id INT NULL,
    profissional VARCHAR(255) NULL,
    motivo VARCHAR(500) NULL,
    agendado_para DATETIME NOT NULL,
    status ENUM('agendada', 'realizada', 'cancelada') NOT NULL DEFAULT 'agendada',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_consulta_paciente
        FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE,
    CONSTRAINT fk_consulta_unidade
        FOREIGN KEY (unidade_saude_id) REFERENCES unidades_saude(id) ON DELETE SET NULL,
    INDEX idx_consulta_paciente_data (paciente_id, agendado_para),
    INDEX idx_consulta_unidade_data (unidade_saude_id, agendado_para)
);

CREATE TABLE IF NOT EXISTS lista_espera (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    unidade_saude_id INT NULL,
    procedimento VARCHAR(255) NOT NULL,
    classificacao_inicial ENUM('verde', 'amarelo', 'azul', 'vermelho') NOT NULL DEFAULT 'verde',
    dias_ate_reclassificacao SMALLINT UNSIGNED NULL,
    data_entrada DATE NOT NULL,
    status ENUM('aguardando', 'realizado', 'cancelado') NOT NULL DEFAULT 'aguardando',
    observacoes TEXT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_lista_espera_paciente
        FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE,
    CONSTRAINT fk_lista_espera_unidade
        FOREIGN KEY (unidade_saude_id) REFERENCES unidades_saude(id) ON DELETE SET NULL,
    INDEX idx_lista_espera_paciente_status (paciente_id, status),
    INDEX idx_lista_espera_data_entrada (data_entrada)
);

CREATE TABLE IF NOT EXISTS altas_hospitalares (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    hospital_id INT NULL,
    unidade_referencia_id INT NULL,
    resumo LONGTEXT NOT NULL,
    orientacoes LONGTEXT NULL,
    retorno_recomendado VARCHAR(500) NULL,
    status ENUM('pendente', 'enviada', 'recebida', 'acompanhamento') NOT NULL DEFAULT 'pendente',
    alta_em DATETIME NOT NULL,
    enviada_em DATETIME NULL,
    recebida_em DATETIME NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_alta_paciente
        FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE,
    CONSTRAINT fk_alta_hospital
        FOREIGN KEY (hospital_id) REFERENCES unidades_saude(id) ON DELETE SET NULL,
    CONSTRAINT fk_alta_unidade_referencia
        FOREIGN KEY (unidade_referencia_id) REFERENCES unidades_saude(id) ON DELETE SET NULL,
    INDEX idx_alta_paciente_data (paciente_id, alta_em),
    INDEX idx_alta_status (status)
);

CREATE TABLE IF NOT EXISTS acessos_prontuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    unidade_saude_id INT NULL,
    profissional VARCHAR(255) NOT NULL,
    motivo VARCHAR(500) NULL,
    acessado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_acesso_paciente
        FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE,
    CONSTRAINT fk_acesso_unidade
        FOREIGN KEY (unidade_saude_id) REFERENCES unidades_saude(id) ON DELETE SET NULL,
    INDEX idx_acesso_paciente_data (paciente_id, acessado_em)
);

-- ============================================================================
-- TABELA: categorias
-- ============================================================================

CREATE TABLE IF NOT EXISTS categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    icone VARCHAR(10),
    ordem INT NOT NULL DEFAULT 0,
    ativo TINYINT(1) DEFAULT 1,
    
    UNIQUE KEY uk_nome (nome)
);

-- ============================================================================
-- TABELA: perguntas
-- Estrutura em árvore (pergunta_pai_id = NULL significa que aparece no menu da categoria)
-- ============================================================================

CREATE TABLE IF NOT EXISTS perguntas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    categoria_id INT NOT NULL,
    pergunta VARCHAR(500) NOT NULL,
    resposta LONGTEXT NOT NULL,
    pergunta_pai_id INT,
    pergunta_pai_chave INT GENERATED ALWAYS AS (IFNULL(pergunta_pai_id, 0)) STORED,
    ordem INT NOT NULL DEFAULT 0,
    ativo TINYINT(1) DEFAULT 1,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (pergunta_pai_id) REFERENCES perguntas(id) ON DELETE RESTRICT,
    
    INDEX idx_categoria_ativo_ordem (categoria_id, ativo, ordem),
    INDEX idx_pergunta_pai_ativo (pergunta_pai_id, ativo, ordem),
    UNIQUE KEY uk_pergunta_contexto (categoria_id, pergunta_pai_chave, pergunta(191))
);

SET @portal_sql = IF(
    (SELECT COUNT(*) FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'perguntas'
       AND COLUMN_NAME = 'pergunta_pai_chave') = 0,
    'ALTER TABLE perguntas ADD COLUMN pergunta_pai_chave INT GENERATED ALWAYS AS (IFNULL(pergunta_pai_id, 0)) STORED',
    'SELECT 1'
);
PREPARE portal_stmt FROM @portal_sql;
EXECUTE portal_stmt;
DEALLOCATE PREPARE portal_stmt;

SET @portal_sql = IF(
    (SELECT COUNT(*) FROM information_schema.STATISTICS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'perguntas'
       AND INDEX_NAME = 'uk_pergunta_contexto') = 0,
    'ALTER TABLE perguntas ADD UNIQUE KEY uk_pergunta_contexto (categoria_id, pergunta_pai_chave, pergunta(191))',
    'SELECT 1'
);
PREPARE portal_stmt FROM @portal_sql;
EXECUTE portal_stmt;
DEALLOCATE PREPARE portal_stmt;

-- ============================================================================
-- TABELA: conversas
-- ============================================================================

CREATE TABLE IF NOT EXISTS conversas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fim TIMESTAMP NULL,
    status ENUM('ativa', 'encerrada') DEFAULT 'ativa',
    
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE RESTRICT,
    
    INDEX idx_paciente_id (paciente_id),
    INDEX idx_status (status)
);

-- ============================================================================
-- TABELA: historico
-- Registra cada interação (clique) do paciente
-- ============================================================================

CREATE TABLE IF NOT EXISTS historico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conversa_id INT NOT NULL,
    pergunta_id INT NOT NULL,
    data_interacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (conversa_id) REFERENCES conversas(id) ON DELETE RESTRICT,
    FOREIGN KEY (pergunta_id) REFERENCES perguntas(id) ON DELETE RESTRICT,
    
    INDEX idx_conversa_id (conversa_id),
    INDEX idx_pergunta_id (pergunta_id)
);

-- ============================================================================
-- TABELA: conhecimentos
-- Fase 7: base de conhecimento recuperada antes da geração por IA
-- ============================================================================

CREATE TABLE IF NOT EXISTS conhecimentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    conteudo LONGTEXT NOT NULL,
    categoria_id INT NULL,
    palavras_chave VARCHAR(500),
    ativo TINYINT(1) DEFAULT 1,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL,
    INDEX idx_conhecimento_categoria_ativo (categoria_id, ativo),
    INDEX idx_conhecimento_ativo (ativo)
);

-- ============================================================================
-- TABELA: administradores
-- Para login na área administrativo (Fase 4)
-- ============================================================================

CREATE TABLE IF NOT EXISTS administradores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    ativo TINYINT(1) DEFAULT 1,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_email (email)
);

-- ============================================================================
-- DADOS FICTÍCIOS
-- ============================================================================

-- Categorias
INSERT IGNORE INTO categorias (id, nome, icone, ordem, ativo) VALUES
(1, 'Internação', '🏥', 1, 1),
(2, 'Exames', '🧪', 2, 1),
(3, 'Convênios', '💳', 3, 1),
(4, 'Consultas', '👨‍⚕️', 4, 1),
(5, 'Contato', '📞', 5, 1);

-- Pacientes fictícios
INSERT INTO pacientes (nome, data_nascimento)
SELECT demonstracao.nome, demonstracao.data_nascimento
FROM (
    SELECT 'João Silva' AS nome, '1980-05-15' AS data_nascimento
    UNION ALL SELECT 'Maria Santos', '1975-08-22'
    UNION ALL SELECT 'Pedro Oliveira', '1990-03-10'
    UNION ALL SELECT 'Ana Costa', '1985-12-28'
) AS demonstracao
WHERE NOT EXISTS (
    SELECT 1 FROM pacientes existente
    WHERE existente.nome = demonstracao.nome
      AND existente.data_nascimento = demonstracao.data_nascimento
);

-- Perguntas - Internação (categoria_id = 1)
INSERT IGNORE INTO perguntas (categoria_id, pergunta, resposta, pergunta_pai_id, ordem, ativo) VALUES
-- Menu raiz de Internação
(1, 'Visitas', 'Informações sobre horário e regras de visitas.', NULL, 1, 1),
(1, 'Acompanhantes', 'Quem pode acompanhar o paciente internado.', NULL, 2, 1),
(1, 'Documentos', 'Quais documentos levar para a internação.', NULL, 3, 1),

-- Submenu de Visitas (pergunta_pai_id = 1)
(1, 'Qual o horário de visitas?', 'As visitas são permitidas diariamente de 13h30 às 17h30.', 1, 1, 1),
(1, 'Quantos visitantes podem entrar?', 'Até 2 visitantes por vez, máximo 4 visitas ao dia.', 1, 2, 1),
(1, 'Menores de idade podem visitar?', 'Menores devem estar acompanhados de um responsável. Menores de 12 anos precisam de autorização do médico.', 1, 3, 1),

-- Submenu de Acompanhantes (pergunta_pai_id = 2)
(1, 'Quem pode ser acompanhante?', 'Familiares ou pessoa indicada pelo paciente, com maioridade legal.', 2, 1, 1),
(1, 'Existe limite de idade para acompanhante?', 'O acompanhante deve ser maior de 18 anos.', 2, 2, 1),

-- Submenu de Documentos (pergunta_pai_id = 3)
(1, 'Quais documentos devo levar?', 'RG, CPF, comprovante de endereço, cartão do convênio ou documentos de identificação.', 3, 1, 1),
(1, 'Preciso levar roupa?', 'A roupa será fornecida pelo hospital. Pode trazer roupas pessoais se desejar, mas o hospital não se responsabiliza.', 3, 2, 1);

-- Perguntas - Exames (categoria_id = 2)
INSERT IGNORE INTO perguntas (categoria_id, pergunta, resposta, pergunta_pai_id, ordem, ativo) VALUES
-- Menu raiz de Exames
(2, 'Preparo para exame', 'Como se preparar para diferentes tipos de exames.', NULL, 1, 1),
(2, 'Resultado de exame', 'Como consultar e receber resultados.', NULL, 2, 1),

-- Submenu de Preparo (pergunta_pai_id = 8)
(2, 'Preciso fazer jejum?', 'Depende do tipo de exame. Consulte a requisição ou entre em contato com o laboratório.', 8, 1, 1),
(2, 'Posso tomar remédios antes do exame?', 'Comunique ao médico sobre qualquer medicação. Alguns devem ser suspensos antes do exame.', 8, 2, 1),

-- Submenu de Resultado (pergunta_pai_id = 9)
(2, 'Quanto tempo demora para sair o resultado?', 'Geralmente 48 a 72 horas. Alguns exames rápidos saem no mesmo dia.', 9, 1, 1),
(2, 'Como recebo o resultado?', 'Pessoalmente, por email ou pelo portal de pacientes. Consulte a forma escolhida no momento do agendamento.', 9, 2, 1);

-- Perguntas - Convênios (categoria_id = 3)
INSERT IGNORE INTO perguntas (categoria_id, pergunta, resposta, pergunta_pai_id, ordem, ativo) VALUES
-- Menu raiz de Convênios
(3, 'Convênios aceitos', 'Lista de convênios e planos aceitos.', NULL, 1, 1),
(3, 'Autorizações', 'Procedimentos de autorização de procedimentos.', NULL, 2, 1),

-- Submenu de Convênios aceitos (pergunta_pai_id = 15)
(3, 'Quais convênios vocês aceitam?', 'Aceitamos a maioria dos convênios do mercado. Verifique sua carteira para confirmar.', 15, 1, 1),
(3, 'Posso consultar se meu plano é aceito?', 'Entre em contato pelo telefone 3333-3333 ou visite a recepção.', 15, 2, 1),

-- Submenu de Autorizações (pergunta_pai_id = 16)
(3, 'Como solicitar autorização para procedimento?', 'Ligue para seu convênio com a requisição do médico ou passe na recepção.', 16, 1, 1),
(3, 'Quanto tempo leva para sair a autorização?', 'Geralmente 48 horas úteis. Procedimentos emergenciais são autorizados no ato.', 16, 2, 1);

-- Pacientes fictícios adicionais (opcional)
-- INSERT INTO pacientes (nome, data_nascimento) VALUES
-- ('Carlos Mendes', '1965-11-05'),
-- ('Beatriz Alves', '1995-06-18');

-- Administrador fictício para testes (senha: admin123 — hash gerado com password_hash)
INSERT IGNORE INTO administradores (nome, email, senha_hash, ativo) VALUES
('Admin Hospital', 'admin@hospital.local', '$2y$10$PQwMT8RJ4m/fnKTKH3GnBelJZEDjrRt1M7tKvmcqg4Q8LkUwzQfxy', 1);

-- Nota: O hash acima é 'admin123' com password_hash(). Para alterar, execute em PHP:
-- echo password_hash('suaSenha', PASSWORD_BCRYPT);

-- Importa as FAQs atuais como base inicial sem duplicar títulos/conteúdos iguais.
INSERT INTO conhecimentos (titulo, conteudo, categoria_id, palavras_chave, ativo)
SELECT p.pergunta, p.resposta, p.categoria_id, p.pergunta, 1
FROM perguntas p
WHERE p.ativo = 1
AND NOT EXISTS (
    SELECT 1 FROM conhecimentos k
    WHERE k.titulo = p.pergunta AND k.conteudo = p.resposta
);

-- ============================================================================
-- DADOS FICTICIOS DO PORTAL DE DEMONSTRACAO
-- ============================================================================

INSERT INTO unidades_saude
    (nome, tipo, endereco, horario_atendimento, ativo)
SELECT demonstracao.nome, demonstracao.tipo, demonstracao.endereco,
       demonstracao.horario, 1
FROM (
    SELECT 'UBS Vila Nova (Demonstração)' AS nome, 'ubs' AS tipo,
           'Rua das Flores, 100, Cidade de Demonstração - RS' AS endereco,
           'Segunda a sexta, das 8h às 17h' AS horario
    UNION ALL
    SELECT 'UBS Centro (Demonstração)', 'ubs',
           'Rua Central, 200, Cidade de Demonstração - RS',
           'Segunda a sexta, das 8h às 17h'
    UNION ALL
    SELECT 'Hospital Municipal (Demonstração)', 'hospital',
           'Avenida da Saúde, 300, Cidade de Demonstração - RS',
           'Atendimento 24 horas'
    UNION ALL
    SELECT 'Hospital Santa Clara (Demonstração)', 'hospital',
           'Rua do Hospital, 400, Cidade de Demonstração - RS',
           'Atendimento 24 horas'
    UNION ALL
    SELECT 'Clínica Saúde Integral (Demonstração)', 'clinica',
           'Rua das Acácias, 500, Cidade de Demonstração - RS',
           'Segunda a sexta, das 8h às 19h'
    UNION ALL
    SELECT 'Clínica Bem Viver (Demonstração)', 'clinica',
           'Rua das Palmeiras, 600, Cidade de Demonstração - RS',
           'Segunda a sexta, das 8h às 18h'
    UNION ALL
    SELECT 'Laboratório Vida (Demonstração)', 'laboratorio',
           'Rua dos Exames, 700, Cidade de Demonstração - RS',
           'Segunda a sexta, das 7h às 16h'
    UNION ALL
    SELECT 'Laboratório Central (Demonstração)', 'laboratorio',
           'Avenida Central, 800, Cidade de Demonstração - RS',
           'Segunda a sexta, das 7h às 15h'
) AS demonstracao
WHERE NOT EXISTS (
    SELECT 1
    FROM unidades_saude existente
    WHERE existente.nome = demonstracao.nome
      AND existente.tipo = demonstracao.tipo
);

INSERT INTO profissionais_saude (nome, cpf, coren, ativo, dados_demonstracao)
SELECT demonstracao.nome, demonstracao.cpf, demonstracao.coren, 1, 1
FROM (
    SELECT 'Profissional de Enfermagem (Demonstração)' AS nome,
           '99999999999' AS cpf, '000001-TE/RS' AS coren
) AS demonstracao
WHERE NOT EXISTS (
    SELECT 1
    FROM profissionais_saude existente
    WHERE existente.cpf = demonstracao.cpf
       OR existente.coren = demonstracao.coren
);

INSERT INTO pacientes
    (nome, data_nascimento, cpf, cns, sexo, telefone, endereco,
     unidade_saude_id, portal_acesso_status, dados_demonstracao)
SELECT demonstracao.nome, demonstracao.data_nascimento, demonstracao.cpf,
       demonstracao.cns, demonstracao.sexo, demonstracao.telefone,
       demonstracao.endereco, unidade.id, 'liberado', 1
FROM (
    SELECT 'Maria Aparecida Souza (Demonstração)' AS nome,
           '1968-03-12' AS data_nascimento, '00000000001' AS cpf,
           '000000000000001' AS cns, 'feminino' AS sexo,
           '(00) 90000-0001' AS telefone,
           'Rua das Flores, 10, Cidade de Demonstração - RS' AS endereco,
           'UBS Vila Nova (Demonstração)' AS unidade
    UNION ALL
    SELECT 'Carlos Eduardo Lima (Demonstração)', '1954-09-02',
           '00000000002', '000000000000002', 'masculino',
           '(00) 90000-0002',
           'Rua Central, 20, Cidade de Demonstração - RS',
           'UBS Centro (Demonstração)'
    UNION ALL
    SELECT 'Ana Beatriz Rocha (Demonstração)', '1992-06-21',
           '00000000003', '000000000000003', 'feminino',
           '(00) 90000-0003',
           'Rua das Acácias, 30, Cidade de Demonstração - RS',
           'UBS Vila Nova (Demonstração)'
) AS demonstracao
JOIN unidades_saude unidade
  ON unidade.nome = demonstracao.unidade
WHERE NOT EXISTS (
    SELECT 1
    FROM pacientes existente
    WHERE existente.cpf = demonstracao.cpf
);

INSERT INTO registros_clinicos
    (paciente_id, unidade_saude_id, tipo, titulo, detalhes, origem, ocorrido_em)
SELECT paciente.id, unidade.id, registro.tipo, registro.titulo,
       registro.detalhes, registro.origem, registro.ocorrido_em
FROM (
    SELECT '00000000001' AS cpf, 'internacao' AS tipo,
           'Internação por pneumonia' AS titulo,
           'Registro clínico fictício para demonstração.' AS detalhes,
           'Pronto-socorro' AS origem, '2026-10-14 09:00:00' AS ocorrido_em,
           'Hospital Municipal (Demonstração)' AS unidade
    UNION ALL
    SELECT '00000000001', 'encaminhamento',
           'Encaminhamento ao pronto-socorro',
           'Encaminhamento fictício para avaliação médica.',
           'Atenção básica', '2026-10-13 10:00:00',
           'UBS Vila Nova (Demonstração)'
    UNION ALL
    SELECT '00000000001', 'exame', 'Raio-X de tórax',
           'Resultado fictício disponível para demonstração.',
           'Rede de demonstração', '2026-10-10 11:00:00',
           'Laboratório Vida (Demonstração)'
    UNION ALL
    SELECT '00000000001', 'consulta', 'Consulta clínica',
           'Consulta fictícia de demonstração.',
           'Atenção básica', '2026-10-09 09:00:00',
           'UBS Vila Nova (Demonstração)'
    UNION ALL
    SELECT '00000000002', 'consulta', 'Acompanhamento de rotina',
           'Registro clínico fictício para demonstração.',
           'Atenção básica', '2026-09-18 09:00:00',
           'UBS Centro (Demonstração)'
    UNION ALL
    SELECT '00000000003', 'consulta', 'Consulta de rotina',
           'Registro clínico fictício para demonstração.',
           'Rede de demonstração', '2026-07-05 09:00:00',
           'Clínica Saúde Integral (Demonstração)'
) AS registro
JOIN pacientes paciente
  ON paciente.cpf = registro.cpf
 AND paciente.dados_demonstracao = 1
JOIN unidades_saude unidade
  ON unidade.nome = registro.unidade
WHERE NOT EXISTS (
    SELECT 1
    FROM registros_clinicos existente
    WHERE existente.paciente_id = paciente.id
      AND existente.tipo = registro.tipo
      AND existente.titulo = registro.titulo
      AND existente.ocorrido_em = registro.ocorrido_em
);

INSERT INTO vacinas_paciente
    (paciente_id, nome, dose, status, aplicada_em, proxima_dose_em, observacoes)
SELECT paciente.id, vacina.nome, vacina.dose, vacina.status,
       vacina.aplicada_em, vacina.proxima_dose_em, vacina.observacoes
FROM (
    SELECT '00000000001' AS cpf, 'Influenza 2026' AS nome,
           'Dose única' AS dose, 'aplicada' AS status,
           '2026-04-15' AS aplicada_em, NULL AS proxima_dose_em,
           'Registro fictício de demonstração.' AS observacoes
    UNION ALL
    SELECT '00000000001', 'COVID-19 (reforço)', 'Reforço',
           'aplicada', '2025-11-11', NULL,
           'Registro fictício de demonstração.'
    UNION ALL
    SELECT '00000000001', 'Hepatite B', '3 doses',
           'aplicada', '2025-03-10', NULL,
           'Esquema fictício de demonstração.'
    UNION ALL
    SELECT '00000000001', 'Dupla adulto (dT)', 'Reforço',
           'pendente', NULL, '2026-10-28',
           'Dose fictícia pendente para demonstração.'
    UNION ALL
    SELECT '00000000001', 'Pneumocócica 23', 'Dose única',
           'pendente', NULL, NULL,
           'Indicação fictícia para demonstração.'
    UNION ALL
    SELECT '00000000002', 'Influenza 2026', 'Dose única',
           'pendente', NULL, NULL,
           'Registro fictício de demonstração.'
    UNION ALL
    SELECT '00000000003', 'Dupla adulto (dT)', 'Reforço',
           'aplicada', '2026-02-10', NULL,
           'Registro fictício de demonstração.'
) AS vacina
JOIN pacientes paciente
  ON paciente.cpf = vacina.cpf
 AND paciente.dados_demonstracao = 1
WHERE NOT EXISTS (
    SELECT 1
    FROM vacinas_paciente existente
    WHERE existente.paciente_id = paciente.id
      AND existente.nome = vacina.nome
      AND existente.dose = vacina.dose
);

INSERT INTO exames_paciente
    (paciente_id, unidade_solicitante_id, unidade_executora_id, nome,
     solicitante, status, solicitado_em, agendado_para, instrucoes,
     resultado_resumo)
SELECT paciente.id, solicitante.id, executora.id, exame.nome,
       exame.profissional, exame.status, exame.solicitado_em,
       exame.agendado_para, exame.instrucoes, exame.resultado
FROM (
    SELECT '00000000001' AS cpf, 'Espirometria' AS nome,
           'Profissional de demonstração' AS profissional,
           'solicitado' AS status, '2026-10-14 10:00:00' AS solicitado_em,
           NULL AS agendado_para, 'Instruções fictícias de demonstração.' AS instrucoes,
           NULL AS resultado, 'Hospital Municipal (Demonstração)' AS unidade_solicitante,
           NULL AS unidade_executora
    UNION ALL
    SELECT '00000000001', 'Raio-X de controle',
           'Profissional de demonstração', 'agendado',
           '2026-10-14 10:30:00', '2026-10-28 08:30:00',
           'Não exige jejum. Instrução fictícia de demonstração.',
           NULL, 'Hospital Municipal (Demonstração)',
           'Laboratório Vida (Demonstração)'
    UNION ALL
    SELECT '00000000001', 'Raio-X de tórax',
           'Profissional de demonstração', 'concluido',
           '2026-10-09 09:30:00', NULL, NULL,
           'Resultado fictício disponível para demonstração.',
           'UBS Vila Nova (Demonstração)',
           'Laboratório Vida (Demonstração)'
    UNION ALL
    SELECT '00000000002', 'Hemoglobina glicada',
           'Profissional de demonstração', 'concluido',
           '2026-09-10 09:30:00', NULL, NULL,
           'Resultado fictício de demonstração.',
           'UBS Centro (Demonstração)',
           'Laboratório Vida (Demonstração)'
) AS exame
JOIN pacientes paciente
  ON paciente.cpf = exame.cpf
 AND paciente.dados_demonstracao = 1
LEFT JOIN unidades_saude solicitante
  ON solicitante.nome = exame.unidade_solicitante
LEFT JOIN unidades_saude executora
  ON executora.nome = exame.unidade_executora
WHERE NOT EXISTS (
    SELECT 1
    FROM exames_paciente existente
    WHERE existente.paciente_id = paciente.id
      AND existente.nome = exame.nome
      AND existente.solicitado_em = exame.solicitado_em
);

INSERT INTO consultas_agendadas
    (paciente_id, unidade_saude_id, profissional, motivo, agendado_para, status)
SELECT paciente.id, unidade.id, 'Profissional de demonstração',
       consulta.motivo, consulta.agendado_para, consulta.status
FROM (
    SELECT '00000000001' AS cpf,
           'Retorno fictício após atendimento de demonstração.' AS motivo,
           '2026-10-26 09:00:00' AS agendado_para,
           'agendada' AS status, 'UBS Vila Nova (Demonstração)' AS unidade
    UNION ALL
    SELECT '00000000002', 'Consulta fictícia de acompanhamento.',
           '2026-11-18 09:00:00', 'agendada',
           'UBS Centro (Demonstração)'
) AS consulta
JOIN pacientes paciente
  ON paciente.cpf = consulta.cpf
 AND paciente.dados_demonstracao = 1
JOIN unidades_saude unidade
  ON unidade.nome = consulta.unidade
WHERE NOT EXISTS (
    SELECT 1
    FROM consultas_agendadas existente
    WHERE existente.paciente_id = paciente.id
      AND existente.agendado_para = consulta.agendado_para
      AND existente.motivo = consulta.motivo
);

INSERT INTO altas_hospitalares
    (paciente_id, hospital_id, unidade_referencia_id, resumo, orientacoes,
     retorno_recomendado, status, alta_em, enviada_em, recebida_em)
SELECT paciente.id, hospital.id, referencia.id,
       'Resumo clínico fictício: paciente estável após atendimento de demonstração.',
       'Orientações fictícias para demonstração. Consulte a equipe de saúde.',
       'Retorno fictício na UBS em 48 horas.',
       'recebida', '2026-10-23 10:00:00',
       '2026-10-23 10:30:00', '2026-10-23 11:00:00'
FROM pacientes paciente
JOIN unidades_saude hospital
  ON hospital.nome = 'Hospital Municipal (Demonstração)'
JOIN unidades_saude referencia
  ON referencia.nome = 'UBS Vila Nova (Demonstração)'
WHERE paciente.cpf = '00000000001'
  AND paciente.dados_demonstracao = 1
  AND NOT EXISTS (
      SELECT 1
      FROM altas_hospitalares existente
      WHERE existente.paciente_id = paciente.id
        AND existente.alta_em = '2026-10-23 10:00:00'
  );

INSERT INTO acessos_prontuario
    (paciente_id, unidade_saude_id, profissional, motivo, acessado_em)
SELECT paciente.id, unidade.id, 'Equipe fictícia da UBS',
       'Acesso de demonstração ao prontuário.',
       '2026-10-20 10:12:00'
FROM pacientes paciente
JOIN unidades_saude unidade
  ON unidade.nome = 'UBS Vila Nova (Demonstração)'
WHERE paciente.cpf = '00000000001'
  AND paciente.dados_demonstracao = 1
  AND NOT EXISTS (
      SELECT 1
      FROM acessos_prontuario existente
      WHERE existente.paciente_id = paciente.id
        AND existente.unidade_saude_id = unidade.id
        AND existente.acessado_em = '2026-10-20 10:12:00'
  );

INSERT INTO acessos_prontuario
    (paciente_id, unidade_saude_id, profissional, motivo, acessado_em)
SELECT paciente.id, unidade.id, 'Equipe fictícia do hospital',
       'Acesso de demonstração ao prontuário.',
       '2026-10-14 21:40:00'
FROM pacientes paciente
JOIN unidades_saude unidade
  ON unidade.nome = 'Hospital Municipal (Demonstração)'
WHERE paciente.cpf = '00000000001'
  AND paciente.dados_demonstracao = 1
  AND NOT EXISTS (
      SELECT 1
      FROM acessos_prontuario existente
      WHERE existente.paciente_id = paciente.id
        AND existente.unidade_saude_id = unidade.id
        AND existente.acessado_em = '2026-10-14 21:40:00'
  );

-- Procedimentos fictícios para demonstrar a mudança de cor conforme o tempo de espera.
UPDATE lista_espera existente
JOIN pacientes paciente
  ON paciente.id = existente.paciente_id
 AND paciente.dados_demonstracao = 1
SET existente.data_entrada = DATE_SUB(CURRENT_DATE, INTERVAL 100 DAY),
    existente.dias_ate_reclassificacao = 30,
    existente.observacoes = NULL
WHERE paciente.cpf = '00000000001'
  AND existente.procedimento = 'Ressonância magnética do joelho'
  AND existente.status = 'aguardando';

UPDATE lista_espera existente
JOIN pacientes paciente
  ON paciente.id = existente.paciente_id
 AND paciente.dados_demonstracao = 1
SET existente.observacoes = 'Atenção: a classificação mudou conforme o tempo de espera.'
WHERE paciente.cpf = '00000000001'
  AND existente.procedimento = 'Avaliação para cirurgia de catarata'
  AND existente.status = 'aguardando';

INSERT INTO lista_espera
    (paciente_id, unidade_saude_id, procedimento, classificacao_inicial,
     dias_ate_reclassificacao, data_entrada, status,
     observacoes)
SELECT paciente.id, unidade.id, demonstracao.procedimento, 'verde',
         demonstracao.dias_ate_reclassificacao,
         DATE_SUB(CURRENT_DATE, INTERVAL demonstracao.dias_espera DAY),
         'aguardando', demonstracao.observacoes
FROM (
    SELECT '00000000001' AS cpf,
             'Ressonância magnética do joelho' AS procedimento,
             15 AS dias_espera, 0 AS dias_ate_reclassificacao,
             NULL AS observacoes,
             'Laboratório Vida (Demonstração)' AS unidade
    UNION ALL
    SELECT '00000000001', 'Avaliação para cirurgia de catarata',
             30, 30,
             'Atenção: a classificação mudou conforme o tempo de espera.',
             'Hospital Municipal (Demonstração)'
) AS demonstracao
JOIN pacientes paciente
  ON paciente.cpf = demonstracao.cpf
 AND paciente.dados_demonstracao = 1
JOIN unidades_saude unidade
  ON unidade.nome = demonstracao.unidade
WHERE NOT EXISTS (
    SELECT 1
    FROM lista_espera existente
    WHERE existente.paciente_id = paciente.id
        AND existente.procedimento = demonstracao.procedimento
        AND existente.status = 'aguardando'
);

INSERT INTO conhecimentos
    (titulo, conteudo, categoria_id, palavras_chave, ativo)
VALUES

(
    'Vacinas do paciente',
    'O portal permite consultar as vacinas registradas para o paciente, incluindo nome da vacina, dose, situação, data de aplicação e próxima dose quando disponível. A resposta deve utilizar os dados registrados no portal e não deve inventar doses ou recomendações médicas.',
    NULL,
    'vacina,vacinas,vacinação,dose,doses,minhas vacinas,vacina pendente,próxima dose',
    1
),

(
    'Exames do paciente',
    'O portal permite consultar os exames vinculados ao paciente. Podem ser exibidos nome do exame, situação, data da solicitação, agendamento, instruções e resultado resumido quando disponível. O assistente não deve interpretar resultados nem realizar diagnóstico.',
    NULL,
    'exame,exames,meus exames,resultado,exame pendente,exame agendado,próximo exame',
    1
),

(
    'Unidades de saúde',
    'O portal possui unidades de saúde cadastradas com nome, tipo, endereço, localização e horário de atendimento. Quando o usuário perguntar sobre unidades próximas, devem ser consideradas somente as unidades cadastradas no sistema.',
    NULL,
    'unidade,unidades,unidades perto,unidade próxima,ubs,hospital,posto,endereço,horário',
    1
),

(
    'Alta hospitalar',
    'O portal permite consultar informações de alta hospitalar do paciente, incluindo resumo, orientações, retorno recomendado, situação e data da alta. O assistente deve somente explicar as informações registradas e não criar novas orientações médicas.',
    NULL,
    'alta,minha alta,alta hospitalar,orientações de alta,retorno,histórico de alta',
    1
),

(
    'Lista de espera',
    'O portal permite consultar procedimentos do paciente em lista de espera. São apresentadas informações como procedimento, dias de espera e classificação. As classificações utilizadas são verde, amarelo, laranja e vermelho. A classificação é determinada pelo sistema e não deve ser alterada pela inteligência artificial.',
    NULL,
    'lista de espera,fila,espera,procedimento,prioridade,classificação,verde,amarelo,laranja,vermelho',
    1
);