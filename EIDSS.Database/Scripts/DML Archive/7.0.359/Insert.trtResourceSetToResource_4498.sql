/*Author:        Stephen Long
Date:            07/05/2023
Description:     Insert resource set to resource for Search Farm for veterinary active surveillance session - detailed information.
*/
IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 136 AND idfsResource = 3123)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (136,3123,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":136,"idfsResource":3123}]', N'System', GETDATE(), N'System', GETDATE())
END
