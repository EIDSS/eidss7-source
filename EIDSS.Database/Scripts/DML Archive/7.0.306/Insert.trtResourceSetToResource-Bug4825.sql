/*
Author:			Stephen Long
Date:			10/22/2022
Description:	Update trtResourceSetToResource for validation messages for laboratory module - testing tab.  DevOps item 4825.

*/

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 4496 AND idfsResourceSet = 81)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (81,4496,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":81,"idfsResource":4496}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 4497 AND idfsResourceSet = 81)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (81,4497,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":81,"idfsResource":4497}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 4498 AND idfsResourceSet = 81)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (81,4498,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":81,"idfsResource":4498}]', N'System', GETDATE(), N'System', GETDATE())
END
GO