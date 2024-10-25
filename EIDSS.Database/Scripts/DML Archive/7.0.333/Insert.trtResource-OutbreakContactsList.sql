/*
    New Localization entry for "Outbreak Contacts List"
*/

INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4751,N'Outbreak Contacts List',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4751}]','System', GETDATE(), 'System', GETDATE(), 10540004)



INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (132,4751,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":132,"idfsResource":4751}]', N'System', GETDATE(), N'System', GETDATE())



INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4751,10049011,N'', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4751,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4751,10049001,N'', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4751,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4751,10049004,N'', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4751,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
