
--*************************************************************************
-- Name 				: report.USP_REP_LAB_AssignmentDiagnosticAZSendToLookup
-- Description			: This procedure used in Assignment For Laboratory Diagnostic report to populate SentToID values.
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_LAB_AssignmentDiagnosticAZSendToLookup 'ru', 'HUMBA000200OZ9'
EXEC report.USP_REP_LAB_AssignmentDiagnosticAZSendToLookup 'en-US', 'HUMBA000200OZ6'
EXEC report.USP_REP_LAB_AssignmentDiagnosticAZSendToLookup 'ru', 'HUMBA000200OZQ'
*/

CREATE PROCEDURE [Report].[USP_REP_LAB_AssignmentDiagnosticAZSendToLookup]
	(
		@LangID	AS NVARCHAR(10), 
		@CaseID	AS VARCHAR(36)
	)
AS	

DECLARE @ReportTable TABLE 
(
	idfsReference BIGINT PRIMARY KEY NOT NULL, 
	strName NVARCHAR(200)
)

/*
input parameters: language, case id

output: organization  id, organization abbreviations

o If case was not found it should returns (-2, null) 
o If case was found, and it does not contain any registered sample meeting criteria of General filtration rules, it should returns (-1, null)
o If case was found, and there is at least one sample meeting criteria of General filtration rules registered in the case, 
then all unique non-blank abbreviations of organizations taken from Send to Organization attribute of all samples meeting criteria 
of General filtration rules shall be returned with their ids


*/

IF NOT EXISTS (SELECT * FROM tlbHumanCase thc WHERE thc.strCaseID = @CaseID)
BEGIN
	-- -2 means that case does not exist
	INSERT INTO @ReportTable VALUES (-2, null)
END
ELSE	
IF NOT EXISTS (
	SELECT		*
	FROM	tlbMaterial m
		INNER JOIN tlbHumanCase thc
		ON thc.idfHumanCase = m.idfHumanCase
		AND thc.intRowStatus = 0
	WHERE	m.intRowStatus = 0
			AND m.idfsSampleType <> 10320001 /*Unknown*/
			AND m.idfParentMaterial is null /*it is initially collected sample*/
			AND thc.strCaseID = @CaseID
)	
BEGIN
	-- -1 means that case exists, but does not contain registered samples
	INSERT INTO @ReportTable VALUES (-1, null) 
END
ELSE
IF EXISTS (
	SELECT		*
	FROM	tlbMaterial m
		INNER JOIN tlbHumanCase thc
		ON thc.idfHumanCase = m.idfHumanCase
		AND thc.intRowStatus = 0
		
		INNER JOIN report.FN_REP_InstitutionRepair(@LangID) i_sent_to
		ON i_sent_to.idfOffice = m.idfSendToOffice
	WHERE	m.intRowStatus = 0
			AND m.idfsSampleType <> 10320001 /*Unknown*/
			AND m.idfParentMaterial is null /*it is initially collected sample*/
			AND thc.strCaseID = @CaseID
)
BEGIN
	--	o If case was found, and there is at least one sample meeting criteria of General filtration rules registered in the case, 
	--then all unique non-blank abbreviations of organizations taken from Send to Organization attribute of all samples meeting criteria 
	--of General filtration rules shall be returned with their ids
	INSERT INTO @ReportTable (idfsReference, strName)
	SELECT	distinct m.idfSendToOffice, i_sent_to.name
	FROM	tlbMaterial m
		INNER JOIN tlbHumanCase thc
		ON thc.idfHumanCase = m.idfHumanCase
		AND thc.intRowStatus = 0
		
		INNER JOIN report.FN_REP_InstitutionRepair(@LangID) i_sent_to
		ON i_sent_to.idfOffice = m.idfSendToOffice
	WHERE	m.intRowStatus = 0
			AND m.idfsSampleType <> 10320001 /*Unknown*/
			AND m.idfParentMaterial is null /*it is initially collected sample*/
			AND thc.strCaseID = @CaseID
END	



SELECT *
FROM @ReportTable



