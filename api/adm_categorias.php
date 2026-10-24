<?php
// ============================================================================
// CHATBOT HOSPITALAR - CRUD DE CATEGORIAS
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
        if ($acao === 'criar') {
            // Criar nova categoria
            $nome = trim($_POST['nome'] ?? '');
            $icone = trim($_POST['icone'] ?? '');
            $ordem = (int)($_POST['ordem'] ?? 0);

            if (empty($nome)) {
                $tipo_mensagem = 'erro';
                $mensagem = 'Nome é obrigatório';
            } else {
                $stmt = $pdo->prepare("
                    INSERT INTO categorias (nome, icone, ordem) 
                    VALUES (?, ?, ?)
                ");
                $stmt->execute([$nome, $icone, $ordem]);
                $tipo_mensagem = 'sucesso';
                $mensagem = 'Categoria criada com sucesso';
            }

        } elseif ($acao === 'editar') {
            // Editar categoria
            $id = (int)($_POST['id'] ?? 0);
            $nome = trim($_POST['nome'] ?? '');
            $icone = trim($_POST['icone'] ?? '');
            $ordem = (int)($_POST['ordem'] ?? 0);
            $ativo = isset($_POST['ativo']) ? 1 : 0;

            if ($id <= 0 || empty($nome)) {
                $tipo_mensagem = 'erro';
                $mensagem = 'Dados inválidos';
            } else {
                $stmt = $pdo->prepare("
                    UPDATE categorias 
                    SET nome = ?, icone = ?, ordem = ?, ativo = ?
                    WHERE id = ?
                ");
                $stmt->execute([$nome, $icone, $ordem, $ativo, $id]);
                $tipo_mensagem = 'sucesso';
                $mensagem = 'Categoria atualizada com sucesso';
            }

        } elseif ($acao === 'deletar') {
            // Deletar categoria (soft delete)
            $id = (int)($_POST['id'] ?? 0);

            if ($id <= 0) {
                $tipo_mensagem = 'erro';
                $mensagem = 'ID inválido';
            } else {
                $stmt = $pdo->prepare("UPDATE categorias SET ativo = 0 WHERE id = ?");
                $stmt->execute([$id]);
                $tipo_mensagem = 'sucesso';
                $mensagem = 'Categoria deletada com sucesso';
            }
        }

    } catch (PDOException $e) {
        log_erro("Erro em CRUD categoria: " . $e->getMessage());
        $tipo_mensagem = 'erro';
        $mensagem = 'Erro ao processar ação';
    }
}

// ============================================================================
// OBTER CATEGORIAS
// ============================================================================

