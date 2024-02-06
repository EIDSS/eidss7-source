

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10067010 AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
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
		10067010,
		dbo.FN_GBL_LanguageCode_GET('ka-GE'),
		N'სულ',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":10067010,"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

	)
END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'სულ',
		intRowStatus = 0,
		AuditUpdateUser = N'System',
		AuditUpdateDTM = GETDATE(),
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = N'[{"idfsBaseReference":10067010,"idfsLanguage":10049004}]'
	WHERE idfsBaseReference = 10067010 
	AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

END

