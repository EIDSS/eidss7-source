/*Author:        Stephen Long
Date:            03/27/2023
Description:     Create resources for SUAC51 - security policy.
*/
IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4789)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4789,N'Passwords must be at least {0} characters',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4789}]','System', GETDATE(), 'System', GETDATE(), 10540003)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4790)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4790,N'Passwords must have at least one lowercase (''a''-''z'')',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4790}]','System', GETDATE(), 'System', GETDATE(), 10540003)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4791)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4791,N'Passwords must have at least one uppercase (''A''-''Z'')',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4791}]','System', GETDATE(), 'System', GETDATE(), 10540003)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4792)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4792,N'Passwords must have at least one special char {0}',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4792}]','System', GETDATE(), 'System', GETDATE(), 10540003)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4793)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4793,N'Passwords must not contain {0} sequential characters',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4793}]','System', GETDATE(), 'System', GETDATE(), 10540003)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4794)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4794,N'Passwords must not space',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4794}]','System', GETDATE(), 'System', GETDATE(), 10540003)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4795)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4795,N'Prevent use of the username as the password',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4795}]','System', GETDATE(), 'System', GETDATE(), 10540003)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4789 AND idfsResourceSet = 221)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (221,4789,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":221,"idfsResource":4789}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4790 AND idfsResourceSet = 221)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (221,4790,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":221,"idfsResource":4790}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4791 AND idfsResourceSet = 221)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (221,4791,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":221,"idfsResource":4791}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4792 AND idfsResourceSet = 221)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (221,4792,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":221,"idfsResource":4792}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4793 AND idfsResourceSet = 221)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (221,4793,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":221,"idfsResource":4793}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4794 AND idfsResourceSet = 221)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (221,4794,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":221,"idfsResource":4794}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4795 AND idfsResourceSet = 221)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (221,4795,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":221,"idfsResource":4795}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4789)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4789,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4789,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4789,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4789,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4789,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4789,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4790)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4790,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4790,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4790,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4790,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4790,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4790,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4791)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4791,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4791,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4791,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4791,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4791,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4791,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4792)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4792,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4792,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4792,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4792,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4792,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4792,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4793)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4793,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4793,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4793,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4793,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4793,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4793,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4794)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4794,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4794,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4794,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4794,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4794,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4794,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4795)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4795,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4795,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4795,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4795,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4795,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4795,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4796)
BEGIN
	INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
	VALUES (4796,N'Passwords must have at least one digit (''0''-''9'')',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4796}]','System', GETDATE(), 'System', GETDATE(), 10540003)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4796 AND idfsResourceSet = 221)
BEGIN
	INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
	VALUES (221,4796,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":221,"idfsResource":4796}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4796)
BEGIN
	INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
	VALUES(4796,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4796,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
	INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
	VALUES(4796,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4796,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
	INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
	VALUES(4796,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4796,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END