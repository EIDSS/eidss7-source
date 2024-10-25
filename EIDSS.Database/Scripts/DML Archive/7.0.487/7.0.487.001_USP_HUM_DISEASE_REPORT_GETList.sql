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
-- Stephen Long     05/09/2023 Corrected exposure table alias on the where criteria, and removed
--                             unneeded gisLocation left join in the final query.  Added 
--                             record identifier search indicator logic.
-- Stephen Long     05/18/2023 Fix for item 5584.
-- Stephen Long     07/05/2023 Fix on site permission deletion query.
--
-- Testing code:
-- EXEC USP_HUM_DISEASE_REPORT_GETList 'en-US'
-- EXEC USP_HUM_DISEASE_REPORT_GETList 'en-US', @EIDSSReportID = 'H'
-- ================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_HUM_DISEASE_REPORT_GETList]
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
    @RecordIdentifierSearchIndicator BIT = 0,
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
            @LanguageCodeEn AS BIGINT = dbo.FN_GBL_LanguageCode_GET('en-US');

    SET @firstRec = (@Page - 1) * @PageSize
    SET @lastRec = (@Page * @PageSize + 1);

	DECLARE @DataEntrySiteToSearch bigint
	if @DataEntrySiteID is not null
	begin
		select	@DataEntrySiteToSearch = s.idfsSite
		from	dbo.tstSite s
		where	s.idfOffice = @DataEntrySiteID
				and s.intRowStatus = 0
	end

	DECLARE @DateEnteredToPlusDay DATETIME = DATEADD(DAY, 1, @DateEnteredTo)
	DECLARE @DiagnosisDateToPlusDay DATETIME = DATEADD(DAY, 1, @DiagnosisDateTo)
	DECLARE @DateOfSymptomsOnsetToPlusDay DATETIME = DATEADD(DAY, 1, @DateOfSymptomsOnsetTo)
	DECLARE @NotificationDateToPlusDay DATETIME = DATEADD(DAY, 1, @NotificationDateTo)
	DECLARE @DateOfFinalCaseClassificationToPlusDay DATETIME = DATEADD(DAY, 1, @DateOfFinalCaseClassificationTo)


    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
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
            IF @RecordIdentifierSearchIndicator = 1
            BEGIN
                INSERT INTO @Results
                SELECT idfHumanCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbHumanCase
                WHERE intRowStatus = 0
                      AND idfsFinalDiagnosis IS NOT NULL
                      AND (
                              strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                              OR @ReportID IS NULL
                          )
                      AND (
                              LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                              OR @LegacyReportID IS NULL
                          )
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
                    LEFT JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = currentAddress.idfsLocation
                           AND g.idfsLanguage = @LanguageCodeEn
                    LEFT JOIN dbo.tlbMaterial m
                        ON m.idfHumanCase = hc.idfHumanCase
                           AND m.intRowStatus = 0
                    LEFT JOIN dbo.tlbGeoLocation exposure
                        ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                    LEFT JOIN dbo.gisLocationDenormalized gExposure
                        ON gExposure.idfsLocation = exposure.idfsLocation
                           AND gExposure.idfsLanguage = @LanguageCodeEn
                WHERE hc.intRowStatus = 0
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
                              (		@DiseaseID IS NOT NULL
									AND	(	idfsFinalDiagnosis = @DiseaseID
											OR	(	idfsFinalDiagnosis IS NULL
													AND idfsTentativeDiagnosis = @DiseaseID
												)
										)
							  )
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
                              hc.datEnteredDate < @DateEnteredToPlusDay
                              OR @DateEnteredTo IS NULL
                          )
                      AND (	  (	@DiagnosisDateFrom IS NOT NULL
								AND	(	(	hc.idfsFinalDiagnosis IS NOT NULL
											AND hc.datFinalDiagnosisDate >= @DiagnosisDateFrom
										)
										OR
										(	hc.idfsFinalDiagnosis IS NULL
											AND hc.datTentativeDiagnosisDate >= @DiagnosisDateFrom
										)
									)
							  )
							  OR @DiagnosisDateFrom IS NULL
                          )
                      AND (	  (	@DiagnosisDateTo IS NOT NULL
								AND	(	(	hc.idfsFinalDiagnosis IS NOT NULL
											AND hc.datFinalDiagnosisDate < @DiagnosisDateToPlusDay
										)
										OR
										(	hc.idfsFinalDiagnosis IS NULL
											AND hc.datTentativeDiagnosisDate < @DiagnosisDateToPlusDay
										)
									)
							  )
							  OR @DiagnosisDateTo IS NULL
                          )
						  
                      AND (
                              hc.datNotificationDate >= @NotificationDateFrom
                              OR @NotificationDateFrom IS NULL
                          )
                      AND (
                              hc.datNotificationDate < @NotificationDateToPlusDay
                              OR @NotificationDateTo IS NULL
                          )
						  
                      AND (
                              hc.datOnSetDate >= @DateOfSymptomsOnsetFrom
                              OR @DateOfSymptomsOnsetFrom IS NULL
                          )
                      AND (
                              hc.datOnSetDate < @DateOfSymptomsOnsetToPlusDay
                              OR @DateOfSymptomsOnsetTo IS NULL
                          )
						  
                      AND (
                              hc.datFinalCaseClassificationDate >= @DateOfFinalCaseClassificationFrom
                              OR @DateOfFinalCaseClassificationFrom IS NULL
                          )
                      AND (
                              hc.datFinalCaseClassificationDate <@DateOfFinalCaseClassificationToPlusDay
                              OR @DateOfFinalCaseClassificationTo IS NULL
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
                              gExposure.Level1ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level2ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level3ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level4ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level5ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level6ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level7ID = @LocationOfExposureAdministrativeLevelID
                              OR @LocationOfExposureAdministrativeLevelID IS NULL
                          )

                      AND (
                              @PatientLastName IS NULL
                              OR @PatientLastName = N'' collate Cyrillic_General_CI_AS
							  OR	(	@PatientLastName IS NOT NULL
										AND @PatientLastName <> N'' collate Cyrillic_General_CI_AS
										AND h.strLastName like N'%' + @PatientLastName + N'%' collate Cyrillic_General_CI_AS
									)
                          )

                      AND (
                              @PatientFirstName IS NULL
                              OR @PatientFirstName = N'' collate Cyrillic_General_CI_AS
							  OR	(	@PatientFirstName IS NOT NULL
										AND @PatientFirstName <> N'' collate Cyrillic_General_CI_AS
										AND h.strFirstName like N'%' + @PatientFirstName + N'%' collate Cyrillic_General_CI_AS
									)
                          )

                      AND (
                              @PatientMiddleName IS NULL
                              OR @PatientMiddleName = N'' collate Cyrillic_General_CI_AS
							  OR	(	@PatientMiddleName IS NOT NULL
										AND @PatientMiddleName <> N'' collate Cyrillic_General_CI_AS
										AND h.strSecondName like N'%' + @PatientMiddleName + N'%' collate Cyrillic_General_CI_AS
									)
                          )

                      AND (
                              hc.idfsSite = @DataEntrySiteToSearch
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
                              OR (
                                  @OutbreakCasesIndicator IS NULL 
                                  AND 
                                  (
                                      hc.idfOutbreak IS NULL 
                                      OR (hc.idfOutbreak IS NOT NULL AND hc.strCaseID IS NOT NULL)
                                  )
                              )
                          )
                      AND (
                              hc.strCaseID LIKE N'%' + TRIM(@ReportID) + N'%' collate Cyrillic_General_CI_AS
                              OR @ReportID IS NULL
                          )
                      AND (
                              hc.LegacyCaseID LIKE N'%' + TRIM(@LegacyReportID) + N'%' collate Cyrillic_General_CI_AS
                              OR @LegacyReportID IS NULL
                          )
                      AND (
                              m.strFieldBarcode LIKE N'%' + TRIM(@LocalOrFieldSampleID) + N'%' collate Cyrillic_General_CI_AS
                              OR @LocalOrFieldSampleID IS NULL
                          )
                      AND (
                              hc.idfsOutcome = @OutcomeID
                              OR @OutcomeID IS NULL
                          )
                GROUP BY hc.idfHumanCase;
            END
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
            SELECT idfHumanCase,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbHumanCase
            WHERE intRowStatus = 0
                  AND idfsSite = @UserSiteID;

            IF @RecordIdentifierSearchIndicator = 1
            BEGIN
                INSERT INTO @Results
                SELECT idfHumanCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM @InitialFilteredResults res
                    INNER JOIN dbo.tlbHumanCase hc
                        ON hc.idfHumanCase = res.ID
                WHERE intRowStatus = 0
                      AND (
                              strCaseID LIKE N'%' + TRIM(@ReportID) + N'%' collate Cyrillic_General_CI_AS
                              OR @ReportID IS NULL
                          )
                      AND (
                              LegacyCaseID LIKE N'%' + TRIM(@LegacyReportID) + N'%' collate Cyrillic_General_CI_AS
                              OR @LegacyReportID IS NULL
                          )
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
                           AND g.idfsLanguage = @LanguageCodeEn
                    LEFT JOIN dbo.tlbMaterial m
                        ON m.idfHumanCase = hc.idfHumanCase
                           AND m.intRowStatus = 0
                    LEFT JOIN dbo.tlbGeoLocation exposure
                        ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                    LEFT JOIN dbo.gisLocationDenormalized gExposure
                        ON gExposure.idfsLocation = exposure.idfsLocation
                           AND gExposure.idfsLanguage = @LanguageCodeEn
                WHERE     (
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
                              (		@DiseaseID IS NOT NULL
									AND	(	idfsFinalDiagnosis = @DiseaseID
											OR	(	idfsFinalDiagnosis IS NULL
													AND idfsTentativeDiagnosis = @DiseaseID
												)
										)
							  )
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

                      AND (	  (	@DiagnosisDateFrom IS NOT NULL
								AND	(	(	hc.idfsFinalDiagnosis IS NOT NULL
											AND hc.datFinalDiagnosisDate >= @DiagnosisDateFrom
										)
										OR
										(	hc.idfsFinalDiagnosis IS NULL
											AND hc.datTentativeDiagnosisDate >= @DiagnosisDateFrom
										)
									)
							  )
							  OR @DiagnosisDateFrom IS NULL
                          )
                      AND (	  (	@DiagnosisDateTo IS NOT NULL
								AND	(	(	hc.idfsFinalDiagnosis IS NOT NULL
											AND hc.datFinalDiagnosisDate < @DiagnosisDateToPlusDay
										)
										OR
										(	hc.idfsFinalDiagnosis IS NULL
											AND hc.datTentativeDiagnosisDate < @DiagnosisDateToPlusDay
										)
									)
							  )
							  OR @DiagnosisDateTo IS NULL
                          )
						  
                      AND (
                              hc.datNotificationDate >= @NotificationDateFrom
                              OR @NotificationDateFrom IS NULL
                          )
                      AND (
                              hc.datNotificationDate < @NotificationDateToPlusDay
                              OR @NotificationDateTo IS NULL
                          )
						  
                      AND (
                              hc.datOnSetDate >= @DateOfSymptomsOnsetFrom
                              OR @DateOfSymptomsOnsetFrom IS NULL
                          )
                      AND (
                              hc.datOnSetDate < @DateOfSymptomsOnsetToPlusDay
                              OR @DateOfSymptomsOnsetTo IS NULL
                          )
						  
                      AND (
                              hc.datFinalCaseClassificationDate >= @DateOfFinalCaseClassificationFrom
                              OR @DateOfFinalCaseClassificationFrom IS NULL
                          )
                      AND (
                              hc.datFinalCaseClassificationDate <@DateOfFinalCaseClassificationToPlusDay
                              OR @DateOfFinalCaseClassificationTo IS NULL
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
                              gExposure.Level1ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level2ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level3ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level4ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level5ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level6ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level7ID = @LocationOfExposureAdministrativeLevelID
                              OR @LocationOfExposureAdministrativeLevelID IS NULL
                          )

                      AND (
                              @PatientLastName IS NULL
                              OR @PatientLastName = N'' collate Cyrillic_General_CI_AS
							  OR	(	@PatientLastName IS NOT NULL
										AND @PatientLastName <> N'' collate Cyrillic_General_CI_AS
										AND h.strLastName like N'%' + @PatientLastName + N'%' collate Cyrillic_General_CI_AS
									)
                          )

                      AND (
                              @PatientFirstName IS NULL
                              OR @PatientFirstName = N'' collate Cyrillic_General_CI_AS
							  OR	(	@PatientFirstName IS NOT NULL
										AND @PatientFirstName <> N'' collate Cyrillic_General_CI_AS
										AND h.strFirstName like N'%' + @PatientFirstName + N'%' collate Cyrillic_General_CI_AS
									)
                          )

                      AND (
                              @PatientMiddleName IS NULL
                              OR @PatientMiddleName = N'' collate Cyrillic_General_CI_AS
							  OR	(	@PatientMiddleName IS NOT NULL
										AND @PatientMiddleName <> N'' collate Cyrillic_General_CI_AS
										AND h.strSecondName like N'%' + @PatientMiddleName + N'%' collate Cyrillic_General_CI_AS
									)
                          )

                      AND (
                              hc.idfsSite = @DataEntrySiteToSearch
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
                              hc.strCaseID LIKE N'%' + TRIM(@ReportID) + N'%' collate Cyrillic_General_CI_AS
                              OR @ReportID IS NULL
                          )
                      AND (
                              hc.LegacyCaseID LIKE N'%' + TRIM(@LegacyReportID) + N'%' collate Cyrillic_General_CI_AS
                              OR @LegacyReportID IS NULL
                          )
                      AND (
                              m.strFieldBarcode LIKE N'%' + TRIM(@LocalOrFieldSampleID) + N'%' collate Cyrillic_General_CI_AS
                              OR @LocalOrFieldSampleID IS NULL
                          )
                      AND (
                              hc.idfsOutcome = @OutcomeID
                              OR @OutcomeID IS NULL
                          )
                GROUP BY hc.idfHumanCase;
            END

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
                           AND g.idfsLanguage = @LanguageCodeEn
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
                           AND g.idfsLanguage = @LanguageCodeEn
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
                           AND g.idfsLanguage = @LanguageCodeEn
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
                           AND g.idfsLanguage = @LanguageCodeEn
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
                       AND g.idfsLanguage = @LanguageCodeEn
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation exposure
                    ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                LEFT JOIN dbo.gisLocationDenormalized gExposure
                    ON gExposure.idfsLocation = exposure.idfsLocation
                       AND gExposure.idfsLanguage = @LanguageCodeEn
            WHERE hc.intRowStatus = 0
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
                            (	@DiseaseID IS NOT NULL
								AND	(	idfsFinalDiagnosis = @DiseaseID
										OR	(	idfsFinalDiagnosis IS NULL
												AND idfsTentativeDiagnosis = @DiseaseID
											)
									)
							)
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
                            hc.datEnteredDate < @DateEnteredToPlusDay
                            OR @DateEnteredTo IS NULL
                        )
                    AND (	  (	@DiagnosisDateFrom IS NOT NULL
							AND	(	(	hc.idfsFinalDiagnosis IS NOT NULL
										AND hc.datFinalDiagnosisDate >= @DiagnosisDateFrom
									)
									OR
									(	hc.idfsFinalDiagnosis IS NULL
										AND hc.datTentativeDiagnosisDate >= @DiagnosisDateFrom
									)
								)
							)
							OR @DiagnosisDateFrom IS NULL
                        )
                    AND (	  (	@DiagnosisDateTo IS NOT NULL
							AND	(	(	hc.idfsFinalDiagnosis IS NOT NULL
										AND hc.datFinalDiagnosisDate < @DiagnosisDateToPlusDay
									)
									OR
									(	hc.idfsFinalDiagnosis IS NULL
										AND hc.datTentativeDiagnosisDate < @DiagnosisDateToPlusDay
									)
								)
							)
							OR @DiagnosisDateTo IS NULL
                        )
						  
                    AND (
                            hc.datNotificationDate >= @NotificationDateFrom
                            OR @NotificationDateFrom IS NULL
                        )
                    AND (
                            hc.datNotificationDate < @NotificationDateToPlusDay
                            OR @NotificationDateTo IS NULL
                        )
						  
                    AND (
                            hc.datOnSetDate >= @DateOfSymptomsOnsetFrom
                            OR @DateOfSymptomsOnsetFrom IS NULL
                        )
                    AND (
                            hc.datOnSetDate < @DateOfSymptomsOnsetToPlusDay
                            OR @DateOfSymptomsOnsetTo IS NULL
                        )
						  
                    AND (
                            hc.datFinalCaseClassificationDate >= @DateOfFinalCaseClassificationFrom
                            OR @DateOfFinalCaseClassificationFrom IS NULL
                        )
                    AND (
                            hc.datFinalCaseClassificationDate <@DateOfFinalCaseClassificationToPlusDay
                            OR @DateOfFinalCaseClassificationTo IS NULL
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
                          gExposure.Level1ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level2ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level3ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level4ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level5ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level6ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level7ID = @LocationOfExposureAdministrativeLevelID
                          OR @LocationOfExposureAdministrativeLevelID IS NULL
                      )

                    AND (
                            @PatientLastName IS NULL
                            OR @PatientLastName = N'' collate Cyrillic_General_CI_AS
							OR	(	@PatientLastName IS NOT NULL
									AND @PatientLastName <> N'' collate Cyrillic_General_CI_AS
									AND h.strLastName like N'%' + @PatientLastName + N'%' collate Cyrillic_General_CI_AS
								)
                        )

                    AND (
                            @PatientFirstName IS NULL
                            OR @PatientFirstName = N'' collate Cyrillic_General_CI_AS
							OR	(	@PatientFirstName IS NOT NULL
									AND @PatientFirstName <> N'' collate Cyrillic_General_CI_AS
									AND h.strFirstName like N'%' + @PatientFirstName + N'%' collate Cyrillic_General_CI_AS
								)
                        )

                    AND (
                            @PatientMiddleName IS NULL
                            OR @PatientMiddleName = N'' collate Cyrillic_General_CI_AS
							OR	(	@PatientMiddleName IS NOT NULL
									AND @PatientMiddleName <> N'' collate Cyrillic_General_CI_AS
									AND h.strSecondName like N'%' + @PatientMiddleName + N'%' collate Cyrillic_General_CI_AS
								)
                        )

                  AND (
                          hc.idfsSite = @DataEntrySiteToSearch
                          OR @DataEntrySiteID IS NULL
                      )
                  AND (
                          (
                              hc.idfOutbreak IS NULL
                              AND @OutbreakCasesIndicator = 0
                          )
                          OR (
                                 hc.idfOutbreak IS NOT NULL 
                                 AND hc.strCaseID IS NOT NULL 
                                 AND @OutbreakCasesIndicator = 1
                             )
                          OR (
                              @OutbreakCasesIndicator IS NULL 
                              AND 
                              (
                                  hc.idfOutbreak IS NULL 
                                  OR (hc.idfOutbreak IS NOT NULL AND hc.strCaseID IS NOT NULL)
                              )
                          )
                      )
                  AND (
                          hc.strCaseID LIKE N'%' + TRIM(@ReportID) + N'%' collate Cyrillic_General_CI_AS
                          OR @ReportID IS NULL
                      )
                  AND (
                          hc.LegacyCaseID LIKE N'%' + TRIM(@LegacyReportID) + N'%' collate Cyrillic_General_CI_AS
                          OR @LegacyReportID IS NULL
                      )
                  AND (
                          m.strFieldBarcode LIKE N'%' + TRIM(@LocalOrFieldSampleID) + N'%' collate Cyrillic_General_CI_AS
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
                    ON oa.idfsObjectID = isnull(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
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
                ON oa.idfsObjectID = isnull(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND hc.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup
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
                ON oa.idfsObjectID = isnull(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND hc.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID
        GROUP BY hc.idfHumanCase;

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = isnull(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
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

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN @UserSitePermissions usp
                ON usp.SiteID = hc.idfsSite
        WHERE usp.Permission = 4 -- Deny permission
              AND usp.PermissionTypeID = 10059003; -- Read permission

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
                   AND g.idfsLanguage = @LanguageCodeEn
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfHumanCase = hc.idfHumanCase
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation exposure
                ON exposure.idfGeoLocation = hc.idfPointGeoLocation
            LEFT JOIN dbo.gisLocationDenormalized gExposure
                ON gExposure.idfsLocation = exposure.idfsLocation
                   AND gExposure.idfsLanguage = @LanguageCodeEn
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
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
						(	@DiseaseID IS NOT NULL
							AND	(	idfsFinalDiagnosis = @DiseaseID
									OR	(	idfsFinalDiagnosis IS NULL
											AND idfsTentativeDiagnosis = @DiseaseID
										)
								)
						)
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
						hc.datEnteredDate < @DateEnteredToPlusDay
						OR @DateEnteredTo IS NULL
					)
				AND (	  (	@DiagnosisDateFrom IS NOT NULL
						AND	(	(	hc.idfsFinalDiagnosis IS NOT NULL
									AND hc.datFinalDiagnosisDate >= @DiagnosisDateFrom
								)
								OR
								(	hc.idfsFinalDiagnosis IS NULL
									AND hc.datTentativeDiagnosisDate >= @DiagnosisDateFrom
								)
							)
						)
						OR @DiagnosisDateFrom IS NULL
					)
				AND (	  (	@DiagnosisDateTo IS NOT NULL
						AND	(	(	hc.idfsFinalDiagnosis IS NOT NULL
									AND hc.datFinalDiagnosisDate < @DiagnosisDateToPlusDay
								)
								OR
								(	hc.idfsFinalDiagnosis IS NULL
									AND hc.datTentativeDiagnosisDate < @DiagnosisDateToPlusDay
								)
							)
						)
						OR @DiagnosisDateTo IS NULL
					)
						  
				AND (
						hc.datNotificationDate >= @NotificationDateFrom
						OR @NotificationDateFrom IS NULL
					)
				AND (
						hc.datNotificationDate < @NotificationDateToPlusDay
						OR @NotificationDateTo IS NULL
					)
						  
				AND (
						hc.datOnSetDate >= @DateOfSymptomsOnsetFrom
						OR @DateOfSymptomsOnsetFrom IS NULL
					)
				AND (
						hc.datOnSetDate < @DateOfSymptomsOnsetToPlusDay
						OR @DateOfSymptomsOnsetTo IS NULL
					)
						  
				AND (
						hc.datFinalCaseClassificationDate >= @DateOfFinalCaseClassificationFrom
						OR @DateOfFinalCaseClassificationFrom IS NULL
					)
				AND (
						hc.datFinalCaseClassificationDate <@DateOfFinalCaseClassificationToPlusDay
						OR @DateOfFinalCaseClassificationTo IS NULL
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
                      gExposure.Level1ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level2ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level3ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level4ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level5ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level6ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level7ID = @LocationOfExposureAdministrativeLevelID
                      OR @LocationOfExposureAdministrativeLevelID IS NULL
                  )

                AND (
                        @PatientLastName IS NULL
                        OR @PatientLastName = N'' collate Cyrillic_General_CI_AS
						OR	(	@PatientLastName IS NOT NULL
								AND @PatientLastName <> N'' collate Cyrillic_General_CI_AS
								AND h.strLastName like N'%' + @PatientLastName + N'%' collate Cyrillic_General_CI_AS
							)
                    )

                AND (
                        @PatientFirstName IS NULL
                        OR @PatientFirstName = N'' collate Cyrillic_General_CI_AS
						OR	(	@PatientFirstName IS NOT NULL
								AND @PatientFirstName <> N'' collate Cyrillic_General_CI_AS
								AND h.strFirstName like N'%' + @PatientFirstName + N'%' collate Cyrillic_General_CI_AS
							)
                    )

                AND (
                        @PatientMiddleName IS NULL
                        OR @PatientMiddleName = N'' collate Cyrillic_General_CI_AS
						OR	(	@PatientMiddleName IS NOT NULL
								AND @PatientMiddleName <> N'' collate Cyrillic_General_CI_AS
								AND h.strSecondName like N'%' + @PatientMiddleName + N'%' collate Cyrillic_General_CI_AS
							)
                    )

              AND (
                      hc.idfsSite = @DataEntrySiteToSearch
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
                      hc.strCaseID LIKE N'%' + TRIM(@ReportID) + N'%' collate Cyrillic_General_CI_AS
                      OR @ReportID IS NULL
                  )
              AND (
                      hc.LegacyCaseID LIKE N'%' + TRIM(@LegacyReportID) + N'%' collate Cyrillic_General_CI_AS
                      OR @LegacyReportID IS NULL
                  )
              AND (
                      m.strFieldBarcode LIKE N'%' + TRIM(@LocalOrFieldSampleID) + N'%' collate Cyrillic_General_CI_AS
                      OR @LocalOrFieldSampleID IS NULL
                  )
              AND (
                      hc.idfsOutcome = @OutcomeID
                      OR @OutcomeID IS NULL
                  )
        GROUP BY ID;

		declare @TotalCount INT =
		(	
			SELECT COUNT(hc.idfHuman) FROM dbo.tlbHumanCase hc WHERE hc.intRowStatus = 0
        );

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
                                                       disease.[name]
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       disease.[name]
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
                                                       ISNULL(finalClassification.[name], initialClassification.[name])
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ClassificationTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ISNULL(finalClassification.[name], initialClassification.[name])
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'ReportStatusTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       reportStatus.[name]
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ReportStatusTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       reportStatus.[name]
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
                   CASE WHEN @OutbreakCasesIndicator = 1 AND hc.idfOutbreak IS NOT NULL THEN
                       ocr.strOutbreakCaseID
                   ELSE 
                       hc.strCaseId 
                   END AS ReportID,
                   hc.LegacyCaseID AS LegacyReportID,
                   reportStatus.[name] AS ReportStatusTypeName,
                   reportType.[name] AS ReportTypeName,
                   hc.datTentativeDiagnosisDate AS TentativeDiagnosisDate,
                   CASE 
						WHEN hc.idfsFinalDiagnosis IS NOT NULL 
							THEN hc.datFinalDiagnosisDate 
						ELSE hc.datTentativeDiagnosisDate 
                   END AS FinalDiagnosisDate,
                   ISNULL(finalClassification.[name], initialClassification.[name]) AS ClassificationTypeName,
                   finalClassification.[name] AS FinalClassificationTypeName,
                   hc.datOnSetDate AS DateOfOnset,
                   isnull(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) AS DiseaseID,
                   disease.[name] AS DiseaseName,
                   h.idfHumanActual AS PersonMasterID,
                   hc.idfHuman AS PersonKey,
                   haai.EIDSSPersonID AS PersonID,
                   h.strPersonID AS PersonalID,
                   dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) AS PersonName,
                   ISNULL(LH.AdminLevel1Name, '') + IIF(LH.AdminLevel2Name IS NULL, N'', N', ')
                   + ISNULL(LH.AdminLevel2Name, '') AS PersonLocation,
                   ha.strEmployerName AS EmployerName,
                   hc.datEnteredDate AS EnteredDate,
                   dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName) AS EnteredByPersonName,
                   organization.AbbreviatedName AS EnteredByOrganizationName, 
                   hc.datModificationDate AS ModificationDate,
                   ISNULL(hospitalization.[name], hospitalization.strDefault) AS HospitalizationStatus,
                   hc.idfsSite AS SiteID,
                   res.ReadPermissionIndicator AS ReadPermissionIndicator,
                   res.AccessToPersonalDataPermissionIndicator AS AccessToPersonalDataPermissionIndicator,
                   res.AccessToGenderAndAgeDataPermissionIndicator AS AccessToGenderAndAgeDataPermissionIndicator,
                   res.WritePermissionIndicator AS WritePermissionIndicator,
                   res.DeletePermissionIndicator AS DeletePermissionIndicator,
                   COUNT(*) OVER () AS RecordCount,
                   @TotalCount AS TotalCount,
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
                LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                    ON LH.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.HumanActualAddlInfo haai
                    ON haai.HumanActualAddlInfoUID = ha.idfHumanActual
                       AND haai.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                    ON disease.idfsReference = isnull(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
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
                INNER JOIN dbo.tstSite s 
                    ON s.idfsSite = hc.idfsSite
                LEFT JOIN dbo.FN_GBL_Institution_Min(@LanguageID) organization
                    ON organization.idfOffice = p.idfInstitution
                LEFT JOIN dbo.OutbreakCaseReport ocr 
                    ON ocr.idfHumanCase = hc.idfHumanCase
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
               EnteredByOrganizationName, 
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
              AND RowNum < @lastRec
        OPTION (RECOMPILE);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
