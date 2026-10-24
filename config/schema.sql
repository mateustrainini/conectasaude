-- ============================================================================
-- CHATBOT HOSPITALAR - SCHEMA
-- Fase 1: Banco de dados
-- ============================================================================

CREATE DATABASE IF NOT EXISTS chatbot_hospital
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE chatbot_hospital;

-- ============================================================================
-- TABELA: pacientes
-- ============================================================================

CREATE TABLE pacientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_nome_data (nome, data_nascimento)
);

-- ============================================================================
-- TABELA: categorias
-- ============================================================================

CREATE TABLE categorias (
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

CREATE TABLE perguntas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    categoria_id INT NOT NULL,
    pergunta VARCHAR(500) NOT NULL,
    resposta LONGTEXT NOT NULL,
    pergunta_pai_id INT,
    ordem INT NOT NULL DEFAULT 0,
    ativo TINYINT(1) DEFAULT 1,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (pergunta_pai_id) REFERENCES perguntas(id) ON DELETE RESTRICT,
    
    INDEX idx_categoria_ativo_ordem (categoria_id, ativo, ordem),
    INDEX idx_pergunta_pai_ativo (pergunta_pai_id, ativo, ordem)
);

-- ============================================================================
-- TABELA: conversas
-- ============================================================================

CREATE TABLE conversas (
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

CREATE TABLE historico (
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

CREATE TABLE conhecimentos (
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

CREATE TABLE administradores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    ativo TINYINT(1) DEFAULT 1,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_email (email)
);

-- ============================================================================
-- DADOS FICTÍCIOS
-- ============================================================================

-- Categorias
INSERT INTO categorias (id, nome, icone, ordem, ativo) VALUES
(1, 'Internação', '🏥', 1, 1),
(2, 'Exames', '🧪', 2, 1),
(3, 'Convênios', '💳', 3, 1),
(4, 'Consultas', '👨‍⚕️', 4, 1),
(5, 'Contato', '📞', 5, 1);

-- Pacientes fictícios
INSERT INTO pacientes (nome, data_nascimento) VALUES
('João Silva', '1980-05-15'),
('Maria Santos', '1975-08-22'),
('Pedro Oliveira', '1990-03-10'),
('Ana Costa', '1985-12-28');

-- Perguntas - Internação (categoria_id = 1)
INSERT INTO perguntas (categoria_id, pergunta, resposta, pergunta_pai_id, ordem, ativo) VALUES
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
INSERT INTO perguntas (categoria_id, pergunta, resposta, pergunta_pai_id, ordem, ativo) VALUES
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
INSERT INTO perguntas (categoria_id, pergunta, resposta, pergunta_pai_id, ordem, ativo) VALUES
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
INSERT INTO administradores (nome, email, senha_hash, ativo) VALUES
('Admin Hospital', 'admin@hospital.local', '$2y$10$PQwMT8RJ4m/fnKTKH3GnBelJZEDjrRt1M7tKvmcqg4Q8LkUwzQfxy', 1);

-- Nota: O hash acima é 'admin123' com password_hash(). Para alterar, execute em PHP:
-- echo password_hash('suaSenha', PASSWORD_BCRYPT);

CREATE TABLE IF NOT EXISTS conhecimentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    conteudo LONGTEXT NOT NULL,
    categoria_id INT NULL,
    palavras_chave VARCHAR(500) NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_conhecimento_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL,
    INDEX idx_conhecimento_categoria_ativo (categoria_id, ativo),
    INDEX idx_conhecimento_ativo (ativo)
);

-- Importa as FAQs atuais como base inicial sem duplicar títulos/conteúdos iguais.
INSERT INTO conhecimentos (titulo, conteudo, categoria_id, palavras_chave, ativo)
SELECT p.pergunta, p.resposta, p.categoria_id, p.pergunta, 1
FROM perguntas p
WHERE p.ativo = 1
AND NOT EXISTS (
    SELECT 1 FROM conhecimentos k
    WHERE k.titulo = p.pergunta AND k.conteudo = p.resposta
);