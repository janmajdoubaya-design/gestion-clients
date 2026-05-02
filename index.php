<?php
// ============================================================
//  SKILL4ALL - Page de login
//  Fichier : index.php
// ============================================================

require_once 'auth/session.php';

// Si déjà connecté → rediriger directement
if (est_connecte()) {
    rediriger_selon_role();
}

// Récupérer l'erreur de login si elle existe
$erreur = $_SESSION['login_erreur'] ?? '';
unset($_SESSION['login_erreur']);
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SKILL4ALL - Connexion</title>
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: #f0f2f5;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-card {
            width: 100%;
            max-width: 420px;
            border-radius: 12px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.10);
        }
        .login-header {
            background: #1a1a2e;
            color: white;
            border-radius: 12px 12px 0 0;
            padding: 30px;
            text-align: center;
        }
        .login-header h4 {
            margin: 0;
            font-weight: 700;
            letter-spacing: 1px;
        }
        .login-header p {
            margin: 6px 0 0;
            opacity: 0.7;
            font-size: 13px;
        }
        .btn-login {
            background: #e94560;
            border: none;
            width: 100%;
            padding: 12px;
            font-size: 15px;
            font-weight: 600;
            border-radius: 8px;
            color: white;
        }
        .btn-login:hover {
            background: #c73652;
            color: white;
        }
    </style>
</head>
<body>

<div class="card login-card">
    <!-- En-tête -->
    <div class="login-header">
        <h4>SKILL4ALL</h4>
        <p>Gestion clients & facturation</p>
    </div>

    <!-- Formulaire -->
    <div class="card-body p-4">
        <h5 class="mb-4 text-center fw-semibold">Connexion</h5>

        <!-- Message d'erreur -->
        <?php if (!empty($erreur)): ?>
            <div class="alert alert-danger py-2 px-3 mb-3" role="alert">
                <small><?= htmlspecialchars($erreur) ?></small>
            </div>
        <?php endif; ?>

        <!-- Formulaire de login -->
        <form action="auth/login.php" method="POST">

            <!-- Token CSRF pour la sécurité -->
            <?php
                if (empty($_SESSION['csrf_token'])) {
                    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
                }
            ?>
            <input type="hidden" name="csrf_token" value="<?= $_SESSION['csrf_token'] ?>">

            <!-- Email -->
            <div class="mb-3">
                <label for="email" class="form-label fw-semibold">Email</label>
                <input
                    type="email"
                    class="form-control"
                    id="email"
                    name="email"
                    placeholder="votre@email.com"
                    required
                    autofocus
                >
            </div>

            <!-- Mot de passe -->
            <div class="mb-4">
                <label for="password" class="form-label fw-semibold">Mot de passe</label>
                <input
                    type="password"
                    class="form-control"
                    id="password"
                    name="password"
                    placeholder="••••••••"
                    required
                >
            </div>

            <!-- Bouton connexion -->
            <button type="submit" class="btn btn-login">
                Se connecter
            </button>

        </form>

        <!-- Infos légales -->
        <hr class="my-4">
        <p class="text-center text-muted" style="font-size:11px; line-height:1.6;">
            SKILL4ALL SARL AU — RC: 180007<br>
            RUE DAKAR IMM N5 APPT 1 OCEAN RABAT<br>
            Tél: 06 61 99 92 66
        </p>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>