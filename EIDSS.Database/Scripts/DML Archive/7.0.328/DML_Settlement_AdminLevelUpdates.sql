
-- For MSTR_Reference
-- INSERT INTO dbo.trtBaseReference
-- (
--     idfsBaseReference,
--     idfsReferenceType,
--     strBaseReferenceCode,
--     strDefault,
--     intOrder,
--     intRowStatus,
--     rowguid,
--     SourceSystemNameID,
--     SourceSystemKeyValue,
--     AuditCreateUser,
--     AuditCreateDTM,
--     change_type
-- )
-- VALUES
-- ( 
-- 	10003004,
-- 	19000003,
-- 	N'admSettlement',
-- 	N'Settlement',
-- 	0,
-- 	0,
-- 	NEWID(),
-- 	10519001,
-- 	N'[{"idfsBaseReference":10003004}]',
-- 	N'System',
-- 	GETDATE(),
-- 	N'ADD'
-- )

-- For deployed databases
IF NOT EXISTS (SELECT * FROM dbo.trtBaseReference WHERE idfsBaseReference = 10003004)
BEGIN

	INSERT INTO dbo.trtBaseReference
	(
		idfsBaseReference,
		idfsReferenceType,
		strBaseReferenceCode,
		strDefault,
		intOrder,
		intRowStatus,
		rowguid,
		SourceSystemNameID,
		SourceSystemKeyValue,
		AuditCreateUser,
		AuditCreateDTM
	)
	VALUES
	( 
		10003004,
		19000003,
		N'admSettlement',
		N'Settlement',
		0,
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":10003004}]',
		N'System',
		GETDATE()
	)
END

IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = 10003004 AND idfsLanguage = 10049004)
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
		10003004,
		10049004,
		N'დასახლების პუნქტი',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":10003004 , "idfsLanguage":10049004}]',
		N'System',
		GETDATE()
	)

END

