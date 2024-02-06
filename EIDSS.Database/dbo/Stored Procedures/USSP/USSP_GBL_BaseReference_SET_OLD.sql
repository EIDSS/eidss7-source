



-- ================================================================================================
-- Name: USSP_GBL_BaseReference_SET_OLD
--
-- Description: Insert/update base reference data.  Non-API stored procedure.  Only call via 
-- other USP stored procedures.
--           
-- Revision History:
-- Name				Date		Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long		08/20/2019	Initial release.
/*
DECLARE @idfsSpeciesType BIGINT

EXEC dbo.USSP_GBL_BaseReference_SET_OLD @idfsSpeciesType OUTPUT, 19000086, 'en', 'Mark', 'Mark', 0, 0


*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_BaseReference_SET_OLD] 
(
	@ReferenceID BIGINT = NULL OUTPUT,
	@ReferenceType BIGINT,
	@LangID NVARCHAR(50),
	@DefaultName VARCHAR(200), -- Default reference name, used if there is no reference translation
	@NationalName NVARCHAR(200) = NULL, -- Reference name in the language defined by @LangID
	@HACode INT = NULL, -- Bit mask for reference using
	@Order INT = NULL, -- Reference record order for sorting
	@System BIT = 0,
	@Unique_strDefault BIT = 'TRUE' OUTPUT
    
)
AS
BEGIN

	DECLARE @idfCustomizationPackage BIGINT;

	BEGIN TRY
		IF EXISTS (
				SELECT idfsBaseReference
				FROM dbo.trtBaseReference
				WHERE idfsBaseReference = @ReferenceID
					AND intRowStatus = 0
				)
		BEGIN
			UPDATE dbo.trtBaseReference
			SET idfsReferenceType = @ReferenceType,
				strDefault = ISNULL(@DefaultName, strDefault),
				intHACode = ISNULL(@HACode, intHACode),
				intOrder = ISNULL(@Order, intOrder),
				blnSystem = ISNULL(@System, blnSystem)
			WHERE idfsBaseReference = @ReferenceID;
		END
		ELSE
		IF EXISTS (SELECT * FROM dbo.trtBaseReference WHERE strDefault = @DefaultName AND idfsReferenceType = @ReferenceType)
			SET @Unique_strDefault = 'FALSE'
		ELSE

		BEGIN
			EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtBaseReference',
				@ReferenceID OUTPUT;
			SET @Unique_strDefault = 'TRUE'

			INSERT INTO dbo.trtBaseReference (
				idfsBaseReference,
				idfsReferenceType,
				intHACode,
				strDefault,
				intOrder,
				blnSystem
				)
			VALUES (
				@ReferenceID,
				@ReferenceType,
				@HACode,
				@DefaultName,
				@Order,
				@System
				);


			SELECT @idfCustomizationPackage = dbo.FN_GBL_CustomizationPackage_GET();

			IF @idfCustomizationPackage IS NOT NULL
				AND @idfCustomizationPackage <> 51577300000000 --The USA
			BEGIN
				EXEC dbo.USP_GBL_BaseReferenceToCP_SET @ReferenceID,
					@idfCustomizationPackage;
			END
		END
-----------------------------------------------------------------------------------------------------------------
-- Added 13May2021 to insert if NULL idfsBaseReference is passed
-----------------------------------------------------------------------------------------------------------------
/*		IF @ReferenceID IS NULL
		BEGIN

			EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtBaseReference',
				@ReferenceID OUTPUT;

			INSERT INTO dbo.trtBaseReference (
				idfsBaseReference,
				idfsReferenceType,
				intHACode,
				strDefault,
				intOrder,
				blnSystem
				)
			VALUES (
				@ReferenceID,
				@ReferenceType,
				@HACode,
				@DefaultName,
				@Order,
				@System
				);


			SELECT @idfCustomizationPackage = dbo.FN_GBL_CustomizationPackage_GET();

			IF @idfCustomizationPackage IS NOT NULL
				AND @idfCustomizationPackage <> 51577300000000 --The USA
			BEGIN
				EXEC dbo.USP_GBL_BaseReferenceToCP_SET @ReferenceID,
					@idfCustomizationPackage;
			END

		END
		*/
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
		IF (@LangID = N'en')
		BEGIN
			IF EXISTS (
					SELECT idfsBaseReference
					FROM dbo.trtStringNameTranslation
					WHERE idfsBaseReference = @ReferenceID
						AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET(N'en')
					)
				EXEC dbo.USSP_GBL_StringTranslation_SET @ReferenceID,
					@LangID,
					@DefaultName,
					@DefaultName;
		END
		ELSE
		BEGIN
			EXEC dbo.USSP_GBL_StringTranslation_SET @ReferenceID,
				@LangID,
				@DefaultName,
				@NationalName;
		END
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
