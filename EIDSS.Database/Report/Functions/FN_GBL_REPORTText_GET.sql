

/*
--*************************************************************
-- Name 				: report.FN_GBL_REPORTText_GET
-- Description			: Function is used to return Report Labels text for Mutiple Languages.
--          
-- Author               : Srini Goli
-- Revision History
--		Name		Date		Change Detail
--		Srini Goli	02/18/2020	if no texts are available for selected language defaulted to english
-- Testing code:
-- SELECT * FROM report.tlbReports
-- SELECT idfsReportTextID,strTextString FROM [report].[FN_GBL_REPORTText_GET]('en',1)  -- Report Spacific
-- SELECT idfsReportTextID,strTextString FROM [report].[FN_GBL_REPORTText_GET]('az-L',1)  -- Report Spacific
-- SELECT idfsReportTextID,strTextString FROM [report].[FN_GBL_REPORTText_GET]('en',9999) -- Common for all Reports
-- SELECT idfsReportTextID,strTextString FROM [report].[FN_GBL_REPORTText_GET]('ru',13)
SELECT * FROM report.FN_GBL_LanguageCode_GET('en-US')
--*************************************************************
*/
CREATE FUNCTION [Report].[FN_GBL_REPORTText_GET]
(
	@LangID NVARCHAR(50),
	@ReportID BIGINT
)
RETURNS TABLE
AS
	RETURN(
	
			SELECT		RSTR.idfsReportTextID,COALESCE(RT.strResourceString,RST.strTextString, R.strResourceName)  AS strTextString 
			FROM dbo.trtResourceSetToResource RSTR
			INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
			LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
			LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
			LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
			WHERE RSTR.idfsResourceSet=@ReportID

		)

