/*Author:        Stephen Long
Date:            03/31/2023
Description:     Create resources for SYSUC07 - set location.
*/
IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4798)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4798,N'Set location',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4798}]','System', GETDATE(), 'System', GETDATE(), 10540004)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4798 AND idfsResourceSet = 54)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (54,4798,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":54,"idfsResource":4798}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4798)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4798,10049011,N'Yer təyin et', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4798,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4798,10049001,N'تحديد الموقع', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4798,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4798,10049004,N'მდებარეობის მითითება', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4798,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4798,10049006,N'Укажите местоположение', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4798,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END