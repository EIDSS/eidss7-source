/*
Author:			Stephen Long
Date:			09/28/2022
Description:	Add heading resource for the laboratory approvals use case. 
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 4492)
BEGIN
    INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4492,N'Validation',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4492}]','System', GETDATE(), 'System', GETDATE(), 10540004)
END
GO

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 4493)
BEGIN
    INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4493,N'Test Deletion',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4493}]','System', GETDATE(), 'System', GETDATE(), 10540004)
END
GO