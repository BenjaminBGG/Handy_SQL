-------------------------------------------------------------------------------
--Script to query instance level setting information.
-------------------------------------------------------------------------------

SELECT SERVERPROPERTY('MachineName') AS [ComputerName],
	SERVERPROPERTY('ServerName') AS [InstanceName],
	SERVERPROPERTY('Edition') AS [Edition],
	SERVERPROPERTY('ProductVersion') AS [ProductVersion],
	SERVERPROPERTY('ProductLevel') AS [ProductLevel],
	SERVERPROPERTY('IsClustered') AS [IsClustered],
	SUBSTRING(@@VERSION, 1, CHARINDEX(CHAR(10), @@VERSION)-1) AS [Version],
	SERVERPROPERTY('Collation') AS [Collation],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'recovery interval (min)') AS [RecoveryInterval],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'fill factor (%)') AS [FillFactor],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'remote access') AS [RemoteAccess],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'remote proc trans') AS [RemoteProcTrans],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'remote login timeout (s)') AS [RemoteLoginTimeout],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'remote query timeout (s)') AS [RemoteQueryTimeout],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'cost threshold for parallelism') AS [CostThresholdForParallelism],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'max degree of parallelism') AS [MaxDegreeOfParallelism],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'min server memory (MB)') AS [MinServerMemory],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'max server memory (MB)') AS [MaxServerMemory],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'blocked process threshold (s)') AS [BlockedProcessThreshold],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'backup compression default') AS [BackupCompressionDefault],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'Agent XPs') AS [AgentXP],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'Database Mail XPs') AS [DatabaseMailXP],
	(SELECT c.value_in_use FROM sys.configurations c WHERE c.name = 'xp_cmdshell') AS [XPCmdShell]