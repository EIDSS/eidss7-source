

IF NOT EXISTS (SELECT * FROM dbo.trtBaseReference WHERE idfsBaseReference = 10067012)
BEGIN
	INSERT INTO dbo.trtBaseReference
	(
		idfsBaseReference,
		idfsReferenceType,
		strBaseReferenceCode,
		strDefault,
		intRowStatus,
		rowguid,
		SourceSystemNameID,
		SourceSystemKeyValue,
		AuditCreateUser,
		AuditCreateDTM
	)
	VALUES
	(
		10067012,
		19000067,
		N'editStatement',
		N'Statement',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":10067012}]',
		N'System',
		GETDATE()
	)
END
ALTER TABLE [dbo].[trtStringNameTranslation] DISABLE TRIGGER [TR_trtStringNameTranslation_I_Delete]

UPDATE dbo.trtStringNameTranslation
SET idfsBaseReference = 10067012
WHERE idfsBaseReference = 129909620010693

ALTER TABLE [dbo].[trtStringNameTranslation] ENABLE TRIGGER [TR_trtStringNameTranslation_I_Delete]


ALTER TABLE [dbo].[trtBaseReference] DISABLE TRIGGER [TR_trtBaseReference_I_Delete]

DELETE FROM dbo.trtBaseReference
WHERE idfsBaseReference = 129909620010693

ALTER TABLE [dbo].[trtBaseReference] ENABLE TRIGGER [TR_trtBaseReference_I_Delete]


IF NOT EXISTS (SELECT * FROM dbo.trtBaseReference WHERE idfsBaseReference = 10071504)
BEGIN
	INSERT INTO dbo.trtBaseReference
	(
		idfsBaseReference,
		idfsReferenceType,
		strBaseReferenceCode,
		strDefault,
		intRowStatus,
		rowguid,
		SourceSystemNameID,
		SourceSystemKeyValue,
		AuditCreateUser,
		AuditCreateDTM
	)
	VALUES
	(
		10071504,
		19000071,
		N'parStatement',
		N'Statement',
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":10071504}]',
		N'System',
		GETDATE()
	)
END
ALTER TABLE [dbo].[trtStringNameTranslation] DISABLE TRIGGER [TR_trtStringNameTranslation_I_Delete]

UPDATE dbo.trtBaseReference
SET strBaseReferenceCode = N'parStatement'
WHERE idfsBaseReference = 10071504

UPDATE dbo.trtStringNameTranslation
SET idfsBaseReference = 10071504
WHERE idfsBaseReference = 129909620010692

ALTER TABLE [dbo].[trtStringNameTranslation] ENABLE TRIGGER [TR_trtStringNameTranslation_I_Delete]


ALTER TABLE [dbo].[trtBaseReference] DISABLE TRIGGER [TR_trtBaseReference_I_Delete]

DELETE FROM dbo.trtBaseReference
WHERE idfsBaseReference = 129909620010692

ALTER TABLE [dbo].[trtBaseReference] ENABLE TRIGGER [TR_trtBaseReference_I_Delete]
