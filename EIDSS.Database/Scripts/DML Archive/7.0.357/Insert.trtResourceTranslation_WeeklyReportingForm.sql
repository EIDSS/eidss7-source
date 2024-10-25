/*Author:        Stephen Long
Date:            06/13/2023
Description:     Insert resource Russian translation for 4810 - Acute Flaccid Paralysis for weekly reporting form.
*/
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsLanguage = 10049006 AND idfsResource = 4810)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4810,10049006,N'Острый вялый паралич', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4810,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END