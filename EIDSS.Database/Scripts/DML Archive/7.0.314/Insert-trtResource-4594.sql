/*
Author:			Mike Kornegay
Date:			11/14/2022
Description:	Add resources for HASC Code.

*/

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 4594)
INSERT into dbo.trtResource (
			idfsResource,
			strResourceName,
			intRowStatus,
			rowguid,
			strMaintenanceFlag,
			strReservedAttribute,
			SourceSystemNameID,
			SourceSystemKeyValue,
			AuditCreateUser,
			AuditCreateDTM,
			AuditUpdateUser,
			AuditUpdateDTM, 
			idfsResourceType
		)
        VALUES (
			4594,
			N'HASC Code',
			0,
			NEWID(),
			N'Add',
			N'EIDSS7 Resources', 
			10519001, 
			N'[{"idfsResource":4594}]',
			'System', 
			GETDATE(), 
			'System', 
			GETDATE(), 
			10540003
		)
GO
		
IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 4594 and idfsResourceSet = 225)
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM, idfsReportTextID)
        VALUES (225,4594,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":4594,"idfsResourceType":10540003}]', N'System', GETDATE(), N'System', GETDATE(),0)
GO
