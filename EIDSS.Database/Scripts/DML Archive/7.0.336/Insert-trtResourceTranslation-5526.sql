/*
    Authro: Doug Albanese

    Needed a resource set to resource for the interface editor to pick up the outbreak side

    Errors on this will occur, but the enetire script was added in case it was ran before other scripts with this content.
*/


INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (1087,N'Date of Notification',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":1087}]','System', GETDATE(), 'System', GETDATE(), 10540003)



INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (284,1087,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":284,"idfsResource":1087}]', N'System', GETDATE(), N'System', GETDATE())



INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(1087,10049011,N'تاريخ الإشعار', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":1087,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(1087,10049001,N'Bildiriş tarixi', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":1087,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(1087,10049004,N'შეტყობინების თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":1087,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())