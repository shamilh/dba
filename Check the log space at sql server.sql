SELECT logical_name  , 
		CONVERT(char, backup_start_date, 111) AS [Date], --yyyy/mm/dd format
		CONVERT(char, backup_start_date, 108) AS [Time],
		CONVERT(numeric(9,2),i2.file_size/1048576) as [File Size],
		CONVERT(numeric(9,2),i2.backup_size/1048576) as [Backup Size]

--,i3.backup_size

  --	MAX(i2.backup_set_id) 
							FROM	msdb.dbo.backupfile i2 JOIN msdb.dbo.backupset i3
								ON i2.backup_set_id = i3.backup_set_id
								Group by 
								logical_name,
								CONVERT(char, backup_start_date, 111),
								CONVERT(char, backup_start_date, 108) ,
								CONVERT(numeric(9,2),i2.file_size/1048576),
								CONVERT(numeric(9,2),i2.backup_size/1048576)

								order by 1