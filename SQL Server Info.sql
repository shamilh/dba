CREATE TABLE ##WinNames
(
WinID float,
WinName varchar(max),
--,VersionName varchar(max),
[MACHINE NAME] varchar(max),
INSTANCE varchar(max),
[SQL PORT] varchar(max),
[Product Version] varchar(max),
[product level] varchar(max),
[SQL Server Version] varchar(max),
[Edition] varchar(max),
[Source IP]varchar(max),
[Server IP] varchar(max),
net_transport varchar(max),
protocol_type varchar(max),
auth_scheme varchar(max)
)

insert into ##WinNames (WinID,WinName) values (3.10,'Windows NT 3.1')
insert into ##WinNames (WinID,WinName) values (3.50,'Windows NT 3.5')
insert into ##WinNames (WinID,WinName) values (3.51,'Windows NT 3.51')
insert into ##WinNames (WinID,WinName) values (4.0,'Windows NT 4.0')
insert into ##WinNames (WinID,WinName) values (5.0,'Windows 2000')
insert into ##WinNames (WinID,WinName) values (5.1,'Windows Server 2003')
insert into ##WinNames (WinID,WinName) values (5.2,'Windows Server 2003 R2')
insert into ##WinNames (WinID,WinName) values (3.50,'Windows NT 3.5')
insert into ##WinNames (WinID,WinName) values (3.10,'Windows NT 3.1')
insert into ##WinNames (WinID,WinName) values (6.0,'Windows Server 2008')
insert into ##WinNames (WinID,WinName) values (6.1,'Windows Server 2008 R2')
insert into ##WinNames (WinID,WinName) values (6.2,'Windows Server 2012')
insert into ##WinNames (WinID,WinName) values (6.3,'Windows Server 2012 R2')

SELECT OSVersion =RIGHT(@@version, LEN(@@version)- 3 -charindex (' ON ', @@VERSION)) into #WVer

select SUBSTRING(OSVersion, 11,4 ) AS WinID, OSVersion into  #WVer1 from #WVer

--Select * from ##WinNames Where WinID = (select SUBSTRING(OSVersion, 11,4 ) AS WinID from #WVer)





Update ##WinNames 
			 Set 
		-- VersionName = Left(@@Version, Charindex('-', @@version) - 5),
		[MACHINE NAME] = (SElect CONVERT(varchar(max),SERVERPROPERTY('MachineName'))),
	    INSTANCE = (select CONVERT(varchar(max),SERVERPROPERTY('InstanceName'))),
		[SQL PORT] = (select CONVERT(varchar(max),CONNECTIONPROPERTY('local_tcp_port'))),
	    [Product Version] = (SElect CONVERT(varchar(max),SERVERPROPERTY ('productversion'))),
        [product level] = (SElect CONVERT(varchar(max),SERVERPROPERTY ('productlevel'))),
		[Edition] = (Select CONVERT(varchar(max),SERVERPROPERTY ('edition'))),
		[SQL Server Version] = (Select CONVERT(varchar(max),@@VERSION)) ,
		[Server IP] = (Select CONVERT(varchar(max),CONNECTIONPROPERTY('local_net_address'))),
		[Source IP] = (select CONVERT(varchar(max),CONNECTIONPROPERTY('client_net_address'))),
		net_transport = (select CONVERT(varchar(max),CONNECTIONPROPERTY('net_transport'))),
		protocol_type = (select CONVERT(varchar(max),CONNECTIONPROPERTY('protocol_type'))),
		auth_scheme = (SElect CONVERT(varchar(max),CONNECTIONPROPERTY('auth_scheme')))
Where WinID = (select SUBSTRING(OSVersion, 11,4 ) AS WinID from #WVer)


select * -- WN.WinName, wn1.OSVersion 
from ##WinNames WN
inner join #WVer1 wn1
on wn1.WinID = wn.WinID

drop table #WVer1
drop table #WVer
drop table ##WinNames



