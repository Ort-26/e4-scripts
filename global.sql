-- ============================================================
-- TABLES
-- ============================================================

-- File: tables/allTables.sql
--DB: e4-support-db

-- 1. CATÁLOGOS BASE (Tablas maestras independientes)

CREATE TABLE cat_permissions (
    permission_id SERIAL PRIMARY KEY, -- Modificado a SERIAL
    permission_name VARCHAR(30) NOT NULL,
    permission_desc VARCHAR(100)
);

CREATE TABLE cat_roles (
    role_id SERIAL PRIMARY KEY, -- Modificado a SERIAL
    role_name VARCHAR(30) NOT NULL,
    role_desc VARCHAR(100)
);

CREATE TABLE cat_ticket_statuses (
    status_id SERIAL PRIMARY KEY, -- Modificado a SERIAL
    status_code VARCHAR(100) NOT NULL,
    status_name VARCHAR(100) NOT NULL,
    status_desc VARCHAR(200)
);

-- 2. TABLAS MAESTRAS CON LLAVES FORÁNEAS SIMPLE

CREATE TABLE mas_users (
    user_id SERIAL PRIMARY KEY, -- Modificado a SERIAL
    user_name VARCHAR(30) NOT NULL,
    user_lastname VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    role_id INTEGER,
    hash_password VARCHAR(500) NOT NULL,
    CONSTRAINT fk_mas_users_cat_roles FOREIGN KEY (role_id) 
        REFERENCES cat_roles(role_id)
);

CREATE TABLE mas_tickets (
    ticket_id SERIAL PRIMARY KEY, -- Modificado a SERIAL
    ticket_title VARCHAR(100) NOT NULL,
    ticket_desc VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_id INTEGER,
    agent_id INTEGER DEFAULT NULL,
    CONSTRAINT fk_mas_tickets_cat_ticket_statuses FOREIGN KEY (status_id) 
        REFERENCES cat_ticket_statuses(status_id)
);

CREATE TABLE mas_comments (
    comment_id SERIAL PRIMARY KEY, -- Modificado a SERIAL
    content TEXT NOT NULL,
    commented_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mas_comments_mas_users FOREIGN KEY (commented_by) 
        REFERENCES mas_users(user_id)
);

-- 3. TABLAS DE CONTROL Y TRANSICIONES

CREATE TABLE ctl_ticket_status_transitions (
    transition_id SERIAL PRIMARY KEY,
    from_status INTEGER NOT NULL,
    to_status INTEGER NOT NULL,
    permission_id INTEGER NOT NULL,

    CONSTRAINT fk_ctl_transitions_from_status 
        FOREIGN KEY (from_status) 
        REFERENCES cat_ticket_statuses(status_id),

    CONSTRAINT fk_ctl_transitions_to_status 
        FOREIGN KEY (to_status) 
        REFERENCES cat_ticket_statuses(status_id),

    CONSTRAINT fk_ctl_transitions_cat_permissions 
        FOREIGN KEY (permission_id) 
        REFERENCES cat_permissions(permission_id),

    CONSTRAINT uq_ticket_status_transition_permission 
        UNIQUE (from_status, to_status, permission_id)
);

-- 4. TABLAS INTERMEDIAS (Se mantienen con INTEGER para la PK compuesta)

CREATE TABLE ctl_roles_permissions (
    permission_id INTEGER,
    role_id INTEGER,
    PRIMARY KEY (permission_id, role_id),
    CONSTRAINT fk_ctl_roles_permissions_cat_permissions FOREIGN KEY (permission_id) 
        REFERENCES cat_permissions(permission_id),
    CONSTRAINT fk_ctl_roles_permissions_cat_roles FOREIGN KEY (role_id) 
        REFERENCES cat_roles(role_id)
);

CREATE TABLE mas_tickets_mas_users (
    user_id INTEGER,
    ticket_id INTEGER,
    PRIMARY KEY (user_id, ticket_id),
    CONSTRAINT fk_mas_tickets_mas_users_mas_users FOREIGN KEY (user_id) 
        REFERENCES mas_users(user_id),
    CONSTRAINT fk_mas_tickets_mas_users_mas_tickets FOREIGN KEY (ticket_id) 
        REFERENCES mas_tickets(ticket_id)
);

