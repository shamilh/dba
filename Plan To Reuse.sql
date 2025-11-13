SELECT b.[cacheobjtype], b.[objtype], b.[usecounts], a.[dbid], a.[objectid], b.[size_in_bytes], a.[text]
FROM sys.dm_exec_cached_plans as b
CROSS APPLY sys.dm_exec_sql_text (b.[plan_handle]) AS a
ORDER BY [usecounts] DESC