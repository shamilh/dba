/*
Get SQL Server Agent Jobs List with Schedule in SQL Server
In this post we will get the list of SQL Server Agent Jobs with schedules. We will be using system tables from MSDB database.

Sys.SysJobs
Sys.SysSchedules
Sys.SysJobSchedules
The below script can be used to get the list of SQL Server Agent Jobs with schedules.
*/
USE msdb
GO 
SELECT Job.name        AS JobName,
       CASE
         WHEN Job.enabled = 1 THEN 'Enable'
         ELSE 'Disable'
       END             AS JobStatus,
       JOB.description AS Job_Description,
       SCH.name        AS ScheduleName,
       CASE
         WHEN SCH.enabled = 1 THEN 'Enable'
         WHEN SCH.enabled = 0 THEN 'Disable'
         ELSE 'Not Schedule'
       END             AS ScheduleStatus,
       SCH.active_start_date,
       SCH.active_end_date,
       SCH.active_start_time,
       SCH.active_end_time
 FROM   dbo.sysjobs JOB
      LEFT JOIN dbo.sysjobschedules JS
               ON Job.job_id = JS.job_id
       LEFT JOIN dbo.sysschedules SCH
               ON JS.schedule_id = SCH.schedule_id