CREATE TABLE mas_tickets_comments (
    ticket_id INTEGER,
    comment_id INTEGER,
    PRIMARY KEY (ticket_id, comment_id),
    CONSTRAINT fk_mas_tickets_comments_mas_tickets FOREIGN KEY (ticket_id) 
        REFERENCES mas_tickets(ticket_id),
    CONSTRAINT fk_mas_tickets_comments_mas_comments FOREIGN KEY (comment_id) 
        REFERENCES mas_comments(comment_id)
);

-- 5. TABLAS DE HISTORIAL

CREATE TABLE his_ticket_status_changes (
    his_change_id SERIAL PRIMARY KEY, 
    ticket_id INTEGER, 
    old_status INTEGER,
    new_status INTEGER,
    changed_by INTEGER,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_id INTEGER,
    CONSTRAINT fk_his_ticket_status_changes_status FOREIGN KEY (status_id) 
        REFERENCES cat_ticket_statuses(status_id)
);

CREATE TABLE his_assignation_changes (
    his_status_id SERIAL PRIMARY KEY, 
    ticket_id INTEGER, 
    old_user INTEGER,
    new_user INTEGER,
    changed_by INTEGER,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- FUNCTIONS
-- ============================================================

-- (no .sql files found in functions)

-- ============================================================
-- INSERTS
-- ============================================================

-- File: inserts/A0 - catalogs.sql
-- =========================================================
-- status
-- =========================================================
INSERT INTO cat_ticket_statuses (status_code, status_name, status_desc) VALUES
('CREATED', 'Created', 'Ticket was created by the client'),
('ASSIGNED', 'Assigned', 'Ticket was assigned to an agent'),
('IN_PROGRESS', 'In Progress', 'Ticket is being actively worked on'),
('WAITING_FOR_CLIENT', 'Waiting for Client', 'Ticket requires client response or validation'),
('RESOLVED', 'Resolved', 'Ticket was marked as resolved'),
('CLOSED', 'Closed', 'Ticket was closed and cannot be modified')
ON CONFLICT DO NOTHING;


-- =========================================================
-- roles
-- =========================================================
INSERT INTO cat_roles (role_name, role_desc) VALUES
('CLIENT', 'User who creates and follows up support tickets'),
('AGENT', 'Support agent who manages assigned tickets'),
('ADMIN', 'Administrator with full ticket management permissions')
ON CONFLICT DO NOTHING;


-- =========================================================
-- permissions
-- =========================================================
INSERT INTO cat_permissions (permission_name, permission_desc)
VALUES
('TICKET_CREATE', 'Can create tickets'),
('TICKET_READ_OWN', 'Can read own tickets'),
('TICKET_READ_ALL', 'Can read all tickets'),
('TICKET_ASSIGN', 'Can assign tickets to agents'),
('TICKET_START_PROGRESS', 'Can move assigned tickets to in progress'),
('TICKET_REQUEST_CLIENT_INFO', 'Can request information from the client'),
('TICKET_CLIENT_RESPOND', 'Can respond when ticket is waiting for client'),
('TICKET_RESOLVE', 'Can resolve tickets'),
('TICKET_CLOSE', 'Can close resolved tickets'),
('TICKET_CLOSE_ANY', 'Can force close tickets from non-final states'),
('TICKET_COMMENT', 'Can add comments to tickets')
('TICKET_REOPEN', 'Can reopen a resolved ticket')
ON CONFLICT DO NOTHING;

-- =========================================================
-- PERMISOS - ROLES
-- =========================================================
-- =========================================================
-- PERMISSIONS - ROLES
-- =========================================================

-- =========================================================
-- ASSIGN PERMISSIONS TO CLIENT
-- =========================================================
INSERT INTO ctl_roles_permissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM cat_roles r
JOIN cat_permissions p 
    ON p.permission_name IN (
        'TICKET_CREATE',
        'TICKET_READ_OWN',
        'TICKET_CLIENT_RESPOND',
        'TICKET_CLOSE',
        'TICKET_COMMENT',
        'TICKET_REOPEN'
    )
WHERE r.role_name = 'CLIENT'
ON CONFLICT DO NOTHING;


-- =========================================================
-- ASSIGN PERMISSIONS TO AGENT
-- =========================================================
INSERT INTO ctl_roles_permissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM cat_roles r
JOIN cat_permissions p 
    ON p.permission_name IN (
        'TICKET_READ_ALL',
        'TICKET_START_PROGRESS',
        'TICKET_REQUEST_CLIENT_INFO',
        'TICKET_RESOLVE',
        'TICKET_COMMENT'
    )
WHERE r.role_name = 'AGENT'
ON CONFLICT DO NOTHING;


-- =========================================================
-- ASSIGN PERMISSIONS TO ADMIN
-- =========================================================
INSERT INTO ctl_roles_permissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM cat_roles r
JOIN cat_permissions p 
    ON p.permission_name IN (
        'TICKET_CREATE',
        'TICKET_READ_OWN',
        'TICKET_READ_ALL',
        'TICKET_ASSIGN',
        'TICKET_START_PROGRESS',
        'TICKET_REQUEST_CLIENT_INFO',
        'TICKET_CLIENT_RESPOND',
        'TICKET_RESOLVE',
        'TICKET_CLOSE',
        'TICKET_CLOSE_ANY',
        'TICKET_COMMENT',
        'TICKET_REOPEN'
    )
WHERE r.role_name = 'ADMIN'
ON CONFLICT DO NOTHING;


-- File: inserts/B1-Permissions.sql
-- =========================================================
-- ASSIGN PERMISSIONS TO CLIENT
-- =========================================================
INSERT INTO ctl_roles_permissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM cat_roles r
JOIN cat_permissions p 
    ON p.permission_name IN (
        'TICKET_CREATE',
        'TICKET_READ_OWN',
        'TICKET_CLIENT_RESPOND',
        'TICKET_CLOSE',
        'TICKET_COMMENT',
        'TICKET_REOPEN'
    )
WHERE r.role_name = 'CLIENT'
ON CONFLICT DO NOTHING;


-- =========================================================
-- ASSIGN PERMISSIONS TO AGENT
-- =========================================================
INSERT INTO ctl_roles_permissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM cat_roles r
JOIN cat_permissions p 
    ON p.permission_name IN (
        'TICKET_READ_ALL',
        'TICKET_START_PROGRESS',
        'TICKET_REQUEST_CLIENT_INFO',
        'TICKET_RESOLVE',
        'TICKET_COMMENT'
    )
WHERE r.role_name = 'AGENT'
ON CONFLICT DO NOTHING;


-- =========================================================
-- ASSIGN PERMISSIONS TO ADMIN
-- =========================================================
INSERT INTO ctl_roles_permissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM cat_roles r
JOIN cat_permissions p 
    ON p.permission_name IN (
        'TICKET_CREATE',
        'TICKET_READ_OWN',
        'TICKET_READ_ALL',
        'TICKET_ASSIGN',
        'TICKET_START_PROGRESS',
        'TICKET_REQUEST_CLIENT_INFO',
        'TICKET_CLIENT_RESPOND',
        'TICKET_RESOLVE',
        'TICKET_CLOSE',
        'TICKET_CLOSE_ANY',
        'TICKET_COMMENT',
        'TICKET_REOPEN'
    )
WHERE r.role_name = 'ADMIN'
ON CONFLICT DO NOTHING;


-- =========================================================
-- FINAL TICKET STATUS TRANSITIONS
-- =========================================================

INSERT INTO ctl_ticket_status_transitions 
(from_status, to_status, permission_id)
VALUES
-- CREATED -> ASSIGNED
(
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'CREATED'),
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'ASSIGNED'),
    (SELECT permission_id FROM cat_permissions WHERE permission_name = 'TICKET_ASSIGN')
),

