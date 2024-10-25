--------------------------------------------------------------------------------------------------------------------------------
-- Name: GG_Role_Translations.sql
--
-- this script creates or updates translations for the GG specific roles
--
--          
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Mark Wilson      21-Mar-2023 Initial release.
--
--------------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -529 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-529,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'დირექტორი (ვეტ)',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-529 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()
END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'დირექტორი (ვეტ)'
	WHERE idfsBaseReference = -529 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -528 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-528,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'დირექტორი (ჯანდაცვა)',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-528 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'დირექტორი (ჯანდაცვა)'
	WHERE idfsBaseReference = -528 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -527 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-527,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'საყრდენი ბაზებით ზედამხედველობის სპეციალისტი',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-527 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'საყრდენი ბაზებით ზედამხედველობის სპეციალისტი'
	WHERE idfsBaseReference = -527 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END


IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -526 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-526,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'ფორმა 03-ის ხელმომწერნი',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-526 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'ფორმა 03-ის ხელმომწერნი'
	WHERE idfsBaseReference = -526 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -525 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-525,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'სურსათის უვნებლობის სპეციალისტი',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-525 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'სურსათის უვნებლობის სპეციალისტი'
	WHERE idfsBaseReference = -525 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -524 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
SELECT
	-524,
	dbo.FN_GBL_LanguageCode_GET('ka-GE'),
	N'ზოო ენტომოლოგი (ვეტ)',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":' + CAST(-524 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
	N'System',
	GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'ზოო ენტომოლოგი (ვეტ)'
	WHERE idfsBaseReference = -524 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -523 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
SELECT
	-523,
	dbo.FN_GBL_LanguageCode_GET('ka-GE'),
	N'ზოო ენტომოლოგი (ჯანდაცვა)',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":' + CAST(-523 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
	N'System',
	GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'ზოო ენტომოლოგი (ჯანდაცვა)'
	WHERE idfsBaseReference = -523 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -522 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
SELECT
	-522,
	dbo.FN_GBL_LanguageCode_GET('ka-GE'),
	N'ლაბორანტი (ვეტ)',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":' + CAST(-522 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
	N'System',
	GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'ლაბორანტი (ვეტ)'
	WHERE idfsBaseReference = -522 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -521 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-521,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'ლაბორანტი (ჯანდაცვა)',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-521 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'ლაბორანტი (ჯანდაცვა)'
	WHERE idfsBaseReference = -521 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END
IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -520 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-520,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'ეპიზოოტოლოგი',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-520 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'ეპიზოოტოლოგი'
	WHERE idfsBaseReference = -520 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END


IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -519 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-519,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'ეპიდემიოლოგი',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-519 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'ეპიდემიოლოგი'
	WHERE idfsBaseReference = -519 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END


IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -518 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-518,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'ლაბორატორიის უფროსი (ვეტ)',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-518 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'ლაბორატორიის უფროსი (ვეტ)'
	WHERE idfsBaseReference = -518 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END


IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -517 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-517,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'ლაბორატორიის უფროსი (ჯანდაცვა)',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-517 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'ლაბორატორიის უფროსი (ჯანდაცვა)'
	WHERE idfsBaseReference = -517 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END


IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -516 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-516,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'უფროსი ეპიზოოტოლოგი',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-516 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'უფროსი ეპიზოოტოლოგი'
	WHERE idfsBaseReference = -516 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -515 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-515,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'უფროსი ეპიდემიოლოგი',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-515 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()
END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'უფროსი ეპიზოოტოლოგი'
	WHERE idfsBaseReference = -515 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -514 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-514,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'ადმინისტრატორი (ვეტ)',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-514 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'ადმინისტრატორი (ვეტ)'
	WHERE idfsBaseReference = -514 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -513 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-513,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'ადმინისტრატორი (ჯანდაცვა)',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-513 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()
END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'ადმინისტრატორი (ჯანდაცვა)'
	WHERE idfsBaseReference = -513 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = -506 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
	SELECT
		-506,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'ნაგულისხმევი ჯგუფი',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":' + CAST(-506 AS NVARCHAR(24)) + N',"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'ნაგულისხმევი ჯგუფი'
	WHERE idfsBaseReference = -506 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END
