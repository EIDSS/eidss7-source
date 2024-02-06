

-- ================================================================================================
-- Name: report.USP_Rep_Lim_TestResultsAmendmentHistory_GET
--
-- Description: Select data for Test Amendment History
--						
-- Author: Mark Wilson
--
-- Revision History:
--		Name       Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Mark Wilson    12/13/2021  Initial version, Converted to E7 standards.
--
-- Testing code:

/*
--Example of a call of procedure:

exec report.USP_Rep_Lim_TestResultsAmendmentHistory_GET @LangID=N'en-US',@ObjID=115146540000870
 
exec report.USP_Rep_Lim_TestResultsAmendmentHistory_GET @LangID=N'en-US',@ObjID=121754080000870
*/

CREATE PROCEDURE [Report].[USP_Rep_Lim_TestResultsAmendmentHistory_GET]
(
	@LangID AS NVARCHAR(10),
    @ObjID	AS BIGINT
)
AS

SELECT  
	OldTestResult.name AS strFirstTestResult,
	amh.datAmendmentDate AS datAmendmentDate,
	dbo.FN_GBL_ConcatFullName(pen.strFamilyName, pen.strSecondName, pen.strFirstName) AS strAmendedByPerson,
	AmendByOffice.name AS strAmendedByOrganization,
	NewTestResult.name AS strNewTestResult,
	amh.strReason AS strReasonOfAmended,
	amh.strNewNote AS srtNewCommentary,
	amh.strOldNote AS srtOldCommentary

FROM dbo.tlbTesting	AS t
INNER JOIN dbo. tlbTestAmendmentHistory AS amh ON t.idfTesting = amh.idfTesting
LEFT JOIN dbo.tlbOffice ofc ON amh.idfAmendByOffice = ofc.idfOffice
LEFT JOIN dbo.tlbPerson pen ON amh.idfAmendByPerson = pen.idfPerson
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000045) AmendByOffice ON AmendByOffice.idfsReference = ofc.idfsOfficeAbbreviation	
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000096) OldTestResult ON OldTestResult.idfsReference = amh.idfsOldTestResult	
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000096) NewTestResult ON NewTestResult.idfsReference = amh.idfsNewTestResult				
WHERE t.idfTesting = @ObjID
AND	t.intRowStatus=0
		

