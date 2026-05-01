<?php
// ============================================================
//  SKILL4ALL - Traitement du formulaire de login
//  Fichier : auth/login.php
// ============================================================

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/session.php';

// Si déjà connecté → rediriger directement
if (est_connecte()) {
    rediriger_selon_role();
}

$erreur = '';

// Traitement uniquement si formulaire soumis
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $email      = trim($_POST['email']     ?? '');
    $mot_de_passe = trim($_POST['password'] ?? '');

    // --- Vérification des champs ---
    if (empty($email) || empty($mot_de_passe)) {
        $erreur = 'Veuillez remplir tous les champs.';

    } else {
        // --- Chercher l'utilisateur par email ---
        $utilisateur = db_row(
            "SELECT u.*, r.nom AS role_nom
             FROM utilisateurs u
             JOIN roles r ON u.role_id = r.id
             WHERE u.email = ? AND u.actif = 1",
            [$email]
        );

        // --- Vérifier si le compte est bloqué ---
        if ($utilisateur && !empty($utilisateur['bloque_jusqua'])) {
            if (new DateTime() < new DateTime($utilisateur['bloque_jusqua'])) {
                $erreur = 'Compte temporairement bloqué. Réessayez dans quelques minutes.';
                $utilisateur = null;
            }
        }

        // --- Vérifier le mot de passe ---
        if ($utilisateur && password_verify($mot_de_passe, $utilisateur['mot_de_passe'])) {

            // Réinitialiser les tentatives échouées
            db_exec(
                "UPDATE utilisateurs SET tentatives = 0, bloque_jusqua = NULL WHERE id = ?",
                [$utilisateur['id']]
            );

            // Enregistrer dans les logs
            db_exec(
                "INSERT INTO logs (utilisateur_id, action, description, ip_adresse)
                 VALUES (?, 'login_succes', 'Connexion réussie', ?)",
                [$utilisateur['id'], $_SERVER['REMOTE_ADDR']]
            );

            // Connecter l'utilisateur
            session_connecter($utilisateur);

            // Rediriger selon le rôle
            rediriger_selon_role();

        } else {
            // --- Mauvais mot de passe ---
            if ($utilisateur) {
                $tentatives = (int)$utilisateur['tentatives'] + 1;

                if ($tentatives >= 5) {
                    // Bloquer le compte 15 minutes
                    db_exec(
                        "UPDATE utilisateurs
                         SET tentatives = ?, bloque_jusqua = DATE_ADD(NOW(), INTERVAL 15 MINUTE)
                         WHERE id = ?",
                        [$tentatives, $utilisateur['id']]
                    );
                    $erreur = 'Trop de tentatives. Compte bloqué 15 minutes.';
                } else {
                    db_exec(
                        "UPDATE utilisateurs SET tentatives = ? WHERE id = ?",
                        [$tentatives, $utilisateur['id']]
                    );
                    $restants = 5 - $tentatives;
                    $erreur = "Email ou mot de passe incorrect. ($restants tentatives restantes)";
                }

                // Log de l'échec
                db_exec(
                    "INSERT INTO logs (utilisateur_id, action, description, ip_adresse)
                     VALUES (?, 'login_echec', 'Tentative échouée', ?)",
                    [$utilisateur['id'], $_SERVER['REMOTE_ADDR']]
                );

            } else {
                $erreur = 'Email ou mot de passe incorrect.';
            }
        }
    }
}

// Renvoyer l'erreur à la page index.php
$_SESSION['login_erreur'] = $erreur;
header('Location: /gestion-clients/index.php');
exit;