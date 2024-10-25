/*
Author:			Stephen Long
Date:			11/28/2022
Description:	Creation of a new table entry for HumanAddlInfo for SAUC30 and 31.
*/

IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577690000000)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (53577690000000, 'HumanAddlInfo', NULL, 10519002, '[{"idfTable":53577690000000}]', 'System', GETDATE(), NULL, NULL)
END
GO