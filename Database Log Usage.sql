/*************************************************************/  
/****************** Database Log Usage ***********************/  
/*************************************************************/  

	IF OBJECT_ID('tempdb..#LogSpace') IS NOT NULL
					DROP TABLE #LogSpace  


CREATE TABLE #LogSpace(  
DBName VARCHAR(100),  
LogSize VARCHAR(50),  
LogSpaceUsed_Percent VARCHAR(100),   
LStatus CHAR(1));  
  
INSERT INTO #LogSpace  
EXEC ('DBCC SQLPERF(LOGSPACE) WITH NO_INFOMSGS;');  


Select * from #LogSpace



	IF OBJECT_ID('tempdb..#LogSpace') IS NOT NULL
					DROP TABLE #LogSpace  
