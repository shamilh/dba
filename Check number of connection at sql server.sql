SELECT DB_NAME(dbid) AS DBName,
       COUNT(dbid)   AS NumberOfConnections,
       loginame      AS LoginName,
       nt_domain     AS NT_Domain,
       nt_username   AS NT_UserName,
       hostname      AS HostName
FROM   sys.sysprocesses
WHERE  dbid > 0
GROUP  BY dbid,
          hostname,
          loginame,
          nt_domain,
          nt_username
ORDER  BY NumberOfConnections DESC;


select 
--DB_NAME(dbid),
* from sys.dm_exec_connections 



RHA8-GM75-WH76-B108

671E-4LFP-R449-C4WI-RNWH-W2R0-3VS2-04TP