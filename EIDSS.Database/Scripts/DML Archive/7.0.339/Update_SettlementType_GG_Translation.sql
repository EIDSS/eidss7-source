
-- CREATE TEMP TABLE for use with import
DROP TABLE IF EXISTS [dbo].[ZZZ_GISStringNameTranslation]
GO
PRINT N'Creating [dbo].[ZZZ_GISStringNameTranslation]'
GO
CREATE TABLE [dbo].[ZZZ_GISStringNameTranslation]
(
	idfsGISBaseReference BIGINT,
	idfsLanguage BIGINT,
	strDefault NVARCHAR(300) COLLATE Cyrillic_General_CI_AS NULL,
	strTextString NVARCHAR(300) COLLATE Cyrillic_General_CI_AS NULL,
	SourceSystemNameID BIGINT,
	SourceSystemKeyValue NVARCHAR(MAX)

)
GO

PRINT(N'Add 3 rows to [dbo].[ZZZ_GISStringNameTranslation]')

INSERT INTO [dbo].[ZZZ_GISStringNameTranslation] ([idfsGISBaseReference], [idfsLanguage], [strDefault], [strTextString], [SourceSystemNameID], [SourceSystemKeyValue]) VALUES (730120000000, 10049004, N'Settlement', N'დასახლება', 10519002, N'[{"idfsGISBaseReference":730120000000,"idfsLanguage":10049004}]')
INSERT INTO [dbo].[ZZZ_GISStringNameTranslation] ([idfsGISBaseReference], [idfsLanguage], [strDefault], [strTextString], [SourceSystemNameID], [SourceSystemKeyValue]) VALUES (730130000000, 10049004, N'Town', N'ქალაქი', 10519002, N'[{"idfsGISBaseReference":730130000000,"idfsLanguage":10049004}]')
INSERT INTO [dbo].[ZZZ_GISStringNameTranslation] ([idfsGISBaseReference], [idfsLanguage], [strDefault], [strTextString], [SourceSystemNameID], [SourceSystemKeyValue]) VALUES (730140000000, 10049004, N'Village', N'სოფელი', 10519002, N'[{"idfsGISBaseReference":730140000000,"idfsLanguage":10049004}]')

----------------------------------------------------------------------------------------------------------------------------------------
--
-- declare variables for cursor
--
----------------------------------------------------------------------------------------------------------------------------------------

DECLARE @idfsGISBaseReference BIGINT
DECLARE @idfsLanguage BIGINT
DECLARE @strTextString NVARCHAR(300)
DECLARE @SourceSystemNameID BIGINT
DECLARE @SourceSystemKeyValue NVARCHAR(MAX)

DECLARE Cursor_gisStringNameTranslation
CURSOR FOR
SELECT
	idfsGISBaseReference,
    idfsLanguage,
    strTextString,
	SourceSystemNameID,
	SourceSystemKeyValue

FROM dbo.ZZZ_GISStringNameTranslation

OPEN Cursor_gisStringNameTranslation
FETCH NEXT FROM Cursor_gisStringNameTranslation
INTO
	@idfsGISBaseReference,
	@idfsLanguage,
	@strTextString,
	@SourceSystemNameID,
	@SourceSystemKeyValue

WHILE @@FETCH_STATUS = 0
BEGIN
	IF NOT EXISTS (SELECT * FROM dbo.gisStringNameTranslation WHERE idfsGISBaseReference = @idfsGISBaseReference AND idfsLanguage = @idfsLanguage)
	BEGIN
		INSERT INTO dbo.gisStringNameTranslation
		(
		    idfsGISBaseReference,
		    idfsLanguage,
		    strTextString,
		    rowguid,
		    intRowStatus,
		    SourceSystemNameID,
		    SourceSystemKeyValue,
		    AuditCreateUser,
		    AuditCreateDTM
		)
		SELECT
			@idfsGISBaseReference,
			@idfsLanguage,
			@strTextString,
			NEWID(),
			0,
			@SourceSystemNameID,
			@SourceSystemKeyValue,
			'System',
			GETDATE()

	END
	ELSE
	BEGIN
		UPDATE dbo.gisStringNameTranslation
		SET strTextString = @strTextString,
			intRowStatus = 0,
			AuditUpdateUser = 'System',
			AuditUpdateDTM = GETDATE()
		WHERE idfsGISBaseReference = @idfsGISBaseReference AND idfsLanguage = @idfsLanguage

	END

	FETCH NEXT FROM Cursor_gisStringNameTranslation
	INTO
		@idfsGISBaseReference,
		@idfsLanguage,
		@strTextString,
		@SourceSystemNameID,
		@SourceSystemKeyValue



END

CLOSE Cursor_gisStringNameTranslation
DEALLOCATE Cursor_gisStringNameTranslation


-- DROP TEMP TABLE
DROP TABLE IF EXISTS [dbo].[ZZZ_GISStringNameTranslation]


