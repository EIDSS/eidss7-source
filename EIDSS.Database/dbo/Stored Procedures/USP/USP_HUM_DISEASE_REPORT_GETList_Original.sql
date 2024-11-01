﻿
-- ================================================================================================
-- Name: USP_HUM_DISEASE_REPORT_GETList_original
--
-- Description: Get a list of human disease reports for the human module.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mandar Kulkarni             Initial release.
-- Stephen Long     03/26/2018 Added the person reported by name for the farm use case.
-- JWJ	            04/17/2018 Added extra col to return:  tlbHuman.idfHumanActual. Added alias 
--                             for region rayon to make them unique in results added report status 
--                             to results 
-- Harold Pryor     10/22/2018 Added input search parameters SearchStrPersonFirstName, 
--                             SearchStrPersonMiddleName, and SearchStrPersonLastName
-- Harold Pryor     10/31/2018 Added input search parameters SearchLegacyCaseID and	
--                             added strLocation (region, rayon) field to list result set
-- Harold Pryor     11/12/2018 Changed @SearchLegacyCaseID parameter from BIGINT to NVARCHAR(200)
-- Stephen Long     12/19/2018 Added pagination logic.
-- Stephen Long     07/07/2019 Added monitoring session ID to parameters and where clause.
-- Stephen Long     07/10/2019 Changed address join from exposure location to patient's current 
--                             residence address.
-- Stephen Long     07/19/2019 Corrected patient name and person entered by name ', '.
-- Stephen Long     02/26/2020 Added non-configurable site filtration rules.
-- Lamont Mitchell  03/03/2020 Modified all joins on human case and human to join on human actual.
-- Stephen Long     04/01/2020 Added if/else for first-level and second-level site types to bypass 
--                             non-configurable rules.
-- Stephen Long     05/18/2020 Added disease filtration rules from use case SAUC62.
-- Stephen Long     06/18/2020 Corrected the join on the rayon of the report current residence 
--                             address (human ID to human ID instead of human ID to human actual 
--                             ID).
-- Stephen Long     06/18/2020 Added where criteria to the query when no site filtration is 
--                             required.
-- Stephen Long     07/07/2020 Added trim to EIDSS identifier like criteria.
-- Doug Albanese	11/16/2020 Added Outbreak Tied filtering
-- Stephen Long     11/18/2020 Added site ID to the query.
-- Stephen Long     11/28/2020 Added configurable site filtration rules.
-- Stephen Long     12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long     12/24/2020 Modified join on disease filtration default role rule.
-- Stephen Long     12/29/2020 Changed function call on reference data for inactive records.
-- Stephen Long     01/04/2020 Added option recompile due to number of optional parameters for 
--                             better execution plan.
-- Stephen Long     04/04/2021 Added updated pagination and location hierarchy.
-- Mike Kornegay	09/23/2021 Added HospitalizationStatus field
-- Stephen Long     11/03/2021 Added disease ID field.
-- Mike Kornegay	11/16/2021 Fix hospitalization field for translations
-- Mike Kornegay	12/07/2021 Added back EnteredByPersonName 
-- Mike Kornegay	12/08/2021 Swapped out FN_GBL_GIS_ReferenceRepair for new flat hierarchy
-- Mike Kornegay	12/23/2021 Fixed YN hospitalization where clause
-- Manickandan Govindarajan 03/21/2022  Rename Param PageNumber to Page
-- Stephen Long     03/29/2022 Fix to site filtration to pull back a user's own site records.
-- Stephen Long     06/03/2022 Updated to point default access rules to base reference.
-- Mike Kornegay    06/06/2022 Added parameter OutcomeID.
-- Mike Kornegay	06/13/2022 Changed inner joins to left joins in final query because result set 
--                             was incorrect.
-- Stephen Long     08/14/2022 Added additional criteria for outbreak cases for laboratory module.
--                             TODO: replace filter outbreak cases parameter, and just filter in 
--                             the initial query to avoid getting extra unneeded records; also just 
--                             make it a boolean value.
--
-- Testing code:
-- EXEC USP_HUM_DISEASE_REPORT_GETList_original 'en'
-- EXEC USP_HUM_DISEASE_REPORT_GETList_original 'en', @EIDSSReportID = 'H'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HUM_DISEASE_REPORT_GETList_original]
    @LanguageID NVARCHAR(50),
    @ReportKey BIGINT = NULL,
    @ReportID NVARCHAR(200) = NULL,
    @LegacyReportID NVARCHAR(200) = NULL,
    @SessionKey BIGINT = NULL,
    @PatientID BIGINT = NULL,
    @PersonID NVARCHAR(200) = NULL,
    @DiseaseID BIGINT = NULL,
    @ReportStatusTypeID BIGINT = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @DateEnteredFrom DATETIME = NULL,
    @DateEnteredTo DATETIME = NULL,
    @ClassificationTypeID BIGINT = NULL,
    @HospitalizationYNID BIGINT = NULL,
    @PatientFirstName NVARCHAR(200) = NULL,
    @PatientMiddleName NVARCHAR(200) = NULL,
    @PatientLastName NVARCHAR(200) = NULL,
    @SentByFacilityID BIGINT = NULL,
    @ReceivedByFacilityID BIGINT = NULL,
    @DiagnosisDateFrom DATETIME = NULL,
    @DiagnosisDateTo DATETIME = NULL,
    @LocalOrFieldSampleID NVARCHAR(200) = NULL,
    @DataEntrySiteID BIGINT = NULL,
    @DateOfSymptomsOnsetFrom DATETIME = NULL,
    @DateOfSymptomsOnsetTo DATETIME = NULL,
    @NotificationDateFrom DATETIME = NULL,
    @NotificationDateTo DATETIME = NULL,
    @DateOfFinalCaseClassificationFrom DATETIME = NULL,
    @DateOfFinalCaseClassificationTo DATETIME = NULL,
    @LocationOfExposureAdministrativeLevelID BIGINT = NULL,
    @OutcomeID BIGINT = NULL,
    @FilterOutbreakTiedReports INT = 0,
    @OutbreakCasesIndicator BIT = 0,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplySiteFiltrationIndicator BIT = 0,
    @SortColumn NVARCHAR(30) = 'ReportID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @Page INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AdministrativeLevelNode AS HIERARCHYID,
            @LocationOfExposureLevelNode AS HIERARCHYID;
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL, INDEX IDX_ID (ID
                                                             ));
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL
    );

    BEGIN TRY
        IF @AdministrativeLevelID IS NOT NULL
        BEGIN
            SELECT @AdministrativeLevelNode = node
            FROM dbo.gisLocation
            WHERE idfsLocation = @AdministrativeLevelID;
        END;

        IF @LocationOfExposureAdministrativeLevelID IS NOT NULL
        BEGIN
            SELECT @LocationOfExposureLevelNode = node
            FROM dbo.gisLocation
            WHERE idfsLocation = @LocationOfExposureAdministrativeLevelID;
        END;

        -- ========================================================================================
        -- NO SITE FILTRATION RULES APPLIED
        --
        -- For first and second level sites, do not apply any site filtration rules.
        -- ========================================================================================
        IF @ApplySiteFiltrationIndicator = 0
        BEGIN
            INSERT INTO @Results
            SELECT hc.idfHumanCase,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                       AND h.intRowStatus = 0
                INNER JOIN dbo.tlbGeoLocation currentAddress
                    ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = currentAddress.idfsLocation
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation exposure
                    ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                LEFT JOIN dbo.gisLocation gExposure
                    ON gExposure.idfsLocation = exposure.idfsLocation
            WHERE hc.intRowStatus = 0
                  AND hc.idfsFinalDiagnosis IS NOT NULL
                  AND (
                          hc.idfHumanCase = @ReportKey
                          OR @ReportKey IS NULL
                      )
                  AND (
                          hc.idfParentMonitoringSession = @SessionKey
                          OR @SessionKey IS NULL
                      )
                  AND (
                          h.idfHumanActual = @PatientID
                          OR @PatientID IS NULL
                      )
                  AND (
                          h.strPersonId = @PersonID
                          OR @PersonID IS NULL
                      )
                  AND (
                          idfsFinalDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          idfsCaseProgressStatus = @ReportStatusTypeID
                          OR @ReportStatusTypeID IS NULL
                      )
                  AND (
                          g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          (CAST(hc.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datFinalDiagnosisDate AS DATE)
                  BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                          )
                          OR (
                                 @DiagnosisDateFrom IS NULL
                                 OR @DiagnosisDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datNotificationDate AS DATE)
                  BETWEEN @NotificationDateFrom AND @NotificationDateTo
                          )
                          OR (
                                 @NotificationDateFrom IS NULL
                                 OR @NotificationDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datOnSetDate AS DATE)
                  BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                          )
                          OR (
                                 @DateOfSymptomsOnsetFrom IS NULL
                                 OR @DateOfSymptomsOnsetTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datFinalCaseClassificationDate AS DATE)
                  BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                          )
                          OR (
                                 @DateOfFinalCaseClassificationFrom IS NULL
                                 OR @DateOfFinalCaseClassificationTo IS NULL
                             )
                      )
                  AND (
                          hc.idfReceivedByOffice = @ReceivedByFacilityID
                          OR @ReceivedByFacilityID IS NULL
                      )
                  AND (
                          hc.idfSentByOffice = @SentByFacilityID
                          OR @SentByFacilityID IS NULL
                      )
                  AND (
                          idfsFinalCaseStatus = @ClassificationTypeID
                          OR @ClassificationTypeID IS NULL
                      )
                  AND (
                          idfsYNHospitalization = @HospitalizationYNID
                          OR @HospitalizationYNID IS NULL
                      )
                  AND (
                          gExposure.node.IsDescendantOf(@LocationOfExposureLevelNode) = 1
                          OR @LocationOfExposureAdministrativeLevelID IS NULL
                      )
                  AND (
                          (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                            WHEN '' THEN
                                                                ISNULL(h.strFirstName, '')
                                                            ELSE
                                                                @PatientFirstName
                                                        END
                          )
                          OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                             WHEN '' THEN
                                                                 ISNULL(h.strSecondName, '')
                                                             ELSE
                                                                 @PatientMiddleName
                                                         END
                          )
                          OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                           WHEN '' THEN
                                                               ISNULL(h.strLastName, '')
                                                           ELSE
                                                               @PatientLastName
                                                       END
                          )
                          OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                      )
                  AND (
                          hc.idfsSite = @DataEntrySiteID
                          OR @DataEntrySiteID IS NULL
                      )
                  AND (
					(
						hc.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						hc.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
                  AND (
                          hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                          OR @ReportID IS NULL
                      )
                  AND (
                          hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                          OR @LegacyReportID IS NULL
                      )
                  AND (
                          m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                          OR @LocalOrFieldSampleID IS NULL
                      )
                 AND  (
                          hc.idfsOutcome = @OutcomeID
                          OR @OutcomeID IS NULL
                      )
            GROUP BY hc.idfHumanCase
            OPTION (RECOMPILE);
        END
        ELSE
        BEGIN
            INSERT INTO @Results
            SELECT hc.idfHumanCase,
            1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                       AND h.intRowStatus = 0
                INNER JOIN dbo.tlbGeoLocation currentAddress
                    ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = currentAddress.idfsLocation
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation exposure
                    ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                LEFT JOIN dbo.gisLocation gExposure
                    ON gExposure.idfsLocation = exposure.idfsLocation
            WHERE hc.intRowStatus = 0
                  AND hc.idfsSite = @UserSiteID
                  AND hc.idfsFinalDiagnosis IS NOT NULL
                  AND (
                          hc.idfHumanCase = @ReportKey
                          OR @ReportKey IS NULL
                      )
                  AND (
                          hc.idfParentMonitoringSession = @SessionKey
                          OR @SessionKey IS NULL
                      )
                  AND (
                          h.idfHumanActual = @PatientID
                          OR @PatientID IS NULL
                      )
                  AND (
                          h.strPersonId = @PersonID
                          OR @PersonID IS NULL
                      )
                  AND (
                          idfsFinalDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          idfsCaseProgressStatus = @ReportStatusTypeID
                          OR @ReportStatusTypeID IS NULL
                      )
                  AND (
                          g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          (CAST(hc.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datFinalDiagnosisDate AS DATE)
                  BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                          )
                          OR (
                                 @DiagnosisDateFrom IS NULL
                                 OR @DiagnosisDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datNotificationDate AS DATE)
                  BETWEEN @NotificationDateFrom AND @NotificationDateTo
                          )
                          OR (
                                 @NotificationDateFrom IS NULL
                                 OR @NotificationDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datOnSetDate AS DATE)
                  BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                          )
                          OR (
                                 @DateOfSymptomsOnsetFrom IS NULL
                                 OR @DateOfSymptomsOnsetTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datFinalCaseClassificationDate AS DATE)
                  BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                          )
                          OR (
                                 @DateOfFinalCaseClassificationFrom IS NULL
                                 OR @DateOfFinalCaseClassificationTo IS NULL
                             )
                      )
                  AND (
                          hc.idfReceivedByOffice = @ReceivedByFacilityID
                          OR @ReceivedByFacilityID IS NULL
                      )
                  AND (
                          hc.idfSentByOffice = @SentByFacilityID
                          OR @SentByFacilityID IS NULL
                      )
                  AND (
                          idfsFinalCaseStatus = @ClassificationTypeID
                          OR @ClassificationTypeID IS NULL
                      )
                  AND (
                          idfsYNHospitalization = @HospitalizationYNID
                          OR @HospitalizationYNID IS NULL
                      )
                  AND (
                          gExposure.node.IsDescendantOf(@LocationOfExposureLevelNode) = 1
                          OR @LocationOfExposureAdministrativeLevelID IS NULL
                      )
                  AND (
                          (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                            WHEN '' THEN
                                                                ISNULL(h.strFirstName, '')
                                                            ELSE
                                                                @PatientFirstName
                                                        END
                          )
                          OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                             WHEN '' THEN
                                                                 ISNULL(h.strSecondName, '')
                                                             ELSE
                                                                 @PatientMiddleName
                                                         END
                          )
                          OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                           WHEN '' THEN
                                                               ISNULL(h.strLastName, '')
                                                           ELSE
                                                               @PatientLastName
                                                       END
                          )
                          OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                      )
                  AND (
                          hc.idfsSite = @DataEntrySiteID
                          OR @DataEntrySiteID IS NULL
                      )
                  AND (
					(
						hc.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						hc.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
                  AND (
                          hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                          OR @ReportID IS NULL
                      )
                  AND (
                          hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                          OR @LegacyReportID IS NULL
                      )
                  AND (
                          m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                          OR @LocalOrFieldSampleID IS NULL
                      )
                 AND  (
                          hc.idfsOutcome = @OutcomeID
                   OR @OutcomeID IS NULL
                      )
            GROUP BY hc.idfHumanCase
            OPTION (RECOMPILE);

            DECLARE @FilteredResults TABLE
            (
                ID BIGINT NOT NULL,
                ReadPermissionIndicator BIT NOT NULL,
                AccessToPersonalDataPermissionIndicator BIT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
                WritePermissionIndicator BIT NOT NULL,
                DeletePermissionIndicator BIT NOT NULL, INDEX IDX_ID (ID
                                                                     ));

            -- =======================================================================================
            -- DEFAULT SITE FILTRATION RULES
            --
            -- Apply active default site filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0;
            DECLARE @AdministrativeLevelTypeID INT;
            DECLARE @OrganizationAdministrativeLevelNode HIERARCHYID;
            DECLARE @DefaultAccessRules AS TABLE
            (
                AccessRuleID BIGINT NOT NULL,
                ActiveIndicator INT NOT NULL,
                ReadPermissionIndicator BIT NOT NULL,
                AccessToPersonalDataPermissionIndicator BIT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
                WritePermissionIndicator BIT NOT NULL,
                DeletePermissionIndicator BIT NOT NULL,
                AdministrativeLevelTypeID INT NULL
            );

            INSERT INTO @DefaultAccessRules
            SELECT AccessRuleID,
                   a.intRowStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator,
                   a.AdministrativeLevelTypeID
            FROM dbo.AccessRule a
            WHERE DefaultRuleIndicator = 1;

            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537000;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537000;
				
                SELECT @AdministrativeLevelNode = g.node.GetAncestor(g.node.GetLevel() - @AdministrativeLevelTypeID)
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared AS l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.gisLocation g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.intRowStatus = 0
                WHERE o.idfOffice = @UserOrganizationID
                      AND g.node.GetLevel() >= @AdministrativeLevelTypeID;

                -- Administrative level specified in the rule of the site where the report was created.
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tstSite s
                        ON h.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                           AND o.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocation g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1;

                -- Administrative level specified in the rule of the report current residence address.
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbHuman hu
                        ON hu.idfHuman = h.idfHuman
                           AND hu.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = hu.idfCurrentResidenceAddress
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocation g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1;

                -- Administrative level specified in the rule of the report location of exposure, 
                -- if corresponding field was filled in.
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = h.idfPointGeoLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocation g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1;
            END;

            -- Report data shall be available to all sites' organizations connected to the particular report.
            -- Notification sent by, notification received by, facility where the patient first sought 
            -- care, hospital, and the conducting investigation organizations.
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 10537001;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE h.intRowStatus = 0
                      AND (
                              h.idfSentByOffice = @UserOrganizationID
                              OR h.idfReceivedByOffice = @UserOrganizationID
                              OR h.idfSoughtCareFacility = @UserOrganizationID
                              OR h.idfHospital = @UserOrganizationID
                              OR h.idfInvestigatedByOffice = @UserOrganizationID
                          )
                ORDER BY h.idfHumanCase;

                -- Sample collected by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfHumanCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbHumanCase h
                        ON h.idfHumanCase = m.idfHumanCase
                           AND h.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE m.intRowStatus = 0
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          )
                GROUP BY m.idfHumanCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;

                -- Sample transferred to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfHumanCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbHumanCase h
                        ON h.idfHumanCase = m.idfHumanCase
                           AND h.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial tom
                        ON m.idfMaterial = tom.idfMaterial
                           AND tom.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT t
                        ON tom.idfTransferOut = t.idfTransferOut
                           AND t.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE m.intRowStatus = 0
                      AND t.idfSendToOffice = @UserOrganizationID
                GROUP BY m.idfHumanCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;
            END;

            --
            -- Report data shall be available to the sites with the connected outbreak, if the report 
            -- is the primary report/session for an outbreak.
            --
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 10537002;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbOutbreak o
                        ON h.idfHumanCase = o.idfPrimaryCaseOrSession
                           AND o.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537002
                WHERE h.intRowStatus = 0
                      AND o.idfsSite = @UserSiteID;
            END;

            -- =======================================================================================
            -- CONFIGURABLE SITE FILTRATION RULES
            -- 
            -- Apply configurable site filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the default rules.
            -- =======================================================================================
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND sgs.idfsSite = h.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                 AND a.GrantingActorSiteID = h.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteID = h.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteID = h.idfsSite;

            -- Copy filtered results to results and use search criteria
            INSERT INTO @Results
            SELECT ID,
                   ReadPermissionIndicator,
                   AccessToPersonalDataPermissionIndicator,
                   AccessToGenderAndAgeDataPermissionIndicator,
                   WritePermissionIndicator,
                   DeletePermissionIndicator
            FROM @FilteredResults
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = ID
                INNER JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                       AND h.intRowStatus = 0
                INNER JOIN dbo.tlbHumanActual ha
                    ON ha.idfHumanActual = h.idfHumanActual
                       AND ha.intRowStatus = 0
                INNER JOIN dbo.tlbGeoLocation currentAddress
                    ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = currentAddress.idfsLocation
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation exposure
                    ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                LEFT JOIN dbo.gisLocation gExposure
                    ON gExposure.idfsLocation = exposure.idfsLocation
            WHERE hc.intRowStatus = 0
                  AND hc.idfsFinalDiagnosis IS NOT NULL
                  AND (
                          hc.idfHumanCase = @ReportKey
                          OR @ReportKey IS NULL
                      )
                  AND (
                          hc.idfParentMonitoringSession = @SessionKey
                          OR @SessionKey IS NULL
                      )
                  AND (
                          ha.idfHumanActual = @PatientID
                          OR @PatientID IS NULL
                      )
                  AND (
                          h.strPersonId = @PersonID
                          OR @PersonID IS NULL
                      )
                  AND (
                          idfsFinalDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          idfsCaseProgressStatus = @ReportStatusTypeID
                          OR @ReportStatusTypeID IS NULL
                      )
                  AND (
                          g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          (CAST(hc.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datFinalDiagnosisDate AS DATE)
                  BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                          )
                          OR (
                                 @DiagnosisDateFrom IS NULL
                                 OR @DiagnosisDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datNotificationDate AS DATE)
                  BETWEEN @NotificationDateFrom AND @NotificationDateTo
                          )
                          OR (
                                 @NotificationDateFrom IS NULL
                                 OR @NotificationDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datOnSetDate AS DATE)
                  BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                          )
                          OR (
                                 @DateOfSymptomsOnsetFrom IS NULL
                                 OR @DateOfSymptomsOnsetTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datFinalCaseClassificationDate AS DATE)
                  BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                          )
                          OR (
                                 @DateOfFinalCaseClassificationFrom IS NULL
                                 OR @DateOfFinalCaseClassificationTo IS NULL
                             )
                      )
                  AND (
                          hc.idfReceivedByOffice = @ReceivedByFacilityID
                          OR @ReceivedByFacilityID IS NULL
                      )
                  AND (
                          hc.idfSentByOffice = @SentByFacilityID
                          OR @SentByFacilityID IS NULL
                      )
                  AND (
                          idfsFinalCaseStatus = @ClassificationTypeID
                          OR @ClassificationTypeID IS NULL
                      )
                  AND (
                          idfsYNHospitalization = @HospitalizationYNID
                          OR @HospitalizationYNID IS NULL
                      )
                  AND (
                          gExposure.node.IsDescendantOf(@LocationOfExposureLevelNode) = 1
                          OR @LocationOfExposureAdministrativeLevelID IS NULL
                      )
                  AND (
                          (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                            WHEN '' THEN
                                                                ISNULL(h.strFirstName, '')
                                                            ELSE
                                                                @PatientFirstName
                                                        END
                          )
                          OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                             WHEN '' THEN
                                                                 ISNULL(h.strSecondName, '')
                                                             ELSE
                                                                 @PatientMiddleName
                                                         END
                          )
                          OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                           WHEN '' THEN
                                                               ISNULL(h.strLastName, '')
                                                           ELSE
                                                               @PatientLastName
                                                       END
                          )
                          OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                      )
                  AND (
                          hc.idfsSite = @DataEntrySiteID
                          OR @DataEntrySiteID IS NULL
                      )
                  AND (
					(
						hc.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						hc.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
                  AND (
                          hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                          OR @ReportID IS NULL
                      )
                  AND (
                          hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                          OR @LegacyReportID IS NULL
                      )
                  AND (
                          m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                          OR @LocalOrFieldSampleID IS NULL
                      )
                 AND  (
                          hc.idfsOutcome = @OutcomeID
                          OR @OutcomeID IS NULL
                      )
            GROUP BY ID,
                     ReadPermissionIndicator,
                     AccessToPersonalDataPermissionIndicator,
                     AccessToGenderAndAgeDataPermissionIndicator,
                     WritePermissionIndicator,
                     DeletePermissionIndicator
            OPTION (RECOMPILE);
        END;


        -- =======================================================================================
        -- Remove "Outbreak" tied disease reports, if filtering is needed
        -- =======================================================================================
        IF @FilterOutbreakTiedReports = 1
        BEGIN
            DELETE I
            FROM @Results I
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = I.ID
            WHERE hc.idfOutbreak IS NOT NULL;
        END;

        -- =======================================================================================
        -- DISEASE FILTRATION RULES
        --
        -- Apply disease filtration rules from use case SAUC62.
        -- =======================================================================================
        -- 
        -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
		
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT h.idfHumanCase
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = h.idfsFinalDiagnosis
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 1
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = -506 -- Default role
        );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbHumanCase hc
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tlbHuman h
                ON h.idfHuman = hc.idfHuman
                   AND h.intRowStatus = 0
            INNER JOIN dbo.tlbGeoLocation currentAddress
                ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = currentAddress.idfsLocation
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfHumanCase = hc.idfHumanCase
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation exposure
                ON exposure.idfGeoLocation = hc.idfPointGeoLocation
            LEFT JOIN dbo.gisLocation gExposure
                ON gExposure.idfsLocation = exposure.idfsLocation
        WHERE oa.intPermission = 2 -- Allow permission
              AND hc.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup
              AND hc.idfsFinalDiagnosis IS NOT NULL
              AND (
                      hc.idfHumanCase = @ReportKey
                      OR @ReportKey IS NULL
                  )
              AND (
                      hc.idfParentMonitoringSession = @SessionKey
                      OR @SessionKey IS NULL
                  )
              AND (
                      h.idfHumanActual = @PatientID
                      OR @PatientID IS NULL
                  )
              AND (
                      h.strPersonId = @PersonID
                      OR @PersonID IS NULL
                  )
              AND (
                      idfsFinalDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      idfsCaseProgressStatus = @ReportStatusTypeID
                      OR @ReportStatusTypeID IS NULL
                  )
              AND (
                      g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                      OR @AdministrativeLevelID IS NULL
                  )
              AND (
                      (CAST(hc.datEnteredDate AS DATE)
              BETWEEN @DateEnteredFrom AND @DateEnteredTo
                      )
                      OR (
                             @DateEnteredFrom IS NULL
                             OR @DateEnteredTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datFinalDiagnosisDate AS DATE)
              BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                      )
                 OR (
                             @DiagnosisDateFrom IS NULL
                             OR @DiagnosisDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datNotificationDate AS DATE)
              BETWEEN @NotificationDateFrom AND @NotificationDateTo
                      )
                      OR (
                             @NotificationDateFrom IS NULL
                             OR @NotificationDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datOnSetDate AS DATE)
              BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                      )
                      OR (
                             @DateOfSymptomsOnsetFrom IS NULL
                             OR @DateOfSymptomsOnsetTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datFinalCaseClassificationDate AS DATE)
              BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                      )
                      OR (
                             @DateOfFinalCaseClassificationFrom IS NULL
                             OR @DateOfFinalCaseClassificationTo IS NULL
                         )
                  )
              AND (
                      hc.idfReceivedByOffice = @ReceivedByFacilityID
                      OR @ReceivedByFacilityID IS NULL
                  )
              AND (
                      hc.idfSentByOffice = @SentByFacilityID
                      OR @SentByFacilityID IS NULL
                  )
              AND (
                      idfsFinalCaseStatus = @ClassificationTypeID
                      OR @ClassificationTypeID IS NULL
                  )
              AND (
                      idfsYNHospitalization = @HospitalizationYNID
                      OR @HospitalizationYNID IS NULL
                  )
              AND (
                      g.node.IsDescendantOf(@LocationOfExposureLevelNode) = 1
                      OR @LocationOfExposureAdministrativeLevelID IS NULL
                  )
              AND (
                      (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                        WHEN '' THEN
                                                            ISNULL(h.strFirstName, '')
                                                        ELSE
                                                            @PatientFirstName
                                                    END
                      )
                      OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                  )
              AND (
                      (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                         WHEN '' THEN
                                                             ISNULL(h.strSecondName, '')
                                                         ELSE
                                                             @PatientMiddleName
                                                     END
                      )
                      OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                  )
              AND (
                      (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                       WHEN '' THEN
                                                           ISNULL(h.strLastName, '')
                                                       ELSE
                                                           @PatientLastName
                                                   END
                      )
                      OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                  )
              AND (
                      hc.idfsSite = @DataEntrySiteID
                      OR @DataEntrySiteID IS NULL
                  )
              AND (
					(
						hc.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						hc.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
              AND (
                      hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                      OR @ReportID IS NULL
                  )
              AND (
                      hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                      OR @LegacyReportID IS NULL
                  )
              AND (
                      m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                      OR @LocalOrFieldSampleID IS NULL
                  )
             AND  (
                     hc.idfsOutcome = @OutcomeID
                     OR @OutcomeID IS NULL
                  )
        GROUP BY hc.idfHumanCase
        OPTION (RECOMPILE);

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbHumanCase hc
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbHuman h
                ON h.idfHuman = hc.idfHuman
                   AND h.intRowStatus = 0
            INNER JOIN dbo.tlbGeoLocation currentAddress
                ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = currentAddress.idfsLocation
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfHumanCase = hc.idfHumanCase
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation exposure
                ON exposure.idfGeoLocation = hc.idfPointGeoLocation
            LEFT JOIN dbo.gisLocation gExposure
                ON gExposure.idfsLocation = exposure.idfsLocation
        WHERE oa.intPermission = 2 -- Allow permission
              AND hc.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID
              AND hc.idfsFinalDiagnosis IS NOT NULL
              AND (
                      hc.idfHumanCase = @ReportKey
                      OR @ReportKey IS NULL
                  )
              AND (
                      hc.idfParentMonitoringSession = @SessionKey
                      OR @SessionKey IS NULL
                  )
              AND (
                      h.idfHumanActual = @PatientID
                      OR @PatientID IS NULL
                  )
              AND (
                      h.strPersonId = @PersonID
                      OR @PersonID IS NULL
                  )
              AND (
                      idfsFinalDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      idfsCaseProgressStatus = @ReportStatusTypeID
                      OR @ReportStatusTypeID IS NULL
                  )
              AND (
                      g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                      OR @AdministrativeLevelID IS NULL
                  )
              AND (
                      (CAST(hc.datEnteredDate AS DATE)
              BETWEEN @DateEnteredFrom AND @DateEnteredTo
                      )
                      OR (
                             @DateEnteredFrom IS NULL
                             OR @DateEnteredTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datFinalDiagnosisDate AS DATE)
              BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                      )
                      OR (
                             @DiagnosisDateFrom IS NULL
                             OR @DiagnosisDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datNotificationDate AS DATE)
              BETWEEN @NotificationDateFrom AND @NotificationDateTo
                      )
                      OR (
                             @NotificationDateFrom IS NULL
                             OR @NotificationDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datOnSetDate AS DATE)
              BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                      )
                      OR (
                             @DateOfSymptomsOnsetFrom IS NULL
                             OR @DateOfSymptomsOnsetTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datFinalCaseClassificationDate AS DATE)
              BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                      )
                      OR (
                             @DateOfFinalCaseClassificationFrom IS NULL
                             OR @DateOfFinalCaseClassificationTo IS NULL
                         )
                  )
              AND (
                      hc.idfReceivedByOffice = @ReceivedByFacilityID
                      OR @ReceivedByFacilityID IS NULL
                  )
              AND (
                      hc.idfSentByOffice = @SentByFacilityID
                      OR @SentByFacilityID IS NULL
                  )
              AND (
                      idfsFinalCaseStatus = @ClassificationTypeID
                      OR @ClassificationTypeID IS NULL
                  )
              AND (
                      idfsYNHospitalization = @HospitalizationYNID
                      OR @HospitalizationYNID IS NULL
                  )
              AND (
                      g.node.IsDescendantOf(@LocationOfExposureLevelNode) = 1
                      OR @LocationOfExposureAdministrativeLevelID IS NULL
                  )
              AND (
                      (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                        WHEN '' THEN
                                                            ISNULL(h.strFirstName, '')
                                                        ELSE
                                                            @PatientFirstName
                                                    END
                      )
                      OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                  )
              AND (
                      (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                         WHEN '' THEN
                                                             ISNULL(h.strSecondName, '')
                                                         ELSE
                                                             @PatientMiddleName
                                                     END
                      )
                      OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                  )
       AND (
                      (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                       WHEN '' THEN
                                                           ISNULL(h.strLastName, '')
                                                       ELSE
                                                           @PatientLastName
                                                   END
                      )
                      OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                  )
              AND (
                      hc.idfsSite = @DataEntrySiteID
                      OR @DataEntrySiteID IS NULL
                  )
              AND (
					(
						hc.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						hc.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
              AND (
                      hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                      OR @ReportID IS NULL
                  )
              AND (
                      hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                      OR @LegacyReportID IS NULL
                  )
              AND (
                      m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                      OR @LocalOrFieldSampleID IS NULL
                  )
             AND  (
                      hc.idfsOutcome = @OutcomeID
                      OR @OutcomeID IS NULL
                  )
        GROUP BY hc.idfHumanCase
        OPTION (RECOMPILE);

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                       AND oa.intRowStatus = 0
            WHERE intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND idfActor = @UserEmployeeID
        );
		
        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        INSERT INTO @FinalResults
        SELECT ID,
               ReadPermissionIndicator,
               AccessToPersonalDataPermissionIndicator,
               AccessToGenderAndAgeDataPermissionIndicator,
               WritePermissionIndicator,
               DeletePermissionIndicator
        FROM @Results res
        WHERE res.ReadPermissionIndicator = 1
        GROUP BY ID,
                 ReadPermissionIndicator,
                 AccessToPersonalDataPermissionIndicator,
                 AccessToGenderAndAgeDataPermissionIndicator,
                 WritePermissionIndicator,
                 DeletePermissionIndicator;

		
        WITH paging
        AS (SELECT ID,
                   c = COUNT(*) OVER ()
            FROM @FinalResults res
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = res.ID
                INNER JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                       AND h.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = h.idfCurrentResidenceAddress
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = gl.idfsLocation
                LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                    ON LH.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                    ON disease.idfsReference = hc.idfsFinalDiagnosis
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) finalClassification
                    ON finalClassification.idfsReference = hc.idfsFinalCaseStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus
                    ON reportStatus.idfsReference = hc.idfsCaseProgressStatus
            ORDER BY CASE
                         WHEN @SortColumn = 'ReportID'
                              AND @SortOrder = 'ASC' THEN
                             hc.strCaseID
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'ReportID'
                              AND @SortOrder = 'DESC' THEN
                             hc.strCaseID
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'EnteredDate'
                              AND @SortOrder = 'ASC' THEN
                             hc.datEnteredDate
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'EnteredDate'
                              AND @SortOrder = 'DESC' THEN
                             hc.datEnteredDate
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'DiseaseName'
                              AND @SortOrder = 'ASC' THEN
                             disease.name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'DiseaseName'
                              AND @SortOrder = 'DESC' THEN
                             disease.name
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'PersonName'
                              AND @SortOrder = 'ASC' THEN
                             ISNULL(h.strLastName, N'') + ISNULL(', ' + h.strFirstName, N'')
                             + ISNULL(' ' + h.strSecondName, N'')
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'PersonName'
                              AND @SortOrder = 'DESC' THEN
                             ISNULL(h.strLastName, N'') + ISNULL(', ' + h.strFirstName, N'')
                             + ISNULL(' ' + h.strSecondName, N'')
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'PersonLocation'
                              AND @SortOrder = 'ASC' THEN
                     (LH.AdminLevel1Name + ', ' + LH.AdminLevel2Name)
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'PersonLocation'
                              AND @SortOrder = 'DESC' THEN
                     (LH.AdminLevel1Name + ', ' + LH.AdminLevel2Name)
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'ClassificationTypeName'
                              AND @SortOrder = 'ASC' THEN
                             finalClassification.name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'ClassificationTypeName'
                              AND @SortOrder = 'DESC' THEN
                             finalClassification.name
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'ReportStatusTypeName'
                              AND @SortOrder = 'ASC' THEN
                             reportStatus.name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'ReportStatusTypeName'
                              AND @SortOrder = 'DESC' THEN
                             reportStatus.name
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'LegacyReportID'
                              AND @SortOrder = 'ASC' THEN
                             hc.LegacyCaseID
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'LegacyReportID'
                              AND @SortOrder = 'DESC' THEN
                             hc.LegacyCaseID
                     END DESC OFFSET @PageSize * (@Page - 1) ROWS FETCH NEXT @PageSize ROWS ONLY
     )
        SELECT res.ID AS ReportKey,
               hc.strCaseId AS ReportID,
               hc.LegacyCaseID AS LegacyReportID,
               reportStatus.name AS ReportStatusTypeName,
               reportType.name AS ReportTypeName,
               hc.datTentativeDiagnosisDate AS TentativeDiagnosisDate,
               hc.datFinalDiagnosisDate AS FinalDiagnosisDate,
               ISNULL(finalClassification.name, initialClassification.name) AS ClassificationTypeName,
               finalClassification.name AS FinalClassificationTypeName,
               hc.datOnSetDate AS DateOfOnset,
               hc.idfsFinalDiagnosis AS DiseaseID,
               disease.Name AS DiseaseName,
               h.idfHumanActual AS PersonMasterID,
               hc.idfHuman AS PersonKey,
               haai.EIDSSPersonID AS PersonID,
               h.strPersonID AS PersonalID,
               dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) AS PersonName,
               ISNULL(LH.AdminLevel1Name, '') + IIF(LH.AdminLevel2Name IS NULL, '', ', ')
               + ISNULL(LH.AdminLevel2Name, '') AS PersonLocation,
               ha.strEmployerName AS EmployerName,
               hc.datEnteredDate AS EnteredDate,
               ISNULL(p.strFamilyName, N'') + ISNULL(', ' + p.strFirstName, N'') + ISNULL(' ' + p.strSecondName, N'') AS EnteredByPersonName,
               hc.datModificationDate AS ModificationDate,
               ISNULL(hospitalization.name, hospitalization.strDefault) AS HospitalizationStatus,
               hc.idfsSite AS SiteID,
               res.ReadPermissionIndicator,
               res.AccessToPersonalDataPermissionIndicator,
               res.AccessToGenderAndAgeDataPermissionIndicator,
               res.WritePermissionIndicator,
               res.DeletePermissionIndicator,
               c AS RecordCount,
               (
                   SELECT COUNT(*) FROM dbo.tlbHumanCase hc WHERE hc.intRowStatus = 0
               ) AS TotalCount,
               TotalPages = (c / @PageSize) + IIF(c % @PageSize > 0, 1, 0),
               CurrentPage = @Page,
               LH.AdminLevel2Name Region,
			   LH.AdminLevel3Name Rayon
        FROM @FinalResults res
            INNER JOIN paging
                ON paging.ID = res.ID
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN dbo.tlbHuman h
                ON h.idfHuman = hc.idfHuman
                   AND h.intRowStatus = 0
            INNER JOIN dbo.tlbHumanActual ha
                ON ha.idfHumanActual = h.idfHumanActual
                   AND ha.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation gl
                ON gl.idfGeoLocation = h.idfCurrentResidenceAddress
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = gl.idfsLocation
            LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                ON LH.idfsLocation = gl.idfsLocation
            LEFT JOIN dbo.HumanActualAddlInfo haai
                ON haai.HumanActualAddlInfoUID = ha.idfHumanActual
                   AND haai.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                ON disease.idfsReference = hc.idfsFinalDiagnosis
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) initialClassification
                ON initialClassification.idfsReference = hc.idfsInitialCaseStatus
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) finalClassification
                ON finalClassification.idfsReference = hc.idfsFinalCaseStatus
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus
                ON reportStatus.idfsReference = hc.idfsCaseProgressStatus
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000144) reportType
                ON reportType.idfsReference = hc.DiseaseReportTypeID
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000041) hospitalization
                ON hospitalization.idfsReference = idfsHospitalizationStatus
            LEFT JOIN dbo.tlbPerson p
                ON p.idfPerson = hc.idfPersonEnteredBy
                   AND p.intRowStatus = 0
        OPTION (RECOMPILE);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
