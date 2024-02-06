--Resourse Set
--4380
IF NOT EXISTS (select * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 170 AND idfsResource = 4380)
BEGIN
	INSERT INTO dbo.trtResourceSetToResource 
	(idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,canEdit)
	VALUES
	(170,4380,0,0,0,NEWID(),'Add','Resource Set To Resource',10519001,'[{"idfsResourceSet":170,"idfsResource":4380}]','System',GETDATE(),1)
END
--4381
IF NOT EXISTS (select * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 170 AND idfsResource = 4381)
BEGIN
	INSERT INTO dbo.trtResourceSetToResource 
	(idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,canEdit)
	VALUES
	(170,4381,0,0,0,NEWID(),'Add','Resource Set To Resource',10519001,'[{"idfsResourceSet":170,"idfsResource":4381}]','System',GETDATE(),1)
END
--4382
IF NOT EXISTS (select * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 170 AND idfsResource = 4382)
BEGIN
	INSERT INTO dbo.trtResourceSetToResource 
	(idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,canEdit)
	VALUES
	(170,4382,0,0,0,NEWID(),'Add','Resource Set To Resource',10519001,'[{"idfsResourceSet":170,"idfsResource":4382}]','System',GETDATE(),1)
END
--4383
IF NOT EXISTS (select * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 170 AND idfsResource = 4383)
BEGIN
	INSERT INTO dbo.trtResourceSetToResource 
	(idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,canEdit)
	VALUES
	(170,4383,0,0,0,NEWID(),'Add','Resource Set To Resource',10519001,'[{"idfsResourceSet":170,"idfsResource":4383}]','System',GETDATE(),1)
END
--4384
IF NOT EXISTS (select * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 170 AND idfsResource = 4384)
BEGIN
	INSERT INTO dbo.trtResourceSetToResource 
	(idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,canEdit)
	VALUES
	(170,4384,0,0,0,NEWID(),'Add','Resource Set To Resource',10519001,'[{"idfsResourceSet":170,"idfsResource":4384}]','System',GETDATE(),1)
END
--4385
IF NOT EXISTS (select * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 170 AND idfsResource = 4385)
BEGIN
	INSERT INTO dbo.trtResourceSetToResource 
	(idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,canEdit)
	VALUES
	(170,4385,0,0,0,NEWID(),'Add','Resource Set To Resource',10519001,'[{"idfsResourceSet":170,"idfsResource":4385}]','System',GETDATE(),1)
END
--4386
IF NOT EXISTS (select * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 170 AND idfsResource = 4386)
BEGIN
	INSERT INTO dbo.trtResourceSetToResource 
	(idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,canEdit)
	VALUES
	(170,4386,0,0,0,NEWID(),'Add','Resource Set To Resource',10519001,'[{"idfsResourceSet":170,"idfsResource":4386}]','System',GETDATE(),1)
END
--4387
IF NOT EXISTS (select * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 170 AND idfsResource = 4387)
BEGIN
	INSERT INTO dbo.trtResourceSetToResource 
	(idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,canEdit)
	VALUES
	(170,4387,0,0,0,NEWID(),'Add','Resource Set To Resource',10519001,'[{"idfsResourceSet":170,"idfsResource":4387}]','System',GETDATE(),1)
END

--Translations
--4385
IF NOT EXISTS (select * FROM dbo.trtResourceTranslation WHERE idfsResource = 4385 AND idfsLanguage = 10049001)
BEGIN
	INSERT INTO dbo.trtResourceTranslation 
	VALUES 
	('4385','10049001','[TBD]',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4385,"idfsLanguage":10049001}]','System',GETDATE(),NULL,NULL)
END
IF NOT EXISTS (select * FROM dbo.trtResourceTranslation WHERE idfsResource = 4385 AND idfsLanguage = 10049004)
BEGIN
	INSERT INTO dbo.trtResourceTranslation 
	VALUES 
	('4385','10049004','[TBD]',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4385,"idfsLanguage":10049001}]','System',GETDATE(),NULL,NULL)
