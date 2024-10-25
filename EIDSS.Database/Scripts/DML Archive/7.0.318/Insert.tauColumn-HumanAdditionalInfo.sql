/*
Author:			Stephen Long
Date:			11/28/2022
Description:	Creation of new column entries for HumanAddlInfo for SAUC30 and 31.
*/

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586890000001)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586890000001, 53577690000000, 'ReportedAge', 'ReportedAge', 10519002, '[{"idfColumn":51586890000001}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586890000002)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586890000002, 53577690000000, 'ReportedAgeUOMID', 'ReportedAgeUOMID', 10519002, '[{"idfColumn":51586890000002}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586890000003)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586890000003, 53577690000000, 'ContactPhoneCountryCode', 'ContactPhoneCountryCode', 10519002, '[{"idfColumn":51586890000003}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586890000004)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586890000004, 53577690000000, 'ContactPhoneNbr', 'ContactPhoneNbr', 10519002, '[{"idfColumn":51586890000004}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586890000005)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586890000005, 53577690000000, 'ContactPhoneNbrTypeID', 'ContactPhoneNbrTypeID', 10519002, '[{"idfColumn":51586890000005}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586890000006)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586890000006, 53577690000000, 'HumanAdditionalInfo', 'HumanAdditionalInfo', 10519002, '[{"idfColumn":51586890000006}]', 'System', GETDATE(), NULL, NULL)
END

GO