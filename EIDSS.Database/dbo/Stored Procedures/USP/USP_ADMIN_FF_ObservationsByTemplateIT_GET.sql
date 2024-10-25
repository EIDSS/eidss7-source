

-- ================================================================================================
-- Name: USP_ADMIN_FF_Observations_GET
-- Description: Retrieves the list of Observations By Template
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Lamont  mitchell    9/19/19 Initial release for new API.
-- ================================================================================================
CREATE  PROCEDURE [dbo].[USP_ADMIN_FF_ObservationsByTemplateIT_GET]
(
	@FormTemplate NVARCHAR(MAX)	
)
AS
BEGIN

	DECLARE
		@returnCode BIGINT,
		@returnMsg  NVARCHAR(MAX)       
	
	BEGIN TRY
	   SELECT idfObservation
			  ,idfsFormTemplate
	   FROM dbo.tlbObservation
	   WHERE idfsFormTemplate = @FormTemplate and intRowStatus = 0
	END TRY 
	BEGIN CATCH   
			THROW;
	END CATCH; 
END

