/*
Author:			Stephen Long
Date:			05/02/2023
Description:	Correct resource translation for Azeri - Samples and Penside Tests.
Note:           -Be sure the record exists in table
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 2460 AND idfsLanguage = 10049001)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(2460,10049001,N'Təcili testlər', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":2460,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END
ELSE
BEGIN
    UPDATE dbo.trtResourceTranslation SET strResourceString = N'Təcili testlər', AuditUpdateDTM = GETDATE() WHERE idfsLanguage = 10049001 AND idfsResource = 2460
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 664 AND idfsLanguage = 10049001)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(664,10049001,N'Nümunələr', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":664,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END
ELSE
BEGIN
    UPDATE dbo.trtResourceTranslation SET strResourceString = N'Nümunələr', AuditUpdateDTM = GETDATE() WHERE idfsLanguage = 10049001 AND idfsResource = 664
END
