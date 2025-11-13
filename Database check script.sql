SELECT name AS [SuspectDB],
  DATABASEPROPERTY(name, N'IsSuspect') AS [Suspect],
  DATABASEPROPERTY(name, N'IsOffline') AS [Offline],
  DATABASEPROPERTY(name, N'IsEmergencyMode') AS [Emergency],
  has_dbaccess(name) AS [HasDBAccess]
FROM sysdatabases
WHERE (DATABASEPROPERTY(name, N'IsSuspect') = 1)
   OR (DATABASEPROPERTY(name, N'IsOffline') = 1)
   OR (DATABASEPROPERTY(name, N'IsEmergencyMode') = 1)
   OR (has_dbaccess(name) = 0)
   