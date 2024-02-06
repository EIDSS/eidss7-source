

-- ================================================================================================
-- Name: USSP_GBL_STREET_SET
--
-- Description: Adds street records for use in a drop down.  This is only called from another 
-- stored procedure and not the application.
--          
-- Revision History:
-- Name                Date       Change Detail
-- ------------------- ---------- ----------------------------------------------------------------
-- Stephen Long        06/16/2021 Initial release.
-- Stephen Long        07/29/2021 Added insert of location ID.
-- Stephen Long        08/05/2021 Added audit user name.
-- Mark Wilson         09/13/2021 Added all fields and update functionality.
--
-- Testing code:
-- DECLARE @StreetName NVARCHAR(200)
-- DECLARE @SettlementID BIGINT
--
-- EXECUTE [dbo].[USSP_GBL_STREET_SET] 
--   @StreetName
--  ,@SettlementID
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_STREET_SET] 
(
	@StreetName NVARCHAR(200),
	@idfsLocation BIGINT,
	@AuditUserName NVARCHAR(200) = '',
	@idfStreet BIGINT = NULL OUTPUT
)
AS
BEGIN

	BEGIN TRY
		IF @AuditUserName = ''
			SET @AuditUserName = SUSER_NAME()

		IF (@idfsLocation IS NOT NULL)
			AND (@StreetName IS NOT NULL)
			AND (LEN(@StreetName) > 0)
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM dbo.tlbStreet
					WHERE idfsLocation = @idfsLocation
						AND strStreetName = @StreetName
						AND intRowStatus = 0
					)
			BEGIN
				IF @idfStreet IS NULL -- this is an insert
				BEGIN

					EXECUTE dbo.USP_GBL_NEXTKEYID_GET 
						@tablename = 'tlbStreet', 
						@idfsKey = @idfStreet OUTPUT
					
					INSERT INTO dbo.tlbStreet
					(
						idfStreet,
						strStreetName,
						idfsLocation,
						intRowStatus,
						rowguid,
						SourceSystemNameID,
						SourceSystemKeyValue,
						AuditCreateUser,
						AuditCreateDTM,
						AuditUpdateUser,
						AuditUpdateDTM
					)
					VALUES
					(
						@idfStreet,
						@StreetName,
						@idfsLocation,
						0,
						NEWID(),
						10519001,
						N'[{"idfStreet":' + CAST(@idfStreet AS NVARCHAR(50)) + '}]',
						@AuditUserName,
						GETDATE(),
						@AuditUserName,
						GETDATE()
					)
				END

				ELSE -- udpate 
				BEGIN

					UPDATE dbo.tlbStreet
					SET 
						strStreetName = @StreetName,
						idfsLocation = @idfsLocation,
						intRowStatus = 0,
						AuditUpdateUser = @AuditUserName,
						AuditUpdateDTM = GETDATE()

					WHERE idfStreet = @idfStreet

				END
				

			END

		END

	END TRY

	BEGIN CATCH

	END CATCH

END
