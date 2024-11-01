﻿

--*************************************************************
-- Name 				: [FN_GBL_InstitutionRepair]
-- Description			:  Get the institution data
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name       Date       Change Detail
-- --------------- ---------- ---------------------------------
-- Stephen Long    09/24/2021 Added organization type ID.
--
-- Testing code:
/*


SELECT * FROM FN_GBL_InstitutionRepair ('en-US')


*/
--*************************************************************
CREATE FUNCTION [dbo].[FN_GBL_InstitutionRepair](@LangID  NVARCHAR(50))
RETURNS TABLE
AS
RETURN
	( 

		SELECT	tlbOffice.idfOffice, 
				ISNULL(s3.strTextString, b1.strDefault) AS EnglishFullName,
				ISNULL(s4.strTextString, b2.strDefault) AS EnglishName,
				ISNULL(s1.strTextString, b1.strDefault) AS [FullName],
				ISNULL(s2.strTextString, b2.strDefault) AS [name],
				tlbOffice.idfsOfficeName,
				tlbOffice.idfsOfficeAbbreviation,
				tlbOffice.idfLocation,
				tlbOffice.strContactPhone,
				tlbOffice.intHACode, 
				tlbOffice.strOrganizationID,
				tlbOffice.OrganizationTypeID,
				b1.strDefault, 
				tlbOffice.idfsSite,
				tlbOffice.intRowStatus,
				b2.intOrder
		FROM dbo.tlbOffice
		LEFT OUTER JOIN	dbo.trtBaseReference AS b1 
		ON		tlbOffice.idfsOfficeName = b1.idfsBaseReference
					--and b1.intRowStatus = 0
		LEFT JOIN	dbo.trtStringNameTranslation AS s1 
		ON		b1.idfsBaseReference = s1.idfsBaseReference
		AND		s1.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
		LEFT JOIN	dbo.trtStringNameTranslation AS s3 
		ON		b1.idfsBaseReference = s3.idfsBaseReference
		AND		s3.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
		LEFT OUTER JOIN	dbo.trtBaseReference AS b2 
		ON		tlbOffice.idfsOfficeAbbreviation = b2.idfsBaseReference
						--and b2.intRowStatus = 0
		LEFT JOIN	dbo.trtStringNameTranslation AS s2 
		ON		b2.idfsBaseReference = s2.idfsBaseReference
		AND		s2.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
		LEFT JOIN	dbo.trtStringNameTranslation AS s4 
		ON		b2.idfsBaseReference = s4.idfsBaseReference
		AND		s4.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
	)



