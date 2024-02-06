/*
Author:			Stephen Long
Date:			09/28/2022
Description:	Add heading resource for the laboratory approvals use case. 
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4492)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4492,10049011,N'التصديق/ التحقق من الصحة', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4492,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4492,10049001,N'Təsdiqləmə', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4492,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4492,10049004,N'დამტკიცება', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4492,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END
GO

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4493)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4493,10049011,N'حذف الاختبار', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4493,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4493,10049001,N'Testin silinməsi', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4493,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4493,10049004,N'ტესტის წაშლა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4493,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END
GO


