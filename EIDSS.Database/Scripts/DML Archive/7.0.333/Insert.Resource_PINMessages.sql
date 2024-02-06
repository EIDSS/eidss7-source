/*
Author:			Stephen Long
Date:			02/13/2023
Description:	Add PIN messages.
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/
IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 4754)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4754,N'According to the search criteria no records found. Please update search criteria and try to find person again.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4754}]','System', GETDATE(), 'System', GETDATE(), 10540006)
END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 4755)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4755,N'Civil Registry Service is not responding. Please try to find the person later” in current language.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4755}]','System', GETDATE(), 'System', GETDATE(), 10540006)
END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 4754 AND idfsResourceSet = 193)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (193,4754,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":193,"idfsResource":4754}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 4755 AND idfsResourceSet = 193)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (193,4755,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":193,"idfsResource":4755}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4754 and idfsLanguage = 10049011)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4754,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4754,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4754 and idfsLanguage = 10049001)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4754,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4754,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4754 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4754,10049004,N'ძებნის მოცემული პარამეტრბით ჩანაწერი არ მოიძებნა. შეცვალეთ ძებნის პარამეტრები და ხელახლა სცადეთ ძებნის განხორციელება.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4754,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4755 and idfsLanguage = 10049011)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4755,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4755,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4755 and idfsLanguage = 10049001)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4755,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4755,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4755 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4755,10049004,N'სამოქალაქო რეესტრის სერვისი მიუწვდომელია. სცადეთ მოგვიანებით.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4755,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

GO