/*
Author:			Stephen Long
Date:			05/08/2023
Description:	Add resource translation for Azeri Legacy ID.
Note:           -Be sure the record exists in table
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 936 AND idfsLanguage = 10049001)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(936,10049001,N'Legacy ID', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":936,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
END
