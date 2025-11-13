USE master
GO
Drop PROCEDURE dbo.sp_ListJobInformation
    @DBUltra bit = 0,
    @PCUltra bit = 0,
    @DBIntra varchar(8000) = NULL,
    @DBExtra varchar(8000) = NULL,
    @PCIntra varchar(100)  = NULL,
    @PCExtra varchar(100)  = NULL,
    @PCAdmin varchar(100)  = NULL
AS

SET NOCOUNT ON

DECLARE @Return int
DECLARE @Retain int
DECLARE @Status int

SET @Status = 0

DECLARE @Task varchar(400)

DECLARE @Name varchar(100)
DECLARE @Same varchar(100)

DECLARE @SPID smallint

CREATE TABLE #DBAH
   (job_id          uniqueidentifier
   ,program_name    varchar(34)
   ,login_time      datetime
   ,last_batch      datetime
   ,run_length      datetime
   ,spid            smallint
   ,spud            smallint
   ,dbid            smallint)

CREATE TABLE #DBAZ
   (job_id          uniqueidentifier
   ,job_name        varchar(100)
   ,step_count      int
   ,last_run_date   int
   ,last_run_time   int
   ,next_run_date   int
   ,next_run_time   int
   ,schedule_id     int
   ,schedule_name   varchar(100)
   ,requested       int
   ,requester_id    int
   ,requester_name  varchar(100)
   ,enabled         int
   ,running         int
   ,step_id         int
   ,step_name       varchar(100)
   ,subsystem       varchar(100)
   ,retry           int
   ,state           int)

SET @PCAdmin = ISNULL(@PCAdmin,'SQLAgent%Job%')

INSERT #DBAH
SELECT 0x0
     , SUBSTRING(P.program_name,CHARINDEX('0x',P.program_name),34)
     ,             P.login_time
     ,             P.last_batch
     , GETDATE() - P.login_time
     , P.spid
     , P.blocked
     , P.dbid
  FROM master.dbo.sysprocesses AS P
 WHERE P.program_name LIKE @PCAdmin

SET @Retain = @@ERROR IF @Status = 0 SET @Status = @Retain

DECLARE Records CURSOR FAST_FORWARD FOR
 SELECT spid, program_name
   FROM #DBAH

OPEN Records

FETCH NEXT FROM Records INTO @SPID, @Name

WHILE @@FETCH_STATUS = 0 AND @Status = 0

    BEGIN

    SET @Task = 'UPDATE #DBAH SET job_id = CONVERT(uniqueidentifier,' + @Name + ') WHERE spid = ' + CONVERT(varchar(5),@SPID)

    EXECUTE (@Task)

    FETCH NEXT FROM Records INTO @SPID, @Name

    END

CLOSE Records DEALLOCATE Records

   INSERT #DBAZ 
     (job_id
     ,last_run_date
     ,last_run_time
     ,next_run_date
     ,next_run_time
     ,schedule_id
     ,requested
     ,requester_id
     ,requester_name
     ,running
     ,step_id
     ,retry
     ,state)
  EXECUTE master.dbo.xp_sqlagent_enum_jobs 1,sa

SET @Retain = @@ERROR IF @Status = 0 SET @Status = @Retain

   UPDATE #DBAZ SET
          enabled = O.enabled
        , job_name = O.name
        , step_name = S.step_name
        , subsystem = S.subsystem
        , schedule_name = W.name
     FROM #DBAZ AS T
     JOIN msdb.dbo.sysjobs AS O
       ON T.job_id = O.job_id
LEFT JOIN msdb.dbo.sysjobsteps AS S
       ON T.job_id = S.job_id AND T.step_id = S.step_id
LEFT JOIN msdb.dbo.sysjobschedules AS W
       ON T.job_id = W.job_id AND T.schedule_id = W.schedule_id
    WHERE 0 = 0
      AND (@DBIntra IS NULL OR CHARINDEX('|'+O.name+'|','|'+(@DBIntra)+'|') > 0)
      AND (@DBExtra IS NULL OR CHARINDEX('|'+O.name+'|','|'+(@DBExtra)+'|') = 0)
      AND (@PCIntra IS NULL OR               O.name     LIKE @PCIntra)
      AND (@PCExtra IS NULL OR               O.name NOT LIKE @PCExtra)

