-- ============================================================
-- TABLES
-- ============================================================

-- File: tables/allTables.sql
--DB: cloudops-swb-db

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
    transition_id SERIAL PRIMARY KEY, -- Modificado a SERIAL
    from_status INTEGER,
    to_status INTEGER,
    role_id INTEGER,
    CONSTRAINT fk_ctl_transitions_from_status FOREIGN KEY (from_status) 
        REFERENCES cat_ticket_statuses(status_id),
    CONSTRAINT fk_ctl_transitions_to_status FOREIGN KEY (to_status) 
        REFERENCES cat_ticket_statuses(status_id),
    CONSTRAINT fk_ctl_transitions_cat_roles FOREIGN KEY (role_id) 
        REFERENCES cat_roles(role_id)
);

-- 4. TABLAS INTERMEDIAS (Se mantienen con INTEGER para la PK compuesta)

CREATE TABLE cat_permissions_roles (
    permission_id INTEGER,
    role_id INTEGER,
    PRIMARY KEY (permission_id, role_id),
    CONSTRAINT fk_cat_permissions_roles_cat_permissions FOREIGN KEY (permission_id) 
        REFERENCES cat_permissions(permission_id),
    CONSTRAINT fk_cat_permissions_roles_cat_roles FOREIGN KEY (role_id) 
        REFERENCES cat_roles(role_id)
);

