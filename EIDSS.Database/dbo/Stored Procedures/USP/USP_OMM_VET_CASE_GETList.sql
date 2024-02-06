-- ================================================================================================
-- Name: USP_OMM_VET_CASE_GETList
--
-- Description:	Get veterinary outbreak case list for the laboratory register new sample and other 
-- use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     08/22/2012 Initial release
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_VET_CASE_GETList]
(
    @LanguageID NVARCHAR(50),
    @CaseKey BIGINT = NULL,
    @CaseID NVARCHAR(200) = NULL,
    @LegacyCaseID NVARCHAR(200) = NULL,
    @SessionKey BIGINT = NULL,
    @FarmMasterID BIGINT = NULL,
    @DiseaseID BIGINT = NULL,
    @ReportStatusTypeID BIGINT = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @DateEnteredFrom DATE = NULL,
    @DateEnteredTo DATE = NULL,
    @ClassificationTypeID BIGINT = NULL,
    @PersonID NVARCHAR(200) = NULL,
    @ReportTypeID BIGINT = NULL,
    @SpeciesTypeID BIGINT = NULL,
    @DiagnosisDateFrom DATE = NULL,
    @DiagnosisDateTo DATE = NULL,
    @InvestigationDateFrom DATE = NULL,
    @InvestigationDateTo DATE = NULL,
    @LocalOrFieldSampleID NVARCHAR(200) = NULL,
    @TotalAnimalQuantityFrom INT = NULL,
    @TotalAnimalQuantityTo INT = NULL,
    @SessionID NVARCHAR(200) = NULL,
    @DataEntrySiteID BIGINT = NULL,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplySiteFiltrationIndicator BIT = 0,
    @SortColumn NVARCHAR(30) = 'CaseID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @PageNumber INT = 1,
    @PageSize INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AdministrativeLevelNode AS HIERARCHYID;
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL, INDEX IDX_ID (ID
                                                             ));

    BEGIN TRY
        IF @AdministrativeLevelID IS NOT NULL
        BEGIN
            SELECT @AdministrativeLevelNode = node
            FROM dbo.gisLocation
            WHERE idfsLocation = @AdministrativeLevelID;
        END;

        -- ========================================================================================
        -- NO SITE FILTRATION RULES APPLIED
        --
        -- For first and second level sites, do not apply any site filtration rules.
        -- ========================================================================================
        IF @ApplySiteFiltrationIndicator = 0
        BEGIN
            INSERT INTO @Results
            SELECT ocr.OutBreakCaseReportUID,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.OutbreakCaseReport ocr
                INNER JOIN dbo.tlbVetCase v
                    ON v.idfVetCase = ocr.idfVetCase
                       AND v.intRowStatus = 0
                INNER JOIN dbo.tlbOutbreak o
                    ON o.idfOutbreak = ocr.idfOutbreak
                       AND o.intRowStatus = 0
                INNER JOIN dbo.tlbFarm f
                    ON f.idfFarm = v.idfFarm
                LEFT JOIN dbo.tlbHuman h
                    ON h.idfHuman = f.idfHuman
                LEFT JOIN dbo.HumanActualAddlInfo haai
                    ON haai.HumanActualAddlInfoUID = h.idfHumanActual
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = f.idfFarmAddress
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfVetCase = v.idfVetCase
            WHERE o.intRowStatus = 0
                  AND (
                          f.idfFarmActual = @FarmMasterID
                          OR @FarmMasterID IS NULL
                      )
                  AND (
                          ocr.OutBreakCaseReportUID = @CaseKey
                          OR @CaseKey IS NULL
                      )
                  AND (
                          ocr.idfOutbreak = @SessionKey
                          OR @SessionKey IS NULL
                      )
                  AND (
                          g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          v.idfsFinalDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          v.idfsCaseClassification = @ClassificationTypeID
                          OR @ClassificationTypeID IS NULL
                      )
                  AND (
                          v.idfsCaseProgressStatus = @ReportStatusTypeID
                          OR @ReportStatusTypeID IS NULL
                      )
                  AND (
                          (CAST(v.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          v.idfsCaseReportType = @ReportTypeID
                          OR @ReportTypeID IS NULL
                      )
                  AND (
                          v.idfsCaseType = @SpeciesTypeID
                          OR @SpeciesTypeID IS NULL
                      )
                  AND (
                          (CAST(v.datFinalDiagnosisDate AS DATE)
                  BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                          )
                          OR (
                                 @DiagnosisDateFrom IS NULL
                                 OR @DiagnosisDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(v.datInvestigationDate AS DATE)
                  BETWEEN @InvestigationDateFrom AND @InvestigationDateTo
                          )
                          OR (
                                 @InvestigationDateFrom IS NULL
                                 OR @InvestigationDateTo IS NULL
                             )
                      )
                  AND (
                          (
                              (f.intAvianTotalAnimalQty
                  BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                              )
                              OR (f.intLivestockTotalAnimalQty
                  BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                                 )
                          )
                          OR (
                                 @TotalAnimalQuantityFrom IS NULL
                                 OR @TotalAnimalQuantityTo IS NULL
                             )
                      )
                  AND (
                          v.idfsSite = @DataEntrySiteID
                          OR @DataEntrySiteID IS NULL
                      )
                  AND (
                          ocr.strOutbreakCaseID LIKE '%' + TRIM(@CaseID) + '%'
                          OR @CaseID IS NULL
                      )
                  AND (
                          v.LegacyCaseID LIKE '%' + TRIM(@LegacyCaseID) + '%'
                          OR @LegacyCaseID IS NULL
                      )
                  AND (
                          haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
                          OR @PersonID IS NULL
                      )
                  AND (
                          m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                          OR @LocalOrFieldSampleID IS NULL
                      )
                  AND (
                          o.strOutbreakID LIKE '%' + TRIM(@SessionID) + '%'
                          OR @SessionID IS NULL
                      )
            GROUP BY ocr.OutBreakCaseReportUID;
        END
        ELSE
        BEGIN
            INSERT INTO @Results
            SELECT ocr.OutBreakCaseReportUID,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.OutbreakCaseReport ocr
                INNER JOIN dbo.tlbVetCase v
                    ON v.idfVetCase = ocr.idfVetCase
                       AND v.intRowStatus = 0
                INNER JOIN dbo.tlbOutbreak o
                    ON o.idfOutbreak = ocr.idfOutbreak
                       AND o.intRowStatus = 0
                INNER JOIN dbo.tlbFarm f
                    ON f.idfFarm = v.idfFarm
                LEFT JOIN dbo.tlbHuman h
                    ON h.idfHuman = f.idfHuman
                LEFT JOIN dbo.HumanActualAddlInfo haai
                    ON haai.HumanActualAddlInfoUID = h.idfHumanActual
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = f.idfFarmAddress
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfVetCase = v.idfVetCase
            WHERE ocr.intRowStatus = 0
                  AND (
                          f.idfFarmActual = @FarmMasterID
                          OR @FarmMasterID IS NULL
                      )
                  AND (
                          ocr.OutBreakCaseReportUID = @CaseKey
                          OR @CaseKey IS NULL
                      )
                  AND (
                          ocr.idfOutbreak = @SessionKey
                          OR @SessionKey IS NULL
                      )
                  AND (
                          g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          v.idfsFinalDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          v.idfsCaseClassification = @ClassificationTypeID
                          OR @ClassificationTypeID IS NULL
                      )
                  AND (
                          v.idfsCaseProgressStatus = @ReportStatusTypeID
                          OR @ReportStatusTypeID IS NULL
                      )
                  AND (
                          (CAST(v.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          v.idfsCaseReportType = @ReportTypeID
                          OR @ReportTypeID IS NULL
                      )
                  AND (
                          v.idfsCaseType = @SpeciesTypeID
                          OR @SpeciesTypeID IS NULL
                      )
                  AND (
                          (CAST(v.datFinalDiagnosisDate AS DATE)
                  BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                          )
                          OR (
                                 @DiagnosisDateFrom IS NULL
                                 OR @DiagnosisDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(v.datInvestigationDate AS DATE)
                  BETWEEN @InvestigationDateFrom AND @InvestigationDateTo
                          )
                          OR (
                                 @InvestigationDateFrom IS NULL
                                 OR @InvestigationDateTo IS NULL
                             )
                      )
                  AND (
                          (
                              (f.intAvianTotalAnimalQty
                  BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                              )
                              OR (f.intLivestockTotalAnimalQty
                  BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                                 )
                          )
                          OR (
                                 @TotalAnimalQuantityFrom IS NULL
                                 OR @TotalAnimalQuantityTo IS NULL
                             )
                      )
                  AND (
                          v.idfsSite = @DataEntrySiteID
                          OR @DataEntrySiteID IS NULL
                      )
                  AND (
                          ocr.strOutbreakCaseID LIKE '%' + TRIM(@CaseID) + '%'
                          OR @CaseID IS NULL
                      )
                  AND (
                          v.LegacyCaseID LIKE '%' + TRIM(@LegacyCaseID) + '%'
                          OR @LegacyCaseID IS NULL
                      )
                  AND (
                          haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
                          OR @PersonID IS NULL
                      )
                  AND (
                          m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                          OR @LocalOrFieldSampleID IS NULL
                      )
                  AND (
                          o.strOutbreakID LIKE '%' + TRIM(@SessionID) + '%'
                          OR @SessionID IS NULL
                      )
            GROUP BY ocr.OutBreakCaseReportUID;

            DECLARE @FilteredResults TABLE
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

            --
            -- Report data shall be available to all sites of the same administrative level 
            -- specified in the rule.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537009;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537009;

                SELECT @OrganizationAdministrativeLevelNode
                    = g.node.GetAncestor(g.node.GetLevel() - @AdministrativeLevelTypeID)
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.gisLocation g
                        ON g.idfsLocation = l.idfsLocation
                WHERE o.idfOffice = @UserOrganizationID
                      AND g.node.GetLevel() >= @AdministrativeLevelTypeID;

                -- Administrative level specified in the rule of the site where the report was created.
                INSERT INTO @FilteredResults
                SELECT ocr.OutBreakCaseReportUID,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.OutbreakCaseReport ocr
                    INNER JOIN dbo.tlbVetCase v
                        ON v.idfVetCase = ocr.idfVetCase
                           AND v.intRowStatus = 0
                    INNER JOIN dbo.tstSite s
                        ON v.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.gisLocation g
                        ON g.idfsLocation = l.idfsLocation
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537009
                WHERE v.intRowStatus = 0
                      AND (
                              v.idfsCaseType = @SpeciesTypeID
                              OR @SpeciesTypeID IS NULL
                          )
                      AND (
                              (CAST(v.datEnteredDate AS DATE)
                      BETWEEN @DateEnteredFrom AND @DateEnteredTo
                              )
                              OR (
                                     @DateEnteredFrom IS NULL
                                     OR @DateEnteredTo IS NULL
                                 )
                          )
                      AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1;

                -- Administrative level specified in the rule of the farm address.
                INSERT INTO @FilteredResults
                SELECT ocr.OutBreakCaseReportUID,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.OutbreakCaseReport ocr
                    INNER JOIN dbo.tlbVetCase v
                        ON v.idfVetCase = ocr.idfVetCase
                           AND v.intRowStatus = 0
                    INNER JOIN dbo.tlbFarm f
                        ON f.idfFarm = v.idfFarm
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = f.idfFarmAddress
                    INNER JOIN dbo.gisLocation g
                        ON g.idfsLocation = l.idfsLocation
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537009
                WHERE ocr.intRowStatus = 0
                      AND (
                              v.idfsCaseType = @SpeciesTypeID
                              OR @SpeciesTypeID IS NULL
                          )
                      AND (
                              (CAST(v.datEnteredDate AS DATE)
                      BETWEEN @DateEnteredFrom AND @DateEnteredTo
                              )
                              OR (
                                     @DateEnteredFrom IS NULL
                                     OR @DateEnteredTo IS NULL
                                 )
                          )
                      AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1;
            END;

            --
            -- Report data shall be available to all sites' organizations connected to the particular report.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537010;

            IF @RuleActiveStatus = 0
            BEGIN
                -- Investigated and reported by organizations
                INSERT INTO @FilteredResults
                SELECT ocr.OutBreakCaseReportUID,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.OutbreakCaseReport ocr
                    INNER JOIN dbo.tlbVetCase v
                        ON v.idfVetCase = ocr.idfVetCase
                           AND v.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537010
                WHERE (ocr.intRowStatus = 0)
                      AND (
                              v.idfInvestigatedByOffice = @UserOrganizationID
                              OR v.idfReportedByOffice = @UserOrganizationID
                          );

                -- Sample collected by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(ocr.OutBreakCaseReportUID),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.OutbreakCaseReport ocr
                        ON ocr.idfVetCase = m.idfVetCase
                           AND ocr.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537010
                WHERE m.intRowStatus = 0
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          )
                GROUP BY m.idfVetCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;

                -- Sample transferred to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(ocr.OutBreakCaseReportUID),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.OutbreakCaseReport ocr
                        ON ocr.idfVetCase = m.idfVetCase
                           AND ocr.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial tom
                        ON m.idfMaterial = tom.idfMaterial
                           AND tom.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT t
                        ON tom.idfTransferOut = t.idfTransferOut
                           AND t.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537010
                WHERE m.intRowStatus = 0
                      AND t.idfSendToOffice = @UserOrganizationID
                GROUP BY m.idfVetCase,
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
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537011;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT ocr.OutBreakCaseReportUID,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.OutbreakCaseReport ocr
                    INNER JOIN dbo.tlbVetCase v
                        ON v.idfVetCase = ocr.idfVetCase
                           AND v.intRowStatus = 0
                    INNER JOIN dbo.tlbOutbreak o
                        ON v.idfVetCase = o.idfPrimaryCaseOrSession
                           AND o.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537011
                WHERE v.intRowStatus = 0
                      AND o.idfsSite = @UserSiteID
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
            SELECT ocr.OutBreakCaseReportUID,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.OutbreakCaseReport ocr
                INNER JOIN dbo.tlbVetCase v
                    ON v.idfVetCase = ocr.idfVetCase
                       AND v.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ocr.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ocr.OutBreakCaseReportUID,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.OutbreakCaseReport ocr
                INNER JOIN dbo.tlbVetCase v
                    ON v.idfVetCase = ocr.idfVetCase
                       AND v.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ocr.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ocr.OutBreakCaseReportUID,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.OutbreakCaseReport ocr
                INNER JOIN dbo.tlbVetCase v
                    ON v.idfVetCase = ocr.idfVetCase
                       AND v.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
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
            WHERE ocr.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ocr.OutBreakCaseReportUID,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.OutbreakCaseReport ocr
                INNER JOIN dbo.tlbVetCase v
                    ON v.idfVetCase = ocr.idfVetCase
                       AND v.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
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
            WHERE ocr.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ocr.OutBreakCaseReportUID,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.OutbreakCaseReport ocr
                INNER JOIN dbo.tlbVetCase v
                    ON v.idfVetCase = ocr.idfVetCase
                       AND v.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ocr.intRowStatus = 0
                  AND sgs.idfsSite = v.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ocr.OutBreakCaseReportUID,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.OutbreakCaseReport ocr
                INNER JOIN dbo.tlbVetCase v
                    ON v.idfVetCase = ocr.idfVetCase
                       AND v.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ocr.intRowStatus = 0
                  AND a.GrantingActorSiteID = v.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ocr.OutBreakCaseReportUID,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.OutbreakCaseReport ocr
                INNER JOIN dbo.tlbVetCase v
                    ON v.idfVetCase = ocr.idfVetCase
                       AND v.intRowStatus = 0
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
            WHERE ocr.intRowStatus = 0
                  AND a.GrantingActorSiteID = v.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ocr.OutBreakCaseReportUID,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.OutbreakCaseReport ocr
                INNER JOIN dbo.tlbVetCase v
                    ON v.idfVetCase = ocr.idfVetCase
                       AND v.intRowStatus = 0
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
            WHERE ocr.intRowStatus = 0
                  AND a.GrantingActorSiteID = v.idfsSite;

            -- Copy filtered results to results and use search criteria
            INSERT INTO @Results
            SELECT ID,
                   ReadPermissionIndicator,
                   AccessToPersonalDataPermissionIndicator,
                   AccessToGenderAndAgeDataPermissionIndicator,
                   WritePermissionIndicator,
                   DeletePermissionIndicator
            FROM @FilteredResults
                INNER JOIN dbo.OutbreakCaseReport ocr
                    ON ocr.OutBreakCaseReportUID = ID
                INNER JOIN dbo.tlbOutbreak o 
                    ON o.idfOutbreak = ocr.idfOutbreak 
                        AND o.intRowStatus = 0
                INNER JOIN dbo.tlbVetCase v
                    ON v.idfVetCase = ocr.idfVetCase
                INNER JOIN dbo.tlbFarm f
                    ON f.idfFarm = v.idfFarm
                LEFT JOIN dbo.tlbHuman h
                    ON h.idfHuman = f.idfHuman
                LEFT JOIN dbo.HumanActualAddlInfo haai
                    ON haai.HumanActualAddlInfoUID = h.idfHumanActual
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = f.idfFarmAddress
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfVetCase = v.idfVetCase
            WHERE ocr.intRowStatus = 0
                  AND (
                          f.idfFarmActual = @FarmMasterID
                          OR @FarmMasterID IS NULL
                      )
                  AND (
                          ocr.OutBreakCaseReportUID = @CaseKey
                          OR @CaseKey IS NULL
                      )
                  AND (
                          ocr.idfOutbreak = @SessionKey
                          OR @SessionKey IS NULL
                      )
                  AND (
                          g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          v.idfsFinalDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          v.idfsCaseClassification = @ClassificationTypeID
                          OR @ClassificationTypeID IS NULL
                      )
                  AND (
                          v.idfsCaseProgressStatus = @ReportStatusTypeID
                          OR @ReportStatusTypeID IS NULL
                      )
                  AND (
                          (CAST(v.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          v.idfsCaseReportType = @ReportTypeID
                          OR @ReportTypeID IS NULL
                      )
                  AND (
                          v.idfsCaseType = @SpeciesTypeID
                          OR @SpeciesTypeID IS NULL
                      )
                  AND (
                          (CAST(v.datFinalDiagnosisDate AS DATE)
                  BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                          )
                          OR (
                                 @DiagnosisDateFrom IS NULL
                                 OR @DiagnosisDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(v.datInvestigationDate AS DATE)
                  BETWEEN @InvestigationDateFrom AND @InvestigationDateTo
                          )
                          OR (
                                 @InvestigationDateFrom IS NULL
                                 OR @InvestigationDateTo IS NULL
                             )
                      )
                  AND (
                          (
                              (f.intAvianTotalAnimalQty
                  BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                              )
                              OR (f.intLivestockTotalAnimalQty
                  BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                                 )
                          )
                          OR (
                                 @TotalAnimalQuantityFrom IS NULL
                                 OR @TotalAnimalQuantityTo IS NULL
                             )
                      )
                  AND (
                          v.idfsSite = @DataEntrySiteID
                          OR @DataEntrySiteID IS NULL
                      )
                  AND (
                          ocr.strOutbreakCaseID LIKE '%' + TRIM(@CaseID) + '%'
                          OR @CaseID IS NULL
                      )
                  AND (
                          v.LegacyCaseID LIKE '%' + TRIM(@LegacyCaseID) + '%'
                          OR @LegacyCaseID IS NULL
                      )
                  AND (
                          haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
                          OR @PersonID IS NULL
                      )
                  AND (
                          m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                          OR @LocalOrFieldSampleID IS NULL
                      )
                  AND (
                          o.strOutbreakID LIKE '%' + TRIM(@SessionID) + '%'
                          OR @SessionID IS NULL
                      )
            GROUP BY ID,
                     ReadPermissionIndicator,
                     AccessToPersonalDataPermissionIndicator,
                     AccessToGenderAndAgeDataPermissionIndicator,
                     WritePermissionIndicator,
                     DeletePermissionIndicator;
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
        WHERE ID IN (
                        SELECT ocr.OutBreakCaseReportUID
                        FROM dbo.OutbreakCaseReport ocr
                            INNER JOIN dbo.tlbVetCase v
                                ON v.idfVetCase = ocr.idfVetCase
                                   AND v.intRowStatus = 0
                            INNER JOIN dbo.tstObjectAccess AS oa
                                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE ocr.intRowStatus = 0
                              AND oa.intPermission = 1
                              AND oa.idfActor = -506 -- Default role
                    );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT ocr.OutBreakCaseReportUID,
               1,
               1,
               1,
               1,
               1
        FROM dbo.OutbreakCaseReport ocr
            INNER JOIN dbo.tlbOutbreak o 
                ON o.idfOutbreak = ocr.idfOutbreak 
                   AND o.intRowStatus = 0
            INNER JOIN dbo.tlbVetCase v
                ON v.idfVetCase = ocr.idfVetCase
                   AND v.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = v.idfFarm
            LEFT JOIN dbo.tlbHuman h
                ON h.idfHuman = f.idfHuman
            LEFT JOIN dbo.HumanActualAddlInfo haai
                ON haai.HumanActualAddlInfoUID = h.idfHumanActual
            LEFT JOIN dbo.tlbGeoLocation gl
                ON gl.idfGeoLocation = f.idfFarmAddress
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = gl.idfsLocation
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfVetCase = v.idfVetCase
                   AND m.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND ocr.intRowStatus = 0
              AND oa.idfActor = egm.idfEmployeeGroup
              AND (
                      f.idfFarmActual = @FarmMasterID
                      OR @FarmMasterID IS NULL
                  )
              AND (
                      ocr.OutBreakCaseReportUID = @CaseKey
                      OR @CaseKey IS NULL
                  )
              AND (
                      ocr.idfOutbreak = @SessionKey
                      OR @SessionKey IS NULL
                  )
              AND (
                      g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                      OR @AdministrativeLevelID IS NULL
                  )
              AND (
                      v.idfsFinalDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      v.idfsCaseClassification = @ClassificationTypeID
                      OR @ClassificationTypeID IS NULL
                  )
              AND (
                      v.idfsCaseProgressStatus = @ReportStatusTypeID
                      OR @ReportStatusTypeID IS NULL
                  )
              AND (
                      (CAST(v.datEnteredDate AS DATE)
              BETWEEN @DateEnteredFrom AND @DateEnteredTo
                      )
                      OR (
                             @DateEnteredFrom IS NULL
                             OR @DateEnteredTo IS NULL
                         )
                  )
              AND (
                      v.idfsCaseReportType = @ReportTypeID
                      OR @ReportTypeID IS NULL
                  )
              AND (
                      v.idfsCaseType = @SpeciesTypeID
                      OR @SpeciesTypeID IS NULL
                  )
              AND (
                      (CAST(v.datFinalDiagnosisDate AS DATE)
              BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                      )
                      OR (
                             @DiagnosisDateFrom IS NULL
                             OR @DiagnosisDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(v.datInvestigationDate AS DATE)
              BETWEEN @InvestigationDateFrom AND @InvestigationDateTo
                      )
                      OR (
                             @InvestigationDateFrom IS NULL
                             OR @InvestigationDateTo IS NULL
                         )
                  )
              AND (
                      (
                          (f.intAvianTotalAnimalQty
              BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                          )
                          OR (f.intLivestockTotalAnimalQty
              BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                             )
                      )
                      OR (
                             @TotalAnimalQuantityFrom IS NULL
                             OR @TotalAnimalQuantityTo IS NULL
                         )
                  )
              AND (
                      v.idfsSite = @DataEntrySiteID
                      OR @DataEntrySiteID IS NULL
                  )
              AND (
                      ocr.strOutbreakCaseID LIKE '%' + TRIM(@CaseID) + '%'
                      OR @CaseID IS NULL
                  )
              AND (
                      v.LegacyCaseID LIKE '%' + TRIM(@LegacyCaseID) + '%'
                      OR @LegacyCaseID IS NULL
                  )
              AND (
                      haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
                      OR @PersonID IS NULL
                  )
              AND (
                      m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                      OR @LocalOrFieldSampleID IS NULL
                  )
              AND (
                      o.strOutbreakID LIKE '%' + TRIM(@SessionID) + '%'
                      OR @SessionID IS NULL
                  )
        GROUP BY ocr.OutBreakCaseReportUID;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.OutbreakCaseReport ocr
                ON ocr.OutBreakCaseReportUID = res.ID
            INNER JOIN dbo.tlbVetCase v
                ON v.idfVetCase = ocr.idfVetCase
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT ocr.OutBreakCaseReportUID,
               1,
               1,
               1,
               1,
               1
        FROM dbo.OutbreakCaseReport ocr
            INNER JOIN dbo.tlbOutbreak o 
                ON o.idfOutbreak = ocr.idfOutbreak 
                   AND o.intRowStatus = 0
            INNER JOIN dbo.tlbVetCase v
                ON v.idfVetCase = ocr.idfVetCase
                   AND v.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = v.idfFarm
            LEFT JOIN dbo.tlbHuman h
                ON h.idfHuman = f.idfHuman
            LEFT JOIN dbo.HumanActualAddlInfo haai
                ON haai.HumanActualAddlInfoUID = h.idfHumanActual
            LEFT JOIN dbo.tlbGeoLocation gl
                ON gl.idfGeoLocation = f.idfFarmAddress
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = gl.idfsLocation
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfVetCase = v.idfVetCase
                   AND m.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND ocr.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID
              AND (
                      f.idfFarmActual = @FarmMasterID
                      OR @FarmMasterID IS NULL
                  )
              AND (
                      ocr.OutBreakCaseReportUID = @CaseKey
                      OR @CaseKey IS NULL
                  )
              AND (
                      ocr.idfOutbreak = @SessionKey
                      OR @SessionKey IS NULL
                  )
              AND (
                      g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                      OR @AdministrativeLevelID IS NULL
                  )
              AND (
                      v.idfsFinalDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      v.idfsCaseClassification = @ClassificationTypeID
                      OR @ClassificationTypeID IS NULL
                  )
              AND (
                      v.idfsCaseProgressStatus = @ReportStatusTypeID
                      OR @ReportStatusTypeID IS NULL
                  )
              AND (
                      (CAST(v.datEnteredDate AS DATE)
              BETWEEN @DateEnteredFrom AND @DateEnteredTo
                      )
                      OR (
                             @DateEnteredFrom IS NULL
                             OR @DateEnteredTo IS NULL
                         )
                  )
              AND (
                      v.idfsCaseReportType = @ReportTypeID
                      OR @ReportTypeID IS NULL
                  )
              AND (
                      v.idfsCaseType = @SpeciesTypeID
                      OR @SpeciesTypeID IS NULL
                  )
              AND (
                      (CAST(v.datFinalDiagnosisDate AS DATE)
              BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                      )
                      OR (
                             @DiagnosisDateFrom IS NULL
                             OR @DiagnosisDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(v.datInvestigationDate AS DATE)
              BETWEEN @InvestigationDateFrom AND @InvestigationDateTo
                      )
                      OR (
                             @InvestigationDateFrom IS NULL
                             OR @InvestigationDateTo IS NULL
                         )
                  )
              AND (
                      (
                          (f.intAvianTotalAnimalQty
              BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                          )
                          OR (f.intLivestockTotalAnimalQty
              BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                             )
                      )
                      OR (
                             @TotalAnimalQuantityFrom IS NULL
                             OR @TotalAnimalQuantityTo IS NULL
                         )
                  )
              AND (
                      v.idfsSite = @DataEntrySiteID
                      OR @DataEntrySiteID IS NULL
                  )
              AND (
                      ocr.strOutbreakCaseID LIKE '%' + TRIM(@CaseID) + '%'
                      OR @CaseID IS NULL
                  )
              AND (
                      v.LegacyCaseID LIKE '%' + TRIM(@LegacyCaseID) + '%'
                      OR @LegacyCaseID IS NULL
                  )
              AND (
                      haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
                      OR @PersonID IS NULL
                  )
              AND (
                      m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                      OR @LocalOrFieldSampleID IS NULL
                  )
              AND (
                      o.strOutbreakID LIKE '%' + TRIM(@SessionID) + '%'
                      OR @SessionID IS NULL
                  )
        GROUP BY ocr.OutBreakCaseReportUID;

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT ocr.OutBreakCaseReportUID
                        FROM dbo.OutbreakCaseReport ocr
                            INNER JOIN dbo.tlbVetCase v
                                ON v.idfVetCase = ocr.idfVetCase
                                   AND v.intRowStatus = 0
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE ocr.intRowStatus = 0
                              AND oa.intPermission = 1 -- Deny permission
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND oa.idfActor = @UserEmployeeID
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
                INNER JOIN dbo.OutbreakCaseReport ocr
                    ON ocr.OutBreakCaseReportUID = res.ID
                INNER JOIN dbo.tlbVetCase v
                    ON v.idfVetCase = ocr.idfVetCase
                INNER JOIN dbo.tlbFarm f
                    ON f.idfFarm = v.idfFarm
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = f.idfFarmAddress
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = g.idfsLocation
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                    ON disease.idfsReference = v.idfsFinalDiagnosis
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) caseClassification
                    ON caseClassification.idfsReference = v.idfsCaseClassification
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus
                    ON reportStatus.idfsReference = v.idfsCaseProgressStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000144) reportType
                    ON reportType.idfsReference = v.idfsCaseReportType
            ORDER BY CASE
                         WHEN @SortColumn = 'CaseID'
                              AND @SortOrder = 'ASC' THEN
                             ocr.strOutbreakCaseID
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'CaseID'
                              AND @SortOrder = 'DESC' THEN
                             ocr.strOutbreakCaseID
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'EnteredDate'
                              AND @SortOrder = 'ASC' THEN
                             v.datEnteredDate
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'EnteredDate'
                              AND @SortOrder = 'DESC' THEN
                             v.datEnteredDate
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
                         WHEN @SortColumn = 'FarmName'
                              AND @SortOrder = 'ASC' THEN
                             f.strNationalName
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'FarmName'
                              AND @SortOrder = 'DESC' THEN
                             f.strNationalName
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'FarmAddress'
                              AND @SortOrder = 'ASC' THEN
                     (lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name)
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'FarmAddress'
                              AND @SortOrder = 'DESC' THEN
                     (lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name)
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'ClassificationTypeName'
                              AND @SortOrder = 'ASC' THEN
                             caseClassification.name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'ClassificationTypeName'
                              AND @SortOrder = 'DESC' THEN
                             caseClassification.name
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
                         WHEN @SortColumn = 'ReportTypeName'
                              AND @SortOrder = 'ASC' THEN
                             reportType.name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'ReportTypeName'
                              AND @SortOrder = 'DESC' THEN
                             reportType.name
                     END DESC OFFSET @PageSize * (@PageNumber - 1) ROWS FETCH NEXT @PageSize ROWS ONLY
           )
        SELECT res.ID AS CaseKey,
               ocr.strOutbreakCaseID AS CaseID,
               ocr.idfOutbreak AS OutbreakKey,
               o.strOutbreakID AS OutbreakID,
               v.idfVetCase AS DiseaseReportKey,
               v.idfsCaseType AS ReportCategoryTypeID,
               reportStatus.name AS ReportStatusTypeName,
               reportType.name AS ReportTypeName,
               caseType.name AS SpeciesTypeName,
               caseClassification.name AS ClassificationTypeName,
               v.datReportDate AS ReportDate,
               v.datInvestigationDate AS InvestigationDate,
               v.idfsFinalDiagnosis AS DiseaseID,
               finalDiagnosis.name AS DiseaseName,
               v.datFinalDiagnosisDate AS FinalDiagnosisDate,
               ISNULL(personInvestigatedBy.strFamilyName, N'') + ISNULL(', ' + personInvestigatedBy.strFirstName, '')
               + ISNULL(' ' + personInvestigatedBy.strSecondName, '') AS InvestigatedByPersonName,
               ISNULL(personReportedBy.strFamilyName, N'') + ISNULL(', ' + personReportedBy.strFirstName, '')
               + ISNULL(' ' + personReportedBy.strSecondName, '') AS ReportedByPersonName,
               (CASE
                    WHEN v.idfsCaseType = 10012003 THEN
                        ISNULL(f.intLivestockSickAnimalQty, '0')
                    ELSE
                        ISNULL(f.intAvianSickAnimalQty, '0')
                END
               ) AS TotalSickAnimalQuantity,
               (CASE
                    WHEN v.idfsCaseType = 10012003 THEN
                        ISNULL(f.intLivestockTotalAnimalQty, '0')
                    ELSE
                        ISNULL(f.intAvianTotalAnimalQty, '0')
                END
               ) AS TotalAnimalQuantity,
               (CASE
                    WHEN v.idfsCaseType = 10012003 THEN
                        ISNULL(f.intLivestockDeadAnimalQty, '0')
                    ELSE
                        ISNULL(f.intAvianDeadAnimalQty, '0')
                END
               ) AS TotalDeadAnimalQuantity,
               f.strFarmCode AS FarmID,
               f.idfFarmActual AS FarmMasterKey,
               f.idfFarm AS FarmKey,
               f.strNationalName AS FarmName,
               f.idfHuman AS FarmOwnerKey,
               haai.EIDSSPersonID AS FarmOwnerID,
               ISNULL(h.strLastName, N'') + ISNULL(', ' + h.strFirstName, '') + ISNULL(' ' + h.strSecondName, '') AS FarmOwnerName,
               (lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name) AS FarmAddress,
               v.datEnteredDate AS EnteredDate,
               ISNULL(personEnteredBy.strFamilyName, N'') + ISNULL(', ' + personEnteredBy.strFirstName, '')
               + ISNULL(' ' + personEnteredBy.strSecondName, '') AS EnteredByPersonName,
               v.idfsSite AS SiteKey,
               res.ReadPermissionIndicator,
               res.AccessToPersonalDataPermissionIndicator,
               res.AccessToGenderAndAgeDataPermissionIndicator,
               res.WritePermissionIndicator,
               res.DeletePermissionIndicator,
               c AS TotalRowCount,
               (
                   SELECT COUNT(*)
                   FROM dbo.tlbVetCase v
                       INNER JOIN dbo.tlbFarm f
                           ON f.idfFarm = v.idfFarm
                              AND f.intRowStatus = 0
                   WHERE v.intRowStatus = 0
                         AND (
                                 (v.idfsCaseType = @SpeciesTypeID)
                                 OR @SpeciesTypeID IS NULL
                             )
               ) AS TotalCount,
               TotalPages = (c / @PageSize) + IIF(c % @PageSize > 0, 1, 0),
               CurrentPage = @PageNumber
        FROM @FinalResults res
            INNER JOIN paging
                ON paging.ID = res.ID
            INNER JOIN dbo.OutbreakCaseReport ocr
                ON ocr.OutBreakCaseReportUID = paging.ID
            INNER JOIN dbo.tlbVetCase v
                ON v.idfVetCase = ocr.idfVetCase
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = v.idfFarm
            LEFT JOIN dbo.tlbHuman h
                ON h.idfHuman = f.idfHuman
            LEFT JOIN dbo.HumanActualAddlInfo haai
                ON haai.HumanActualAddlInfoUID = h.idfHumanActual
            LEFT JOIN dbo.tlbPerson personInvestigatedBy
                ON personInvestigatedBy.idfPerson = v.idfPersonInvestigatedBy
            LEFT JOIN dbo.tlbPerson personEnteredBy
                ON personEnteredBy.idfPerson = v.idfPersonEnteredBy
            LEFT JOIN dbo.tlbPerson personReportedBy
                ON personReportedBy.idfPerson = v.idfPersonReportedBy
            LEFT JOIN dbo.tlbGeoLocation gl
                ON gl.idfGeoLocation = f.idfFarmAddress
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = gl.idfsLocation
            LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                ON lh.idfsLocation = g.idfsLocation
            LEFT JOIN dbo.tlbOutbreak o
                ON o.idfOutbreak = v.idfOutbreak
                   AND o.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) finalDiagnosis
                ON finalDiagnosis.idfsReference = v.idfsFinalDiagnosis
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) caseClassification
                ON caseClassification.idfsReference = v.idfsCaseClassification
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus
                ON reportStatus.idfsReference = v.idfsCaseProgressStatus
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000144) reportType
                ON reportType.idfsReference = v.idfsCaseReportType
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000012) caseType
                ON caseType.idfsReference = v.idfsCaseType;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;