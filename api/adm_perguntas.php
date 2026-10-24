<?php
// ============================================================================
// CHATBOT HOSPITALAR - CRUD DE PERGUNTAS
// Fase 4: Admin
// ============================================================================

require __DIR__ . '/sessao.php';
require __DIR__ . '/config/db.php';
require __DIR__ . '/helpers.php';

verificar_login();

$mensagem = '';
$tipo_mensagem = '';

// ============================================================================
// AÇÕES (POST)
// ============================================================================

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $acao = $_POST['acao'] ?? '';

    try {
        if ($acao === 'criar' || $acao === 'editar') {
            $categoria_id = (int)($_POST['categoria_id'] ?? 0);
            $pergunta = trim($_POST['pergunta'] ?? '');
            $resposta = trim($_POST['resposta'] ?? '');
            $pergunta_pai_id = !empty($_POST['pergunta_pai_id']) ? (int)$_POST['pergunta_pai_id'] : null;
            $ordem = (int)($_POST['ordem'] ?? 0);

            if ($categoria_id <= 0 || empty($pergunta) || empty($resposta)) {
                $tipo_mensagem = 'erro';
                $mensagem = 'Categoria, pergunta e resposta são obrigatórias';
            } else {
                if ($acao === 'criar') {
                    $stmt = $pdo->prepare("
                        INSERT INTO perguntas (categoria_id, pergunta, resposta, pergunta_pai_id, ordem) 
                        VALUES (?, ?, ?, ?, ?)
                    ");
                    $stmt->execute([$categoria_id, $pergunta, $resposta, $pergunta_pai_id, $ordem]);
                    $tipo_mensagem = 'sucesso';
                    $mensagem = 'Pergunta criada com sucesso';
                } else {
                    $id = (int)($_POST['id'] ?? 0);
                    $ativo = isset($_POST['ativo']) ? 1 : 0;
                    
                    $stmt = $pdo->prepare("
                        UPDATE perguntas 
                        SET categoria_id = ?, pergunta = ?, resposta = ?, pergunta_pai_id = ?, ordem = ?, ativo = ?
                        WHERE id = ?
                    ");
                    $stmt->execute([$categoria_id, $pergunta, $resposta, $pergunta_pai_id, $ordem, $ativo, $id]);
                    $tipo_mensagem = 'sucesso';
                    $mensagem = 'Pergunta atualizada com sucesso';
                }
            }

        } elseif ($acao === 'deletar') {
            $id = (int)($_POST['id'] ?? 0);
            if ($id <= 0) {
                $tipo_mensagem = 'erro';
                $mensagem = 'ID inválido';
            } else {
                $stmt = $pdo->prepare("UPDATE perguntas SET ativo = 0 WHERE id = ?");
                $stmt->execute([$id]);
                $tipo_mensagem = 'sucesso';
                $mensagem = 'Pergunta deletada com sucesso';
            }
        }

    } catch (PDOException $e) {
        log_erro("Erro em CRUD pergunta: " . $e->getMessage());
        $tipo_mensagem = 'erro';
        $mensagem = 'Erro ao processar ação';
    }
}

// ============================================================================
// OBTER DADOS
// ============================================================================

try {
    // Categorias
    $stmt = $pdo->query("SELECT * FROM categorias WHERE ativo = 1 ORDER BY ordem");
    $categorias = $stmt->fetchAll();

    // Perguntas
    $stmt = $pdo->query("
        SELECT p.*, c.nome as categoria_nome 
        FROM perguntas p
        JOIN categorias c ON p.categoria_id = c.id
        ORDER BY p.categoria_id, p.pergunta_pai_id, p.ordem
    ");
    $perguntas = $stmt->fetchAll();

    // Se está em edicao
    $edicao = false;
    $pergunta_edit = null;
    if (isset($_GET['editar'])) {
        $id = (int)$_GET['editar'];
        $stmt = $pdo->prepare("SELECT * FROM perguntas WHERE id = ?");
        $stmt->execute([$id]);
        $pergunta_edit = $stmt->fetch();
        if ($pergunta_edit) {
            $edicao = true;
        }
    }

} catch (PDOException $e) {
    $perguntas = [];
    $categorias = [];
    $tipo_mensagem = 'erro';
    $mensagem = 'Erro ao carregar dados';
}

// Função para exibir árvore
function exibir_arvore($perguntas, $pai_id = null, $nivel = 0) {
    $filhos = array_filter($perguntas, function($p) use ($pai_id) {
        return $p['pergunta_pai_id'] == $pai_id;
    });

    foreach ($filhos as $p) {
        $indent = str_repeat('&nbsp;&nbsp;&nbsp;', $nivel);
        echo '<tr>';
        echo '<td>' . $indent . htmlspecialchars($p['pergunta']) . '</td>';
        echo '<td>' . htmlspecialchars($p['categoria_nome']) . '</td>';
        echo '<td>' . $p['ordem'] . '</td>';
        echo '<td><span style="color: ' . ($p['ativo'] ? '#4caf50' : '#999') . ';">' . ($p['ativo'] ? '✓' : '✗') . '</span></td>';
        echo '<td class="acao">';
        echo '<a href="?editar=' . $p['id'] . '" class="btn btn-primario btn-pequeno">E</a>';
        echo '<form method="POST" style="display: inline;" onsubmit="return confirm(\'Tem certeza?\');">';
        echo '<input type="hidden" name="acao" value="deletar">';
        echo '<input type="hidden" name="id" value="' . $p['id'] . '">';
        echo '<button type="submit" class="btn btn-erro btn-pequeno">D</button>';
        echo '</form>';
        echo '</td>';
        echo '</tr>';

        // Recursivo: mostrar filhos
        exibir_arvore($perguntas, $p['id'], $nivel + 1);
    }
}

?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin — Perguntas</title>
    <link rel="stylesheet" href="../assets/css/adm.css">
</head>
<body>
    <div class="admin-container">
        <!-- SIDEBAR -->
        <aside class="admin-sidebar">
            <div class="sidebar-header">
                <h2>🏥 Admin</h2>
                <p><?php echo htmlspecialchars(obter_admin_nome()); ?></p>
            </div>

            <ul class="sidebar-menu">
                <li><a href="./">📊 Dashboard</a></li>
                <li><a href="categorias.php">📁 Categorias</a></li>
                <li><a href="perguntas.php" class="ativo">❓ Perguntas</a></li>
                <li><a href="conversas.php">💬 Conversas</a></li>
            </ul>

            <div class="sidebar-logout">
                <a href="logout.php">🚪 Sair</a>
            </div>
        </aside>

        <!-- MAIN -->
        <div class="admin-main">
            <header class="admin-header">
                <h1><?php echo $edicao ? 'Editar pergunta' : 'Perguntas'; ?></h1>
            </header>

            <div class="admin-content">
                <?php if ($mensagem): ?>
                    <div class="alerta alerta-<?php echo $tipo_mensagem; ?>">
                        <?php echo htmlspecialchars($mensagem); ?>
                    </div>
                <?php endif; ?>

                <!-- FORMULÁRIO -->
                <div class="card">
                    <h2><?php echo $edicao ? 'Editar' : 'Nova pergunta'; ?></h2>
                    <form method="POST" style="max-width: 600px;">
                        <input type="hidden" name="acao" value="<?php echo $edicao ? 'editar' : 'criar'; ?>">
                        <?php if ($edicao): ?>
                            <input type="hidden" name="id" value="<?php echo $pergunta_edit['id']; ?>">
                        <?php endif; ?>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="categoria_id">Categoria:</label>
                                <select id="categoria_id" name="categoria_id" required>
                                    <option value="">Selecione...</option>
                                    <?php foreach ($categorias as $cat): ?>
                                        <option value="<?php echo $cat['id']; ?>" <?php echo $edicao && $pergunta_edit['categoria_id'] == $cat['id'] ? 'selected' : ''; ?>>
                                            <?php echo htmlspecialchars($cat['nome']); ?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="pergunta_pai_id">Pergunta pai (opcional):</label>
                                <select id="pergunta_pai_id" name="pergunta_pai_id">
                                    <option value="">Nenhuma (menu raiz)</option>
                                    <?php foreach ($perguntas as $p): ?>
                                        <?php if (!$p['pergunta_pai_id']): ?>
                                            <option value="<?php echo $p['id']; ?>" <?php echo $edicao && $pergunta_edit['pergunta_pai_id'] == $p['id'] ? 'selected' : ''; ?>>
                                                <?php echo htmlspecialchars($p['pergunta']); ?>
                                            </option>
                                        <?php endif; ?>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="pergunta">Pergunta:</label>
                            <input 
                                type="text" 
                                id="pergunta" 
                                name="pergunta" 
                                required
                                value="<?php echo $edicao ? htmlspecialchars($pergunta_edit['pergunta']) : ''; ?>"
                            >
                        </div>

                        <div class="form-group">
                            <label for="resposta">Resposta:</label>
                            <textarea 
                                id="resposta" 
                                name="resposta" 
                                required
                            ><?php echo $edicao ? htmlspecialchars($pergunta_edit['resposta']) : ''; ?></textarea>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="ordem">Ordem:</label>
                                <input 
                                    type="number" 
                                    id="ordem" 
                                    name="ordem"
                                    value="<?php echo $edicao ? $pergunta_edit['ordem'] : '0'; ?>"
                                >
                            </div>

                            <?php if ($edicao): ?>
                                <div class="form-group">
                                    <label>
                                        <input type="checkbox" name="ativo" <?php echo $pergunta_edit['ativo'] ? 'checked' : ''; ?>>
                                        Ativa
                                    </label>
                                </div>
                            <?php endif; ?>
                        </div>

                        <button type="submit" class="btn btn-sucesso">
                            <?php echo $edicao ? '✓ Atualizar' : '+ Criar'; ?>
                        </button>
                        <?php if ($edicao): ?>
                            <a href="perguntas.php" class="btn btn-primario" style="margin-left: 10px;">← Voltar</a>
                        <?php endif; ?>
                    </form>
                </div>

                <!-- LISTA (ÁRVORE) -->
                <div class="card">
                    <h2>Perguntas</h2>
                    <table class="tabela">
                        <thead>
                            <tr>
                                <th>Pergunta</th>
                                <th>Categoria</th>
                                <th>Ordem</th>
                                <th>Status</th>
                                <th class="acao">Ação</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if (empty($perguntas)): ?>
                                <tr>
                                    <td colspan="5" style="text-align: center; color: #999;">Nenhuma pergunta</td>
                                </tr>
                            <?php else: ?>
                                <?php exibir_arvore($perguntas); ?>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
