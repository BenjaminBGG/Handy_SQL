--getDBRoleOwners

	SELECT p.name AS [Owner], p2.name AS [Role] FROM sys.database_principals p
	JOIN sys.database_principals p2
	ON p2.owning_principal_id = p.principal_id
	
