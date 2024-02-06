/*Author:        Stephen Long
Date:            06/08/2023
Description:     Insert resource set to resource for 3407 - record saved successfully message for weekly reporting form.
*/
IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 256 AND idfsResource = 3407)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (256,3407,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":256,"idfsResource":3407}]', N'System', GETDATE(), N'System', GETDATE())
END

UPDATE trtResourceTranslation SET strResourceString = N'ჩანაწერი შენახულია წარმატებით. ჩანაწერის ID არის {0}' where idfsResource = 3407 and idfsLanguage = 10049004

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsLanguage = 10049006 AND idfsResource = 3407)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3407,10049006,N'Запись успешно сохранена. Инд. № записи {0}', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3407,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END
ELSE
BEGIN
    UPDATE trtResourceTranslation SET strResourceString = N'Запись успешно сохранена. Инд. № записи {0}' WHERE idfsResource = 3407 AND idfsLanguage = 10049006
END

IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4810)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4810,N'Acute Flaccid Paralysis',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4810}]','System', GETDATE(), 'System', GETDATE(), 10540002)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 96 AND idfsResource = 4810)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (96,4810,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":96,"idfsResource":4810}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsLanguage = 10049004 AND idfsResource = 4810)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4810,10049004,N'მწვავე დუნე დამბლა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4810,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4811)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4811,N'Total must be greater than Among them Notified',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4811}]','System', GETDATE(), 'System', GETDATE(), 10540006)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 96 AND idfsResource = 4811)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (96,4811,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":96,"idfsResource":4811}]', N'System', GETDATE(), N'System', GETDATE())
END