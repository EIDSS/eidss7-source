/*
Author:			Stephen Long
Date:			10/03/2022
Description:	Add heading resource for the laboratory samples LUC01 use case. 
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResourceSet = 164 AND idfsResource = 4494)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (164,4494,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":164,"idfsResource":4494}]', N'System', GETDATE(), N'System', GETDATE())
END
GO
