/*
Author:			Stephen Long
Date:			12/15/2022
Description:	Add mappings for SAUC29 - search actors modal. 
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 500 AND idfsResourceSet = 375)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit)
    VALUES (375,500,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":375,"idfsResource":500}]', N'System', GETDATE(), N'System', GETDATE(),1)
END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 501 AND idfsResourceSet = 375)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit)
    VALUES (375,501,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":375,"idfsResource":501}]', N'System', GETDATE(), N'System', GETDATE(),1)
END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 610 AND idfsResourceSet = 375)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit)
    VALUES (375,610,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":375,"idfsResource":610}]', N'System', GETDATE(), N'System', GETDATE(),1)
END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 661 AND idfsResourceSet = 375)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit)
    VALUES (375,661,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":375,"idfsResource":661}]', N'System', GETDATE(), N'System', GETDATE(),1)
END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 201 AND idfsResourceSet = 375)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit)
    VALUES (375,201,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":375,"idfsResource":201}]', N'System', GETDATE(), N'System', GETDATE(),1)
END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 423 AND idfsResourceSet = 375)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit)
    VALUES (375,423,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":375,"idfsResource":423}]', N'System', GETDATE(), N'System', GETDATE(),1)
END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 486 AND idfsResourceSet = 375)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit)
    VALUES (375,486,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":375,"idfsResource":486}]', N'System', GETDATE(), N'System', GETDATE(),1)
END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 608 AND idfsResourceSet = 375)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit)
    VALUES (375,608,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":375,"idfsResource":608}]', N'System', GETDATE(), N'System', GETDATE(),1)
END

GO