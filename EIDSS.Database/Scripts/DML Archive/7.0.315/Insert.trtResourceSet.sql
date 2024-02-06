/*
Author:			Doug Albanese
Date:			11/18/2022
Description:	Creation of a new Resource Set used by the "Export to CISID" module

*/

IF NOT EXISTS (SELECT 1 FROM trtResourceSet WHERE idfsResourceSet = 445)
BEGIN

	INSERT INTO trtResourceSet (idfsResourceSet,strResourceSet, strResourceSetUnique, intRowStatus, rowguid, strMaintenanceFlag, strReservedAttribute, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (445, 'Export To CISID', 'Export To CISID', 0, '741BD3B2-5150-4A0A-B99F-591D7B1864E3', 'ADD', 'EIDSS7 Resource Sets', 10519001, '[{"idfsResourceSet":445}]', 'dalbanese', GETDATE(), 'dalbanese', GETDATE())
END