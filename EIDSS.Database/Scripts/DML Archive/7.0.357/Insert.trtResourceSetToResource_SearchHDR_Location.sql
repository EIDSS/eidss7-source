/*Author:        Stephen Long
Date:            06/14/2023
Description:     Insert resource set to resource for Location for search human disease report.
*/
IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 212 AND idfsResource = 975)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (212,975,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":212,"idfsResource":975}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 320 AND idfsResource = 975)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (320,975,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":320,"idfsResource":975}]', N'System', GETDATE(), N'System', GETDATE())
END
