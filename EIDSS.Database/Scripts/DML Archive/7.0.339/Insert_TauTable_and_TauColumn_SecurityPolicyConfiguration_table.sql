

/*
Author:			Manickandan Govindarajan
Date:			03/12/2023
Description:	Creation of a new table entry for SecurityPolicyConfiguration for SAUC30 and 31 in TauTable and TauColumn
*/



IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000005)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (53577790000005, 'SecurityPolicyConfiguration', NULL, 10519002, '[{"idfTable":53577790000005}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000049)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000049, 53577790000005, 'SecurityPolicyConfigurationUID', 'SecurityPolicyConfigurationUID', 10519002, '[{"idfColumn":51586990000049}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000050)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000050, 53577790000005, 'MinPasswordLength', 'MinPasswordLength', 10519002, '[{"idfColumn":51586990000050}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000051)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000051, 53577790000005, 'EnforcePasswordHistoryCount', 'EnforcePasswordHistoryCount', 10519002, '[{"idfColumn":51586990000051}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000052)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000052, 53577790000005, 'MinPasswordAgeDays', 'MinPasswordAgeDays', 10519002, '[{"idfColumn":51586990000052}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000053)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000053, 53577790000005, 'ForceUppercaseFlag', 'ForceUppercaseFlag', 10519002, '[{"idfColumn":51586990000053}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000054)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000054, 53577790000005, 'ForceLowercaseFlag', 'ForceLowercaseFlag', 10519002, '[{"idfColumn":51586990000054}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000055)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000055, 53577790000005, 'ForceNumberUsageFlag', 'ForceNumberUsageFlag', 10519002, '[{"idfColumn":51586990000055}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000056)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000056, 53577790000005, 'ForceSpecialCharactersFlag', 'ForceSpecialCharactersFlag', 10519002, '[{"idfColumn":51586990000056}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000057)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000057, 53577790000005, 'AllowUseOfSpaceFlag', 'AllowUseOfSpaceFlag', 10519002, '[{"idfColumn":51586990000057}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000058)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000058, 53577790000005, 'PreventSequentialCharacterFlag', 'PreventSequentialCharacterFlag', 10519002, '[{"idfColumn":51586990000058}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000059)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000059, 53577790000005, 'PreventUsernameUsageFlag', 'PreventUsernameUsageFlag', 10519002, '[{"idfColumn":51586990000059}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000060)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000060, 53577790000005, 'LockoutThld', 'LockoutThld', 10519002, '[{"idfColumn":51586990000060}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000061)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000061, 53577790000005, 'LockoutDurationMinutes', 'LockoutDurationMinutes', 10519002, '[{"idfColumn":51586990000061}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000062)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000062, 53577790000005, 'MaxSessionLength', 'MaxSessionLength', 10519002, '[{"idfColumn":51586990000062}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000063)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000063, 53577790000005, 'SesnIdleTimeoutWarnThldMins', 'SesnIdleTimeoutWarnThldMins', 10519002, '[{"idfColumn":51586990000063}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000064)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000064, 53577790000005, 'SesnIdleCloseoutThldMins', 'SesnIdleCloseoutThldMins', 10519002, '[{"idfColumn":51586990000064}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000065)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000065, 53577790000005, 'SesnInactivityTimeOutMins', 'SesnInactivityTimeOutMins', 10519002, '[{"idfColumn":51586990000065}]', 'System', GETDATE(), NULL, NULL)
END
GO

