SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================================
-- Name: USP_LAB_APPROVAL_GETList
--
-- Description:	Get laboratory approval list for the various lab use cases.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     12/03/2018 Initial release.
-- Stephen Long     12/19/2018 Added pagination logic.
-- Stephen Long     01/25/2019 Added previous sample and test status types.
-- Stephen Long     01/30/2019 Added sample disease reference join and removed the vector 
--                             surveillance session joins as they are no longer needed.
-- Stephen Long     02/19/2019 Split out selects between sample and test and added test deletion 
--                             as one of the options.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     08/30/2019 Added organization ID parameter and where clause changes for site.
-- Stephen Long     09/14/2019 Added pagination set 0 to bring back "all" records.
-- Stephen Long     09/28/2019 Updated test deletion base reference value to newly added entry.
-- Stephen Long     01/21/2020 Converted site ID to site list for site filtration.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     04/23/2020 Correction on disease ID and disease name; add vector surveillance 
--                             session.
-- Stephen Long     09/04/2020 Updated reference value for marked for deletion test status.
-- Stephen Long     11/30/2020 Removed site ID parameter and updated where criteria to use 
--                             sent to organization ID.
-- Stephen Long     12/16/2020 Changed join for vector surveillance session diseases to the sample
--                             table.
-- Stephen Long     12/31/2020 Change function on reference data to handle inactive records.
-- Stephen Long     09/25/2021 Added new pagination and order by.
-- Stephen Long     11/18/2021 Added sample ID and test ID parameters and action requested ID to 
--                             the query.
-- Stephen Long     12/08/2021 Changed pagination logic and removed option recompile.
-- Stephen Long     01/03/2022 Corrected sample status type to use the correct field.
-- Stephen Long     01/10/2022 Corrected join on user table, removed identity column, and changed 
--                             default sort order.
-- Stephen Long     02/03/2022 Corrected monitoring session to diagnosis join.
-- Stephen Long     02/10/2022 Removed unneeded joins on the disease fields.
-- Stephen Long     05/17/2022 Removed primary key from monitoring and vector session disease 
--                             table variables.
-- Stephen Long     05/20/2022 Added string agg to vector session diseases.
-- Stephen Long     07/26/2022 Updated case statement on disease id and name.
-- Stephen Long     09/28/2022 Added translated value for action requested name.
-- Stephen Long     10/11/2022 Added check for closed batch test status to display test records 
--                             ready for validation.
-- Stephen Long     10/21/2022 Added display disease names separated by comma.
-- Stephen Long     10/23/2022 Added check for non-laboratory test indicator of false.
-- Stephen Long     11/16/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/11/2023 Updated for site filtration queries.
-- Stephen Long     03/02/2023 Updated initial query where to use site ID instead of sent to 
--                             organization.
-- Stephen Long     03/23/2023 Correction on criteria for sent to organization and site ID.
-- ================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_LAB_APPROVAL_GETList]
(
    @LanguageID NVARCHAR(50),
    @SampleID BIGINT = NULL,
    @TestID BIGINT = NULL,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @UserSiteID BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Results TABLE
    (
        SampleID BIGINT NOT NULL,
        TestID BIGINT NULL
    );
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
	/*TODO: reapply permissions to sites
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
	*/
    DECLARE @TotalRowCount INT = 0,
            @LanguageCode BIGINT,
            @SampleDeletion NVARCHAR(MAX),
            @SampleDestruction NVARCHAR(MAX),
            @TestDeletion NVARCHAR(MAX),
            @Validation NVARCHAR(MAX);

    BEGIN TRY
	/*TODO: reapply permissions to sites
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
		*/

        SET @LanguageCode = dbo.FN_GBL_LanguageCode_Get(@LanguageID);
        SET @SampleDeletion =
        (
            SELECT COALESCE(rt.strResourceString, r.strResourceName)
            FROM dbo.trtResource r
                LEFT JOIN dbo.trtResourceTranslation rt
                    ON rt.idfsResource = r.idfsResource
                       AND rt.idfsLanguage = @LanguageCode
                       AND rt.intRowStatus = 0
            WHERE r.idfsResource = 812
        );
        SET @SampleDestruction =
        (
            SELECT COALESCE(rt.strResourceString, r.strResourceName)
            FROM dbo.trtResource r
                LEFT JOIN dbo.trtResourceTranslation rt
                    ON rt.idfsResource = r.idfsResource
                       AND rt.idfsLanguage = @LanguageCode
                       AND rt.intRowStatus = 0
            WHERE r.idfsResource = 1040
        );
        SET @TestDeletion =
        (
            SELECT COALESCE(rt.strResourceString, r.strResourceName)
            FROM dbo.trtResource r
                LEFT JOIN dbo.trtResourceTranslation rt
                    ON rt.idfsResource = r.idfsResource
                       AND rt.idfsLanguage = @LanguageCode
                       AND rt.intRowStatus = 0
            WHERE r.idfsResource = 4493
        );
        SET @Validation =
        (
            SELECT COALESCE(rt.strResourceString, r.strResourceName)
            FROM dbo.trtResource r
                LEFT JOIN dbo.trtResourceTranslation rt
                    ON rt.idfsResource = r.idfsResource
                       AND rt.idfsLanguage = @LanguageCode
                       AND rt.intRowStatus = 0
            WHERE r.idfsResource = 4492
        );

	/*TODO: remove
        INSERT INTO @MonitoringSessionDiseases
        SELECT MonitoringSessionID,
               STRING_AGG(DiseaseID, ',') AS DiseaseIdentifiers,
               STRING_AGG(DiseaseName, '|') AS DiseaseNames,
               REPLACE(STRING_AGG(DiseaseName, '|'), '|', ', ') AS DisplayDiseaseNames
        FROM dbo.FN_LAB_MONITORING_SESSION_DISEASES_GET(@LanguageID)
        GROUP BY MonitoringSessionID;

        INSERT INTO @VectorSessionDiseases
        SELECT VectorSurveillanceSessionID,
               STRING_AGG(DiseaseID, ',') AS DiseaseIdentifiers,
               STRING_AGG(DiseaseName, '|') AS DiseaseNames,
               REPLACE(STRING_AGG(DiseaseName, '|'), '|', ', ') AS DisplayDiseaseNames
        FROM dbo.FN_LAB_VECTOR_SESSION_DISEASES_GET(@LanguageID)
        GROUP BY VectorSurveillanceSessionID;
	*/

        INSERT INTO @Results
        SELECT m.idfMaterial,
               NULL
        FROM dbo.tlbMaterial m
        WHERE m.intRowStatus = 0
              AND m.idfsSampleStatus IN (   10015002, --Marked for Deletion 
                                            10015003
                                        ) --Marked for Destruction
              AND (
                     m.idfsCurrentSite = @UserSiteID
                  )
              AND (
                      m.idfMaterial = @SampleID
                      OR @SampleID IS NULL
                  );

        INSERT INTO @Results
        SELECT m.idfMaterial,
               t.idfTesting
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON t.idfMaterial = m.idfMaterial
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestStatus IN (   10001004, --Preliminary 
                                          10001008
                                      ) --Marked for Deletion
              AND (
                      t.idfBatchTest IS NULL
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus <> 10001001
                         ) -- Closed
                  )
              AND (
                     m.idfsCurrentSite = @UserSiteID
                  )
              AND (
                      t.idfTesting = @TestID
                      OR @TestID IS NULL
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
	/*TODO: reapply permissions to sites
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT m.idfMaterial
            FROM dbo.tlbMaterial m
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = m.idfsSite OR oa.idfsObjectID = m.idfsCurrentSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE m.intRowStatus = 0
                  AND oa.idfsObjectOperation = 10059003 -- Read permission
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = eg.idfEmployeeGroup
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.SampleID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = m.idfsSite OR ugsp.SiteID = m.idfsCurrentSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT m.idfMaterial
            FROM dbo.tlbMaterial m
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = m.idfsSite OR usp.SiteID = m.idfsCurrentSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );
		*/

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        SET @TotalRowCount =
        (
            SELECT COUNT(*) FROM @Results
        );

		INSERT INTO @MonitoringSessionDiseases
        SELECT	ms.idfMonitoringSession,
				STUFF(isnull(msDiseases.DiseaseIds, N','),1,1,N'') AS DiseaseIds,
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
			(	select	distinct N',' + cast(msd.idfsDiagnosis as nvarchar(20))
				from		dbo.tlbMonitoringSessionToDiagnosis msd
				join		dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
				on			diseaseName.idfsReference = msd.idfsDiagnosis
				where		msd.idfMonitoringSession = ms.idfMonitoringSession
							and msd.intRowStatus = ms.intRowStatus
				order by	N',' + cast(msd.idfsDiagnosis as nvarchar(20))
				for xml path('')
			) DiseaseIds
		) msDiseases
		where	exists
				(	select	1
					from	@Results res
					join	dbo.tlbMaterial m
					on		m.idfMaterial = res.SampleID
							and m.intRowStatus = 0
					where	m.idfMonitoringSession = ms.idfMonitoringSession
				)


        INSERT INTO @VectorSessionDiseases
        SELECT	vss.idfVectorSurveillanceSession,
				STUFF(isnull(vsDiseases.DiseaseIds, N','),1,1,N'') AS DiseaseIds,
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
				(	select	N',' + cast(d.idfsDiagnosis as nvarchar(20))
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
					order by	N',' + cast(d.idfsDiagnosis as nvarchar(20))
					for xml path('')
				) DiseaseIds
		) vsDiseases
		where	exists
				(	select	1
					from	@Results res
					join	dbo.tlbMaterial m
					on		m.idfMaterial = res.SampleID
							and m.intRowStatus = 0
					where	m.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
				)


        SELECT CASE
                   WHEN m.idfsSampleStatus = 10015002 --Marked for Deletion
            THEN
                       m.idfsSampleStatus
                   WHEN m.idfsSampleStatus = 10015003 --Marked for Destruction
            THEN
                       m.idfsSampleStatus
                   WHEN t.idfsTestStatus = 10001004 --Preliminary
            THEN
                       t.idfsTestStatus
                   WHEN t.idfsTestStatus = 10001008 --Marked for Deletion
            THEN
                       t.idfsTestStatus
               END AS ActionRequestedID,
               CASE
                   WHEN m.idfsSampleStatus = 10015002 --Marked for Deletion
               THEN
                       @SampleDeletion
                   WHEN m.idfsSampleStatus = 10015003 --Marked for Destruction
               THEN
                       @SampleDestruction
                   WHEN t.idfsTestStatus = 10001004 --Preliminary
               THEN
                       @Validation
                   WHEN t.idfsTestStatus = 10001008 --Marked for Deletion
               THEN
                       @TestDeletion
               END AS ActionRequested,
               m.idfMaterial AS SampleID,
               m.strBarcode AS EIDSSLaboratorySampleID,
               m.strCalculatedCaseID AS EIDSSReportOrSessionID,
               a.strAnimalCode AS EIDSSAnimalID,
               m.strCalculatedHumanName AS PatientOrFarmOwnerName,
               sampleType.name AS SampleTypeName,
			   coalesce(CAST(m.DiseaseID AS NVARCHAR(MAX)), msDiseases.DiseaseIdentifiers, vsDiseases.DiseaseIdentifiers, N'') AS DiseaseID,
			   coalesce(diseaseName.[name], msDiseases.DiseaseNames, vsDiseases.DiseaseNames, N'') AS DiseaseName,
			   coalesce(diseaseName.[name], msDiseases.DisplayDiseaseNames, vsDiseases.DisplayDiseaseNames, N'') AS DisplayDiseaseName,
               t.idfTesting AS TestID,
               t.idfsTestName AS TestNameTypeID,
               t.idfsTestCategory AS TestCategoryTypeID,
               t.idfsTestResult AS TestResultTypeID,
               t.idfsTestStatus AS TestStatusTypeID,
               testNameType.name AS TestNameTypeName,
               testStatusType.name AS TestStatusTypeName,
               testResultType.name AS TestResultTypeName,
               u.idfUserID AS ResultEnteredByUserID,
               m.datAccession AS AccessionDate,
               m.idfsSampleStatus AS SampleStatusTypeID,
               (CASE
                    WHEN m.blnAccessioned = 0
                         AND m.idfsAccessionCondition IS NULL THEN
                        'Un-accessioned'
                    WHEN (m.blnAccessioned = 1 and m.idfsSampleStatus IS NULL/*TODO: what is the case?*/) THEN
                        accessionConditionType.name
                    WHEN m.idfsSampleStatus = 10015007 --In Repository
               THEN
                        accessionConditionType.name
                    ELSE
                        sampleStatusType.name
                END
               ) AS AccessionConditionOrSampleStatusTypeName,
               t.datConcludedDate AS ResultDate,
               m.PreviousSampleStatusID AS PreviousSampleStatusTypeID,
               NULL AS PreviousTestStatusTypeID,
               m.intRowStatus AS RowStatus,
               0 AS RowAction,
               0 AS RowSelectionIndicator,
               @TotalRowCount AS TotalRowCount
        FROM @Results res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.SampleID
                   AND m.intRowStatus = 0
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                ON sampleType.idfsReference = m.idfsSampleType
            LEFT JOIN dbo.tlbTesting t
                ON t.idfTesting = res.TestID
                   AND t.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
                ON diseaseName.idfsReference = m.DiseaseID
            LEFT JOIN @MonitoringSessionDiseases msDiseases
                ON msDiseases.ID = m.idfMonitoringSession
            LEFT JOIN @VectorSessionDiseases vsDiseases
                ON vsDiseases.ID = m.idfVectorSurveillanceSession
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000110) accessionConditionType
                ON accessionConditionType.idfsReference = m.idfsAccessionCondition
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000015) sampleStatusType
                ON sampleStatusType.idfsReference = m.idfsSampleStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                ON testNameType.idfsReference = t.idfsTestName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                ON testStatusType.idfsReference = t.idfsTestStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                ON testResultType.idfsReference = t.idfsTestResult
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                ON testCategoryType.idfsReference = t.idfsTestCategory
            LEFT JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
            LEFT JOIN dbo.tstUserTable u
                ON u.idfPerson = t.idfResultEnteredByPerson
                   AND u.intRowStatus = 0
            OPTION (RECOMPILE);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
