



-- ================================================================================================
-- Name: USSP_GBL_POSTAL_CODE_SET
--
-- Description: Inserts or updates a postal code record.  Called from another stored procedure, 
-- and not the application.
--          
-- Author: Stephen Long
--
-- Revision History:
-- Name					Date       Change Detail
-- ------------------	---------- -----------------------------------------------------------------
-- Stephen Long			06/04/2020 Initial release
-- Stephen Long			07/29/2021 Added insert of location ID.
-- Stephen Long			08/05/2021 Added audit user name.
-- Mark Wilson			09/13/2021 Added all fields and update functionality.
-- Mark Wilson			09/22/2021	updated to ignore idfsSettlement and change param to @idfsLocation
--
-- Testing code:
/* 

DECLARE 
	@strPostCode NVARCHAR(200) = '13233',
	@idfsLocation BIGINT = 75111070000801,
	@AuditUserName NVARCHAR(100) = 'BigTest',
	@idfPostalCode BIGINT = NULL --1130000776

EXECUTE [dbo].[USSP_GBL_POSTAL_CODE_SET] 
	@strPostCode = @strPostCode,
	@idfsLocation = @idfsLocation,
	@AuditUserName = @AuditUserName,
	@idfPostalCode = @idfPostalCode

EXEC dbo.USP_GBL_POSTAL_CODE_GETLIST
	@idfsLocation = @idfsLocation	

SELECT * FROM dbo.tlbPostalCode where idfPostalCode = @idfPostalCode

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_POSTAL_CODE_SET] 
(
	@strPostCode NVARCHAR(200),
	@idfsLocation BIGINT,
	@AuditUserName NVARCHAR(200) = '',
	@idfPostalCode BIGINT = NULL OUTPUT
)
AS
BEGIN

	BEGIN TRY
		
		IF @AuditUserName = ''
			SET @AuditUserName = SUSER_NAME()

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
						SourceSystemNameID,
						SourceSystemKeyValue,
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
						10519001,
						N'[{"idfPostalCode":' + CAST(@idfPostalCode AS NVARCHAR(50)) + '}]',
						@AuditUserName,
						GETDATE(),
						@AuditUserName,
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
						AuditUpdateUser = @AuditUserName,
						AuditUpdateDTM = GETDATE()

					WHERE idfPostalCode = @idfPostalCode

				END

			END

		END


	END TRY

	BEGIN CATCH


	END CATCH

END


