
CREATE FUNCTION [dbo].[FN_GBL_Department](@LangID NVARCHAR(50))
RETURNS TABLE
AS
RETURN(
 
SELECT			tlbDepartment.idfDepartment,
				tlbDepartment.idfOrganization AS idfInstitution,
				trtBaseReference.strDefault AS DefaultName,
				ISNULL(trtStringNameTranslation.strTextString, trtBaseReference.strDefault) AS name,
				trtBaseReference.intHACode,
				trtBaseReference.strDefault,
				trtBaseReference.intRowStatus

FROM		tlbDepartment

LEFT JOIN	dbo.trtBaseReference
ON			tlbDepartment.idfsDepartmentName = trtBaseReference.idfsBaseReference
			--and trtBaseReference.intRowStatus = 0

LEFT JOIN	dbo.trtStringNameTranslation
ON			tlbDepartment.idfsDepartmentName = trtStringNameTranslation.idfsBaseReference
			AND trtStringNameTranslation.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)

WHERE		tlbDepartment.intRowStatus = 0
)


