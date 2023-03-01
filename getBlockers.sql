WITH Blocked_Sessions AS (
-- Collect lead blockers
-- Pull all blocking IDs & check which ones are not being blocked themselves
SELECT sys.dm_exec_requests.blocking_session_id AS LeadSessionId,
sys.dm_exec_requests.blocking_session_id AS BlockingSessionId ,
0 as Count
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0
AND blocking_session_id NOT IN (SELECT session_id
FROM sys.dm_exec_requests
WHERE sys.dm_exec_requests.blocking_session_id <> 0)
UNION ALL
-- Recurse through list of blocked sessions
SELECT Blocked_Sessions.LeadSessionId,
sys.dm_exec_requests.session_id AS BlockingSessionId,
1 as Count
FROM sys.dm_exec_requests
JOIN Blocked_Sessions ON Blocked_Sessions.LeadSessionId = sys.dm_exec_requests.blocking_session_id
),
Blocked AS (
-- Add up all sessions blocked for the lead blocker
SELECT LeadSessionId,
SUM(Count) AS sessions_blocked
FROM Blocked_Sessions
GROUP BY LeadSessionId)

SELECT Blocked.*,
DATEDIFF(s, Sess.last_request_start_time, getdate()) as BlockingSec,
ISNULL(Req.status,'sleeping') as Status,
SqlText.text as Sql,
STUFF((SELECT DISTINCT ISNULL(', ' + db.name,'')
FROM sys.databases db
JOIN sys.dm_tran_locks lcks
ON db.database_id = lcks.resource_database_id
WHERE lcks.request_session_id = Sess.session_id
ORDER BY ISNULL(', ' + db.name,'')
FOR XML PATH(''),TYPE).value('.','VARCHAR(MAX)') ,1,2,'') AS DatabaseList,
Conn.client_net_address as Address,
Sess.login_name as Login
FROM sys.dm_exec_connections Conn
LEFT OUTER JOIN sys.dm_exec_sessions Sess ON Conn.session_id = Sess.session_id
JOIN Blocked ON Blocked.LeadSessionId = Sess.session_id
CROSS APPLY sys.dm_exec_sql_text(Conn.most_recent_sql_handle) SqlText
LEFT JOIN sys.dm_exec_requests Req ON Req.session_id = Sess.session_id
WHERE Blocked.sessions_blocked >= 1
-- We only care if the session has been blocked for longer than 30 seconds.
-- This can obviously be modified or commented out.
AND DATEDIFF(s, Sess.last_request_start_time, getdate()) > 3; -- 3 seconds of blocking




--EXEC sp_WhoIsActive @find_block_leaders = 1;




/*
select loginame as User,
cpu,
memusage,
physical_io,
*
from master..sysprocesses a
where exists ( select b.*
from master..sysprocesses b
where b.blocked > 0 and
b.blocked = a.spid ) and not
exists ( select b.*
from master..sysprocesses b
where b.blocked > 0 and
b.spid = a.spid )
order by spid
*/