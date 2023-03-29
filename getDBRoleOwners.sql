--getDBRoleOwners

SELECT 
'DB Role Owner' AS [Type],
p2.name AS [Role], 
p.name AS [Owner] 
FROM sys.database_principals p
JOIN sys.database_principals p2 ON p2.owning_principal_id = p.principal_id

