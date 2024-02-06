/*
    Author: Doug Albanese

    New entry for localization

    NOTE! I've decided to leave the entire script in, just in case if this was ran in a different order...when creating a new DB or when migration is performed.
    So, you will get some "Red" errors, because of existing entries.
*/

INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4540,N'Date of Disease',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4540}]','System', GETDATE(), 'System', GETDATE(), 10540003)



INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (284,4540,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":284,"idfsResource":4540}]', N'System', GETDATE(), N'System', GETDATE())



INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4540,10049011,N'تاريخ المرض', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4540,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4540,10049001,N'Xəstəliyin aşkar olunma tarixi', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4540,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4540,10049004,N'დაავადების თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4540,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
