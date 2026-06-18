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
    ticket_id INTEGER PRIMARY KEY, 
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