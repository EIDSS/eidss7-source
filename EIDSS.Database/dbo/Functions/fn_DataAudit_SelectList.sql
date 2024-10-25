

--##SUMMARY Returns list of data audit events.

--##REMARKS Author: Zurin M.
--##REMARKS Create date: 12.04.2010

--##RETURNS Returns list of data audit events.
-- Manickandan Govindarajan 01/24/2023 Added more columns



/*
Example of function call:

SELECT * FROM fn_DataAudit_SelectList ('en') 

*/


create   FUNCTION [dbo].[fn_DataAudit_SelectList](
	@LangID as nvarchar(50) --##PARAM @LangID - language ID
)
returns table 
as
return

SELECT idfDataAuditEvent
	  ,idfsDataAuditObjectType AS idfsObjectType
      ,ObjectType.name AS ObjectType
      ,tauDataAuditEvent.idfsDataAuditEventType AS idfsActionName
      ,EventType.name AS ActionName
      ,tstSite.idfsSite
      ,tstSite.idfOffice
      ,tstSite.strSiteID
      ,datEnteringDate
      ,dbo.tauDataAuditEvent.idfMainObject
      ,dbo.tauDataAuditEvent.idfMainObjectTable
      ,tauDataAuditEvent.idfUserID
      ,tlbPerson.idfPerson
	  ,dbo.fnConcatFullName(strFamilyName, strFirstName, strSecondName)  AS strPersonName,
	  tauDataAuditEvent.idfsDataAuditEventType,
	  tauDataAuditEvent.idfsDataAuditObjectType,
	  tauDataAuditEvent.strMainObject,
	  tstSite.strSiteName,
	  tlbPerson.strFirstName,
	  tlbPerson.strFamilyName,
	  tlbPerson.strSecondName


FROM			dbo.tauDataAuditEvent
INNER JOIN		fnReferenceRepair(@LangID,19000016) AS EventType --'rftDataAuditEventType'
		ON		tauDataAuditEvent.idfsDataAuditEventType = EventType.idfsReference
				
INNER JOIN		fnReferenceRepair(@LangID,19000017) AS ObjectType --'rftDataAuditObjectType'
		ON		tauDataAuditEvent.idfsDataAuditObjectType = ObjectType.idfsReference
				
LEFT OUTER JOIN	(
							tstUserTable 
				INNER JOIN	tlbPerson 
					ON		tlbPerson.idfPerson = tstUserTable.idfPerson
				)
		ON		tstUserTable.idfUserID = tauDataAuditEvent.idfUserID

INNER JOIN		tstSite
		ON		tauDataAuditEvent.idfsSite = tstSite.idfsSite
	


