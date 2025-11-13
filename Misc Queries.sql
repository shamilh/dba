-- Dynamic SQL QUICK SYNTAX

------------
/*
USE AdventureWorks2008;

EXEC ('SELECT * FROM Sales.SalesOrderHeader')

 

DECLARE @DynamicSQL varchar(256); SET @DynamicSQL='SELECT * FROM Sales.SalesOrderHeader'

EXEC (@DynamicSQL)

GO

DECLARE @DynamicSQL varchar(256), @Table sysname;

SET @DynamicSQL='SELECT * FROM'; SET @Table = 'Sales.SalesOrderHeader'

SET @DynamicSQL = @DynamicSQL+' '+@Table

PRINT @DynamicSQL  -- for testing & debugging

EXEC (@DynamicSQL)

GO
*/
-- Dynamic SQL for rowcount in all tables

DECLARE @DynamicSQL nvarchar(max), @Schema sysname, @Table sysname;

SET @DynamicSQL = ''

SELECT @DynamicSQL = @DynamicSQL + 'SELECT '''+QUOTENAME(TABLE_SCHEMA)+'.'+

  QUOTENAME(TABLE_NAME)+''''+

  '= COUNT(*) FROM '+ QUOTENAME(TABLE_SCHEMA)+'.'+QUOTENAME(TABLE_NAME) +';'

FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'

PRINT @DynamicSQL                 -- test & debug

EXEC sp_executesql @DynamicSQL    -- sql server sp_executesql

 

-- Equivalent code using the undocumented sp_MSforeachtable

EXEC sp_MSforeachtable 'select ''?'', count(*) from ?'

------------

-- Dynamic sort with collation - Dynamic ORDER BY - SQL dynamic sorting

DECLARE @SQL nvarchar(max)='SELECT FullName=FirstName+'' ''+Lastname

  FROM AdventureWorks2008.Person.Person

  ORDER BY LastName '

DECLARE @Collation nvarchar(max) = 'COLLATE SQL_Latin1_General_CP1250_CS_AS'

SET @SQL=@SQL + @Collation

PRINT @SQL

EXEC sp_executeSQL @SQL

------------

-- sp_executeSQL usage with input and output parameters

DECLARE @SQL NVARCHAR(max), @ParmDefinition NVARCHAR(1024)

DECLARE @Color varchar(16) = 'Blue', @LastProduct varchar(64)

SET @SQL =       N'SELECT @pLastProduct = max(Name)

                   FROM AdventureWorks2008.Production.Product

                   WHERE Color = @pColor'

SET @ParmDefinition = N'@pColor varchar(16),

                        @pLastProduct varchar(64) OUTPUT'

EXECUTE sp_executeSQL

            @SQL,

            @ParmDefinition,

            @pColor = @Color,

            @pLastProduct=@LastProduct OUTPUT

SELECT Color=@Color, LastProduct=@LastProduct

/* Color    LastProduct

Blue  Touring-3000 Blue, 62 */