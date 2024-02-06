-- ================================================================================================
-- Name: USP_ADMIN_FF_TemplateSectionOrder_Set
-- Description: Changes the order of a Section
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albanese	04/07/2020	Initial release for new API.
-- Doug Albanese	10/20/2020	Added Auditing Information
-- Doug Albanese	10/28/2021	Refactoring to get EF to generate a proper return model
-- Doug Albanese	03/24/2023	Refactored the entire SP to swap the order of two sections.
-- Doug Albanese	06/12/2023	Added Language to separate the design options for each language.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_TemplateSectionOrder_Set] (
	  @LangId						NVARCHAR(50),
	  @idfsFormTemplate				BIGINT,
	  @idfsCurrentSection			BIGINT,
	  @idfsDestinationSection		BIGINT,
	  @User							NVARCHAR(50) = ''
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION
		 DECLARE @returnCode INT = 0
         DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS'

		 DECLARE @idfSectionDesignOptionCurrent		 BIGINT
		 DECLARE @idfsSectionCurrentOrder			 INT

		 DECLARE @idfSectionDesignOptionDestination	 BIGINT
		 DECLARE @idfsSectionDestinationOrder		 INT

		 DECLARE @langid_int						 BIGINT
		 
		 SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangID);	

		 --Collect Section details to be moved
		 SELECT
			@idfSectionDesignOptionCurrent = idfSectionDesignOption,
			@idfsSectionCurrentOrder = intOrder
		 FROM
			ffSectionDesignOption
		 WHERE
			idfsFormTemplate = @idfsFormTemplate AND
			idfsSection = @idfsCurrentSection AND
			intRowStatus = 0 AND
			idfsLanguage = @langid_int

		 --Collect Destination details for Section to be moved to
		 SELECT
			@idfSectionDesignOptionDestination = idfSectionDesignOption,
			@idfsSectionDestinationOrder = intOrder
		 FROM
			ffSectionDesignOption
		 WHERE
			idfsFormTemplate = @idfsFormTemplate AND
			idfsSection = @idfsDestinationSection AND
			intRowStatus = 0  AND
			idfsLanguage = @langid_int

		 --Swap order between Current and Destination sections
		 UPDATE
			ffSectionDesignOption
		 SET
			intOrder = @idfsSectionDestinationOrder,
			AuditUpdateDTM = GETDATE(),
			AuditUpdateUser = @User
		 WHERE
			idfSectionDesignOption  = @idfSectionDesignOptionCurrent AND
			idfsLanguage = @langid_int
	  
		 --Swap order between Current and Destination sections
		 UPDATE
			ffSectionDesignOption
		 SET
			intOrder = @idfsSectionCurrentOrder,
			AuditUpdateDTM = GETDATE(),
			AuditUpdateUser = @User
		 WHERE
			idfSectionDesignOption  = @idfSectionDesignOptionDestination AND
			idfsLanguage = @langid_int
   

		 SELECT @returnCode AS ReturnCode,
			   @returnMsg AS ReturnMessage

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
