/*
    New Resource entries requested by Leo Tracchia

    Author: Doug Albanese
*/

    
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4808,N'The value of field Age shall not exceed 31 days, or 60 months, or 200 years.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4808}]','System', GETDATE(), 'System', GETDATE(), 10540006)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4809,N'Age > 100. Please verify age is correct.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4809}]','System', GETDATE(), 'System', GETDATE(), 10540006)



INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (193,4808,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":193,"idfsResource":4808}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (193,4809,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":193,"idfsResource":4809}]', N'System', GETDATE(), N'System', GETDATE())



INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4808,10049011,N'', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4808,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4808,10049001,N'', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4808,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4808,10049004,N'', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4808,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4809,10049011,N'', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4809,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4809,10049001,N'', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4809,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4809,10049004,N'', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4809,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