-- ASSIGNED -> IN_PROGRESS
(
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'ASSIGNED'),
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'IN_PROGRESS'),
    (SELECT permission_id FROM cat_permissions WHERE permission_name = 'TICKET_START_PROGRESS')
),

-- IN_PROGRESS -> WAITING_FOR_CLIENT
(
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'IN_PROGRESS'),
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'WAITING_FOR_CLIENT'),
    (SELECT permission_id FROM cat_permissions WHERE permission_name = 'TICKET_REQUEST_CLIENT_INFO')
),

-- WAITING_FOR_CLIENT -> IN_PROGRESS
(
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'WAITING_FOR_CLIENT'),
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'IN_PROGRESS'),
    (SELECT permission_id FROM cat_permissions WHERE permission_name = 'TICKET_CLIENT_RESPOND')
),

-- IN_PROGRESS -> RESOLVED
(
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'IN_PROGRESS'),
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'RESOLVED'),
    (SELECT permission_id FROM cat_permissions WHERE permission_name = 'TICKET_RESOLVE')
),

-- RESOLVED -> CLOSED
(
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'RESOLVED'),
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'CLOSED'),
    (SELECT permission_id FROM cat_permissions WHERE permission_name = 'TICKET_CLOSE')
),

-- CREATED -> CLOSED
(
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'CREATED'),
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'CLOSED'),
    (SELECT permission_id FROM cat_permissions WHERE permission_name = 'TICKET_CLOSE_ANY')
),

