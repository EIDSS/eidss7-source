CREATE PROCEDURE [dbo].[USP_DataAudit_AuditEvents_GetList]
AS
SELECT 
	 t.idfTable AuditTable
	,t.strName TableName
	,RTRIM(CAST(t.idfTable AS NVARCHAR(20))) + '_' + RTRIM(CAST(c.idfColumn  AS NVARCHAR(20))) AuditColumn
	,c.strName ColumnName
	,c.strDescription Description 
FROM tauTable t
JOIN tauColumn c ON c.idfTable = T.idfTable
ORDER BY T.strName, c.strName

RETURN 0
