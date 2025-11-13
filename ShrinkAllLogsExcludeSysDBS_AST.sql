SELECT 
    'USE [' 
    + databases.name + N']' 
    + CHAR(13) 
    + CHAR(10) 
    + 'DBCC SHRINKFILE (N''' 
    + masterFiles.name 
    + N''' , 0, TRUNCATEONLY)' 
    + CHAR(13) 
    + CHAR(10) 
    + CHAR(13) 
    + CHAR(10)            
				AS sqlCommand
INTO
    #shrinkCommands
FROM 
    [sys].[master_files] masterFiles 
    INNER JOIN [sys].[databases] databases ON masterFiles.database_id = databases.database_id 
WHERE 
    databases.database_id > 4; -- Exclude system DBs


DECLARE iterationCursor CURSOR

FOR
    SELECT 
        sqlCommand 
    FROM 
        #shrinkCommands

OPEN iterationCursor

DECLARE @sqlStatement varchar(max)

FETCH NEXT FROM iterationCursor INTO @sqlStatement

WHILE (@@FETCH_STATUS = 0)
BEGIN
    EXEC(@sqlStatement)
    FETCH NEXT FROM iterationCursor INTO @sqlStatement
END

-- Clean up
CLOSE iterationCursor
DEALLOCATE iterationCursor
DROP TABLE #shrinkCommands