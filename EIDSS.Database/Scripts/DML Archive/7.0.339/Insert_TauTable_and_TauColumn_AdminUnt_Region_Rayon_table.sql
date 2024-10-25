

/*
Author:			Manickandan Govindarajan
Date:			03/12/2023
Description:	Creation of a new table entry for Adminstrative Unit for SAUC30 and 31 in TauTable and TauColumn
*/


-- Rayon
IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000007)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (53577790000007, 'gisRayon', NULL, 10519002, '[{"idfTable":53577790000007}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000078)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000078, 53577790000007, 'dblLatitude', 'dblLatitude', 10519002, '[{"idfColumn":51586990000078}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000079)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000079, 53577790000007, 'dblLongitude', 'dblLongitude', 10519002, '[{"idfColumn":51586990000079}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000080)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000080, 53577790000007, 'idfsCountry', 'Country identifier', 10519002, '[{"idfColumn":51586990000080}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000081)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000081, 53577790000007, 'idfsRegion', 'Region identifier', 10519002, '[{"idfColumn":51586990000081}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000082)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000082, 53577790000007, 'idfsRayon', 'Rayon identifier', 10519002, '[{"idfColumn":51586990000082}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000083)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000083, 53577790000007, 'intElevation', null, 10519002, '[{"idfColumn":51586990000083}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000086)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000086, 53577790000007, 'strHASC', null, 10519002, '[{"idfColumn":51586990000086}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000087)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000087, 53577790000007, 'strCode', null, 10519002, '[{"idfColumn":51586990000087}]', 'System', GETDATE(), NULL, NULL)
END
GO


-- Region
IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000008)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (53577790000008, 'gisRegion', NULL, 10519002, '[{"idfTable":53577790000008}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000072)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000072, 53577790000008, 'dblLatitude', 'dblLatitude', 10519002, '[{"idfColumn":51586990000072}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000073)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000073, 53577790000008, 'dblLongitude', 'dblLongitude', 10519002, '[{"idfColumn":51586990000073}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000074)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000074, 53577790000008, 'idfsCountry', 'Country identifier', 10519002, '[{"idfColumn":51586990000074}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000076)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000076, 53577790000008, 'idfsRegion', 'Rayon identifier', 10519002, '[{"idfColumn":51586990000076}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000077)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000077, 53577790000008, 'intElevation', null, 10519002, '[{"idfColumn":51586990000077}]', 'System', GETDATE(), NULL, NULL)
END
GO


IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000084)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000084, 53577790000008, 'strHASC', null, 10519002, '[{"idfColumn":51586990000084}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000085)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000085, 53577790000008, 'strCode', null, 10519002, '[{"idfColumn":51586990000085}]', 'System', GETDATE(), NULL, NULL)
END
GO


-- gisLocation
IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000009)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (53577790000009, 'gisLocation', NULL, 10519002, '[{"idfTable":53577790000009}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000087)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000087, 53577790000009, 'strHASC', null, 10519002, '[{"idfColumn":51586990000087}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000088)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000088, 53577790000009, 'strHASC', null, 10519002, '[{"idfColumn":51586990000088}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000089)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000089, 53577790000009, 'strCode', null, 10519002, '[{"idfColumn":51586990000089}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000090)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000090, 53577790000009, 'idfsType', null, 10519002, '[{"idfColumn":51586990000090}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000091)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000091, 53577790000009, 'dblLongitude', null, 10519002, '[{"idfColumn":51586990000091}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000092)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000092, 53577790000009, 'dblLatitude', null, 10519002, '[{"idfColumn":51586990000092}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000093)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000093, 53577790000009, 'blnIsCustom', null, 10519002, '[{"idfColumn":51586990000093}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000094)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000094, 53577790000009, 'intElevation', null, 10519002, '[{"idfColumn":51586990000094}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000095)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000095, 53577790000009, 'intRowStatus', null, 10519002, '[{"idfColumn":51586990000095}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000096)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000096, 53577790000009, 'idfsLocation', null, 10519002, '[{"idfColumn":51586990000096}]', 'System', GETDATE(), NULL, NULL)
END
GO
