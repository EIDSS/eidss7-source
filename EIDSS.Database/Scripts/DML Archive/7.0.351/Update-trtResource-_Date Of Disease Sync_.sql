/*
    The DBs are out of sync for the "Resource" tables. This will correct that issue for "Date of Disease"

    Errors do occur, but that is ok.

    Author: Doug Albanese

*/

INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4540,N'Date Of Disease',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4540}]','System', GETDATE(), 'System', GETDATE(), 10540003)

INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (284,4540,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":284,"idfsResource":4540}]', N'System', GETDATE(), N'System', GETDATE())

INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4540,10049011,N'تاريخ المرض', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4540,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4540,10049001,N'Xəstəliyin aşkar olunma tarixi', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4540,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4540,10049004,N'დაავადების თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4540,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())

--If the records already exist, then they need to be updated.
update trtResourceTranslation set strResourceString = N'Xəstəliyin aşkar olunma tarixi' where idfsResource = 4540 and idfsLanguage = 10049001
update trtResourceTranslation set strResourceString = N'დაავადების თარიღი' where idfsResource = 4540 and idfsLanguage = 10049004
update trtResourceTranslation set strResourceString = N'تاريخ المرض' where idfsResource = 4540 and idfsLanguage = 10049011