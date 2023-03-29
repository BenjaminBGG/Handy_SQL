--getServerRoleMembers

SELECT 
'DB Role Member' AS [Type], 
r.name AS [Role], 
m.name AS [Member] 
FROM master.sys.server_role_members rm
JOIN master.sys.server_principals r ON r.principal_id = rm.role_principal_id AND r.type = 'R'
JOIN master.sys.server_principals m ON m.principal_id = rm.member_principal_id


-- getDBRoleMembers

SELECT 
'DB Role Member' AS [Type], 
r.name AS [Role], 
m.name AS [Member]
FROM sys.database_role_members rm 
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
ORDER BY 2, 3


--getDBRoleOwners

SELECT 
'DB Role Owner' AS [Type],
p2.name AS [Role], 
p.name AS [Owner] 
FROM sys.database_principals p
JOIN sys.database_principals p2 ON p2.owning_principal_id = p.principal_id

