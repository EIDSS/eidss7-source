/*Author:        Stephen Long
Date:            03/31/2023
Description:     Update data audit base reference record for Human Aggregate Disease Report.
*/
UPDATE dbo.trtBaseReference SET intRowStatus = 0 WHERE idfsBaseReference = 10017077

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10017077 AND idfsLanguage = 10049004)
BEGIN
	INSERT INTO dbo.trtStringNameTranslation (idfsBaseReference, idfsLanguage, strTextString, intRowStatus, SourceSystemNameID, SourceSystemKeyValue, AuditCreateDTM, AuditCreateUser) 
	VALUES (10017077, 10049004, N'ადამიანის აგრეგირებული ანგარიში', 0, 10519001, N'[{"idfsBaseReference":10017077,"idfsLanguage":10049004}]', GETDATE(), 'System')
END