<?php
// ============================================================================
// CHATBOT HOSPITALAR - GERENCIAMENTO DE SESSÃO
// Fase 4: Admin
// ============================================================================

session_start();

function verificar_login() {
    if (!isset($_SESSION['admin_id']) || !isset($_SESSION['admin_nome'])) {
        header('Location: login.php');
        exit;
    }
}

function fazer_logout() {
    session_destroy();
    header('Location: login.php');
    exit;
}

function admin_logado() {
    return isset($_SESSION['admin_id']) && isset($_SESSION['admin_nome']);
}

function obter_admin_id() {
    return $_SESSION['admin_id'] ?? null;
}

function obter_admin_nome() {
    return $_SESSION['admin_nome'] ?? null;
}

?>
