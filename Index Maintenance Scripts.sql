--Index Maintenance Scripts
--You can check fragmented index with following script. Type SQL Server Database name is correctly in the first line then query will find fragmented indexes.

declare @db int
select @db=DB_ID('DEVECI')
select 'ALTER INDEX [' + i.name +'] on '+OBJECT_NAME(s.object_id)+' REBUILD WITH (ONLINE = ON)',
objname = OBJECT_NAME(s.object_id),
s.object_id,
index_name= i.name,
index_type_desc, 
avg_fragmentation_in_percent
from sys.dm_db_index_physical_stats(@db,null,null,null,null) as s
join sys.indexes i on i.object_id = s.object_id and i.index_id = s.index_id 
where avg_fragmentation_in_percent>30
order by avg_fragmentation_in_percent desc, page_count desc;