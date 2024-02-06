/*
Author:			Stephen Long
Date:			05/01/2023
Description:	Add resource translation for veterinary aggregate action summary tab headers.
Note:           -Be sure the record exists in table
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4804)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4804,N'Diagnostic investigations',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4804}]','System', GETDATE(), 'System', GETDATE(), 10540004)
END
IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4805)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4805,N'Treatment-prophylactic and vaccination measures',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4805}]','System', GETDATE(), 'System', GETDATE(), 10540004)
END
IF NOT EXISTS (SELECT * FROM dbo.trtResource WHERE idfsResource = 4806)
BEGIN
    INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
    VALUES (4806,N'Veterinary-sanitary measures',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4806}]','System', GETDATE(), 'System', GETDATE(), 10540004)
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4804 AND idfsResourceSet = 20)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (20,4804,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":20,"idfsResource":4804}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4805 AND idfsResourceSet = 20)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (20,4805,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":20,"idfsResource":4805}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResource = 4806 AND idfsResourceSet = 20)
BEGIN
    INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES (20,4806,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":20,"idfsResource":4806}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4804 AND idfsLanguage = 10049001)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4804,10049001,N'Dianostik tədqiqatlar', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4804,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4804 AND idfsLanguage = 10049006)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4804,10049006,N'Диагностические исследования', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4804,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4804 AND idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4804,10049004,N'სადიაგნოსტიკო კვლევები', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4804,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4804 AND idfsLanguage = 10049011)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4804,10049011,N'تحقيقات لتحديد التشخيص', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4804,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4805 AND idfsLanguage = 10049011)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4805,10049011,N'تدابير العلاج الوقائي والتطعيم', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4805,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4805 AND idfsLanguage = 10049001)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4805,10049001,N'Müalicə-profilaktik və peyvəndləmə tədbirləri', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4805,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4805 AND idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4805,10049004,N'სამკურნალო-პროფილაქტიკური ღონისძიებები და ვაქცინაცია', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4805,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4806 AND idfsLanguage = 10049011)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4806,10049011,N'الإجراءات البيطرية والصحية', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4806,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4806 AND idfsLanguage = 10049001)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4806,10049001,N'Baytarlıq-sanitariya tədbirləri', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4806,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
END
IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4806 AND idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4806,10049004,N'ვეტერინარულ-სანიტარული ღონისძიებები', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4806,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END