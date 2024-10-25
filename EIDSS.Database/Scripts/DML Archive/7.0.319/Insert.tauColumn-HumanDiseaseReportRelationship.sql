/*
Author:			Stephen Long
Date:			11/30/2022
Description:	Creation of new column entries for HumanDiseaseReportRelationship for SAUC30 and 31.
*/

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000001)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000001, 53577790000000, 'HumanDiseasereportRelnUID', 'HumanDiseasereportRelnUID', 10519002, '[{"idfColumn":51586990000001}]', 'System', GETDATE(), NULL, NULL)
END

GO