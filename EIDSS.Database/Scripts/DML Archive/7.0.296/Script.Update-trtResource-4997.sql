/*
Author:			Stephen Long
Date:			10/03/2022
Description:	Correcting resource string for LUC12 - edit test use case, and bad data for tests in 
                preliminary status with no result date.
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

BEGIN
    UPDATE trtResource 
    SET strResourceName = N'Result Date must be on or after Test Started Date' 
    WHERE idfsResource = 4413
END
GO

BEGIN
    UPDATE tlbTesting 
    SET datConcludedDate = GETDATE(), AuditUpdateUser = 'longs', AuditUpdateDTM = GETDATE() 
    WHERE intRowStatus = 0 and idfsTestStatus = 10001004 AND datConcludedDate IS NULL
END
GO