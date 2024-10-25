/*
    Correction for translations that are not synced up across all the DBs.

    This will error out on DBs that already have it, and will update them if they are blank.

    Author: Doug Albanese
*/

INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (3695,N'Return to Outbreak Parameters',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":3695}]','System', GETDATE(), 'System', GETDATE(), 10540000)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (3696,N'Proceed to Outbreak Session',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":3696}]','System', GETDATE(), 'System', GETDATE(), 10540000)

INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (61,3695,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":61,"idfsResource":3695}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (61,3696,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":61,"idfsResource":3696}]', N'System', GETDATE(), N'System', GETDATE())

INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(3695,10049004,N'აფეთქების პარამეტრებზე დაბრუნება', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3695,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(3696,10049004,N'გადადით აფეთქების სესიაზე', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3696,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())


UPDATE trtResourceTranslation SET strResourceString = N'აფეთქების პარამეტრებზე დაბრუნება' WHERE idfsResource = 3695 AND idfsLanguage = 10049004
UPDATE trtResourceTranslation SET strResourceString = N'გადადით აფეთქების სესიაზე' WHERE idfsResource = 3696 AND idfsLanguage = 10049004