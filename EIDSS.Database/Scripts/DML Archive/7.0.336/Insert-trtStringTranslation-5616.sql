/*

This script must be fixed as "SEED" data for a migration, since this entry wasn't available...when the copy was perform over to the EIDSS 7 db.

*/

INSERT INTO trtStringNameTranslation (
   idfsBaseReference,
   idfsLanguage,
   strTextString,
   intRowStatus,
   rowguid,
   strMaintenanceFlag,
   strReservedAttribute,
   SourceSystemNameID,
   SourceSystemKeyValue,
   AuditCreateUser,
   AuditCreateDTM,
   AuditUpdateUser,
   AuditUpdateDTM
)
VALUES (
   19812230001101,
   10049003,
   'COVID-19',
   0,
   NEWID(),
   NULL,
   NULL,
   10519001,
   '[{"idfsBaseReference":19812230001101 , "idfsLanguage":10049003}]',
   'Administrator',
   GETDATE(),
   NULL,
   NULL
)