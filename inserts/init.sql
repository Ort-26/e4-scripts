-- =========================================================
-- status
-- =========================================================
INSERT INTO cat_ticket_statuses (code, name, description) VALUES
('CREATED', 'Created', 'Ticket was created by the client'),
('ASSIGNED', 'Assigned', 'Ticket was assigned to an agent'),
('IN_PROGRESS', 'In Progress', 'Ticket is being actively worked on'),
('WAITING_FOR_CLIENT', 'Waiting for Client', 'Ticket requires client response or validation'),
('RESOLVED', 'Resolved', 'Ticket was marked as resolved'),
('CLOSED', 'Closed', 'Ticket was closed and cannot be modified');


-- =========================================================
-- roles
-- =========================================================
INSERT INTO cat_roles (code, name, description) VALUES
('CLIENT', 'Client', 'User who creates and follows up support tickets'),
('AGENT', 'Agent', 'Support agent who manages assigned tickets'),
('ADMIN', 'Admin', 'Administrator with full ticket management permissions');


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

INSERT INTO ticket_status_transitions (
    from_status_id,
    to_status_id,
    role_id
)
SELECT fs.id, ts.id, r.id
FROM cat_ticket_statuses fs
JOIN cat_ticket_statuses ts ON ts.code = 'ASSIGNED'
JOIN cat_roles r ON r.code = 'ADMIN'
WHERE fs.code = 'CREATED';

INSERT INTO ticket_status_transitions (
    from_status_id,
    to_status_id,
    role_id
)
SELECT fs.id, ts.id, r.id
FROM cat_ticket_statuses fs
JOIN cat_ticket_statuses ts ON ts.code = 'IN_PROGRESS'
JOIN cat_roles r ON r.code = 'AGENT'
WHERE fs.code = 'ASSIGNED';

INSERT INTO ticket_status_transitions (
    from_status_id,
    to_status_id,
    role_id
)
SELECT fs.id, ts.id, r.id
FROM cat_ticket_statuses fs
JOIN cat_ticket_statuses ts ON ts.code = 'WAITING_FOR_CLIENT'
JOIN cat_roles r ON r.code = 'AGENT'
WHERE fs.code = 'IN_PROGRESS';

INSERT INTO ticket_status_transitions (
    from_status_id,
    to_status_id,
    role_id
)
SELECT fs.id, ts.id, r.id
FROM cat_ticket_statuses fs
JOIN cat_ticket_statuses ts ON ts.code = 'IN_PROGRESS'
JOIN cat_roles r ON r.code = 'CLIENT'
WHERE fs.code = 'WAITING_FOR_CLIENT';

INSERT INTO ticket_status_transitions (
    from_status_id,
    to_status_id,
    role_id
)
SELECT fs.id, ts.id, r.id
FROM cat_ticket_statuses fs
JOIN cat_ticket_statuses ts ON ts.code = 'RESOLVED'
JOIN cat_roles r ON r.code = 'CLIENT'
WHERE fs.code = 'WAITING_FOR_CLIENT';

INSERT INTO ticket_status_transitions (
    from_status_id,
    to_status_id,
    role_id
)
SELECT fs.id, ts.id, r.id
FROM cat_ticket_statuses fs
JOIN cat_ticket_statuses ts ON ts.code = 'RESOLVED'
JOIN cat_roles r ON r.code = 'AGENT'
WHERE fs.code = 'IN_PROGRESS';

INSERT INTO ticket_status_transitions (
    from_status_id,
    to_status_id,
    role_id
)
SELECT fs.id, ts.id, r.id
FROM cat_ticket_statuses fs
JOIN cat_ticket_statuses ts ON ts.code = 'CLOSED'
JOIN cat_roles r ON r.code = 'ADMIN'
WHERE fs.code = 'RESOLVED';