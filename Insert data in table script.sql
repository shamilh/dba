
--Use DBNAme 
--GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[TestTableSize](
	[MyKeyField] [varchar](10) NOT NULL,
	[MyDate1] [datetime] NOT NULL,
	[MyDate2] [datetime] NOT NULL,
	[MyDate3] [datetime] NOT NULL,
	[MyDate4] [datetime] NOT NULL,
	[MyDate5] [datetime] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/************************************************************************/


DECLARE @RowCount INT
DECLARE @RowString VARCHAR(10)
DECLARE @Random INT
DECLARE @Upper INT
DECLARE @Lower INT
DECLARE @InsertDate DATETIME

SET @Lower = -730
SET @Upper = -1
SET @RowCount = 0

WHILE @RowCount < 50000
BEGIN
	SET @RowString = CAST(@RowCount AS VARCHAR(10))
	SELECT @Random = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)
	SET @InsertDate = DATEADD(dd, @Random, GETDATE())
	
	INSERT INTO TestTableSize
		(MyKeyField
		,MyDate1
		,MyDate2
		,MyDate3
		,MyDate4
		,MyDate5)
	VALUES
		(REPLICATE('0', 10 - DATALENGTH(@RowString)) + @RowString
		, @InsertDate
		,DATEADD(dd, 1, @InsertDate)
		,DATEADD(dd, 2, @InsertDate)
		,DATEADD(dd, 3, @InsertDate)
		,DATEADD(dd, 4, @InsertDate))

	SET @RowCount = @RowCount + 1
END