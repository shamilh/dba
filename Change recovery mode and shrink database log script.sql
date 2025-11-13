
/************************************************************************************************/

--If tempdb not clearing then run the following command
DBCC FREEPROCCACHE
/************************************************************************************************/


USE MASTER
declare
   @isql varchar(2000),
   @dbname varchar(64),
   @logfile varchar(128),
   @RMS Varchar(8),
   @RMF Varchar(8)
   
   Set @RMS = 'SIMPLE'
   Set @RMF = 'FULL'
   
      declare c1 cursor for 
   SELECT  d.name, mf.name as logfile --, physical_name AS current_file_location, size
	FROM sys.master_files mf
      inner join sys.databases d
      on mf.database_id = d.database_id
   where recovery_model_desc <>  @RMS  --'SIMPLE'
   and d.name not in ('master','model','msdb','tempdb') 
   and mf.type_desc = 'LOG'   
   open c1
   fetch next from c1 into @dbname, @logfile
   While @@fetch_status <> -1
      begin
	  Print ' -- Convert Database recovery mode to SIMPLE Database '+ @dbname
      select @isql = 'ALTER DATABASE ' + @dbname + ' SET RECOVERY '+@RMS
      print @isql
      --exec(@isql)
	  Print '  -- Check Point occoured on Database '+ @dbname
      select @isql='USE ' + @dbname + ' checkpoint'
      print @isql
      --exec(@isql)
	  Print '  -- Shrink Database '+ @dbname
      select @isql='USE ' + @dbname + ' DBCC SHRINKFILE (' + @logfile + ', 1)'
      print @isql
      ----exec(@isql)
	  Print '  -- Convert Database recovery mode to FULL Database  '+ @dbname
      select @isql = 'ALTER DATABASE ' + @dbname + ' SET RECOVERY '+@RMF
      print @isql
      ----exec(@isql)

      fetch next from c1 into @dbname, @logfile
      end
   close c1
   deallocate c1
   
    /*****************************************************************************************/
   USE [tempdb]
GO
DBCC SHRINKDATABASE(N'tempdb' )
GO


USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev' , 0, TRUNCATEONLY)
GO


USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev2' , 0, TRUNCATEONLY)
GO


USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev3' , 0, TRUNCATEONLY)
GO

USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev4' , 0, TRUNCATEONLY)
GO
   
   /*****************************************************************************************/
   
--Shrinking tempdb without restarting SQL Server  

--DBCC DROPCLEANBUFFERS
--Clears the clean buffers. This will flush cached indexes and data pages. You may want to run a CHECKPOINT command first, in order to flush everything to disk.
	CHECKPOINT;
	GO
	DBCC DROPCLEANBUFFERS;
	GO

--DBCC FREEPROCCACHE
--Clears the procedure cache, which may free up some space in tempdb, although at the expense of your cached execution plans, which will need to be rebuilt the next time. This means that ad-hoc queries and stored procedures will have to recompile the next time you run them. Although this happens automatically, you may notice a significant performance decrease the first few times you run your procedures.

DBCC FREEPROCCACHE;
GO

--DBCC FREESYSTEMCACHE
--This operation is similar to FREEPROCCACHE, except it affects other types of caches.


DBCC FREESYSTEMCACHE ('ALL');
GO

--DBCC FREESESSIONCACHE
--Flushes the distributed query connection cache. This has to do with distributed queries (queries between servers), but I’m really not sure how much space they actually take up in tempdb.

DBCC FREESESSIONCACHE;
GO
--.. and finally, DBCC SHRINKFILE
--DBCC SHRINKFILE is the same tool used to shrink any database file, in tempdb or other databases. This is the step that actually frees the unallocated space from the database file.

--Warning: Make sure you don’t have any open transactions when running DBCC SHRINKFILE. Open transactions may cause the DBCC operation to fail, and possibly corrupt your tempdb!

DBCC SHRINKFILE (TEMPDEV, 20480);   --- New file size in MB
GO


/*****************************************************************************************/
   




  
 --  shrink temp db logfile
   
   Use [Tempdb]
GO
SELECT name AS 'File Name' , physical_name AS 'Physical Name', size/128 AS 'Total Size in MB', 
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS 'Available Space In MB', * FROM sys.database_files;


