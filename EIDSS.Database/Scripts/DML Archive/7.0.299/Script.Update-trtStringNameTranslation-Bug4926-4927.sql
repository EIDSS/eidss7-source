/*
Author:			Stephen Long
Date:			10/11/2022
Description:	Update record in trtStringNameTranslation for Avian and Livestock to be Veterinary Active Surveillance
                Session to be inline with the use case.
Note:           -Be sure the record exists in table
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF EXISTS (SELECT 1 FROM trtStringNameTranslation WHERE idfsBaseReference = 10502002 AND idfsLanguage = 10049003)
BEGIN
    UPDATE trtStringNameTranslation 
    SET strTextString = 'Veterinary Active Surveillance Session', AuditUpdateDTM = GETDATE() 
    WHERE idfsBaseReference = 10502002 AND idfsLanguage = 10049003
END
GO

IF EXISTS (SELECT 1 FROM trtStringNameTranslation WHERE idfsBaseReference = 10502009 AND idfsLanguage = 10049003)
BEGIN
    UPDATE trtStringNameTranslation 
    SET strTextString = 'Veterinary Active Surveillance Session', AuditUpdateDTM = GETDATE() 
    WHERE idfsBaseReference = 10502009 AND idfsLanguage = 10049003
END
GO