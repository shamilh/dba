
 SELECT sqlserver_start_time FROM sys.dm_os_sys_info;  

SELECT login_time FROM sys.dm_exec_sessions WHERE session_id = 1;  

select start_time from sys.traces where is_default = 1  
 
SELECT crdate FROM sysdatabases WHERE name='tempdb'  
 
SELECT create_date FROM sys.databases WHERE name = 'tempdb' 

/************************************************************************************/

SET NOCOUNT ON
DECLARE @crdate DATETIME,
@days varchar(3),
@hr VARCHAR(50),
@min VARCHAR(5),
@today DATETIME

SET @today = GETDATE()

SELECT @crdate=crdate FROM sysdatabases WHERE NAME='tempdb'

SET @min = DATEDIFF (mi,@crdate,@today)
SET @days= @min/1440
SET @hr = (@min/60) - (@days * 24)
SET @min= @min - ( (@hr + (@days*24)) * 60)

PRINT 'SQL Server "' + CONVERT(VARCHAR(20),SERVERPROPERTY('SERVERNAME'))+'" is Online for the past '
+@days + ' days & '
+@hr+' hours & '
+@min+' minutes'
IF NOT EXISTS (SELECT 1 FROM master.sys.sysprocesses WHERE program_name = N'SQLAgent - Generic Refresher')
BEGIN
PRINT 'SQL Server is running but SQL Server Agent running'
END
ELSE
BEGIN
PRINT 'SQL Server and SQL Server Agent both are running'
END

/**************************************************************************************************/
WITH ServerUpTimeInfo AS (

   SELECT (dm_io_virtual_file_stats.sample_ms / 1e3 ) 

      AS server_up_time_sec,

      (dm_io_virtual_file_stats.sample_ms / 1000.00 ) / 60.00

      AS server_up_time_min,

     ((dm_io_virtual_file_stats.sample_ms / 1000.00 ) / 60.00) / 60.00

      AS server_up_time_hr,

     (((dm_io_virtual_file_stats.sample_ms / 1000.00 ) / 60.00) / 60.00) / 24.00

      AS server_up_time_day

   FROM sys.dm_io_virtual_file_stats(1,1) AS dm_io_virtual_file_stats )

 SELECT CAST(server_up_time_min AS decimal(12,2)) AS server_up_time_min,

   CAST(server_up_time_hr AS decimal(12,2)) AS server_up_time_hr,

   CAST(server_up_time_day AS decimal(12,2)) AS server_up_time_day,

   CAST(DATEADD(second,-server_up_time_sec,GETUTCDATE()) AS smalldatetime)

      AS approx_server_start_utc_datetime,

   CAST(DATEADD(second,-server_up_time_sec,GETDATE()) AS smalldatetime)

      AS approx_server_start_localtime

 FROM ServerUpTimeInfo;

 GO

/***********************************************************************************************/
WITH ServerUpTimeInfo AS (
   SELECT (dm_io_virtual_file_stats.sample_ms / 1000.00 ) / 60.00
      AS server_up_time_min,
     ((dm_io_virtual_file_stats.sample_ms / 1000.00 ) / 60.00) / 60.00
      AS server_up_time_hr,
     (((dm_io_virtual_file_stats.sample_ms / 1000.00 ) / 60.00) / 60.00) / 24.00
      AS server_up_time_day
   FROM sys.dm_io_virtual_file_stats(1,1) AS dm_io_virtual_file_stats )
 SELECT CAST(server_up_time_min AS decimal(12,2)) AS server_up_time_min,
   CAST(server_up_time_hr AS decimal(12,2)) AS server_up_time_hr,
   CAST(server_up_time_day AS decimal(12,2)) AS server_up_time_day,
   CAST(DATEADD(n,
     -ROUND(server_up_time_min, -1),
     DATEADD(hh, -ROUND(server_up_time_hr, -1), DATEADD(d, -ROUND(server_up_time_day, -1), GETUTCDATE()))
     ) AS smalldatetime)
      AS approx_server_start_utc_datetime
 FROM ServerUpTimeInfo;
 GO
