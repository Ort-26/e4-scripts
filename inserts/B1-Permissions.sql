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