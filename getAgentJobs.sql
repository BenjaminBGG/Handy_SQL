-------------------------------------------------------------------------------
----Script to query database maintenance job schedule information.
-------------------------------------------------------------------------------


USE [msdb]
GO

WITH WEEKDAY AS (
	SELECT 1 AS mask, 'Sunday' AS MaskValue
	UNION ALL SELECT 2 AS mask, 'Monday' AS MaskValue
	UNION ALL SELECT 4 AS mask, 'Tuesday' AS MaskValue
	UNION ALL SELECT 8 AS mask, 'Wednesday' AS MaskValue
	UNION ALL SELECT 16 AS mask, 'Thursday' AS MaskValue
	UNION ALL SELECT 32 AS mask, 'Friday' AS MaskValue
	UNION ALL SELECT 64 AS mask, 'Saturday' AS MaskValue
),
SCHED AS (
SELECT sched.name AS 'scheduleName',
	sched.schedule_id,
	jobsched.job_id AS job_id,
	CASE 
		WHEN sched.freq_type = 1 THEN 'Once' 
		WHEN sched.freq_type = 4 AND sched.freq_interval = 1 THEN 'Daily'
		WHEN sched.freq_type = 4 THEN 'Every ' + CAST(sched.freq_interval AS VARCHAR(5)) + ' days'
		WHEN sched.freq_type = 8 THEN REPLACE(REPLACE(REPLACE((SELECT maskValue FROM WEEKDAY AS x WHERE sched.freq_interval & x.mask <> 0 ORDER BY mask FOR XML RAW), '""/><row maskValue=""', ', '), '<row maskValue=""', ''), '""/>', '') +
			CASE
				WHEN sched.freq_recurrence_factor <> 0 AND sched.freq_recurrence_factor = 1 THEN '; weekly' 
				WHEN sched.freq_recurrence_factor <> 0 THEN '; every ' + CAST(sched.freq_recurrence_factor AS VARCHAR(10)) + ' weeks' 
			END
		WHEN sched.freq_type = 16 THEN 'On day ' + CAST(sched.freq_interval AS VARCHAR(10)) + ' of every ' + CAST(sched.freq_recurrence_factor AS VARCHAR(10)) + ' months' 
		WHEN sched.freq_type = 32 THEN
			CASE 
				WHEN sched.freq_relative_interval = 1 THEN 'First'
				WHEN sched.freq_relative_interval = 2 THEN 'Second'
				WHEN sched.freq_relative_interval = 4 THEN 'Third'
				WHEN sched.freq_relative_interval = 8 THEN 'Fourth'
				WHEN sched.freq_relative_interval = 16 THEN 'Last'
			END + 
			CASE 
				WHEN sched.freq_interval = 1 THEN ' Sunday'
				WHEN sched.freq_interval = 2 THEN ' Monday'
				WHEN sched.freq_interval = 3 THEN ' Tuesday'
				WHEN sched.freq_interval = 4 THEN ' Wednesday'
				WHEN sched.freq_interval = 5 THEN ' Thursday'
				WHEN sched.freq_interval = 6 THEN ' Friday'
				WHEN sched.freq_interval = 7 THEN ' Saturday'
				WHEN sched.freq_interval = 8 THEN ' Day'
				WHEN sched.freq_interval = 9 THEN ' Weekday'
				WHEN sched.freq_interval = 10 THEN ' Weekend'
			END + 
			CASE 
				WHEN sched.freq_recurrence_factor <> 0 AND sched.freq_recurrence_factor = 1 THEN '; monthly'
				WHEN sched.freq_recurrence_factor <> 0 THEN '; every ' + CAST(sched.freq_recurrence_factor AS VARCHAR(10)) + ' months' 
			END
		WHEN sched.freq_type = 64 THEN 'StartUp'
		WHEN sched.freq_type = 128 THEN 'Idle'
	END AS 'frequency',
	ISNULL('Every ' + CAST(sched.freq_subday_interval AS VARCHAR(10)) + 
	CASE 
		WHEN sched.freq_subday_type = 2  THEN ' seconds'
		WHEN sched.freq_subday_type = 4  THEN ' minutes'
		WHEN sched.freq_subday_type = 8 THEN ' hours'
	END, 'Once') AS 'subFrequency',
	CASE LEN(sched.active_start_time) WHEN 1 THEN CAST('00:00:0' + RIGHT(sched.active_start_time, 2) AS CHAR(8))
		WHEN 2 THEN CAST('00:00:' + RIGHT(sched.active_start_time, 2) AS CHAR(8))
		WHEN 3 THEN CAST('00:0' + LEFT(RIGHT(sched.active_start_time, 3), 1) + ':' + RIGHT(sched.active_start_time, 2) AS CHAR(8))
		WHEN 4 THEN CAST('00:' + LEFT(RIGHT(sched.active_start_time, 4), 2) + ':' + RIGHT(sched.active_start_time, 2) AS CHAR(8))
		WHEN 5 THEN CAST('0' + LEFT(RIGHT(sched.active_start_time, 5), 1) + ':' + LEFT(RIGHT(sched.active_start_time, 4), 2) + ':' + RIGHT(sched.active_start_time, 2) AS CHAR(8))
		WHEN 6 THEN CAST(LEFT(RIGHT(sched.active_start_time, 6), 2) + ':' + LEFT(RIGHT(sched.active_start_time, 4), 2) + ':' + RIGHT(sched.active_start_time, 2) AS CHAR(8))
	END AS [Start_time],      
	CASE LEN(sched.active_end_time)
		WHEN 1 THEN CAST('00:00:0' + RIGHT(sched.active_end_time, 2) AS CHAR(8))
		WHEN 2 THEN CAST('00:00:' + RIGHT(sched.active_end_time, 2) AS CHAR(8))
		WHEN 3 THEN CAST('00:0'	+ LEFT(RIGHT(sched.active_end_time, 3), 1) + ':' + RIGHT(sched.active_end_time, 2) AS CHAR(8))
		WHEN 4 THEN CAST('00:' + LEFT(RIGHT(sched.active_end_time, 4), 2) + ':' + RIGHT(sched.active_end_time, 2) AS CHAR(8))
		WHEN 5 THEN CAST('0' + LEFT(RIGHT(sched.active_end_time, 5), 1) + ':' + LEFT(RIGHT(sched.active_end_time, 4), 2) + ':' + RIGHT(sched.active_end_time, 2) AS CHAR(8))
		WHEN 6 THEN CAST(LEFT(RIGHT(sched.active_end_time, 6), 2) + ':' + LEFT(RIGHT(sched.active_end_time, 4), 2) + ':' + RIGHT(sched.active_end_time, 2) AS CHAR(8))
	END AS [End_time],
	REPLICATE('0', 6 - Len(jobsched.next_run_time)) + CAST(jobsched.next_run_time AS VARCHAR(6)) AS 'nextRunTime',
	CAST(jobsched.next_run_date AS char(8)) AS 'nextRunDate'
FROM msdb.dbo.sysschedules AS sched
JOIN msdb.dbo.sysjobschedules AS jobsched
ON sched.schedule_id = jobsched.schedule_id
),
JOB AS (
SELECT job.job_id AS [job_id],
	job.Name AS [Job_Name],
	CASE job.Enabled WHEN 1 THEN 'Yes' WHEN 0 THEN 'No'	END AS [Job_Enabled],
	sched.schedule_id AS [Sched_ID],
	CASE sched.enabled WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' END AS [Sched_Enabled],
	CASE sched.freq_type
		WHEN 1 THEN 'Once'
		WHEN 4 THEN 'Daily'
		WHEN 8 THEN 'Weekly'
		WHEN 16 THEN 'Monthly'
		WHEN 32 THEN 'Monthly relative'
		WHEN 64 THEN 'WHEN SQLServer Agent starts'
	END AS [Sched_Frequency],
	CASE next_run_date
		WHEN 0 THEN NULL
		ELSE SUBSTRING(CONVERT(VARCHAR(15), next_run_date), 1, 4) + '/' + SUBSTRING(CONVERT(VARCHAR(15), next_run_date), 5, 2) + '/' + SUBSTRING(CONVERT(VARCHAR(15), next_run_date), 7, 2)
	END AS [Next_Run_Date],
	CASE LEN(next_run_time)
		WHEN 1 THEN CAST('00:00:0' + RIGHT(next_run_time, 2) AS CHAR(8))
		WHEN 2 THEN CAST('00:00:' + RIGHT(next_run_time, 2) AS CHAR(8))
		WHEN 3 THEN CAST('00:0' + LEFT(RIGHT(next_run_time, 3), 1) + ':' + RIGHT(next_run_time, 2) AS CHAR(8))
		WHEN 4 THEN CAST('00:' + LEFT(RIGHT(next_run_time, 4), 2) + ':' + RIGHT(next_run_time, 2) AS CHAR(8))
		WHEN 5 THEN CAST('0' + LEFT(RIGHT(next_run_time, 5), 1) + ':' + LEFT(RIGHT(next_run_time, 4), 2) + ':' + RIGHT(next_run_time, 2) AS CHAR(8))
		WHEN 6 THEN CAST(LEFT(RIGHT(next_run_time, 6), 2) + ':' + LEFT(RIGHT(next_run_time, 4), 2) + ':' + RIGHT(next_run_time, 2) AS CHAR(8))
	END AS [Next_Run_Time],
	CASE LEN(max_run_duration)
		WHEN 1 THEN CAST('00:00:0' + CAST(max_run_duration AS CHAR) AS CHAR(8))
		WHEN 2 THEN CAST('00:00:' + CAST(max_run_duration AS CHAR) AS CHAR(8))
		WHEN 3 THEN CAST('00:0' + LEFT(RIGHT(max_run_duration, 3), 1) + ':' + RIGHT(max_run_duration, 2) AS CHAR(8))
		WHEN 4 THEN CAST('00:' + LEFT(RIGHT(max_run_duration, 4), 2) + ':' + RIGHT(max_run_duration, 2) AS CHAR(8))
		WHEN 5 THEN CAST('0' + LEFT(RIGHT(max_run_duration, 5), 1) + ':' + LEFT(RIGHT(max_run_duration, 4), 2) + ':' + RIGHT(max_run_duration, 2) AS CHAR(8))
		WHEN 6 THEN CAST(LEFT(RIGHT(max_run_duration, 6), 2) + ':' + LEFT(RIGHT(max_run_duration, 4), 2) + ':' + RIGHT(max_run_duration, 2) AS CHAR(8))
	END AS [Max_Duration],      
	CASE LEN(min_run_duration)
		WHEN 1 THEN CAST('00:00:0' + CAST(min_run_duration AS CHAR) AS CHAR(8))
		WHEN 2 THEN CAST('00:00:' + CAST(min_run_duration AS CHAR) AS CHAR(8))
		WHEN 3 THEN CAST('00:0' + LEFT(RIGHT(min_run_duration, 3), 1) + ':' + RIGHT(min_run_duration, 2) AS CHAR(8))
		WHEN 4 THEN CAST('00:' + LEFT(RIGHT(min_run_duration, 4), 2) + ':' + RIGHT(min_run_duration, 2) AS CHAR(8))
		WHEN 5 THEN CAST('0' + LEFT(RIGHT(min_run_duration, 5), 1) + ':' + LEFT(RIGHT(min_run_duration, 4), 2) + ':' + RIGHT(min_run_duration, 2) AS CHAR(8))
		WHEN 6 THEN CAST(LEFT(RIGHT(min_run_duration, 6), 2) + ':' + LEFT(RIGHT(min_run_duration, 4), 2) + ':' + RIGHT(min_run_duration, 2) AS CHAR(8))
	END AS [Min_Duration],
	CASE LEN(avg_run_duration)
		WHEN 1 THEN CAST('00:00:0' + CAST(avg_run_duration AS CHAR) AS CHAR(8))
		WHEN 2 THEN CAST('00:00:' + CAST(avg_run_duration AS CHAR) AS CHAR(8))
		WHEN 3 THEN CAST('00:0' + LEFT(RIGHT(avg_run_duration, 3), 1) + ':' + RIGHT(avg_run_duration, 2) AS CHAR(8))
		WHEN 4 THEN CAST('00:' + LEFT(RIGHT(avg_run_duration, 4), 2) + ':' + RIGHT(avg_run_duration, 2) AS CHAR(8))
		WHEN 5 THEN CAST('0' + LEFT(RIGHT(avg_run_duration, 5), 1) + ':' + LEFT(RIGHT(avg_run_duration, 4), 2) + ':' + RIGHT(avg_run_duration, 2) AS CHAR(8))
		WHEN 6 THEN CAST(LEFT(RIGHT(avg_run_duration, 6), 2) + ':' + LEFT(RIGHT(avg_run_duration, 4), 2) + ':' + RIGHT(avg_run_duration, 2) AS CHAR(8))
	END AS [Avg_Duration],
	CASE (sched.freq_subday_interval)
		WHEN 0 THEN 'Once'
		ELSE CAST('Every ' + RIGHT(sched.freq_subday_interval, 2) + ' ' + 
			CASE (sched.freq_subday_type)
				WHEN 1 THEN 'Once'
				WHEN 4 THEN 'Minutes'
				WHEN 8 THEN 'Hours'
			END AS CHAR(16))
	END AS [Subday_Frequency],
	sched.active_end_date AS [Sched_End Date],
	sched.active_end_time AS [Sched_End Time],
	CASE WHEN oper.enabled = 0 THEN 'Disabled: ' ELSE '' END + oper.name AS [Fail_Notify_Name],
	oper.email_address AS [Fail_Notify_Email],
	server
FROM dbo.sysjobs job
LEFT JOIN (
	SELECT	job_schd.job_id,
		sys_schd.enabled,
		sys_schd.schedule_id,
		sys_schd.freq_type,
		sys_schd.freq_subday_type,
		sys_schd.freq_subday_interval,
		CASE WHEN job_schd.next_run_date = 0 THEN sys_schd.active_start_date ELSE job_schd.next_run_date END AS [next_run_date],
		CASE WHEN job_schd.next_run_date = 0 THEN sys_schd.active_start_time ELSE job_schd.next_run_time END AS [next_run_time],
		NULLIF(sys_schd.active_end_date, '99991231') AS [active_end_date],
		NULLIF(sys_schd.active_end_time, '235959') AS [active_end_time]
	FROM dbo.sysjobschedules job_schd
	LEFT JOIN dbo.sysschedules sys_schd ON job_schd.schedule_id = sys_schd.schedule_id
) sched ON job.job_id = sched.job_id
LEFT OUTER JOIN (
	SELECT job_id,
		server,
		MAX(job_his.run_duration) AS [max_run_duration],
		MIN(job_his.run_duration) AS [min_run_duration],
		AVG(job_his.run_duration) AS [avg_run_duration]
	FROM dbo.sysjobhistory job_his
	GROUP BY job_id, server
) Q1 ON job.job_id = Q1.job_id
LEFT JOIN sysoperators oper ON job.notify_email_operator_id = oper.id
)
----

