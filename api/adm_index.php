<?php
// ============================================================================
// CHATBOT HOSPITALAR - DASHBOARD DO ADMIN
// Fase 4: Admin
// ============================================================================

require __DIR__ . '/sessao.php';
require __DIR__ . '/config/db.php';

verificar_login();

// Obter estatísticas
try {
    // Total de pacientes
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM pacientes");
    $total_pacientes = $stmt->fetch()['total'];

    // Total de conversas
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM conversas");
    $total_conversas = $stmt->fetch()['total'];

    // Conversas ativas
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM conversas WHERE status = 'ativa'");
    $conversas_ativas = $stmt->fetch()['total'];

    // Total de perguntas
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM perguntas WHERE ativo = 1");
    $total_perguntas = $stmt->fetch()['total'];

    // Perguntas mais acessadas
    $stmt = $pdo->query("
        SELECT p.pergunta, COUNT(h.id) as acessos
        FROM perguntas p
        LEFT JOIN historico h ON p.id = h.pergunta_id
        WHERE p.ativo = 1
        GROUP BY p.id
        ORDER BY acessos DESC
        LIMIT 5
    ");
    $perguntas_top = $stmt->fetchAll();

} catch (PDOException $e) {
    $erro = "Erro ao carregar estatísticas";
}

?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin — Dashboard</title>
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
                <li><a href="./" class="ativo">📊 Dashboard</a></li>
                <li><a href="categorias.php">📁 Categorias</a></li>
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
                <h1>Dashboard</h1>
            </header>

            <div class="admin-content">
                <?php if (isset($erro)): ?>
                    <div class="alerta alerta-erro"><?php echo $erro; ?></div>
                <?php endif; ?>

                <!-- ESTATÍSTICAS -->
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 32px;">
                    <div class="card">
                        <h3 style="color: #2196f3;">👥 Pacientes</h3>
                        <p style="font-size: 28px; font-weight: bold; margin: 16px 0;"><?php echo $total_pacientes; ?></p>
                    </div>

                    <div class="card">
                        <h3 style="color: #4caf50;">💬 Conversas</h3>
                        <p style="font-size: 28px; font-weight: bold; margin: 16px 0;"><?php echo $total_conversas; ?></p>
                    </div>

                    <div class="card">
                        <h3 style="color: #ff9800;">⏳ Ativas</h3>
                        <p style="font-size: 28px; font-weight: bold; margin: 16px 0;"><?php echo $conversas_ativas; ?></p>
                    </div>

                    <div class="card">
                        <h3 style="color: #9c27b0;">❓ Perguntas</h3>
                        <p style="font-size: 28px; font-weight: bold; margin: 16px 0;"><?php echo $total_perguntas; ?></p>
                    </div>
                </div>

                <!-- PERGUNTAS MAIS ACESSADAS -->
                <div class="card">
                    <h2>Perguntas mais acessadas</h2>
                    <table class="tabela">
                        <thead>
                            <tr>
                                <th>Pergunta</th>
                                <th style="text-align: right;">Acessos</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if (!empty($perguntas_top)): ?>
                                <?php foreach ($perguntas_top as $pergunta): ?>
                                    <tr>
                                        <td><?php echo htmlspecialchars($pergunta['pergunta']); ?></td>
                                        <td style="text-align: right;"><strong><?php echo $pergunta['acessos']; ?></strong></td>
                                    </tr>
                                <?php endforeach; ?>
                            <?php else: ?>
                                <tr>
                                    <td colspan="2" style="text-align: center; color: #999;">Nenhuma pergunta acessada ainda</td>
                                </tr>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>

                <!-- ATALHOS -->
                <div class="card">
                    <h2>Ações rápidas</h2>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <a href="categorias.php" class="btn btn-primario">+ Nova categoria</a>
                        <a href="perguntas.php" class="btn btn-primario">+ Nova pergunta</a>
                        <a href="conversas.php" class="btn btn-primario">Ver conversas</a>
                        <a href="../" class="btn btn-aviso">← Voltar ao chatbot</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
