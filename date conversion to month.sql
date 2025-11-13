Select convert (Varchar(4),(YEAR(getdate()))) + '-' + convert (Varchar(4),(Month(getdate()))) 

 SELECT DATENAME(month, DATEADD(month, getdate()-1, CAST('2008-01-01' AS datetime)))
 SELECT DATENAME(month, GETDATE()) AS 'Month Name'
