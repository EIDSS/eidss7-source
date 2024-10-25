/*Author:        Stephen Long
Date:            06/05/2023
Description:     Insert resource set to resource for 949 - admin level 4 for vet active surveillance session search.
*/
IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 389 AND idfsResource = 949)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (389,949,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":389,"idfsResource":949}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 329 AND idfsResource = 949)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (329,949,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":329,"idfsResource":949}]', N'System', GETDATE(), N'System', GETDATE())
END