<?php
// ============================================================
//  SKILL4ALL - Connexion base de données
//  Fichier : config/db.php
//  À inclure en haut de chaque page PHP qui utilise la BDD
// ============================================================

// --- Paramètres de connexion ---
define('DB_HOST', 'localhost');
define('DB_NAME', 'skill4all_db');
define('DB_USER', 'root');       // utilisateur XAMPP par défaut
define('DB_PASS', '');           // mot de passe XAMPP par défaut (vide)
define('DB_CHARSET', 'utf8mb4');

// --- Connexion PDO sécurisée ---
try {
    $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;

    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,  // affiche les erreurs
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,        // retourne les données en tableau
        PDO::ATTR_EMULATE_PREPARES   => false,                   // sécurité anti-injection SQL
    ];

    $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);

} catch (PDOException $e) {
    // En cas d'erreur de connexion
    error_log("Erreur BDD : " . $e->getMessage());
    die(json_encode([
        'erreur' => 'Connexion à la base de données impossible. Vérifiez que XAMPP est lancé.'
    ]));
}

// --- Fonction utilitaire : exécuter une requête préparée ---
// Utilisation : $rows = db_query("SELECT * FROM clients WHERE id = ?", [$id]);
function db_query(string $sql, array $params = []): array {
    global $pdo;
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchAll();
}

// --- Fonction utilitaire : récupérer une seule ligne ---
// Utilisation : $client = db_row("SELECT * FROM clients WHERE id = ?", [$id]);
function db_row(string $sql, array $params = []): ?array {
    global $pdo;
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $row = $stmt->fetch();
    return $row ?: null;
}

// --- Fonction utilitaire : insérer / modifier / supprimer ---
// Utilisation : $ok = db_exec("INSERT INTO clients (nom) VALUES (?)", ['Ahmed']);
function db_exec(string $sql, array $params = []): bool {
    global $pdo;
    $stmt = $pdo->prepare($sql);
    return $stmt->execute($params);
}

// --- Fonction utilitaire : récupérer le dernier ID inséré ---
function db_last_id(): string {
    global $pdo;
    return $pdo->lastInsertId();
}