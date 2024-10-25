/*
Author:			Mike Kornegay
Date:			10/25/2022
Description:	Add resources for collection date validation messages for vector detailed collections.

*/

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 4500)
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
			4500,
			N'Collection date shall be on or before the identifying date.',
			0,
			NEWID(),
			N'Add',
			N'EIDSS7 Resources', 
			10519001, 
			N'[{"idfsResource":4500}]',
			'System', 
			GETDATE(), 
			'System', 
			GETDATE(), 
			10540006
		)
GO
		
IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 4500 and idfsResourceSet = 245)
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM, idfsReportTextID)
        VALUES (245,4500,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":245,"idfsResource":4500,"idfsResourceType":10540006}]', N'System', GETDATE(), N'System', GETDATE(),0)
GO

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 4501)
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
			4501,
			N'Identifying date shall be on or after the session start date.',
			0,
			NEWID(),
			N'Add',
			N'EIDSS7 Resources', 
			10519001, 
			N'[{"idfsResource":4501}]',
			'System', 
			GETDATE(), 
			'System', 
			GETDATE(), 
			10540006
		)
GO

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 4501 and idfsResourceSet = 245)
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM, idfsReportTextID)
        VALUES (245,4501,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":245,"idfsResource":4501,"idfsResourceType":10540006}]', N'System', GETDATE(), N'System', GETDATE(),0)
GO

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 4502)
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
			4502,
			N'Identifying date shall be on or after the collection date.',
			0,
			NEWID(),
			N'Add',
			N'EIDSS7 Resources', 
			10519001, 
			N'[{"idfsResource":4502}]',
			'System', 
			GETDATE(), 
			'System', 
			GETDATE(), 
			10540006
		)
GO

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 4502 and idfsResourceSet = 245)
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM, idfsReportTextID)
        VALUES (245,4502,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":245,"idfsResource":4502,"idfsResourceType":10540006}]', N'System', GETDATE(), N'System', GETDATE(),0)
GO

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 4592)
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
			4592,
			N'Identifying date shall be on or before the session close date.',
			0,
			NEWID(),
			N'Add',
			N'EIDSS7 Resources', 
			10519001, 
			N'[{"idfsResource":4592}]',
			'System', 
			GETDATE(), 
			'System', 
			GETDATE(), 
			10540006
		)
GO

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 4592 and idfsResourceSet = 245)
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM, idfsReportTextID)
        VALUES (245,4592,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":245,"idfsResource":4592,"idfsResourceType":10540006}]', N'System', GETDATE(), N'System', GETDATE(),0)
GO