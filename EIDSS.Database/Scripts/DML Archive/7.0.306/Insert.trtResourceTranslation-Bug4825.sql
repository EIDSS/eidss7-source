/*
Author:			Stephen Long
Date:			10/22/2022
Description:	Update trtResourceTranslation for validation messages for laboratory module - testing tab.  DevOps item 4825.

*/
IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4496)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4496,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4496,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4496,10049001,N'"Testin nəticəsi" sahəsinin dolurulması mütləqdir', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4496,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4496,10049004,N'ტესტის შედეგი არის სავალდებულო ველი ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4496,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4497)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4497,10049011,N'تاريخ النتيجة مطلوب', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4497,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4497,10049001,N'"Nəticənin tarixi" sahəsinin doldurulması mütləqdir', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4497,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4497,10049004,N'შედეგის თარიღი არის სავალდებულო ველი.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4497,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4498)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4498,10049011,N'يجب أن يكون تاريخ النتيجة سابقًا أو مساويًا للتاريخ الحالي', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4498,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4498,10049001,N'Nəticənin tarixi cari tarix ilə eyni və ya ondan əvvəl olmalıdır ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4498,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4498,10049004,N'შედეგის თარიღი უნდა იყოს უფრო ადრე ან იგივე, რაც ამჟამინდელი თარიღი.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4498,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END
GO