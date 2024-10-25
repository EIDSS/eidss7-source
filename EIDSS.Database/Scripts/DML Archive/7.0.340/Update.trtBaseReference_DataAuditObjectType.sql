/*Author:        Stephen Long
Date:            03/17/2023
Description:     Disable v6.1 data audit object type.
*/
UPDATE dbo.trtBaseReference SET intRowStatus = 1, AuditUpdateUser = 'LongS', AuditUpdateDTM = GETDATE() WHERE idfsBaseReference = 10017006
UPDATE dbo.trtStringNameTranslation SET intRowStatus = 1, AuditUpdateUser = 'LongS', AuditUpdateDTM = GETDATE() WHERE idfsBaseReference = 10017006