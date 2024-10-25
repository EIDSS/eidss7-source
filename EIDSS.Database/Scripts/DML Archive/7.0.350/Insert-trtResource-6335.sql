/*
    New localization entry. Should be applied to the master DB for new deploys or migration.

    Author: Doug Albanese
*/

INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4807,N'List of Risk Factors',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4807}]','System', GETDATE(), 'System', GETDATE(), 10540004)



INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (199,4807,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":199,"idfsResource":4807}]', N'System', GETDATE(), N'System', GETDATE())



INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4807,10049011,N'قائمة عوامل الخطر', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4807,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4807,10049001,N'Risk faktorlarının siyahısı', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4807,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4807,10049004,N'რისკ ფაქტორების ჩამონათვალი ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4807,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