SELECT ISNULL(b.server,CONVERT(VARCHAR(MAX),SERVERPROPERTY('ServerName'))) AS fstrServer, 
	b.job_name AS Job,
	b.job_enabled AS JobEnabled,
	ISNULL(b.sched_enabled,'No') AS SchedEnabled,
	ISNULL(a.scheduleName, 'None') AS fstrScheduleName, ISNULL(a.frequency,'Not scheduled') AS Frequency, 
	ISNULL(a.subFrequency, 'None') AS fstrSubFrequency, ISNULL(a.start_time,'-') AS fdtmStartTime, ISNULL(a.end_Time,'-') AS EndTime, 
	ISNULL(b.Next_Run_Date, '-') AS NextRunDate,  ISNULL(b.Next_Run_Time, '-') AS NextRunTime, 
	ISNULL(b.Max_Duration, '-') AS MaxDuration,    ISNULL(b.Min_Duration, '-') AS MinDuration, 
	ISNULL(b.Avg_Duration, '-') AS AvgDuration,    ISNULL(b.Fail_Notify_Name, 'None') AS FailNotifyName, 
	ISNULL(b.Fail_Notify_Email, 'None') AS FailNotifyEmail
FROM SCHED a RIGHT OUTER JOIN JOB b ON a.job_id = b.job_id 
ORDER BY job_name
