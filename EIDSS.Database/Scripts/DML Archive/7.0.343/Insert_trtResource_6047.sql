/*
Author:        	Mike Kornegay
Date:           04/04/2023	
Description:    Create resources for defect 6047 - required fields on farm.
*/

IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4799)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4799,N'Region, rayon, and settlement (if shown) are required when farm owner is left blank.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4799}]','System', GETDATE(), 'System', GETDATE(), 10540006)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4799 AND idfsResourceSet = 41)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (41,4799,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":41,"idfsResource":4799}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4799)
BEGIN
  
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4799,10049004,N'რეგიონი, რაიონი და დასახლება (თუ ნაჩვენებია) საჭიროა, როდესაც ფერმის მფლობელი ცარიელი დარჩა.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4799,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())

END

IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4800)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4800,N'Street is required when farm owner and farm name are left blank.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4800}]','System', GETDATE(), 'System', GETDATE(), 10540006)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4800 AND idfsResourceSet = 41)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (41,4800,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":41,"idfsResource":4800}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4800)
BEGIN
  
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4800,10049004,N'ქუჩა საჭიროა, როდესაც ფერმის მფლობელი და ფერმის სახელი ცარიელი დარჩა.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4800,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())

END

