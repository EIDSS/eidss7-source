
--------------------------------------------------------------------------------------------------------------------------------
-- DML_Update_Farm_Translation.sql
-- 
-- This script will remove ' ID' from and Farm GG Translation
--
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Mark Wilson      27-Mar-2023 Initial release.
--
--------------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10506025 AND idfsLanguage = 10049004)
BEGIN
	INSERT INTO dbo.trtStringNameTranslation
	(
	    idfsBaseReference,
	    idfsLanguage,
	    strTextString,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM
	)
	VALUES
	(   
		10506025,
		10049004,
		N'ფერმის',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":10506025,"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

	)

END
ELSE
UPDATE dbo.trtStringNameTranslation
SET strTextString = N'ფერმის',
	intRowStatus = 0,
	SourceSystemNameID = 10519001,
	SourceSystemKeyValue = N'[{"idfsResource":10506025,"idfsLanguage":10049004}]'
WHERE idfsBaseReference = 10506025
AND idfsLanguage = 10049004

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10506115 AND idfsLanguage = 10049004)
BEGIN
	INSERT INTO dbo.trtStringNameTranslation
	(
	    idfsBaseReference,
	    idfsLanguage,
	    strTextString,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM
	)
	VALUES
	(   
		10506115,
		10049004,
		N'ფერმის',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":10506115,"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

	)

END
ELSE
UPDATE dbo.trtStringNameTranslation
SET strTextString = N'ფერმის',
	intRowStatus = 0,
	SourceSystemNameID = 10519001,
	SourceSystemKeyValue = N'[{"idfsResource":10506115,"idfsLanguage":10049004}]'
WHERE idfsBaseReference = 10506115
AND idfsLanguage = 10049004

