--*************************************************************
-- Name 				: USP_REP_ReportForm_GETDETAIL
-- Description			: Get Weekly Report Form Details
--          
-- Author               : Mark Wilson
-- Revision History
--		Name		Date		Change Detail
--		Mark		03/08/2022  initial
-- Stephen Long     07/06/2023  Fix to entered by and sent by
--                              person name, and sent by org 
--                              name to match UI.
--
--
-- Testing code:
--
--
/*

EXECUTE [Report].[USP_REP_ReportForm_GETDETAIL] 
	'en-US',
	18
	
*/
CREATE PROCEDURE [Report].[USP_REP_ReportForm_GETDETAIL]
(
	@LangID AS NVARCHAR(50),
	@idfReportForm AS BIGINT = NULL
)
AS

BEGIN
	BEGIN TRY
		SELECT 
			RF.idfReportForm,
			RF.idfsReportFormType,
			RF.idfsAdministrativeUnit,
			RF.idfSentByOffice,
			SentByOffice.name AS strSentByOffice,
			RF.idfSentByPerson,
			dbo.FN_GBL_ConcatFullName(sentByPerson.strFamilyName, sentByPerson.strFirstName, sentByPerson.strSecondName) AS strSentByPerson,
			RF.idfEnteredByOffice,
			EnteredByOffice.FullName AS strEnteredByOffice,
			RF.idfEnteredByPerson,
			dbo.FN_GBL_ConcatFullName(entByPerson.strFamilyName, entByPerson.strFirstName, entByPerson.strSecondName) AS strEnteredByPerson,
			dbo.FN_GBL_FormatDate(RF.datSentByDate, 'mm/dd/yyyy') AS datSentByDate,
			dbo.FN_GBL_FormatDate(RF.datEnteredByDate, 'mm/dd/yyyy') AS datEnteredByDate,
			dbo.FN_GBL_FormatDate(RF.datStartDate, 'mm/dd/yyyy') AS datStartDate,
			dbo.FN_GBL_FormatDate(RF.datFinishDate, 'mm/dd/yyyy') AS datFinishDate,
			RF.strReportFormID,
			AdminUnit.idfsBaseReference AS idfsAreaType,
			lh.AdminLevel1ID AS AdminLevel0,
			lh.AdminLevel1Name AS AdminLevel0Name,
			lh.AdminLevel2ID AS AdminLevel1,
			lh.AdminLevel2Name AS AdminLevel1Name,
			lh.AdminLevel3ID AS AdminLevel2,
			lh.AdminLevel3Name AS AdminLevel2Name,
			lh.AdminLevel4ID AS idfsSettlement,
			lh.AdminLevel4Name AS SettlementName,
			Period.idfsBaseReference AS idfsPeriodType,
			Period.strTextString AS strPeriodName,
			NULL AS Organization, 
			RF.idfsDiagnosis,
			D.strDefault AS diseaseDefaultName,
			D.[name] AS diseaseName,
			DD.strIDC10,
			RF.Total,
			RF.Notified,
			RF.Comments
		FROM dbo.tlbReportForm RF
		INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) D ON D.idfsReference = RF.idfsDiagnosis
		INNER JOIN dbo.trtDiagnosis DD ON DD.idfsDiagnosis = RF.idfsDiagnosis
		INNER JOIN dbo.FN_GBL_Institution(@LangID) SentByOffice ON RF.idfSentByOffice = SentByOffice.idfOffice
		INNER JOIN dbo.tlbPerson entByPerson ON RF.idfEnteredByPerson = entByPerson.idfPerson
		INNER JOIN dbo.FN_GBL_Institution(@LangID) EnteredByOffice ON RF.idfEnteredByOffice = EnteredByOffice.idfOffice
		INNER JOIN dbo.tlbPerson sentByPerson ON RF.idfSentByPerson= sentByPerson.idfPerson
		INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lh ON lh.idfsLocation= RF.idfsAdministrativeUnit
		LEFT JOIN dbo.trtBaseReference AS AdminUnit
			ON AdminUnit.idfsBaseReference = CASE 
					WHEN NOT lh.AdminLevel4ID IS NULL
						THEN 10089004
					WHEN NOT lh.AdminLevel3ID IS NULL
						THEN 10089002
					WHEN NOT lh.AdminLevel2ID IS NULL
						THEN 10089003
					WHEN NOT lh.AdminLevel1Id IS NULL
						THEN   10089001
					END
		LEFT OUTER JOIN dbo.trtStringNameTranslation Period
			ON Period.idfsBaseReference = CASE 
					WHEN DATEDIFF(DAY, datStartDate, datFinishDate) = 0
						THEN 10091002 /*day*/
					WHEN DATEDIFF(DAY, datStartDate, datFinishDate) = 6
						THEN 10091004 /*week - use datediff with day because datediff with week will return incorrect result if first day of week in country differ from sunday*/
					WHEN DATEDIFF(MONTH, datStartDate, datFinishDate) = 0
						THEN 10091001 /*month*/
					WHEN DATEDIFF(QUARTER, datStartDate, datFinishDate) = 0
						THEN 10091003 /*quarter*/
					WHEN DATEDIFF(YEAR, datStartDate, datFinishDate) = 0
						THEN 10091005 /*year*/
					END
				AND Period.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
		WHERE RF.intRowStatus = 0
		AND RF.idfReportForm = @idfReportForm;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
