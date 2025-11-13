/*

The following code generates the same information found in sp_who2, along with some additional troubleshooting information. It also contains the SQL Statement being run, 

Unlike sp_who2, this custom query only shows sessions that have a current executing request.

What is also shown is the reads and writes for the current command, along with the number of reads and writes for the entire SPID. It also shows the protocol being used (TCP, NamedPipes, or Shared Memory).

The lead blocker below will show in the BlkBy column as -1.

*/


--USE [master]
--GO
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT
		SPID = er.session_id
		, [Login] = ses.login_name 
		, DBName = DB_Name(er.database_id) 
	--	,BlkBy = 
		,[Blocked By] =
				CASE WHEN lead_blocker = 1 
				THEN -1 
				ELSE er.blocking_session_id 
				END 
		, ExecutionPlan = pln.query_plan
		, CommandType = er.command
		,ObjectName = OBJECT_SCHEMA_NAME(qt.objectid,qt.dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
		,SQLStatement =
					SUBSTRING
					(
					qt.text,
					er.statement_start_offset/2,
				CASE WHEN
					(
						CASE WHEN er.statement_end_offset = -1
							THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
					ELSE er.statement_end_offset
				END 
			- er.statement_start_offset / 2
		) < 0 
		  THEN 0 
			ELSE 
				CASE WHEN er.statement_end_offset = -1 
				THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2 
			ELSE er.statement_end_offset 
		END
				 - er.statement_start_offset / 2 END ) 
			, STATUS = ses.STATUS 
			, [Program Name] = program_name
			, Host = ses.host_name 
			, StartTime = er.start_time 
			, Protocol = con.net_transport 
			,transaction_isolation = 
									 CASE ses.transaction_isolation_level 
										 WHEN 0 THEN 'Unspecified' 
										 WHEN 1 THEN 'Read Uncommitted' 
										 WHEN 2 THEN 'Read Committed' 
										 WHEN 3 THEN 'Repeatable' 
										 WHEN 4 THEN 'Serializable' 
										 WHEN 5 THEN 'Snapshot' 
									 END  
				, [Interface Name] = client_interface_name
				, ElapsedMS = er.total_elapsed_time
				, CPU = er.cpu_time
				, IOReads = er.logical_reads + er.reads
				, IOWrites = er.writes
				, Executions = ec.execution_count
				, LastWaitType = er.last_wait_type
				, ConnectionWrites = con.num_writes 
				, ConnectionReads = con.num_reads 
				, ClientAddress = con.client_net_address 
				, Authentication = con.auth_scheme 
				, DatetimeSnapshot = GETDATE() 
				, plan_handle = er.plan_handle 
				
				
							FROM sys.dm_exec_requests er 
						LEFT JOIN sys.dm_exec_sessions ses ON ses.session_id = er.session_id 
						LEFT JOIN sys.dm_exec_connections con ON con.session_id = ses.session_id 
						OUTER APPLY sys.dm_exec_sql_text (er.sql_handle) AS qt 
						OUTER APPLY sys.dm_exec_query_plan (er.plan_handle) pln
						OUTER APPLY ( SELECT execution_count = MAX(cp.usecounts) 
										FROM sys.dm_exec_cached_plans cp 
											WHERE cp.plan_handle = er.plan_handle ) ec 
						OUTER APPLY ( SELECT lead_blocker = 1 
										FROM master.dbo.sysprocesses sp 
											WHERE sp.spid IN ( SELECT blocked 
																	FROM master.dbo.sysprocesses WITH (NOLOCK) 
																		WHERE blocked != 0)				
						AND sp.blocked = 0 
						AND sp.spid = er.session_id ) lb 
					WHERE er.sql_handle IS NOT NULL 
						AND er.session_id != @@SPID 
				ORDER BY 
						CASE WHEN lb.lead_blocker = 1 
							THEN -1 * 1000 
							ELSE - er.blocking_session_id 
						END
				, er.blocking_session_id DESC
				, er.logical_reads + er.reads DESC
				, er.session_id; 
		END 
