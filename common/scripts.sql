select * from cat_permissions

select * from cat_roles

select * from cat_ticket_statuses

SELECT a.*,b.permission_name, c.status_name as from_name, d.status_name as to_name
FROM ctl_ticket_status_transitions a 
JOIN cat_permissions b ON a.permission_id = b.permission_id
JOIN cat_ticket_statuses c ON a.from_status = c.status_id
JOIN cat_ticket_statuses d ON a.to_status = d.status_id
-- WHERE b.permission_name in (
-- 'TICKET_IN_PROGRESS'
-- ,'TICKET_RESOLVE'
-- )
order by a.transition_id



SELECT * 
from ctl_roles_permissions a
JOIN cat_roles c on c.role_id = a.role_id 
JOIN cat_permissions b ON b.permission_id = a.permission_id


-- UPDATE ctl_ticket_status_transitions 
-- set transition_id = 10
-- where transition_id = 21




