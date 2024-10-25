
-- ================================================================================================
-- Name: USP_OMM_Case_GetList
--
-- Description: Gets a list of outbreak cases.
--          
-- Author: Doug Albanese
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Doug Albanese   05/20/2019 Added capabilities for Vet Disease retrieval
-- Doug Albanese   01/11/2021 Changed the output for the Date Entered so that it can be converted, 
--                            when switching languages.
-- Doug Albanese   01/22/2021 Changed the OutbreakSpeciesParameter table to be joined via a LEFT 
--                            OUTER JOIN
-- Doug Albanese   02/09/2021 Correction to fix migrated data between eidss6.1 content and missing 
--                            EIDSS 7 data.
-- Doug Albanese   09/29/2021 Refactored to work with the MVC gridview taghelper
-- Doug Albanese   09/30/2021 Clean up of unecessary content that was confusing EF
-- Stephen Long    04/23/2022 Cleaned up formatting and changed over to location hierarchy.
-- Stephen Long    05/12/2022 Added distinct to remove duplicates on human and vet case.
-- Stephen Long    06/05/2022 Temporary hard-code for human outbreak type to handle convert contact
--                            to case, so application will navigate to correct case details view.
-- Doug Albanese   06/15/2022 I forgot to add a comment here, from about a week ago for the removal 
--                            for SpeciesTypeName...which was causing duplicate rows to show up in 
--                            the case listing.
-- Stephen Long    06/20/2022 Added human and veterinary disease report identifiers.
-- Stephen Long    07/23/2022 Added search term check on human and vet checks; otherwise lab module
--                            returns nothing, and disease ID and patient/farm owner name.
-- Doug Albanese   07/25/2022 Changes 10012002 to 10012004. 10012002 wasn't a value that existed 
--                            in the Base Reference for Avian.
-- Stephen Long    07/28/2022 Fix on veterinary case get where criteria; was puilling back records 
--                            for outbreak sessions that did not have any cases.
-- Doug Albanese  09/08/2022  Correction for Vet Case Listings
-- Stephen Long    10/25/2022 Fix to remove duplicate cases.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_Case_GetList]
(
    @LanguageID NVARCHAR(50),
    @OutbreakID BIGINT = NULL,
    @SearchTerm NVARCHAR(100) = NULL,
    @HumanMasterID BIGINT = NULL,
    @FarmMasterID BIGINT = NULL,
    @TodaysFollowUpsIndicator BIT = NULL,
    @Page INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'EIDSSCaseID',
    @SortOrder NVARCHAR(4) = 'DESC'
)
AS
BEGIN
    DECLARE @FirstRec INT = (@Page - 1) * @Pagesize,
            @LastRec INT = (@Page * @PageSize + 1);

    BEGIN TRY
        DECLARE @InitialResults TABLE
        (
            OutbreakID BIGINT NOT NULL,
            EIDSSOutbreakID NVARCHAR(200) NOT NULL,
            CaseID BIGINT NOT NULL,
            EIDSSCaseID NVARCHAR(200) NOT NULL,
            HumanDiseaseReportID BIGINT NULL,
            VeterinaryDiseaseReportID BIGINT NULL,
            DiseaseID BIGINT NULL, 
            DiseaseName NVARCHAR(200) NULL,
            PatientOrFarmOwnerName NVARCHAR(MAX) NULL, 
            SpeciesTypeName NVARCHAR(200) NULL,
            CaseTypeName NVARCHAR(200) NOT NULL,
            StatusTypeName NVARCHAR(200) NULL,
            ClassificationTypeName NVARCHAR(200) NULL,
            CaseLocation NVARCHAR(200) NULL,
            DateEntered DATETIME NOT NULL,
            DateOfSymptomOnset DATETIME NULL,
            InvestigationDate DATETIME NULL,
            ReportedByPersonName NVARCHAR(200) NULL,
            InvestigatedByPersonName NVARCHAR(200) NULL,
            TotalSickAnimalQuantity INT NULL,
            TotalDeadAnimalQuantity INT NULL,
            PrimaryCaseIndicator INT NOT NULL,
            MonitoringDuration INT NULL,
            MonitoringFrequency INT NULL,
			OutbreakTypeID BIGINT NULL
        );

        DECLARE @FinalResults TABLE
        (
            OutbreakID BIGINT NOT NULL,
            EIDSSOutbreakID NVARCHAR(200) NOT NULL,
            CaseID BIGINT NOT NULL,
            EIDSSCaseID NVARCHAR(200) NOT NULL,
            HumanDiseaseReportID BIGINT NULL,
            VeterinaryDiseaseReportID BIGINT NULL,
            DiseaseID BIGINT NULL, 
            DiseaseName NVARCHAR(200) NULL,
            PatientOrFarmOwnerName NVARCHAR(MAX) NULL, 
            SpeciesTypeName NVARCHAR(200) NULL,
            CaseTypeName NVARCHAR(200) NOT NULL,
            StatusTypeName NVARCHAR(200) NULL,
            ClassificationTypeName NVARCHAR(200) NULL,
            CaseLocation NVARCHAR(200) NULL,
            DateEntered DATETIME NOT NULL,
            DateOfSymptomOnset DATETIME NULL,
            InvestigationDate DATETIME NULL,
            ReportedByPersonName NVARCHAR(200) NULL,
            InvestigatedByPersonName NVARCHAR(200) NULL,
            TotalSickAnimalQuantity INT NULL,
            TotalDeadAnimalQuantity INT NULL,
            PrimaryCaseIndicator INT NOT NULL,
            MonitoringDuration INT NULL,
            MonitoringFrequency INT NULL,
			OutbreakTypeID BIGINT NULL
        );

        IF (@OutbreakID IS NOT NULL OR @HumanMasterID IS NOT NULL OR @SearchTerm IS NOT NULL)
        BEGIN
            INSERT INTO @InitialResults
            SELECT DISTINCT
                ocr.idfOutbreak,
                o.strOutbreakID,
                ocr.OutBreakCaseReportUID,
                ocr.strOutbreakCaseID,
                ocr.idfHumanCase,
                NULL,
                disease.idfsReference, 
                disease.name,
                ISNULL(h.strLastName, N'') + ISNULL(', ' + h.strFirstName, '') + ISNULL(' ' + h.strSecondName, ''),
                outbreakSpeciesGroupType.name,
                caseType.name,
                statusType.name,
                classificationType.name,
                lh.AdminLevel2Name + ', ' + lh.AdminLevel1Name,
                hc.datEnteredDate,
                hc.datOnSetDate,
                hc.datInvestigationStartDate,
                NULL,
                NULL,
                NULL,
                NULL,
                COALESCE(IsPrimaryCaseFlag,0),
                osp.CaseMonitoringDuration,
                osp.CaseMonitoringFrequency,
				10513001 -- TODO - Handle convert to case for outbreak types of veterinary or zoonotic?
            FROM dbo.OutbreakCaseReport ocr
                INNER JOIN dbo.tlbOutbreak o
                    ON o.idfOutbreak = ocr.idfOutbreak
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = ocr.idfHumanCase
                LEFT JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                    ON disease.idfsReference = hc.idfsFinalDiagnosis
                LEFT OUTER JOIN dbo.OutbreakSpeciesParameter osp
                    ON osp.idfOutbreak = ocr.idfOutbreak
                       AND osp.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = h.idfCurrentResidenceAddress
                       AND gl.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000011) classificationType
                    ON classificationType.idfsReference = ocr.OutbreakCaseClassificationID
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000520) statusType
                    ON statusType.idfsReference = ocr.OutbreakCaseStatusID
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000513) caseType
                    ON caseType.idfsReference = 10513001 -- TODO - Handle convert to case for outbreak types of veterinary or zoonotic?
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000514) outbreakSpeciesGroupType
                    ON outbreakSpeciesGroupType.idfsReference = osp.OutbreakSpeciesTypeID
            WHERE ocr.idfHumanCase IS NOT NULL
   			      AND osp.OutbreakSpeciesTypeID IN (10514001)
                  AND ocr.intRowStatus = 0
                  AND (
                          ocr.idfOutbreak = @OutbreakID
                          OR @OutbreakID IS NULL
                      )
                  AND (
                          h.idfHumanActual = @HumanMasterID
                          OR @HumanMasterID IS NULL
                      );

			
        END

        IF (@OutbreakID IS NOT NULL OR @FarmMasterID IS NOT NULL OR @SearchTerm IS NOT NULL)
        BEGIN
            INSERT INTO @InitialResults
            SELECT DISTINCT ocr.idfOutbreak,
                   o.strOutbreakID,
                   ocr.OutBreakCaseReportUID,
                   ocr.strOutbreakCaseID,
                   NULL,
                   ocr.idfVetCase,
                   disease.idfsReference, 
                   disease.name,
                   ISNULL(h.strLastName, N'') + ISNULL(', ' + h.strFirstName, '') + ISNULL(' ' + h.strSecondName, ''),
                   --outbreakSpeciesGroupType.name,
				  osp.OutbreakSpeciesTypeID as name,
                   caseType.name,
                   statusType.name,
                   classificationType.name,
                   lh.AdminLevel2Name + ', ' + lh.AdminLevel1Name,
                   vc.datEnteredDate,
                   vc.datReportDate,
                   vc.datInvestigationDate,
                   ISNULL(personReportedBy.strFamilyName, N'') + ISNULL(', ' + personReportedBy.strFirstName, '')
                   + ISNULL(' ' + personReportedBy.strSecondName, ''),
                   ISNULL(personInvestigatedBy.strFamilyName, N'')
                   + ISNULL(', ' + personInvestigatedBy.strFirstName, '')
                   + ISNULL(' ' + personInvestigatedBy.strSecondName, ''),
                   (CASE
                        WHEN vc.idfsCaseType = 10012003 THEN
                            ISNULL(f.intLivestockSickAnimalQty, '0')
                        ELSE
                            ISNULL(f.intAvianSickAnimalQty, '0')
                    END
                   ),
                   (CASE
                        WHEN vc.idfsCaseType = 10012003 THEN
                            ISNULL(f.intLivestockDeadAnimalQty, '0')
                        ELSE
                            ISNULL(f.intAvianDeadAnimalQty, '0')
                    END
                   ),
                   IsPrimaryCaseFlag,
                   osp.CaseMonitoringDuration,
                   osp.CaseMonitoringFrequency,
				   caseType.idfsReference
            FROM dbo.OutbreakCaseReport ocr
                INNER JOIN dbo.tlbOutbreak o
                    ON o.idfOutbreak = ocr.idfOutbreak
                INNER JOIN dbo.tlbVetCase vc
                    ON vc.idfVetCase = ocr.idfVetCase
                LEFT JOIN dbo.tlbFarm f
                    ON f.idfFarm = vc.idfFarm
                LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                    ON disease.idfsReference = vc.idfsFinalDiagnosis
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = f.idfFarmAddress
                       AND gl.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = gl.idfsLocation
                LEFT OUTER JOIN dbo.OutbreakSpeciesParameter osp
                    ON osp.idfOutbreak = ocr.idfOutbreak
                       AND osp.intRowStatus = 0
                LEFT JOIN dbo.tlbPerson personInvestigatedBy
                    ON personInvestigatedBy.idfPerson = vc.idfPersonInvestigatedBy
                LEFT JOIN dbo.tlbPerson personReportedBy
                    ON personReportedBy.idfPerson = vc.idfPersonReportedBy
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000011) classificationType
                    ON classificationType.idfsReference = ocr.OutbreakCaseClassificationID
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000520) statusType
                    ON statusType.idfsReference = ocr.OutbreakCaseStatusID
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000513) caseType
                    ON caseType.idfsReference = 10513002
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000514) outbreakSpeciesGroupType
                    ON outbreakSpeciesGroupType.idfsReference = osp.OutbreakSpeciesTypeID
            WHERE ocr.idfVetCase IS NOT NULL
                  AND ((
                          vc.idfsCaseType = 10012004
                          AND osp.OutbreakSpeciesTypeID = 10514002
                      )
                  OR (
                         vc.idfsCaseType = 10012003
                         AND osp.OutbreakSpeciesTypeID = 10514003
                     ))
                  AND ocr.intRowStatus = 0
                  AND (
                      ocr.idfOutbreak = @OutbreakID
                      OR @OutbreakID IS NULL
                  )
                  AND (
                      f.idfFarmActual = @FarmMasterID
                      OR @FarmMasterID IS NULL
                  );
        END

        IF @TodaysFollowUpsIndicator = 1
        BEGIN
            DELETE FROM @InitialResults
            WHERE CaseID NOT IN (
                                    SELECT CaseID
                                    FROM @InitialResults
                                    WHERE DateEntered > DATEADD(DAY, -MonitoringDuration, GETDATE())
                                          AND DATEDIFF(DAY, DateEntered, GETDATE()) % MonitoringFrequency = 0
                                );
        END

        IF @SearchTerm IS NULL
        BEGIN
            INSERT INTO @FinalResults
            SELECT OutbreakID,
                   EIDSSOutbreakID,
                   CaseID,
                   EIDSSCaseID,
                   HumanDiseaseReportID,
                   VeterinaryDiseaseReportID,
                   DiseaseID,
                   DiseaseName,
                   PatientOrFarmOwnerName, 
                   SpeciesTypeName,
                   CaseTypeName,
                   StatusTypeName,
                   ClassificationTypeName,
                   CaseLocation,
                   DateEntered,
                   DateOfSymptomOnset,
                   InvestigationDate,
                   ReportedByPersonName,
                   InvestigatedByPersonName,
                   TotalSickAnimalQuantity,
                   TotalDeadAnimalQuantity,
                   PrimaryCaseIndicator,
                   MonitoringDuration,
                   MonitoringFrequency,
				   OutbreakTypeID
            FROM @InitialResults;
        END
        ELSE
        BEGIN
            INSERT INTO @FinalResults
            SELECT DISTINCT
                OutbreakID,
                EIDSSOutbreakID,
                CaseID,
                EIDSSCaseID,
                HumanDiseaseReportID,
                VeterinaryDiseaseReportID,
                DiseaseID,
                DiseaseName,
                PatientOrFarmOwnerName,
                SpeciesTypeName,
                CaseTypeName,
                StatusTypeName,
                ClassificationTypeName,
                CaseLocation,
                DateEntered,
                DateOfSymptomOnset,
                InvestigationDate,
                ReportedByPersonName,
                InvestigatedByPersonName,
                TotalSickAnimalQuantity,
                TotalDeadAnimalQuantity,
                PrimaryCaseIndicator,
                MonitoringDuration,
                MonitoringFrequency,
				OutbreakTypeID
            FROM @InitialResults
            WHERE EIDSSOutbreakID LIKE '%' + @SearchTerm + '%'
                  OR EIDSSCaseID LIKE '%' + @SearchTerm + '%'
                  OR HumanDiseaseReportID LIKE '%' + @SearchTerm + '%'
                  OR VeterinaryDiseaseReportID LIKE '%' + @SearchTerm + '%'
                  OR CaseTypeName LIKE '%' + @SearchTerm + '%'
                  OR StatusTypeName LIKE '%' + @SearchTerm + '%'
                  OR DateOfSymptomOnset LIKE '%' + @SearchTerm + '%'
                  OR ClassificationTypeName LIKE '%' + @SearchTerm + '%'
                  OR CaseLocation LIKE '%' + @SearchTerm + '%'
                  OR DateEntered LIKE '%' + @SearchTerm + '%'
        END;

        WITH CTEResults
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'EIDSSOutbreakID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       EIDSSOutbreakID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EIDSSOutbreakID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       EIDSSOutbreakID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'EIDSSCaseID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       EIDSSCaseID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EIDSSCaseID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       EIDSSCaseID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'CaseTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       CaseTypeName
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'CaseTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       CaseTypeName
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'StatusTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       StatusTypeName
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'StatusTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       StatusTypeName
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       DiseaseName
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       DiseaseName
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'SpeciesTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       SpeciesTypeName
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'SpeciesTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       SpeciesTypeName
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'DateOfSymptomOnset'
                                                        AND @SortOrder = 'ASC' THEN
                                                       DateOfSymptomOnset
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'DateOfSymptomOnset'
                                                        AND @SortOrder = 'DESC' THEN
                                                       DateOfSymptomOnset
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'InvestigationDate'
                                                        AND @SortOrder = 'ASC' THEN
                                                       InvestigationDate
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'InvestigationDate'
                                                        AND @SortOrder = 'DESC' THEN
                                                       InvestigationDate
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'ClassificationTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ClassificationTypeName
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ClassificationTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ClassificationTypeName
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'CaseLocation'
                                                        AND @SortOrder = 'ASC' THEN
                                                       CaseLocation
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'CaseLocation'
                                                        AND @SortOrder = 'DESC' THEN
                                                       CaseLocation
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'DateEntered'
                                                        AND @SortOrder = 'ASC' THEN
                                                       DateEntered
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'DateEntered'
                                                        AND @SortOrder = 'DESC' THEN
                                                       DateEntered
                                               END DESC
                                     ) AS ROWNUM,
                   COUNT(*) OVER () AS [RowCount],
                   EIDSSOutbreakID,
                   CaseID,
                   EIDSSCaseID,
                   HumanDiseaseReportID, 
                   VeterinaryDiseaseReportID, 
                   DiseaseID,
                   DiseaseName,
                   PatientOrFarmOwnerName,
                   SpeciesTypeName,
                   CaseTypeName,
                   StatusTypeName,
                   ClassificationTypeName,
                   CaseLocation,
                   DateEntered,
                   DateOfSymptomOnset,
                   InvestigationDate,
                   ReportedByPersonName,
                   InvestigatedByPersonName,
                   TotalSickAnimalQuantity,
                   TotalDeadAnimalQuantity,
                   PrimaryCaseIndicator,
                   MonitoringDuration,
                   MonitoringFrequency,
				   OutbreakTypeID
            FROM @FinalResults
           )
        SELECT DISTINCT EIDSSOutbreakID,
               CaseID,
               EIDSSCaseID,
               HumanDiseaseReportID, 
               VeterinaryDiseaseReportID, 
               DiseaseID,
               DiseaseName,
               PatientOrFarmOwnerName,
               --SpeciesTypeName,
               CaseTypeName,
               StatusTypeName,
               ClassificationTypeName,
               CaseLocation,
               DateEntered,
               DateOfSymptomOnset,
               InvestigationDate,
               ReportedByPersonName,
               InvestigatedByPersonName,
               TotalSickAnimalQuantity,
               TotalDeadAnimalQuantity,
               PrimaryCaseIndicator,
               MonitoringDuration,
               MonitoringFrequency,
			   OutbreakTypeID,
               [RowCount],
               (
                   SELECT COUNT(*) FROM dbo.OutbreakCaseReport WHERE intRowStatus = 0
               ) AS TotalRowCount,
               CurrentPage = @Page,
               TotalPages = ([RowCount] / @PageSize) + IIF([RowCount] % @PageSize > 0, 1, 0)
        FROM CTEResults
        WHERE RowNum > @FirstRec
              AND RowNum < @LastRec;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
