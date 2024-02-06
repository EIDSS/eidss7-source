--*************************************************************
-- Name 				: USP_GBL_POSTALCODE_SET
-- Description			: SET Postal Code
--          
-- Author               : Mandar Kulkarni
-- Revision History
--	Name			Date		Change Detail
--	Mark Wilson		09/13/2021	updated to add @user and insert idfsLocation
--								and add update
--	Mark Wilson		09/22/2021	updated to ignore idfsSettlement and change param to @idfsLocation
--	Mark Wilson		12/23/2021	Added additional return parameter idfPostalCode
--
-- Testing code:
/*

DECLARE @strPostCode NVARCHAR(200) = 30302
DECLARE @idfsLocation NVARCHAR(36) = 

EXECUTE [dbo].[USP_GBL_STREET_SET] 
	@strPostCode,
	@idfsLocation,
	@idfPostalCode OUTPUT,
	@returnCode OUTPUT,
	@returnMsg

*/

CREATE PROCEDURE [dbo].[USP_GBL_POSTALCODE_SET]
(
	@strPostCode NVARCHAR(200),
	@idfsLocation BIGINT,
	@idfPostalCode BIGINT = NULL,
	@user NVARCHAR(100) = NULL

)
AS
BEGIN
    declare @returnCode INT = 0;
	declare @returnMsg NVARCHAR(MAX) = 'SUCCESS' 
	


	BEGIN TRY
		IF (@idfsLocation IS NOT NULL) AND (@strPostCode IS NOT NULL) AND (LEN(@strPostCode) > 0)
		BEGIN
			IF NOT EXISTS	(	SELECT	*	
								FROM	dbo.tlbPostalCode
								WHERE	idfsLocation = @idfsLocation
										AND strPostCode = @strPostCode
										AND intRowStatus = 0
							)
			BEGIN
		
				IF @idfPostalCode IS NULL
				BEGIN  -- insert

					EXECUTE dbo.USP_GBL_NEXTKEYID_GET
						@tablename = 'tlbPostalCode', 
						@idfsKey = @idfPostalCode OUTPUT
		
					INSERT INTO dbo.tlbPostalCode
					(
						idfPostalCode,
						strPostCode,
						idfsLocation,
						intRowStatus,
						rowguid,
						AuditCreateUser,
						AuditCreateDTM,
						AuditUpdateUser,
						AuditUpdateDTM
					)
					VALUES
					(
						@idfPostalCode,
						@strPostCode,
						@idfsLocation,
						0,
						NEWID(),
						ISNULL(@user, SUSER_NAME()),
						GETDATE(),
						ISNULL(@user, SUSER_NAME()),
						GETDATE()
					)

				END

				ELSE -- update
				BEGIN

					UPDATE dbo.tlbPostalCode
					SET 
						idfsLocation = @idfsLocation,
						strPostCode = @strPostCode,
						intRowStatus = 0,
						AuditUpdateUser = ISNULL(@user, SUSER_NAME()),
						AuditUpdateDTM = GETDATE()

					WHERE idfPostalCode = @idfPostalCode

				END

			END

		END

		SELECT @returnCode ReturnCode, @returnMsg ReturnMessage,@idfPostalCode idfPostalCode

	END TRY

	BEGIN CATCH
		  SET @returnCode = ERROR_NUMBER()
		  SET @returnMsg = ERROR_MESSAGE()

		  SELECT @returnCode ReturnCode, @returnMsg ReturnMessage,@idfPostalCode idfPostalCode

	END CATCH

END
