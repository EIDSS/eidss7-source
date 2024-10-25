/*
Author:			Leo Tracchia
Date:			12/5/2022
Description:	Creation of a new column entries for MonitoringSessionToSampleType for SAUC30 and 31.
*/


IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000018)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000018, 53577790000002, 'idfMonitoringSession', null, NEWID(), 10519002, '[{"idfTable":51586990000018}]', 'System', getdate(), null, null)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000019)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000019, 53577790000002, 'intOrder', null, NEWID(), 10519002, '[{"idfTable":51586990000019}]', 'System', getdate(), null, null)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000020)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000020, 53577790000002, 'intRowStatus', null, NEWID(), 10519002, '[{"idfTable":51586990000020}]', 'System', getdate(), null, null)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000021)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000021, 53577790000002, 'idfsSampleType', null, NEWID(), 10519002, '[{"idfTable":51586990000021}]', 'System', getdate(), null, null)
END
GO