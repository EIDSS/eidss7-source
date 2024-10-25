/*
Author:			Stephen Long
Date:			02/24/2023
Description:	Creation of new table entries for tauColumn for SAUC30 and 31 - organization.
*/

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000045)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000045, 75650000000, 'OrganizationTypeID', NULL, 10519002, '[{"idfColumn":51586990000045}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000046)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000046, 75650000000, 'OwnershipFormID', NULL, 10519002, '[{"idfColumn":51586990000046}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000047)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000047, 75650000000, 'LegalFormID', NULL, 10519002, '[{"idfColumn":51586990000047}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000048)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000048, 75650000000, 'MainFormOfActivityID', NULL, 10519002, '[{"idfColumn":51586990000048}]', 'System', GETDATE(), NULL, NULL)
END