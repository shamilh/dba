--Missing Index
SELECT 
    DatabaseName = DB_NAME(database_id)
	,'Create Non-Clustered Index Enter_IndexName ON ' + DB_NAME(database_id) COLLATE DATABASE_DEFAULT + 
		  ' ( ' + IsNull(equality_columns, '') + 
					  CASE WHEN inequality_columns IS NULL THEN ''
							 ELSE 
								  CASE WHEN equality_columns IS NULL THEN ''
								  ELSE ','
								  END + inequality_columns 
					  END + 
		  ' ) ' + 
		CASE WHEN included_columns IS NULL THEN ''
				 ELSE 'INCLUDE (' + included_columns + ')' 
		  END + ';' AS CreateIndexStatement
	,equality_columns
	,inequality_columns
	,included_columns 
FROM sys.dm_db_missing_index_details
where DB_NAME(database_id) not in ('Master', 'msdb','model','distribution')
ORDER BY 1 DESC;



==================================================================================================================================================

SELECT TOP 10 db_name(qt.dbid),
SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1),
qs.execution_count,
qs.total_logical_reads, qs.last_logical_reads,
qs.total_logical_writes, qs.last_logical_writes,
qs.total_worker_time,
qs.last_worker_time,
qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
qs.last_execution_time,
qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
Where DB_NAME(qt.dbid) not in ('Master', 'msdb','model','distribution')
ORDER BY qs.total_worker_time DESC -- CPU time
-- ORDER BY qs.total_logical_reads DESC -- logical reads
-- ORDER BY qs.total_logical_writes DESC -- logical writes
