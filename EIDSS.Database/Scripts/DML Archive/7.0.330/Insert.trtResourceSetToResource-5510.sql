/*
Author:			Stephen Long
Date:			01/17/2023
Description:	Update trtResourceSetToResource for headings on site details - permissions.  DevOps item 5510.

*/

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 339 AND idfsResourceSet = 333)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (333,339,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":333,"idfsResource":339}]', N'System', GETDATE(), N'System', GETDATE())
END
GO