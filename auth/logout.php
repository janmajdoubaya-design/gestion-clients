<?php
// ============================================================
//  SKILL4ALL - Déconnexion
//  Fichier : auth/logout.php
// ============================================================

require_once __DIR__ . '/session.php';

// Log de la déconnexion
if (est_connecte()) {
    require_once __DIR__ . '/../config/db.php';
    db_exec(
        "INSERT INTO logs (utilisateur_id, action, description, ip_adresse)
         VALUES (?, 'logout', 'Déconnexion', ?)",
        [get_user_id(), $_SERVER['REMOTE_ADDR']]
    );
}

// Détruire la session
session_deconnecter();

// Rediriger vers la page de login
header('Location: /gestion-clients/index.php');
exit;