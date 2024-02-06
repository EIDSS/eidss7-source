-- ================================================================================================
-- Name: USP_GBL_ReportForm_GETDETAIL
--
-- Description: Get Weekly Report Form Details
--          
-- Author: Mani
-- Revision History:
-- Name                  Date       Change Detail
-- --------------------- ---------- --------------------------------------------------------------
-- Mani                  03/06/2022 Updated using Location Hierarchy Denormailzed table
-- Stephen Long          07/05/2023 Removed unneeded inner joins on organizations and gisLocation.
--
-- Testing code:
--
/*

EXECUTE [dbo].[USP_GBL_ReportForm_GETDETAIL] 
	'ru',
	10506188,
	6
--*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_ReportForm_GETDETAIL]
(
	@LangID AS NVARCHAR(50),
	@idfsReportFormType AS BIGINT = NULL,
	@idfReportForm AS BIGINT = NULL
	)
AS
BEGIN
	BEGIN TRY
		SELECT tlbReportForm.idfReportForm,
			tlbReportForm.idfsReportFormType,
			tlbReportForm.idfsAdministrativeUnit,
			tlbReportForm.idfSentByOffice,
			tlbReportForm.idfSentByPerson,
			tlbReportForm.idfEnteredByOffice,
			EnteredByOffice.FullName AS strEnteredByOffice,
			tlbReportForm.idfEnteredByPerson,
			dbo.FN_GBL_ConcatFullName(entByPerson.strFamilyName, entByPerson.strFirstName, entByPerson.strSecondName) AS strEnteredByPerson,
			dbo.FN_GBL_FormatDate(tlbReportForm.datSentByDate, 'mm/dd/yyyy') AS datSentByDate,
			dbo.FN_GBL_FormatDate(tlbReportForm.datEnteredByDate, 'mm/dd/yyyy') AS datEnteredByDate,
			dbo.FN_GBL_FormatDate(tlbReportForm.datStartDate, 'mm/dd/yyyy') AS datStartDate,
			dbo.FN_GBL_FormatDate(tlbReportForm.datFinishDate, 'mm/dd/yyyy') AS datFinishDate,
			tlbReportForm.strReportFormID,
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
			tlbReportForm.idfsDiagnosis,
			Diagnosis.name AS diseaseName,
			tlbReportForm.Total,
			tlbReportForm.Notified,
			tlbReportForm.Comments
		FROM dbo.tlbReportForm
		LEFT JOIN dbo.FN_GBL_Institution(@LangID) EnteredByOffice
			ON tlbReportForm.idfEnteredByOffice = EnteredByOffice.idfOffice
		LEFT JOIN dbo.tlbPerson entByPerson ON tlbReportForm.idfEnteredByPerson = entByPerson.idfPerson
		INNER JOIN FN_GBL_LocationHierarchy_Flattened(@LangID) lh ON lh.idfsLocation= tlbReportForm.idfsAdministrativeUnit
		LEFT JOIN dbo.trtBaseReference AdminUnit
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
             LEFT JOIN dbo.FN_GBL_Repair(@LangID, 19000019) Diagnosis
                    ON Diagnosis.idfsReference = tlbReportForm.idfsDiagnosis
		WHERE tlbReportForm.intRowStatus = 0
			AND (
				CASE 
					WHEN @idfsReportFormType IS NULL
						THEN 1
					WHEN ISNULL(tlbReportForm.idfsReportFormType, '') = @idfsReportFormType
						THEN 1
					ELSE 0
					END = 1
				)
			AND (
				CASE 
					WHEN @idfReportForm IS NULL
						THEN 1
					WHEN ISNULL(tlbReportForm.idfReportForm, '') = @idfReportForm
						THEN 1
					ELSE 0
					END = 1
				);
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
