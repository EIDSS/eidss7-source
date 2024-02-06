
--*************************************************************
-- Name: [USP_OMM_Session_GetList]
-- Description: Insert/Update for Campaign Monitoring Session
--          
-- Author: Doug Albanese
-- Revision History
--	Name			Date		Change Detail
--	Doug Albanese	10/08/2021	Refactored to use language translation
--*************************************************************
CREATE PROCEDURE [dbo].[USP_OMM_Session_Note_GetList]
(    
	@LangID			nvarchar(50),
	@idfOutbreak	BIGINT
)
AS

BEGIN    
		
		SELECT 
			idfOutbreakNote,
			idfOutbreak,
			NoteRecordUID,
			strNote,
			datNoteDate,
			OBN.idfPerson,
			P.strFirstName + ' ' + P.strFamilyName AS UserName,
			B.strDefault AS Organization,
			OBN.intRowStatus,
			OBN.rowguid,
			OBN.strMaintenanceFlag,
			OBN.strReservedAttribute,
			UpdatePriorityID,
			UP.name AS UpdatePriority,
			UpdateRecordTitle,
			Coalesce(UploadFileName,'') AS UploadFileName,
			UploadFileDescription,
			CAST(CASE UploadFileName WHEN Coalesce(UploadFileName,'') THEN 'View' ELSE '' END AS NVARCHAR(50)) AS FileView
		FROM
			tlbOutbreakNote OBN
		INNER JOIN		tlbPerson P											ON P.idfPerson = OBN.idfPerson
		INNER JOIN		tlbOffice O											ON O.idfOffice = P.idfInstitution
		INNER JOIN		FN_GBL_ReferenceRepair_GET(@LangID, 19000045) B		ON B.idfsReference = O.idfsOfficeAbbreviation
		INNER JOIN		FN_GBL_ReferenceRepair_GET(@LangID, 19000518) UP	ON UP.idfsReference = obn.UpdatePriorityID
		
		WHERE
			idfOutbreak = @idfOutbreak AND
			OBN.intRowStatus = 0
END
