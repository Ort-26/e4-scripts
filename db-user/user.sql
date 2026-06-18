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