SET @Retain = @@ERROR IF @Status = 0 SET @Status = @Retain

   UPDATE #DBAZ SET
          step_count = I.step_count
     FROM #DBAZ AS T
     JOIN
  (SELECT O.job_id
        , COUNT(*) AS step_count
     FROM msdb.dbo.sysjobs AS O
     JOIN msdb.dbo.sysjobsteps AS S
       ON O.job_id = S.job_id
 GROUP BY O.job_id) AS I
       ON T.job_id = I.job_id

SET @Retain = @@ERROR IF @Status = 0 SET @Status = @Retain

   DELETE #DBAZ WHERE job_name IS NULL OR (@DBUltra <> 0 AND enabled = 0) OR (@PCUltra <> 0 AND running = 0)

   SELECT I.job_id
        , I.job_name
        , I.step_count
        , SUBSTRING(I.last_run_date,1,4) + '.' + SUBSTRING(I.last_run_date,5,2) + '.' + SUBSTRING(I.last_run_date,7,2) AS last_run_date
        , SUBSTRING(I.last_run_time,1,2) + ':' + SUBSTRING(I.last_run_time,3,2) + ':' + SUBSTRING(I.last_run_time,5,2) AS last_run_time
        , SUBSTRING(I.next_run_date,1,4) + '.' + SUBSTRING(I.next_run_date,5,2) + '.' + SUBSTRING(I.next_run_date,7,2) AS next_run_date
        , SUBSTRING(I.next_run_time,1,2) + ':' + SUBSTRING(I.next_run_time,3,2) + ':' + SUBSTRING(I.next_run_time,5,2) AS next_run_time
        , I.schedule_id
        , I.schedule_name
        , I.enabled
        , I.running
        , I.retry
        , I.state
--      , I.requested
        , I.requester_id
        , I.requester_name
        , I.step_id
        , I.step_name
        , I.subsystem
        , ISNULL(O.name,SPACE(0)) AS database_name
        , ISNULL(CONVERT(varchar(20),T.login_time,102),SPACE(0)) AS login_date
        , ISNULL(CONVERT(varchar(20),T.login_time,  8),SPACE(0)) AS login_time
        , ISNULL(CONVERT(varchar(20),T.last_batch,102),SPACE(0)) AS batch_date
        , ISNULL(CONVERT(varchar(20),T.last_batch,  8),SPACE(0)) AS batch_time
        , ISNULL(CONVERT(varchar(20),T.run_length,  8),SPACE(0)) AS run_length
        , ISNULL(T.spid,0) AS job_spid
        , ISNULL(T.spud,0) AS blocking
     FROM
  (SELECT job_id
        , job_name
        , step_count
        , RIGHT(STR(last_run_date+100000000,9),8) AS last_run_date
        , RIGHT(STR(last_run_time+1000000  ,7),6) AS last_run_time
        , RIGHT(STR(next_run_date+100000000,9),8) AS next_run_date
        , RIGHT(STR(next_run_time+1000000  ,7),6) AS next_run_time
        , ISNULL(schedule_id  ,      0 ) AS schedule_id
        , ISNULL(schedule_name,SPACE(0)) AS schedule_name
        , enabled
        , running
        , retry
        , state
--      , ISNULL(requested     ,      0 ) AS requested
        , ISNULL(requester_id  ,      0 ) AS requester_id
        , ISNULL(requester_name,SPACE(0)) AS requester_name
        , ISNULL(step_id  ,      0 ) AS step_id
        , ISNULL(step_name,SPACE(0)) AS step_name
        , ISNULL(subsystem,SPACE(0)) AS subsystem
     FROM #DBAZ) AS I
LEFT JOIN #DBAH  AS T
       ON I.job_id = T.job_id
LEFT JOIN master.dbo.sysdatabases AS O
       ON T.dbid = O.dbid

SET @Retain = @@ERROR IF @Status = 0 SET @Status = @Retain

DROP TABLE #DBAH

DROP TABLE #DBAZ

SET NOCOUNT OFF

RETURN (@Status)

EXECUTE sp_ListJobInformation1 1,0 
