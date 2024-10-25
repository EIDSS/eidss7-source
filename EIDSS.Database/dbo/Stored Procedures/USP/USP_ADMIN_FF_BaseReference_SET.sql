


-- ================================================================================================
-- Name: USP_ADMIN_FF_BaseReference_SET
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
-- Mark Wilson		10/04/2021 Added @User
/*
DECLARE @idfsSpeciesType BIGINT

EXEC dbo.USP_ADMIN_FF_BaseReference_SET @idfsSpeciesType OUTPUT, 19000086, 'en-US', 'FFTest', 'Mark', 'TestUser'

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_BaseReference_SET] 
(
	@ReferenceID BIGINT = NULL OUTPUT,
	@ReferenceType BIGINT,
	@LangID NVARCHAR(50),
	@DefaultName VARCHAR(200), -- Default reference name, used if there is no reference translation
	@NationalName NVARCHAR(200) = NULL, -- Reference name in the language defined by @LangID
	@User NVARCHAR(100) = NULL
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
					intOrder = 0,
					blnSystem = 0,
					SourceSystemNameID = ISNULL(SourceSystemNameID, 10519001),
					SourceSystemKeyValue = ISNULL(SourceSystemKeyValue, N'[{"idfsBaseReference":' + CAST(@ReferenceID AS NVARCHAR(300)) + '}]'),
					AuditUpdateDTM = GETDATE(),
					AuditUpdateUser = @User
				WHERE idfsBaseReference = @ReferenceID;
			END
		ELSE

			BEGIN
				IF @ReferenceID IS NULL
				BEGIN
					EXEC dbo.USP_GBL_NEXTKEYID_GET 
						'trtBaseReference',
						@ReferenceID OUTPUT;
				END

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
					AuditCreateUser,
				    AuditUpdateDTM,
					AuditUpdateUser
				)
				VALUES (
					@ReferenceID,
					@ReferenceType,
					NULL,
					@DefaultName,
					NULL,
					0,
					0,
					0,
					NEWID(),
					'ADD',
					'EIDSS7 new reference data',
					10519001,
					N'[{"idfsBaseReference":' + CAST(@ReferenceID AS NVARCHAR(300)) + '}]',
					GETDATE(),
					@User,
					GETDATE(),
					@User
				);

				SELECT @idfCustomizationPackage = dbo.FN_GBL_CustomizationPackage_GET();

				IF @idfCustomizationPackage IS NOT NULL
					AND @idfCustomizationPackage <> 51577300000000 --The USA
				BEGIN
					EXEC dbo.USP_GBL_BaseReferenceToCP_SET 
						@ReferenceID,
						@idfCustomizationPackage,
						@User
				END
			END

			EXEC dbo.USSP_GBL_StringTranslation_SET 
				@ReferenceID,
				@LangID,
				@NationalName,
				@User

		RETURN;

	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