/********************************************************************************************************/
SET NOCOUNT ON
DECLARE @crdate DATETIME, @hr VARCHAR(50), @min VARCHAR(5)
SELECT @crdate=create_date FROM sys.databases WHERE NAME='tempdb'
SELECT @hr=(DATEDIFF ( mi, @crdate,GETDATE()))/60
IF ((DATEDIFF ( mi, @crdate,GETDATE()))/60)=0
SELECT @min=(DATEDIFF ( mi, @crdate,GETDATE()))
ELSE
SELECT @min=(DATEDIFF ( mi, @crdate,GETDATE()))-((DATEDIFF( mi, @crdate,GETDATE()))/60)*60
PRINT 'SQL Server "' + CONVERT(VARCHAR(20),SERVERPROPERTY('SERVERNAME'))+'" is Online for the past '+@hr+' hours & '+@min+' minutes'
IF NOT EXISTS (SELECT 1 FROM master.dbo.sysprocesses WHERE program_name = N'SQLAgent - Generic Refresher')
BEGIN
PRINT 'SQL Server is running but SQL Server Agent <<NOT>> running'
END
ELSE BEGIN
PRINT 'SQL Server and SQL Server Agent both are running'
END

/*******************************************************************************/
USE

master;

SET

NOCOUNT ON

DECLARE

@crdate DATETIME, @hr VARCHAR(50), @min VARCHAR(5)

SELECT

@crdate=crdate FROM sysdatabases WHERE NAME='tempdb'

SELECT

@hr=(DATEDIFF ( mi, @crdate,GETDATE()))/60

IF

((DATEDIFF ( mi, @crdate,GETDATE()))/60)=0

SELECT

@min=(DATEDIFF ( mi, @crdate,GETDATE()))

ELSE

SELECT

@min=(DATEDIFF ( mi, @crdate,GETDATE()))-((DATEDIFF( mi, @crdate,GETDATE()))/60)*60

PRINT

'SQL Server "' + CONVERT(VARCHAR(20),SERVERPROPERTY('SERVERNAME'))+'" is Online for the past '+@hr+' hours & '+@min+' minutes'

IF

NOT EXISTS (SELECT 1 FROM master.dbo.sysprocesses WHERE program_name = N'SQLAgent - Generic Refresher')

BEGIN

PRINT

'SQL Server is running but SQL Server Agent <<NOT>> running'

END

ELSE

BEGIN

PRINT

'SQL Server and SQL Server Agent both are running'

END
/******************************************************************************************************************************/
SET NOCOUNT ON
DECLARE @crdate DATETIME, @hr VARCHAR(50), @min VARCHAR(5)
SELECT @crdate=crdate FROM sysdatabases WHERE NAME='tempdb'
SELECT @hr=(DATEDIFF ( mi, @crdate,GETDATE()))/60
IF ((DATEDIFF ( mi, @crdate,GETDATE()))/60)=0
SELECT @min=(DATEDIFF ( mi, @crdate,GETDATE()))
ELSE
SELECT @min=(DATEDIFF ( mi, @crdate,GETDATE()))-((DATEDIFF( mi, @crdate,GETDATE()))/60)*60
PRINT 'SQL Server "' + CONVERT(VARCHAR(20),SERVERPROPERTY('SERVERNAME'))+'" is Online for the past '+@hr+' hours & '+@min+' minutes'
IF NOT EXISTS (SELECT 1 FROM master.dbo.sysprocesses WHERE program_name = N'SQLAgent - Generic Refresher')
BEGIN
PRINT 'SQL Server is running but SQL Server Agent <<NOT>> running'
END
ELSE BEGIN
PRINT 'SQL Server and SQL Server Agent both are running'
END

 