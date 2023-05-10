
 SELECT TOP 10000 
 step_id AS [Step ID], 
 step_name AS [Step Name], 
CASE 
	WHEN(RUN_TIME) < 100000 THEN
	CAST(STUFF(STUFF(run_date, 5, 0, '-'), 8, 0, '-') + ' 0' + STUFF(STUFF(CAST(RUN_TIME AS nvarchar(30)), 2, 0, ':'), 5, 0, ':') AS DATETIME)
	ELSE CAST(STUFF(STUFF(run_date, 5, 0, '-'), 8, 0, '-') + ' ' + STUFF(STUFF(CAST(RUN_TIME AS nvarchar(30)), 3, 0, ':'), 6, 0, ':') AS DATETIME)
END
AS [Start_Time], 
run_date AS [Run_Date], 
CASE
WHEN(run_time) < 100000 THEN
'0' + CAST(run_time AS nvarchar(30))
ELSE CAST(run_time AS nvarchar(30))
END
AS [Run_Time]
, 
run_duration AS [Duration], 
CASE 
	WHEN(RUN_TIME+RUN_DURATION) < 100000 THEN
	STUFF(STUFF(run_date, 5, 0, '-'), 8, 0, '-') + ' 0' + STUFF(STUFF(CAST(RUN_TIME+RUN_DURATION AS nvarchar(30)), 2, 0, ':'), 5, 0, ':') 
	WHEN(RUN_TIME+RUN_DURATION) > 240000 THEN
	STUFF(STUFF(run_date+1, 5, 0, '-'), 8, 0, '-') + ' 0' + STUFF(STUFF(CAST(RUN_TIME+RUN_DURATION-240000 AS nvarchar(30)), 2, 0, ':'), 5, 0, ':')
	ELSE STUFF(STUFF(run_date, 5, 0, '-'), 8, 0, '-') + ' ' + STUFF(STUFF(CAST(RUN_TIME+RUN_DURATION AS nvarchar(30)), 3, 0, ':'), 6, 0, ':')
END
AS [End_Time]
 --, CAST(CAST(RUN_TIME+RUN_DURATION AS nvarchar(30)) AS TIME) 
FROM MSDB..sysjobhistory

WHERE 1=1
AND job_id =  ''
--AND step_id = 2

ORDER BY START_TIME DESC

