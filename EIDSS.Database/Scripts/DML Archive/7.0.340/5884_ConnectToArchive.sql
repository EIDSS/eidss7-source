

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10506213 and idfsLanguage = 10049004)
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
		10506213,
		10049004,
		N'არქივთან დაკავშირება',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":10506213,"idfsLanguage":10049004}]',
		N'System',
		GETDATE()
			)


END
ELSE
BEGIN
	UPDATE dbo.trtStringNameTranslation
	SET strTextString = N'არქივთან დაკავშირება',
		AuditUpdateDTM = GETDATE(),
		AuditUpdateUser = 'System'

	WHERE idfsBaseReference = 10506213 AND idfsLanguage = 10049004

END