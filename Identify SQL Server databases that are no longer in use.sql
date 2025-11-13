EXECUTE sp_MSforeachdb '
USE ? ;
SELECT   DB_NAME(),
         MIN([d].[Begin Time]) AS [Begin Time],
         [d].[Transaction Name]
FROM     ::fn_dblog (NULL, NULL) AS [d]
WHERE    [d].[Begin Time] IS NOT NULL
GROUP BY [d].[Transaction Name]

--UNION ALL

--SELECT   DB_NAME(),
--         NULL,
--         NULL
ORDER BY [Begin Time] DESC;'