<?php
// ============================================================
//  SKILL4ALL - Protection des pages selon le rôle
//  Fichier : includes/auth_check.php
//  Usage : require_once 'includes/auth_check.php'; verifier_role('admin');
// ============================================================

require_once __DIR__ . '/../auth/session.php';

// --- Vérifier que l'utilisateur est connecté ---
// Si pas connecté → renvoyer vers login
function verifier_connexion(): void {
    if (!est_connecte()) {
        header('Location: /gestion-clients/index.php');
        exit;
    }
}

// --- Vérifier le rôle ---
// Utilisation : verifier_role('admin') ou verifier_role(['admin','agent'])
function verifier_role(string|array $roles_autorises): void {
    verifier_connexion();

    $role_actuel = get_role();

    if (is_string($roles_autorises)) {
        $roles_autorises = [$roles_autorises];
    }

    if (!in_array($role_actuel, $roles_autorises, true)) {
        // Accès refusé → rediriger vers son dashboard
        rediriger_selon_role();
    }
}