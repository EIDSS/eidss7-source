/*
Author:			Stephen Long
Date:			02/08/2023
Description:	Creation of new table entries for tauTable for SAUC30 and 31.
*/
IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 52577590000000)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (52577590000000, 'HumanActualAddlInfo', null, '9F3B3980-7D91-4465-BD40-2A3293FA0748', 10519002, null, null, GETDATE(), null, null);
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577690000000)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (53577690000000, 'HumanAddlInfo', NULL, 10519002, '[{"idfTable":53577690000000}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577590000000)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (53577590000000, 'HumanDiseaseReportVaccination', NULL, 10519002, '[{"idfTable":53577590000000}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000000)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (53577790000000, 'HumanDiseaseReportRelationship', NULL, 10519002, '[{"idfTable":53577790000000}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000002)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (53577790000002, 'MonitoringSessionToSampleType', NULL, 10519002, '[{"idfTable":53577790000002}]', 'System', GETDATE(), NULL, NULL)	
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000003)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (53577790000003, 'tlbMonitoringSessionToMaterial', NULL, 10519002, '[{"idfTable":53577790000003}]', 'System', GETDATE(), NULL, NULL)	
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000001)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (53577790000001, 'tlbReportForm', NULL, 10519002, '[{"idfTable":53577790000001}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000004)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (53577790000004, 'VetDiseaseReportRelationship', NULL, 10519002, '[{"idfTable":53577790000004}]', 'System', GETDATE(), NULL, NULL)
END

GO