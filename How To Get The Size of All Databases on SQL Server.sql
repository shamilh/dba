--DBA - How To Get The Size of All Databases on SQL Server
--Here is code that can be used to get the size of Data File (MB), Log File (MB) and Total Size of Database in GB on SQL Server.

SELECT DBName,
       DataFile                        AS DataFileSizeInMB,
       LogFile                         AS LogFileInMB,
       ( DataFile + LogFile ) / 1024.0 AS DataBaseSizeInGB
FROM   (SELECT DB_NAME(Database_id) AS DBName,
               size * 8.0 / 1024    AS SizeInMB,
               CASE
                 WHEN TYPE = 0 THEN 'DataFile'
                 ELSE 'LogFile'
               END                  AS FileType
        FROM   sys.master_files) D
       PIVOT ( MAX(SizeInMB)
             FOR FileType IN (DataFile,
                              LogFile)) pvt