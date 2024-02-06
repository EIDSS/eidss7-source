-- ================================================================================================
-- Name: USP_ADMIN_FF_TemplateDesign_GET
-- Description: Returns list of Sections/Parameters
--          
--	Revision History:
--	Name            Date		Change
--	--------------- ----------	--------------------------------------------------------------------
--	Doug Albanese	02/26/2020	Initial release for new API.
--	Doug Albanese	04/06/2020	Addition of automatic intOrder assignment for NULL or zero values
--	Doug Albanese	04/07/2020	return column name change to seperate section from parameters for intOrder
--	Doug Albanese	04/27/2020	Clean up for new templates created where nulls are only the response
--	Doug Albanese	05/11/2020	Correct for duplicate rows being returned
--	Doug Albanese	10/28/2020	Corrected the result to handle missing section data.
--	Doug Albanese	01/06/2021	Added idfsEditMode to handle the status of a parameter's required validation
--	Doug Albanese	01/21/2021	Correction to force the ordering of sections and parameters for a flex form, plus used the new translation function
--	Doug Albanese	01/22/2021	Design Option join didn't include the base reference language id.
--	Doug Albanese	05/21/2021	Refactored to produce "Sectionless" parameters
--	Doug Albanese	05/25/2021	Corrected an intRowStatus problem for parameters getting picked up, when they were deleted.
--	Doug Albanese	07/04/2021  Correction to force template design to come through for the Flex Form Designer
--	Doug Albanese	07/06/2021	Added Observations to the output to determine if a template is locked for specific funtionality
--	Doug Albanese	07/08/2021	Removed idfsSection and idfsParameter from ordering
--	Doug Albanese	10/28/2021	Removed the old concept of reordering parameters/sections, when they have 0 for intOrder
--	Doug Albanese	03/15/2022	Added a USSP to resolve any design option problems. Also added auditing information for the user requesting this call
--	Doug Albanese	03/16/2022	Changed out USSP_ADMIN_FF_DesignOptionsRefresh with USSP_ADMIN_FF_DesignOptionsRefresh_SET
--	Doug Albanese	05/09/2022	Cleaning up duplicates
--	Doug Albanese	05/23/2022	Missing Section Options requires a LEFT JOIN to continue without error
--	Doug Albanese	06/07/2022	Filtered output to only display items that have parameters. Nulls were showing up previously
--  Doug Albanese	03/03/2023	Added Editor Type to the return
--  Doug Albanese	04/04/2023	Refactored to correctly pick up objects pertaining to a specific template.
--  Doug Albanese	04/10/2023	Section data doesn't always exists, so a LEFT Join used on section related tables.
--	Doug Albanese	04/14/2023	Changed size of "Name" fields from 200 to 2000
--  Doug Albanese   04/18/2023	Swapped out fnGetLanguageCode for dbo.FN_GBL_LanguageCode_GET(@LangID);	
--  Doug Albanese	06/07/2023	Added 'System' for the auto refresh of any design options that may be missing
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_TemplateDesign_GET] (
	@langid				NVARCHAR(50),
	@idfsFormTemplate	BIGINT = NULL,
	@User				NVARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE		@langid_int				BIGINT
				,@returnCode			BIGINT
				,@returnMsg				NVARCHAR(MAX)

	BEGIN TRY
		BEGIN TRANSACTION

		SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangID);	

		--On occasion, Parameters and Sections do not have any Design Options associated with them. The following SP will create them so that ordering information will be available.
		--If ordering information is all null, or zeros...then they will be reassigned new numbers, and kept in the same order as they were before.
		EXEC USSP_ADMIN_FF_DesignOptionsRefresh_SET @LangId= @langid, @idfsFormTemplate = @idfsFormTemplate, @User = 'System'

		DECLARE @TemplateDesign TABLE (
			idfsSection					BIGINT,
			idfsParentSection			BIGINT,
			idfsParameter				BIGINT,
			idfsEditor					BIGINT,
			idfsParameterType			BIGINT,
			idfsParameterCaption		BIGINT,
			intSectionOrder				INT,
			intParameterOrder			INT,
			ParameterName				NVARCHAR(2000),
			SectionName					NVARCHAR(2000),
			idfsEditMode				BIGINT,
			Observations				INT
		)
		
		DECLARE @iObservations		INT

		SELECT
			@iObservations = COUNT(idfObservation)
		FROM
			tlbObservation O
		INNER JOIN ffFormTemplate FT
			ON FT.idfsFormTemplate = O.idfsFormTemplate
			AND FT.intRowStatus = 0
		WHERE
			O.idfsFormTemplate = @idfsFormTemplate

		INSERT INTO @TemplateDesign (idfsSection,idfsParentSection,idfsParameter,idfsEditor,idfsParameterType,idfsParameterCaption,intSectionOrder,intParameterOrder,ParameterName,SectionName,idfsEditMode,Observations)
		 SELECT 
			   COALESCE(s.idfsSection, -1) AS idfsSection
			   ,s.idfsParentSection
			   ,p.idfsParameter
			   ,p.idfsEditor
			   ,p.idfsParameterType
			   ,p.idfsParameterCaption
			   ,sdo.intOrder AS intSectionOrder
			   ,pdo.intOrder AS intParameterOrder
			   ,pn.name AS ParameterName
			   ,sn.name AS SectionName
			   ,pft.idfsEditMode
			   ,@iObservations AS Observations
		 FROM
			   ffFormTemplate ft
		 INNER JOIN ffParameterForTemplate pft ON pft.idfsFormTemplate = ft.idfsFormTemplate and pft.intRowStatus = 0
		 INNER JOIN ffParameter p ON p.idfsParameter = pft.idfsParameter and p.intRowStatus = 0
		 INNER JOIN ffSection s ON s.idfsSection = p.idfsSection and s.intRowStatus = 0
		 LEFT JOIN ffSectionForTemplate sft ON sft.idfsSection = s.idfsSection and sft.idfsFormTemplate = @idfsFormTemplate and sft.intRowStatus = 0
		 INNER JOIN ffParameterDesignOption pdo ON pdo.idfsParameter = p.idfsParameter and pdo.idfsFormTemplate = @idfsFormTemplate and pdo.idfsLanguage = @langid_int and pdo.intRowStatus = 0
		 LEFT JOIN ffSectionDesignOption sdo ON sdo.idfsSection = s.idfsSection and sdo.idfsFormTemplate = @idfsFormTemplate and sdo.idfsLanguage = @langid_int and sdo.intRowStatus = 0
		 INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000066) pn
						   ON pn.idfsReference = p.idfsParameter
		 INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000101) sn
						   ON sn.idfsReference = s.idfsSection
		 WHERE 
			   ft.idfsFormTemplate = @idfsFormTemplate 

		 INSERT INTO @TemplateDesign (idfsSection,idfsParentSection,idfsParameter,idfsEditor,idfsParameterType,idfsParameterCaption,intSectionOrder,intParameterOrder,ParameterName,SectionName,idfsEditMode, Observations)
		 SELECT 
			   -1 AS idfsSection --????
			   ,NULL As idfsParentSection
			   ,p.idfsParameter
			   ,p.idfsEditor
			   ,p.idfsParameterType
			   ,p.idfsParameterCaption
			   ,0 AS intSectionOrder
			   ,pdo.intOrder AS intParameterOrder
			   ,pn.name AS ParameterName
			   ,'' AS SectionName
			   ,pft.idfsEditMode
			   ,@iObservations
		 FROM
			   ffFormTemplate ft
		 INNER JOIN ffParameterForTemplate pft 
			   ON pft.idfsFormTemplate = ft.idfsFormTemplate and pft.intRowStatus = 0
		 INNER JOIN ffParameter p ON p.idfsParameter = pft.idfsParameter and p.intRowStatus = 0
		 INNER JOIN ffParameterDesignOption pdo ON pdo.idfsParameter = p.idfsParameter and pdo.idfsFormTemplate = @idfsFormTemplate and pdo.idfsLanguage = @langid_int and pdo.intRowStatus = 0
		 INNER JOIN dbo.FN_GBL_ReferenceRepair(@langid, 19000066) pn
						   ON pn.idfsReference = p.idfsParameter
		 WHERE 
			   ft.idfsFormTemplate = @idfsFormTemplate and 
			   p.idfsSection IS NULL
		
		SELECT
			idfsParentSection,
			idfsSection,
			SectionName,
			intSectionOrder,
			idfsParameter,
			ParameterName,
			intParameterOrder,
			idfsEditor,
			idfsParameterType,
			idfsParameterCaption,
			idfsEditMode,
			Observations
		FROM
			@TemplateDesign
		WHERE
			idfsParameter IS NOT NULL
		ORDER BY
			intSectionOrder,
			intParameterOrder

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
