
exec master.dbo.xp_servicecontrol 'QUERYSTATE', 'MSSQLServer'
exec master.dbo.xp_servicecontrol 'QUERYSTATE', 'SQLServerAgent'
exec master.dbo.xp_servicecontrol 'QUERYSTATE', 'SQLBrowser'

      Declare @MinSpc         Int

    Set @MinSpc = 0

Create Table ##ChkSpc
(
      
	  Drv         Char(1),
      DrvSpace    Int
)

Insert Into ##ChkSpc Exec master.dbo.xp_fixeddrives

-- Convert MB into GB
Update      ##ChkSpc
Set   DrvSpace = DrvSpace / 1024 
--Select  @@Servername
    Select 
            @@servername
          , Drv As Drive
          , DrvSpace As [Space Left In GB] 
    From ##ChkSpc 
     Where --Drv != 'C'
     DrvSpace > @MinSpc 
Drop Table ##ChkSpc

SELECT (available_physical_memory_kb/1024)/1024 as "Total Memory GB",
       available_physical_memory_kb/(total_physical_memory_kb*1.0)*100 AS "% Memory Free"
FROM sys.dm_os_sys_memory

declare @Time_Start datetime;
declare @Time_End datetime;
set @Time_Start=getdate()-2;
set @Time_End=getdate();
-- Create the temporary table
CREATE TABLE #ErrorLog (logdate datetime
                      , processinfo varchar(255)
                      , Message varchar(500))
-- Populate the temporary table
INSERT #ErrorLog (logdate, processinfo, Message)
   EXEC master.dbo.xp_readerrorlog 0, 1, null, null , @Time_Start, @Time_End, N'desc';
-- Filter the temporary table
SELECT LogDate, Message FROM #ErrorLog
WHERE (Message LIKE '%error%' OR Message LIKE '%failed%') AND processinfo NOT LIKE 'logon'
ORDER BY logdate DESC
-- Drop the temporary table 
DROP TABLE #ErrorLog

use msdb
go
select 'FAILED' as Status, cast(sj.name as varchar(100)) as "Job Name",
       cast(sjs.step_id as varchar(5)) as "Step ID",
       cast(sjs.step_name as varchar(30)) as "Step Name",
       cast(REPLACE(CONVERT(varchar,convert(datetime,convert(varchar,sjh.run_date)),102),'.','-')+' '+SUBSTRING(RIGHT('000000'+CONVERT(varchar,sjh.run_time),6),1,2)+':'+SUBSTRING(RIGHT('000000'+CONVERT(varchar,sjh.run_time),6),3,2)+':'+SUBSTRING(RIGHT('000000'+CONVERT(varchar,sjh.run_time),6),5,2) as varchar(30)) 'Start Date Time',
       sjh.message as "Message"
from sysjobs sj
join sysjobsteps sjs 
 on sj.job_id = sjs.job_id
join sysjobhistory sjh 
 on sj.job_id = sjh.job_id and sjs.step_id = sjh.step_id
where sjh.run_status <> 1
  and cast(sjh.run_date as float)*1000000+sjh.run_time > 
      cast(convert(varchar(8), getdate()-1, 112) as float)*1000000+70000 --yesterday at 7am
union
select 'FAILED',cast(sj.name as varchar(100)) as "Job Name",
       'MAIN' as "Step ID",
       'MAIN' as "Step Name",
       cast(REPLACE(CONVERT(varchar,convert(datetime,convert(varchar,sjh.run_date)),102),'.','-')+' '+SUBSTRING(RIGHT('000000'+CONVERT(varchar,sjh.run_time),6),1,2)+':'+SUBSTRING(RIGHT('000000'+CONVERT(varchar,sjh.run_time),6),3,2)+':'+SUBSTRING(RIGHT('000000'+CONVERT(varchar,sjh.run_time),6),5,2) as varchar(30)) 'Start Date Time',
       sjh.message as "Message"
from sysjobs sj
join sysjobhistory sjh 
 on sj.job_id = sjh.job_id
where sjh.run_status <> 1 and sjh.step_id=0
  and cast(sjh.run_date as float)*1000000+sjh.run_time >
      cast(convert(varchar(8), getdate()-1, 112) as float)*1000000+70000 --yesterday at 7am


	  SELECT top 10 text as "SQL Statement",
   last_execution_time as "Last Execution Time",
   (total_logical_reads+total_physical_reads+total_logical_writes)/execution_count as [Average IO],
   (total_worker_time/execution_count)/1000000.0 as [Average CPU Time (sec)],
   (total_elapsed_time/execution_count)/1000000.0 as [Average Elapsed Time (sec)],
   execution_count as "Execution Count",
   qp.query_plan as "Query Plan"
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
order by total_elapsed_time/execution_count desc



-- Get CPU Utilization History for last 30 minutes (SQL 2008)
DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks)FROM sys.dm_os_sys_info); 

SELECT TOP(30) SQLProcessUtilization AS [SQL Server Process CPU Utilization], 
               SystemIdle AS [System Idle Process], 
               100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization], 
               DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time] 
FROM ( 
	  SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
			AS [SystemIdle], 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
			'int') 
			AS [SQLProcessUtilization], [timestamp] 
	  FROM ( 
			SELECT [timestamp], CONVERT(xml, record) AS [record] 
			FROM sys.dm_os_ring_buffers 
			WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
			AND record LIKE '%<SystemHealth>%') AS x 
	  ) AS y 
ORDER BY record_id DESC;