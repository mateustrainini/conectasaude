<?php
// ============================================================================
// CHATBOT HOSPITALAR - LOGIN DO ADMINISTRADOR
// Fase 4: Admin
// ============================================================================

require __DIR__ . '/sessao.php';
require __DIR__ . '/config/db.php';
require __DIR__ . '/helpers.php';

// Se já está logado, redireciona
if (admin_logado()) {
    header('Location: adm/');
    exit;
}

$erro = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = isset($_POST['email']) ? trim($_POST['email']) : '';
    $senha = isset($_POST['senha']) ? $_POST['senha'] : '';

    if (empty($email) || empty($senha)) {
        $erro = 'Email e senha são obrigatórios';
    } else {
        try {
            // Procurar admin no banco
            $stmt = $pdo->prepare("
                SELECT id, nome, senha_hash 
                FROM administradores 
                WHERE email = ? AND ativo = 1
                LIMIT 1
            ");
            $stmt->execute([$email]);
            $admin = $stmt->fetch();

            if ($admin && password_verify($senha, $admin['senha_hash'])) {
                // Senha correta
                $_SESSION['admin_id'] = $admin['id'];
                $_SESSION['admin_nome'] = $admin['nome'];
                header('Location: adm/');
                exit;
            } else {
                $erro = 'Email ou senha incorretos';
            }

        } catch (PDOException $e) {
            log_erro("Erro ao fazer login: " . $e->getMessage());
            $erro = 'Erro ao conectar com o servidor';
        }
    }
}

?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — Administrador</title>
    <link rel="stylesheet" href="assets/css/adm.css">
</head>
<body class="login-page">
    <div class="login-container">
        <div class="login-box">
            <header class="login-header">
                <h1>🏥 Administrador</h1>
                <p>Chatbot Hospitalar</p>
            </header>

            <?php if ($erro): ?>
                <div class="alerta alerta-erro">
                    <?php echo htmlspecialchars($erro); ?>
                </div>
            <?php endif; ?>

            <form method="POST" class="form-login">
                <div class="form-group">
                    <label for="email">Email:</label>
                    <input 
                        type="email" 
                        id="email" 
                        name="email" 
                        required 
                        autofocus
                        value="admin@hospital.local"
                    >
                </div>

                <div class="form-group">
                    <label for="senha">Senha:</label>
                    <input 
                        type="password" 
                        id="senha" 
                        name="senha" 
                        required
                        value="admin123"
                    >
                </div>

                <button type="submit" class="btn btn-primario btn-grande">
                    Entrar
                </button>
            </form>

            <footer class="login-footer">
                <p><strong>Teste:</strong> admin@hospital.local / admin123</p>
            </footer>
        </div>
    </div>
</body>
</html>
