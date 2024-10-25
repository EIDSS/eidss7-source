--*************************************************************************************************
-- Name: USP_GBL_LKUP_DISEASE_GETList
--
-- Description: Returns a list of diseases filtered by a user's filtration permissions as defined 
-- per use case SAUC62.
--          
-- Author: Stephen Long
--
-- Revision History:
-- Name              Date       Change Detail
-- ----------------- ---------- ------------------------------------------------------------------
-- Stephen Long      09/29/2021 Initial release
-- Mike Kornegay	 11/03/2021 Added bitwise to where for Accessory Codes
-- Stephen Long      01/24/2022 Added ICD10 and OIE code to the query.
-- Mani				 03/10/2022	Added intHACode as return parameter
-- Leo Tracchia	     11/17/2022 Added distinct to remove possible duplicates from return
-- Mike Kornegay	 12/20/2022 Added idfsUsingType as return field.
-- Mike Kornegay     04/27/2023 Rolled back changes that were made incorrectly in commit f021eb276bcbfb3905255d4ed4fd8b23da5dbdae
--                              (set back to 12/20/2022 version that was correct)
--
-- Testing code:
/*
-- Human standard diseases
EXEC USP_GBL_LKUP_DISEASE_GETList 'en-US', 2, 10020001, NULL, 420664190000873
-- Avian aggregate diseases
EXEC USP_GBL_LKUP_DISEASE_GETList 'en-US', 96, null, NULL, 155568340001295
-- Livestock standard diseases wildcard matching advanced search term.
EXEC USP_GBL_LKUP_DISEASE_GETList 'en-US', 32, 10020001, 'Bru', 420664190000873
*/
--*************************************************************************************************
CREATE PROCEDURE [dbo].[USP_GBL_LKUP_DISEASE_GETList]
(
    @LanguageID NVARCHAR(50),
    @AccessoryCode INT = NULL,         -- Human, Avian, Livestock, Vector, etc.
    @UsingType BIGINT = NULL,          -- Aggregate or standard disease types
    @AdvancedSearchTerm NVARCHAR(200), -- String passed to filter disease names. If nothing is passed in, no filter is applied.
    @UserEmployeeID BIGINT
)
AS
BEGIN
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL
    );

    BEGIN TRY
        INSERT INTO @Results
        SELECT d.idfsDiagnosis,
               1,
               1,
               1,
               1,
               1
        FROM dbo.trtDiagnosis d
            INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                ON disease.idfsReference = d.idfsDiagnosis
        WHERE d.intRowStatus = 0
              AND (
                      (disease.intHACode & @AccessoryCode) > 0 --IN (SELECT * FROM dbo.FN_GBL_SplitHACode(@AccessoryCode, 510))
                      OR @AccessoryCode IS NULL
                  )
              AND (
                      d.idfsUsingType = @UsingType
                      OR @UsingType IS NULL
                  )
              AND (
                      disease.name LIKE '%' + @AdvancedSearchTerm + '%'
                      OR @AdvancedSearchTerm IS NULL
                  );

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
                        SELECT d.idfsDiagnosis
                        FROM dbo.trtDiagnosis d
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = d.idfsDiagnosis
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
        SELECT d.idfsDiagnosis,
               1,
               1,
               1,
               1,
               1
        FROM dbo.trtDiagnosis d
            INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                ON disease.idfsReference = d.idfsDiagnosis
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = d.idfsDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND d.intRowStatus = 0
              AND (
                      d.idfsUsingType = @UsingType
                      OR @UsingType IS NULL
                  )
              AND (
                      disease.intHACode = @AccessoryCode
                      OR @AccessoryCode IS NULL
                  )
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup
              AND (
                      disease.name LIKE '%' + @AdvancedSearchTerm + '%'
                      OR @AdvancedSearchTerm IS NULL
                  );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = res.ID
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT d.idfsDiagnosis,
               1,
               1,
               1,
               1,
               1
        FROM dbo.trtDiagnosis d
            INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                ON disease.idfsReference = d.idfsDiagnosis
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = d.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND d.intRowStatus = 0
              AND (
                      d.idfsUsingType = @UsingType
                      OR @UsingType IS NULL
                  )
              AND (
                      disease.intHACode = @AccessoryCode
                      OR @AccessoryCode IS NULL
                  )
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID
              AND (
                      disease.name LIKE '%' + @AdvancedSearchTerm + '%'
                      OR @AdvancedSearchTerm IS NULL
                  );

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT d.idfsDiagnosis
                        FROM dbo.trtDiagnosis d
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = ID
                                   AND oa.intRowStatus = 0
                        WHERE intPermission = 1 -- Deny permission
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND idfActor = @UserEmployeeID
                    );

        SELECT distinct ID AS DiseaseID,
			   disease.intHACode,
               disease.name AS DiseaseName,			   
               diagnosis.strIDC10 AS IDC10,
               diagnosis.strOIECode AS OIECode,
			   disease.intOrder,
			   diagnosis.idfsUsingType AS UsingType 
        FROM @Results
            INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                ON disease.idfsReference = ID
            LEFT JOIN dbo.trtDiagnosis diagnosis
                ON diagnosis.idfsDiagnosis = ID
        ORDER BY disease.intOrder,
                 disease.name;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END

go

