-- ================================================================================================
-- Name: USP_HUM_HUMAN_DISEASE_INVESTIGATEDBY_UPDATE
--
-- Description: Updates the idfInvestigatedByPerson and strEpidemiologistsName for specific record.
--
-- Author: Leo Tracchia
-- 
-- Revision History:
-- Name					Date		Change Detail
-- -------------------- ----------	---------------------------------------------------------------
-- Leo Tracchia			3/2/2022	Initial Release

-- ================================================================================================

CREATE PROCEDURE [dbo].[USP_HUM_HUMAN_DISEASE_INVESTIGATEDBY_UPDATE]
	@IdfHumanCase				bigint,
	@IdfInvestigatedByPerson	bigint,
	@StrEpidemiologistsName		nvarchar(2000)
AS
BEGIN
	
	SET NOCOUNT ON;	
	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;

	BEGIN TRY

		BEGIN TRANSACTION

			UPDATE tlbHumanCase SET 
				idfInvestigatedByPerson = @IdfInvestigatedByPerson, 
				strEpidemiologistsName = @StrEpidemiologistsName,
				AuditUpdateDTM = getdate(), 
				AuditUpdateUser = @IdfInvestigatedByPerson				
			WHERE idfHumanCase = @IdfHumanCase
			
			IF @@TRANCOUNT > 0 
				COMMIT
						
			SELECT @returnCode 'ReturnCode', @ReturnMessage 'ReturnMessage';			

	END TRY

	BEGIN CATCH
		
		SET @ReturnCode = ERROR_NUMBER();		
		SET @ReturnMessage = ERROR_MESSAGE();
		SELECT @returnCode 'ReturnCode', @ReturnMessage 'ReturnMessage';
		
	END CATCH;

END
