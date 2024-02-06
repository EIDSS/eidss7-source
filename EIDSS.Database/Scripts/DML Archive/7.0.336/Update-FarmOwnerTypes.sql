/*
Author:			Mike Kornegay
Date:			2/27/2023
Description:	1.  Check for Farm Owner reference type and add if not there 
				2.  Add Farm Owner base references
*/

IF NOT EXISTS (SELECT 1 FROM trtReferenceType WHERE idfsReferenceType = 19000065)
BEGIN
	INSERT INTO [dbo].[trtReferenceType]
           ([idfsReferenceType]
           ,[strReferenceTypeCode]
           ,[strReferenceTypeName]
           ,[intStandard]
           ,[idfMinID]
		   ,[idfMaxID]
           ,[rowguid]
		   ,[intRowStatus]
           ,[intHACodeMask]
		   ,[intDefaultHACode]
		   ,[strEditorName]
           ,[strMaintenanceFlag]
           ,[strReservedAttribute]
           ,[SourceSystemNameID]
           ,[SourceSystemKeyValue]
           ,[AuditCreateUser]
           ,[AuditCreateDTM]
           ,[AuditUpdateUser]
           ,[AuditUpdateDTM]
		   ,[strChildTableColumnName]
		   ,[EditorSettings]
		   )
     VALUES
          (
			19000065,
			'rftOwnershipType',
			'Farm Ownership Type',
			4,
			0,
			0,
			NEWID(),
			0,
			NULL,
			32,
			'Base Reference Editor',
			N'Add',
			N'EIDSS7 Resources', 
			10519002, 
			N'[{"idfsReferenceType":19000065}]',
			'System', 
			GETDATE(), 
			'System', 
			GETDATE(),
			'idfsOwnershipStructure',
			NULL
         )
END

IF NOT EXISTS (SELECT 1 FROM trtBaseReference WHERE idfsBaseReference = 10800000000)
BEGIN
	INSERT INTO [dbo].[trtBaseReference]
           ([idfsBaseReference]
           ,[idfsReferenceType]
           ,[strBaseReferenceCode]
           ,[strDefault]
           ,[intHACode]
           ,[intOrder]
           ,[blnSystem]
           ,[intRowStatus]
           ,[rowguid]
           ,[strMaintenanceFlag]
           ,[strReservedAttribute]
           ,[SourceSystemNameID]
           ,[SourceSystemKeyValue]
           ,[AuditCreateUser]
           ,[AuditCreateDTM]
           ,[AuditUpdateUser]
           ,[AuditUpdateDTM])
     VALUES
          (
			10800000000,
			19000065,
			'owtCollective',
			'Collective Farm',
			NULL,
			1,
			0,
			0,
			NEWID(),
			NULL,
			NULL, 
			10519002, 
			N'[{"idfsBaseReference":10800000000}]',
			'System', 
			GETDATE(), 
			'System', 
			GETDATE()
         )
END
GO

IF NOT EXISTS (SELECT 1 FROM trtBaseReference WHERE idfsBaseReference = 10810000000)
BEGIN
	INSERT INTO [dbo].[trtBaseReference]
           ([idfsBaseReference]
           ,[idfsReferenceType]
           ,[strBaseReferenceCode]
           ,[strDefault]
           ,[intHACode]
           ,[intOrder]
           ,[blnSystem]
           ,[intRowStatus]
           ,[rowguid]
           ,[strMaintenanceFlag]
           ,[strReservedAttribute]
           ,[SourceSystemNameID]
           ,[SourceSystemKeyValue]
           ,[AuditCreateUser]
           ,[AuditCreateDTM]
           ,[AuditUpdateUser]
           ,[AuditUpdateDTM])
     VALUES
          (
			10810000000,
			19000065,
			'owtPrivate',
			'Private Farm',
			NULL,
			0,
			0,
			0,
			NEWID(),
			NULL,
			NULL, 
			10519002, 
			N'[{"idfsBaseReference":10810000000}]',
			'System', 
			GETDATE(), 
			'System', 
			GETDATE()
         )
END
GO

IF NOT EXISTS (SELECT 1 FROM trtBaseReference WHERE idfsBaseReference = 10820000000)
BEGIN
	INSERT INTO [dbo].[trtBaseReference]
           ([idfsBaseReference]
           ,[idfsReferenceType]
           ,[strBaseReferenceCode]
           ,[strDefault]
           ,[intHACode]
           ,[intOrder]
           ,[blnSystem]
           ,[intRowStatus]
           ,[rowguid]
           ,[strMaintenanceFlag]
           ,[strReservedAttribute]
           ,[SourceSystemNameID]
           ,[SourceSystemKeyValue]
           ,[AuditCreateUser]
           ,[AuditCreateDTM]
           ,[AuditUpdateUser]
           ,[AuditUpdateDTM])
     VALUES
          (
			10820000000,
			19000065,
			'owtState',
			'State Farm',
			NULL,
			2,
			0,
			0,
			NEWID(),
			NULL,
			NULL, 
			10519002, 
			N'[{"idfsBaseReference":10820000000}]',
			'System', 
			GETDATE(), 
			'System', 
			GETDATE()
         )
END
GO

