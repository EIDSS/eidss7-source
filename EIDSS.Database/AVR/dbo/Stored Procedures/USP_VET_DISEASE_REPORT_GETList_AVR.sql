-- ================================================================================================
-- Name: USP_VET_DISEASE_REPORT_GETList
--
-- Description:	Get disease list for the farm edit/enter and other use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     03/25/2018 Initial release.
-- Stephen Long     11/09/2018 Added FarmOwnerID and FarmOwnerName for lab use case 10.
-- Stephen Long     11/25/2018 Updated for the new API.
-- Stephen Long     12/31/2018 Added pagination logic.
-- Stephen Long     04/24/2019 Added advanced search parameters to sync up with use case VUC10.
-- Stephen Long     04/29/2019 Added related to veterinary disease report fields for use case VUC11 
--                             and VUC12.
-- Stephen Long     06/14/2019 Adjusted date from's and to's to be cast as just dates with no time.
-- Stephen Long     06/22/2019 Fix to the farm address logic (building, apartment, house IIF's 
--                             to case statements).
-- Stephen Long     06/25/2019 Add group by for joins with multiple records (such as samples).
-- Stephen Long     07/20/2019 Changed farm inventory counts to ISNULL.
-- Stephen Long     09/03/2019 Add active status check on species list.
-- Ann Xiong		12/05/2019 Added EIDSSPersonID to select list and replaced "ON 
--                             caseType.idfsReference = vc.idfsCaseReportType" with 
--                             "caseType.idfsReference = vc.idfsCaseType".
-- Ann Xiong		12/10/2019 Added a parameter @PersonID NVARCHAR(200) = NULL.
-- Ann Xiong		12/19/2019 Added EIDSSFarmID to select list
-- Stephen Long     01/22/2020 Added site list parameter for site filtration.
-- Stephen Long     01/28/2020 Added non-configurable filtration rules, and legacy report ID.
-- Stephen Long     02/03/2020 Added dbo prefix and changed non-configurable filtration comments.
-- Stephen Long     02/16/2020 Removed group by and pagination applied on final query.
-- Stephen Long     02/26/2020 Added data entry site ID parameter and where clause.
-- Stephen Long     03/04/2020 Corrected where clause on total count for null species type.
-- Stephen Long     03/17/2020 Corrected farm owner ID to use idfHuman instead of idfHumanActual.
-- Stephen Long     03/25/2020 Added if/else for first-level and second-level site types to bypass 
--                             non-configurable rules.
-- Stephen Long     05/18/2020 Added disease filtration rules from use case SAUC62.
-- Stephen Long     06/18/2020 Added where criteria to the query when no site filtration is 
--                             required.
-- Stephen Long     07/07/2020 Added trim to the EIDSS identifier like criteria.
-- Stephen Long     07/08/2020 Replaced common table experssion; was not working well with POCO.
-- Stephen Long     09/24/2020 Update address fields returned (settlement, rayon and region only).
-- Stephen Long     11/18/2020 Added site ID to the query.
-- Stephen Long     11/23/2020 Added configurable site filtration rules.
-- Stephen Long     11/25/2020 Modified for new permission fields on the AccessRule table.
-- Stephen Long     11/28/2020 Add index to table variable primary key.
-- Stephen Long     12/02/2020 Remove primary key from table variable IDs.
-- Stephen Long     12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long     12/23/2020 Added EIDSS session ID parameter and where clause criteria.
-- Stephen Long     12/24/2020 Modified join on disease filtration default role rule.
-- Stephen Long     12/29/2020 Changed function call on reference data for inactive records.
-- Stephen Long     01/04/2021 Added option recompile due to number of optional parameters for 
--                             better execution plan.
-- Stephen Long     01/05/2021 Removed species list sub-query due to performance.  New stored 
--                             procedure added to get species list when user expands disease 
--                             report row in search.
-- Stephen Long     01/06/2021 Added string aggregate function on species list and parameter to 
--                             include.
-- Stephen Long     01/25/2021 Added order by parameter to handle when a user selected a specific 
--                             column to sort by.
-- Stephen Long     01/27/2021 Fix for order by; alias will not work on order by with case.
-- Stephen Long     04/02/2021 Added updated pagination and location hierarchy.
-- Stephen Long     01/11/2022 Added farm owner (idfHuman) ID to the query and updated location 
--                             hierarchy.
-- Mike Kornegay	01/26/2022 Changed RecordCount to TotalRowCount to match BaseModel.
-- Stephen Long     03/29/2022 Added disease ID to the model for laboratory module, and corrected 
--                             site filtration.
-- Ann Xiong		04/25/2022 Added f.idfFarm to select list for Veterinary Disease Report 
--                             Deduplication.
-- Stephen Long     05/10/2022 Added report category type ID to the query.
-- Stephen Long     06/03/2022 Updated to point default access rules to base reference.
-- Mike Kornegay	08/28/2022 Changed FarmAddress to FarmLocation and added FarmLocation.
-- Mike Kornegay    08/31/2022 Corrected sort by adding order by to final query.
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Doug Albanese    01/11/2023 Modifying so that the same SP can bring back Ou
-- Stephen Long     01/13/2023 Updated for site filtration queries.
-- Edgard Torres & Keith   05/09/2023 Modified version of USP_VET_DISEASE_REPORT_GETList to return comma delimeted SiteIDs 
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VET_DISEASE_REPORT_GETList_AVR]
	@LanguageID NVARCHAR(50)
	,@ReportKey BIGINT = NULL
	,@ReportID NVARCHAR(200) = NULL
	,@LegacyReportID NVARCHAR(200) = NULL
	,@SessionKey BIGINT = NULL
	,@FarmMasterID BIGINT = NULL
	,@DiseaseID BIGINT = NULL
	,@ReportStatusTypeID BIGINT = NULL
	,@AdministrativeLevelID BIGINT = NULL
	,@DateEnteredFrom DATE = NULL
	,@DateEnteredTo DATE = NULL
	,@ClassificationTypeID BIGINT = NULL
	,@PersonID NVARCHAR(200) = NULL
	,@ReportTypeID BIGINT = NULL
	,@SpeciesTypeID BIGINT = NULL
	,@OutbreakCasesIndicator BIT = 0
	,@DiagnosisDateFrom DATE = NULL
	,@DiagnosisDateTo DATE = NULL
	,@InvestigationDateFrom DATE = NULL
	,@InvestigationDateTo DATE = NULL
	,@LocalOrFieldSampleID NVARCHAR(200) = NULL
	,@TotalAnimalQuantityFrom INT = NULL
	,@TotalAnimalQuantityTo INT = NULL
	,@SessionID NVARCHAR(200) = NULL
	,@DataEntrySiteID BIGINT = NULL
	,@UserSiteID BIGINT
	,@UserOrganizationID BIGINT
	,@UserEmployeeID BIGINT
	,@ApplySiteFiltrationIndicator BIT = 0
	,@IncludeSpeciesListIndicator BIT = 0
	,@SortColumn NVARCHAR(30) = 'ReportID'
	,@SortOrder NVARCHAR(4) = 'DESC'
	,@PageNumber INT = 1
	,@PageSize INT = 10
	,@OutbreakCaseReportOnly INT = 0
	,@SiteIDs NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @firstRec INT;
    DECLARE @lastRec INT;

    SET @firstRec = (@PageNumber - 1) * @PageSize;
    SET @lastRec = (@PageNumber * @PageSize + 1);

	DECLARE @AdministrativeLevelNode AS HIERARCHYID;
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

		IF @AdministrativeLevelID IS NOT NULL
		BEGIN
			SELECT @AdministrativeLevelNode = node
			FROM dbo.gisLocation
			WHERE idfsLocation = @AdministrativeLevelID;
		END;

        -- ========================================================================================
        -- NO CONFIGURABLE FILTRATION RULES APPLIED
        --
        -- For first and second level sites, do not apply any site filtration rules.
        -- ========================================================================================
		IF @ApplySiteFiltrationIndicator = 0
		BEGIN
			INSERT INTO @Results
			SELECT v.idfVetCase
				,1
				,1
				,1
				,1
				,1
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
			LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
			LEFT JOIN dbo.HumanActualAddlInfo haai ON haai.HumanActualAddlInfoUID = h.idfHumanActual
			LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
			LEFT JOIN dbo.tlbMaterial m ON m.idfVetCase = v.idfVetCase
			LEFT JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = v.idfParentMonitoringSession
			WHERE v.intRowStatus = 0
				AND (
					f.idfFarmActual = @FarmMasterID
					OR @FarmMasterID IS NULL
					)
				AND (
					v.idfVetCase = @ReportKey
					OR @ReportKey IS NULL
					)
				AND (
					v.idfParentMonitoringSession = @SessionKey
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
					(
						CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
							AND @DateEnteredTo
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
					(
						CAST(v.datFinalDiagnosisDate AS DATE) BETWEEN @DiagnosisDateFrom
							AND @DiagnosisDateTo
						)
					OR (
						@DiagnosisDateFrom IS NULL
						OR @DiagnosisDateTo IS NULL
						)
					)
				AND (
					(
						CAST(v.datInvestigationDate AS DATE) BETWEEN @InvestigationDateFrom
							AND @InvestigationDateTo
						)
					OR (
						@InvestigationDateFrom IS NULL
						OR @InvestigationDateTo IS NULL
						)
					)
				AND (
					(
						(
							f.intAvianTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
								AND @TotalAnimalQuantityTo
							)
						OR (
							f.intLivestockTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
								AND @TotalAnimalQuantityTo
							)
						)
					OR (
						@TotalAnimalQuantityFrom IS NULL
						OR @TotalAnimalQuantityTo IS NULL
						)
					)
				AND (
					(
						v.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						v.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
				AND (
					v.idfsSite = @DataEntrySiteID
					OR @DataEntrySiteID IS NULL
					)
				AND (
					v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
					OR @ReportID IS NULL
					)
				AND (
					v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
					OR @LegacyReportID IS NULL
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
					ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
					OR @SessionID IS NULL
					)
			GROUP BY v.idfVetCase;
		END
		ELSE
		BEGIN
		INSERT INTO @Results
			SELECT v.idfVetCase
				,1
				,1
				,1
				,1
				,1
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
			LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
			LEFT JOIN dbo.HumanActualAddlInfo haai ON haai.HumanActualAddlInfoUID = h.idfHumanActual
			LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
			LEFT JOIN dbo.tlbMaterial m ON m.idfVetCase = v.idfVetCase
			LEFT JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = v.idfParentMonitoringSession
			WHERE v.intRowStatus = 0
				AND v.idfsSite = @UserSiteID 
				AND (
					f.idfFarmActual = @FarmMasterID
					OR @FarmMasterID IS NULL
					)
				AND (
					v.idfVetCase = @ReportKey
					OR @ReportKey IS NULL
					)
				AND (
					v.idfParentMonitoringSession = @SessionKey
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
					(
						CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
							AND @DateEnteredTo
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
					(
						CAST(v.datFinalDiagnosisDate AS DATE) BETWEEN @DiagnosisDateFrom
							AND @DiagnosisDateTo
						)
					OR (
						@DiagnosisDateFrom IS NULL
						OR @DiagnosisDateTo IS NULL
						)
					)
				AND (
					(
						CAST(v.datInvestigationDate AS DATE) BETWEEN @InvestigationDateFrom
							AND @InvestigationDateTo
						)
					OR (
						@InvestigationDateFrom IS NULL
						OR @InvestigationDateTo IS NULL
						)
					)
				AND (
					(
						(
							f.intAvianTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
								AND @TotalAnimalQuantityTo
							)
						OR (
							f.intLivestockTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
								AND @TotalAnimalQuantityTo
							)
						)
					OR (
						@TotalAnimalQuantityFrom IS NULL
						OR @TotalAnimalQuantityTo IS NULL
						)
					)
				AND (
					(
						v.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						v.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
				AND (
					v.idfsSite = @DataEntrySiteID
					OR @DataEntrySiteID IS NULL
					)
				AND (
					v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
					OR @ReportID IS NULL
					)
				AND (
					v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
					OR @LegacyReportID IS NULL
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
					ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
					OR @SessionID IS NULL
					)
			GROUP BY v.idfVetCase;

			DECLARE @FilteredResults TABLE (
				ID BIGINT NOT NULL
				,ReadPermissionIndicator INT NOT NULL
				,AccessToPersonalDataPermissionIndicator INT NOT NULL
				,AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL
				,WritePermissionIndicator INT NOT NULL
				,DeletePermissionIndicator INT NOT NULL
				,INDEX IDX_ID(ID)
				);

            -- =======================================================================================
            -- DEFAULT CONFIGURABLE FILTRATION RULES
            --
            -- Apply active default filtration rules for third level sites.
            -- =======================================================================================
			DECLARE @RuleActiveStatus INT = 0;
			DECLARE @AdministrativeLevelTypeID INT;
			DECLARE @OrganizationAdministrativeLevelNode HIERARCHYID;
			DECLARE @DefaultAccessRules TABLE (
				AccessRuleID BIGINT NOT NULL,
				ActiveIndicator INT NOT NULL
				,ReadPermissionIndicator INT NOT NULL
				,AccessToPersonalDataPermissionIndicator INT NOT NULL
				,AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL
				,WritePermissionIndicator INT NOT NULL
				,DeletePermissionIndicator INT NOT NULL
				,AdministrativeLevelTypeID INT NULL
				);

			INSERT INTO @DefaultAccessRules
			SELECT AccessRuleID
			    ,a.intRowStatus
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
				,a.AdministrativeLevelTypeID
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

				SELECT @OrganizationAdministrativeLevelNode = g.node.GetAncestor(g.node.GetLevel() - @AdministrativeLevelTypeID)
				FROM dbo.tlbOffice o
				INNER JOIN dbo.tlbGeoLocationShared l ON l.idfGeoLocationShared = o.idfLocation
				INNER JOIN dbo.gisLocation g ON g.idfsLocation = l.idfsLocation
				WHERE o.idfOffice = @UserOrganizationID
					AND g.node.GetLevel() >= @AdministrativeLevelTypeID;

				-- Administrative level specified in the rule of the site where the report was created.
				INSERT INTO @FilteredResults
				SELECT v.idfVetCase
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator
				FROM dbo.tlbVetCase v
				INNER JOIN dbo.tstSite s ON v.idfsSite = s.idfsSite
				INNER JOIN dbo.tlbOffice o ON o.idfOffice = s.idfOffice
				INNER JOIN dbo.tlbGeoLocationShared l ON l.idfGeoLocationShared = o.idfLocation
				INNER JOIN dbo.gisLocation g ON g.idfsLocation = l.idfsLocation
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537009
				WHERE v.intRowStatus = 0
					AND (
						v.idfsCaseType = @SpeciesTypeID
						OR @SpeciesTypeID IS NULL
						)
					AND (
						(
							CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
								AND @DateEnteredTo
							)
						OR (
							@DateEnteredFrom IS NULL
							OR @DateEnteredTo IS NULL
							)
						)
					AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1;

				-- Administrative level specified in the rule of the farm address.
				INSERT INTO @FilteredResults
				SELECT v.idfVetCase
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator
				FROM dbo.tlbVetCase v
				INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
				INNER JOIN dbo.tlbGeoLocation l ON l.idfGeoLocation = f.idfFarmAddress
				INNER JOIN dbo.gisLocation g ON g.idfsLocation = l.idfsLocation
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537009
				WHERE v.intRowStatus = 0
					AND (
						v.idfsCaseType = @SpeciesTypeID
						OR @SpeciesTypeID IS NULL
						)
					AND (
						(
							CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
								AND @DateEnteredTo
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
				SELECT v.idfVetCase
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator
				FROM dbo.tlbVetCase v
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537010
				WHERE (v.intRowStatus = 0)
					AND (
						v.idfInvestigatedByOffice = @UserOrganizationID
						OR v.idfReportedByOffice = @UserOrganizationID
						);

				-- Sample collected by and sent to organizations
				INSERT INTO @FilteredResults
				SELECT MAX(m.idfVetCase)
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator
				FROM dbo.tlbMaterial m
				INNER JOIN dbo.tlbVetCase v ON v.idfVetCase = m.idfVetCase
					AND v.intRowStatus = 0
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537010
				WHERE m.intRowStatus = 0
					AND (
						m.idfFieldCollectedByOffice = @UserOrganizationID
						OR m.idfSendToOffice = @UserOrganizationID
						)
				GROUP BY m.idfVetCase
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator;

				-- Sample transferred to organizations
				INSERT INTO @FilteredResults
				SELECT MAX(m.idfVetCase)
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator
				FROM dbo.tlbMaterial m
				INNER JOIN dbo.tlbVetCase v ON v.idfVetCase = m.idfVetCase
					AND v.intRowStatus = 0
				INNER JOIN dbo.tlbTransferOutMaterial tom ON m.idfMaterial = tom.idfMaterial
					AND tom.intRowStatus = 0
				INNER JOIN dbo.tlbTransferOUT t ON tom.idfTransferOut = t.idfTransferOut
					AND t.intRowStatus = 0
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537010
				WHERE m.intRowStatus = 0
					AND t.idfSendToOffice = @UserOrganizationID
				GROUP BY m.idfVetCase
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator;
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
				SELECT v.idfVetCase
					,a.ReadPermissionIndicator
					,a.AccessToPersonalDataPermissionIndicator
					,a.AccessToGenderAndAgeDataPermissionIndicator
					,a.WritePermissionIndicator
					,a.DeletePermissionIndicator
				FROM dbo.tlbVetCase v
				INNER JOIN dbo.tlbOutbreak o ON v.idfVetCase = o.idfPrimaryCaseOrSession
					AND o.intRowStatus = 0
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537011
				WHERE v.intRowStatus = 0
					AND o.idfsSite = @UserSiteID
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
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = v.idfsSite
			INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup ON userSiteGroup.idfsSite = @UserSiteID
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			--
			-- Apply at the user's site level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = v.idfsSite
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteID = @UserSiteID
				AND ara.ActorEmployeeGroupID IS NULL
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			-- 
			-- Apply at the user's employee group level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = v.idfsSite
			INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID
				AND egm.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			-- 
			-- Apply at the user's ID level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = v.idfsSite
			INNER JOIN dbo.tstUserTable u ON u.idfPerson = @UserEmployeeID
				AND u.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorUserID = u.idfUserID
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			--
			-- Apply at the user's site group level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tflSiteToSiteGroup sgs ON sgs.idfsSite = @UserSiteID
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteGroupID = sgs.idfSiteGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND sgs.idfsSite = v.idfsSite;

			-- 
			-- Apply at the user's site level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteID = @UserSiteID
				AND ara.ActorEmployeeGroupID IS NULL
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND a.GrantingActorSiteID = v.idfsSite;

			-- 
			-- Apply at the user's employee group level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID
				AND egm.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND a.GrantingActorSiteID = v.idfsSite;

			-- 
			-- Apply at the user's ID level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT v.idfVetCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbVetCase v
			INNER JOIN dbo.tstUserTable u ON u.idfPerson = @UserEmployeeID
				AND u.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorUserID = u.idfUserID
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE v.intRowStatus = 0
				AND a.GrantingActorSiteID = v.idfsSite;

			-- Copy filtered results to results and use search criteria
			INSERT INTO @Results
			SELECT ID
				,ReadPermissionIndicator
				,AccessToPersonalDataPermissionIndicator
				,AccessToGenderAndAgeDataPermissionIndicator
				,WritePermissionIndicator
				,DeletePermissionIndicator
			FROM @FilteredResults
			INNER JOIN dbo.tlbVetCase v ON v.idfVetCase = ID
			INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
			LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
			LEFT JOIN dbo.HumanActualAddlInfo haai ON haai.HumanActualAddlInfoUID = h.idfHumanActual
			LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
			LEFT JOIN dbo.tlbMaterial m ON m.idfVetCase = v.idfVetCase
			LEFT JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = v.idfParentMonitoringSession
			WHERE v.intRowStatus = 0
				AND (
					f.idfFarmActual = @FarmMasterID
					OR @FarmMasterID IS NULL
					)
				AND (
					v.idfVetCase = @ReportKey
					OR @ReportKey IS NULL
					)
				AND (
					v.idfParentMonitoringSession = @SessionKey
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
					(
						CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
							AND @DateEnteredTo
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
					(
						CAST(v.datFinalDiagnosisDate AS DATE) BETWEEN @DiagnosisDateFrom
							AND @DiagnosisDateTo
						)
					OR (
						@DiagnosisDateFrom IS NULL
						OR @DiagnosisDateTo IS NULL
						)
					)
				AND (
					(
						CAST(v.datInvestigationDate AS DATE) BETWEEN @InvestigationDateFrom
							AND @InvestigationDateTo
						)
					OR (
						@InvestigationDateFrom IS NULL
						OR @InvestigationDateTo IS NULL
						)
					)
				AND (
					(
						(
							f.intAvianTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
								AND @TotalAnimalQuantityTo
							)
						OR (
							f.intLivestockTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
								AND @TotalAnimalQuantityTo
							)
						)
					OR (
						@TotalAnimalQuantityFrom IS NULL
						OR @TotalAnimalQuantityTo IS NULL
						)
					)
				AND (
					(
						v.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						v.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
				AND (
					v.idfsSite = @DataEntrySiteID
					OR @DataEntrySiteID IS NULL
					)
				AND (
					v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
					OR @ReportID IS NULL
					)
				AND (
					v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
					OR @LegacyReportID IS NULL
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
					ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
					OR @SessionID IS NULL
					)
			GROUP BY ID
				,ReadPermissionIndicator
				,AccessToPersonalDataPermissionIndicator
				,AccessToGenderAndAgeDataPermissionIndicator
				,WritePermissionIndicator
				,DeletePermissionIndicator;
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
		DELETE
		FROM @Results
		WHERE ID IN (
				SELECT v.idfVetCase
				FROM dbo.tlbVetCase v
				INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = v.idfsFinalDiagnosis
					AND oa.intRowStatus = 0
				WHERE oa.intPermission = 1
					AND oa.idfActor = - 506 -- Default role
				);

		--
		-- Apply level 1 disease filtration rules for an employee's associated user group(s).  
		-- Allows and denies will supersede level 0.
		--
		INSERT INTO @Results
		SELECT v.idfVetCase
			,1
			,1
			,1
			,1
			,1
		FROM dbo.tlbVetCase v
		INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = v.idfsFinalDiagnosis
			AND oa.intRowStatus = 0
		INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID
			AND egm.intRowStatus = 0
		INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
		LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
		LEFT JOIN dbo.HumanActualAddlInfo haai ON haai.HumanActualAddlInfoUID = h.idfHumanActual
		LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
		LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
		LEFT JOIN dbo.tlbMaterial m ON m.idfVetCase = v.idfVetCase
			AND m.intRowStatus = 0
		LEFT JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = v.idfParentMonitoringSession
			AND ms.intRowStatus = 0
		WHERE oa.intPermission = 2 -- Allow permission
			AND v.intRowStatus = 0
			AND oa.idfActor = egm.idfEmployeeGroup
			AND (
				f.idfFarmActual = @FarmMasterID
				OR @FarmMasterID IS NULL
				)
			AND (
				v.idfVetCase = @ReportKey
				OR @ReportKey IS NULL
				)
			AND (
				v.idfParentMonitoringSession = @SessionKey
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
				(
					CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
						AND @DateEnteredTo
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
				(
					CAST(v.datFinalDiagnosisDate AS DATE) BETWEEN @DiagnosisDateFrom
						AND @DiagnosisDateTo
					)
				OR (
					@DiagnosisDateFrom IS NULL
					OR @DiagnosisDateTo IS NULL
					)
				)
			AND (
				(
					CAST(v.datInvestigationDate AS DATE) BETWEEN @InvestigationDateFrom
						AND @InvestigationDateTo
					)
				OR (
					@InvestigationDateFrom IS NULL
					OR @InvestigationDateTo IS NULL
					)
				)
			AND (
				(
					(
						f.intAvianTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
							AND @TotalAnimalQuantityTo
						)
					OR (
						f.intLivestockTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
							AND @TotalAnimalQuantityTo
						)
					)
				OR (
					@TotalAnimalQuantityFrom IS NULL
					OR @TotalAnimalQuantityTo IS NULL
					)
				)
			AND (
				(
					v.idfOutbreak IS NULL
					AND @OutbreakCasesIndicator = 0
					)
				OR (
					v.idfOutbreak IS NOT NULL
					AND @OutbreakCasesIndicator = 1
					)
				OR (@OutbreakCasesIndicator IS NULL)
				)
			AND (
				v.idfsSite = @DataEntrySiteID
				OR @DataEntrySiteID IS NULL
				)
			AND (
				v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
				OR @ReportID IS NULL
				)
			AND (
				v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
				OR @LegacyReportID IS NULL
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
				ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
				OR @SessionID IS NULL
				)
		GROUP BY v.idfVetCase;

		DELETE res
		FROM @Results res
		INNER JOIN dbo.tlbVetCase v ON v.idfVetCase = res.ID
		INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID
			AND egm.intRowStatus = 0
		INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = v.idfsFinalDiagnosis
			AND oa.intRowStatus = 0
		WHERE oa.intPermission = 1
			AND oa.idfsObjectType = 10060001 -- Disease
			AND oa.idfActor = egm.idfEmployeeGroup;

		--
		-- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
		-- will supersede level 1.
		--
		INSERT INTO @Results
		SELECT v.idfVetCase
			,1
			,1
			,1
			,1
			,1
		FROM dbo.tlbVetCase v
		INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = v.idfsFinalDiagnosis
			AND oa.intRowStatus = 0
		INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
		LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
		LEFT JOIN dbo.HumanActualAddlInfo haai ON haai.HumanActualAddlInfoUID = h.idfHumanActual
		LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
		LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
		LEFT JOIN dbo.tlbMaterial m ON m.idfVetCase = v.idfVetCase
			AND m.intRowStatus = 0
		LEFT JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = v.idfParentMonitoringSession
			AND ms.intRowStatus = 0
		WHERE oa.intPermission = 2 -- Allow permission
			AND v.intRowStatus = 0
			AND oa.idfsObjectType = 10060001 -- Disease
			AND oa.idfActor = @UserEmployeeID
			AND (
				f.idfFarmActual = @FarmMasterID
				OR @FarmMasterID IS NULL
				)
			AND (
				v.idfVetCase = @ReportKey
				OR @ReportKey IS NULL
				)
			AND (
				v.idfParentMonitoringSession = @SessionKey
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
				(
					CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
						AND @DateEnteredTo
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
				(
					CAST(v.datFinalDiagnosisDate AS DATE) BETWEEN @DiagnosisDateFrom
						AND @DiagnosisDateTo
					)
				OR (
					@DiagnosisDateFrom IS NULL
					OR @DiagnosisDateTo IS NULL
					)
				)
			AND (
				(
					CAST(v.datInvestigationDate AS DATE) BETWEEN @InvestigationDateFrom
						AND @InvestigationDateTo
					)
				OR (
					@InvestigationDateFrom IS NULL
					OR @InvestigationDateTo IS NULL
					)
				)
			AND (
				(
					(
						f.intAvianTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
							AND @TotalAnimalQuantityTo
						)
					OR (
						f.intLivestockTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
							AND @TotalAnimalQuantityTo
						)
					)
				OR (
					@TotalAnimalQuantityFrom IS NULL
					OR @TotalAnimalQuantityTo IS NULL
					)
				)
			AND (
				(
					v.idfOutbreak IS NULL
					AND @OutbreakCasesIndicator = 0
					)
				OR (
					v.idfOutbreak IS NOT NULL
					AND @OutbreakCasesIndicator = 1
					)
				OR (@OutbreakCasesIndicator IS NULL)
				)
			AND (
				v.idfsSite = @DataEntrySiteID
				OR @DataEntrySiteID IS NULL
				)
			AND (
				v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
				OR @ReportID IS NULL
				)
			AND (
				v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
				OR @LegacyReportID IS NULL
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
				ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
				OR @SessionID IS NULL
				)
		GROUP BY v.idfVetCase;

		DELETE
		FROM @Results
		WHERE ID IN (
				SELECT v.idfVetCase
				FROM dbo.tlbVetCase v
				INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = v.idfsFinalDiagnosis
					AND oa.intRowStatus = 0
				WHERE oa.intPermission = 1 -- Deny permission
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
            SELECT vc.idfVetCase
            FROM dbo.tlbVetCase vc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = vc.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE vc.intRowStatus = 0
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
        SELECT vc.idfVetCase,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbVetCase vc
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = vc.idfsSite
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE vc.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = vc.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVetCase vc
                ON vc.idfVetCase = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = vc.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT vc.idfVetCase,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbVetCase vc
        WHERE vc.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = vc.idfsSite
        );

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT vc.idfVetCase
            FROM dbo.tlbVetCase vc
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = vc.idfsSite
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
		    INNER JOIN dbo.tlbVetCase v 
			    ON v.idfVetCase = res.ID 
				INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
		LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
		LEFT JOIN dbo.HumanActualAddlInfo haai ON haai.HumanActualAddlInfoUID = h.idfHumanActual
		LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
		LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
		LEFT JOIN dbo.tlbMaterial m ON m.idfVetCase = v.idfVetCase
			AND m.intRowStatus = 0
		LEFT JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = v.idfParentMonitoringSession
			AND ms.intRowStatus = 0
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
					AND (
				f.idfFarmActual = @FarmMasterID
				OR @FarmMasterID IS NULL
				)
			AND (
				v.idfVetCase = @ReportKey
				OR @ReportKey IS NULL
				)
			AND (
				v.idfParentMonitoringSession = @SessionKey
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
				(
					CAST(v.datEnteredDate AS DATE) BETWEEN @DateEnteredFrom
						AND @DateEnteredTo
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
				(
					CAST(v.datFinalDiagnosisDate AS DATE) BETWEEN @DiagnosisDateFrom
						AND @DiagnosisDateTo
					)
				OR (
					@DiagnosisDateFrom IS NULL
					OR @DiagnosisDateTo IS NULL
					)
				)
			AND (
				(
					CAST(v.datInvestigationDate AS DATE) BETWEEN @InvestigationDateFrom
						AND @InvestigationDateTo
					)
				OR (
					@InvestigationDateFrom IS NULL
					OR @InvestigationDateTo IS NULL
					)
				)
			AND (
				(
					(
						f.intAvianTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
							AND @TotalAnimalQuantityTo
						)
					OR (
						f.intLivestockTotalAnimalQty BETWEEN @TotalAnimalQuantityFrom
							AND @TotalAnimalQuantityTo
						)
					)
				OR (
					@TotalAnimalQuantityFrom IS NULL
					OR @TotalAnimalQuantityTo IS NULL
					)
				)
			AND (
				(
					v.idfOutbreak IS NULL
					AND @OutbreakCasesIndicator = 0
					)
				OR (
					v.idfOutbreak IS NOT NULL
					AND @OutbreakCasesIndicator = 1
					)
				OR (@OutbreakCasesIndicator IS NULL)
				)
			AND (
				v.idfsSite = @DataEntrySiteID
				OR @DataEntrySiteID IS NULL
				)
			AND (
				v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
				OR @ReportID IS NULL
				)
			AND (
				v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
				OR @LegacyReportID IS NULL
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
				ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
				OR @SessionID IS NULL
				)
        GROUP BY ID;

		WITH paging
		AS (SELECT 
				ID,
				c = COUNT(*) OVER()
			FROM @FinalResults res
			INNER JOIN dbo.tlbVetCase v ON v.idfVetCase = res.ID
			INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
			LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
			LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh ON lh.idfsLocation = g.idfsLocation
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease ON disease.idfsReference = v.idfsFinalDiagnosis
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) caseClassification ON caseClassification.idfsReference = v.idfsCaseClassification
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus ON reportStatus.idfsReference = v.idfsCaseProgressStatus
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000144) reportType ON reportType.idfsReference = v.idfsCaseReportType
			ORDER BY 
				CASE WHEN @SortColumn = 'ReportID' AND @SortOrder = 'ASC' THEN v.strCaseID END ASC,
				CASE WHEN @SortColumn = 'ReportID' AND @SortOrder = 'DESC' THEN v.strCaseID END DESC,
				CASE WHEN @SortColumn = 'EnteredDate' AND @SortOrder = 'ASC' THEN v.datEnteredDate END ASC,
				CASE WHEN @SortColumn = 'EnteredDate' AND @SortOrder = 'DESC' THEN v.datEnteredDate END DESC,
				CASE WHEN @SortColumn = 'DiseaseName' AND @SortOrder = 'ASC' THEN disease.name END ASC,
				CASE WHEN @SortColumn = 'DiseaseName' AND @SortOrder = 'DESC' THEN disease.name END DESC,
				CASE WHEN @SortColumn = 'FarmName' AND @SortOrder = 'ASC' THEN f.strNationalName END ASC,
				CASE WHEN @SortColumn = 'FarmName' AND @SortOrder = 'DESC' THEN f.strNationalName END DESC,
				CASE WHEN @SortColumn = 'FarmAddress' AND @SortOrder = 'ASC' THEN (lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name) END ASC,
				CASE WHEN @SortColumn = 'FarmAddress' AND @SortOrder = 'DESC' THEN (lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name) END DESC,
				CASE WHEN @SortColumn = 'ClassificationTypeName' AND @SortOrder = 'ASC' THEN caseClassification.name END ASC,
				CASE WHEN @SortColumn = 'ClassificationTypeName' AND @SortOrder = 'DESC' THEN caseClassification.name END DESC,
				CASE WHEN @SortColumn = 'ReportStatusTypeName' AND @SortOrder = 'ASC' THEN reportStatus.name END ASC,
				CASE WHEN @SortColumn = 'ReportStatusTypeName' AND @SortOrder = 'DESC' THEN reportStatus.name END DESC,
				CASE WHEN @SortColumn = 'ReportTypeName' AND @SortOrder = 'ASC' THEN reportType.name END ASC,
				CASE WHEN @SortColumn = 'ReportTypeName' AND @SortOrder = 'DESC' THEN reportType.name END DESC
				OFFSET @PageSize * (@PageNumber - 1) ROWS FETCH NEXT @PageSize ROWS ONLY),
		SITEID AS
		(
		SELECT DISTINCT v.idfsSite AS SiteKey
		FROM paging 
			INNER JOIN @FinalResults res ON res.ID = paging.ID
			INNER JOIN dbo.tlbVetCase v ON v.idfVetCase = res.ID
			INNER JOIN dbo.tlbFarm f ON f.idfFarm = v.idfFarm
			LEFT JOIN dbo.tlbHuman h ON h.idfHuman = f.idfHuman
			LEFT JOIN dbo.HumanActualAddlInfo haai ON haai.HumanActualAddlInfoUID = h.idfHumanActual
			LEFT JOIN dbo.tlbPerson personInvestigatedBy ON personInvestigatedBy.idfPerson = v.idfPersonInvestigatedBy
			LEFT JOIN dbo.tlbPerson personEnteredBy ON personEnteredBy.idfPerson = v.idfPersonEnteredBy
			LEFT JOIN dbo.tlbPerson personReportedBy ON personReportedBy.idfPerson = v.idfPersonReportedBy
			LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = f.idfFarmAddress
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
			LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh ON lh.idfsLocation = g.idfsLocation
			LEFT JOIN dbo.tlbOutbreak o ON o.idfOutbreak = v.idfOutbreak
				AND o.intRowStatus = 0
			LEFT JOIN dbo.OutbreakCaseReport ocr ON ocr.idfOutbreak = v.idfOutbreak 
			   AND ocr.idfVetCase IS NOT NULL 	
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) finalDiagnosis ON finalDiagnosis.idfsReference = v.idfsFinalDiagnosis
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) caseClassification ON caseClassification.idfsReference = v.idfsCaseClassification
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus ON reportStatus.idfsReference = v.idfsCaseProgressStatus
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000144) reportType ON reportType.idfsReference = v.idfsCaseReportType
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000012) caseType ON caseType.idfsReference = v.idfsCaseType
		 WHERE 
			(v.strCaseID IS NOT NULL AND @OutbreakCaseReportOnly = 0) OR
			(ocr.strOutbreakCaseID IS NOT NULL AND @OutbreakCaseReportOnly = 1)

		
		--ORDER BY 
		--	CASE WHEN @SortColumn = 'ReportID' AND @SortOrder = 'ASC' THEN v.strCaseID END ASC,
		--	CASE WHEN @SortColumn = 'ReportID' AND @SortOrder = 'DESC' THEN v.strCaseID END DESC,
		--	CASE WHEN @SortColumn = 'EnteredDate' AND @SortOrder = 'ASC' THEN v.datEnteredDate END ASC,
		--	CASE WHEN @SortColumn = 'EnteredDate' AND @SortOrder = 'DESC' THEN v.datEnteredDate END DESC,
		--	CASE WHEN @SortColumn = 'DiseaseName' AND @SortOrder = 'ASC' THEN finalDiagnosis.name END ASC,
		--	CASE WHEN @SortColumn = 'DiseaseName' AND @SortOrder = 'DESC' THEN finalDiagnosis.name END DESC,
		--	CASE WHEN @SortColumn = 'FarmName' AND @SortOrder = 'ASC' THEN f.strNationalName END ASC,
		--	CASE WHEN @SortColumn = 'FarmName' AND @SortOrder = 'DESC' THEN f.strNationalName END DESC,
		--	CASE WHEN @SortColumn = 'FarmAddress' AND @SortOrder = 'ASC' THEN (lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name) END ASC,
		--	CASE WHEN @SortColumn = 'FarmAddress' AND @SortOrder = 'DESC' THEN (lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name) END DESC,
		--	CASE WHEN @SortColumn = 'ClassificationTypeName' AND @SortOrder = 'ASC' THEN caseClassification.name END ASC,
		--	CASE WHEN @SortColumn = 'ClassificationTypeName' AND @SortOrder = 'DESC' THEN caseClassification.name END DESC,
		--	CASE WHEN @SortColumn = 'ReportStatusTypeName' AND @SortOrder = 'ASC' THEN reportStatus.name END ASC,
		--	CASE WHEN @SortColumn = 'ReportStatusTypeName' AND @SortOrder = 'DESC' THEN reportStatus.name END DESC,
		--	CASE WHEN @SortColumn = 'ReportTypeName' AND @SortOrder = 'ASC' THEN reportType.name END ASC,
		--	CASE WHEN @SortColumn = 'ReportTypeName' AND @SortOrder = 'DESC' THEN reportType.name END DESC;
			)

		SELECT @SiteIDs = STRING_AGG(CAST(SiteKey AS NVARCHAR(24)), ',') 
		FROM SITEID
		
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END;
