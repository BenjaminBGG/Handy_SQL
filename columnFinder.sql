--ColumnFinder.sql
-- Finds all columns named %MyName% in the current DB

DECLARE @COMMAND NVARCHAR(1000) = 'USE ? SELECT DB_NAME() AS [Current Database],   c.name  AS ''ColumnName'',t.name AS ''TableName''
									FROM        sys.columns c
									JOIN        sys.tables  t   ON c.object_id = t.object_id
									WHERE       c.name LIKE ''%ColumnName%''
									ORDER BY    TableName
												,ColumnName;'



EXEC sp_MSforeachdb @COMMAND

SELECT DB_NAME() AS [Current Database],   c.name  AS 'ColumnName',t.name AS 'TableName'
									FROM        sys.columns c
									JOIN        sys.tables  t   ON c.object_id = t.object_id
									WHERE       c.name LIKE '%ColumnName%'
									ORDER BY    TableName
												,ColumnName;