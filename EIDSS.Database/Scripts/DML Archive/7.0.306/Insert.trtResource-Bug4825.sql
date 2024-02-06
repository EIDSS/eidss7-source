/*
Author:			Stephen Long
Date:			10/22/2022
Description:	Update trtResource for validation messages for laboratory module - testing tab.

*/

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 4496)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4496,N'Test Result is required',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4496}]','System', GETDATE(), 'System', GETDATE(), 10540006)
END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 4497)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4497,N'Result Date is required',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4497}]','System', GETDATE(), 'System', GETDATE(), 10540006)
END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 4498)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4498,N'Result Date must be earlier or equal to the current date',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4498}]','System', GETDATE(), 'System', GETDATE(), 10540006)
END
GO