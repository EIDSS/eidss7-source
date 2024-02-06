/*
Author:			Stephen Long
Date:			05/02/2023
Description:	Add resource translation for Azeri and Arabic for Add Avian and Add Livestock and Return to Farm.
Note:           -Be sure the record exists in table
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 3259 AND idfsLanguage = 10049001)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3259,10049001,N'Qaramal xəstəliyi hadisəsini əlavə et', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3259,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 3260 AND idfsLanguage = 10049001)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3260,10049001,N'Quş xəstəliyi hadisəsini əlavə et', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3260,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 3259 AND idfsLanguage = 10049011)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3259,10049011,N'أضف الحيوانات الزراعية/ أضف الماشية', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3259,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 3260 AND idfsLanguage = 10049011)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3260,10049011,N'أضف الطيور', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3260,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 3186 AND idfsLanguage = 10049001)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3186,10049001,N'Fermaya qayıt', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3186,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END
ELSE
BEGIN
    UPDATE dbo.trtResourceTranslation SET strResourceString = N'Fermaya qayıt', AuditUpdateDTM = GETDATE() WHERE idfsLanguage = 10049001 AND idfsResource = 3186
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 3186 AND idfsLanguage = 10049011)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3186,10049011,N'العودة الى الحقل/ المزرعة', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3186,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END
ELSE
BEGIN
    UPDATE dbo.trtResourceTranslation SET strResourceString = N'العودة الى الحقل/ المزرعة', AuditUpdateDTM = GETDATE() WHERE idfsLanguage = 10049011 AND idfsResource = 3186
END
