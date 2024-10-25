/*Author:        Stephen Long
Date:            03/21/2023
Description:     Update duplicate Not an Outbreak base reference records to inactive for 5926.
*/
UPDATE dbo.trtStringNameTranslation 
SET intRowStatus = 1, AuditUpdateDTM = GETDATE(), AuditUpdateUser = 'System' 
WHERE idfsBaseReference IN (10274790001100, 13646170001100, 55459240000000);

UPDATE dbo.trtBaseReference 
SET intRowStatus = 1, AuditUpdateDTM = GETDATE(), AuditUpdateUser = 'System' 
WHERE idfsBaseReference IN (10274790001100, 13646170001100, 55459240000000);

UPDATE dbo.trtBaseReference SET intRowStatus = 0, AuditUpdateDTM = GETDATE(), AuditUpdateUser = 'System' 
WHERE idfsBaseReference IN (10063501, 10063502)