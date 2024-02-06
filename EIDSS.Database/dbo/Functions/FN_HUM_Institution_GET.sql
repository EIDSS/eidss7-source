

--*************************************************************
-- Name 				: dbo.FN_HUM_Institution_GET
-- Description			: The FUNCTION returns default and translations of offices
--          
-- Author               : Mark Wilson
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*

select * from dbo.FN_HUM_Institution_GET('en-US')

*/
--************************************************************

CREATE FUNCTION [dbo].[FN_HUM_Institution_GET]
(
	@LangID  NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN
( 
	
	SELECT			
		
		O.idfOffice, 
		ISNULL(s3.strTextString, b1.strDefault) AS EnglishFullName,
		ISNULL(s4.strTextString, b2.strDefault) AS EnglishName,
		ISNULL(s1.strTextString, b1.strDefault) AS [FullName],
		ISNULL(s2.strTextString, b2.strDefault) AS [name],
		O.idfsOfficeName,
		O.idfsOfficeAbbreviation,
		O.idfLocation,
		O.strContactPhone,
		O.intHACode, 
		O.strOrganizationID,
		b1.strDefault, 
		st.idfsSite,
		O.intRowStatus,
		b2.intOrder
	FROM dbo.tlbOffice O
	LEFT OUTER JOIN	dbo.trtBaseReference AS b1 ON O.idfsOfficeName = b1.idfsBaseReference
	LEFT JOIN dbo.trtStringNameTranslation AS s1 ON	b1.idfsBaseReference = s1.idfsBaseReference	AND s1.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
	LEFT JOIN dbo.trtStringNameTranslation AS s3 ON	b1.idfsBaseReference = s3.idfsBaseReference	AND s3.idfsLanguage = dbo.FN_GBL_LanguageCode_GET('en-US')
	LEFT OUTER JOIN	dbo.trtBaseReference AS b2 ON O.idfsOfficeAbbreviation = b2.idfsBaseReference
	LEFT JOIN dbo.trtStringNameTranslation AS s2 ON	b2.idfsBaseReference = s2.idfsBaseReference	AND s2.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
	LEFT JOIN dbo.trtStringNameTranslation AS s4 ON	b2.idfsBaseReference = s4.idfsBaseReference	AND s4.idfsLanguage = dbo.FN_GBL_LanguageCode_GET('en-US')
	LEFT JOIN dbo.tstSite AS st ON st.idfOffice = O.idfOffice AND st.intRowStatus = 0

)

