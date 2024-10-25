



--*************************************************************************
-- Name 				: report.USP_GBL_Language_GET
-- Description			: List of Languages
--						  - used in Reports to select languages
--          
-- Author               : Mark Wilson
-- Revision History
--		Name			Date       Change Detail
--		Srini Goli		1/3/2020   To Display selected Languages
-- Testing code:
--
-- EXEC report.USP_GBL_Language_GET
-- EXEC report.USP_GBL_Language_GET 'en-US,ru,az-Latn-AZ'
-- SELECT * FROM dbo.trtBaseReference WHERE idfsReferenceType=19000049
--*************************************************************************

CREATE PROCEDURE [Report].[USP_GBL_Language_GET]
(
	 @LanguageIDList AS NVARCHAR(MAX)= NULL
)
AS
DECLARE @returnCode					INT = 0 
DECLARE	@returnMsg					NVARCHAR(MAX) = 'SUCCESS' 

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		
		DECLARE @LanguageTable	TABLE
		(
				idfsLanguage BIGINT		
		)	
	
		INSERT INTO @LanguageTable 
 
		SELECT dbo.FN_GBL_LanguageCode_GET(CAST([Value] as NVARCHAR(50))) FROM report.FN_GBL_SYS_SplitList(@LanguageIDList,1,',')

		SELECT  
			idfsBaseReference AS idfsLanguage,
			strDefault AS [Language],
			strBaseReferenceCode AS [LangID]

		FROM dbo.trtBaseReference 

		WHERE idfsReferenceType = 19000049
		
		AND ''=ISNULL(LTRIM(@LanguageIDList),'') OR idfsBaseReference in (SELECT idfsLanguage FROM @LanguageTable)
		
		IF @@TRANCOUNT > 0 AND @returnCode = 0
			COMMIT

		SELECT @returnCode, @returnMsg

	END TRY

	BEGIN CATCH
	
		IF @@Trancount = 1 
			ROLLBACK
			SET @returnCode = ERROR_NUMBER()
			SET @returnMsg = 
			'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
			+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
			+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
			+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
			+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
			+ ' ErrorMessage: '+ ERROR_MESSAGE()

			SELECT @returnCode, @returnMsg

	END CATCH

END



