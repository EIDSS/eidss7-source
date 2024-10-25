/*
	This needs to be ran on the master DB.

	In addition, this needs to be applied to all existing DBs
*/

IF NOT EXISTS(SELECT idfsBaseReference FROM trtStringNameTranslation WHERE idfsBaseReference = 10019001 and idfsLanguage = 10049003)
   BEGIN
	  INSERT INTO trtStringNameTranslation (idfsBaseReference, idfsLanguage, strTextString, intRowStatus, rowguid, strMaintenanceFlag, strReservedAttribute, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM)
		 VALUES (10019001, 10049003, N'ILI',0,NEWID(), NULL, NULL, 10519001, '[{"idfsBaseReference":10019001 , "idfsLanguage":10049003}]', 'Administrator', GETDATE())
   END

IF NOT EXISTS(SELECT idfsBaseReference FROM trtStringNameTranslation WHERE idfsBaseReference = 10019002  and idfsLanguage = 10049003)
   BEGIN
	  INSERT INTO trtStringNameTranslation (idfsBaseReference, idfsLanguage, strTextString, intRowStatus, rowguid, strMaintenanceFlag, strReservedAttribute, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM)
		 VALUES (10019002, 10049003, N'SARD',0,NEWID(), NULL, NULL, 10519001, '[{"idfsBaseReference":10019002 , "idfsLanguage":10049003}]', 'Administrator', GETDATE())
   END
