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