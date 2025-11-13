Declare @OldestLog datetime, 
     @FirstLog int, 
     @SearchText nvarchar(50), 
     @DBName sysname 
Declare @ErrorLog Table (LogID int identity(1, 1) not null primary key, 
                              LogDate datetime null, 
                              ProcessInfo nvarchar(100) null, 
                              LogText nvarchar(max) null) 
Declare @EnumLogs Table (ArchiveNum int not null primary key, 
                              ArcDate Datetime not null, 
                              LogFileSize bigint not null) 

Set nocount On 
Set @OldestLog = '2/1/2009' 
Set @SearchText = N'pages dumped: ' 
Set @DBName = '<database name>' 

Insert Into @EnumLogs 
Exec master..xp_enumerrorlogs 

Select Top 1 @FirstLog = ArchiveNum 
From @EnumLogs 
Where ArcDate < @OldestLog 
Order By ArcDate DESC 

If @FirstLog Is Null 
  Begin 
     Select Top 1 @FirstLog = ArchiveNum 
     From @EnumLogs 
     Order By ArchiveNum DESC 
  End 

While @FirstLog >= 0 
  Begin 
     Insert Into @ErrorLog (LogDate, ProcessInfo, LogText) 
     Exec master..xp_readerrorlog @FirstLog 
     Set @FirstLog = @FirstLog - 1 
  End 

Select Convert(varchar, LogDate, 101) As BUPDate, 
Cast(Cast((Cast(RTrim(LTrim(SubString(LogText, CharIndex(@SearchText, LogText) + Len(@SearchText), CharIndex(',', LogText, CharIndex(@SearchText, LogText)) - CharIndex(@SearchText, LogText) - Len(@SearchText)))) as BigInt) * 8.0)/1024 As Decimal(9, 2)) As varchar) + ' MB' As BUPSize 
From @ErrorLog 
Where CharIndex('Backup', ProcessInfo) > 0 
And CharIndex('Database backed up. Database: ' + @DBName, LogText) > 0 
Order By LogDate Asc 

Set nocount Off

