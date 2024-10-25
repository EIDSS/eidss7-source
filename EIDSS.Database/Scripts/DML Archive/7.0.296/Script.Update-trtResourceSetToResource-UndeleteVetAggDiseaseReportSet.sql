/*
Author:			Mike Kornegay
Date:			09/28/2022
Description:	Resetting all Veterinary Aggregate Disease Report resources in set 111 back to active
                and add resources 352, 2799, and 3586 to set 111.
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

BEGIN
    UPDATE trtResourceSetToResource 
    SET intRowStatus = 0
    WHERE idfsResourceSet = 111
END
GO

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 352 AND idfsResourceSet = 111)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource 
            (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM, idfsReportTextID)
    VALUES 
            (111,352,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":111,"idfsResource":352,"idfsResourceType":10540003}]', N'System', GETDATE(), N'System', GETDATE(),0)
END
GO

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 2799 AND idfsResourceSet = 111)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource 
            (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM, idfsReportTextID)
    VALUES 
            (111,2799,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":111,"idfsResource":2799,"idfsResourceType":10540003}]', N'System', GETDATE(), N'System', GETDATE(),0)
END
GO

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 3586 AND idfsResourceSet = 111)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource 
            (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM, idfsReportTextID)
    VALUES 
            (111,3586,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":111,"idfsResource":3586,"idfsResourceType":10540003}]', N'System', GETDATE(), N'System', GETDATE(),0)
END
GO