-- ASSIGNED -> CLOSED
(
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'ASSIGNED'),
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'CLOSED'),
    (SELECT permission_id FROM cat_permissions WHERE permission_name = 'TICKET_CLOSE_ANY')
),

-- IN_PROGRESS -> CLOSED
(
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'IN_PROGRESS'),
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'CLOSED'),
    (SELECT permission_id FROM cat_permissions WHERE permission_name = 'TICKET_CLOSE_ANY')
),

-- WAITING_FOR_CLIENT -> CLOSED
(
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'WAITING_FOR_CLIENT'),
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'CLOSED'),
    (SELECT permission_id FROM cat_permissions WHERE permission_name = 'TICKET_CLOSE_ANY')
),

-- RESOLVED -> IN_PROGRESS
(
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'RESOLVED'),
    (SELECT status_id FROM cat_ticket_statuses WHERE status_code = 'IN_PROGRESS'),
    (SELECT permission_id FROM cat_permissions WHERE permission_name = 'TICKET_REOPEN')
)
ON CONFLICT DO NOTHING;


-- File: inserts/U1 - users.sql
INSERT INTO mas_users (
    user_name,
    user_lastname,
    email,
    role_id,
    hash_password
)
VALUES (
    'Carlos',
    'Cliente Demo',
    'cliente.demo@e4-support.com',
    (SELECT role_id FROM cat_roles WHERE role_name = 'CLIENT'),
    '$2b$10$pC6tjCsWcvonPLkeeJRb4O65dgI8La.lDxNa44XLO.WycMg4YVYFi'
);

INSERT INTO mas_users (
    user_name,
    user_lastname,
    email,
    role_id,
    hash_password
)
VALUES (
    'Ana',
    'Agente Demo',
    'agente.demo@e4-support.com',
    (SELECT role_id FROM cat_roles WHERE role_name = 'AGENT'),
    '$2b$10$0PSw1vxkCU1X8ELVwEoDYOxdXxX0ntMp.pSXlps7AaQI542.4zDBa'
);

INSERT INTO mas_users (
    user_name,
    user_lastname,
    email,
    role_id,
    hash_password
)
VALUES (
    'Admin',
    'Sistema',
    'admin.demo@e4-support.com',
    (SELECT role_id FROM cat_roles WHERE role_name = 'ADMIN'),
    '$2b$10$QzBxgev8Z79HGfohchYR/eoUilUzntE5d8sgxTMmMXgOG9N0u/MAq'
);


-- File: inserts/mock-data.sql



-- ============================================================
-- DB USER
-- ============================================================

-- File: db-user/user.sql
CREATE USER app_user WITH PASSWORD 'app_secure_password';

GRANT USAGE ON SCHEMA public TO app_user;

-- Tablas de catálogo (solo lectura)
GRANT SELECT ON TABLE public.cat_permissions TO app_user;
GRANT SELECT ON TABLE public.cat_roles TO app_user;
GRANT SELECT ON TABLE public.cat_ticket_statuses TO app_user;
GRANT SELECT ON TABLE public.ctl_ticket_status_transitions TO app_user;
GRANT SELECT ON TABLE public.ctl_roles_permissions TO app_user;

-- Usuarios (lectura para autenticación)
GRANT SELECT ON TABLE public.mas_users TO app_user;

-- Tickets (lectura y escritura)
GRANT SELECT, INSERT, UPDATE ON TABLE public.mas_tickets TO app_user;
GRANT SELECT, INSERT ON TABLE public.mas_tickets_mas_users TO app_user;

-- Comentarios (lectura y escritura)
GRANT SELECT, INSERT ON TABLE public.mas_comments TO app_user;
GRANT SELECT, INSERT ON TABLE public.mas_tickets_comments TO app_user;

-- Historial (solo inserción)
GRANT SELECT, INSERT ON TABLE public.his_ticket_status_changes TO app_user;
GRANT SELECT, INSERT ON TABLE public.his_assignation_changes TO app_user;

-- Permisos de USAGE para secuencias (necesario con columnas SERIAL)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