-- ================================================================================================
-- Name: USP_HUM_DISEASE_REPORT_GETList
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
-- Mark Wilson      09/01/2022 update to use denormalized locations to work with site filtration.
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Mike Kornegay	10/11/2022 Move order by back to CTE row partition for performance and add 
--                             LanguageID to default filtration rule joins.
-- Stephen Long     11/02/2022 Fixes for 4599 - site filtration returning the wrong results.
-- Stephen Long     11/09/2022 Fix on where criteria when filtration is run; added groupings for 
--                             the user entered parameters from the search criteria page.
-- Ann Xiong		11/29/2022 Updated to return records correctly when filter by only 
--                             DateEnteredFrom or DateEnteredTo.
-- Ann Xiong		11/30/2022 Updated to return records including DateEnteredTo.
-- Stephen Long     01/09/2023 Updated for site filtration queries.
-- Stephen Long     04/21/2023 Changed employee default group logic on disease filtration.
--
-- Testing code:
-- EXEC USP_HUM_DISEASE_REPORT_GETList 'en-US'
-- EXEC USP_HUM_DISEASE_REPORT_GETList 'en-US', @EIDSSReportID = 'H'
-- ================================================================================================
alter PROCEDURE [dbo].[USP_HUM_DISEASE_REPORT_GETList]
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

    DECLARE @firstRec INT,
            @lastRec INT,
            @FiltrationSiteAdministrativeLevelID AS BIGINT,
            @LanguageCode AS BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID);
    SET @firstRec = (@Page - 1) * @PageSize
    SET @lastRec = (@Page * @PageSize + 1);

    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL, INDEX IDX_ID (ID
                                                             ));
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @UserSitePermissions TABLE
    (
        SiteID BIGINT NOT NULL,
        PermissionTypeID BIGINT NOT NULL,
        Permission INT NOT NULL
    );
    DECLARE @UserGroupSitePermissions TABLE
    (
        SiteID BIGINT NOT NULL,
        PermissionTypeID BIGINT NOT NULL,
        Permission INT NOT NULL
    );

    BEGIN TRY
        INSERT INTO @UserGroupSitePermissions
        SELECT oa.idfsOnSite,
               oa.idfsObjectOperation,
               CASE
                   WHEN oa.intPermission = 2 THEN
                       3
                   ELSE
                       2
               END
        FROM dbo.tstObjectAccess oa
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intRowStatus = 0
              AND oa.idfsObjectType = 10060011 -- Site
              AND oa.idfActor = egm.idfEmployeeGroup;

        INSERT INTO @UserSitePermissions
        SELECT oa.idfsOnSite,
               oa.idfsObjectOperation,
               CASE
                   WHEN oa.intPermission = 2 THEN
                       5
                   ELSE
                       4
               END
        FROM dbo.tstObjectAccess oa
        WHERE oa.intRowStatus = 0
              AND oa.idfsObjectType = 10060011 -- Site
              AND oa.idfActor = @UserEmployeeID;

        IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
        END

        -- ========================================================================================
        -- NO CONFIGURABLE FILTRATION RULES APPLIED
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
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = currentAddress.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation exposure
                    ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                LEFT JOIN dbo.gisLocationDenormalized gExposure
                    ON gExposure.idfsLocation = exposure.idfsLocation
                       AND gExposure.idfsLanguage = @LanguageCode
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
                          g.Level1ID = @AdministrativeLevelID
                          OR g.Level2ID = @AdministrativeLevelID
                          OR g.Level3ID = @AdministrativeLevelID
                          OR g.Level4ID = @AdministrativeLevelID
                          OR g.Level5ID = @AdministrativeLevelID
                          OR g.Level6ID = @AdministrativeLevelID
                          OR g.Level7ID = @AdministrativeLevelID
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          hc.datEnteredDate >= @DateEnteredFrom
                          OR @DateEnteredFrom IS NULL
                      )
                  AND (
                          (convert(date, hc.datEnteredDate, 102) <= @DateEnteredTo)
                          OR @DateEnteredTo IS NULL
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
                          g.Level1ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level2ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level3ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level4ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level5ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level6ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level7ID = @LocationOfExposureAdministrativeLevelID
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
                  AND (
                          hc.idfsOutcome = @OutcomeID
                          OR @OutcomeID IS NULL
                      )
            GROUP BY hc.idfHumanCase;
        END
        ELSE
        BEGIN -- Configurable Filtration Rules
            DECLARE @InitialFilteredResults TABLE
            (
                ID BIGINT NOT NULL,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL, INDEX IDX_ID (ID
                                                                     ));

            INSERT INTO @InitialFilteredResults
            SELECT hc.idfHumanCase,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbHumanCase hc
            WHERE hc.intRowStatus = 0
                  AND hc.idfsSite = @UserSiteID;

            INSERT INTO @Results
            SELECT hc.idfHumanCase,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM @InitialFilteredResults res
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = res.ID
                INNER JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                       AND h.intRowStatus = 0
                INNER JOIN dbo.tlbGeoLocation currentAddress
                    ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = currentAddress.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation exposure
                    ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                LEFT JOIN dbo.gisLocationDenormalized gExposure
                    ON gExposure.idfsLocation = exposure.idfsLocation
                       AND gExposure.idfsLanguage = @LanguageCode
            WHERE hc.idfsFinalDiagnosis IS NOT NULL
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
                          g.Level1ID = @AdministrativeLevelID
                          OR g.Level2ID = @AdministrativeLevelID
                          OR g.Level3ID = @AdministrativeLevelID
                          OR g.Level4ID = @AdministrativeLevelID
                          OR g.Level5ID = @AdministrativeLevelID
                          OR g.Level6ID = @AdministrativeLevelID
                          OR g.Level7ID = @AdministrativeLevelID
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          hc.datEnteredDate >= @DateEnteredFrom
                          OR @DateEnteredFrom IS NULL
                      )
                  AND (
                          (convert(date, hc.datEnteredDate, 102) <= @DateEnteredTo)
                          OR @DateEnteredTo IS NULL
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
                          g.Level1ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level2ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level3ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level4ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level5ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level6ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level7ID = @LocationOfExposureAdministrativeLevelID
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
                  AND (
                          hc.idfsOutcome = @OutcomeID
                          OR @OutcomeID IS NULL
                      )
            GROUP BY hc.idfHumanCase;

            DECLARE @FilteredResults TABLE
            (
                ID BIGINT NOT NULL,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL, INDEX IDX_ID (ID
                                                                     ));

            -- =======================================================================================
            -- DEFAULT CONFIGURABLE FILTRATION RULES
            --
            -- Apply active default filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0;
            DECLARE @AdministrativeLevelTypeID INT;
            DECLARE @DefaultAccessRules AS TABLE
            (
                AccessRuleID BIGINT NOT NULL,
                ActiveIndicator INT NOT NULL,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL,
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

                SELECT @FiltrationSiteAdministrativeLevelID = CASE
                                                                  WHEN @AdministrativeLevelTypeID = 1 THEN
                                                                      g.Level1ID
                                                                  WHEN @AdministrativeLevelTypeID = 2 THEN
                                                                      g.Level2ID
                                                                  WHEN @AdministrativeLevelTypeID = 3 THEN
                                                                      g.Level3ID
                                                                  WHEN @AdministrativeLevelTypeID = 4 THEN
                                                                      g.Level4ID
                                                                  WHEN @AdministrativeLevelTypeID = 5 THEN
                                                                      g.Level5ID
                                                                  WHEN @AdministrativeLevelTypeID = 6 THEN
                                                                      g.Level6ID
                                                                  WHEN @AdministrativeLevelTypeID = 7 THEN
                                                                      g.Level7ID
                                                              END
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
                WHERE o.intRowStatus = 0
                      AND o.idfOffice = @UserOrganizationID;

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
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )

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
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )

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
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )
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
            -- CONFIGURABLE FILTRATION RULES
            -- 
            -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
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
            ----
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
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = currentAddress.idfsLocation
                       AND g.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation exposure
                    ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                LEFT JOIN dbo.gisLocationDenormalized gExposure
                    ON gExposure.idfsLocation = exposure.idfsLocation
                       AND gExposure.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
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
                          g.Level1ID = @AdministrativeLevelID
                          OR g.Level2ID = @AdministrativeLevelID
                          OR g.Level3ID = @AdministrativeLevelID
                          OR g.Level4ID = @AdministrativeLevelID
                          OR g.Level5ID = @AdministrativeLevelID
                          OR g.Level6ID = @AdministrativeLevelID
                          OR g.Level7ID = @AdministrativeLevelID
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          hc.datEnteredDate >= @DateEnteredFrom
                          OR @DateEnteredFrom IS NULL
                      )
                  AND (
                          (convert(date, hc.datEnteredDate, 102) <= @DateEnteredTo)
                          OR @DateEnteredTo IS NULL
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
                          g.Level1ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level2ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level3ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level4ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level5ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level6ID = @LocationOfExposureAdministrativeLevelID
                          OR g.Level7ID = @LocationOfExposureAdministrativeLevelID
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
                  AND (
                          hc.idfsOutcome = @OutcomeID
                          OR @OutcomeID IS NULL
                      )
            GROUP BY ID,
                     ReadPermissionIndicator,
                     AccessToPersonalDataPermissionIndicator,
                     AccessToGenderAndAgeDataPermissionIndicator,
                     WritePermissionIndicator,
                     DeletePermissionIndicator;
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
        -- as all records have been pulled above with or without disease filtration rules applied.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE hc.intRowStatus = 0
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = eg.idfEmployeeGroup
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
        WHERE oa.intPermission = 2 -- Allow permission
              AND hc.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup
              AND hc.idfsFinalDiagnosis IS NOT NULL
        GROUP BY hc.idfHumanCase;

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
        WHERE oa.intPermission = 1 -- Deny permission
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
        WHERE oa.intPermission = 2 -- Allow permission
              AND hc.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID
              AND hc.idfsFinalDiagnosis IS NOT NULL
        GROUP BY hc.idfHumanCase;

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                       AND oa.intRowStatus = 0
            WHERE hc.intRowStatus = 0
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = @UserEmployeeID
        );

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = hc.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE hc.intRowStatus = 0
                  AND oa.idfsObjectOperation = 10059003 -- Read permission
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = eg.idfEmployeeGroup
        );

        --
        -- Apply level 1 site filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbHumanCase hc
        WHERE hc.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = hc.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = hc.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbHumanCase hc
        WHERE hc.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = hc.idfsSite
        );

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = hc.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        INSERT INTO @FinalResults
        SELECT ID,
               MAX(res.ReadPermissionIndicator),
               MAX(res.AccessToPersonalDataPermissionIndicator),
               MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
               MAX(res.WritePermissionIndicator),
               MAX(res.DeletePermissionIndicator)
        FROM @Results res
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN dbo.tlbHuman h
                ON h.idfHuman = hc.idfHuman
                   AND h.intRowStatus = 0
            INNER JOIN dbo.tlbHumanActual ha
                ON ha.idfHumanActual = h.idfHumanActual
                   AND ha.intRowStatus = 0
            INNER JOIN dbo.tlbGeoLocation currentAddress
                ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
            LEFT JOIN dbo.gisLocationDenormalized g
                ON g.idfsLocation = currentAddress.idfsLocation
                   AND g.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfHumanCase = hc.idfHumanCase
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation exposure
                ON exposure.idfGeoLocation = hc.idfPointGeoLocation
            LEFT JOIN dbo.gisLocationDenormalized gExposure
                ON gExposure.idfsLocation = exposure.idfsLocation
                   AND gExposure.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
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
                      g.Level1ID = @AdministrativeLevelID
                      OR g.Level2ID = @AdministrativeLevelID
                      OR g.Level3ID = @AdministrativeLevelID
                      OR g.Level4ID = @AdministrativeLevelID
                      OR g.Level5ID = @AdministrativeLevelID
                      OR g.Level6ID = @AdministrativeLevelID
                      OR g.Level7ID = @AdministrativeLevelID
                      OR @AdministrativeLevelID IS NULL
                  )
              AND (
                      hc.datEnteredDate >= @DateEnteredFrom
                      OR @DateEnteredFrom IS NULL
                  )
              AND (
                      (CONVERT(date, hc.datEnteredDate, 102) <= @DateEnteredTo)
                      OR @DateEnteredTo IS NULL
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
                      g.Level1ID = @LocationOfExposureAdministrativeLevelID
                      OR g.Level2ID = @LocationOfExposureAdministrativeLevelID
                      OR g.Level3ID = @LocationOfExposureAdministrativeLevelID
                      OR g.Level4ID = @LocationOfExposureAdministrativeLevelID
                      OR g.Level5ID = @LocationOfExposureAdministrativeLevelID
                      OR g.Level6ID = @LocationOfExposureAdministrativeLevelID
                      OR g.Level7ID = @LocationOfExposureAdministrativeLevelID
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
              AND (
                      hc.idfsOutcome = @OutcomeID
                      OR @OutcomeID IS NULL
                  )
        GROUP BY ID;

        WITH paging
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
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
                                               END DESC
                                     ) AS ROWNUM,
                   res.ID AS ReportKey,
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
                   ISNULL(p.strFamilyName, N'') + ISNULL(', ' + p.strFirstName, N'')
                   + ISNULL(' ' + p.strSecondName, N'') AS EnteredByPersonName,
                   hc.datModificationDate AS ModificationDate,
                   ISNULL(hospitalization.name, hospitalization.strDefault) AS HospitalizationStatus,
                   hc.idfsSite AS SiteID,
                   res.ReadPermissionIndicator AS ReadPermissionIndicator,
                   res.AccessToPersonalDataPermissionIndicator AS AccessToPersonalDataPermissionIndicator,
                   res.AccessToGenderAndAgeDataPermissionIndicator AS AccessToGenderAndAgeDataPermissionIndicator,
                   res.WritePermissionIndicator AS WritePermissionIndicator,
                   res.DeletePermissionIndicator AS DeletePermissionIndicator,
                   COUNT(*) OVER () AS RecordCount,
                   (
                       SELECT COUNT(*) FROM dbo.tlbHumanCase hc WHERE hc.intRowStatus = 0
                   ) AS TotalCount,
                   LH.AdminLevel2Name AS Region,
                   LH.AdminLevel3Name AS Rayon
            FROM @FinalResults res
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
           )
        SELECT ReportKey,
               ReportID,
               LegacyReportID,
               ReportStatusTypeName,
               ReportTypeName,
               TentativeDiagnosisDate,
               FinalDiagnosisDate,
               ClassificationTypeName,
               FinalClassificationTypeName,
               DateOfOnset,
               DiseaseID,
               DiseaseName,
               PersonMasterID,
               PersonKey,
               PersonID,
               PersonalID,
               PersonName,
               PersonLocation,
               EmployerName,
               EnteredDate,
               EnteredByPersonName,
               ModificationDate,
               HospitalizationStatus,
               SiteID,
               CASE
                   WHEN ReadPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN ReadPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, ReadPermissionIndicator)
               END AS ReadPermissionindicator,
               CASE
                   WHEN AccessToPersonalDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToPersonalDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToPersonalDataPermissionIndicator)
               END AS AccessToPersonalDataPermissionIndicator,
               CASE
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToGenderAndAgeDataPermissionIndicator)
               END AS AccessToGenderAndAgeDataPermissionIndicator,
               CASE
                   WHEN WritePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN WritePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, WritePermissionIndicator)
               END AS WritePermissionIndicator,
               CASE
                   WHEN DeletePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN DeletePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, DeletePermissionIndicator)
               END AS DeletePermissionIndicator,
               RecordCount,
               TotalCount,
               TotalPages = (RecordCount / @PageSize) + IIF(RecordCount % @PageSize > 0, 1, 0),
               CurrentPage = @Page,
               Region,
               Rayon
        FROM paging
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END

