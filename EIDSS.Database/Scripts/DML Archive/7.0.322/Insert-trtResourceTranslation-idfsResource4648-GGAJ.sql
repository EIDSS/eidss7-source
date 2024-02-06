/*
Author:			Srilatha Chebrolu
Date:			12/12/2022
Description:	Add Missing Resource Translation String.
*/

INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4648,N'Advance Search',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4648}]','System', GETDATE(), 'System', GETDATE(), 10540004)

INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (128,4648,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":128,"idfsResource":4648}]', N'System', GETDATE(), N'System', GETDATE())

INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4648,10049001,N'[TBD]', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4648,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4648,10049004,N'[TBD]', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4648,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4648,10049006,N'[TBD]', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4648,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4648,10049011,N'[TBD]', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4648,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())

GO