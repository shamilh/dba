Create procedure sp_list_fragmented_tables 
  ( @internalFragmentationPctAllowed int,
    @externalFragmentationPctAllowed int )
as
BEGIN 
  Declare @showContigStmt varchar(100)
  Declare @CurrTable         varchar(50)

/* Cursor declared on USER tables that have A clustered index */

  DECLARE c_examined_tables
        cursor for select a.table_name from 
        information_schema.tables a,sysindexes b 
        where             a.table_type = 'BASE TABLE' and 
                a.table_name = object_name (b.id) and 
                b.indid = 1 
  set noCount on 

/* create Result table as a temporary table */   

  Create table #showContigResults 
        (ObjectName sysname,
         Objectid bigint,
         IndexName sysname,
         indexid int,
         [level] int,
         pages int ,
         [rows] bigint,
         minRecsize int,
         maxRecsize int,
         avgRecSize real ,
         ForwardRecs int,
         Extents int,
         ExtentSwitches int,
         AvgFreeBytes real,
         AvgPageDensity real,
         ScanDensity decimal(5,2), 
         BestCount int,
         ActCount int,
         LogicalFrag decimal (5,2), 
         ExtentFragmentation decimal (5,2)) 
 
  /* loop over all tables and exec DBCC SHOWCONTIG with TABLERESULTS format */

  OPEN c_examined_tables
  FETCH NEXT FROM c_examined_tables INTO @CurrTable
  WHILE @@FETCH_STATUS = 0
   BEGIN
     set @showContigStmt = 'DBCC SHOWCONTIG ([' + @currTable + '])' + 
                ' with tableresults'
     Insert  #showContigResults exec (@showContigStmt)
     FETCH NEXT FROM c_examined_tables INTO @CurrTable
   END 

  close c_examined_tables
  deallocate c_examined_tables

 /* output fragmented objects that fall within the criteria */
  select ObjectName ,  ScanDensity , ExtentFragmentation 
  from #showContigResults
  where ScanDensity < @internalFragmentationPctAllowed or 
        ExtentFragmentation > @externalFragmentationPctAllowed
 
END 
go


exec sp_list_fragmented_tables 50,10

DBCC SHOWCONTIG 
With All_Indexes
