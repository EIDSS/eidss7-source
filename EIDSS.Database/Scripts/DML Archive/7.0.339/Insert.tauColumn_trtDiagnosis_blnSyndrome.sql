/*Author:        Leo Tracchia
Date:            03/14/2023
Description:     create new table entry in tauColumn for blnSyndrome for Data Audit on Disease Reference Editor 
*/
IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000118)
	BEGIN
   
		INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
		VALUES (51586990000118, 75840000000, 'blnSyndrome', 'Syndromic Surveillance', 10519002, '[{"idfColumn":51586990000118}]', 'System', GETDATE(), NULL, NULL)

	END
GO