--Long Running Queries 

SELECT top 10
	 convert(Varchar(20), Creation_time , 101) CreationDate
	,convert(Varchar(20), Creation_time , 114) CreationTime
	,convert(Varchar(20), last_execution_time , 101) last_execution_Date 
	,convert(Varchar(20), last_execution_time , 114) last_execution_time
	,qs.total_elapsed_time / qs.execution_count / 1000000.0 AS average_seconds
    ,qs.total_elapsed_time / 1000000.0  AS total_seconds
	,(total_logical_reads + total_logical_writes) / qs.execution_count AS average_IO
	,(total_logical_reads + total_logical_writes) AS total_IO
	,qs.execution_count,
    SUBSTRING (qt.text,qs.statement_start_offset/2, 
         (CASE WHEN qs.statement_end_offset = -1 
            THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
          ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) AS individual_query,
        DB_NAME(qt.dbid) AS database_name
FROM sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
 where DB_NAME(qt.dbid) not in ('Master', 'msdb','model','distribution')
--and (qs.total_elapsed_time / 1000000.0) > 30
  ORDER BY average_seconds DESC;
/**********************************************************************************************************-*/
  SELECT DISTINCT TOP 10
t.TEXT QueryName,
s.execution_count AS ExecutionCount,
s.max_elapsed_time AS MaxElapsedTime,
ISNULL(s.total_elapsed_time / s.execution_count, 0) AS AvgElapsedTime,
s.creation_time AS LogCreatedOn,
ISNULL(s.execution_count / DATEDIFF(s, s.creation_time, GETDATE()), 0) AS FrequencyPerSec
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_sql_text( s.sql_handle ) t
 where DB_NAME(t.dbid) not in ('Master', 'msdb','model','distribution')
ORDER BY
s.max_elapsed_time DESC
GO 