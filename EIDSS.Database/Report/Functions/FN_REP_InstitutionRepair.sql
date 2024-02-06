
--*************************************************************************
-- Name 				: report.FN_REP_InstitutionRepair
-- DescriptiON			: This function used in report.USP_REP_LAB_AssignmentDiagnosticAZSendToLookup procedure
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
SELECT * FROM report.FN_REP_InstitutionRepair('en')
SELECT * FROM report.FN_REP_InstitutionRepair('az-l')
*/

CREATE FUNCTION [Report].[FN_REP_InstitutionRepair](@LangID  nvarchar(50))
returns table
as
return( 

select			tlbOffice.idfOffice, 
				IsNull(s3.strTextString, b1.strDefault) as EnglishFullName,
				IsNull(s4.strTextString, b2.strDefault) as EnglishName,
				IsNull(s1.strTextString, b1.strDefault) as [FullName],
				IsNull(s2.strTextString, b2.strDefault) as [name],
				tlbOffice.idfsOfficeName,
				tlbOffice.idfsOfficeAbbreviation,
				tlbOffice.idfLocation,
				tlbOffice.strContactPhone,
				tlbOffice.intHACode, 
				tlbOffice.strOrganizationID,
				b1.strDefault, 
				tlbOffice.idfsSite,
				tlbOffice.intRowStatus,
				b2.intOrder
from			dbo.tlbOffice
left outer join	dbo.trtBaseReference as b1 
on				tlbOffice.idfsOfficeName = b1.idfsBaseReference
				--and b1.intRowStatus = 0
left join		dbo.trtStringNameTranslation as s1 
on				b1.idfsBaseReference = s1.idfsBaseReference
				and s1.idfsLanguage = report.FN_GBL_LanguageCode_GET(@LangID)
left join		dbo.trtStringNameTranslation as s3 
on				b1.idfsBaseReference = s3.idfsBaseReference
				and s3.idfsLanguage = report.FN_GBL_LanguageCode_GET(@LangID)

left outer join	dbo.trtBaseReference as b2 
on				tlbOffice.idfsOfficeAbbreviation = b2.idfsBaseReference
				--and b2.intRowStatus = 0
left join		dbo.trtStringNameTranslation as s2 
on				b2.idfsBaseReference = s2.idfsBaseReference
				and s2.idfsLanguage = report.FN_GBL_LanguageCode_GET(@LangID)
left join		dbo.trtStringNameTranslation as s4 
on				b2.idfsBaseReference = s4.idfsBaseReference
				and s4.idfsLanguage = report.FN_GBL_LanguageCode_GET(@LangID)
)




