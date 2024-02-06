/*
Author:			Stephen Long
Date:			10/11/2022
Description:	Update record in trtBaseReference for Avian and Livestock to be Veterinary Active Surveillance
                Session to be inline with the use case.
Note:           -Be sure the record exists in table
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF EXISTS (SELECT 1 FROM trtBaseReference WHERE idfsBaseReference = 10502002)
BEGIN
    UPDATE trtBaseReference SET strDefault = 'Veterinary Active Surveillance Session', AuditUpdateDTM = GETDATE() 
    WHERE idfsBaseReference = 10502002
END
GO

IF EXISTS (SELECT 1 FROM trtBaseReference WHERE idfsBaseReference = 10502009)
BEGIN
    UPDATE trtBaseReference SET strDefault = 'Veterinary Active Surveillance Session', AuditUpdateDTM = GETDATE() 
    WHERE idfsBaseReference = 10502009
END
GO