END
IF NOT EXISTS (select * FROM dbo.trtResourceTranslation WHERE idfsResource = 4385 AND idfsLanguage = 10049006)
BEGIN
	INSERT INTO dbo.trtResourceTranslation 
	VALUES 
	('4385','10049006','[TBD]',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4385,"idfsLanguage":10049001}]','System',GETDATE(),NULL,NULL)
END
IF NOT EXISTS (select * FROM dbo.trtResourceTranslation WHERE idfsResource = 4385 AND idfsLanguage = 10049011)
BEGIN
	INSERT INTO dbo.trtResourceTranslation 
	VALUES 
	('4385','10049011','[TBD]',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4385,"idfsLanguage":10049001}]','System',GETDATE(),NULL,NULL)
END
--4386
IF NOT EXISTS (select * FROM dbo.trtResourceTranslation WHERE idfsResource = 4386 AND idfsLanguage = 10049001)
BEGIN
	INSERT INTO dbo.trtResourceTranslation 
	VALUES 
	('4386','10049001','[TBD]',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4386,"idfsLanguage":10049001}]','System',GETDATE(),NULL,NULL)
END
IF NOT EXISTS (select * FROM dbo.trtResourceTranslation WHERE idfsResource = 4386 AND idfsLanguage = 10049004)
BEGIN
	INSERT INTO dbo.trtResourceTranslation 
	VALUES 
	('4386','10049004','[TBD]',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4386,"idfsLanguage":10049001}]','System',GETDATE(),NULL,NULL)
END
IF NOT EXISTS (select * FROM dbo.trtResourceTranslation WHERE idfsResource = 4386 AND idfsLanguage = 10049006)
BEGIN
	INSERT INTO dbo.trtResourceTranslation 
	VALUES 
	('4386','10049006','[TBD]',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4386,"idfsLanguage":10049001}]','System',GETDATE(),NULL,NULL)
END
IF NOT EXISTS (select * FROM dbo.trtResourceTranslation WHERE idfsResource = 4386 AND idfsLanguage = 10049011)
BEGIN
	INSERT INTO dbo.trtResourceTranslation 
	VALUES 
	('4386','10049011','[TBD]',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4386,"idfsLanguage":10049001}]','System',GETDATE(),NULL,NULL)
END
--4387
IF NOT EXISTS (select * FROM dbo.trtResourceTranslation WHERE idfsResource = 4387 AND idfsLanguage = 10049001)
BEGIN
	INSERT INTO dbo.trtResourceTranslation 
	VALUES 
	('4387','10049001','[TBD]',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4387,"idfsLanguage":10049001}]','System',GETDATE(),NULL,NULL)
END
IF NOT EXISTS (select * FROM dbo.trtResourceTranslation WHERE idfsResource = 4387 AND idfsLanguage = 10049004)
BEGIN
	INSERT INTO dbo.trtResourceTranslation 
	VALUES 
	('4387','10049004','[TBD]',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4387,"idfsLanguage":10049001}]','System',GETDATE(),NULL,NULL)
END
IF NOT EXISTS (select * FROM dbo.trtResourceTranslation WHERE idfsResource = 4387 AND idfsLanguage = 10049006)
BEGIN
	INSERT INTO dbo.trtResourceTranslation 
	VALUES 
	('4387','10049006','[TBD]',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4387,"idfsLanguage":10049001}]','System',GETDATE(),NULL,NULL)
END
IF NOT EXISTS (select * FROM dbo.trtResourceTranslation WHERE idfsResource = 4387 AND idfsLanguage = 10049011)
BEGIN
	INSERT INTO dbo.trtResourceTranslation 
	VALUES 
	('4387','10049011','[TBD]',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4387,"idfsLanguage":10049001}]','System',GETDATE(),NULL,NULL)
END