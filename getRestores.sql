-- Get most recent restores
WITH LastRestores AS
(
SELECT
    DatabaseName = [d].[name] ,
    [d].[create_date] ,
    [d].[compatibility_level] ,
    [d].[collation_name] ,
    r.*,
    RowNum = ROW_NUMBER() OVER (PARTITION BY d.Name ORDER BY r.[restore_date] DESC)
FROM master.sys.databases d
LEFT OUTER JOIN msdb.dbo.[restorehistory] r ON r.[destination_database_name] = d.Name
)
SELECT *
FROM [LastRestores]
WHERE [RowNum] = 1
and [DatabaseName] like ('%%')

order by restore_date desc


-- Get running restores/backups
SELECT r.session_id AS [Session_Id]
    ,r.command AS [command]
    ,CONVERT(NUMERIC(6, 2), r.percent_complete) AS [% Complete]
    ,GETDATE() AS [Current Time]
    ,CONVERT(VARCHAR(20), DATEADD(ms, r.estimated_completion_time, GetDate()), 20) AS [Estimated Completion Time]
    ,CONVERT(NUMERIC(32, 2), r.total_elapsed_time / 1000.0 / 60.0) AS [Elapsed Min]
    ,CONVERT(NUMERIC(32, 2), r.estimated_completion_time / 1000.0 / 60.0) AS [Estimated Min]
    ,CONVERT(NUMERIC(32, 2), r.estimated_completion_time / 1000.0 / 60.0 / 60.0) AS [Estimated Hours]
    ,CONVERT(VARCHAR(1000), (
            SELECT SUBSTRING(TEXT, r.statement_start_offset / 2, CASE
                        WHEN r.statement_end_offset = - 1
                            THEN 1000
                        ELSE (r.statement_end_offset - r.statement_start_offset) / 2
                        END) 'Statement text'
            FROM sys.dm_exec_sql_text(sql_handle)
            ))
FROM sys.dm_exec_requests r
WHERE command like 'RESTORE%'
or  command like 'BACKUP%'

-- Get running restores/backups 2
SELECT r.command AS 'Command Executing'
    ,s.text AS 'SQL Text'
    ,r.start_time AS 'Start Time'
    ,r.percent_complete AS 'Percent Complete'
    ,CONVERT(VARCHAR(30), DATEDIFF(SS,r.start_time,GETDATE())/3600, 120) + ' hr, '
        + CONVERT(VARCHAR(30), (DATEDIFF(SS,r.start_time,GETDATE()) %3600) /60, 120) + ' min, '
        + CONVERT(VARCHAR(30), DATEDIFF(SS,r.start_time,GETDATE()) %60, 120) + ' sec' AS 'Running Time'
    ,CONVERT(VARCHAR(30), ((r.estimated_completion_time /1000) /60) /60) + ' hr, '
        + CONVERT(VARCHAR(30), ((r.estimated_completion_time /1000) /60) %60) + ' min, '
        + CONVERT(VARCHAR(30), ((r.estimated_completion_time /1000) %60) %60) + ' sec' AS 'Estimated Time Remaining'
    ,DATEADD(SS,r.estimated_completion_time /1000, GETDATE()) AS 'Estimated Completion Time'
    ,DB_NAME(r.database_id) AS 'Database Name'
FROM sys.dm_exec_requests r 
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) s 
WHERE r.command IN ('RESTORE DATABASE'
                    ,'RESTORE HEADERONLY'
                    ,'BACKUP DATABASE'
                    ,'RESTORE LOG'
                    ,'BACKUP LOG'
                    ,'RESTORE VERIFYON'
                    ,'UPDATE STATISTIC'
                    ,'DBCC ALLOC CHECK'
                    ,'DBCC TABLE CHECK')