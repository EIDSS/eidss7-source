SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================================
-- Name: USP_LAB_TRANSFER_GETList
--
-- Description:	Get laboratory transfer list for the various laboratory use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     10/18/2018 Initial release.
-- Stephen Long     12/19/2018 Added pagination logic.
-- Stephen Long     01/25/2019 Added row selection indicator and corrected intRowStatus in where 
--                             clause to use sample table instead of testing table.
-- Stephen Long     01/30/2019 Added sample disease reference join, and removed the vector 
--                             surveillance session joins as they are no longer needed.
-- Stephen Long     02/09/2019 Added sample ID parameter.
-- Stephen Long     02/19/2019 Added test requested, disease ID and functional area to the select 
--                             list.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     08/19/2019 Added comma to sent by person name (last name ', ' first name).
-- Stephen Long     09/14/2019 Added pagination set 0 to bring back "all" records.
-- Stephen Long     10/21/2019 Added accession indicator and test status type ID to the list of 
--                             fields.
-- Stephen Long     01/22/2020 Added site list for site filtration.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     03/17/2020 Removed declined transfer status from inclusion in the list.
-- Stephen Long     03/30/2020 Changed criteria on transferred in sample left join.
-- Stephen Long     04/07/2020 Added test name type ID to model, and corrected test assigned 
--                             indicator.
-- Stephen Long     04/23/2020 Correction on disease ID and disease name; add vector surveillance 
--                             session.
-- Stephen Long     04/26/2020 Added sent to organization ID to the model.
-- Stephen Long     05/06/2020 Added test started date and test category type name to the model.
-- Stephen Long     06/09/2020 Added intRowStatus check on transferred from organization.
-- Stephen Long     06/24/2020 Added external test check to the test left join.
-- Jason Li			09/24/2020 Remove blnExternalTest --AND t.blnExternalTest = 1 at line 224
-- Stephen Long     11/28/2020 Added configurable site filtration rules.
-- Stephen Long     12/16/2020 Changed join for vector surveillance session diseases to the sample
--                             table.
-- Stephen Long     12/31/2020 Change function on reference data to handle inactive records.
-- Mark Wilson		08/17/2021 Join tlbMonitoringSessionToDiagnosis to get diagnosis
-- Stephen Long     09/25/2021 Added new pagination and order by.
-- Stephen Long     11/18/2021 Added test status type name to the query.
-- Stephen Long     12/08/2021 Changed pagination logic and removed option recompile.
-- Stephen Long     02/03/2022 Corrected monitoring session to diagnosis join.
-- Stephen Long     02/10/2022 Replaced joins for monitoring session and vector session
--                             disease references to improve performance.
-- Stephen Long     03/24/2022 Added final results table variable to account for duplicates that 
--                             may return from filtration rules.
-- Stephen Long     05/17/2022 Removed primary key from monitoring and vector session disease 
--                             table variables.
-- Stephen Long     05/20/2022 Added string agg to session diseases.
-- Stephen Long     07/26/2022 Updated case statement on disease id and name.
-- Stephen Long     08/12/2022 Changed default sort column to EIDSSTransferID.
-- Stephen Long     10/14/2022 Changed monitoring session disease function to monitoring session
--                             to sample disease function.
-- Stephen Long     10/18/2022 Added test disease ID to the query.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/12/2023 Updated for site filtration queries.
-- Stephen Long     02/14/2023 Added filtration indicator logic.
-- Stephen Long     03/14/2023 Fix on default sort order.
-- Stephen Long     03/29/2023 Added default rule check for configurable filtration.
-- ================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_LAB_TRANSFER_GETList]
(
    @LanguageID NVARCHAR(50),
    @SampleID BIGINT = NULL,
    @FiltrationIndicator BIT = 1,
    @UserID BIGINT,
    @UserEmployeeID BIGINT,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT = NULL,
    @UserSiteGroupID BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MonitoringSessionDiseases TABLE
    (
        ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
        DiseaseIdentifiers VARCHAR(MAX) NOT NULL,
        DiseaseNames NVARCHAR(MAX) NOT NULL,
        DisplayDiseaseNames NVARCHAR(MAX) NOT NULL
    );
    DECLARE @VectorSessionDiseases TABLE
    (
        ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
        DiseaseIdentifiers VARCHAR(MAX) NOT NULL,
        DiseaseNames NVARCHAR(MAX) NOT NULL,
        DisplayDiseaseNames NVARCHAR(MAX) NOT NULL
    );
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL INDEX c NONCLUSTERED,
        SampleID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL,
        SampleID BIGINT NOT NULL INDEX c CLUSTERED,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @TransferredInSampleIdentifiers TABLE
    (
        SampleID BIGINT NOT NULL,
        TransferredInSampleID BIGINT NULL
    );
	
    DECLARE @Favorites XML;

    BEGIN TRY
	
        SET @Favorites =
        (
            SELECT PreferenceDetail
            FROM dbo.UserPreference Laboratory
            WHERE idfUserID = @UserID
                  AND ModuleConstantID = 10508006
                  AND intRowStatus = 0
        );

		-- Filter by Transfer Date within the date range which equals to XX days specified in System Preference:
		-- “Number of days for which data is displayed by default”.
		DECLARE @DaysDisplayed NVARCHAR(10)
		SELECT TOP 1
			@DaysDisplayed = JSON_VALUE(PreferenceDetail, '$.NumberDaysDisplayedByDefault')
		FROM dbo.SystemPreference
		WHERE intRowStatus = 0

		DECLARE @StartDate DATETIME
		IF @DaysDisplayed IS NOT NULL
			SET @StartDate = DATEADD(DAY, -1 * @DaysDisplayed, CONVERT(DATE, GETDATE()))

        IF @SampleID IS NULL
        BEGIN
            INSERT INTO @Results
            SELECT tr.idfTransferOut,
                   tom.idfMaterial,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbTransferOUT tr
                INNER JOIN dbo.tlbTransferOutMaterial tom
                    ON tom.idfTransferOut = tr.idfTransferOut
                       AND tom.intRowStatus = 0
            WHERE (
                      tr.idfSendFromOffice = @UserOrganizationID
                      OR tr.idfSendToOffice = @UserOrganizationID
                  )
                  AND (tr.idfsTransferStatus IN (   10001003, --In Progress
                                                    10001006 --Amended
                                                )
                      )
                  AND tr.intRowStatus = 0
				  AND (@StartDate IS NULL OR tr.datSendDate > @StartDate);

            -- =======================================================================================
            -- CONFIGURABLE FILTRATION RULES
            -- 
            -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the non-configurable rules.
            -- =======================================================================================
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT tr.idfTransferOut,
                   tom.idfMaterial,
                   ar.ReadPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ar.DeletePermissionIndicator
            FROM dbo.tlbTransferOUT tr
                INNER JOIN dbo.tlbTransferOutMaterial tom
                    ON tom.idfTransferOut = tr.idfTransferOut
                       AND tom.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = tr.idfsSite
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = @UserSiteGroupID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule ar
                    ON ar.AccessRuleID = ara.AccessRuleID
                       AND ar.intRowStatus = 0
                       AND ar.DefaultRuleIndicator = 0
            WHERE tr.intRowStatus = 0
                  AND @UserSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup
				  AND (@StartDate IS NULL OR tr.datSendDate > @StartDate);

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT tr.idfTransferOut,
                   tom.idfMaterial,
                   ar.ReadPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ar.DeletePermissionIndicator
            FROM dbo.tlbTransferOUT tr
                INNER JOIN dbo.tlbTransferOutMaterial tom
                    ON tom.idfTransferOut = tr.idfTransferOut
                       AND tom.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = tr.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule ar
                    ON ar.AccessRuleID = ara.AccessRuleID
                       AND ar.intRowStatus = 0
                       AND ar.DefaultRuleIndicator = 0
            WHERE tr.intRowStatus = 0
                  AND ar.GrantingActorSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup
				  AND (@StartDate IS NULL OR tr.datSendDate > @StartDate);

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT tr.idfTransferOut,
                   tom.idfMaterial,
                   ar.ReadPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ar.DeletePermissionIndicator
            FROM dbo.tlbTransferOUT tr
                INNER JOIN dbo.tlbTransferOutMaterial tom
                    ON tom.idfTransferOut = tr.idfTransferOut
                       AND tom.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = tr.idfsSite
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule ar
                    ON ar.AccessRuleID = ara.AccessRuleID
                       AND ar.intRowStatus = 0
                       AND ar.DefaultRuleIndicator = 0
            WHERE tr.intRowStatus = 0
                  AND ar.GrantingActorSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup
				  AND (@StartDate IS NULL OR tr.datSendDate > @StartDate);

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT tr.idfTransferOut,
                   tom.idfMaterial,
                   ar.ReadPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ar.DeletePermissionIndicator
            FROM dbo.tlbTransferOUT tr
                INNER JOIN dbo.tlbTransferOutMaterial tom
                    ON tom.idfTransferOut = tr.idfTransferOut
                       AND tom.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = tr.idfsSite
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule ar
                    ON ar.AccessRuleID = ara.AccessRuleID
                       AND ar.intRowStatus = 0
                       AND ar.DefaultRuleIndicator = 0
            WHERE tr.intRowStatus = 0
                  AND ar.GrantingActorSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup
				  AND (@StartDate IS NULL OR tr.datSendDate > @StartDate);

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @Results
            SELECT tr.idfTransferOut,
                   tom.idfMaterial,
                   ar.ReadPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ar.DeletePermissionIndicator
            FROM dbo.tlbTransferOUT tr
                INNER JOIN dbo.tlbTransferOutMaterial tom
                    ON tom.idfTransferOut = tr.idfTransferOut
                       AND tom.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfSiteGroup = @UserSiteGroupID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule ar
                    ON ar.AccessRuleID = ara.AccessRuleID
                       AND ar.intRowStatus = 0
                       AND ar.DefaultRuleIndicator = 0
            WHERE tr.intRowStatus = 0
                  AND @UserSiteGroupID IS NOT NULL
                  AND sgs.idfsSite = tr.idfsSite
				  AND (@StartDate IS NULL OR tr.datSendDate > @StartDate);

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @Results
            SELECT tr.idfTransferOut,
                   tom.idfMaterial,
                   ar.ReadPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ar.DeletePermissionIndicator
            FROM dbo.AccessRule ar
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.tlbTransferOUT tr
                    ON tr.intRowStatus = 0
                INNER JOIN dbo.tlbTransferOutMaterial tom
                    ON tom.idfTransferOut = tr.idfTransferOut
                       AND tom.intRowStatus = 0
            WHERE ar.GrantingActorSiteID IS NOT NULL
                  AND ar.DefaultRuleIndicator = 0
                  AND tr.idfsSite = ar.GrantingActorSiteID
				  AND (@StartDate IS NULL OR tr.datSendDate > @StartDate);

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @Results
            SELECT tr.idfTransferOut,
                   tom.idfMaterial,
                   ar.ReadPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ar.DeletePermissionIndicator
            FROM dbo.AccessRule ar
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.tlbTransferOUT tr
                    ON tr.intRowStatus = 0
                INNER JOIN dbo.tlbTransferOutMaterial tom
                    ON tom.idfTransferOut = tr.idfTransferOut
                       AND tom.intRowStatus = 0
            WHERE ar.GrantingActorSiteID IS NOT NULL
                  AND ar.DefaultRuleIndicator = 0
                  AND tr.idfsSite = ar.GrantingActorSiteID
				  AND (@StartDate IS NULL OR tr.datSendDate > @StartDate);

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @Results
            SELECT tr.idfTransferOut,
                   tom.idfMaterial,
                   ar.ReadPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ar.DeletePermissionIndicator
            FROM dbo.AccessRule ar
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.tlbTransferOUT tr
                    ON tr.intRowStatus = 0
                INNER JOIN dbo.tlbTransferOutMaterial tom
                    ON tom.idfTransferOut = tr.idfTransferOut
                       AND tom.intRowStatus = 0
            WHERE ar.GrantingActorSiteID IS NOT NULL
                  AND ar.DefaultRuleIndicator = 0
                  AND tr.idfsSite = ar.GrantingActorSiteID
				  AND (@StartDate IS NULL OR tr.datSendDate > @StartDate);

            -- =======================================================================================
            -- SITE FILTRATION RULES
            --
            -- Apply site filtration rules from use case SAUC29.
            -- =======================================================================================
            
            INSERT INTO @FinalResults
            SELECT res.ID,
                   res.SampleID,
                   MAX(res.ReadPermissionIndicator),
                   MAX(res.AccessToPersonalDataPermissionIndicator),
                   MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
                   MAX(res.WritePermissionIndicator),
                   MAX(res.DeletePermissionIndicator)
            FROM @Results res
                INNER JOIN dbo.tlbTransferOUT tr
                    ON tr.idfTransferOut = res.ID
                INNER JOIN dbo.tlbTransferOutMaterial tom
                    ON tom.idfTransferOut = tr.idfTransferOut
                       AND tom.intRowStatus = 0
            WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
                  AND (
                          tr.idfSendFromOffice = @UserOrganizationID
                          OR tr.idfSendToOffice = @UserOrganizationID
                      )
                  AND (
                          tom.idfMaterial = @SampleID
                          OR @SampleID IS NULL
                      )
                  AND (tr.idfsTransferStatus IN (   10001003, --In Progress
                                                    10001006 --Amended
                                                )
                      )
                  AND tr.intRowStatus = 0
            GROUP BY ID,
                     SampleID;
        END
        ELSE
        BEGIN
            INSERT INTO @FinalResults
            SELECT tr.idfTransferOut,
                   tom.idfMaterial,
                   1,
                   CASE
                       WHEN tr.idfsSite = @UserSiteID
                            OR @FiltrationIndicator = 0 THEN
                           1
                       ELSE
                           0
                   END,
                   CASE
                       WHEN tr.idfsSite = @UserSiteID
                            OR @FiltrationIndicator = 0 THEN
                           1
                       ELSE
                           0
                   END,
                   CASE
                       WHEN tr.idfsSite = @UserSiteID
                            OR @FiltrationIndicator = 0 THEN
                           1
                       ELSE
                           0
                   END,
                   CASE
                       WHEN tr.idfsSite = @UserSiteID
                            OR @FiltrationIndicator = 0 THEN
                           1
                       ELSE
                           0
                   END
            FROM dbo.tlbTransferOUT tr
                INNER JOIN dbo.tlbTransferOutMaterial tom
                    ON tom.idfTransferOut = tr.idfTransferOut
                       AND tom.intRowStatus = 0
            WHERE tom.idfMaterial = @SampleID
                  AND tr.intRowStatus = 0
				  AND (@StartDate IS NULL OR tr.datSendDate > @StartDate);
        END

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        DECLARE @InProgressCount INT = (
                                           SELECT COUNT(DISTINCT res.ID)
                                           FROM @FinalResults res
                                               INNER JOIN dbo.tlbTransferOUT tr
                                                   ON tr.idfTransferOut = res.ID
                                           WHERE tr.idfsTransferStatus IN (   10001003, --In Progress
                                                                              10001006  --Amended
                                                                          )
                                       );

        INSERT INTO @TransferredInSampleIdentifiers
        SELECT SampleID,
               transferredInSample.idfMaterial
        FROM @FinalResults
            INNER JOIN dbo.tlbMaterial AS transferredInSample
                ON transferredInSample.idfRootMaterial = SampleID
                   AND transferredInSample.intRowStatus = 0
                   AND transferredInSample.idfsSampleKind = 12675430000000; --Transferred in


		INSERT INTO @MonitoringSessionDiseases
        SELECT	ms.idfMonitoringSession,
				STUFF(isnull(msDiseases.DiseaseIds, ','),1,1,'') AS DiseaseIds,
				STUFF(isnull(msDiseases.DiseaseNames, N'|'),1,1,N'') AS DiseaseNames,
				REPLACE(STUFF(isnull(msDiseases.DiseaseNames, N'|'),1,1,N''), N'|', N',') AS DisplayDiseaseNames
		from	dbo.tlbMonitoringSession ms
		outer apply
		(	select
			(	select	distinct N'|' + diseaseName.[name]
				from		dbo.tlbMonitoringSessionToDiagnosis msd
				join		dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
				on			diseaseName.idfsReference = msd.idfsDiagnosis
				where		msd.idfMonitoringSession = ms.idfMonitoringSession
							and msd.intRowStatus = ms.intRowStatus
				order by	N'|' + diseaseName.[name]
				for xml path('')
			) DiseaseNames,
			(	select	distinct ',' + cast(msd.idfsDiagnosis as nvarchar(20))
				from		dbo.tlbMonitoringSessionToDiagnosis msd
				join		dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
				on			diseaseName.idfsReference = msd.idfsDiagnosis
				where		msd.idfMonitoringSession = ms.idfMonitoringSession
							and msd.intRowStatus = ms.intRowStatus
				order by	',' + cast(msd.idfsDiagnosis as nvarchar(20))
				for xml path('')
			) DiseaseIds
		) msDiseases
		where	exists
				(	select	1
					FROM @FinalResults res
						INNER JOIN dbo.tlbTransferOUT tr
							ON tr.idfTransferOut = res.ID
						INNER JOIN dbo.tlbMaterial m
							ON m.idfMaterial = res.SampleID
							   AND m.intRowStatus = 0
					where	m.idfMonitoringSession = ms.idfMonitoringSession
				)


        INSERT INTO @VectorSessionDiseases
        SELECT	vss.idfVectorSurveillanceSession,
				STUFF(isnull(vsDiseases.DiseaseIds, ','),1,1,'') AS DiseaseIds,
				STUFF(isnull(vsDiseases.DiseaseNames, N'|'),1,1,N'') AS DiseaseNames,
				REPLACE(STUFF(isnull(vsDiseases.DiseaseNames, N'|'),1,1,N''), N'|', N',') AS DisplayDiseaseNames
		from	dbo.tlbVectorSurveillanceSession vss
		outer apply
		(		select
				(	select	distinct N'|' + diseaseName.[name]
					from		trtDiagnosis d
					outer apply
					(	select	top 1 vsssd.idfsVSSessionSummary
						from	tlbVectorSurveillanceSessionSummaryDiagnosis vsssd
						join	tlbVectorSurveillanceSessionSummary vsss
						on		vsss.idfsVSSessionSummary = vsssd.idfsVSSessionSummary
								and vsss.intRowStatus = 0
						where	vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
								and vsssd.idfsDiagnosis = d.idfsDiagnosis
								and vsssd.intRowStatus = 0
					) sum_diag
					outer apply
					(	select	top 1 m_dname.idfMaterial
						from	tlbMaterial m_dname
						where	m_dname.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
								and m_dname.DiseaseID = d.idfsDiagnosis
								and m_dname.intRowStatus = 0
					) m_diag
					join		dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
					on			diseaseName.idfsReference = d.idfsDiagnosis
					where		(sum_diag.idfsVSSessionSummary is not null or m_diag.idfMaterial is not null)
								and diseaseName.[name] is not null
					order by	N'|' + diseaseName.[name]
					for xml path('')
				) DiseaseNames,
				(	select	',' + cast(d.idfsDiagnosis as nvarchar(20))
					from		trtDiagnosis d
					outer apply
					(	select	top 1 vsssd.idfsVSSessionSummary
						from	tlbVectorSurveillanceSessionSummaryDiagnosis vsssd
						join	tlbVectorSurveillanceSessionSummary vsss
						on		vsss.idfsVSSessionSummary = vsssd.idfsVSSessionSummary
								and vsss.intRowStatus = 0
						where	vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
								and vsssd.idfsDiagnosis = d.idfsDiagnosis
								and vsssd.intRowStatus = 0
					) sum_diag
					outer apply
					(	select	top 1 m_dname.idfMaterial
						from	tlbMaterial m_dname
						where	m_dname.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
								and m_dname.DiseaseID = d.idfsDiagnosis
								and m_dname.intRowStatus = 0
					) m_diag
					where		(sum_diag.idfsVSSessionSummary is not null or m_diag.idfMaterial is not null)
					order by	',' + cast(d.idfsDiagnosis as nvarchar(20))
					for xml path('')
				) DiseaseIds
		) vsDiseases
		where	exists
				(	select	1
					FROM @FinalResults res
						INNER JOIN dbo.tlbTransferOUT tr
							ON tr.idfTransferOut = res.ID
						INNER JOIN dbo.tlbMaterial m
							ON m.idfMaterial = res.SampleID
							   AND m.intRowStatus = 0
					where	m.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
				)


        SELECT tr.idfTransferOut AS TransferID,
               tr.strBarcode AS EIDSSTransferID,
               m.idfMaterial AS TransferredOutSampleID,
               trsid.TransferredInSampleID AS TransferredInSampleID,
               CASE
                   WHEN f.SampleID IS NULL THEN
                       0
                   ELSE
                       1
               END AS FavoriteIndicator,
               m.strCalculatedCaseID AS EIDSSReportOrSessionID,
               m.strCalculatedHumanName AS PatientOrFarmOwnerName,
               m.strBarcode AS EIDSSLaboratorySampleID,
               tr.idfSendToOffice AS TransferredToOrganizationID,
               transferredToOrganization.AbbreviatedName AS TransferredToOrganizationName,
               tr.idfSendFromOffice AS TransferredFromOrganizationID,
               tr.datSendDate AS TransferDate,
               tr.TestRequested,
               t.idfTesting AS TestID,
               t.idfsTestName AS TestNameTypeID,
               testNameType.name AS TestNameTypeName,
               t.idfsTestResult AS TestResultTypeID,
               testResultType.name AS TestResultTypeName,
               t.idfsTestStatus AS TestStatusTypeID,
               testStatusType.name AS TestStatusTypeName,
               t.idfsTestCategory AS TestCategoryTypeID,
               t.idfsDiagnosis AS TestDiseaseID,
               t.datStartedDate AS StartedDate,
               t.datConcludedDate AS ResultDate,
               t.strContactPerson AS ContactPersonName,
               m.strFieldBarcode AS EIDSSLocalOrFieldSampleID,
               sampleType.name AS SampleTypeName,
			   coalesce(CAST(m.DiseaseID AS VARCHAR(MAX)), msDiseases.DiseaseIdentifiers, vsDiseases.DiseaseIdentifiers, '') AS DiseaseID,
			   coalesce(diseaseName.[name], msDiseases.DiseaseNames, vsDiseases.DiseaseNames, N'') AS DiseaseName,
               m.datAccession AS AccessionDate,
               m.idfInDepartment AS FunctionalAreaID,
               functionalArea.name AS FunctionalAreaName,
               m.blnAccessioned AS AccessionIndicator,
               m.idfsAccessionCondition AS AccessionConditionTypeID,
               m.idfsSampleStatus AS SampleStatusTypeID,
               CASE
                   WHEN m.blnAccessioned = 0
                        AND m.idfsSampleStatus IS NULL
                        AND m.idfsAccessionCondition IS NULL THEN
                       'Un-accessioned'
                   WHEN (m.blnAccessioned = 1 and m.idfsSampleStatus IS NULL) THEN
                       accessionConditionType.name
                   WHEN m.idfsSampleStatus = 10015007 --In Repository
               THEN
                       accessionConditionType.name
                   ELSE
                       sampleStatusType.name
               END AS AccessionConditionOrSampleStatusTypeName,
               m.strCondition AS AccessionComment,
               tr.strNote AS PurposeOfTransfer,
               tr.idfsSite AS TransferredFromOrganizationSiteID,
               transferredToOrganization.idfsSite AS TransferredToOrganizationSiteID,
               m.idfSendToOffice AS SentToOrganizationID,
               tr.idfSendByPerson AS SentByPersonID,
               tr.idfsTransferStatus AS TransferStatusTypeID,
               tr.intRowStatus AS RowStatus,
               a.strAnimalCode AS EIDSSAnimalID,
               CASE
                   WHEN m.TestUnassignedIndicator = 1 THEN
                       0
                   ELSE
                       1
               END AS TestAssignedIndicator,
               CASE
                   WHEN transferredToOrganization.idfsSite IS NULL THEN
                       1
                   ELSE
                       0
               END AS NonEIDSSLaboratoryIndicator,
               CASE
                   WHEN res.ReadPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN res.ReadPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN res.ReadPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN res.ReadPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, res.ReadPermissionIndicator)
               END AS ReadPermissionindicator,
               CASE
                   WHEN res.AccessToPersonalDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN res.AccessToPersonalDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN res.AccessToPersonalDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN res.AccessToPersonalDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, res.AccessToPersonalDataPermissionIndicator)
               END AS AccessToPersonalDataPermissionIndicator,
               CASE
                   WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, res.AccessToGenderAndAgeDataPermissionIndicator)
               END AS AccessToGenderAndAgeDataPermissionIndicator,
               CASE
                   WHEN res.WritePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN res.WritePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN res.WritePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN res.WritePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, res.WritePermissionIndicator)
               END AS WritePermissionIndicator,
               CASE
                   WHEN res.DeletePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN res.DeletePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN res.DeletePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN res.DeletePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, res.DeletePermissionIndicator)
               END AS DeletePermissionIndicator,
               0 AS RowAction,
               0 AS RowSelectionIndicator,
               @InProgressCount AS InProgressCount,
               COUNT(*) OVER () AS TotalRowCount
        FROM @FinalResults res
            INNER JOIN dbo.tlbTransferOUT tr
                ON tr.idfTransferOut = res.ID
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.SampleID
                   AND m.intRowStatus = 0
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                ON sampleType.idfsReference = m.idfsSampleType
            INNER JOIN dbo.FN_GBL_Institution_Min(@LanguageID) transferredToOrganization
                ON transferredToOrganization.idfOffice = tr.idfSendToOffice
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
                   AND t.blnExternalTest = 1
            LEFT JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'BIGINT')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
            LEFT JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
            LEFT JOIN @MonitoringSessionDiseases msDiseases
                ON msDiseases.ID = m.idfMonitoringSession
                   AND m.idfMonitoringSession IS NOT NULL
            LEFT JOIN @VectorSessionDiseases vsDiseases
                ON vsDiseases.ID = m.idfVectorSurveillanceSession
                   AND m.idfVectorSurveillanceSession IS NOT NULL
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) diseaseName
                ON diseaseName.idfsReference = m.DiseaseID
            LEFT JOIN dbo.tlbDepartment d
                ON d.idfDepartment = m.idfInDepartment
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164) functionalArea
                ON functionalArea.idfsReference = d.idfsDepartmentName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                ON testNameType.idfsReference = t.idfsTestName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                ON testResultType.idfsReference = t.idfsTestResult
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                ON testStatusType.idfsReference = t.idfsTestStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000110) accessionConditionType
                ON accessionConditionType.idfsReference = m.idfsAccessionCondition
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000015) sampleStatusType
                ON sampleStatusType.idfsReference = m.idfsSampleStatus
			outer apply
               (
                   SELECT TOP 1
                       tsi.TransferredInSampleID
                   FROM @TransferredInSampleIdentifiers tsi
                   WHERE tsi.SampleID = res.SampleID
               ) AS trsid
            ORDER BY tr.strBarcode DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
