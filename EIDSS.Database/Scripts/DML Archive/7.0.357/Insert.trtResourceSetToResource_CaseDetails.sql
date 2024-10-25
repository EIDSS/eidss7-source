/*Author:        Stephen Long
Date:            06/27/2023
Description:     Insert resource set to resource for Case details for human outbreak case.
*/
IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 284 AND idfsResource = 3435)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (284,3435,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":284,"idfsResource":3435}]', N'System', GETDATE(), N'System', GETDATE())
END
