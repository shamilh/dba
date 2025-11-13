USE master;
GO
DECLARE @Ver VARCHAR(MAX), @Ver1 VARCHAR(MAX), @Ver2 INT, @Ver3 INT, @Ver4 INT, @VersionOS VARCHAR(MAX)
CREATE TABLE #tmpOSInfo(t_index NVARCHAR(100), t_name NVARCHAR(100), t_internalV NVARCHAR(100), t_characterV NVARCHAR(100) );
--Select * from #tmpOSInfo
INSERT INTO #tmpOSInfo EXEC xp_msver 'WindowsVersion';
--SELECT t_characterV FROM #tmpOSInfo;
SELECT @Ver = t_characterV FROM #tmpOSInfo;
SET @Ver1 = '('
SET @Ver2 = LEN(@Ver1)
SELECT @Ver3 = CHARINDEX(@Ver1,@Ver)
SET @Ver1 = ')'
SET @Ver2 = LEN(@Ver1)
SELECT @Ver4 = CHARINDEX(@Ver1,@Ver)
SELECT @VersionOS = SUBSTRING(@Ver,@Ver3+1,@Ver4-@Ver3-1);
SELECT CONNECTIONPROPERTY ('local_net_address') AS 'Ip Adress'
   ,CONNECTIONPROPERTY ('local_tcp_port') AS Port
   ,SERVERPROPERTY('ComputerNamePhysicalNetBIOS')AS 'Machine Name'
   ,@@servicename AS 'Instance Name', CASE 
       WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '8%' THEN 'SQL 2000'
       WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '9%' THEN 'SQL 2005'
       WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.0%' THEN 'SQL 2008'
       WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.5%' THEN 'SQL 2008 R2'
       WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '11%' THEN 'SQL 2012'
       WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '12%' THEN 'SQL 2014'
       WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '13%' THEN 'SQL 2016'     
       WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '14%' THEN 'SQL 2017' 
       WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '15%' THEN 'SQL 2019' 
       ELSE 'unknown'
    END AS Version, 
    SERVERPROPERTY('ProductLevel') AS SP,
    SERVERPROPERTY('ProductUpdateLevel') AS CU ,  
    SERVERPROPERTY('ProductUpdateReference')AS KB,
    --SERVERPROPERTY('ProductBuildType') AS GDR,
    SERVERPROPERTY('Edition') AS Edition,
    SERVERPROPERTY('ProductVersion') AS ProductVersion,
(SELECT 
		CASE
			WHEN @VersionOS = 17763 THEN 'Windows Server 2019'
			WHEN @VersionOS = 14393 THEN 'Windows Server 2016'
			WHEN @VersionOS = 9600 THEN 'Windows Server 2012 R2'
			WHEN @VersionOS = 9200 THEN 'Windows Server 2012'
			WHEN @VersionOS = 7601 THEN 'Windows Server 2008 R2'
			WHEN @VersionOS = 6003 THEN 'Windows Server 2008'
		ELSE 'No definido – Revisar Script'
			END AS OperationSystem) AS [Windows Server]
, DEFAULT_DOMAIN()[DomainName] 

		DROP TABLE #tmpOSInfo;
