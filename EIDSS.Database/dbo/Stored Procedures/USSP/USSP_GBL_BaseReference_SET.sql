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
-- Mark Wilson		08/10/2021 Updated remove unused parameter from USSP_GBL_StringTranslation_SET
-- Stephen Long     08/12/2021 Corrected to use order parameter on insert instead of 0.
-- Stephen Long     02/13/2023 Changed default name from varchar to nvarchar.
/*
DECLARE @idfsSpeciesType BIGINT

EXEC dbo.USSP_GBL_BaseReference_SET @idfsSpeciesType OUTPUT, 19000086, 'en-US', 'Mark', 'Mark', 0, 0


*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_BaseReference_SET] 
(
	@ReferenceID BIGINT = NULL OUTPUT,
	@ReferenceType BIGINT,
	@LangID NVARCHAR(50),
	@DefaultName NVARCHAR(200), -- Default reference name, used if there is no reference translation
	@NationalName NVARCHAR(200) = NULL, -- Reference name in the language defined by @LangID
	@HACode INT = NULL, -- Bit mask for reference using
	@Order INT = NULL, -- Reference record order for sorting
	@System BIT = 0,
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
				blnSystem = ISNULL(@System, blnSystem),
				rowguid = ISNULL(rowguid, NEWID()),
				AuditUpdateDTM = GETDATE()
			WHERE idfsBaseReference = @ReferenceID;
		END
		ELSE

		BEGIN
			IF @ReferenceID IS NULL
			BEGIN
				EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtBaseReference',
					@ReferenceID OUTPUT;
			END

			IF @Order IS NULL 
			BEGIN
				SET @Order = 0;
			END

			IF EXISTS (SELECT * FROM dbo.trtBaseReference WHERE strDefault = @DefaultName AND idfsReferenceType = @ReferenceType)
				SET @Unique_strDefault = 'FALSE'
			ELSE
				SET @Unique_strDefault = 'TRUE'

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
				strMaintenanceFlag,
				strReservedAttribute,
				SourceSystemNameID,
				SourceSystemKeyValue,
				AuditCreateDTM,
				AuditUpdateDTM
			)
			VALUES (
				@ReferenceID,
				@ReferenceType,
				NULL,
				@DefaultName,
				NULL,
				@Order,
				0,
				0,
				NEWID(),
				'ADD',
				'EIDSS7 new reference data',
				10519001,
				N'[{"idfsBaseReference":' + CAST(@ReferenceID AS NVARCHAR(300)) + '}]',
				GETDATE(),
				GETDATE()
			);

			SELECT @idfCustomizationPackage = dbo.FN_GBL_CustomizationPackage_GET();

			IF @idfCustomizationPackage IS NOT NULL
				AND @idfCustomizationPackage <> 51577300000000 --The USA
			BEGIN
				EXEC dbo.USP_GBL_BaseReferenceToCP_SET @ReferenceID,
					@idfCustomizationPackage;
			END
		END
		
		EXEC dbo.USSP_GBL_StringTranslation_SET 
			@ReferenceID,
			@LangID,
			@NationalName;

		RETURN;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
