

-- ================================================================================================
-- Name: USP_ADMIN_DEDUPLICATION_DISEASE_ANTIVIRALTHERAPIES_DEL
--
-- Description: Delete an Antimicrobial Therapy record.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Ann Xiong    6/19/2019 Initial release for new API.
--
--
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_DEDUPLICATION_DISEASE_ANTIVIRALTHERAPIES_DEL] 
(
	@LanguageID					NVARCHAR(20),
	@idfAntimicrobialTherapy	BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnCode INT = 0 
	DECLARE	@ReturnMsg NVARCHAR(max) = 'SUCCESS' 

	BEGIN TRY
		BEGIN TRANSACTION
			UPDATE 	dbo.tlbAntimicrobialTherapy
			SET 	intRowStatus = 1						
			WHERE	idfAntimicrobialTherapy = @idfAntimicrobialTherapy
					AND intRowStatus = 0
			
			IF @@TRANCOUNT > 0 
				COMMIT TRANSACTION;
			
			SELECT @ReturnCode 'ReturnCode', @ReturnMsg 'ReturnMsg'
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

		SELECT @ReturnCode, @ReturnMsg

	END CATCH
END
