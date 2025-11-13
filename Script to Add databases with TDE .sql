--select getdate()
--GO


-- Declaring parameters
DECLARE @Baksql VARCHAR(8000)
DECLARE @Baktrn VARCHAR(8000)
DECLARE @Rstsql VARCHAR(8000)
DECLARE @Rsttrn VARCHAR(8000)
DECLARE @SQLAdd VARCHAR(8000)
DECLARE @AOAG VARCHAR(8000)
DECLARE @BackupFolder VARCHAR(100)
DECLARE @BackupFile VARCHAR(100)
DECLARE @BAK_PATH VARCHAR(4000)

-- Setting VALUE of  backup folder
SET @BackupFolder = '\\CTXDBWQ4\sharedfiles\'


SET @AOAG =( SELECT NAME FROM sys.availability_groups)
--PRINT @AOAG



-- Declaring cursor
DECLARE c_bakup CURSOR FAST_FORWARD READ_ONLY FOR  
SELECT NAME FROM SYS.DATABASES 
WHERE state_desc = 'ONLINE' -- Consider databases which are online
AND NAME NOT IN ('tempdb','master','model','msdb')  -- Exluding Temp databases

-- Opening and fetching next VALUEs from cursor
OPEN c_bakup 
FETCH NEXT FROM c_bakup INTO @BackupFile 

WHILE @@FETCH_STATUS = 0
BEGIN

-- Creating dynamic script for every databases backup which are online 
SET @Baksql = 'BACKUP DATABASE ['+@BackupFile+'] TO DISK = '''+@BackupFolder+@BackupFile+'.bak'' WITH FORMAT,COMPRESSION ;'
SET @Baktrn = 'BACKUP LOG ['+@BackupFile+'] TO DISK = '''+@BackupFolder+@BackupFile+'.trn'' WITH FORMAT,COMPRESSION;'
SET @Rstsql = 'RESTORE DATABASE ['+@BackupFile+'] TO DISK = '''+@BackupFolder+@BackupFile+'.bak'' WITH FORMAT,COMPRESSION ;'
SET @Rsttrn = 'RESTORE LOG ['+@BackupFile+'] TO DISK = '''+@BackupFolder+@BackupFile+'.trn'' WITH FORMAT,COMPRESSION;'

--Generate backup script 
-- Executing dynamic query to take backup
Print '-- Backup script   ' + @BackupFile
PRINT (@Baksql)
--EXEC(@Baksql)

Print '-- Log Script   ' + @BackupFile
PRINT (@Baktrn)
--EXEC(@Baktrn)
/*
----Generate Restore Script 
Print 'Restore Backup sccript  ' + @BackupFile
PRINT (@Rstsql)
--EXEC(@Rstsql)
Print 'Restore LOG Sccript   ' +  @BackupFile
PRINT (@Rstsql)
--EXEC(@Rstsql)

SET @SQLAdd = 'USE master  ALTER AVAILABILITY GROUP [ '+@AOAG+'] ADD DATABASE ['+@BackupFile + ']'
Print @SQLAdd
--EXEC @SQLAdd
*/
-- Opening and fetching next VALUEs from sursor
FETCH NEXT FROM c_bakup INTO @BackupFile 
END 

-- Closing and Deallocating cursor
CLOSE c_bakup
DEALLOCATE c_bakup

--select getdate()
--GO

/*
--BACKUP DATABASE [TESTHA] TO  DISK = N'E:\Dailybackup\testha.bak' WITH NOFORMAT, INIT,  NAME = N'TESTHA-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
--GO
--BACKUP LOG [TESTHA] TO  DISK = N'E:\Dailybackup\testha.trn' WITH NOFORMAT, INIT,  NAME = N'TESTHA-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
--GO


SET @Rstsql = 'RESTORE DATABASE ['+@BackupFile+'] TO DISK = '''+@BackupFolder+@BackupFile+'.bak'' WITH FORMAT,COMPRESSION ;'
SET @Rsttrn = 'RESTORE LOG ['+@BackupFile+'] TO DISK = '''+@BackupFolder+@BackupFile+'.trn'' WITH FORMAT,COMPRESSION;'

--restore Backup
USE [master]
RESTORE DATABASE [TESTHA] FROM  DISK = N'E:\Dailybackup\TESTHA.bak' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  REPLACE,  STATS = 5
GO

-- Restore LOG
RESTORE LOG [TESTHA] FROM  DISK = N'E:\Dailybackup\TESTHA.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

SET @SQLAdd = 'USE master  ALTER AVAILABILITY GROUP [ '+@AOAG+'] ADD DATABASE ['+@BackupFile + ']'
Print @SQLAdd
USE master  ALTER AVAILABILITY GROUP CITRIXUATHA ADD DATABASE [TDE_Test]

*/