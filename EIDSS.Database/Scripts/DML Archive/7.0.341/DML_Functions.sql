
--------------------------------------------------------------------------------------------------------------------------------
-- DML_Functions.sql
-- 
-- This script will create either insert or update the translations for the resource 3923 'Functions'
-- to 'ფუნქციები'
--
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Mark Wilson      27-Mar-2023 Initial release.
--
--------------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 3923 AND idfsLanguage = 10049004)
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
		3923,
		10049004,
		N'ფუნქციები',
		0,
		NEWID(),
		10519001,
		N'[{"idfsResource":3923,"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

	)

END
ELSE
UPDATE dbo.trtResourceTranslation
SET strResourceString = N'ფუნქციები',
	intRowStatus = 0,
	SourceSystemNameID = 10519001,
	SourceSystemKeyValue = N'[{"idfsResource":3923,"idfsLanguage":10049004}]'
WHERE idfsResource = 3923
AND idfsLanguage = 10049004