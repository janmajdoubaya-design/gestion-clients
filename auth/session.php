<?php
// ============================================================
//  SKILL4ALL - Gestion des sessions
//  Fichier : auth/session.php
// ============================================================

// Démarre la session si pas encore démarrée
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// --- Connecter un utilisateur ---
function session_connecter(array $utilisateur): void {
    $_SESSION['user_id']    = $utilisateur['id'];
    $_SESSION['user_nom']   = $utilisateur['nom'];
    $_SESSION['user_prenom']= $utilisateur['prenom'];
    $_SESSION['user_email'] = $utilisateur['email'];
    $_SESSION['user_role']  = $utilisateur['role_nom'];
    $_SESSION['connecte']   = true;
}

// --- Vérifier si connecté ---
function est_connecte(): bool {
    return !empty($_SESSION['connecte']) && $_SESSION['connecte'] === true;
}

// --- Récupérer le rôle de l'utilisateur connecté ---
function get_role(): string {
    return $_SESSION['user_role'] ?? '';
}

// --- Récupérer l'ID de l'utilisateur connecté ---
function get_user_id(): int {
    return (int)($_SESSION['user_id'] ?? 0);
}

// --- Récupérer le prénom + nom ---
function get_user_nom(): string {
    return ($_SESSION['user_prenom'] ?? '') . ' ' . ($_SESSION['user_nom'] ?? '');
}

// --- Déconnecter ---
function session_deconnecter(): void {
    session_unset();
    session_destroy();
}

// --- Rediriger selon le rôle après login ---
function rediriger_selon_role(): void {
    $role = get_role();
    if ($role === 'admin') {
        header('Location: /gestion-clients/admin/dashboard.php');
    } elseif ($role === 'agent') {
        header('Location: /gestion-clients/agent/dashboard.php');
    } elseif ($role === 'client') {
        header('Location: /gestion-clients/client/dashboard.php');
    } else {
        header('Location: /gestion-clients/index.php');
    }
    exit;
}