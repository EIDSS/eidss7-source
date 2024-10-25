
------------------------------------------------------------------------------------------------------------------
--
-- update trtReferenceType table to controlled id values
--
------------------------------------------------------------------------------------------------------------------
UPDATE dbo.trtReferenceType
SET idfminid = 10538000,
	idfMaxID = 10538999
WHERE idfsReferenceType = 19000538

------------------------------------------------------------------------------------------------------------------
--
-- create new base reference values
--
------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.trtBaseReference WHERE idfsBaseReference = 10538000)
BEGIN
	INSERT INTO dbo.trtBaseReference
	(
		idfsBaseReference,
		idfsReferenceType,
		strBaseReferenceCode,
		strDefault,
		intHACode,
		intOrder,
		blnSystem,
		intRowStatus,
		rowguid,
		SourceSystemNameID,
		SourceSystemKeyValue,
		AuditCreateUser,
		AuditCreateDTM
	)

	SELECT
		10538000,
		idfsReferenceType,
		strBaseReferenceCode,
		strDefault,
		intHACode,
		intOrder,
		blnSystem,
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":10538000}]',
		'System',
		GETDATE()

	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = 129909620007069

END
GO

IF NOT EXISTS (SELECT * FROM dbo.trtBaseReference WHERE idfsBaseReference = 10538001)
BEGIN
	INSERT INTO dbo.trtBaseReference
	(
		idfsBaseReference,
		idfsReferenceType,
		strBaseReferenceCode,
		strDefault,
		intHACode,
		intOrder,
		blnSystem,
		intRowStatus,
		rowguid,
		SourceSystemNameID,
		SourceSystemKeyValue,
		AuditCreateUser,
		AuditCreateDTM
	)

	SELECT
		10538001,
		idfsReferenceType,
		strBaseReferenceCode,
		strDefault,
		intHACode,
		intOrder,
		blnSystem,
		0,
		NEWID(),
		10519001,
		N'[{"idfsBaseReference":10538001}]',
		'System',
		GETDATE()

	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = 129909620007070

END

GO
------------------------------------------------------------------------------------------------------------------
--
-- update monitoring sessions to the new values.
--
------------------------------------------------------------------------------------------------------------------
UPDATE dbo.tlbMonitoringSession
SET idfsMonitoringSessionSpeciesType = 10538000
WHERE idfsMonitoringSessionSpeciesType = 129909620007069

UPDATE dbo.tlbMonitoringSession
SET idfsMonitoringSessionSpeciesType = 10538001
WHERE idfsMonitoringSessionSpeciesType = 129909620007070


------------------------------------------------------------------------------------------------------------------
--
-- update translations
--
------------------------------------------------------------------------------------------------------------------
ALTER TABLE [dbo].[trtStringNameTranslation] DISABLE TRIGGER [TR_trtStringNameTranslation_A_Update]

UPDATE dbo.trtStringNameTranslation
SET idfsBaseReference = 10538000
WHERE idfsBaseReference = 129909620007069

UPDATE dbo.trtStringNameTranslation
SET idfsBaseReference = 10538001
WHERE idfsBaseReference = 129909620007070


ALTER TABLE [dbo].[trtStringNameTranslation] ENABLE TRIGGER [TR_trtStringNameTranslation_A_Update]


------------------------------------------------------------------------------------------------------------------
--
-- delete old basereference data
--
------------------------------------------------------------------------------------------------------------------
ALTER TABLE [dbo].[trtBaseReference] DISABLE TRIGGER [TR_trtBaseReference_I_Delete]

DELETE FROM dbo.trtBaseReference WHERE idfsBaseReference IN (129909620007069, 129909620007070)

ALTER TABLE [dbo].[trtBaseReference] ENABLE TRIGGER [TR_trtBaseReference_I_Delete]
