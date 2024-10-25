-- ================================================================================================
-- Name: USSP_GBL_BaseReference_SET
--
-- Description: Insert/update base reference data.  Non-API stored procedure.  Only call via 
-- other USP stored procedures.
--           
-- Revision History:
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long		08/20/2019 Initial release.
-- Mark Wilson		05/13/2021 Updated to insert when duplicate value is used
-- Stephen Long     06/26/2021 Added return to end and added set nocount on so output param will
--                             return to calling stored procedure.
/*
DECLARE @idfsSpeciesType BIGINT

EXEC dbo.USSP_GBL_BaseReference_SET @idfsSpeciesType OUTPUT, 19000086, 'en', 'Mark', 'Mark', 0, 0


*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_BaseReference_SET2] 
(
	@ReferenceID BIGINT = NULL OUTPUT,
	@ReferenceType BIGINT,
	@LangID NVARCHAR(50),
	@DefaultName VARCHAR(200), -- Default reference name, used if there is no reference translation
	@NationalName NVARCHAR(200) = NULL, -- Reference name in the language defined by @LangID
	@HACode INT = NULL, -- Bit mask for reference using
	@Order INT = NULL, -- Reference record order for sorting
	@System BIT = 0,
	@AllowDuplicates BIT = 1,
	@Unique_strDefault BIT = 'TRUE' OUTPUT
    
)
AS
BEGIN
	SET NOCOUNT ON;
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
			BEGIN
				IF EXISTS (SELECT * FROM dbo.trtBaseReference WHERE strDefault = @DefaultName AND idfsReferenceType = @ReferenceType)
					SET @Unique_strDefault = 'FALSE'
				ELSE
					SET @Unique_strDefault = 'TRUE'

				IF @AllowDuplicates = 1 OR @Unique_strDefault = 'TRUE'
					BEGIN
						IF @ReferenceID IS NULL OR @ReferenceID = NULL
							BEGIN
								EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtBaseReference',
									@ReferenceID OUTPUT;
							END

								

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
			IF @AllowDuplicates = 1 OR @Unique_strDefault = 'TRUE'
				BEGIN
					EXEC dbo.USSP_GBL_StringTranslation_SET @ReferenceID,
						@LangID,
						@DefaultName,
						@NationalName;
				END
		END

		RETURN;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
