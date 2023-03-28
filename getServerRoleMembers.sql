--getServerRoleMembers

SELECT r.name AS Role, m.name AS Principal FROM master.sys.server_role_members rm
INNER JOIN
master.sys.server_principals r ON r.principal_id = rm.role_principal_id AND r.type = 'R'
INNER JOIN
master.sys.server_principals m ON m.principal_id = rm.member_principal_id