-- ============================================================
--  SKILL4ALL SARL - Base de données complète
--  RC: 180007 | ICE: 003546805000097
--  Fichier : skill4all_database.sql
--  Charset : utf8mb4 | Moteur : InnoDB
-- ============================================================

CREATE DATABASE IF NOT EXISTS skill4all_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE skill4all_db;

-- ============================================================
-- TABLE 1 : roles
-- Définit les trois niveaux d'accès du système
-- ============================================================
CREATE TABLE roles (
    id          TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom         VARCHAR(30)      NOT NULL COMMENT 'admin | agent | client',
    description VARCHAR(150)     NOT NULL DEFAULT '',
    cree_le     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_roles_nom (nom)
) ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci
  COMMENT='Rôles utilisateurs : admin, agent, client';

-- Données par défaut
INSERT INTO roles (nom, description) VALUES
  ('admin',  'Accès complet : clients, services, factures, utilisateurs, statistiques'),
  ('agent',  'Accès limité à ses propres clients et factures'),
  ('client', 'Accès à son espace personnel : ses factures et son profil');


-- ============================================================
-- TABLE 2 : utilisateurs
-- Comptes de connexion (admin, agents, clients internes)
-- ============================================================
CREATE TABLE utilisateurs (
    id              INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    role_id         TINYINT UNSIGNED NOT NULL,
    nom             VARCHAR(80)      NOT NULL,
    prenom          VARCHAR(80)      NOT NULL,
    email           VARCHAR(180)     NOT NULL,
    telephone       VARCHAR(20)      NOT NULL DEFAULT '',
    mot_de_passe    VARCHAR(255)     NOT NULL COMMENT 'Hash bcrypt',
    token_2fa       VARCHAR(10)      NULL     COMMENT 'Code 2FA temporaire',
    token_2fa_exp   DATETIME         NULL     COMMENT 'Expiration du code 2FA',
    token_reset     VARCHAR(100)     NULL     COMMENT 'Token réinitialisation mdp',
    token_reset_exp DATETIME         NULL,
    tentatives      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Tentatives de connexion échouées',
    bloque_jusqua   DATETIME         NULL     COMMENT 'Bloqué après 5 tentatives',
    actif           TINYINT(1)       NOT NULL DEFAULT 1,
    cree_le         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_utilisateurs_email (email),
    KEY idx_utilisateurs_role (role_id),
    CONSTRAINT fk_utilisateurs_role
        FOREIGN KEY (role_id) REFERENCES roles(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci
  COMMENT='Comptes de connexion au système';

-- Compte admin par défaut
-- Mot de passe : Admin@2024  (à changer immédiatement)
-- Hash bcrypt généré avec password_hash('Admin@2024', PASSWORD_BCRYPT, ['cost'=>12])
INSERT INTO utilisateurs (role_id, nom, prenom, email, telephone, mot_de_passe) VALUES
  (1, 'SKILL4ALL', 'Admin', 'admin@skill4all.ma', '0661999266',
   '$2y$12$eImiTXuWVxfM37uY4JANjQ==.hash_a_regenerer_avec_php');


-- ============================================================
-- TABLE 3 : clients
-- Clients de l'entreprise (différents des utilisateurs système)
-- ============================================================
CREATE TABLE clients (
    id              INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    utilisateur_id  INT UNSIGNED     NULL     COMMENT 'Lié si le client a un accès portail',
    agent_id        INT UNSIGNED     NULL     COMMENT 'Agent responsable de ce client',
    nom             VARCHAR(80)      NOT NULL,
    prenom          VARCHAR(80)      NOT NULL,
    email           VARCHAR(180)     NOT NULL,
    telephone       VARCHAR(20)      NOT NULL DEFAULT '',
    adresse         TEXT             NULL,
    ville           VARCHAR(80)      NOT NULL DEFAULT '',
    code_postal     VARCHAR(10)      NOT NULL DEFAULT '',
    pays            VARCHAR(60)      NOT NULL DEFAULT 'Maroc',
    ice             VARCHAR(20)      NOT NULL DEFAULT '' COMMENT 'Numéro ICE entreprise si applicable',
    actif           TINYINT(1)       NOT NULL DEFAULT 1,
    notes           TEXT             NULL     COMMENT 'Notes internes sur le client',
    cree_le         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_clients_email (email),
    KEY idx_clients_agent (agent_id),
    KEY idx_clients_utilisateur (utilisateur_id),
    CONSTRAINT fk_clients_utilisateur
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_clients_agent
        FOREIGN KEY (agent_id) REFERENCES utilisateurs(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci
  COMMENT='Clients de SKILL4ALL';


-- ============================================================
-- TABLE 4 : categories_services
-- Catégories pour organiser le catalogue
-- ============================================================
CREATE TABLE categories_services (
    id          SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom         VARCHAR(80)       NOT NULL,
    description VARCHAR(255)      NOT NULL DEFAULT '',
    actif       TINYINT(1)        NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uq_categories_nom (nom)
) ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci
  COMMENT='Catégories du catalogue de services';

INSERT INTO categories_services (nom, description) VALUES
  ('Travaux divers',    'Tous types de travaux et prestations diverses'),
  ('Services généraux', 'Services généraux aux entreprises'),
  ('Négoce',            'Achat et revente de marchandises');


-- ============================================================
-- TABLE 5 : services
-- Catalogue des services proposés avec leur prix
-- ============================================================
CREATE TABLE services (
    id              INT UNSIGNED      NOT NULL AUTO_INCREMENT,
    categorie_id    SMALLINT UNSIGNED NOT NULL,
    nom             VARCHAR(150)      NOT NULL,
    description     TEXT              NULL,
    prix_ht         DECIMAL(10,2)     NOT NULL DEFAULT 0.00 COMMENT 'Prix hors taxe en MAD',
    tva_pct         DECIMAL(5,2)      NOT NULL DEFAULT 20.00 COMMENT 'Taux TVA en %',
    unite           VARCHAR(30)       NOT NULL DEFAULT 'forfait' COMMENT 'unité, heure, jour, m², kg...',
    actif           TINYINT(1)        NOT NULL DEFAULT 1,
    cree_le         DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_services_categorie (categorie_id),
    CONSTRAINT fk_services_categorie
        FOREIGN KEY (categorie_id) REFERENCES categories_services(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci
  COMMENT='Catalogue de services SKILL4ALL';

-- Exemples de services
INSERT INTO services (categorie_id, nom, description, prix_ht, tva_pct, unite) VALUES
  (1, 'Travaux de nettoyage',         'Nettoyage locaux professionnels',     500.00, 20.00, 'forfait'),
  (1, 'Travaux de peinture',          'Peinture intérieure / extérieure',    800.00, 20.00, 'm²'),
  (2, 'Conseil administratif',        'Accompagnement démarches admin',      300.00, 20.00, 'heure'),
  (2, 'Gestion courrier',             'Tri et distribution courrier',        200.00, 20.00, 'mois'),
  (3, 'Fournitures de bureau',        'Vente fournitures et consommables',   150.00, 20.00, 'unité'),
  (3, 'Équipement informatique',      'Vente matériel informatique',        2500.00, 20.00, 'unité');


-- ============================================================
-- TABLE 6 : factures
-- En-tête de chaque facture
-- ============================================================
CREATE TABLE factures (
    id              INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    numero          VARCHAR(20)      NOT NULL COMMENT 'Ex: FAC-2024-0001',
    client_id       INT UNSIGNED     NOT NULL,
    agent_id        INT UNSIGNED     NULL     COMMENT 'Agent qui a créé la facture',
    statut          ENUM('brouillon','envoyee','payee','en_retard','annulee')
                                     NOT NULL DEFAULT 'brouillon',
    date_emission   DATE             NOT NULL,
    date_echeance   DATE             NOT NULL COMMENT 'Date limite de paiement',
    date_paiement   DATE             NULL     COMMENT 'Remplie quand statut = payee',
    sous_total_ht   DECIMAL(12,2)    NOT NULL DEFAULT 0.00,
    total_tva       DECIMAL(12,2)    NOT NULL DEFAULT 0.00,
    total_ttc       DECIMAL(12,2)    NOT NULL DEFAULT 0.00,
    remise_pct      DECIMAL(5,2)     NOT NULL DEFAULT 0.00 COMMENT 'Remise globale en %',
    remise_montant  DECIMAL(12,2)    NOT NULL DEFAULT 0.00,
    notes           TEXT             NULL     COMMENT 'Conditions de paiement, notes',
    pdf_path        VARCHAR(255)     NULL     COMMENT 'Chemin vers le fichier PDF généré',
    email_envoye    TINYINT(1)       NOT NULL DEFAULT 0,
    sms_envoye      TINYINT(1)       NOT NULL DEFAULT 0,
    rappel_compte   TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Nb de rappels envoyés',
    dernier_rappel  DATETIME         NULL,
    cree_le         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_factures_numero (numero),
    KEY idx_factures_client  (client_id),
    KEY idx_factures_agent   (agent_id),
    KEY idx_factures_statut  (statut),
    KEY idx_factures_echeance (date_echeance),
    CONSTRAINT fk_factures_client
        FOREIGN KEY (client_id) REFERENCES clients(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_factures_agent
        FOREIGN KEY (agent_id) REFERENCES utilisateurs(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci
  COMMENT='En-têtes des factures SKILL4ALL';


-- ============================================================
-- TABLE 7 : lignes_facture
-- Détail de chaque ligne d'une facture (service + quantité)
-- ============================================================
CREATE TABLE lignes_facture (
    id              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    facture_id      INT UNSIGNED  NOT NULL,
    service_id      INT UNSIGNED  NULL     COMMENT 'NULL si service manuel supprimé',
    designation     VARCHAR(200)  NOT NULL COMMENT 'Copié au moment de la création',
    quantite        DECIMAL(10,3) NOT NULL DEFAULT 1.000,
    prix_unitaire_ht DECIMAL(10,2) NOT NULL,
    tva_pct         DECIMAL(5,2)  NOT NULL DEFAULT 20.00,
    total_ht        DECIMAL(12,2) NOT NULL COMMENT 'quantite × prix_unitaire_ht',
    total_tva       DECIMAL(12,2) NOT NULL,
    total_ttc       DECIMAL(12,2) NOT NULL,
    ordre           TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Ordre d affichage',
    PRIMARY KEY (id),
    KEY idx_lignes_facture (facture_id),
    KEY idx_lignes_service (service_id),
    CONSTRAINT fk_lignes_facture
        FOREIGN KEY (facture_id) REFERENCES factures(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_lignes_service
        FOREIGN KEY (service_id) REFERENCES services(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci
  COMMENT='Lignes détaillées de chaque facture';


-- ============================================================
-- TABLE 8 : devis
-- Devis avant transformation en facture
-- ============================================================
CREATE TABLE devis (
    id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
    numero          VARCHAR(20)  NOT NULL COMMENT 'Ex: DEV-2024-0001',
    client_id       INT UNSIGNED NOT NULL,
    agent_id        INT UNSIGNED NULL,
    statut          ENUM('en_attente','accepte','refuse','expire','converti')
                                 NOT NULL DEFAULT 'en_attente',
    date_emission   DATE         NOT NULL,
    date_validite   DATE         NOT NULL,
    total_ttc       DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    notes           TEXT         NULL,
    facture_id      INT UNSIGNED NULL COMMENT 'Rempli si converti en facture',
    cree_le         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_devis_numero (numero),
    KEY idx_devis_client (client_id),
    CONSTRAINT fk_devis_client
        FOREIGN KEY (client_id) REFERENCES clients(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_devis_facture
        FOREIGN KEY (facture_id) REFERENCES factures(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci
  COMMENT='Devis envoyés aux clients';


-- ============================================================
-- TABLE 9 : paiements
-- Historique des paiements reçus
-- ============================================================
CREATE TABLE paiements (
    id              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    facture_id      INT UNSIGNED  NOT NULL,
    montant         DECIMAL(12,2) NOT NULL,
    mode_paiement   ENUM('especes','virement','cheque','carte','autre')
                                  NOT NULL DEFAULT 'virement',
    reference       VARCHAR(100)  NOT NULL DEFAULT '' COMMENT 'N° chèque, ref virement',
    date_paiement   DATE          NOT NULL,
    note            VARCHAR(255)  NOT NULL DEFAULT '',
    cree_le         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_paiements_facture (facture_id),
    CONSTRAINT fk_paiements_facture
        FOREIGN KEY (facture_id) REFERENCES factures(id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci
  COMMENT='Paiements reçus par facture';


-- ============================================================
-- TABLE 10 : notifications
-- Historique de tous les emails et SMS envoyés
-- ============================================================
CREATE TABLE notifications (
    id              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    facture_id      INT UNSIGNED  NULL,
    client_id       INT UNSIGNED  NOT NULL,
    type            ENUM('email','sms')        NOT NULL,
    sujet           ENUM('facture','rappel','confirmation','autre') NOT NULL,
    destinataire    VARCHAR(180)  NOT NULL COMMENT 'Email ou numéro de téléphone',
    statut          ENUM('envoye','echec')      NOT NULL DEFAULT 'envoye',
    message_erreur  VARCHAR(255)  NULL,
    envoye_le       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_notifs_facture (facture_id),
    KEY idx_notifs_client  (client_id),
    CONSTRAINT fk_notifs_facture
        FOREIGN KEY (facture_id) REFERENCES factures(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_notifs_client
        FOREIGN KEY (client_id) REFERENCES clients(id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci
  COMMENT='Journal des emails et SMS envoyés';


-- ============================================================
-- TABLE 11 : logs
-- Journal de sécurité : toutes les actions importantes
-- ============================================================
CREATE TABLE logs (
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    utilisateur_id  INT UNSIGNED    NULL     COMMENT 'NULL si action non connectée',
    action          VARCHAR(80)     NOT NULL COMMENT 'login_succes, login_echec, facture_creee...',
    table_cible     VARCHAR(50)     NULL     COMMENT 'Table concernée par l action',
    enregistrement_id INT UNSIGNED  NULL     COMMENT 'ID de la ligne concernée',
    description     VARCHAR(500)    NOT NULL DEFAULT '',
    ip_adresse      VARCHAR(45)     NOT NULL DEFAULT '' COMMENT 'IPv4 ou IPv6',
    user_agent      VARCHAR(300)    NOT NULL DEFAULT '',
    cree_le         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_logs_utilisateur (utilisateur_id),
    KEY idx_logs_action      (action),
    KEY idx_logs_date        (cree_le),
    CONSTRAINT fk_logs_utilisateur
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci
  COMMENT='Journal de sécurité et audit des actions';


-- ============================================================
-- TABLE 12 : parametres
-- Configuration générale de l'application
-- ============================================================
CREATE TABLE parametres (
    cle             VARCHAR(80)  NOT NULL,
    valeur          TEXT         NOT NULL,
    description     VARCHAR(255) NOT NULL DEFAULT '',
    modifie_le      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (cle)
) ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci
  COMMENT='Paramètres de configuration';

INSERT INTO parametres (cle, valeur, description) VALUES
  ('entreprise_nom',       'SKILL4ALL SARL AU',                   'Nom de l entreprise'),
  ('entreprise_rc',        '180007',                              'Numéro RC'),
  ('entreprise_patente',   '26307795',                            'Numéro patente'),
  ('entreprise_if',        '66031744',                            'Identifiant fiscal'),
  ('entreprise_cnss',      '6146306',                             'Numéro CNSS'),
  ('entreprise_ice',       '003546805000097',                     'Identifiant commun entreprise'),
  ('entreprise_adresse',   'RUE DAKAR IMM N5 APPT 1 OCEAN RABAT','Adresse'),
  ('entreprise_telephone', '0661999266',                          'Téléphone'),
  ('entreprise_fax',       '0537681456',                          'Fax'),
  ('entreprise_email',     'contact@skill4all.ma',               'Email contact'),
  ('compte_bancaire',      '011815000022210000546254',            'RIB bancaire'),
  ('tva_defaut',           '20',                                  'Taux TVA par défaut en %'),
  ('delai_paiement',       '30',                                  'Délai paiement en jours'),
  ('devise',               'MAD',                                 'Devise'),
  ('facture_prefixe',      'FAC',                                 'Préfixe numéro facture'),
  ('devis_prefixe',        'DEV',                                 'Préfixe numéro devis'),
  ('rappel_jours',         '3',                                   'Envoyer rappel X jours après échéance'),
  ('logo_path',            'assets/img/logo_skill4all.png',       'Chemin logo pour les PDF');


-- ============================================================
-- VUE : vue_factures_resume
-- Vue pratique pour afficher les factures avec infos client
-- ============================================================
CREATE OR REPLACE VIEW vue_factures_resume AS
SELECT
    f.id,
    f.numero,
    f.statut,
    f.date_emission,
    f.date_echeance,
    f.date_paiement,
    f.total_ttc,
    f.email_envoye,
    f.sms_envoye,
    f.rappel_compte,
    CONCAT(c.prenom, ' ', c.nom) AS client_nom,
    c.email                       AS client_email,
    c.telephone                   AS client_telephone,
    CONCAT(u.prenom, ' ', u.nom) AS agent_nom
FROM factures f
JOIN clients      c ON f.client_id = c.id
LEFT JOIN utilisateurs u ON f.agent_id = u.id;


-- ============================================================
-- VUE : vue_tableau_de_bord
-- Statistiques pour le dashboard admin
-- ============================================================
CREATE OR REPLACE VIEW vue_tableau_de_bord AS
SELECT
    COUNT(DISTINCT c.id)                                      AS total_clients,
    COUNT(DISTINCT f.id)                                      AS total_factures,
    COALESCE(SUM(f.total_ttc), 0)                            AS chiffre_affaires_total,
    COALESCE(SUM(CASE WHEN f.statut = 'payee'     THEN f.total_ttc END), 0) AS montant_paye,
    COALESCE(SUM(CASE WHEN f.statut = 'en_retard' THEN f.total_ttc END), 0) AS montant_en_retard,
    COALESCE(SUM(CASE WHEN f.statut = 'envoyee'   THEN f.total_ttc END), 0) AS montant_en_attente,
    COUNT(CASE WHEN f.statut = 'en_retard' THEN 1 END)       AS factures_en_retard
FROM clients c
LEFT JOIN factures f ON f.client_id = c.id AND f.statut != 'annulee';

-- ============================================================
-- FIN DU SCRIPT
-- Pour importer : mysql -u root -p skill4all_db < skill4all_database.sql
-- ============================================================