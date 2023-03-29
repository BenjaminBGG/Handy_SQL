--getServerRoleMembers

--SELECT 
--'Server Role Member' AS [Type], 
--r.name AS [Role], 
--m.name AS [Member] 
--FROM master.sys.server_role_members rm
--JOIN master.sys.server_principals r ON r.principal_id = rm.role_principal_id AND r.type = 'R'
--JOIN master.sys.server_principals m ON m.principal_id = rm.member_principal_id

--getDBRoleOwners
DECLARE @SQL NVARCHAR(MAX)

SET @SQL = 'USE ?
SELECT 
''DB Role Owner'' AS [Type],
''?'' AS [DB],
p2.name AS [Role],
p.name AS [Owner]
FROM sys.database_principals p
JOIN sys.database_principals p2 ON p2.owning_principal_id = p.principal_id
WHERE 1=1
AND  p.name <> ''dbo''
ORDER by 3'
EXEC sp_MSforeachdb @SQL

-- getDBRoleMembers
--DECLARE @SQL NVARCHAR(MAX)

SET @SQL =
'USE ?
SELECT 
''DB Role Member'' AS [Type], 
''?'' AS [DB],
r.name AS [Role], 
m.name AS [Member]
FROM sys.database_role_members rm 
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
ORDER BY 3, 4'
EXEC sp_MSforeachdb @SQL

-- getDBPrincipals
--DECLARE @SQL NVARCHAR(MAX)

SET @SQL = 'USE ?
SELECT 
''DB Principals'' AS [Type],
''?'' AS [DB],
p.name AS [Name],
p.default_schema_name AS [Default Schema]
FROM sys.database_principals p
WHERE 1=1 
AND p.name LIKE (''sog%'') AND p.type = ''u''
--AND p.default_schema_name <> ''dbo''
'
EXEC sp_MSforeachdb @SQL

