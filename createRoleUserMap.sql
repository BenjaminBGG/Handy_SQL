
USE [DBA]
GO

/*
CREATE User to Database Role Mapping Table
*/

DROP TABLE IF EXISTS DBA.dbo.RoleUserMap

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [DBA].[dbo].[RoleUserMap](
	[Server] [nvarchar](128) NOT NULL DEFAULT (''),
	[PhysicalDb] [nvarchar](128) NOT NULL DEFAULT (''),
	[UserType] [nvarchar](128) NOT NULL DEFAULT (''),
	[DataBaseUserName] [nvarchar](128) NOT NULL DEFAULT (''),
	[LoginName] [nvarchar](128) NOT NULL DEFAULT (''),
	[DbRole] [nvarchar](128) NOT NULL DEFAULT (''),
	[When] [datetime] NOT NULL DEFAULT ('31-Dec-9999')
) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

ALTER TABLE [DBA].[dbo].[RoleUserMap] WITH NOCHECK ADD
CONSTRAINT [i01ROLEUSERMAP] PRIMARY KEY CLUSTERED
(
	[Server] ASC,
	[PhysicalDb] ASC,
	[DataBaseUserName] ASC,
	[DbRole] ASC
)
WITH (ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, DATA_COMPRESSION = PAGE)
ON
[PRIMARY]

GO

/*
Create dbo.dbRoleUserMap on each DB to and run to populate DBA.dbo.RoleUserMap
*/

DECLARE @SQL NVARCHAR(MAX)

SET @SQL =
'USE ? 

DROP FUNCTION IF EXISTS dbo.dbRoleUserMap;

EXEC sp_executesql N''
	CREATE FUNCTION dbo.dbRoleUserMap (@dbRole SYSNAME = ''''%'''')
	RETURNS TABLE
	AS
	RETURN (
		  SELECT
			[Server] = @@SERVERNAME, 
			[PhysicalDb] = DB_NAME(),
			[UserType] = 
			   CASE mmbrp.[type] 
			   WHEN ''''G'''' THEN ''''Windows Group'''' 
			   WHEN ''''U'''' THEN ''''Windows User''''
			   WHEN ''''S'''' THEN ''''SQL User''''
			   END,
			 [DataBaseUserName] = mmbrp.[name],
			 [LoginName] = ul.[name],
			 [DbRole] = rolp.[name],
			 [fdtmWhen] = GETDATE()
		  FROM sys.database_role_members mmbr, -- The Role OR members associations table
			 sys.database_principals rolp,     -- The DB Roles names table
			 sys.database_principals mmbrp,    -- The Role members table (database users)
			 sys.server_principals ul          -- The Login accounts table
		  WHERE Upper (mmbrp.[type]) IN ( ''''U'''', ''''G'''', ''''S'''' )
			 -- No need for these system account types
			 AND Upper (mmbrp.[name]) NOT IN (''''SYS'''',''''INFORMATION_SCHEMA'''')
			 AND rolp.[principal_id] = mmbr.[role_principal_id]
			 AND mmbrp.[principal_id] = mmbr.[member_principal_id]
			 AND ul.[sid] = mmbrp.[sid]
			 AND rolp.[name] LIKE ''''%'''' + @dbRole + ''''%''''
		  )''

	INSERT INTO DBA.dbo.RoleUserMap
	SELECT * FROM dbo.dbRoleUserMap (DEFAULT)
	EXCEPT 
	SELECT * FROM DBA.dbo.RoleUserMap

END'

--SELECT @SQL

EXEC sp_MSforeachdb @SQL

SELECT * FROM DBA.dbo.RoleUserMap
