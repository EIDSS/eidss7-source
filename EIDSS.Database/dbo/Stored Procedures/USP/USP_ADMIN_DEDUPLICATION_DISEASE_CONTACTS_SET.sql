-- ================================================================================================
-- Name: USP_ADMIN_DEDUPLICATION_DISEASE_CONTACTS_SET
--
-- Description: Update column idfHumanCase in tlbContactedCasePerson.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Ann Xiong    6/5/2019 Initial release for new API.
-- Ann Xiong    6/12/2019 Added idfContactedCasePerson
-- Ann Xiong    7/2/2019 Added script to select idfHuman from idfHumanCase and update idfHuman
-- ================================================================================================

CREATE PROCEDURE [dbo].[USP_ADMIN_DEDUPLICATION_DISEASE_CONTACTS_SET]
	@idfContactedCasePerson			BIGINT NULL, 
 	@SurvivorHumanDiseaseReportID		BIGINT = NULL,
	@SupersededHumanDiseaseReportID		BIGINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnCode INT = 0 
	DECLARE	@ReturnMsg NVARCHAR(max) = 'SUCCESS' 
	DECLARE	@idfHuman	BIGINT

	BEGIN TRY

		BEGIN TRANSACTION

			SELECT	@idfHuman = idfHuman
			FROM	tlbHumanCase
			WHERE	idfHumanCase = @SurvivorHumanDiseaseReportID

			UPDATE 	dbo.tlbContactedCasePerson
			SET 	idfHumanCase   = @SurvivorHumanDiseaseReportID,
			 		idfHuman   = @idfHuman					
			WHERE	idfHumanCase   = @SupersededHumanDiseaseReportID and idfContactedCasePerson = @idfContactedCasePerson
			
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

		SELECT @ReturnCode 'ReturnCode', @ReturnMsg 'ReturnMsg'

	END CATCH
END
