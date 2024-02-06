/*
Author:			Stephen Long
Date:			09/26/2022
Description:	Add field label resource for the laboratory module edit sample use case. 
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 854 AND idfsResourceSet = 368)
BEGIN
    INSERT INTO trtResourceSetToResource (idfsResourceSet, idfsResource, isHidden, isRequired, intRowStatus, strMaintenanceFlag, strReservedAttribute, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM) 
    VALUES (368, 854, 0, 0, 0, 'Add', 'Resource Set To Resource', 10519001, '[{"idfsResourceSet":368,"idfsResource":854}]', 'System', GETDATE(), 'System', GETDATE());
END
GO


