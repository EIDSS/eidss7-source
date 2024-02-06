/*
Author:			Stephen Long
Date:			11/28/2022
Description:	Creation of new column entry for tlbTesting for SAUC30 and 31.
*/

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586790000001)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586790000001, 75740000000, 'idfHumanCase', 'idfHumanCase', 10519002, '[{"idfColumn":51586790000001}]', 'System', GETDATE(), NULL, NULL)
END

GO