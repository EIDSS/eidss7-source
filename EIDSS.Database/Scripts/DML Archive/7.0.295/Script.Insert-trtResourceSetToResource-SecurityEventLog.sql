/*
Author:			Stephen Long
Date:			09/26/2022
Description:	Add heading resource for the security event log use case. 
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 4491 AND idfsResourceSet = 220)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (220,4491,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":220,"idfsResource":4491}]', N'System', GETDATE(), N'System', GETDATE())
END
GO


