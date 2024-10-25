/*
Author:			Stephen Long
Date:			01/05/2023
Description:	Activate the default employee group as required for SAUC29 and disease permissions.
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF EXISTS (SELECT 1 FROM trtBaseReference WHERE idfsBaseReference = -506 AND intRowStatus = 1)
BEGIN
    UPDATE trtBaseReference SET intRowStatus = 0, blnSystem = 1, AuditUpdateDTM = GETDATE(), AuditUpdateUser = 'System' WHERE idfsBaseReference = -506
END

IF EXISTS (SELECT 1 FROM tlbEmployeeGroup WHERE idfEmployeeGroup = -506 AND intRowStatus = 1)
BEGIN
    UPDATE tlbEmployeeGroup SET intRowStatus = 0, AuditUpdateDTM = GETDATE(), AuditUpdateUser = 'System' WHERE idfEmployeeGroup = -506
END

GO