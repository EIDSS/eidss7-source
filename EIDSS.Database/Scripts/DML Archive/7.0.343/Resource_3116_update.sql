

IF NOT EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 3116 AND idfsLanguage = 10049004)
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
	
	SELECT
		3116,
		10049004,
		N'თქვენ წარმატებით შექმენით ახალი დაავადების ანგარიში დზეის-ის სისტემაში. დზეის-ის  ID არის {0}',
		0,
		NEWID(),
		10519001,
		N'[{"idfsResource":3116,"idfsLanguage":10049004}]',
		N'System',
		GETDATE()

END
ELSE
UPDATE dbo.trtResourceTranslation
SET strResourceString = N'თქვენ წარმატებით შექმენით ახალი დაავადების ანგარიში დზეის-ის სისტემაში. დზეის-ის  ID არის {0}',
	AuditUpdateUser = 'System',
	AuditUpdateDTM = GETDATE(),
	SourceSystemNameID = 10519001,
	SourceSystemKeyValue = N'[{"idfsResource":3116,"idfsLanguage":10049004}]'
WHERE idfsResource = 3116 AND idfsLanguage = 10049004

