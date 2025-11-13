SET NOCOUNT ON;
DECLARE @objectid int;
DECLARE @indexid int;
DECLARE @DBID INT;
DECLARE @partitioncount bigint;
DECLARE @schemaname nvarchar(130); 
DECLARE @objectname nvarchar(130); 
DECLARE @indexname nvarchar(130); 
DECLARE @partitionnum bigint;
DECLARE @partitions bigint;
DECLARE @frag float;
DECLARE @command nvarchar(4000); 
DECLARE @subject nvarchar(400);
DECLARE @body nvarchar(2000);
DECLARE @profile_name nvarchar(20);
DECLARE @name nvarchar(20);

-- Conditionally select tables and indexes from the sys.dm_db_index_physical_stats function 
-- and convert object and index IDs to names.
SET @DBID = DB_ID();
SELECT
    object_id AS objectid,
    index_id AS indexid,
    partition_number AS partitionnum,
    avg_fragmentation_in_percent AS frag
INTO #work_to_do
FROM sys.dm_db_index_physical_stats (@DBID, NULL, NULL , NULL, 'LIMITED')
WHERE avg_fragmentation_in_percent > 10.0 AND index_id > 0
    and object_id not in (select object_id from sys.objects where name like '%[_]temp[_]%')
    --only do the pair tables for testing
    --and object_id in (select object_id from sys.objects where name like '%[_]pair[_]%');

-- Declare the cursor for the list of partitions to be processed.
DECLARE partitions CURSOR FOR SELECT * FROM #work_to_do;
DECLARE @prevObject nvarchar(130);
declare @sqlcmd nvarchar(500)
declare @totalRows int 
DECLARE @ParmList nvarchar(50)

set @prevObject = ''
set @totalRows = 0

-- Open the cursor.
OPEN partitions;

-- Loop through the partitions.
WHILE (1=1)
    BEGIN;
                                set @prevObject = @objectname
        FETCH NEXT
           FROM partitions
           INTO @objectid, @indexid, @partitionnum, @frag;
        IF @@FETCH_STATUS < 0 BREAK;
        
       
        SELECT @objectname = QUOTENAME(o.name), @schemaname = QUOTENAME(s.name)
        FROM sys.objects AS o
        JOIN sys.schemas as s ON s.schema_id = o.schema_id
        WHERE o.object_id = @objectid;
        SELECT @indexname = QUOTENAME(name)
        FROM sys.indexes
        WHERE  object_id = @objectid AND index_id = @indexid;
        SELECT @partitioncount = count (*)
        FROM sys.partitions
        WHERE object_id = @objectid AND index_id = @indexid;
        
        if @prevObject <> @objectname 
                                begin
                                                set @sqlcmd = N'select @totalRows = COUNT(*) from ' + @schemaname + N'.' + @objectName
                                                set @ParmList = N'@totalRows int OUTPUT'
                                                exec sp_executesql @sqlcmd, @parmList, @totalRows = @totalRows output
        end
        
 
-- 30 is an arbitrary decision point at which to switch between reorganizing and rebuilding.
-- Rebuilding datbases locks the tables while reorganizing does not
        IF @frag < 30.0
            SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REORGANIZE';
        IF @frag >= 30.0
            SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REBUILD';
        IF @partitioncount > 1
            SET @command = @command + N' PARTITION=' + CAST(@partitionnum AS nvarchar(10));

        PRINT N'Executed: ' + @command;
    END;

-- Close and deallocate the cursor.
CLOSE partitions;
DEALLOCATE partitions;

-- Drop the temporary table.
DROP TABLE #work_to_do;
GO
