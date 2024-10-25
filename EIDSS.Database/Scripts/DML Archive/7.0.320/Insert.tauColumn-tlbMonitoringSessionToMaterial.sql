/*
Author:			Leo Tracchia
Date:			12/5/2022
Description:	Creation of a new column entries for tlbMonitoringSessionToMaterial for SAUC30 and 31.
*/

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000022)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000022, 53577790000003, 'idfMaterial', null, NEWID(), 10519002, '[{"idfTable":51586990000022}]', 'System', getdate(), null, null)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000023)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000023, 53577790000003, 'idfsSampleType', null, NEWID(), 10519002, '[{"idfTable":51586990000023}]', 'System', getdate(), null, null)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000024)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000024, 53577790000003, 'idfMonitoringSession', null, NEWID(), 10519002, '[{"idfTable":51586990000024}]', 'System', getdate(), null, null)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000025)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000025, 53577790000003, 'idfsDisease', null, NEWID(), 10519002, '[{"idfTable":51586990000025}]', 'System', getdate(), null, null)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000026)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000026, 53577790000003, 'intRowStatus', null, NEWID(), 10519002, '[{"idfTable":51586990000026}]', 'System', getdate(), null, null)
END
GO

