USE MASTER
declare
   @isql varchar(2000),
   @dbname varchar(64),
   @logfile varchar(128),
   @RMS Varchar(8),
   @RMF Varchar(8)
   
   Set @RMS = 'SIMPLE'
   Set @RMF = 'FULL'
   
      declare c1 cursor for 
   SELECT  d.name, mf.name as logfile --, physical_name AS current_file_location, size
	FROM sys.master_files mf
      inner join sys.databases d
      on mf.database_id = d.database_id
   where recovery_model_desc <>  @RMS  --'SIMPLE'
   and d.name not in ('master','model','msdb','tempdb') 
   and mf.type_desc = 'LOG'   
   open c1
   fetch next from c1 into @dbname, @logfile
   While @@fetch_status <> -1
      begin
	  Print ' -- Convert Database recovery mode to SIMPLE Database '+ @dbname
      select @isql = 'ALTER DATABASE ' + @dbname + ' SET RECOVERY '+@RMS
      print @isql
      --exec(@isql)
	  Print '  -- Check Point occoured on Database '+ @dbname
      select @isql='USE ' + @dbname + ' checkpoint'
      print @isql
      --exec(@isql)
	  Print '  -- Shrink Database '+ @dbname
      select @isql='USE ' + @dbname + ' DBCC SHRINKFILE (' + @logfile + ', 1)'
      print @isql
      ----exec(@isql)
	  Print '  -- Convert Database recovery mode to FULL Database  '+ @dbname
      select @isql = 'ALTER DATABASE ' + @dbname + ' SET RECOVERY '+@RMF
      print @isql
      ----exec(@isql)

      fetch next from c1 into @dbname, @logfile
      end
   close c1
   deallocate c1