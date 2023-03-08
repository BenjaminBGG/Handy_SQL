SELECT wait_type,
	waiting_tasks_count AS waiting_tasks_count_HeatMap,
	max_wait_time_ms,
	signal_wait_time_ms,
	CASE
		WHEN	wait_type = 'OLEDB' THEN 'Optimize the query on the linked server'
		WHEN	wait_type = 'ASYNC_NETWORK_IO' THEN 'Check clients submitting queries that produce large result sets'
		WHEN 	wait_type = 'CXPACKET' THEN 'Queries running in parallel and therefore expensive. Identify queries and attempt to tune'
		WHEN 	wait_type = 'PREEMPTIVE_OS_WRITEFILEGATHER' THEN 'Long Autogrow events. Try plan and manually grow data and log files'
		WHEN	wait_type = 'PREEMPTIVE_OS_AUTHENTICATIONOPS' THEN 'Problem talking to DC. Check with Infra team to fix connectivity issues'
		WHEN	wait_type = 'WRITELOG' THEN 'Poor I/O system performance writing to t-log. Try tune the log file and check with Infra team to improve IO system'
		WHEN	wait_type = 'SOS_SCHEDULER_YIELD' THEN 'High concurrency and competition for CPU time. Tune application code or request more cores'
		WHEN	wait_type = 'LCK_M_%' THEN 'Look at index tuning and isolation levels'
		WHEN	wait_type = 'PAGEIOLATCH_%' THEN 'I/O latency. Check with Infra team to investigate and improve'
		ELSE 	'Check with PROD DBA'
	END AS [Action Required]
FROM    sys.dm_os_wait_stats



WHERE    
    (
        wait_type  IN     ('PREEMPTIVE_OS_WRITEFILEGATHER',
            'PREEMPTIVE_OS_AUTHENTICATIONPS',
            'ASYNC_NETWORK_IO',
            'CXPACKET',
            'OLEDB',
            'SOS_SCHEDULER_YIELD',
            'WRITELOG')
    OR    wait_type  LIKE 'LCK_M_%'
    OR    wait_type  LIKE 'PAGEIOLATCH_%'
    )
AND    wait_time_ms  <> 0

ORDER BY    wait_time_ms DESC