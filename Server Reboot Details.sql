-----Server Reboot Details-----


SELECT 
		 SERVERPROPERTY('ComputerNamePhysicalNetBIOS')AS 'Machine Name'
		,CONNECTIONPROPERTY ('local_net_address') AS 'Ip Adress' 
		,CONNECTIONPROPERTY ('local_tcp_port') AS Port
	  --sqlserver_start_time 'Last Recycle'
	  --,Convert(Varchar(10), sqlserver_start_time,104) 'Last Recycle Date'
		,Convert(Varchar(11), sqlserver_start_time,100) 'Last Recycle Date'
		,Convert(Varchar(5), sqlserver_start_time,108) 'Last Recycle time'
	  --,Convert(Varchar(11), sqlserver_start_time,11) 'Last Recycle time'
		,GetDate() 'Current Date'
		, DATEDIFF(DD, sqlserver_start_time,GETDATE())'Up Time in Days'  
FROM sys.dm_os_sys_info;  