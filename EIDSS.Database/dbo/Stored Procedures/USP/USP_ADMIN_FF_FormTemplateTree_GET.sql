
-- ================================================================================================
-- Name: USP_ADMIN_FF_Parameters_GET
-- Description: Gets list of the Parameters.
--          
-- Revision History:
-- Name				Date			Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albabese	12/23/2019	Initial release for new API.
-- Doug Albanese	4/20/2020	Filter by Form Type
-- Doug Albanese	4/20/2020	Added Un-used Form Types
-- Doug Albanese	5/11/2020	Corrected an issue where deleted items were being picked up
-- Doug Albanese	10/28/2020	Corrected to return list in the language requested
-- ================================================================================================

CREATE PROCEDURE [dbo].[USP_ADMIN_FF_FormTemplateTree_GET]
(
	@LangID					NVARCHAR(50) = NULL,
	@idfsFormType			AS BIGINT = NULL
)	
AS
BEGIN	

	DECLARE	@returnCode								INT = 0;
	DECLARE @returnMsg								NVARCHAR(MAX) = 'SUCCESS';

	BEGIN TRY

		DECLARE @TemplateTree TABLE (
			idfsFormType BIGINT,
			FormType NVARCHAR(MAX),
			idfsFormTemplate BIGINT,
			FormTemplate NVARCHAR(MAX)
		)

		INSERT INTO @TemplateTree
		SELECT
			ft.idfsFormType, ft2.name AS FormType, ft.idfsFormTemplate, ft3.name AS FormTemplate
		FROM
			ffFormTemplate ft
		LEFT JOIN FN_GBL_Reference_GETList(@LangID, 19000034) ft2
			ON ft2.idfsReference = ft.idfsFormType
		LEFT JOIN FN_GBL_Reference_GETList(@LangID, 19000033) ft3
			ON ft3.idfsReference = ft.idfsFormTemplate
		WHERE
			ft2.name IS NOT NULL AND
			ft3.name IS NOT NULL AND
			ft.intRowStatus = 0

		--Add unused form types
		INSERT INTO @TemplateTree
		SELECT idfsReference AS idfsFormType,[name] AS FormType,'', ''
		FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000034) ft 
		WHERE idfsReference IN (10034007,10034011,10034015,10034501,10034502,10034503,10034504,10034505,10034506,10034507,10034508,10034509) AND
		idfsReference NOT IN (SELECT DISTINCT idfsFormType FROM ffFormTemplate)
		
		IF @idfsFormType IS NOT NULL
			BEGIN
				DELETE FROM @TemplateTree
				WHERE idfsFormType <> @idfsFormType
			END
		
		SELECT
			CAST(idfsFormType AS NVARCHAR(MAX)) + '¦' + FormType + '!' + CAST(idfsFormTemplate AS NVARCHAR(MAX)) + '¦' + FormTemplate + '!' AS Template
		FROM
			@TemplateTree
		ORDER BY
			FormType

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT = 1 
			ROLLBACK;
		
		SET		@returnCode = ERROR_NUMBER();
		SET		@returnMsg = 
					'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
					+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
					+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
					+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '')
					+ ' ErrorLine: ' +  CONVERT(VARCHAR, ISNULL(ERROR_LINE(), ''))
					+ ' ErrorMessage: '+ ERROR_MESSAGE();

		;throw;
	END CATCH

END

