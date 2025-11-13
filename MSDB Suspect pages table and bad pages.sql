
SELECT DB_NAME(database_id),[file_id],page_id,
CASE event_type 
WHEN 1 THEN '823 or 824 or Torn Page'
WHEN 2 THEN 'Bad Checksum'
WHEN 3 THEN 'Torn Page'
WHEN 4 THEN 'Restored'
WHEN 5 THEN 'Repaired (DBCC)'
WHEN 7 THEN 'Deallocated (DBCC)'
END,
error_count,
last_update_date
FROM msdb..suspect_pages