GO

--*************************************************************
-- Name: [USP_OMM_SESSION_Note_Set]
-- Description: Insert/Update for Outbreak Case
--          
-- Author: Doug Albanese
-- Revision History
--	Name			Date		Change Detail
--	LAMONT MITCHELL	1/25/19		Removed @T temp table, Aliased Return Columns, Added throw to Try Catch
--	Doug Albanese	10/9/2020	Added Auditing information
--  Doug Albanese	04/19/2023	 Converted VARCHAR to NVARCHAR for a number of fields
--
--*************************************************************
ALTER PROCEDURE [dbo].[USP_OMM_SESSION_Note_Set]
(    
	@LangID								NVARCHAR(50), 
	@idfOutbreakNote					BIGINT = -1,
	@idfOutbreak						BIGINT,
	@strNote							NVARCHAR(2000) = NULL,
	@idfPerson							BIGINT,
	@intRowStatus						INT = 0,
	@strMaintenanceFlag					NVARCHAR(20) = NULL,
	@strReservedAttribute				NVARCHAR(MAX) = NULL,
	@UpdatePriorityID					BIGINT = NULL,
	@UpdateRecordTitle					NVARCHAR(200) = NULL,
	@UploadFileName						NVARCHAR(200) = NULL,
	@UploadFileDescription				NVARCHAR(200) = NULL,
	@UploadFileObject					VARBINARY(MAX) = NULL,
	@DeleteAttachment					VARCHAR(1) = '0',
	@User								NVARCHAR(200) = ''
)
AS

