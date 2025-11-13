
		/**** Enable Send mail option in SQL Server ****/
USE master
GO
sp_configure 'show advanced options',1
GO
RECONFIGURE WITH OVERRIDE
GO
sp_configure 'Database Mail XPs',1
GO
RECONFIGURE 
GO
--***************************************************************************--
			/*** Add Profile ***/

USE msdb
GO
EXECUTE msdb.dbo.sysmail_add_profile_sp
@profile_name = 'MS-SQL DBAS Profile',
@description = 'MS-SQL DBAS'

GO
/******************************************************************************/
			/**** Create Account ****/

EXECUTE msdb.dbo.sysmail_add_account_sp
@account_name = 'MS-SQL DBAS Account',
@description = 'MS-SQL DBAS',
@email_address = 'MS-SQLDBAs@riyadbank.com',
@display_name = 'MS-SQL DBAS',
@mailserver_name = 'rdccas.intra.riyadbank.com',
@port = 25
GO

/*******************************************************************************/
		/****  Add Account to Profile ****/


EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
@profile_name = 'MS-SQL DBAS Profile',
@account_name = 'MS-SQL DBAS Account',
@sequence_number = 1
GO

/*************  Add Operators ***************************/

USE [msdb]
GO
EXEC msdb.dbo.sp_add_operator @name=N'Hassan Shamil', 
		@enabled=1, 
		@pager_days=0, 
		@email_address=N'v-hassan.jehangir@riyadbank.com'
EXEC msdb.dbo.sp_add_operator @name=N'MS-SQL DBAS', 
		@enabled=1, 
		@pager_days=0, 
		@email_address=N'MS-SQLDBAs@riyadbank.com'
EXEC msdb.dbo.sp_add_operator @name=N' Naeem Ullah Inam Ullah', 
		@enabled=1, 
		@pager_days=0, 
		@email_address=N'v-naeem.inam@riyadbank.com'
EXEC msdb.dbo.sp_add_operator @name=N'Muhammad Ajaz', 
		@enabled=1, 
		@pager_days=0, 
		@email_address=N'muhammad.ajaz@riyadbank.com'


EXEC msdb.dbo.sp_add_operator @name=N'MS-SQLDBA-Group', 
		@enabled=1, 
		@pager_days=0, 
		@email_address=N'v-hassan.jehangir@riyadbank.com;v-naeem.inam@riyadbank.com;muhammad.ajaz@riyadbank.com'


		/**************************  Add Notifier in the backup job ****************************************/
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'Dailybackup', 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@notify_email_operator_name=N'MS-SQLDBA-Group'
GO

		/************************   Disable Daily backup Job  *****************************************/

EXEC msdb.dbo.sp_update_job @job_name='Dailybackup',@enabled = 0