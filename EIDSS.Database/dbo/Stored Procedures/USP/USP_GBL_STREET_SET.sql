
--********************************************************************
-- Name 				: USP_GBL_STREET_SET
-- Description			: SET Address
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name			Date		Change Detail
--		Mark Wilson		09/13/2021	updated to add @user and insert idfsLocation
--									and add update
--		Mark Wilson		09/22/2021	updated to ignore idfsSettlement and change param to @idfsLocation
--									change @idfsLocation to BIGINT
--	    Manickandan Govindarajan		12/23/2021	Added additional return parameter idfStreet
-- Testing code:
/*

DECLARE
	@strStreetName NVARCHAR(200) = 'New Road Avenue',
	@idfsLocation BIGINT = 75111140000801,
	@user NVARCHAR(100) = 'TestData'


EXEC [dbo].[USP_GBL_STREET_SET] 
	@strStreetName = @strStreetName,
	@idfsLocation = @idfsLocation,
	@user = @user


EXEC dbo.USP_GBL_STREET_GETList
	@idfsLocation = @idfsLocation	


*/
---------------------------------------------------------------------
CREATE PROCEDURE [dbo].[USP_GBL_STREET_SET]
(
	@strStreetName NVARCHAR(200),  --##PARAM @strStreetName - street name
	@idfsLocation BIGINT,  --##PARAM @idfsLocation - ID of location to which stree is belongs
	@idfStreet BIGINT = NULL,
	@user NVARCHAR(100) = NULL
)
AS 
BEGIN

    declare @returnCode INT = 0;
	declare @returnMsg NVARCHAR(MAX) = 'SUCCESS' 

	BEGIN TRY
		
		IF @user = ''
			SET @user = SUSER_NAME()

		IF (@idfsLocation IS NOT NULL) AND (@strStreetName IS NOT NULL) AND (LEN(@strStreetName) > 0)
			BEGIN
				IF NOT EXISTS	(	SELECT	*	
									FROM	dbo.tlbStreet
									WHERE	idfsLocation = @idfsLocation
											AND strStreetName = @strStreetName
											AND intRowStatus = 0
								)
				BEGIN
		
					IF @idfStreet IS NULL -- insert
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
								AuditCreateUser,
								AuditCreateDTM,
								AuditUpdateUser,
								AuditUpdateDTM
							)
						VALUES
							(
								@idfStreet,
								@strStreetName,
								@idfsLocation,
								0,
								NEWID(),
								ISNULL(@user, SUSER_NAME()),
								GETDATE(),
								ISNULL(@user, SUSER_NAME()),
								GETDATE()
							)
					END

					ELSE -- udpate 
					BEGIN

						UPDATE dbo.tlbStreet
						SET strStreetName = @strStreetName,
							idfsLocation = @idfsLocation,
							intRowStatus = 0,
							AuditUpdateUser = ISNULL(@user, SUSER_NAME()),
							AuditUpdateDTM = GETDATE()

						WHERE idfStreet = @idfStreet

					END

				END

			END
	
			SELECT @returnCode ReturnCode, @returnMsg ReturnMessage,@idfStreet idfStreet
	END TRY
	BEGIN CATCH
		  SET @returnCode = ERROR_NUMBER()
		  SET @returnMsg = ERROR_MESSAGE()

		  SELECT @returnCode ReturnCode, @returnMsg ReturnMessage,@idfStreet idfStreet
	END CATCH

END



