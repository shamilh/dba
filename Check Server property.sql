--select @@version
SELECT 
        (CONVERT(varchar(max),SERVERPROPERTY('MachineName'))) AS  [Server Name],
        (CONVERT(varchar(max),SERVERPROPERTY('InstanceName'))) AS Instance, 
      r.Name AS EmployeeName , 
            Case r.is_disabled 
              WHEN '1' THEN 'Disable'
              WHEN '0' THEN 'Enable'
            Else 'User not found' end AS [Login Status],
        GetDate() AS [Checked Date]
FROM sys.server_principals r
   WHERE r.Name  --= 'sa'
              --  Like '%sa%' 
              in ('5912087','5902079','6112053','6109000')