/*
Author:			Stephen Long
Date:			10/10/2022
Description:	Add heading resource for the SAUC60 - system event log use case. 
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 4495)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4495,N'System Event Log',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4495}]','System', GETDATE(), 'System', GETDATE(), 10540004)
END
GO