-- ================================================================================================
-- Name: USP_OMM_Case_GetDetail
--
-- Description: Gets details of an outbreak case summary.
--          
-- Author: Doug Albanese
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Doug Albanese	05/29/2010 Changes for OMUC07 (Vet Disease details)
-- Doug Albanese	07/01/2019 Changes for aligning the Human Disease Report for retreival
-- Stephen Long     04/25/2022 Cleaned up formatting and removed human disease report specific.
-- Stephen Long     06/23/2022 Added farm name to the query.
-- Doug Albanese	07/25/2022	 Changes 10012002 to 10012004. 10012002 wasn't a value that existed in the Base Reference for Avian.
--	Doug Albanese	07/26/2022	Add field CaseQuestionnaireTemplateId, to correctly identify a form that has been answered
-- Doug Albanese	 10/25/2022	 Refactored to provide the correct observation ID for Case Questionnaire.
-- Sample code
/*

EXEC dbo.USP_OMM_Case_GetDetail
	@LanguageID = 'en-US',
	@OutbreakCaseReportUID = 12

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_Case_GetDetail]
(
    @LanguageID NVARCHAR(50),
    @OutbreakCaseReportUID BIGINT = -1
)
AS
BEGIN
    BEGIN TRY
        SELECT ocr.OutBreakCaseReportUID AS CaseId,
               ocr.idfOutbreak AS OutbreakId,
               osp.OutbreakSpeciesTypeID AS CaseTypeId, 
               ocr.strOutbreakCaseID AS EIDSSCaseId,
               CAST(ocr.IsPrimaryCaseFlag AS BIT) AS PrimaryCaseIndicator,
               ocr.OutbreakCaseClassificationID AS ClassificationTypeId,
               ocr.OutbreakCaseStatusID AS StatusTypeId,
               ocr.idfHumanCase AS HumanDiseaseReportId,
               ocr.idfVetCase AS VeterinaryDiseaseReportId,
               CASE
                   WHEN f.strNationalName IS NULL THEN
                       f.strInternationalName
                   WHEN f.strNationalName = '' THEN
                       f.strInternationalName
                   ELSE
                       f.strNationalName
               END AS FarmName,
               ocr.OutbreakCaseObservationID AS CaseQuestionnaireObservationId,
               null AS CaseQuestionnaireObservationFormTypeId,
               ocr.CaseEPIObservationID,
               null AS CaseEPIObservationFormTypeId,
               ocr.AuditCreateDTM AS DateEntered,
               ocr.AuditUpdateDTM AS DateLastUpdated,
			   osp.CaseQuestionaireTemplateID AS CaseQuestionnaireTemplateId
        FROM dbo.OutbreakCaseReport ocr
            LEFT OUTER JOIN dbo.OutbreakSpeciesParameter osp
                ON osp.idfOutbreak = ocr.idfOutbreak
                   AND osp.intRowStatus = 0
            LEFT JOIN dbo.tlbVetCase vc 
                ON vc.idfVetCase = ocr.idfVetCase 
            LEFT JOIN dbo.tlbFarm f
                ON f.idfFarm = vc.idfFarm
        WHERE ocr.OutBreakCaseReportUID = @OutbreakCaseReportUID 
              AND (ocr.idfVetCase IS NOT NULL
                  AND (
                          vc.idfsCaseType = 10012004
                          AND osp.OutbreakSpeciesTypeID = 10514002
                      )
                  OR (
                         vc.idfsCaseType = 10012003
                         AND osp.OutbreakSpeciesTypeID = 10514003
                     ) OR ocr.idfVetCase IS NULL);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
