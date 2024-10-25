
-- ================================================================================================
-- Name: USP_HUM_DISEASE_AdvanceSearch_REPORT_GETList
--
-- Description: List Human Disease Report with advance Search Parameters
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
-- Lamont Mitchell  04/14/2019 ADDED ADVANCED SEARCH PARAMETERS , Initially created by copying  USP_HUM_DISEASE__REPORT_GETList
-- Ann Xiong        07/03/2019 Used ISNULL to handle NULL strLastName, strFirstName, strFamilyName, 
--                             and strSecondName
-- Lamont Mitchell 06/08/2020 uncommented Paging
-- Lamont Mitchell 06/12/2020 Changed join in LEFT JOIN tlbGeoLocation L ON L.idfsSite = h.idfsSite 
-- Mandar Kulkarni 06/22/2020 Changed the join to look for person's current address as per the use 
--                            case HUC09
-- Lamont Mitchell 10/13/2020 Changed HospitalizationStatus to idfsYNHospitalization in where clause 
--                            using same parameter @HospitalizationStatusTypeID as input
-- Stephen Long    12/23/2020 Added rules for configurable filtration, and fixed order by.
-- Stephen Long    12/24/2020 Modified join on disease filtration default role rule.
-- Stephen Long    12/29/2020 Changed function call on reference data for inactive records.
-- Mike Kornegay	09/13/2021 Refactor pagination to the new paging standard
--
-- Testing code:
-- EXEC USP_HUM_DISEASE_AdvanceSearch_REPORT_GETList 'en'
-- EXEC USP_HUM_DISEASE_AdvanceSearch_REPORT_GETList 'en', @EIDSSReportID = 'H'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HUM_DISEASE_AdvanceSearch_REPORT_GETList] 
(
	@LanguageID NVARCHAR(50)
	,@HumanDiseaseReportID BIGINT = NULL
	,@LegacyID NVARCHAR(200) = NULL
	,@PatientID BIGINT = NULL
	,@EIDSSPersonID NVARCHAR(200) = NULL
	,@DiseaseID BIGINT = NULL
	,@ReportStatusTypeID BIGINT = NULL
	,@RegionID BIGINT = NULL
	,@RayonID BIGINT = NULL
	,@DateEnteredFrom DATETIME = NULL
	,@DateEnteredTo DATETIME = NULL
	,@ClassificationTypeID BIGINT = NULL
	,@HospitalizationStatusTypeID BIGINT = NULL
	,@EIDSSReportID NVARCHAR(200) = NULL
	,@PatientFirstOrGivenName NVARCHAR(200) = NULL
	,@PatientMiddleName NVARCHAR(200) = NULL
	,@PatientLastOrSurname NVARCHAR(200) = NULL
	,@SentByFacility AS NVARCHAR(200) = NULL
	,@ReceivedByFacility AS NVARCHAR(200) = NULL
	,@DiagnosisDateFrom AS DATETIME = NULL
	,@DiagnosisDateTo AS DATETIME = NULL
	,@LocalSampleID AS NVARCHAR(200) = NULL
	,@DataEntrySite AS BIGINT = NULL
	,@DateOfSymptomsOnset AS DATETIME = NULL
	,@NotificationDate AS DATETIME = NULL
	,@DateOfFinalCaseClassification AS DATETIME = NULL
	,@LocationOfExposureRegion AS BIGINT = NULL
	,@LocationOfExposureRayon AS BIGINT = NULL
	,@SiteList VARCHAR(MAX) = NULL
	,@EmployeeID BIGINT
	,@EmployeeGroupList VARCHAR(MAX) = NULL
	,@SiteGroupID BIGINT = NULL
	,@ApplyNonConfigurableFiltration BIT = 0
	,@ApplyConfigurableFiltration BIT = 0
	,@pageNo INT = 1
	,@pageSize INT = 10
	,@sortColumn NVARCHAR(30) = 'ReportId'
	,@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IDs TABLE (
		ID BIGINT NOT NULL
		,ReadPermissionIndicator BIT NOT NULL
		,AccessToPersonalDataPermissionIndicator BIT NOT NULL
		,AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL
		,WritePermissionIndicator BIT NOT NULL
		,DeletePermissionIndicator BIT NOT NULL
		,INDEX IDX_ID(ID)
		);

		DECLARE @firstRec INT
		DECLARE @lastRec INT
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)

	BEGIN TRY
		-- ========================================================================================
		-- NO NON-CONFIGURABLE SITE FILTRATION RULES APPLIED
		--
		-- For first and second level sites, do not apply any non-configurable site filtration 
		-- rules.
		-- ========================================================================================
		IF @ApplyNonConfigurableFiltration = 0
			AND @ApplyConfigurableFiltration = 0
		BEGIN
			INSERT INTO @IDs
			SELECT 
				hc.idfHumanCase,
				1,
				1,
				1,
				1,
				1

			FROM dbo.tlbHumanCase hc
			INNER JOIN dbo.tlbHuman h ON h.idfHuman = hc.idfHuman AND h.intRowStatus = 0
			INNER JOIN dbo.tlbGeoLocation L ON L.idfGeoLocation = h.idfCurrentResidenceAddress AND L.intRowStatus = 0
			LEFT JOIN dbo.tlbHumanActual AS ha ON h.idfHumanActual = ha.idfHumanActual AND h.intRowStatus = 0 AND ha.intRowStatus = 0
			LEFT JOIN dbo.HumanActualAddlInfo AS humanActAddInfo ON humanActAddInfo.HumanActualAddlInfoUID = ha.idfHumanActual AND humanActAddInfo.intRowStatus = 0
			LEFT JOIN dbo.tlbOffice SentBy ON SentBy.idfOffice = HC.idfSentByOffice AND SentBy.intRowStatus = 0
			LEFT JOIN dbo.tlbOffice ReceivedBy ON ReceivedBy.idfOffice = HC.idfReceivedByOffice AND ReceivedBy.intRowStatus = 0
			LEFT JOIN dbo.tlbGeoLocation expoSure ON expoSure.idfGeoLocation = hc.idfPointGeoLocation AND expoSure.intRowStatus = 0
			WHERE ((hc.strCaseID LIKE '%' + @EIDSSReportID + '%') OR @EIDSSReportID IS NULL)
			AND ((hc.idfHumanCase = @HumanDiseaseReportID) OR (@HumanDiseaseReportID IS NULL))
			AND ((hc.LegacyCaseID = @LegacyID) OR (@LegacyID IS NULL))
			AND ((ha.idfHumanActual = @PatientID) OR (@PatientID IS NULL))
			AND ((h.strPersonId = @EIDSSPersonID) OR (@EIDSSPersonID IS NULL))
			AND ((hc.idfsFinalDiagnosis = @DiseaseID) OR (@DiseaseID IS NULL))
			AND ((hc.idfsCaseProgressStatus = @ReportStatusTypeID) OR (@ReportStatusTypeID IS NULL))
			AND ((hc.idfsFinalCaseStatus = @ClassificationTypeID) OR (@ClassificationTypeID IS NULL))
			AND ((hc.idfsYNHospitalization = @HospitalizationStatusTypeID) OR (@HospitalizationStatusTypeID IS NULL))
			AND ((ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstOrGivenName, '')
												WHEN ''
													THEN ISNULL(h.strFirstName, '')
												ELSE @PatientFirstOrGivenName
												END)
						OR (CHARINDEX(@PatientFirstOrGivenName, ISNULL(h.strFirstName, '')) > 0))
			AND ((ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
												WHEN ''
													THEN ISNULL(h.strSecondName, '')
												ELSE @PatientMiddleName
												END)
						OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0))
			AND ((ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastOrSurname, '')
												WHEN ''
													THEN ISNULL(h.strLastName, '')
												ELSE @PatientLastOrSurname
												END)
						OR (CHARINDEX(@PatientLastOrSurname, ISNULL(h.strLastName, '')) > 0))
			AND (hc.strLocalIdentifier = @LocalSampleID	OR @LocalSampleID IS NULL) 
			AND ((L.idfsRegion = @RegionID) OR (@RegionID IS NULL))
			AND ((L.idfsRayon = @RayonID) OR (@RayonID IS NULL))
			AND ((hc.datEnteredDate >= CASE ISNULL(@DateEnteredFrom, '1/1/2050')
										WHEN '1/1/2050'
											THEN isnull(hc.datEnteredDate, '1/1/2050')
										ELSE @DateEnteredFrom
										END)
						OR (ISNULL(@DateEnteredFrom, '') = ''))
			AND ((hc.datEnteredDate <= CASE ISNULL(@DateEnteredTo, '1/1/1901')
										WHEN '1/1/1901'
											THEN ISNULL(hc.datEnteredDate, '1/1/1901')
										ELSE @DateEnteredTo
										END)
						OR (ISNULL(@DateEnteredTo, '') = ''))
			AND ((ReceivedBy.idfsOfficeName = @ReceivedByFacility) OR (@ReceivedByFacility IS NULL))
			AND ((SentBy.idfsOfficeName = @SentByFacility) OR (@SentByFacility IS NULL))
			AND ((hc.datFinalDiagnosisDate = @DiagnosisDateTo) OR (@DiagnosisDateTo IS NULL))
			AND ((hc.datFirstSoughtCareDate = @DiagnosisDateFrom) OR (@DiagnosisDateFrom IS NULL))
			AND ((hc.idfsSite = @DataEntrySite) OR (@DataEntrySite IS NULL))
			AND ((hc.datOnSetDate = @DateOfSymptomsOnset) OR (@DateOfSymptomsOnset IS NULL))
			AND ((hc.datNotificationDate = @NotificationDate) OR (@NotificationDate IS NULL))
			AND ((hc.datFinalCaseClassificationDate = @DateOfFinalCaseClassification) OR (@DateOfFinalCaseClassification IS NULL))
			AND ((expoSure.idfsRayon = @LocationOfExposureRayon) OR (@LocationOfExposureRayon IS NULL))
			AND ((expoSure.idfsRegion = @LocationOfExposureRegion) OR (@LocationOfExposureRegion IS NULL))
			AND hc.intRowStatus = 0;
		END
		ELSE
		BEGIN
			-- =======================================================================================
			-- NON-CONFIGURABLE SITE FILTRATION RULES
			--
			-- Apply non-configurable site filtration rules for third level sites.
			-- =======================================================================================
			--
			-- Rayon of the site where the report was created.
			DECLARE @SiteRayonList VARCHAR(MAX) = '';

			SELECT @SiteRayonList = @SiteRayonList + ',' + CAST(l.idfsRayon AS VARCHAR)
			FROM dbo.tstSite s
			INNER JOIN dbo.tlbOffice AS o ON o.idfOffice = s.idfOffice
			INNER JOIN dbo.tlbGeoLocationShared AS l ON l.idfGeoLocationShared = o.idfLocation
			WHERE (s.idfsSite IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@SiteList, NULL, ',')) OR (@SiteList IS NULL));

			SET @SiteRayonList = SUBSTRING(@SiteRayonList, 2, LEN(@SiteRayonList));

			INSERT INTO @IDs
			SELECT 
				h.idfHumanCase,
				1,
				1,
				1,
				1,
				1

			FROM dbo.tlbHumanCase h
			INNER JOIN dbo.tstSite AS s ON h.idfsSite = s.idfsSite
			INNER JOIN dbo.tlbOffice AS o ON o.idfOffice = s.idfOffice AND o.intRowStatus = 0
			INNER JOIN dbo.tlbGeoLocationShared AS l ON l.idfGeoLocationShared = o.idfLocation AND l.intRowStatus = 0
			WHERE (h.intRowStatus = 0)
			AND (l.idfsRayon IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@SiteRayonList, NULL, ',')))
			ORDER BY h.idfHumanCase;

			-- Rayon of the report current residence address.
			INSERT INTO @IDs
			SELECT 
				h.idfHumanCase,
				1,
				1,
				1,
				1,
				1

			FROM dbo.tlbHumanCase h
			INNER JOIN dbo.tlbHuman AS hu ON hu.idfHuman = h.idfHuman AND hu.intRowStatus = 0
			INNER JOIN dbo.tlbGeoLocation l ON l.idfGeoLocation = hu.idfCurrentResidenceAddress AND l.intRowStatus = 0
			WHERE (h.intRowStatus = 0)
			AND (l.idfsRayon IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@SiteRayonList, NULL, ',')))
			ORDER BY h.idfHumanCase;

			-- Rayon of the report location of exposure, if corresponding field was filled in.
			INSERT INTO @IDs
			SELECT 
				h.idfHumanCase,
				1,
				1,
				1,
				1,
				1

			FROM dbo.tlbHumanCase h
			INNER JOIN dbo.tlbGeoLocation l ON l.idfGeoLocation = h.idfPointGeoLocation AND l.intRowStatus = 0
			WHERE (h.intRowStatus = 0)
			AND (l.idfsRayon IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@SiteRayonList, NULL, ',')))
			ORDER BY h.idfHumanCase;

			-- Report data shall be available to all sites' organizations connected to the particular report.
			-- Notification sent by, notification received by, facility where the patient first sought 
			-- care, hospital, and the conducting investigation organizations.
			DECLARE @SiteOrganizationList VARCHAR(MAX) = '';

			SELECT 
				@SiteOrganizationList = @SiteOrganizationList + ',' + CAST(o.idfOffice AS VARCHAR)
			FROM dbo.tlbOffice o
			WHERE (o.idfsSite IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@SiteList, NULL, ',')) OR (@SiteList IS NULL));

			SET @SiteOrganizationList = SUBSTRING(@SiteOrganizationList, 2, LEN(@SiteOrganizationList));

			INSERT INTO @IDs
			SELECT 
				h.idfHumanCase,
				1,
				1,
				1,
				1,
				1

			FROM dbo.tlbHumanCase h
			WHERE (h.intRowStatus = 0)
			AND (h.idfSentByOffice IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@SiteOrganizationList, NULL, ','))
					OR h.idfReceivedByOffice IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@SiteOrganizationList, NULL, ','))
					OR h.idfSoughtCareFacility IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@SiteOrganizationList, NULL, ','))
					OR h.idfHospital IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@SiteOrganizationList, NULL, ','))
					OR h.idfInvestigatedByOffice IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@SiteOrganizationList, NULL, ','))
				)
			ORDER BY h.idfHumanCase;

			-- Sample collected by and sent to organizations
			INSERT INTO @IDs
			SELECT 
				MAX(m.idfHumanCase),
				1,
				1,
				1,
				1,
				1

			FROM dbo.tlbMaterial m
			INNER JOIN dbo.tlbHumanCase AS h ON h.idfHumanCase = m.idfHumanCase AND h.intRowStatus = 0
			WHERE (m.intRowStatus = 0)
				AND (m.idfFieldCollectedByOffice IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@SiteOrganizationList, NULL, ','))
					OR m.idfSendToOffice IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@SiteOrganizationList, NULL, ',')))
			GROUP BY m.idfHumanCase;

			-- Sample transferred to organizations
			INSERT INTO @IDs
			SELECT 
				MAX(m.idfHumanCase),
				1,
				1,
				1,
				1,
				1

			FROM dbo.tlbMaterial m
			INNER JOIN dbo.tlbHumanCase AS h ON h.idfHumanCase = m.idfHumanCase AND h.intRowStatus = 0
			INNER JOIN dbo.tlbTransferOutMaterial AS tom ON m.idfMaterial = tom.idfMaterial AND tom.intRowStatus = 0
			INNER JOIN dbo.tlbTransferOUT AS t ON tom.idfTransferOut = t.idfTransferOut AND t.intRowStatus = 0
			WHERE (m.intRowStatus = 0)
			AND (t.idfSendToOffice IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@SiteOrganizationList, NULL, ',')))
			GROUP BY m.idfHumanCase;

			--
			-- Report data shall be available to the sites with the connected outbreak, if the report 
			-- is the primary report/session for an outbreak.
			--
			INSERT INTO @IDs
			SELECT
				h.idfHumanCase,
				1,
				1,
				1,
				1,
				1

			FROM dbo.tlbHumanCase h
			INNER JOIN dbo.tlbOutbreak AS o ON h.idfHumanCase = o.idfPrimaryCaseOrSession AND o.intRowStatus = 0
			WHERE (h.intRowStatus = 0)
			AND (o.idfsSite IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@SiteList, NULL, ',')));

		END;

		-- =======================================================================================
		-- CONFIGURABLE SITE FILTRATION RULES
		-- 
		-- Apply configurable site filtration rules for use case SAUC34. Some of these rules may 
		-- overlap the non-configurable rules.
		-- =======================================================================================
		--
		-- Apply at the user's site group level, granted by a site group.
		--
		INSERT INTO @IDs
		SELECT 
			h.idfHumanCase,
			a.ReadPermissionIndicator,
			a.AccessToPersonalDataPermissionIndicator,
			a.AccessToGenderAndAgeDataPermissionIndicator,
			a.WritePermissionIndicator,
			a.DeletePermissionIndicator

		FROM dbo.tlbHumanCase h
		INNER JOIN dbo.tflSiteToSiteGroup AS grantingSGS ON grantingSGS.idfsSite = h.idfsSite
		INNER JOIN dbo.tstUserTable AS u ON u.idfPerson = @EmployeeID AND u.intRowStatus = 0
		INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorSiteGroupID = @SiteGroupID AND ara.intRowStatus = 0
		INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID AND a.intRowStatus = 0
		INNER JOIN dbo.AccessRulePermission AS arp ON arp.AccessRuleID = a.AccessRuleID AND arp.intRowStatus = 0
		WHERE h.intRowStatus = 0
		AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

		--
		-- Apply at the user's site level, granted by a site group.
		--
		INSERT INTO @IDs
		SELECT 
			h.idfHumanCase,
			a.ReadPermissionIndicator,
			a.AccessToPersonalDataPermissionIndicator,
			a.AccessToGenderAndAgeDataPermissionIndicator,
			a.WritePermissionIndicator,
			a.DeletePermissionIndicator

		FROM dbo.tlbHumanCase h
		INNER JOIN dbo.tflSiteToSiteGroup AS grantingSGS ON grantingSGS.idfsSite = h.idfsSite
		INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorSiteID = @SiteList AND ara.ActorEmployeeGroupID IS NULL AND ara.intRowStatus = 0
		INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID AND a.intRowStatus = 0
		WHERE h.intRowStatus = 0
		AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

		-- 
		-- Apply at the user's employee group level, granted by a site group.
		--
		INSERT INTO @IDs
		SELECT
			h.idfHumanCase,
			a.ReadPermissionIndicator,
			a.AccessToPersonalDataPermissionIndicator,
			a.AccessToGenderAndAgeDataPermissionIndicator,
			a.WritePermissionIndicator,
			a.DeletePermissionIndicator

		FROM dbo.tlbHumanCase h
		INNER JOIN dbo.tflSiteToSiteGroup AS grantingSGS ON grantingSGS.idfsSite = h.idfsSite
		INNER JOIN dbo.tlbEmployeeGroupMember AS egm ON egm.idfEmployee = @EmployeeID AND egm.intRowStatus = 0
		INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup AND ara.intRowStatus = 0
		INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID AND a.intRowStatus = 0
		WHERE h.intRowStatus = 0
		AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

		-- 
		-- Apply at the user's ID level, granted by a site group.
		--
		INSERT INTO @IDs
		SELECT 
			h.idfHumanCase,
			a.ReadPermissionIndicator,
			a.AccessToPersonalDataPermissionIndicator,
			a.AccessToGenderAndAgeDataPermissionIndicator,
			a.WritePermissionIndicator,
			a.DeletePermissionIndicator

		FROM dbo.tlbHumanCase h
		INNER JOIN dbo.tflSiteToSiteGroup AS grantingSGS ON grantingSGS.idfsSite = h.idfsSite
		INNER JOIN dbo.tstUserTable AS u ON u.idfPerson = @EmployeeID AND u.intRowStatus = 0
		INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorUserID = u.idfUserID AND ara.intRowStatus = 0
		INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID AND a.intRowStatus = 0
		WHERE h.intRowStatus = 0
		AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

		--
		-- Apply at the user's site group level, granted by a site.
		--
		INSERT INTO @IDs
		SELECT 
			h.idfHumanCase,
			a.ReadPermissionIndicator,
			a.AccessToPersonalDataPermissionIndicator,
			a.AccessToGenderAndAgeDataPermissionIndicator,
			a.WritePermissionIndicator,
			a.DeletePermissionIndicator

		FROM dbo.tlbHumanCase h
		INNER JOIN dbo.tflSiteToSiteGroup AS sgs ON sgs.idfSiteGroup = @SiteGroupID
		INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorSiteGroupID = sgs.idfSiteGroup AND ara.intRowStatus = 0
		INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID AND a.intRowStatus = 0
		WHERE h.intRowStatus = 0
		AND sgs.idfsSite = h.idfsSite;

		-- 
		-- Apply at the user's site level, granted by a site.
		--
		INSERT INTO @IDs
		SELECT 
			h.idfHumanCase,
			a.ReadPermissionIndicator,
			a.AccessToPersonalDataPermissionIndicator,
			a.AccessToGenderAndAgeDataPermissionIndicator,
			a.WritePermissionIndicator,
			a.DeletePermissionIndicator

		FROM dbo.tlbHumanCase h
		INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorSiteID = @SiteList AND ara.ActorEmployeeGroupID IS NULL AND ara.intRowStatus = 0
		INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID AND a.intRowStatus = 0
		WHERE h.intRowStatus = 0
		AND a.GrantingActorSiteID = h.idfsSite;

		-- 
		-- Apply at the user's employee group level, granted by a site.
		--
		INSERT INTO @IDs
		SELECT
			h.idfHumanCase,
			a.ReadPermissionIndicator,
			a.AccessToPersonalDataPermissionIndicator,
			a.AccessToGenderAndAgeDataPermissionIndicator,
			a.WritePermissionIndicator,
			a.DeletePermissionIndicator

		FROM dbo.tlbHumanCase h
		INNER JOIN dbo.tlbEmployeeGroupMember AS egm ON egm.idfEmployee = @EmployeeID AND egm.intRowStatus = 0
		INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup AND ara.intRowStatus = 0
		INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID	AND a.intRowStatus = 0
		WHERE h.intRowStatus = 0
		AND a.GrantingActorSiteID = h.idfsSite;

		-- 
		-- Apply at the user's ID level, granted by a site.
		--
		INSERT INTO @IDs
		SELECT
			h.idfHumanCase,
			a.ReadPermissionIndicator,
			a.AccessToPersonalDataPermissionIndicator,
			a.AccessToGenderAndAgeDataPermissionIndicator,
			a.WritePermissionIndicator,
			a.DeletePermissionIndicator

		FROM dbo.tlbHumanCase h
		INNER JOIN dbo.tstUserTable AS u ON u.idfPerson = @EmployeeID AND u.intRowStatus = 0
		INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorUserID = u.idfUserID AND ara.intRowStatus = 0
		INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID AND a.intRowStatus = 0
		WHERE h.intRowStatus = 0
		AND a.GrantingActorSiteID = h.idfsSite;

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
		FROM @IDs
		WHERE ID IN (
				SELECT h.idfHumanCase
				FROM dbo.tlbHumanCase h
				INNER JOIN dbo.tstObjectAccess AS oa ON oa.idfsObjectID = h.idfsFinalDiagnosis
					AND oa.intRowStatus = 0
				WHERE oa.intPermission = 1
					AND oa.idfActor = -506
				);

		--
		-- Apply level 1 disease filtration rules for an employee's associated user group(s).  
		-- Allows and denies will supersede level 0.
		--
		INSERT INTO @IDs
		SELECT h.idfHumanCase
			,1
			,1
			,1
			,1
			,1
		FROM dbo.tlbHumanCase h
		INNER JOIN dbo.tstObjectAccess AS oa ON oa.idfsObjectID = h.idfsFinalDiagnosis
			AND oa.intRowStatus = 0
		WHERE oa.intPermission = 2 -- Allow permission
			AND h.intRowStatus = 0
			AND (
				oa.idfActor IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@EmployeeGroupList, NULL, ',')
					)
				);

		DELETE
		FROM @IDs
		WHERE ID IN (
				SELECT h.idfHumanCase
				FROM dbo.tlbHumanCase h
				INNER JOIN dbo.tstObjectAccess AS oa ON oa.idfsObjectID = h.idfsFinalDiagnosis
					AND oa.intRowStatus = 0
				WHERE intPermission = 1 -- Deny permission
					AND (
						idfActor IN (
							SELECT CAST([Value] AS BIGINT)
							FROM dbo.FN_GBL_SYS_SplitList(@EmployeeGroupList, NULL, ',')
							)
						)
				);

		--
		-- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
		-- will supersede level 1.
		--
		INSERT INTO @IDs
		SELECT h.idfHumanCase
			,1
			,1
			,1
			,1
			,1
		FROM dbo.tlbHumanCase h
		INNER JOIN dbo.tstObjectAccess AS oa ON oa.idfsObjectID = h.idfsFinalDiagnosis
			AND oa.intRowStatus = 0
		WHERE oa.intPermission = 2 -- Allow permission
			AND h.intRowStatus = 0
			AND oa.idfActor = @EmployeeID;

		DELETE
		FROM @IDs
		WHERE ID IN (
				SELECT h.idfHumanCase
				FROM dbo.tlbHumanCase h
				INNER JOIN dbo.tstObjectAccess AS oa ON oa.idfsObjectID = h.idfsFinalDiagnosis
					AND oa.intRowStatus = 0
				WHERE intPermission = 1 -- Deny permission
					AND idfActor = @EmployeeID
				);

		-- ========================================================================================
		-- FINAL QUERY
		-- ========================================================================================
		DECLARE @t TABLE( 
			HumanDiseaseReportID bigint, 
			Report_ID nvarchar(200), 
			PatientID bigint, 
			HumanMasterID bigint,
			LegacyCaseId nvarchar(200),
			Persons_Name nvarchar(600),
			Date_Entered datetime,
			Disease nvarchar(200),
			Report_Status nvarchar(200),
			[Location] nvarchar(200),
			Case_Classification nvarchar(100),
			Person_ID nvarchar(100),
			Entered_By_Name nvarchar(600),
			Entered_By_Organization nvarchar(2000),
			Report_Type nvarchar(200),
			Hospitalization nvarchar(200)
		)	
		INSERT INTO @t
		SELECT hc.idfHumanCase 'HumanDiseaseReportID'
			,hc.strCaseID 'Report_ID'
			,hc.idfHuman AS PatientID
			,h.idfHumanActual AS HumanMasterID
			,hc.LegacyCaseId
			,ISNULL(h.strLastName, N'') + ', ' + ISNULL(' ' + h.strFirstName, '') + ISNULL(' ' + h.strSecondName, '') AS 'Persons_Name'
			,hc.datEnteredDate 'Date_Entered'
			,disease.[name] AS 'Disease'
			,reportStatus.[name] AS 'Report_Status'
			,region.[name] + ', ' + rayon.[name] AS 'Location'
			,ISNULL(finalClassification.strDefault, initialClassification.strDefault) AS 'Case_Classification'
			,humanActAddInfo.EIDSSPersonID AS 'Person_ID'
			,ISNULL(person.strFamilyName, N'') + ', ' + ISNULL(' ' + person.strFirstName, '') AS 'Entered_By_Name'
			,orgname.[name] AS 'Entered_By_Organization'
			,reportType.[name] AS 'Report_Type'
			,hosp.[name] AS 'Hospitalization'
		FROM @IDs hdr
		INNER JOIN dbo.tlbHumanCase AS hc ON hc.idfHumanCase = hdr.ID
			AND hc.intRowStatus = 0
		INNER JOIN tlbHuman h ON h.idfHuman = hc.idfHuman
			AND h.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) AS disease ON disease.idfsReference = hc.idfsFinalDiagnosis
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) AS reportStatus ON reportStatus.idfsReference = hc.idfsCaseProgressStatus
		-- 06/22/2020 MK: Changed the join to look for person's current address as per the used case HUC09
		INNER JOIN dbo.tlbGeoLocation L ON L.idfGeoLocation = h.idfCurrentResidenceAddress
			AND L.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000003) AS region ON region.idfsReference = L.idfsRegion
		LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000002) AS rayon ON rayon.idfsReference = L.idfsRayon
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) AS initialClassification ON initialClassification.idfsReference = hc.idfsInitialCaseStatus
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) AS finalClassification ON finalClassification.idfsReference = hc.idfsFinalCaseStatus
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000144) AS reportType ON reportType.idfsReference = hc.DiseaseReportTypeID
		LEFT JOIN dbo.tlbPerson person ON person.idfPerson = hc.idfPersonEnteredBy
			AND person.intRowStatus = 0
		LEFT JOIN dbo.tlbOffice AS org ON org.idfOffice = person.idfInstitution
			AND org.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000100) AS hosp ON hosp.idfsReference = hc.idfsYNHospitalization
		LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) AS orgname ON orgname.idfOffice = hc.idfInvestigatedByOffice
			AND orgname.intRowStatus = 0
		LEFT JOIN dbo.tlbHumanActual AS ha ON h.idfHumanActual = ha.idfHumanActual
			AND h.intRowStatus = 0
			AND ha.intRowStatus = 0
		LEFT JOIN dbo.HumanActualAddlInfo AS humanActAddInfo ON humanActAddInfo.HumanActualAddlInfoUID = ha.idfHumanActual
			AND humanActAddInfo.intRowStatus = 0
		LEFT JOIN dbo.tlbOffice SentBy ON SentBy.idfOffice = HC.idfSentByOffice
			AND SentBy.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000046) SentByRef ON SentByRef.idfsReference = SentBy.idfsOfficeName
		LEFT JOIN dbo.tlbOffice ReceivedBy ON ReceivedBy.idfOffice = HC.idfReceivedByOffice
			AND ReceivedBy.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000046) ReceivedByRef ON ReceivedByRef.idfsReference = ReceivedBy.idfsOfficeName
		LEFT JOIN dbo.tlbGeoLocation expoSure ON expoSure.idfGeoLocation = hc.idfPointGeoLocation
			AND expoSure.intRowStatus = 0
		WHERE (
				(hc.strCaseID LIKE '%' + @EIDSSReportID + '%')
				OR @EIDSSReportID IS NULL
				)
			AND (
				(hc.idfHumanCase = @HumanDiseaseReportID)
				OR (@HumanDiseaseReportID IS NULL)
				)
			AND (
				(hc.LegacyCaseID = @LegacyID)
				OR (@LegacyID IS NULL)
				)
			AND (
				(ha.idfHumanActual = @PatientID)
				OR (@PatientID IS NULL)
				)
			AND (
				(h.strPersonId = @EIDSSPersonID)
				OR (@EIDSSPersonID IS NULL)
				)
			AND (
				(idfsFinalDiagnosis = @DiseaseID)
				OR (@DiseaseID IS NULL)
				)
			AND (
				(idfsCaseProgressStatus = @ReportStatusTypeID)
				OR (@ReportStatusTypeID IS NULL)
				)
			AND (
				(idfsFinalCaseStatus = @ClassificationTypeID)
				OR (@ClassificationTypeID IS NULL)
				)
			AND (
				(hc.idfsYNHospitalization = @HospitalizationStatusTypeID)
				OR (@HospitalizationStatusTypeID IS NULL)
				)
			AND (
				(
					ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstOrGivenName, '')
						WHEN ''
							THEN ISNULL(h.strFirstName, '')
						ELSE @PatientFirstOrGivenName
						END
					)
				OR (CHARINDEX(@PatientFirstOrGivenName, ISNULL(h.strFirstName, '')) > 0)
				)
			AND (
				(
					ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
						WHEN ''
							THEN ISNULL(h.strSecondName, '')
						ELSE @PatientMiddleName
						END
					)
				OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
				)
			AND (
				(
					ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastOrSurname, '')
						WHEN ''
							THEN ISNULL(h.strLastName, '')
						ELSE @PatientLastOrSurname
						END
					)
				OR (CHARINDEX(@PatientLastOrSurname, ISNULL(h.strLastName, '')) > 0)
				)
			AND (
				hc.strLocalIdentifier = @LocalSampleID
				OR @LocalSampleID IS NULL
				) -- is this the same
			AND (
				(L.idfsRegion = @RegionID)
				OR (@RegionID IS NULL)
				)
			AND (
				(L.idfsRayon = @RayonID)
				OR (@RayonID IS NULL)
				)
			AND (
				(
					hc.datEnteredDate >= CASE ISNULL(@DateEnteredFrom, '1/1/2050')
						WHEN '1/1/2050'
							THEN isnull(hc.datEnteredDate, '1/1/2050')
						ELSE @DateEnteredFrom
						END
					)
				OR (ISNULL(@DateEnteredFrom, '') = '')
				)
			AND (
				(
					hc.datEnteredDate <= CASE ISNULL(@DateEnteredTo, '1/1/1901')
						WHEN '1/1/1901'
							THEN ISNULL(hc.datEnteredDate, '1/1/1901')
						ELSE @DateEnteredTo
						END
					)
				OR (ISNULL(@DateEnteredTo, '') = '')
				)
			AND (
				(ReceivedBy.idfsOfficeName = @ReceivedByFacility)
				OR (@ReceivedByFacility IS NULL)
				)
			AND (
				(SentBy.idfsOfficeName = @SentByFacility)
				OR (@SentByFacility IS NULL)
				)
			AND (
				(hc.datFinalDiagnosisDate = @DiagnosisDateTo)
				OR (@DiagnosisDateTo IS NULL)
				)
			AND (
				(hc.datFirstSoughtCareDate = @DiagnosisDateFrom)
				OR (@DiagnosisDateFrom IS NULL) -- is this same
				)
			AND (
				(hc.idfsSite = @DataEntrySite)
				OR (@DataEntrySite IS NULL)
				)
			AND (
				(hc.datOnSetDate = @DateOfSymptomsOnset)
				OR (@DateOfSymptomsOnset IS NULL)
				)
			AND (
				(hc.datNotificationDate = @NotificationDate)
				OR (@NotificationDate IS NULL)
				)
			AND (
				(hc.datFinalCaseClassificationDate = @DateOfFinalCaseClassification)
				OR (@DateOfFinalCaseClassification IS NULL)
				)
			AND (
				(expoSure.idfsRayon = @LocationOfExposureRayon)
				OR (@LocationOfExposureRayon IS NULL)
				)
			AND (
				(expoSure.idfsRegion = @LocationOfExposureRegion)
				OR (@LocationOfExposureRegion IS NULL)
				)
			AND hc.intRowStatus = 0
		--ORDER BY hc.strCaseID DESC
		--	,disease.Name
		--	,hc.datEnteredDate
		--	,reportStatus.name OFFSET(@PageSize * @MaxPagesPerFetch) * (@PaginationSet - 1) ROWS

		;
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER (ORDER BY
				CASE WHEN @sortColumn = 'ReportID' AND @sortOrder = 'asc' THEN Report_ID END ASC,
				CASE WHEN @sortColumn = 'ReportID' AND @sortOrder = 'desc' THEN Report_ID END DESC
			) AS ROWNUM,
			COUNT(*) OVER () AS
				TotalRowCount,
				HumanDiseaseReportID,
				Report_ID, 
				PatientID, 
				HumanMasterID,
				LegacyCaseId,
				Persons_Name,
				Date_Entered,
				Disease,
				Report_Status,
				[Location],
				Case_Classification,
				Person_ID,
				Entered_By_Name,
				Entered_By_Organization,
				Report_Type,
				Hospitalization
			FROM @t
		)

		SELECT 
				TotalRowCount,
				HumanDiseaseReportID,
				Report_ID, 
				PatientID, 
				HumanMasterID,
				LegacyCaseId,
				Persons_Name,
				Date_Entered,
				Disease,
				Report_Status,
				[Location],
				Case_Classification,
				Person_ID,
				Entered_By_Name,
				Entered_By_Organization,
				Report_Type,
				Hospitalization,
				TotalPages = (TotalRowcount/@pageSize) + IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo
			FROM CTEResults
			WHERE RowNum > @firstRec AND RowNum < @lastRec

		
		--FETCH NEXT (@PageSize * @MaxPagesPerFetch) ROWS ONLY;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
