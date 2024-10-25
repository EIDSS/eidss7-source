/*
Author:			Stephen Long
Date:			11/28/2022
Description:	Creation of new column entries for tlbGeoLocation for SAUC30 and 31.
*/

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51523700000000)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51523700000000, 75580000000, 'idfsLocation', 'idfsLocation', 10519002, '[{"idfColumn":51523700000000}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51523710000000)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51523710000000, 4572590000000, 'idfsLocation', 'idfsLocation', 10519002, '[{"idfColumn":51523710000000}]', 'System', GETDATE(), NULL, NULL)
END


GO