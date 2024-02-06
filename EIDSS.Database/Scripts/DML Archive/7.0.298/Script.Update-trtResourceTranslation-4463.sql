/*
Author:			Stephen Long
Date:			10/07/2022
Description:	Update record in trtResourceTranslation for The record is deleted successfully for Georgian
                language.
Note:           -Be sure the record exists in table
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsLanguage = 10049004 AND idfsResource = 219)
BEGIN
    UPDATE trtResourceTranslation 
    SET strResourceString = N'ჩანაწერი წაშლილია წარმატებით.', AuditUpdateDTM = GETDATE() 
    WHERE idfsLanguage = 10049004 AND idfsResource = 219
END
GO
