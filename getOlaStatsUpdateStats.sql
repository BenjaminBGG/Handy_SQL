-- Requires Ola Hallengren DB Maintenance with commandlog table

Select  CONVERT(DATE,starttime) [Run], 
CONVERT(TIME,MAX(endtime)-MIN(starttime)) [ElapsedTime],
MIN(starttime) [Start],
MAX(endtime) [End],
COUNT(1) [TOTAL], 
SUM(CASE WHEN commandtype = 'UPDATE_STATISTICS' THEN 1 END) [TOTALStats],
SUM(CASE WHEN commandtype = 'UPDATE_STATISTICS' AND indexname IS NOT NULL THEN 1 END) [StatsOnIndexes],
SUM(CASE WHEN commandtype = 'UPDATE_STATISTICS' AND indexname IS NULL THEN 1 END) [StatsOnColumns],
SUM(CASE WHEN commandtype = 'ALTER_INDEX' THEN 1 END) [TOTALIndexes],
SUM(CASE WHEN commandtype = 'ALTER_INDEX' AND command LIKE '%REBUILD%' THEN 1 END) [IndexRebuild],
SUM(CASE WHEN commandtype = 'ALTER_INDEX' AND command LIKE '%REORGANIZE%' THEN 1 END) [IndexReorg]
FROM commandlog 
GROUP BY CONVERT(DATE,starttime)