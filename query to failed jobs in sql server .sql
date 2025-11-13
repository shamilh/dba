-- Variable Declarations 

DECLARE @PreviousDate datetime  
DECLARE @Year VARCHAR(4)   
DECLARE @Month VARCHAR(2)  
DECLARE @MonthPre VARCHAR(2)  
DECLARE @Day VARCHAR(2)  
DECLARE @DayPre VARCHAR(2)  
DECLARE @FinalDate INT  

-- Initialize Variables  
SET @PreviousDate = DATEADD(dd, -1, GETDATE()) -- Last 1 day   
SET @Year = DATEPART(yyyy, @PreviousDate)   
SELECT @MonthPre = CONVERT(VARCHAR(2), DATEPART(mm, @PreviousDate))  
SELECT @Month = RIGHT(CONVERT(VARCHAR, (@MonthPre + 1000000000)),2)  
SELECT @DayPre = CONVERT(VARCHAR(2), DATEPART(dd, @PreviousDate))  
SELECT @Day = RIGHT(CONVERT(VARCHAR, (@DayPre + 1000000000)),2)  
SET @FinalDate = CAST(@Year + @Month + @Day AS INT)  

--select @PreviousDate AS PreviousDate
--select @Year as [Year]
--SELECT @MonthPre as MonthPre
--select @Month as [Month]
--select @DayPre as [DayPre]
--select @Day as [Day]
--select  @FinalDate as [FinalDate]
--select @PreviousDate AS PreviousDate,  @Year as [Year],@MonthPre as MonthPre,@Month as [Month], @DayPre as [DayPre], @Day as [Day],@FinalDate as [FinalDate]

-- Final Logic 

SELECT   j.[name],  
         s.step_name,  
         h.step_id,  
         h.step_name,  
         h.run_date,  
         h.run_time,  
         h.sql_severity,  
         h.message,   
         h.server  
FROM     msdb.dbo.sysjobhistory h  
         INNER JOIN msdb.dbo.sysjobs j  
           ON h.job_id = j.job_id  
         INNER JOIN msdb.dbo.sysjobsteps s  
           ON j.job_id = s.job_id 
           AND h.step_id = s.step_id  
WHERE    h.run_status = 0 -- Failure  
         AND h.run_date > @FinalDate  
AND NAME IN ('RB-DBCC-Checkdb','RB-RebuildReorganizeIndex','RB-Recycle-Errorlog','RB-Update-Statistics')
ORDER BY h.instance_id DESC  
