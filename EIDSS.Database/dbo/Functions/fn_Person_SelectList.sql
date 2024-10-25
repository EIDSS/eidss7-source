






--##SUMMARY Selects list of employees for PersonList form

--##REMARKS Author: Zurin M.
--##REMARKS Update date: 19.01.2010

--##RETURNS Doesn't use

/*
--Example of a call of procedure:

SELECT * FROM fn_Person_SelectList('en')
*/


CREATE    FUNCTION [dbo].[fn_Person_SelectList](
	@LangID AS NVARCHAR(50) --##PARAM @LangID - language ID
)
RETURNS TABLE 
AS
RETURN

SELECT		tlbPerson.idfPerson AS idfEmployee, 
			tlbPerson.strFirstName,
			tlbPerson.strSecondName,
			tlbPerson.strFamilyName,
			dbo.FN_GBL_ConcatFullName(tlbPerson.strFamilyName,tlbPerson.strFirstName,tlbPerson.strFamilyName) as PersonFulLName,
			Organization.[name] AS Organization,
			Organization.FullName AS OrganizationFullName,
			Organization.strOrganizationID,
			tlbPerson.idfInstitution,
			Position.[name] AS strRankName,
			Position.idfsReference AS idfRankName

FROM	tlbPerson
INNER JOIN	tlbEmployee
	ON		tlbEmployee.idfEmployee = tlbPerson.idfPerson
			AND tlbEmployee.intRowStatus = 0		
LEFT JOIN FN_GBL_ReferenceRepair(@LangID, 19000073 /*rftPosition*/) Position	
	ON		tlbPerson.idfsStaffPosition = Position.idfsReference
LEFT JOIN	FN_GBL_Institution(@LangID) AS Organization
	ON		Organization.idfOffice = tlbPerson.idfInstitution

--WHERE ISNULL(tlbPerson.strFirstName, '') <> ''
--	OR ISNULL(tlbPerson.strSecondName, '') <> ''
--	OR ISNULL(tlbPerson.strFamilyName, '') <> ''


