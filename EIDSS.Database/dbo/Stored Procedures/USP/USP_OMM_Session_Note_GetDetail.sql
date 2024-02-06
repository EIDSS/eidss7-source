

--*************************************************************
-- Name: [USP_OMM_Session_Note_GetDetail]
-- Description: Insert/Update for Outbreak Session Note
--          
-- Author: Doug Albanese
-- Revision History
--	Name			Date		Change Detail
--	Doug Albanese	10/05/2021	Removed catch details that were interferring with EF.
--	Mark Wilson		10/06/2021	joined with dbo.FN_GBL_ReferenceRepair_GET, qualified all fields.
--								added testing code
--	Doug Albanese	10/08/2021	Added text field for Priority (needed because of select2 prepopulation)
--	Doug Albanese	10/12/2021	Refactored to get EF return.
--	Doug Albanese	10/12/2021	Added NoteRecordUID
/* Testing code

EXEC dbo.USP_OMM_Session_Note_GetDetail
	@LangID = N'az-Latn-AZ',
	@idfOutbreakNote = 1

EXEC dbo.USP_OMM_Session_Note_GetDetail
	@LangID = N'en-US',
	@idfOutbreakNote = 1

*/
--*************************************************************
CREATE PROCEDURE [dbo].[USP_OMM_Session_Note_GetDetail]
(    
	@LangID NVARCHAR(50),
	@idfOutbreakNote BIGINT
)
AS

BEGIN    

	SELECT
		obn.idfOutbreakNote,
		obn.NoteRecordUID,
		obn.idfOutbreak,
		obn.strNote,
		obn.datNoteDate,
		obn.idfPerson,
		P.strFirstName + ' ' + P.strFamilyName AS UserName,
		B.[name] AS Organization,
		obn.intRowStatus,
		obn.strMaintenanceFlag,
		obn.strReservedAttribute,
		obn.UpdatePriorityID,
		P2.name AS strPriority,
		obn.UpdateRecordTitle,
		obn.UploadFileName,
		obn.UploadFileDescription,
		obn.UploadFileObject

	FROM dbo.tlbOutbreakNote obn
	INNER JOIN dbo.tlbPerson P ON P.idfPerson = obn.idfPerson
	INNER JOIN dbo.tlbOffice O ON O.idfOffice = P.idfInstitution
	INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000045) B ON B.idfsReference = O.idfsOfficeAbbreviation
	INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000518) P2 ON P2.idfsReference = obn.UpdatePriorityID
		
	WHERE obn.idfOutbreakNote = @idfOutbreakNote

END