BEGIN    

	DECLARE	@returnCode					INT = 0;
	DECLARE @returnMsg					NVARCHAR(MAX) = 'SUCCESS';
	DECLARE @outbreakLocation			BIGINT = NULL

	Declare @SupressSelect table
	( 
		retrunCode int,
		returnMessage varchar(200)
	)
	BEGIN TRY
		
		IF @DeleteAttachment = '1'
			BEGIN
				UPDATE	tlbOutbreakNote
				SET		UploadFileName = NULL,
						UploadFileObject = NULL,
						AuditUpdateDTM = GETDATE(),
						AuditUpdateUser = @User
				WHERE
						idfOutbreakNote=@idfOutbreakNote			
			END
		ELSE
			BEGIN
				IF EXISTS (SELECT * FROM tlbOutbreakNote WHERE idfOutbreakNote = @idfOutbreakNote)
					BEGIN
						UPDATE		tlbOutbreakNote
						SET 
									strNote = @strNote,
									datNoteDate = GETDATE(),
									intRowStatus = @intRowStatus,
									strMaintenanceFlag = @strMaintenanceFlag,
									strReservedAttribute = @strReservedAttribute,
									UpdatePriorityID = @UpdatePriorityID,
									UpdateRecordTitle = @UpdateRecordTitle,
									UploadFileDescription = @UploadFileDescription,
									AuditUpdateDTM = GETDATE(),
									AuditUpdateUser = @User

						WHERE
									idfOutbreakNote=@idfOutbreakNote

						IF @UploadFileName <> ''
							UPDATE	tlbOutbreakNote
							SET		UploadFileName = @UploadFileName,
									UploadFileObject = @UploadFileObject,
									AuditUpdateDTM = GETDATE(),
									AuditUpdateUser = @User
							WHERE
									idfOutbreakNote=@idfOutbreakNote
						

					END
				ELSE
					BEGIN

						INSERT INTO @SupressSelect
						EXEC	dbo.USP_GBL_NEXTKEYID_GET 'tlbOutbreakNote', @idfOutbreakNote OUTPUT;
						INSERT INTO	dbo.tlbOutbreakNote
						(

								idfOutbreakNote,
								idfOutbreak,
								strNote,
								datNoteDate,
								idfPerson,
								intRowStatus,
								strMaintenanceFlag,
								strReservedAttribute,
								UpdatePriorityID,
								UpdateRecordTitle,
								UploadFileName,
								UploadFileDescription,
								UploadFileObject,
								AuditCreateDTM,
								AuditCreateUser
						)
						VALUES
						(

								@idfOutbreakNote,
								@idfOutbreak,
								@strNote,
								GETDATE(),
								@idfPerson,
								@intRowStatus,
								@strMaintenanceFlag,
								@strReservedAttribute,
								@UpdatePriorityID,
								@UpdateRecordTitle,
								@UploadFileName,
								@UploadFileDescription,
								@UploadFileObject,
								GETDATE(),
								@User
						)

					END
							
			END

	END TRY
	BEGIN CATCH
		--IF @@TRANCOUNT = 1 
		--	ROLLBACK;
		
		--SET		@returnCode = ERROR_NUMBER();
		--SET		@returnMsg = 
		--			'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
		--			+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
		--			+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
		--			+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '')
		--			+ ' ErrorLine: ' +  CONVERT(VARCHAR, ISNULL(ERROR_LINE(), ''))
		--			+ ' ErrorMessage: '+ ERROR_MESSAGE();

		--		INSERT INTO @T
		--		SELECT @returnCode as returnCode, @returnMsg as returnMsg, @idfOutbreakNote as idfOutbreakNote
		Throw;
	END CATCH

	SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage', @idfOutbreakNote 'idfOutbreakNote'

END

GO

--=================================================================================================
-- Name: USP_REF_DIAGNOSISREFERENCE_GETList
--
-- Description:	Returns list of diagnosis/disease references
--							
-- Author:  Philip Shaffer
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Philip Shaffer	09/25/2018 Initial Release
-- Ricky Moss		12/12/2018 Removes return codes and reference id variable
-- Ricky Moss		02/01/2019 Added Penside Test, Lab Test, Sample Type, and Syndrome fields
-- Ricky Moss		04/06/2020 Added the search parameter
-- Stephen Long     04/23/2020 Added accessory code parameter and where clause for proper
--                             filtration.
-- Lamont Mitchell	09/30/2020 Added diagnosis  to be a filter in the Or clause
-- Doug Albanese	06/07/2021 Corrected the default sort column to be intOrder
-- Doug Albanese	08/03/2021 Removed unneccesarry ording, and added a CTE expression to cover 
--                             for a second column of sorting on intOrder
-- Mark Wilson		08/26/2021 Updated to do a bitwise compare for haCode
-- Doug Albanese	12/11/2021 Corrected an "Empty" search issue that pulled all HA Codes, instead 
--                             of a particular requested one
-- Stephen Long     01/26/2023 Added disease filtration rules.
-- Leo Tracchia		04/25/2023 Added additional logic for returning only active records
--
-- Test Code:
-- exec USP_REF_DIAGNOSISREFERENCE_GETList 'en-us', NULL, NULL
-- exec USP_REF_DIAGNOSISREFERENCE_GETList 'en-us', 'Hu', NULL
-- exec USP_REF_DIAGNOSISREFERENCE_GETList 'en-us', NULL, 32
--=================================================================================================
ALTER PROCEDURE [dbo].[USP_REF_DIAGNOSISREFERENCE_GETList]
    @LangID NVARCHAR(50),
    @search NVARCHAR(50),
    @AccessoryCode BIGINT = NULL,
    @pageNo INT = 1,
    @pageSize INT = 10,
    @sortColumn NVARCHAR(30) = 'intOrder',
    @sortOrder NVARCHAR(4) = 'ASC',
    @advancedSearch NVARCHAR(100) = NULL,
    @UserEmployeeID BIGINT
