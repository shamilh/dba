SELECT  
	SERVERPROPERTY('MachineName') AS [MACHINE NAME]
	,SERVERPROPERTY('InstanceName') AS INSTANCE
	,CONNECTIONPROPERTY('local_tcp_port') AS [SQL PORT]
	,SERVERPROPERTY ('productversion')AS [Product Version]
    ,SERVERPROPERTY ('productlevel') AS [product level]
    ,SERVERPROPERTY ('edition') AS [Edition]
	,@@VERSION AS [SQL Server Version]
	,CONNECTIONPROPERTY('local_net_address') AS [Server IP]
	,CONNECTIONPROPERTY('client_net_address') AS [Source IP]
	,CONNECTIONPROPERTY('net_transport') AS net_transport
	,CONNECTIONPROPERTY('protocol_type') AS protocol_type
	,CONNECTIONPROPERTY('auth_scheme') AS auth_scheme
	
	
