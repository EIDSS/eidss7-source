/*
Author:			Stephen Long
Date:			04/27/2023
Description:	Add resource translation for Day for Azeri and Arabic.
Note:           -Be sure the record exists in table
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 937 AND idfsLanguage = 10049001)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'Gün' WHERE idfsResource = 937 AND idfsLanguage = 10049001
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(937,10049001,N'Gün', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":937,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 937 AND idfsLanguage = 10049011)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'يوم' WHERE idfsResource = 937 AND idfsLanguage = 10049011
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(937,10049011,N'يوم', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":937,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 759 AND idfsLanguage = 10049001)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'Xəstəlik matriksi' WHERE idfsResource = 759 AND idfsLanguage = 10049001
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(759,10049001,N'Xəstəlik matriksi', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":759,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 759 AND idfsLanguage = 10049011)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'معرف الحملة' WHERE idfsResource = 759 AND idfsLanguage = 10049011
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(759,10049011,N'معرف الحملة', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":759,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END
