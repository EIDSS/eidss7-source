/*
Author:			Stephen Long
Date:			11/28/2022
Description:	Creation of new column entries for HumanDiseaseReportVaccinations for SAUC30 and 31.
*/

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586690000001)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586690000001, 53577590000000, 'VaccinationName', 'VaccinationName', 10519002, '[{"idfColumn":51586690000001}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586690000002)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586690000002, 53577590000000, 'VaccinationDate', 'VaccinationDate', 10519002, '[{"idfColumn":51586690000002}]', 'System', GETDATE(), NULL, NULL)
END

GO