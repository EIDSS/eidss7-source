
--=====================================================================================================
-- Created by:				Joan Li
-- Last modified date:		04/19/2017
-- Last modified by:		Joan Li
-- Description:				04/19/2017: Created based on V6 spPerson_SelectDetail : rename for V7
--                          04/26/2017: change name to : usp_Person_GetDetail
--                          Input: personid, languageid; Output: person list, group list
--                          07/03/2017: JL open user blocked code
-- Version History
--
--	Mark Wilson		08/05/2021	Edited to use E7 FN and removed reference to 'en'
-- Testing code:
/*
----testing code:

Valid values for idfPerson are:

SELECT 
	DISTINCT EM.idfEmployee 

FROM dbo.tlbEmployeeGroupMember EM
INNER JOIN dbo.tlbEmployee E ON E.idfEmployee = EM.idfEmployee and E.intRowStatus =0 AND E.idfsEmployeeType = 10023002
INNER JOIN dbo.tlbPerson P ON P.idfPerson = E.idfEmployee AND P.intRowStatus = 0

WHERE EM.intRowStatus = 0

DECLARE @idfPerson BIGINT = 3238450000000
exec usp_Person_GetDetail @idfPerson, 'en-US'
*/

--====================================================================================================
CREATE PROCEDURE [dbo].[usp_Person_GetDetail]

( 

	@idfPerson AS BIGINT,  --##PARAM @idfPerson - person ID
	@LangID NVARCHAR(50) --##PARAM @LangID - language ID

)	

AS

SELECT 
	P.idfPerson,
	P.idfsStaffPosition,
	P.idfInstitution,
	P.idfDepartment,
	P.strFamilyName,
	P.strFirstName,
	P.strSecondName,
	P.strContactPhone,
	P.strBarcode,
	E.idfsSite

FROM dbo.tlbPerson P
INNER JOIN dbo.tlbEmployee E ON	P.idfPerson = E.idfEmployee AND E.intRowStatus = 0 

WHERE E.idfEmployee = @idfPerson
AND E.idfsEmployeeType = 10023002 --Person 

SELECT	 
	UT.idfUserID,
	UT.idfPerson,
	UT.idfsSite,
	UT.strAccountName,
	S.strSiteID,
	S.strSiteName,
	S.idfsSiteType,
	ISNULL(Rf.name, Rf.strDefault) AS strSiteType

FROM dbo.tstUserTable UT
INNER JOIN dbo.tstSite S ON S.idfsSite = UT.idfsSite AND S.intRowStatus = 0
INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000085/*Site Type*/) Rf ON S.idfsSiteType = Rf.idfsReference
WHERE UT.idfPerson = @idfPerson
AND UT.intRowStatus = 0
 

-- Groups
SELECT		
	EG.idfEmployeeGroup,
	EG.idfsEmployeeGroupName,
	E.idfEmployee,
	ISNULL(GroupName.name,EG.strName) AS strName,
	EG.strDescription

FROM dbo.tlbEmployeeGroup EG

INNER JOIN dbo.tlbEmployeeGroupMember EM ON	EM.idfEmployeeGroup=EG.idfEmployeeGroup
INNER JOIN dbo.tlbEmployee E ON E.idfEmployee=EM.idfEmployee
LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000022) GroupName ON GroupName.idfsReference = EG.idfsEmployeeGroupName

WHERE E.intRowStatus = 0 
AND EG.idfEmployeeGroup <> -1 
AND EG.intRowStatus = 0
AND EM.intRowStatus = 0
AND E.idfEmployee = @idfPerson



