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
('TICKET_COMMENT', 'Can add comments to tickets'),
('TICKET_REOPEN', 'Can reopen a resolved ticket')
ON CONFLICT DO NOTHING;

-- =========================================================
-- PERMISOS - ROLES
-- =========================================================
-- =========================================================
-- PERMISSIONS - ROLES
-- =========================================================
