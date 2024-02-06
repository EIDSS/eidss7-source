/*
Author:			Mark Wilson
Date:			12/9/2022
Description:	Update resource 929 for Geogian language.
*/

UPDATE dbo.trtResourceTranslation
SET strResourceString = N'ადამიანის საერთო დაავადების ანგარიში',
    AuditUpdateUser = N'System',
    AuditUpdateDTM = GETDATE()
WHERE idfsResource = 929 AND idfsLanguage = 10049004
GO