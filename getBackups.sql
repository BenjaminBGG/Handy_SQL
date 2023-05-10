-- GetBackups.sql
-- Returns list of backups on server for last @plngDaysBack


DECLARE @DaysBack int = 1

SELECT 
CONVERT(CHAR(100), SERVERPROPERTY('%%')) AS Server, 
msdb.dbo.backupset.database_name AS [DB], 
msdb.dbo.backupset.backup_start_date AS [Start], 
msdb.dbo.backupset.backup_finish_date AS [Finish], 
msdb.dbo.backupset.expiration_date AS [Expires], 
CASE msdb..backupset.type 
WHEN 'D' THEN 'Database' 
WHEN 'L' THEN 'Log' 
WHEN 'I' THEN 'Differential'
END AS [Type], 
msdb.dbo.backupset.backup_size AS [Size], 
msdb.dbo.backupmediafamily.logical_device_name AS [Logical], 
msdb.dbo.backupmediafamily.physical_device_name AS [Physical], 
msdb.dbo.backupset.name AS [Set Name], 
msdb.dbo.backupset.description AS [Description]
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - @DaysBack) 

ORDER BY 
--msdb.dbo.backupset.database_name, 
msdb.dbo.backupset.backup_finish_date 
