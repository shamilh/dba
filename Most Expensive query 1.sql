-- Most Expensive query

	SELECT TOP 10 
		SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
		((CASE qs.statement_end_offset
			WHEN -1 THEN DATALENGTH(qt.TEXT)
				ELSE qs.statement_end_offset
					END - qs.statement_start_offset)/2)+1) ,
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
				
	where 
		Convert(varchar(10), qs.last_execution_time , 120) = '2014-11-27'   -- For the Specific date if you have a time when this query executed 
		
	  --and Convert(varchar(10), qs.last_execution_time , 108) between '11:57:11' and '12:57:11' -- for the specific time around i.e between 4:00 pm pm to 5:00 pm  
		
		--  qs.last_execution_time Between '2014-11-27 09:44:24.817' and '2014-11-27 09:44:32.190'  -- For  sql datetime format between which time query was executed.
					
	ORDER BY	qs.total_logical_reads DESC -- logical reads
				--ORDER BY qs.total_logical_writes DESC -- logical writes
				-- ORDER BY qs.total_worker_time DESC -- CPU time





