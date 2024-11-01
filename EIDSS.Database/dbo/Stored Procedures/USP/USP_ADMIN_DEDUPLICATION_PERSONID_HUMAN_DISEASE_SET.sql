﻿
-- ================================================================================================
-- Name: USP_ADMIN_DEDUPLICATION_PERSONID_HUMAN_DISEASE_SET
--
-- Description: Update column idfHumanActual with SurvivorHumanMasterID in tlbHuman.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Ann Xiong    4/16/2019 Initial release for new API.
-- Ann Xiong    2/10/2022 Updated 'ReturnMsg' to 'ReturnMessage'
--
--
-- ================================================================================================

CREATE PROCEDURE [dbo].[USP_ADMIN_DEDUPLICATION_PERSONID_HUMAN_DISEASE_SET]
 	@SurvivorHumanMasterID		BIGINT = NULL,
	@SupersededHumanMasterID	BIGINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnCode INT = 0 
	DECLARE	@ReturnMsg NVARCHAR(max) = 'SUCCESS' 

	BEGIN TRY

		BEGIN TRANSACTION

			UPDATE 	dbo.tlbHuman
			SET 	idfHumanActual = @SurvivorHumanMasterID					
			WHERE	idfHumanActual = @SupersededHumanMasterID
			
			IF @@TRANCOUNT > 0 
				COMMIT TRANSACTION;
			
			SELECT @ReturnCode 'ReturnCode', @ReturnMsg 'ReturnMessage'
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SET @ReturnCode = ERROR_NUMBER()
		SET @ReturnMsg = 'ErrorNumber: ' + convert(varchar, ERROR_NUMBER() ) 
							+ ' ErrorSeverity: ' + convert(varchar, ERROR_SEVERITY() )
			   				+ ' ErrorState: ' + convert(varchar,ERROR_STATE())
			   				+ ' ErrorProcedure: ' + isnull(ERROR_PROCEDURE() ,'')
			   				+ ' ErrorLine: ' +  convert(varchar,isnull(ERROR_LINE() ,''))
			   				+ ' ErrorMessage: '+ ERROR_MESSAGE()

		SELECT @ReturnCode 'ReturnCode', @ReturnMsg 'ReturnMessage'

	END CATCH
END


