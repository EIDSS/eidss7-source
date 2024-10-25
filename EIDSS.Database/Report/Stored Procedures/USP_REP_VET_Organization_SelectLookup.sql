

--*************************************************************************
-- Name 				: report.USP_REP_VET_Organization_SelectLookup
-- Description			: Selects lookup list of organizations for GG vet reports.
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of procedure call:
EXEC report.USP_REP_VET_Organization_SelectLookup 'en', NULL
EXEC report.USP_REP_VET_Organization_SelectLookup 'en', 48130000000

*/

CREATE PROCEDURE [Report].[USP_REP_VET_Organization_SelectLookup]
	@LangID AS NVARCHAR(50), --##PARAM @LangID - language ID
	@ID AS BIGINT = NULL --##PARAM @ID - organization ID, if not null only record with this organization is selected
AS

SELECT 
	0 as idfKey
	,0 as idfInstitution
	, '' as name
	, '' as FullName
	, '' as strReportType
	, 0 as intRowStatus
UNION ALL
SELECT  
	CAST(ROW_NUMBER() OVER (ORDER BY tbra.varValue, [name]) AS BIGINT) idfKey
	, Organization.idfOffice AS idfInstitution
	, Organization.[name]
	, Organization.FullName	
	, tbra.varValue as strReportType
	, Organization.intRowStatus
FROM dbo.fnInstitutionRepair(@LangID) Organization
JOIN trtAttributeType tat ON
	tat.strAttributeTypeName = 'attr_department'
JOIN trtBaseReferenceAttribute tbra ON
	tbra.idfAttributeType = tat.idfAttributeType
	AND tbra.idfsBaseReference = Organization.idfsOfficeAbbreviation
WHERE Organization.idfOffice = ISNULL(@ID, Organization.idfOffice)
--ORDER BY Organization.name

