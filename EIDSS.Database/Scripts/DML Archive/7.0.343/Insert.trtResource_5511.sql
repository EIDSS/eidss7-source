/*Author:        Stephen Long
Date:            04/05/2023
Description:     Create resources for OMMUC08 - search outbreak.
*/
IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4801)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4801,N'Search Outbreak',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4801}]','System', GETDATE(), 'System', GETDATE(), 10540004)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4801 AND idfsResourceSet = 60)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (60,4801,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":60,"idfsResource":4801}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4801)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4801,10049011,N'بحث تفشي المرض', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4801,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4801,10049001,N'Alovlanmanı axtar', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4801,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4801,10049004,N'აფეთქების ძებნა ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4801,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END