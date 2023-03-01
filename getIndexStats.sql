SELECT 
DB_NAME() AS [Database], 
obj.name AS [Table], 
obj.type AS [Object_Type], 
i.name AS [Index], 
i.type AS [Index_Type], 
stat.name AS [Statistic], 
sp.rows AS [Rows], 
sp.rows_sampled AS [Rows Sampled] 

FROM sys.objects AS obj   
INNER JOIN sys.stats AS stat ON stat.object_id = obj.object_id  
FULL OUTER JOIN sys.indexes AS i ON stat.name = i.name
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp  

WHERE 1=1
AND obj.name not like 'sys%' --and obj.name like 'tbl5'
AND sp.rows <> sp.rows_sampled