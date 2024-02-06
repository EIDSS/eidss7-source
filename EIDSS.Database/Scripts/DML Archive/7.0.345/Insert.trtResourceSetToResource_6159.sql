/*Author:        Stephen Long
Date:            04/19/2023
Description:     Insert resource set to resource for 759 - Disease Matrix Heading for Veterinary Aggregate Report
*/
IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 250 AND idfsResource = 759)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (250,759,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":250,"idfsResource":759}]', N'System', GETDATE(), N'System', GETDATE())
END