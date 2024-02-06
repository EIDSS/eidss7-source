
--------------------------------------------------------------------------------------------------------------------------
--
-- this script will either insert or update the Georgian translation for base reference Employee types User and Non-User
--
--------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM  dbo.trtStringNameTranslation WHERE idfsBaseReference = 10526001 AND idfsLanguage = 10049004)
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
		10526001,
		10049004,
		N'მომხმარებელი',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":10526001,"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

	)

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'მომხმარებელი',
		intRowStatus = 0
	WHERE idfsBaseReference = 10526001 
	AND idfsLanguage = 10049004

END

GO


IF NOT EXISTS (SELECT * FROM  dbo.trtStringNameTranslation WHERE idfsBaseReference = 10526002 AND idfsLanguage = 10049004)
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
		10526002,
		10049004,
		N'არ არის მომხმარებელი',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":10526002,"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

	)

END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'არ არის მომხმარებელი',
		intRowStatus = 0
	WHERE idfsBaseReference = 10526002 
	AND idfsLanguage = 10049004

END