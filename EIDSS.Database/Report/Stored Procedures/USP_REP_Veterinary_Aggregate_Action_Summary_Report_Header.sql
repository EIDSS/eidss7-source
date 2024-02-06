-- ================================================================================================
-- Name: USP_REP_Veterinary_Aggregate_Action_Summary_Report_Header
-- Description: PrintedForm Veterinary Aggregate Action Report
--          
-- Revision History:
-- Name				Date			Change
-- ---------------	----------	--------------------------------------------------------------------
-- Srini Goli		10/12/2022	Initial release for Veterinary Aggregate Action Summary Report.
--
-- Testing code:
--
-- Legends
/*
	Case Type
	HumanAggregateCase = 10102001
	VetAggregateCase = 10102002
	VetAggregateAction = 10102003

	TEST Code

	EXEC Report.USP_REP_Veterinary_Aggregate_Action_Summary_Report_Header 'en-US', @idfsAggrCaseType=10102002, @idfAggrCaseList = '155564770001956;155564770001955'

*/
-- ================================================================================================
CREATE PROCEDURE [Report].[USP_REP_Veterinary_Aggregate_Action_Summary_Report_Header] (
	@LangID AS NVARCHAR(50)
	,@idfsAggrCaseType AS BIGINT = NULL
	,@idfAggrCaseList AS  NVARCHAR(MAX)= NULL
	)
AS
BEGIN
DECLARE @returnCode INT = 0;
DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';

DECLARE @AggrCaseTable TABLE (
	[idfAggrCase] BIGINT,
	[intRowNumber] INT
	)

	BEGIN TRY
		--Get Selected Agg Cases
		INSERT INTO @AggrCaseTable (
				[idfAggrCase],
				[intRowNumber]
				)
		SELECT CAST([Value] AS BIGINT),
			ROW_NUMBER() OVER (
				ORDER BY [Value]
				)
		FROM [dbo].[FN_GBL_SYS_SplitList](@idfAggrCaseList, NULL, NULL)

		--Get the necessary columns from [dbo].[USP_AGG_CASE_GETDETAIL]
		SELECT datStartDate
			,datFinishDate
			,strCaseID
			,strRegion
			,strRayon
			,strSettlement
			,CONCAT(ISNULL(strCountry,''),IIF(ISNULL(strRegion,'')!='',', ',''),ISNULL(strRegion,''),IIF(ISNULL(strRayon,'')!='',', ',''),ISNULL(strRayon,''),IIF(ISNULL(strSettlement,'')!='',', ',''),ISNULL(strSettlement,'')) As strLocation
		FROM
		(
		SELECT 
			a.datStartDate
			,a.datFinishDate
			,a.strCaseID
			--,ISNULL(Country.idfsReference, '') AS idfsCountry
			,ISNULL(Country.[name], '') AS strCountry
			--,ISNULL(Region.idfsReference, '') AS idfsRegion
			,ISNULL(Region.[name], '') AS strRegion
			--,ISNULL(Rayon.idfsReference, '') AS idfsRayon
			,ISNULL(Rayon.[name], '') AS strRayon
			--,ISNULL(Settlement.idfsReference, '') AS idfsSettlement
			,ISNULL(Settlement.[name], '') AS strSettlement
		FROM dbo.tlbAggrCase a
		LEFT JOIN dbo.tlbOffice RBO ON RBO.idfOffice = a.idfReceivedByOffice
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) RBON ON RBON.idfsReference = RBO.idfsOfficeAbbreviation

		LEFT JOIN dbo.tlbOffice EBO ON EBO.idfOffice = a.idfEnteredByOffice
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) EBON ON EBON.idfsReference = EBO.idfsOfficeAbbreviation

		LEFT JOIN dbo.tlbOffice SBO ON SBO.idfOffice = a.idfSentByOffice
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) SBON ON SBON.idfsReference = SBO.idfsOfficeAbbreviation
		
		LEFT JOIN dbo.tlbPerson ReceivedByPerson ON a.idfReceivedByPerson = ReceivedByPerson.idfPerson
		LEFT JOIN dbo.tlbPerson EnteredByPerson ON a.idfEnteredByPerson = EnteredByPerson.idfPerson
		LEFT JOIN dbo.tlbPerson SentByPerson ON a.idfSentByPerson = SentByPerson.idfPerson
		
		INNER JOIN dbo.gisLocation AUL ON AUL.idfsLocation = a.idfsAdministrativeUnit
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) AS Country ON AUL.node.IsDescendantOf(Country.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) AS Region ON AUL.node.IsDescendantOf(Region.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) AS Rayon ON AUL.node.IsDescendantOf(Rayon.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004) AS Settlement ON AUL.node.IsDescendantOf(Settlement.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000005) AS LocType ON LocType.idfsReference = Settlement.idfsType
		
		LEFT JOIN dbo.trtStringNameTranslation Period ON Period.idfsBaseReference = CASE 
				WHEN DATEDIFF(DAY, a.datStartDate, a.datFinishDate) = 0
					THEN 10091002 /*day*/
				WHEN DATEDIFF(DAY, a.datStartDate, a.datFinishDate) = 6
					THEN 10091004 /*week - use datediff with day because datediff with week will return incorrect result if first day of week in country differ from sunday*/
				WHEN DATEDIFF(MONTH, a.datStartDate, a.datFinishDate) = 0
					THEN 10091001 /*month*/
				WHEN DATEDIFF(QUARTER, a.datStartDate, a.datFinishDate) = 0
					THEN 10091003 /*quarter*/
				WHEN DATEDIFF(YEAR, a.datStartDate, a.datFinishDate) = 0
					THEN 10091005 /*year*/
				END
			AND Period.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
		--LEFT JOIN dbo.tlbObservation CaseObs ON idfCaseObservation = CaseObs.idfObservation
		--LEFT JOIN dbo.tlbObservation DiagnosticObs ON idfDiagnosticObservation = DiagnosticObs.idfObservation
		--LEFT JOIN dbo.tlbObservation ProphylacticObs ON idfProphylacticObservation = ProphylacticObs.idfObservation
		--LEFT JOIN dbo.tlbObservation SanitaryObs ON idfSanitaryObservation = SanitaryObs.idfObservation
		--LEFT JOIN dbo.FN_GBL_Institution(@LangID) AS organizationAdminUnit ON a.idfOffice = organizationAdminUnit.idfOffice
		WHERE a.intRowStatus = 0
		AND a.idfAggrCase IN (SELECT idfAggrCase FROM @AggrCaseTable)
		--AND (@idfAggrCase IS NULL OR a.idfAggrCase = @idfAggrCase)
		--	AND (
		--		CASE 
		--			WHEN @idfsAggrCaseType IS NULL
		--				THEN 1
		--			WHEN ISNULL(a.idfsAggrCaseType, '') = @idfsAggrCaseType
		--				THEN 1
		--			ELSE 0
		--			END = 1
		--		)
		--	AND (
		--		CASE 
		--			WHEN @idfAggrCase IS NULL
		--				THEN 1
		--			WHEN ISNULL(a.idfAggrCase, '') = @idfAggrCase
		--				THEN 1
		--			ELSE 0
		--			END = 1
		--		) 
			) A;


	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
