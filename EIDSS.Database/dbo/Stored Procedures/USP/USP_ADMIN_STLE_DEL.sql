

--=====================================================================================================
-- Created by:				Joan Li
-- Last modified date:		06/07/2017
-- Last modified by:		Joan Li
-- Description:				06/07/2017:Created based on V6 spSettlement_Delete: rename for V7 USP47
--                          Delete (soft) from the following:
--                          tables: gisWKBSettlement;gisSettlement;gisStringNameTranslation;gisBaseReference
--     
-- Testing code:

-- Update: Ricky Moss 08/07/2019 API Accommodations - Return Code and Return Message Fields
--         Ricky Moss 04/29/2020 Added in use functionality
/*
DECLARE	@return_value int
EXEC	@return_value = [dbo].[USP_ADMIN_STLE_DEL]
		@idfsSettlement = 67920000000
SELECT	'Return Value' = @return_value
*/
--=====================================================================================================

CREATE   PROC [dbo].[USP_ADMIN_STLE_DEL]
(
	@idfsSettlement AS BIGINT
)
AS

DECLARE @returnMsg VARCHAR(MAX) = 'Success'
DECLARE @returnCode BIGINT = 0
BEGIN

	BEGIN TRY  	

	BEGIN TRANSACTION
		IF  @idfsSettlement IS NOT NULL
			BEGIN
			IF NOT EXISTS(SELECT idfsSettlement FROM dbo.tlbGeoLocation WHERE intRowStatus = 0 AND idfsSettlement = @idfsSettlement)
			BEGIN

				-- Delete from gisWKBSettlement table
				DELETE 
				FROM	dbo.gisWKBSettlement 
				WHERE	idfsGeoObject = @idfsSettlement
			
				-- Delete from gisSettlement table
				DELETE 
				FROM	dbo.gisSettlement 
				WHERE	[idfsSettlement] = @idfsSettlement

				-- Delete from gisStringNameTranslation table
				DELETE 
				FROM	dbo.gisStringNameTranslation 
				WHERE	idfsGISBaseReference = @idfsSettlement

				-- Delete from gisBaseReference
				DELETE 
				FROM	dbo.gisBaseReference 
				WHERE	idfsGISBaseReference = @idfsSettlement

			END

			IF EXISTS(SELECT idfsSettlement FROM dbo.tlbGeoLocation WHERE intRowStatus = 0 AND idfsSettlement = @idfsSettlement)
			BEGIN 
				SET @returnMsg = 'IN USE'
			END

		END

		IF @@TRANCOUNT > 0 		
			COMMIT  

			SELECT @returnCode 'returnCode', @returnMsg 'returnMessage'
	END TRY  

	BEGIN CATCH  

		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK

				SET @returnMsg = 
				'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
				+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
				+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
				+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
				+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
				+ ' ErrorMessage: '+ ERROR_MESSAGE()
				SELECT @returnCode 'returnCode', @returnMsg 'returnMessage'
			END

	END CATCH; 
END




