
--resource set hierarchy
IF NOT EXISTS (SELECT 1 FROM dbo.trtResourceSetHierarchy WHERE idfResourceHierarchy = 577 and idfsResourceSet = 445)
BEGIN
	INSERT INTO [dbo].[trtResourceSetHierarchy]
           ([idfResourceHierarchy]
           ,[idfsResourceSet]
           ,[ResourceSetNode]
           ,[intOrder]
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
           (577
           ,445
           ,0x87933B
           ,100
           ,0
           ,NEWID()
           ,'ADD'
           ,'EIDSS7 Resource Sets'
           ,10519001
           ,'[{"idfsResourceSet":[{"idfsResourceSet":577}]'
           ,'System'
           ,'2022-11-18 15:44:27.077'
           ,'dbo'
           ,'2022-11-18 15:44:27.077')
END
GO


--resource set
IF NOT EXISTS (SELECT 1 FROM dbo.trtResourceSet WHERE idfsResourceSet = 445)
BEGIN
INSERT INTO [dbo].[trtResourceSet]
           ([idfsResourceSet]
           ,[strResourceSet]
           ,[strResourceSetUnique]
           ,[intRowStatus]
           ,[rowguid]
           ,[strMaintenanceFlag]
           ,[strReservedAttribute]
           ,[SourceSystemNameID]
           ,[SourceSystemKeyValue]
           ,[AuditCreateUser]
           ,[AuditCreateDTM]
           ,[AuditUpdateUser]
           ,[AuditUpdateDTM]
           )
     VALUES
           (445
           ,'Export to CISID'
           ,'Export to CISID'
           ,0
           ,NEWID()
           ,'ADD'
           ,'EIDSS7 Resource Sets'
           ,10519001
           ,'[{"idfsResourceSet":445}]'
           ,'dalbanese'
           ,'2022-11-18 13:36:26.467'
           ,'dalbanese'
           ,'2022-11-18 13:36:26.467'
           )
END
GO