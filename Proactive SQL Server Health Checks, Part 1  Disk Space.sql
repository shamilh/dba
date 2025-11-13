--USE [Baselines];
--GO
 
IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'SQLskills_TrackLogSpace'))
 
BEGIN
	CREATE TABLE [dbo].[##SQLskills_TrackLogSpace](
		[DatabaseName] [VARCHAR](250) NULL,
		[LogSizeMB] [DECIMAL](38, 0) NULL,
		[LogSpaceUsed] [DECIMAL](38, 0) NULL,
		[LogStatus] [TINYINT] NULL,
		[CaptureDate] [DATETIME2](7) NULL
	) ON [PRIMARY];
 
	ALTER TABLE [dbo].[##SQLskills_TrackLogSpace] ADD  DEFAULT (SYSDATETIME()) FOR [CaptureDate];
 
END
 
CREATE TABLE #LogSpace_Temp (
	DatabaseName VARCHAR(100),
	LogSizeMB DECIMAL(10,2),
	LogSpaceUsed DECIMAL(10,2),
	LogStatus VARCHAR(1)
	);
 
INSERT INTO #LogSpace_Temp EXEC('dbcc sqlperf(logspace)');
 
INSERT INTO ##SQLskills_TrackLogSpace 
	(DatabaseName, LogSizeMB, LogSpaceUsed, LogStatus)
	SELECT DatabaseName, LogSizeMB, LogSpaceUsed, LogStatus
	FROM #LogSpace_Temp;


 select * from ##SQLskills_TrackLogSpace 

 SELECT MIN(FreeSpace*100.0/Size)
  FROM SQLSentry.dbo.PerformanceAnalysisDeviceLogicalDisk;

DROP TABLE #LogSpace_Temp;
Drop table ##SQLskills_TrackLogSpace 
 /********************************************************************************************************************************/
 
 SELECT *
    --[file_id] AS [File ID],
    --[type] AS [File Type],
    --substring([physical_name],1,1) AS [Drive],
    --[name] AS [Logical Name],
    --[physical_name] AS [Physical Name],
    --CAST([size] as DECIMAL(38,0))/128. AS [File Size MB], 
    --CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128. AS [Space Used MB], 
    --(CAST([size] AS DECIMAL(38,0))/128) - (CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128.) AS [Free Space],
    --[max_size] AS [Max Size],
    --[is_percent_growth] AS [Percent Growth Enabled],
    --[growth] AS [Growth Rate],
    --SYSDATETIME() AS [Current Date]
FROM sys.database_files;
 /************************************************************************************************************/

 SELECT DISTINCT
  vs.volume_mount_point AS [Drive],
  vs.logical_volume_name AS [Drive Name],
  vs.total_bytes/1024/1024/1024 AS [Drive Size GB],
  vs.available_bytes/1024/1024/1024 AS [Drive Free Space GB]
FROM sys.master_files AS f
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
ORDER BY vs.volume_mount_point;
 
 /************************************************************************************************/

 SELECT Alert = MAX(CASE 
  WHEN Name = N'C:' AND [FreeSpace%] < 10 THEN 1
  WHEN Name = N'S:' AND [FreeSpace%] < 25 THEN 1
  WHEN Name = N'T:' AND [FreeSpace%] < 20 THEN 1
  ELSE 0 END)
FROM 
(
  SELECT 
	d.Name, 
	d.FreeSpace * 100.0/d.Size AS [FreeSpace%]
  FROM SQLSentry.dbo.PerformanceAnalysisDeviceLogicalDisk AS d
  INNER JOIN SQLSentry.dbo.EventSourceConnection AS c
  ON d.DeviceID = c.DeviceID
  WHERE c.ObjectName = N'HANK\SQL2012' -- replace with your server/instance
) AS s;