CREATE TABLE mas_tickets_mas_users (
    user_id INTEGER,
    ticket_id INTEGER,
    PRIMARY KEY (user_id, ticket_id),
    CONSTRAINT fk_mas_tickets_users_mas_users FOREIGN KEY (user_id) 
        REFERENCES mas_users(user_id),
    CONSTRAINT fk_mas_tickets_users_mas_tickets FOREIGN KEY (ticket_id) 
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

-- File: inserts/init.sql
-- =========================================================
-- status
-- =========================================================
INSERT INTO cat_ticket_statuses (status_code, status_name, status_desc) VALUES
('CREATED', 'Created', 'Ticket was created by the client'),
('ASSIGNED', 'Assigned', 'Ticket was assigned to an agent'),
('IN_PROGRESS', 'In Progress', 'Ticket is being actively worked on'),
('WAITING_FOR_CLIENT', 'Waiting for Client', 'Ticket requires client response or validation'),
('RESOLVED', 'Resolved', 'Ticket was marked as resolved'),
('CLOSED', 'Closed', 'Ticket was closed and cannot be modified');


-- =========================================================
-- roles
-- =========================================================
INSERT INTO cat_roles (role_name, role_desc) VALUES
('CLIENT', 'User who creates and follows up support tickets'),
('AGENT', 'Support agent who manages assigned tickets'),
('ADMIN', 'Administrator with full ticket management permissions');


-- =========================================================
-- permissions
-- =========================================================
INSERT INTO cat_permissions (
    permission_id,
    permission_name,
    permission_desc
)
SELECT 1, 'TICKET_CREATE', 'Permite crear tickets'
WHERE NOT EXISTS (
    SELECT 1 FROM cat_permissions WHERE permission_name = 'TICKET_CREATE'
);

INSERT INTO cat_permissions (
    permission_id,
    permission_name,
    permission_desc
)
SELECT 2, 'TICKET_READ_OWN', 'Permite consultar tickets propios'
WHERE NOT EXISTS (
    SELECT 1 FROM cat_permissions WHERE permission_name = 'TICKET_READ_OWN'
);

INSERT INTO cat_permissions (
    permission_id,
    permission_name,
    permission_desc
)
SELECT 3, 'TICKET_READ_ALL', 'Permite consultar todos los tickets'
WHERE NOT EXISTS (
    SELECT 1 FROM cat_permissions WHERE permission_name = 'TICKET_READ_ALL'
);

INSERT INTO cat_permissions (
    permission_id,
    permission_name,
    permission_desc
)
SELECT 4, 'TICKET_UPDATE', 'Permite actualizar información general del ticket'
WHERE NOT EXISTS (
    SELECT 1 FROM cat_permissions WHERE permission_name = 'TICKET_UPDATE'
);

INSERT INTO cat_permissions (
    permission_id,
    permission_name,
    permission_desc
)
SELECT 5, 'TICKET_ASSIGN', 'Permite asignar o reasignar tickets'
WHERE NOT EXISTS (
    SELECT 1 FROM cat_permissions WHERE permission_name = 'TICKET_ASSIGN'
);

INSERT INTO cat_permissions (
    permission_id,
    permission_name,
    permission_desc
)
SELECT 6, 'TICKET_CHANGE_STATUS', 'Permite cambiar el estado de un ticket'
WHERE NOT EXISTS (
    SELECT 1 FROM cat_permissions WHERE permission_name = 'TICKET_CHANGE_STATUS'
);

INSERT INTO cat_permissions (
    permission_id,
    permission_name,
    permission_desc
)
SELECT 7, 'TICKET_CLOSE', 'Permite cerrar tickets'
WHERE NOT EXISTS (
    SELECT 1 FROM cat_permissions WHERE permission_name = 'TICKET_CLOSE'
);

INSERT INTO cat_permissions (
    permission_id,
    permission_name,
    permission_desc
)
SELECT 8, 'COMMENT_CREATE', 'Permite agregar comentarios a un ticket'
WHERE NOT EXISTS (
    SELECT 1 FROM cat_permissions WHERE permission_name = 'COMMENT_CREATE'
);

INSERT INTO cat_permissions (
    permission_id,
    permission_name,
    permission_desc
)
SELECT 9, 'COMMENT_READ', 'Permite consultar comentarios de un ticket'
WHERE NOT EXISTS (
    SELECT 1 FROM cat_permissions WHERE permission_name = 'COMMENT_READ'
);

INSERT INTO cat_permissions (
    permission_id,
    permission_name,
    permission_desc
)
SELECT 10, 'HISTORY_READ', 'Permite consultar historial de cambios del ticket'
WHERE NOT EXISTS (
    SELECT 1 FROM cat_permissions WHERE permission_name = 'HISTORY_READ'
);

INSERT INTO cat_permissions (
    permission_id,
    permission_name,
    permission_desc
)
SELECT 11, 'CATALOG_READ', 'Permite consultar catálogos del sistema'
WHERE NOT EXISTS (
    SELECT 1 FROM cat_permissions WHERE permission_name = 'CATALOG_READ'
);

INSERT INTO cat_permissions (
    permission_id,
    permission_name,
    permission_desc
)
SELECT 12, 'USER_MANAGE', 'Permite administrar usuarios'
WHERE NOT EXISTS (
    SELECT 1 FROM cat_permissions WHERE permission_name = 'USER_MANAGE'
);

-- =========================================================
-- PERMISOS - ROLES
-- =========================================================

-- CLIENT
INSERT INTO cat_permissions_roles (
    permission_id,
    role_id
)
SELECT p.permission_id, r.role_id
FROM cat_permissions p
JOIN cat_roles r ON r.role_name = 'CLIENT'
WHERE p.permission_name IN (
    'TICKET_CREATE',
    'TICKET_READ_OWN',
    'TICKET_CHANGE_STATUS',
    'COMMENT_CREATE',
    'COMMENT_READ',
    'HISTORY_READ',
    'CATALOG_READ'
)
AND NOT EXISTS (
    SELECT 1
    FROM cat_permissions_roles pr
    WHERE pr.permission_id = p.permission_id
      AND pr.role_id = r.role_id
);

-- AGENT
INSERT INTO cat_permissions_roles (
    permission_id,
    role_id
)
SELECT p.permission_id, r.role_id
FROM cat_permissions p
JOIN cat_roles r ON r.role_name = 'AGENT'
WHERE p.permission_name IN (
    'TICKET_READ_ALL',
    'TICKET_UPDATE',
    'TICKET_ASSIGN',
    'TICKET_CHANGE_STATUS',
    'TICKET_CLOSE',
    'COMMENT_CREATE',
    'COMMENT_READ',
    'HISTORY_READ',
    'CATALOG_READ'
)
AND NOT EXISTS (
    SELECT 1
    FROM cat_permissions_roles pr
    WHERE pr.permission_id = p.permission_id
      AND pr.role_id = r.role_id
);

-- ADMIN
INSERT INTO cat_permissions_roles (
    permission_id,
    role_id
)
SELECT p.permission_id, r.role_id
FROM cat_permissions p
JOIN cat_roles r ON r.role_name = 'ADMIN'
WHERE p.permission_name IN (
    'TICKET_CREATE',
    'TICKET_READ_OWN',
    'TICKET_READ_ALL',
    'TICKET_UPDATE',
    'TICKET_ASSIGN',
    'TICKET_CHANGE_STATUS',
    'TICKET_CLOSE',
    'COMMENT_CREATE',
    'COMMENT_READ',
    'HISTORY_READ',
    'CATALOG_READ',
    'USER_MANAGE'
)
AND NOT EXISTS (
    SELECT 1
    FROM cat_permissions_roles pr
    WHERE pr.permission_id = p.permission_id
      AND pr.role_id = r.role_id
);


-- =========================================================
-- status_transitions
-- =========================================================

INSERT INTO ctl_ticket_status_transitions (
    from_status,
    to_status,
    role_id
)
SELECT fs.status_id, ts.status_id, r.role_id
FROM cat_ticket_statuses fs
JOIN cat_ticket_statuses ts ON ts.status_code = 'ASSIGNED'
JOIN cat_roles r ON r.role_name = 'ADMIN'
WHERE fs.status_code = 'CREATED';

INSERT INTO ctl_ticket_status_transitions (
    from_status,
    to_status,
    role_id
)
SELECT fs.status_id, ts.status_id, r.role_id
FROM cat_ticket_statuses fs
JOIN cat_ticket_statuses ts ON ts.status_code = 'IN_PROGRESS'
JOIN cat_roles r ON r.role_name = 'AGENT'
WHERE fs.status_code = 'ASSIGNED';

INSERT INTO ctl_ticket_status_transitions (
    from_status,
    to_status,
    role_id
)
SELECT fs.status_id, ts.status_id, r.role_id
FROM cat_ticket_statuses fs
JOIN cat_ticket_statuses ts ON ts.status_code = 'WAITING_FOR_CLIENT'
JOIN cat_roles r ON r.role_name = 'AGENT'
WHERE fs.status_code = 'IN_PROGRESS';

INSERT INTO ctl_ticket_status_transitions (
    from_status,
    to_status,
    role_id
)
SELECT fs.status_id, ts.status_id, r.role_id
FROM cat_ticket_statuses fs
JOIN cat_ticket_statuses ts ON ts.status_code = 'IN_PROGRESS'
JOIN cat_roles r ON r.role_name = 'CLIENT'
WHERE fs.status_code = 'WAITING_FOR_CLIENT';

INSERT INTO ctl_ticket_status_transitions (
    from_status,
    to_status,
    role_id
)
SELECT fs.status_id, ts.status_id, r.role_id
FROM cat_ticket_statuses fs
JOIN cat_ticket_statuses ts ON ts.status_code = 'RESOLVED'
JOIN cat_roles r ON r.role_name = 'CLIENT'
WHERE fs.status_code = 'WAITING_FOR_CLIENT';

INSERT INTO ctl_ticket_status_transitions (
    from_status,
    to_status,
    role_id
)
SELECT fs.status_id, ts.status_id, r.role_id
FROM cat_ticket_statuses fs
JOIN cat_ticket_statuses ts ON ts.status_code = 'RESOLVED'
JOIN cat_roles r ON r.role_name = 'AGENT'
WHERE fs.status_code = 'IN_PROGRESS';

INSERT INTO ctl_ticket_status_transitions (
    from_status,
    to_status,
    role_id
)
SELECT fs.status_id, ts.status_id, r.role_id
FROM cat_ticket_statuses fs
JOIN cat_ticket_statuses ts ON ts.status_code = 'CLOSED'
JOIN cat_roles r ON r.role_name = 'ADMIN'
WHERE fs.status_code = 'RESOLVED';


-- ============================================================
-- DB USER
-- ============================================================

-- File: db-user/user.sql
CREATE USER app_user WITH PASSWORD 'app_secure_password';

GRANT USAGE ON SCHEMA public TO app_user;

-- Permisos explicitos sobre cada tabla
GRANT SELECT ON TABLE public.cat_permissions TO app_user;
GRANT SELECT ON TABLE public.cat_roles TO app_user;
GRANT SELECT ON TABLE public.cat_ticket_statuses TO app_user;
GRANT SELECT ON TABLE public.mas_users TO app_user;
GRANT SELECT ON TABLE public.mas_tickets TO app_user;
GRANT SELECT ON TABLE public.mas_comments TO app_user;
GRANT SELECT ON TABLE public.ctl_ticket_status_transitions TO app_user;
GRANT SELECT ON TABLE public.cat_permissions_roles TO app_user;
GRANT SELECT ON TABLE public.mas_tickets_mas_users TO app_user;
GRANT SELECT ON TABLE public.mas_tickets_comments TO app_user;
GRANT SELECT ON TABLE public.his_ticket_status_changes TO app_user;
GRANT SELECT ON TABLE public.his_assignation_changes TO app_user;

-- Permisos de USAGE para secuencias (necesario con columnas SERIAL)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

