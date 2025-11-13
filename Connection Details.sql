    
/*************************************************************/  
/****************** Connection Details ***********************/  
/*************************************************************/  
		IF OBJECT_ID('tempdb..#ConnInfo') IS NOT NULL
					DROP TABLE #ConnInfo  


-- Number of connection on the instance grouped by hostnames  
Create table #ConnInfo(               
Hostname varchar(100),                           
NumberOfconn varchar(10)                          
)    
insert into #ConnInfo  
SELECT  Case when len(hostname)=0 Then 'Internal Process' Else hostname END,count(*)NumberOfconnections   
FROM sys.sysprocesses  
GROUP BY hostname  
  
  Select * from #ConnInfo


IF OBJECT_ID('tempdb..#ConnInfo') IS NOT NULL
					DROP TABLE #ConnInfo  

