 select CONNECTIONPROPERTY ('local_net_address') AS 'Ip Adress'
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
     ELSE 'unknown'
  END AS Edition, SERVERPROPERTY('ProductLevel') AS SP,SERVERPROPERTY('ProductUpdateLevel') AS CU , SERVERPROPERTY('ProductUpdateReference')AS KB,SERVERPROPERTY('ProductBuildType') AS GDR