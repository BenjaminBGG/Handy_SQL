-- getDBRoleMembers

SELECT 'DB Role Member' AS [Type], r.name AS [Role], m.name AS [Member]
FROM sys.database_role_members rm 
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
ORDER BY 2, 3