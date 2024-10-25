
--*************************************************************
-- Name: [USP_OMM_FlexForm_Set]
-- Description: This procedure sets the Template Id of a Flex Form for use within Outbreak for a specific case
--          
-- Author: Doug Albanese
-- Revision History
--	Name			Date		Change Detail
--	Doug Albanese	4/282/2020	Initial Creation for Flex Form designation in Outbreak
--*************************************************************
CREATE PROCEDURE [dbo].[USP_OMM_FlexForm_Set]
(    
	@idfsFormTemplate					BIGINT,
	@idfOutbreakSpeciesParameterUID		BIGINT,
	@strFormCategory					NVARCHAR(20)		
)
AS

BEGIN    

	DECLARE	@returnCode					INT = 0;
	DECLARE @returnMsg					NVARCHAR(MAX) = 'SUCCESS';

	BEGIN TRY
		
		IF @strFormCategory ='Monitoring'
			BEGIN
				UPDATE
					OutbreakSpeciesParameter
				SET
					CaseMonitoringTemplateID = @idfsFormTemplate
				WHERE
					OutbreakSpeciesParameterUID = @idfOutbreakSpeciesParameterUID
			
			END

		IF @strFormCategory ='Tracing'
			BEGIN
				UPDATE
					OutbreakSpeciesParameter
				SET
					ContactTracingTemplateID  = @idfsFormTemplate
				WHERE
					OutbreakSpeciesParameterUID = @idfOutbreakSpeciesParameterUID
			END

		IF @strFormCategory ='Questionnaire'
			BEGIN
				UPDATE
					OutbreakSpeciesParameter
				SET
					CaseQuestionaireTemplateID  = @idfsFormTemplate
				WHERE
					OutbreakSpeciesParameterUID = @idfOutbreakSpeciesParameterUID
			END

	END TRY
	BEGIN CATCH
		Throw;
	END CATCH

	SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'

END
