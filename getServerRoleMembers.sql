--getServerRoleMembers

SELECT 
'Server Role Member' AS [Type], 
r.name AS [Role], 
m.name AS [Member] 
FROM master.sys.server_role_members rm
JOIN master.sys.server_principals r ON r.principal_id = rm.role_principal_id AND r.type = 'R'
JOIN master.sys.server_principals m ON m.principal_id = rm.member_principal_id