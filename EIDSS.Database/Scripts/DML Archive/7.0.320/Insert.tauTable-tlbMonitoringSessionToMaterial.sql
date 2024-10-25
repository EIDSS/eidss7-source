/*
Author:			Leo Tracchia
Date:			12/5/2022
Description:	Creation of a new table entry for tlbMonitoringSessionToMaterial for SAUC30 and 31.
*/

IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000003)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (53577790000003, 'tlbMonitoringSessionToMaterial', NULL, 10519002, '[{"idfTable":53577790000003}]', 'System', GETDATE(), NULL, NULL)	
END
GO