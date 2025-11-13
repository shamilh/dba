/********************************************************************/  
/****************** Index Fragmentation Details ***********************/  
/********************************************************************/  


  	IF OBJECT_ID('tempdb..#IdxFrag_Detail') IS NOT NULL
					DROP TABLE #IdxFrag_Detail  

  
CREATE TABLE #IdxFrag_Detail(  
ID INT IDENTITY PRIMARY KEY NOT NULL,
[SCHEMA]   NVARCHAR(250),
[TABLE]	   NVARCHAR(250),
[INDEX]    NVARCHAR(250),
[FRAGMENTATION] NVARCHAR(250),
[PAGE_COUNT] NVARCHAR(500), 
[STATUS] NVARCHAR(250));

INSERT INTO #IdxFrag_Detail ([SCHEMA],[TABLE],[INDEX],[FRAGMENTATION],[PAGE_COUNT],[STATUS])
SELECT	TOP 50
		object_schema_name(ips.object_id)	AS 'Schema_Name',
		object_name (ips.object_id)		AS 'Object_Name',
		i.name					AS 'Index_Name',
		ips.avg_fragmentation_in_percent	AS 'Avg_Fragmentation%',
		ips.page_count				AS 'Page_Count',
		CASE	WHEN (ips.avg_fragmentation_in_percent BETWEEN 5 AND 30) AND ips.page_count > 1000
			THEN 'Reorganize'
		WHEN ips.avg_fragmentation_in_percent > 30 AND ips.page_count > 1000 
			THEN 'Rebuild'
		ELSE	     'Healthy'
		END AS 'Index_Status'
FROM	sys.dm_db_index_physical_stats(db_id(), null, null, null, null) ips
INNER JOIN sys.indexes i ON i.object_id = ips.object_id 
		   AND i.index_id = ips.index_id
WHERE	ips.index_id > 0
ORDER BY avg_fragmentation_in_percent DESC;


Select * from #IdxFrag_Detail


  	IF OBJECT_ID('tempdb..#IdxFrag_Detail') IS NOT NULL
					DROP TABLE #IdxFrag_Detail  