AS
BEGIN
    DECLARE @firstRec INT = (@pageNo - 1) * @pagesize,
            @lastRec INT = (@pageNo * @pageSize + 1),
            @returnMsg NVARCHAR(MAX) = 'SUCCESS',
            @returnCode BIGINT = 0;
    DECLARE @T TABLE
    (
        idfsDiagnosis bigint,
        strDefault nvarchar(2000),
        strName nvarchar(2000),
        strIDC10 nvarchar(200),
        strOIECode nvarchar(2000),
        strSampleType nvarchar(4000),
        strSampleTypeNames nvarchar(4000),
        strLabTest nvarchar(4000),
        strLabTestNames nvarchar(4000),
        strPensideTest nvarchar(4000),
        strPensideTestNames nvarchar(4000),
        strHACode nvarchar(4000),
        strHACodeNames nvarchar(4000),
        idfsUsingType bigint,
        strUsingType nvarchar(2000),
        intHACode int,
        intRowStatus int,
        blnZoonotic bit,
        blnSyndrome bit,
        intOrder int
    );
    DECLARE @FilteredResults TABLE
    (
        idfsDiagnosis bigint,
        strDefault nvarchar(2000),
        strName nvarchar(2000),
        strIDC10 nvarchar(200),
        strOIECode nvarchar(2000),
        strSampleType nvarchar(4000),
        strSampleTypeNames nvarchar(4000),
        strLabTest nvarchar(4000),
        strLabTestNames nvarchar(4000),
        strPensideTest nvarchar(4000),
        strPensideTestNames nvarchar(4000),
        strHACode nvarchar(4000),
        strHACodeNames nvarchar(4000),
        idfsUsingType bigint,
        strUsingType nvarchar(2000),
        intHACode int,
        intRowStatus int,
        blnZoonotic bit,
        blnSyndrome bit,
        intOrder int
    );

    IF @search = ''
        SET @search = NULL;

    BEGIN TRY
        IF (@advancedSearch IS NOT NULL)
        BEGIN
            INSERT INTO @T
            SELECT *
            FROM
            (
                SELECT d.idfsDiagnosis,
                       dbr.strDefault,
                       dbr.[name] AS strName,
                       d.strIDC10,
                       d.strOIECode,
                       dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                       dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                       dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                       dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                       dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                       dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                       dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                       dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                       d.idfsUsingType,
                       ut.[name] AS strUsingType,
                       dbr.intHACode,
                       dbr.intRowStatus,
                       blnZoonotic,
                       d.blnSyndrome,
                       dbr.intOrder
                FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                    INNER JOIN dbo.trtDiagnosis d
                        ON d.idfsDiagnosis = dbr.idfsReference
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                        ON d.idfsUsingType = ut.idfsReference
                    OUTER APPLY
                (
                    SELECT TOP 1
                        d_to_dg.idfsDiagnosisGroup,
                        dg.[name] AS strDiagnosesGroupName
                    FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                        INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                            ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                    WHERE d_to_dg.intRowStatus = 0
                          AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
                ) AS diagnosesGroup
                WHERE (
                          dbr.intHACode IS NULL
                          OR dbr.intHACode > 0
                      )
                      AND d.intRowStatus = 0
                      AND dbr.intRowStatus = 0
            ) AS disease
            WHERE CAST(disease.idfsDiagnosis AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR disease.strDefault LIKE '%' + @advancedSearch + '%'
                  OR disease.strName LIKE '%' + @advancedSearch + '%'
                  OR disease.strIDC10 LIKE '%' + @advancedSearch + '%'
                  OR disease.strOIECode LIKE '%' + @advancedSearch + '%'
                  OR disease.strSampleType LIKE '%' + @advancedSearch + '%'
                  OR disease.strSampleTypeNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strLabTest LIKE '%' + @advancedSearch + '%'
                  OR disease.strLabTestNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strPensideTest LIKE '%' + @advancedSearch + '%'
                  OR disease.strPensideTestNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strHACode LIKE '%' + @advancedSearch + '%'
                  OR disease.strHACodeNames LIKE '%' + @advancedSearch + '%'
                  OR CAST(disease.idfsUsingType AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR CAST(disease.intHACode AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR disease.strUsingType LIKE '%' + @advancedSearch + '%'
                  OR disease.idfsDiagnosis LIKE '%' + @advancedSearch + '%';

            -- =======================================================================================
            -- DISEASE FILTRATION RULES
            --
            -- Apply disease filtration rules from use case SAUC62.
            -- =======================================================================================
            -- 
            -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
            -- as all records have been pulled above with or without disease filtration rules applied.
            --
            DELETE FROM @T
            WHERE EXISTS
            (
                SELECT idfsObjectID
                FROM dbo.tstObjectAccess oa
                    INNER JOIN dbo.tlbEmployee e
                        ON e.idfEmployee = @UserEmployeeID
                           AND e.intRowStatus = 0
                    INNER JOIN dbo.tlbEmployeeGroup eg
                        ON eg.idfsSite = e.idfsSite
                           AND eg.intRowStatus = 0
                    INNER JOIN dbo.trtBaseReference br
                        ON br.idfsBaseReference = eg.idfEmployeeGroup
                           AND br.intRowStatus = 0
                           AND br.blnSystem = 1
                WHERE oa.idfsObjectID = idfsDiagnosis
                      AND oa.intRowStatus = 0
                      AND oa.intPermission = 1 -- Deny permission
                      AND oa.idfsObjectType = 10060001 -- Disease
                      AND oa.idfActor = eg.idfEmployeeGroup
            );

            --
            -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
            -- Allows and denies will supersede level 0.
            --
            INSERT INTO @T
            SELECT disease.*
            FROM
            (
                SELECT d.idfsDiagnosis,
                       dbr.strDefault,
                       dbr.[name] AS strName,
                       d.strIDC10,
                       d.strOIECode,
                       dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                       dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                       dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                       dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                       dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                       dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                       dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                       dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                       d.idfsUsingType,
                       ut.[name] AS strUsingType,
                       dbr.intHACode,
                       dbr.intRowStatus,
                       blnZoonotic,
                       d.blnSyndrome,
                       dbr.intOrder
                FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                    INNER JOIN dbo.trtDiagnosis d
                        ON d.idfsDiagnosis = dbr.idfsReference
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                        ON d.idfsUsingType = ut.idfsReference
                    OUTER APPLY
                (
                    SELECT TOP 1
                        d_to_dg.idfsDiagnosisGroup,
                        dg.[name] AS strDiagnosesGroupName
                    FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                        INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                            ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                    WHERE d_to_dg.intRowStatus = 0
                          AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
                ) AS diagnosesGroup
				WHERE d.intRowStatus = 0
                      AND dbr.intRowStatus = 0
            ) AS disease
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = disease.idfsDiagnosis
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup
                  AND CAST(disease.idfsDiagnosis AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR disease.strDefault LIKE '%' + @advancedSearch + '%'
                  OR disease.strName LIKE '%' + @advancedSearch + '%'
                  OR disease.strIDC10 LIKE '%' + @advancedSearch + '%'
                  OR disease.strOIECode LIKE '%' + @advancedSearch + '%'
                  OR disease.strSampleType LIKE '%' + @advancedSearch + '%'
                  OR disease.strSampleTypeNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strLabTest LIKE '%' + @advancedSearch + '%'
                  OR disease.strLabTestNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strPensideTest LIKE '%' + @advancedSearch + '%'
                  OR disease.strPensideTestNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strHACode LIKE '%' + @advancedSearch + '%'
                  OR disease.strHACodeNames LIKE '%' + @advancedSearch + '%'
                  OR CAST(disease.idfsUsingType AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR CAST(disease.intHACode AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR disease.strUsingType LIKE '%' + @advancedSearch + '%'
                  OR disease.idfsDiagnosis LIKE '%' + @advancedSearch + '%';

            DELETE res
            FROM @T res
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = res.idfsDiagnosis
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup;

            --
            -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
            -- will supersede level 1.
            --
            INSERT INTO @T
            SELECT disease.*
            FROM
            (
                SELECT d.idfsDiagnosis,
                       dbr.strDefault,
                       dbr.[name] AS strName,
                       d.strIDC10,
                       d.strOIECode,
                       dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                       dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                       dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                       dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                       dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                       dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                       dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                       dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                       d.idfsUsingType,
                       ut.[name] AS strUsingType,
                       dbr.intHACode,
                       dbr.intRowStatus,
                       blnZoonotic,
                       d.blnSyndrome,
                       dbr.intOrder
                FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                    INNER JOIN dbo.trtDiagnosis d
                        ON d.idfsDiagnosis = dbr.idfsReference
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                        ON d.idfsUsingType = ut.idfsReference
                    OUTER APPLY
                (
                    SELECT TOP 1
                        d_to_dg.idfsDiagnosisGroup,
                        dg.[name] AS strDiagnosesGroupName
                    FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                        INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                            ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                    WHERE d_to_dg.intRowStatus = 0
                          AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
                ) AS diagnosesGroup
					WHERE d.intRowStatus = 0
                    AND dbr.intRowStatus = 0
            ) AS disease
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = disease.idfsDiagnosis
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = @UserEmployeeID
                  AND CAST(disease.idfsDiagnosis AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR disease.strDefault LIKE '%' + @advancedSearch + '%'
                  OR disease.strName LIKE '%' + @advancedSearch + '%'
                  OR disease.strIDC10 LIKE '%' + @advancedSearch + '%'
                  OR disease.strOIECode LIKE '%' + @advancedSearch + '%'
                  OR disease.strSampleType LIKE '%' + @advancedSearch + '%'
                  OR disease.strSampleTypeNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strLabTest LIKE '%' + @advancedSearch + '%'
                  OR disease.strLabTestNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strPensideTest LIKE '%' + @advancedSearch + '%'
                  OR disease.strPensideTestNames LIKE '%' + @advancedSearch + '%'
                  OR disease.strHACode LIKE '%' + @advancedSearch + '%'
                  OR disease.strHACodeNames LIKE '%' + @advancedSearch + '%'
                  OR CAST(disease.idfsUsingType AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR CAST(disease.intHACode AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%'
                  OR disease.strUsingType LIKE '%' + @advancedSearch + '%'
                  OR disease.idfsDiagnosis LIKE '%' + @advancedSearch + '%';

            DELETE FROM @T
            WHERE EXISTS
            (
                SELECT idfsObjectID
                FROM dbo.tstObjectAccess oa
                WHERE oa.idfsObjectID = idfsDiagnosis
                      AND oa.intRowStatus = 0
                      AND oa.intPermission = 1 -- Deny permission
                      AND oa.idfsObjectType = 10060001 -- Disease
                      AND oa.idfActor = @UserEmployeeID
            );
        END
        ELSE IF (@search IS NOT NULL)
        BEGIN
            INSERT INTO @T
            SELECT *
            FROM
            (
                SELECT d.idfsDiagnosis,
                       dbr.strDefault,
                       dbr.[name] AS strName,
                       d.strIDC10,
                       d.strOIECode,
                       dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                       dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                       dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                       dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                       dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                       dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                       dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                       dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                       d.idfsUsingType,
                       ut.[name] AS strUsingType,
                       dbr.intHACode,
                       dbr.intRowStatus,
                       blnZoonotic,
                       d.blnSyndrome,
                       dbr.intOrder
                FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                    INNER JOIN dbo.trtDiagnosis d
                        ON d.idfsDiagnosis = dbr.idfsReference
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                        ON d.idfsUsingType = ut.idfsReference
                    OUTER APPLY
                (
                    SELECT TOP 1
                        d_to_dg.idfsDiagnosisGroup,
                        dg.[name] AS strDiagnosesGroupName
                    FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                        INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                            ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                    WHERE d_to_dg.intRowStatus = 0
                          AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
                ) AS diagnosesGroup
                WHERE (
                          dbr.intHACode IS NULL
                          OR dbr.intHACode > 0
                      )
                      AND d.intRowStatus = 0
                      AND dbr.intRowStatus = 0
            ) AS disease
            WHERE disease.strDefault LIKE '%' + @search + '%'
                  OR disease.strName LIKE '%' + @search + '%'
                  OR disease.strIDC10 LIKE '%' + @search + '%'
                  OR disease.strOIECode LIKE '%' + @search + '%'
                  OR disease.strHACodeNames LIKE '%' + @search + '%'
                  OR disease.strLabTestNames LIKE '%' + @search + '%'
                  OR disease.strPensideTestNames LIKE '%' + @search + '%'
                  OR disease.strSampleTypeNames LIKE '%' + @search + '%'
                  OR disease.strUsingType LIKE '%' + @search + '%'
                  OR disease.idfsDiagnosis LIKE '%' + @search + '%';

            -- =======================================================================================
            -- DISEASE FILTRATION RULES
            --
            -- Apply disease filtration rules from use case SAUC62.
            -- =======================================================================================
            -- 
            -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
            -- as all records have been pulled above with or without disease filtration rules applied.
            --
            DELETE FROM @T
            WHERE EXISTS
            (
                SELECT idfsObjectID
                FROM dbo.tstObjectAccess oa
                    INNER JOIN dbo.tlbEmployee e
                        ON e.idfEmployee = @UserEmployeeID
                           AND e.intRowStatus = 0
                    INNER JOIN dbo.tlbEmployeeGroup eg
                        ON eg.idfsSite = e.idfsSite
                           AND eg.intRowStatus = 0
                    INNER JOIN dbo.trtBaseReference br
                        ON br.idfsBaseReference = eg.idfEmployeeGroup
                           AND br.intRowStatus = 0
                           AND br.blnSystem = 1
                WHERE oa.idfsObjectID = idfsDiagnosis
                      AND oa.intRowStatus = 0
                      AND oa.intPermission = 1 -- Deny permission
                      AND oa.idfsObjectType = 10060001 -- Disease
                      AND oa.idfActor = eg.idfEmployeeGroup
            );

            --
            -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
            -- Allows and denies will supersede level 0.
            --
            INSERT INTO @T
            SELECT disease.*
            FROM
            (
                SELECT d.idfsDiagnosis,
                       dbr.strDefault,
                       dbr.[name] AS strName,
                       d.strIDC10,
                       d.strOIECode,
                       dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                       dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                       dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                       dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                       dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                       dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                       dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                       dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                       d.idfsUsingType,
                       ut.[name] AS strUsingType,
                       dbr.intHACode,
                       dbr.intRowStatus,
                       blnZoonotic,
                       d.blnSyndrome,
                       dbr.intOrder
                FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                    INNER JOIN dbo.trtDiagnosis d
                        ON d.idfsDiagnosis = dbr.idfsReference
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                        ON d.idfsUsingType = ut.idfsReference
                    OUTER APPLY
                (
                    SELECT TOP 1
                        d_to_dg.idfsDiagnosisGroup,
                        dg.[name] AS strDiagnosesGroupName
                    FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                        INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                            ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                    WHERE d_to_dg.intRowStatus = 0
                          AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
                ) AS diagnosesGroup
				WHERE d.intRowStatus = 0
                      AND dbr.intRowStatus = 0
            ) AS disease
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = disease.idfsDiagnosis
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup
                  AND disease.strDefault LIKE '%' + @search + '%'
                  OR disease.strName LIKE '%' + @search + '%'
                  OR disease.strIDC10 LIKE '%' + @search + '%'
                  OR disease.strOIECode LIKE '%' + @search + '%'
                  OR disease.strHACodeNames LIKE '%' + @search + '%'
                  OR disease.strLabTestNames LIKE '%' + @search + '%'
                  OR disease.strPensideTestNames LIKE '%' + @search + '%'
                  OR disease.strSampleTypeNames LIKE '%' + @search + '%'
                  OR disease.strUsingType LIKE '%' + @search + '%'
                  OR disease.idfsDiagnosis LIKE '%' + @search + '%';

            DELETE res
            FROM @T res
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = res.idfsDiagnosis
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup;

            --
            -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
            -- will supersede level 1.
            --
            INSERT INTO @T
            SELECT disease.*
            FROM
            (
                SELECT d.idfsDiagnosis,
                       dbr.strDefault,
                       dbr.[name] AS strName,
                       d.strIDC10,
                       d.strOIECode,
                       dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                       dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                       dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                       dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                       dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                       dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                       dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                       dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                       d.idfsUsingType,
                       ut.[name] AS strUsingType,
                       dbr.intHACode,
                       dbr.intRowStatus,
                       blnZoonotic,
                       d.blnSyndrome,
                       dbr.intOrder
                FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                    INNER JOIN dbo.trtDiagnosis d
                        ON d.idfsDiagnosis = dbr.idfsReference
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                        ON d.idfsUsingType = ut.idfsReference
                    OUTER APPLY
                (
                    SELECT TOP 1
                        d_to_dg.idfsDiagnosisGroup,
                        dg.[name] AS strDiagnosesGroupName
                    FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                        INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                            ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                    WHERE d_to_dg.intRowStatus = 0
                          AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
                ) AS diagnosesGroup
					WHERE d.intRowStatus = 0
                    AND dbr.intRowStatus = 0
            ) AS disease
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = disease.idfsDiagnosis
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = @UserEmployeeID
                  AND disease.strDefault LIKE '%' + @search + '%'
                  OR disease.strName LIKE '%' + @search + '%'
                  OR disease.strIDC10 LIKE '%' + @search + '%'
                  OR disease.strOIECode LIKE '%' + @search + '%'
                  OR disease.strHACodeNames LIKE '%' + @search + '%'
                  OR disease.strLabTestNames LIKE '%' + @search + '%'
                  OR disease.strPensideTestNames LIKE '%' + @search + '%'
                  OR disease.strSampleTypeNames LIKE '%' + @search + '%'
                  OR disease.strUsingType LIKE '%' + @search + '%'
                  OR disease.idfsDiagnosis LIKE '%' + @search + '%';

            DELETE FROM @T
            WHERE EXISTS
            (
                SELECT idfsObjectID
                FROM dbo.tstObjectAccess oa
                WHERE oa.idfsObjectID = idfsDiagnosis
                      AND oa.intRowStatus = 0
                      AND oa.intPermission = 1 -- Deny permission
                      AND oa.idfsObjectType = 10060001 -- Disease
                      AND oa.idfActor = @UserEmployeeID
            );
        END
        ELSE
        BEGIN
            INSERT INTO @T
            SELECT d.idfsDiagnosis,
                   dbr.strDefault,
                   dbr.[name] AS strName,
                   d.strIDC10,
                   d.strOIECode,
                   dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                   dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                   dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                   dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                   dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                   dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                   dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                   dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                   d.idfsUsingType,
                   ut.[name] AS strUsingType,
                   dbr.intHACode,
                   dbr.intRowStatus,
                   blnZoonotic,
                   d.blnSyndrome,
                   dbr.intOrder
            FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                INNER JOIN dbo.trtDiagnosis d
                    ON d.idfsDiagnosis = dbr.idfsReference
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                    ON d.idfsUsingType = ut.idfsReference
                OUTER APPLY
            (
                SELECT TOP 1
                    d_to_dg.idfsDiagnosisGroup,
                    dg.[name] AS strDiagnosesGroupName
                FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                    INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                        ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                WHERE d_to_dg.intRowStatus = 0
                      AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
            ) AS diagnosesGroup
            WHERE (
                      dbr.intHACode IS NULL
                      OR dbr.intHACode > 0
                  )
                  AND d.intRowStatus = 0
                  AND dbr.intRowStatus = 0
                  AND (
                          ((@AccessoryCode & dbr.intHACode) > 0)
                          OR (@AccessoryCode IS NULL)
                      );

            -- =======================================================================================
            -- DISEASE FILTRATION RULES
            --
            -- Apply disease filtration rules from use case SAUC62.
            -- =======================================================================================
            -- 
            -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
            -- as all records have been pulled above with or without disease filtration rules applied.
            --
            DELETE FROM @T
            WHERE EXISTS
            (
                SELECT idfsObjectID
                FROM dbo.tstObjectAccess oa
                    INNER JOIN dbo.tlbEmployee e
                        ON e.idfEmployee = @UserEmployeeID
                           AND e.intRowStatus = 0
                    INNER JOIN dbo.tlbEmployeeGroup eg
                        ON eg.idfsSite = e.idfsSite
                           AND eg.intRowStatus = 0
                    INNER JOIN dbo.trtBaseReference br
                        ON br.idfsBaseReference = eg.idfEmployeeGroup
                           AND br.intRowStatus = 0
                           AND br.blnSystem = 1
                WHERE oa.idfsObjectID = idfsDiagnosis
                      AND oa.intRowStatus = 0
                      AND oa.intPermission = 1 -- Deny permission
                      AND oa.idfsObjectType = 10060001 -- Disease
                      AND oa.idfActor = eg.idfEmployeeGroup
            );

            --
            -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
            -- Allows and denies will supersede level 0.
            --
            INSERT INTO @T
            SELECT d.idfsDiagnosis,
                   dbr.strDefault,
                   dbr.[name] AS strName,
                   d.strIDC10,
                   d.strOIECode,
                   dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                   dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                   dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                   dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                   dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                   dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                   dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                   dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                   d.idfsUsingType,
                   ut.[name] AS strUsingType,
                   dbr.intHACode,
                   dbr.intRowStatus,
                   blnZoonotic,
                   d.blnSyndrome,
                   dbr.intOrder
            FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                INNER JOIN dbo.trtDiagnosis d
                    ON d.idfsDiagnosis = dbr.idfsReference
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                    ON d.idfsUsingType = ut.idfsReference
                OUTER APPLY
            (
                SELECT TOP 1
                    d_to_dg.idfsDiagnosisGroup,
                    dg.[name] AS strDiagnosesGroupName
                FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                    INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                        ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                WHERE d_to_dg.intRowStatus = 0
                      AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
            ) AS diagnosesGroup
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = dbr.idfsReference
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup
                  AND (
                          dbr.intHACode IS NULL
                          OR dbr.intHACode > 0
                      )
                  AND d.intRowStatus = 0
                  AND dbr.intRowStatus = 0
                  AND (
                          ((@AccessoryCode & dbr.intHACode) > 0)
                          OR (@AccessoryCode IS NULL)
                      );

            DELETE res
            FROM @T res
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = res.idfsDiagnosis
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup;

            --
            -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
            -- will supersede level 1.
            --
            INSERT INTO @T
            SELECT d.idfsDiagnosis,
                   dbr.strDefault,
                   dbr.[name] AS strName,
                   d.strIDC10,
                   d.strOIECode,
                   dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleType,
                   dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strSampleTypeNames,
                   dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTest,
                   dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strLabTestNames,
                   dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTest,
                   dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.idfsDiagnosis) AS strPensideTestNames,
                   dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.intHACode) AS strHACode,
                   dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.intHACode) AS strHACodeNames,
                   d.idfsUsingType,
                   ut.[name] AS strUsingType,
                   dbr.intHACode,
                   dbr.intRowStatus,
                   blnZoonotic,
                   d.blnSyndrome,
                   dbr.intOrder
            FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS dbr
                INNER JOIN dbo.trtDiagnosis d
                    ON d.idfsDiagnosis = dbr.idfsReference
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut
                    ON d.idfsUsingType = ut.idfsReference
                OUTER APPLY
            (
                SELECT TOP 1
                    d_to_dg.idfsDiagnosisGroup,
                    dg.[name] AS strDiagnosesGroupName
                FROM dbo.trtDiagnosisToDiagnosisGroup AS d_to_dg
                    INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) AS dg
                        ON d_to_dg.idfsDiagnosisGroup = dg.idfsReference
                WHERE d_to_dg.intRowStatus = 0
                      AND d_to_dg.idfsDiagnosis = d.idfsDiagnosis
            ) AS diagnosesGroup
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = dbr.idfsReference
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = @UserEmployeeID
                  AND (
                          dbr.intHACode IS NULL
                          OR dbr.intHACode > 0
                      )
                  AND d.intRowStatus = 0
                  AND dbr.intRowStatus = 0
                  AND (
                          ((@AccessoryCode & dbr.intHACode) > 0)
                          OR (@AccessoryCode IS NULL)
                      );

            DELETE FROM @T
            WHERE EXISTS
            (
                SELECT idfsObjectID
                FROM dbo.tstObjectAccess oa
                WHERE oa.idfsObjectID = idfsDiagnosis
                      AND oa.intRowStatus = 0
                      AND oa.intPermission = 1 -- Deny permission
                      AND oa.idfsObjectType = 10060001 -- Disease
                      AND oa.idfActor = @UserEmployeeID
            );
        END;

        INSERT INTO @FilteredResults
        SELECT *
        FROM @T
        GROUP BY idfsDiagnosis,
                 strDefault,
                 strName,
                 strIDC10,
                 strOIECode,
                 strSampleType,
                 strSampleTypeNames,
                 strLabTest,
                 strLabTestNames,
                 strPensideTest,
                 strPensideTestNames,
                 strHACode,
                 strHACodeNames,
                 idfsUsingType,
                 strUsingType,
                 intHACode,
                 intRowStatus,
                 blnZoonotic,
                 blnSyndrome,
                 intOrder;

        WITH CTEResults
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @sortColumn = 'idfsDiagnosis'
                                                        AND @SortOrder = 'asc' THEN
                                                       idfsDiagnosis
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'idfsDiagnosis'
                                                        AND @SortOrder = 'desc' THEN
                                                       idfsDiagnosis
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strdefault'
                                                        AND @SortOrder = 'asc' THEN
                                                       strdefault
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strdefault'
                                                        AND @SortOrder = 'desc' THEN
                                                       strdefault
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strName'
                                                        AND @SortOrder = 'asc' THEN
                                                       strName
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strName'
                                                        AND @SortOrder = 'desc' THEN
                                                       strName
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strIDC10'
                                                        AND @SortOrder = 'asc' THEN
                                                       strIDC10
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strIDC10'
                                                        AND @SortOrder = 'desc' THEN
                                                       strIDC10
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strOIECode'
                                                        AND @SortOrder = 'asc' THEN
                                                       strOIECode
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strOIECode'
                                                        AND @SortOrder = 'desc' THEN
                                                       strOIECode
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strSampleType'
                                                        AND @SortOrder = 'asc' THEN
                                                       strSampleType
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strSampleType'
                                                        AND @SortOrder = 'desc' THEN
                                                       strSampleType
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strSampleTypeNames'
                                                        AND @SortOrder = 'asc' THEN
                                                       strSampleTypeNames
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strSampleTypeNames'
                                                        AND @SortOrder = 'desc' THEN
                                                       strSampleTypeNames
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strLabTest'
                                                        AND @SortOrder = 'asc' THEN
                                                       strLabTest
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strLabTest'
                                                        AND @SortOrder = 'desc' THEN
                                                       strLabTest
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strLabTestNames'
                                                        AND @SortOrder = 'asc' THEN
                                                       strLabTestNames
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strLabTestNames'
                                                        AND @SortOrder = 'desc' THEN
                                                       strLabTestNames
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strPensideTest'
                                                        AND @SortOrder = 'asc' THEN
                                                       strPensideTest
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strPensideTest'
                                                        AND @SortOrder = 'desc' THEN
                                                       strPensideTest
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strPensideTestNames'
                                                        AND @SortOrder = 'asc' THEN
                                                       strPensideTestNames
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strPensideTestNames'
                                                        AND @SortOrder = 'desc' THEN
                                                       strPensideTestNames
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strHACode'
                                                        AND @SortOrder = 'asc' THEN
                                                       strHACode
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strHACode'
                                                        AND @SortOrder = 'desc' THEN
                                                       strHACode
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strHACodeNames'
                                                        AND @SortOrder = 'asc' THEN
                                                       strHACodeNames
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strHACodeNames'
                                                        AND @SortOrder = 'desc' THEN
                                                       strHACodeNames
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'idfsUsingType'
                                                        AND @SortOrder = 'asc' THEN
                                                       idfsUsingType
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'idfsUsingType'
                                                        AND @SortOrder = 'desc' THEN
                                                       idfsUsingType
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'strUsingType'
                                                        AND @SortOrder = 'asc' THEN
                                                       strUsingType
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'strUsingType'
                                                        AND @SortOrder = 'desc' THEN
                                                       strUsingType
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'intHACode'
                                                        AND @SortOrder = 'asc' THEN
                                                       intHACode
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'intHACode'
                                                        AND @SortOrder = 'desc' THEN
                                                       intHACode
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'intRowStatus'
                                                        AND @SortOrder = 'asc' THEN
                                                       intRowStatus
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'intRowStatus'
                                                        AND @SortOrder = 'desc' THEN
                                                       intRowStatus
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'blnZoonotic'
                                                        AND @SortOrder = 'asc' THEN
                                                       blnZoonotic
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'blnZoonotic'
                                                        AND @SortOrder = 'desc' THEN
                                                       blnZoonotic
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'blnSyndrome'
                                                        AND @SortOrder = 'asc' THEN
                                                       blnSyndrome
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'blnSyndrome'
                                                        AND @SortOrder = 'desc' THEN
                                                       blnSyndrome
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'intOrder'
                                                        AND @SortOrder = 'asc' THEN
                                                       intOrder
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'intOrder'
                                                        AND @SortOrder = 'desc' THEN
                                                       intOrder
                                               END DESC,
                                               IIF(@sortColumn = 'intOrder', strName, NULL) ASC
                                     ) AS ROWNUM,
                   COUNT(*) OVER () AS TotalRowCount,
                   idfsDiagnosis,
                   strDefault,
                   strName,
                   strIDC10,
                   strOIECode,
                   strSampleType,
                   strSampleTypeNames,
                   strLabTest,
                   strLabTestNames,
                   strPensideTest,
                   strPensideTestNames,
                   strHACode,
                   strHACodeNames,
                   idfsUsingType,
                   strUsingType,
                   intHACode,
                   intRowStatus,
                   blnZoonotic,
                   blnSyndrome,
                   intOrder
            FROM @FilteredResults
           )
        SELECT TotalRowCount,
               idfsDiagnosis,
               strDefault,
               strName,
               strIDC10,
               strOIECode,
               strSampleType,
               strSampleTypeNames,
               strLabTest,
               strLabTestNames,
               strPensideTest,
               strPensideTestNames,
               strHACode,
               strHACodeNames,
               idfsUsingType,
               strUsingType,
               intHACode,
               intRowStatus,
               blnZoonotic,
               blnSyndrome,
               intOrder,
               TotalPages = (TotalRowCount / @pageSize) + IIF(TotalRowCount % @pageSize > 0, 1, 0),
               CurrentPage = @pageNo
        FROM CTEResults
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
