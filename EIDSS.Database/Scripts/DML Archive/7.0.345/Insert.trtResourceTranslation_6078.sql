/*Author:        Stephen Long
Date:            04/18/2023
Description:     Update resource translation for Azeri on Legacy ID.
*/
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsLanguage = 10049001 AND idfsResource = 936)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(936,10049001,N'Legacy ID', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":936,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
END

GO