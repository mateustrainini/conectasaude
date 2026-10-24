<?php
header('Cache-Control: no-store, private');
header('X-Content-Type-Options: nosniff');
require __DIR__ . '/helpers.php';
require __DIR__ . '/../config/db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    header('Allow: GET');
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Este endpoint permite somente a leitura dos dados.',
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $patients = $pdo->query("
        SELECT p.id, p.nome, p.data_nascimento, p.cpf, p.cns, p.telefone,
               p.endereco, p.portal_acesso_status, u.nome AS unidade
        FROM pacientes p
        LEFT JOIN unidades_saude u ON u.id = p.unidade_saude_id
        WHERE p.dados_demonstracao = 1
        ORDER BY p.id
    ")->fetchAll();

    $patientId = isset($_GET['paciente_id']) ? filter_var(
        $_GET['paciente_id'],
        FILTER_VALIDATE_INT,
        ['options' => ['min_range' => 1]]
    ) : null;

    if (isset($_GET['paciente_id']) && $patientId === false) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'O identificador do paciente é inválido.',
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    if ($patientId === null && !empty($patients)) {
        $patientId = (int)$patients[0]['id'];
    }

    $patient = null;
    foreach ($patients as $listedPatient) {
        if ((int)$listedPatient['id'] === $patientId) {
            $patient = $listedPatient;
            break;
        }
    }

    $units = $pdo->query("
        SELECT id, nome, tipo, endereco, latitude, longitude, horario_atendimento
        FROM unidades_saude
        WHERE ativo = 1
        ORDER BY nome
    ")->fetchAll();

    $data = [
        'pacientes' => $patients,
        'paciente' => $patient,
        'unidades' => $units,
        'registros' => [],
        'vacinas' => [],
        'exames' => [],
        'consultas' => [],
        'lista_espera' => [],
        'altas' => [],
        'acessos' => [],
    ];

    if ($patient !== null) {
        $queries = [
            'registros' => "SELECT r.id, r.tipo, r.titulo, r.detalhes, r.origem, r.ocorrido_em,
                                   r.documento_url, u.nome AS unidade
                            FROM registros_clinicos r
                            LEFT JOIN unidades_saude u ON u.id = r.unidade_saude_id
                            WHERE r.paciente_id = ? ORDER BY r.ocorrido_em DESC, r.id DESC",
            'vacinas' => "SELECT id, nome, dose, status, aplicada_em, proxima_dose_em, observacoes
                          FROM vacinas_paciente
                          WHERE paciente_id = ? ORDER BY COALESCE(aplicada_em, proxima_dose_em) DESC, id DESC",
            'exames' => "SELECT e.id, e.nome, e.solicitante, e.status, e.solicitado_em,
                                e.agendado_para, e.instrucoes, e.resultado_resumo, e.documento_url,
                                solicitante.nome AS unidade_solicitante,
                                executora.nome AS unidade_executora
                         FROM exames_paciente e
                         LEFT JOIN unidades_saude solicitante ON solicitante.id = e.unidade_solicitante_id
                         LEFT JOIN unidades_saude executora ON executora.id = e.unidade_executora_id
                         WHERE e.paciente_id = ? ORDER BY e.solicitado_em DESC, e.id DESC",
            'consultas' => "SELECT c.id, c.profissional, c.motivo, c.agendado_para, c.status,
                                   u.nome AS unidade
                            FROM consultas_agendadas c
                            LEFT JOIN unidades_saude u ON u.id = c.unidade_saude_id
                            WHERE c.paciente_id = ? ORDER BY c.agendado_para DESC, c.id DESC",
            'lista_espera' => "SELECT l.id, l.procedimento, l.classificacao_inicial,
                                      l.data_entrada, DATEDIFF(CURRENT_DATE, l.data_entrada) AS dias_espera,
                                      l.observacoes, u.nome AS unidade,
                                      CASE
                                          WHEN l.classificacao_inicial = 'verde'
                                               AND l.dias_ate_reclassificacao IS NOT NULL
                                               AND DATEDIFF(CURRENT_DATE, l.data_entrada) >= l.dias_ate_reclassificacao
                                          THEN 'amarelo'
                                          ELSE l.classificacao_inicial
                                      END AS classificacao_atual
                               FROM lista_espera l
                               LEFT JOIN unidades_saude u ON u.id = l.unidade_saude_id
                               WHERE l.paciente_id = ? AND l.status = 'aguardando'
                               ORDER BY FIELD(l.classificacao_inicial, 'vermelho', 'laranja', 'amarelo', 'verde'),
                                        l.data_entrada DESC, l.id ASC",
            'altas' => "SELECT a.id, a.resumo, a.orientacoes, a.retorno_recomendado,
                               a.status, a.alta_em, a.enviada_em, a.recebida_em,
                               hospital.nome AS hospital,
                               referencia.nome AS unidade_referencia
                        FROM altas_hospitalares a
                        LEFT JOIN unidades_saude hospital ON hospital.id = a.hospital_id
                        LEFT JOIN unidades_saude referencia ON referencia.id = a.unidade_referencia_id
                        WHERE a.paciente_id = ? ORDER BY a.alta_em DESC, a.id DESC",
            'acessos' => "SELECT a.id, a.profissional, a.motivo, a.acessado_em,
                                 u.nome AS unidade
                          FROM acessos_prontuario a
                          LEFT JOIN unidades_saude u ON u.id = a.unidade_saude_id
                          WHERE a.paciente_id = ? ORDER BY a.acessado_em DESC, a.id DESC",
        ];

        foreach ($queries as $key => $query) {
            $statement = $pdo->prepare($query);
            $statement->execute([$patientId]);
            $data[$key] = $statement->fetchAll();
        }
    }

    echo json_encode(
        ['success' => true] + $data,
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
    );
} catch (PDOException $error) {
    log_erro('Erro ao consultar o portal de demonstração: ' . $error->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Não foi possível consultar os dados do portal.',
    ], JSON_UNESCAPED_UNICODE);
}
