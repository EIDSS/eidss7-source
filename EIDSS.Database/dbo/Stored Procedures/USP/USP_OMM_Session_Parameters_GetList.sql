
--*************************************************************
-- Name: [USP_OMM_Session_GetList]
-- Description: Insert/Update for Campaign Monitoring Session
--          
-- Author: Doug Albanese
-- Revision History
--	Name			Date		Change Detail
--	Doug Albanese	09/07/2021	Removed the date and user info.
--*************************************************************
CREATE PROCEDURE [dbo].[USP_OMM_Session_Parameters_GetList]
(    
	@LangID			nvarchar(50),
	@idfOutbreak	BIGINT
)
AS

BEGIN    

	BEGIN TRY
			
		SELECT
			OutbreakSpeciesParameterUID,
			idfOutbreak,
			OutbreakSpeciesTypeID,
			CaseMonitoringDuration,
			CaseMonitoringFrequency,
			ContactTracingDuration,
			ContactTracingFrequency,
			intRowStatus,
			CaseQuestionaireTemplateID,
			CaseMonitoringTemplateID,
			ContactTracingTemplateID
		FROM
			OutbreakSpeciesParameter
		WHERE
			idfOutbreak = @idfOutbreak AND
			intRowStatus = 0
			
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT = 1 
			ROLLBACK;
	END CATCH

	

END
