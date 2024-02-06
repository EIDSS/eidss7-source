/*
    This script is for creating new localization entries.

    This script should run without any PK errors.

    Since this is Translations...run on the Master and all environments.

    Author: Doug Albanese
*/

INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4803,N'List of Symptoms',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4803}]','System', GETDATE(), 'System', GETDATE(), 10540003)



INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (284,4803,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":284,"idfsResource":4803}]', N'System', GETDATE(), N'System', GETDATE())

INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (233,4803,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":233,"idfsResource":4803}]', N'System', GETDATE(), N'System', GETDATE())


INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4803,10049011,N'قائمة الأعراض', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4803,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4803,10049001,N'Simptomların siyahısı', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4803,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4803,10049004,N'სიმპტომების ჩამონათვალი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4803,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())







