

--##REMARKS UPDATED BY: Vorobiev E. --deleted tlbCase
--##REMARKS Date: 17.04.2013

-- select * from report.FN_Event_SelectList('ka')


CREATE FUNCTION [Report].[FN_Event_SelectList](@LangID AS NVARCHAR(50))
RETURNS TABLE 
AS
RETURN
SELECT			
				tstEvent.idfEventID,
				EventType.[name] AS strEventTypeName,  
				tstEvent.idfObjectID, 
				tstEvent.strInformationString, 
				tstEvent.strNote, 
			    tstEvent.idfsEventTypeID,
				tstEvent.datEventDatatime,
				tlbPerson.idfPerson,
				dbo.FN_GBL_ConcatFullName(strFamilyName, strFirstName, strSecondName) AS strPersonName,
				CASE 
					WHEN tlbHumanCase.idfHumanCase IS NOT NULL THEN 10012001
					ELSE tlbVetCase.idfsCaseType
				END AS idfsCaseType

FROM			(
	tstEvent 
	INNER JOIN		report.FN_GBL_ReferenceRepair_GET(@LangID,19000025) AS EventType --'rftEventType'
	ON				tstEvent.idfsEventTypeID = EventType.idfsReference
				)
	LEFT OUTER JOIN	(
	tstUserTable 
/*
	INNER JOIN		Employee 
	on				Employee.idfEmployee = UserTable.idfEmployee
					--and (Employee.intRowStatus = 0 or Employee.intRowStatus is null) 
*/
	INNER JOIN		tlbPerson 
	ON				tlbPerson.idfPerson = tstUserTable.idfPerson
				)
	ON				tstUserTable.idfUserID = tstEvent.idfUserID
	LEFT JOIN		tlbHumanCase
	ON				tlbHumanCase.idfHumanCase = tstEvent.idfObjectID
	LEFT JOIN		tlbVetCase
	ON				tlbVetCase.idfVetCase = tstEvent.idfObjectID

WHERE
	tstEvent.idfsEventTypeID <> 10025001 --'evtLanguageChanged'




