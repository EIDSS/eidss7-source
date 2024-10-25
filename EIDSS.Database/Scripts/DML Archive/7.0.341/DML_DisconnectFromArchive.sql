
--------------------------------------------------------------------------------------------------------------------------------
-- DML_DisconnectFromArchive.sql
-- 
-- This script will create either insert or update the translations for the resource 3623 'Connect to archive'
-- to 'არქივიდან გათიშვა'
--
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Mark Wilson      27-Mar-2023 Initial release.
--
--------------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 3623 AND idfsLanguage = 10049004)
BEGIN
	INSERT INTO dbo.trtResourceTranslation
	(
		idfsResource,
		idfsLanguage,
		strResourceString,
		intRowStatus,
		rowguid,
		SourceSystemNameID,
		SourceSystemKeyValue,
		AuditCreateUser,
		AuditCreateDTM

	)
	VALUES
	(
		3623,
		10049004,
		N'არქივიდან გათიშვა',
		0,
		NEWID(),
		10519001,
		N'[{"idfsResource":3623,"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

	)

END
ELSE
UPDATE dbo.trtResourceTranslation
SET strResourceString = N'არქივიდან გათიშვა',
	intRowStatus = 0,
	SourceSystemNameID = 10519001,
	SourceSystemKeyValue = N'[{"idfsResource":3623,"idfsLanguage":10049004}]'
WHERE idfsResource = 3623
AND idfsLanguage = 10049004