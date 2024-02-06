/*
Author:			Stephen Long
Date:			09/28/2022
Description:	Add heading resource for the SAUC60 - system event log use case. 
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4495)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4495,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4495,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4495,10049001,N'Hadisələr jurnalı', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4495,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4495,10049004,N'სიტემის მოვლენეის ჟურნალი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4495,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END
GO