try {
    $stmt = $pdo->query("
        SELECT * FROM categorias 
        ORDER BY ordem ASC
    ");
    $categorias = $stmt->fetchAll();
} catch (PDOException $e) {
    $categorias = [];
    $tipo_mensagem = 'erro';
    $mensagem = 'Erro ao carregar categorias';
}

// Detectar se está em modo edição
$edicao = false;
$categoria_edit = null;
if (isset($_GET['editar'])) {
    $id = (int)$_GET['editar'];
    $stmt = $pdo->prepare("SELECT * FROM categorias WHERE id = ?");
    $stmt->execute([$id]);
    $categoria_edit = $stmt->fetch();
    if ($categoria_edit) {
        $edicao = true;
    }
}

?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin — Categorias</title>
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
                <li><a href="categorias.php" class="ativo">📁 Categorias</a></li>
                <li><a href="perguntas.php">❓ Perguntas</a></li>
                <li><a href="conversas.php">💬 Conversas</a></li>
            </ul>

            <div class="sidebar-logout">
                <a href="logout.php">🚪 Sair</a>
            </div>
        </aside>

        <!-- MAIN -->
        <div class="admin-main">
            <header class="admin-header">
                <h1><?php echo $edicao ? 'Editar categoria' : 'Categorias'; ?></h1>
            </header>

            <div class="admin-content">
                <?php if ($mensagem): ?>
                    <div class="alerta alerta-<?php echo $tipo_mensagem; ?>">
                        <?php echo htmlspecialchars($mensagem); ?>
                    </div>
                <?php endif; ?>

                <!-- FORMULÁRIO -->
                <div class="card">
                    <h2><?php echo $edicao ? 'Editar' : 'Nova categoria'; ?></h2>
                    <form method="POST" style="max-width: 500px;">
                        <input type="hidden" name="acao" value="<?php echo $edicao ? 'editar' : 'criar'; ?>">
                        <?php if ($edicao): ?>
                            <input type="hidden" name="id" value="<?php echo $categoria_edit['id']; ?>">
                        <?php endif; ?>

                        <div class="form-group">
                            <label for="nome">Nome:</label>
                            <input 
                                type="text" 
                                id="nome" 
                                name="nome" 
                                required
                                value="<?php echo $edicao ? htmlspecialchars($categoria_edit['nome']) : ''; ?>"
                            >
                        </div>

                        <div class="form-group">
                            <label for="icone">Ícone:</label>
                            <input 
                                type="text" 
                                id="icone" 
                                name="icone"
                                placeholder="Ex: 🏥"
                                value="<?php echo $edicao ? htmlspecialchars($categoria_edit['icone']) : ''; ?>"
                            >
                        </div>

                        <div class="form-group">
                            <label for="ordem">Ordem:</label>
                            <input 
                                type="number" 
                                id="ordem" 
                                name="ordem"
                                value="<?php echo $edicao ? $categoria_edit['ordem'] : '0'; ?>"
                            >
                        </div>

                        <?php if ($edicao): ?>
                            <div class="form-group">
                                <label>
                                    <input type="checkbox" name="ativo" <?php echo $categoria_edit['ativo'] ? 'checked' : ''; ?>>
                                    Ativa
                                </label>
                            </div>
                        <?php endif; ?>

                        <button type="submit" class="btn btn-sucesso">
                            <?php echo $edicao ? '✓ Atualizar' : '+ Criar'; ?>
                        </button>
                        <?php if ($edicao): ?>
                            <a href="categorias.php" class="btn btn-primario" style="margin-left: 10px;">← Voltar</a>
                        <?php endif; ?>
                    </form>
                </div>

                <!-- LISTA -->
                <div class="card">
                    <h2>Categorias</h2>
                    <table class="tabela">
                        <thead>
                            <tr>
                                <th>Ícone</th>
                                <th>Nome</th>
                                <th>Ordem</th>
                                <th>Status</th>
                                <th class="acao">Ação</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if (empty($categorias)): ?>
                                <tr>
                                    <td colspan="5" style="text-align: center; color: #999;">Nenhuma categoria</td>
                                </tr>
                            <?php else: ?>
                                <?php foreach ($categorias as $cat): ?>
                                    <tr>
                                        <td><?php echo htmlspecialchars($cat['icone'] ?? '—'); ?></td>
                                        <td><?php echo htmlspecialchars($cat['nome']); ?></td>
                                        <td><?php echo $cat['ordem']; ?></td>
                                        <td>
                                            <span style="color: <?php echo $cat['ativo'] ? '#4caf50' : '#999'; ?>;">
                                                <?php echo $cat['ativo'] ? '✓ Ativa' : '✗ Inativa'; ?>
                                            </span>
                                        </td>
                                        <td class="acao">
                                            <a href="?editar=<?php echo $cat['id']; ?>" class="btn btn-primario btn-pequeno">Editar</a>
                                            <form method="POST" style="display: inline;" onsubmit="return confirm('Tem certeza?');">
                                                <input type="hidden" name="acao" value="deletar">
                                                <input type="hidden" name="id" value="<?php echo $cat['id']; ?>">
                                                <button type="submit" class="btn btn-erro btn-pequeno">Deletar</button>
                                            </form>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
