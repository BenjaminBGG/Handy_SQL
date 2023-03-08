
--DECLARE @DBname NVARCHAR(50)

--DECLARE @sql NVARCHAR (255)

--SET @DBname = 'FID_GTAPP'
--SET @sql = N'USE ' + @DBname;-- + CHAR(13) + N'GO';
--exec sp_executesql @sql

--INSERT INTO DBA.dbo.tblTableSize


execute sp_MSforeachdb
'USE[?]
IF DB_ID() > 4

SELECT (SELECT name from sys.databases where database_id = DB_ID()) as [Database]
, tbl.name as [TableName]
, tbl.max_column_id_used AS [Columns]

, COALESCE( ( SELECT SUM (spart.rows) FROM sys.partitions spart 
WHERE spart.object_id = tbl.object_id AND spart.index_id < 2), 0) AS [Rows]

, COALESCE( (SELECT CAST(v.low/1024.0 AS FLOAT) 
* SUM(a.used_pages - CASE WHEN a.type <> 1 THEN a.used_pages WHEN p.index_id < 2 THEN a.data_pages ELSE 0 END) 
FROM sys.indexes AS i
JOIN sys.partitions AS p ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
WHERE i.object_id = tbl.object_id), 0.0) AS [IndexKB]

, COALESCE( (SELECT CAST(V.LOW/1024.0 AS FLOAT)
* SUM(CASE WHEN a.type <> 1 THEN a.used_pages WHEN p.index_id < 2 THEN a.data_pages ELSE 0 END) 
FROM sys.indexes AS i
JOIN sys.partitions AS p ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
WHERE i.object_id = tbl.object_id), 0.0) AS [DataKB]
, GETDATE() as [When]

FROM sys.tables AS TBL
INNER JOIN sys.indexes AS IDX ON (idx.object_id = tbl.object_id AND idx.index_id < 2)
INNER JOIN master.dbo.spt_values v ON (v.number=1 AND v.type=''E'')
ORDER BY 5 DESC 
'

USE DBA
GO

CREATE TABLE TableSize(
[TableName] VARCHAR(50) DEFAULT '',
[Columns] TINYINT DEFAULT 0,
[RowCount] INT DEFAULT 0,
[IndexKB] INT DEFAULT 0,
[DataKB] INT DEFAULT 0
--,[When] datetime default getdate()) 


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Benjamin George>
-- Create date: <20171204>
-- Description:	<Logs table sizes to DBA.dbo.TableSize>
-- =============================================
CREATE PROCEDURE usp_GetTableSize
	
	@DBName VARCHAR(50)
AS
BEGIN
SET NOCOUNT ON;

INSERT INTO DBA.dbo.TableSize
SELECT tbl.name
--, COALESCE((SELECT pr.name 
--FROM sys.database_principals pr 
--WHERE pr.principal_id = tbl.principal_id)
--, SCHEMA_NAME(tbl.schema_id)) AS [Owner]
, tbl.max_column_id_used AS [Columns]

, COALESCE( ( SELECT SUM (spart.rows) FROM [@DBName.sys.partitions] spart 
WHERE spart.object_id = tbl.object_id and spart.index_id < 2), 0) AS [Rowcount]

, COALESCE( (SELECT CAST(v.low/1024.0 AS FLOAT) 
* SUM(a.used_pages - CASE WHEN a.type <> 1 THEN a.used_pages WHEN p.index_id < 2 THEN a.data_pages ELSE 0 END) 
FROM sys.indexes AS i
JOIN sys.partitions AS p ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
WHERE i.object_id = tbl.object_id), 0.0) AS [IndexKB]

, COALESCE( (SELECT CAST(v.low/1024.0 AS FLOAT)
* SUM(CASE WHEN a.type <> 1 THEN a.used_pages WHEN p.index_id < 2 THEN a.data_pages ELSE 0 END) 
FROM sys.indexes AS i
JOIN sys.partitions AS p ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
WHERE i.object_id = tbl.object_id), 0.0) AS [DataKB]
, GETDATE()

FROM sys.tables AS tbl
INNER JOIN sys.indexes AS idx ON (idx.object_id = tbl.object_id AND idx.index_id < 2)
INNER JOIN master.dbo.spt_values v ON (v.number=1 AND v.type='E')

END
GO