select * from sys.dm_db_file_space_usage

USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev' , 1024)
GO 

USE [tempdb]
GO
DBCC SHRINKDATABASE (N'tempdb')
GO 

USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev' , 0, TRUNCATEONLY)
GO 


/************************************************************************************************************/

select 
    database_id, 
    file_id, 
    io_stall,
    io_pending_ms_ticks,
    scheduler_address 
from   sys.dm_io_virtual_file_stats(NULL, NULL)t1,
        sys.dm_io_pending_io_requests as t2
where   t1.file_handle = t2.io_handle


/***************************************************************************************************************/

--select * from tempdb.sys.all_objects
--where is_ms_shipped = 0;



USE [tempdb]
SELECT
   [name]
   ,CONVERT(NUMERIC(10,2),ROUND([size]/128.,2))                                 AS [Size]
   ,CONVERT(NUMERIC(10,2),ROUND(FILEPROPERTY([name],'SpaceUsed')/128.,2))            AS [Used]
   ,CONVERT(NUMERIC(10,2),ROUND(([size]-FILEPROPERTY([name],'SpaceUsed'))/128.,2))      AS [Unused]
FROM [sys].[database_files]




/****************************************************************************************************************************/


select * from sys.dm_db_file_space_usage

USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev' , 1024)
GO 

USE [tempdb]
GO
DBCC SHRINKDATABASE (N'tempdb')
GO 

USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev' , 0, TRUNCATEONLY)
GO	
/*********************************************************************************************************************************/


DBCC SHRINKFILE (N’tempdev’, NOTRUNCATE) -- Move allocated pages from end of file to top of file
DBCC SHRINKFILE (N’tempdev’ , 0, TRUNCATEONLY) -- Drop unallocated pages from end of file

/*********************************************************************************************************************************/

--Would this really be necessary ? FREEPROCCACHE will reset all execution plans. This command clears the cache for the entire SQL instance, all databases. To clear for just one database, use the following:

DECLARE @intDBID INTEGER SET @intDBID = (SELECT dbid FROM master. dbo.sysdatabases WHERE name = 'TempDB' )
--Flush stored procedure/plan cache for the specific database
DBCC FLUSHPROCINDB (@intDBID )

/*********************************************************************************************************************************/


-- Report existing file sizes
use tempdb
GO
SELECT name, size
FROM sys.master_files
WHERE database_id = DB_ID(N’tempdb’);
GO
DBCC FREEPROCCACHE — clean cache
DBCC DROPCLEANBUFFERS — clean buffers
DBCC FREESYSTEMCACHE ('ALL') — clean system cache
DBCC FREESESSIONCACHE — clean session cache
DBCC SHRINKDATABASE(tempdb, 10); — shrink tempdb
dbcc shrinkfile ('tempdev') — shrink default db file
dbcc shrinkfile ('tempdev2') — shrink db file tempdev2
dbcc shrinkfile ('tempdev3') — shrink db file tempdev3
dbcc shrinkfile ('tempdev4') — shrink db file tempdev4
dbcc shrinkfile ('templog') — shrink log file
GO

-- report the new file sizes
SELECT name, size
FROM sys.master_files
WHERE database_id = DB_ID(N’tempdb’);
GO


/*********************************************************************************************************************************/

DBCC SHRINKFILE (N’tempdev’ , EMPTYFILE)

/*********************************************************************************************************************************/
-- I like the approach Marcy posted. I myself like to dig into the procedure cache individually for the production env; Usually it’s some rogue developer causing havoc. However, I have seen some procs kill tempdb quickly like this one… just to return analysis info…

SELECT TOP 50 SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END – qs.statement_start_offset)/2)+1),
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
ORDER BY qs.total_logical_reads DESC — logical reads
— ORDER BY qs.total_logical_writes DESC — logical writes
— ORDER BY qs.total_worker_time DESC — CPU time

/*********************************************************************************************************************************/


/*********************************************************************************************************************************/


/*********************************************************************************************************************************/


/*********************************************************************************************************************************/


/*********************************************************************************************************************************/


/*********************************************************************************************************************************/


/*********************************************************************************************************************************/


/*********************************************************************************************************************************/


