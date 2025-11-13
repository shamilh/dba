/*************************************************************/  
/************* SQL Server Memory Usage Details ***************/  
/*************************************************************/  
 
 IF OBJECT_ID('tempdb..#Memory_BPool') IS NOT NULL
    DROP TABLE #Memory_BPool 
 

CREATE TABLE #Memory_BPool (  
BPool_Committed_MB VARCHAR(50),  
BPool_Commit_Tgt_MB VARCHAR(50),  
BPool_Visible_MB VARCHAR(50));  

/****  
  
-- SQL server 2008 / 2008 R2  
INSERT INTO #Memory_BPool    
SELECT  
     (bpool_committed*8)/1024.0 as BPool_Committed_MB,  
     (bpool_commit_target*8)/1024.0 as BPool_Commit_Tgt_MB,  
     (bpool_visible*8)/1024.0 as BPool_Visible_MB  
FROM sys.dm_os_sys_info;  
****/  

-- SQL server 2012 / 2014 / 2016  


INSERT INTO #Memory_BPool   
SELECT  
      (committed_kb)/1024.0 as BPool_Committed_MB,  
      (committed_target_kb)/1024.0 as BPool_Commit_Tgt_MB,  
      (visible_target_kb)/1024.0 as BPool_Visible_MB  
FROM  sys.dm_os_sys_info;  


IF OBJECT_ID('tempdb..#Memory_sys') IS NOT NULL
    DROP TABLE #Memory_sys 

CREATE TABLE #Memory_sys (  
total_physical_memory_mb VARCHAR(50),  
available_physical_memory_mb VARCHAR(50),  
total_page_file_mb VARCHAR(50),  
available_page_file_mb VARCHAR(50),  
Percentage_Used VARCHAR(50),  
system_memory_state_desc VARCHAR(50));  
  
INSERT INTO #Memory_sys  
select  
      total_physical_memory_kb/1024 AS total_physical_memory_mb,  
      available_physical_memory_kb/1024 AS available_physical_memory_mb,  
      total_page_file_kb/1024 AS total_page_file_mb,  
      available_page_file_kb/1024 AS available_page_file_mb,  
      100 - (100 * CAST(available_physical_memory_kb AS DECIMAL(18,3))/CAST(total_physical_memory_kb AS DECIMAL(18,3)))   
      AS 'Percentage_Used',  
      system_memory_state_desc  
from  sys.dm_os_sys_memory;  
  
 
IF OBJECT_ID('tempdb..#Memory_process') IS NOT NULL
    DROP TABLE #Memory_process  

CREATE TABLE #Memory_process(  
physical_memory_in_use_GB VARCHAR(50),  
locked_page_allocations_GB VARCHAR(50),  
virtual_address_space_committed_GB VARCHAR(50),  
available_commit_limit_GB VARCHAR(50),  
page_fault_count VARCHAR(50))  
  
INSERT INTO #Memory_process  
select  
      physical_memory_in_use_kb/1048576.0 AS 'Physical_Memory_In_Use(GB)',  
      locked_page_allocations_kb/1048576.0 AS 'Locked_Page_Allocations(GB)',  
      virtual_address_space_committed_kb/1048576.0 AS 'Virtual_Address_Space_Committed(GB)',  
      available_commit_limit_kb/1048576.0 AS 'Available_Commit_Limit(GB)',  
      page_fault_count as 'Page_Fault_Count'  
from  sys.dm_os_process_memory;  
  
 IF OBJECT_ID('tempdb..#Memory') IS NOT NULL
    DROP TABLE #Memory
 
CREATE TABLE #Memory(  
ID INT IDENTITY NOT NULL,
Parameter VARCHAR(200),  
Value VARCHAR(100));  
  
INSERT INTO #Memory   
SELECT 'BPool_Committed_MB',BPool_Committed_MB FROM #Memory_BPool  
UNION  
SELECT 'BPool_Commit_Tgt_MB', BPool_Commit_Tgt_MB FROM #Memory_BPool  
UNION   
SELECT 'BPool_Visible_MB', BPool_Visible_MB FROM #Memory_BPool  
UNION  
SELECT 'Total_Physical_Memory_MB',total_physical_memory_mb FROM #Memory_sys  
UNION  
SELECT 'Available_Physical_Memory_MB',available_physical_memory_mb FROM #Memory_sys
UNION  
SELECT 'Percentage_Used',Percentage_Used FROM #Memory_sys  
UNION
SELECT 'System_memory_state_desc',system_memory_state_desc FROM #Memory_sys  
UNION  
SELECT 'Total_page_file_mb',total_page_file_mb FROM #Memory_sys  
UNION  
SELECT 'Available_page_file_mb',available_page_file_mb FROM #Memory_sys  
UNION  
SELECT 'Physical_memory_in_use_GB',physical_memory_in_use_GB FROM #Memory_process  
UNION  
SELECT 'Locked_page_allocations_GB',locked_page_allocations_GB FROM #Memory_process  
UNION  
SELECT 'Virtual_Address_Space_Committed_GB',virtual_address_space_committed_GB FROM #Memory_process  
UNION  
SELECT 'Available_Commit_Limit_GB',available_commit_limit_GB FROM #Memory_process  
UNION  
SELECT 'Page_Fault_Count',page_fault_count FROM #Memory_process;  
  

select * from #Memory_BPool
select * from #Memory_sys
select * from #Memory_process
select * from #Memory


 
 IF OBJECT_ID('tempdb..#Memory_BPool') IS NOT NULL
    DROP TABLE #Memory_BPool 

IF OBJECT_ID('tempdb..#Memory_sys') IS NOT NULL
    DROP TABLE #Memory_sys 


 
IF OBJECT_ID('tempdb..#Memory_process') IS NOT NULL
    DROP TABLE #Memory_process 


  
 IF OBJECT_ID('tempdb..#Memory') IS NOT NULL
    DROP TABLE #Memory


