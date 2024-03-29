SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================================
-- Name: USP_LAB_FAVORITE_GETList
--
-- Description:	Get laboratory favorites list for the various laboratory use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     10/20/2018 Initial release.
-- Stephen Long     12/19/2018 Added pagination logic.
-- Stephen Long     01/25/2019 Added intRowStatus check to where clause.
-- Stephen Long     01/30/2019 Added sample disease reference join and removed the vector 
--                             surveillance session joins as they are no longer needed.
-- Stephen Long     02/20/2019 Added disease ID to the select list.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     09/14/2019 Added pagination set 0 to bring back "all" records.
-- Stephen Long     10/20/2019 Added test assigned indicator and test name type ID to the list of 
--                             fields.
-- Stephen Long     01/15/2020 Added transfer ID to query.
-- Stephen Long     01/22/2020 Cleaned up stored procedure.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     04/23/2020 Correction on disease ID and disease name; add vector surveillance 
--                             session.
-- Stephen Long     04/26/2020 Added sent to organization ID to the model.
-- Stephen Long     06/06/2020 Added batch status type ID to the model.
-- Stephen Long     06/14/2020 Added action requested to the model.
-- Stephen Long     06/24/2020 Added test completed indicator to the model.
-- Stephen Long     11/29/2020 Added configurable site filtration rules.
-- Stephen Long     12/16/2020 Changed join for vector surveillance session diseases to the sample
--                             table.
-- Stephen Long     12/31/2020 Change function on reference data to handle inactive records.
-- Mark Wilson		08/16/2021 Join tlbMonitoringSessionToDiagnosis to get diagnosis
-- Stephen Long     09/25/2021 Added new pagination and order by.
-- Stephen Long     11/10/2021 Added sample ID parameter and where criteria.
-- Stephen Long     11/16/2021 Changed to use select row over instead of with cte.
-- Stephen Long     11/18/2021 Added action requested ID and previous test status type to the 
--                  query.
-- Stephen Long     12/14/2021 Added sample status date to the query.
-- Stephen Long     02/10/2022 Removed unneeded joins on the disease fields.
-- Stephen Long     03/10/2022 Added note field to the query.
-- Stephen Long     04/15/2022 Added join for favorites to the filtration queries.
-- Stephen Long     05/17/2022 Removed primary key from monitoring and vector session disease 
--                             table variables.
-- Stephen Long     05/20/2022 Added string agg to session diseases.
-- Stephen Long     07/26/2022 Updated case statement on disease id and name.
-- Stephen Long     10/21/2022 Added display disease names separated by comma.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/12/2023 Updated for site filtration queries.
-- Stephen Long     01/23/2023 Updated default sort order.
-- Stephen Long     03/29/2023 Added default rule check for configurable filtration.
--
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_LAB_FAVORITE_GETList]
		@LanguageID = N'en-US',
		@UserID = 161287150000872, --rykermase
		@UserEmployeeID = 420664190000872,
		@UserSiteID = 864,
		@UserOrganizationID = 758210000000,
		@UserSiteGroupID = NULL,
		@Page = 1,
		@PageSize = 10,
		@SortColumn = N'EIDSSLaboratorySampleID',
		@SortOrder = N'DESC'

SELECT	'Return Value' = @return_value

GO
*/
-- ================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_LAB_FAVORITE_GETList]
(
    @LanguageID NVARCHAR(50),
    @SampleID BIGINT = NULL,
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
        ID BIGINT NOT NULL PRIMARY KEY,
        DiseaseIdentifiers VARCHAR(MAX) NOT NULL,
        DiseaseNames NVARCHAR(MAX) NOT NULL,
        DisplayDiseaseNames NVARCHAR(MAX) NOT NULL
    );
    DECLARE @VectorSessionDiseases TABLE
    (
        ID BIGINT NOT NULL PRIMARY KEY,
        DiseaseIdentifiers VARCHAR(MAX) NOT NULL,
        DiseaseNames NVARCHAR(MAX) NOT NULL,
        DisplayDiseaseNames NVARCHAR(MAX) NOT NULL
    );
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
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
    DECLARE @Favorites XML;

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

        SET @Favorites =
        (
            SELECT PreferenceDetail
            FROM dbo.UserPreference Laboratory
            WHERE idfUserID = @UserID
                  AND ModuleConstantID = 10508006
                  AND intRowStatus = 0
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

 	/*TODO: remove
       INSERT INTO @Results
        SELECT m.idfMaterial,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbMaterial m
            INNER JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'BIGINT')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
        WHERE m.intRowStatus = 0
              AND (
                      m.idfMaterial = @SampleID
                      OR @SampleID IS NULL
                  );
	*/

        -- =======================================================================================
        -- CONFIGURABLE FILTRATION RULES ARE NOT NEEDED

        -- =======================================================================================


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
                    ON oa.idfsObjectID = m.idfsSite
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

        --
        -- Apply level 1 site filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = m.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003 -- Read permission
              AND NOT EXISTS (
                              SELECT * FROM @UserSitePermissions WHERE SiteID = m.idfsSite
              );

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT m.idfMaterial
            FROM dbo.tlbMaterial m
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = m.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );
		*/

        INSERT INTO @FinalResults
        SELECT distinct
			   m.idfMaterial,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbMaterial m
            INNER JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'BIGINT')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
        WHERE m.intRowStatus = 0
              AND (
                      m.idfMaterial = @SampleID
                      OR @SampleID IS NULL
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
					from	@FinalResults res
					join	dbo.tlbMaterial m
					on		m.idfMaterial = res.[ID]
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
					from	@FinalResults res
					join	dbo.tlbMaterial m
					on		m.idfMaterial = res.[ID]
					where	m.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
				)

        DECLARE @FavoriteCount AS INT = (
                                            SELECT COUNT(*)
                                            FROM @FinalResults
                                        );

        SELECT m.idfMaterial AS SampleID,
               m.idfsSite AS SiteID,
               m.idfsCurrentSite AS CurrentSiteID,
               t.idfTesting AS TestID,
               tom.idfTransferOut AS TransferID,
               m.strCalculatedCaseID AS EIDSSReportOrSessionID,
               m.strCalculatedHumanName AS PatientOrFarmOwnerName,
               m.idfsSampleType AS SampleTypeID,
               sampleType.name AS SampleTypeName,
			   coalesce(CAST(m.DiseaseID AS NVARCHAR(MAX)), msDiseases.DiseaseIdentifiers, vsDiseases.DiseaseIdentifiers, N'') AS DiseaseID,
			   coalesce(diseaseName.[name], msDiseases.DiseaseNames, vsDiseases.DiseaseNames, N'') AS DiseaseName,
			   coalesce(diseaseName.[name], msDiseases.DisplayDiseaseNames, vsDiseases.DisplayDiseaseNames, N'') AS DisplayDiseaseName,
               m.idfRootMaterial AS RootSampleID,
               m.idfParentMaterial AS ParentSampleID,
               m.strBarcode AS EIDSSLaboratorySampleID,
               m.strFieldBarcode AS EIDSSLocalOrFieldSampleID,
               m.datFieldCollectionDate AS CollectionDate,
               m.idfFieldCollectedByPerson AS CollectedByPersonID,
               m.idfFieldCollectedByOffice AS CollectedByOrganizationID,
               m.datFieldSentDate AS SentDate,
               m.idfSendToOffice AS SentToOrganizationID,
               t.idfsTestName AS TestNameTypeID,
               testNameType.name AS TestNameTypeName,
               t.idfsTestStatus AS TestStatusTypeID,
               testStatusType.name AS TestStatusTypeName,
               t.datStartedDate AS StartedDate,
               t.idfsTestResult AS TestResultTypeID,
               testResultType.name AS TestResultTypeName,
               t.datConcludedDate AS ResultDate,
               t.idfsTestCategory AS TestCategoryTypeID,
               testCategoryType.name AS TestCategoryTypeName,
               m.blnAccessioned AS AccessionIndicator,
               m.datAccession AS AccessionDate,
               m.idfInDepartment AS FunctionalAreaID,
               functionalArea.name AS FunctionalAreaName,
               m.idfSubdivision AS FreezerSubdivisionID,
               m.StorageBoxPlace,
               m.datEnteringDate AS EnteredDate,
               m.datOutOfRepositoryDate AS OutOfRepositoryDate,
               m.idfMarkedForDispositionByPerson AS MarkedForDispositionByPersonID,
               m.blnReadOnly AS ReadOnlyIndicator,
               m.idfsAccessionCondition AS AccessionConditionTypeID,
               m.idfsSampleStatus AS SampleStatusTypeID,
               CASE
                   WHEN m.blnAccessioned = 0
                        AND m.idfsSampleStatus IS NULL
                        AND m.idfsAccessionCondition IS NULL THEN
                       'Un-accessioned'
                   WHEN m.idfsSampleStatus IS NULL THEN
                       accessionConditionType.name
                   WHEN m.idfsSampleStatus = 10015007 --In Repository
               THEN
                       accessionConditionType.name
                   ELSE
                       sampleStatusType.name
               END AS AccessionConditionOrSampleStatusTypeName,
               m.idfAccesionByPerson AS AccessionedInByPersonID,
               m.datSampleStatusDate AS SampleStatusDate,
               m.strCondition AS AccessionComment,
               m.strNote AS Comment,
               a.strAnimalCode AS EIDSSAnimalID,
               m.idfsBirdStatus AS BirdStatusTypeID,
               m.idfMainTest AS MainTestID,
               m.idfsSampleKind AS SampleKindTypeID,
               b.idfsBatchStatus AS BatchStatusTypeID,
               ISNULL(TestNotCompleted.blnExists, 0) AS TestAssignedIndicator,
               CASE
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
                       'Sample Deletion'
                   WHEN m.idfsSampleStatus = 10015003 --Marked for Destruction
               THEN
                       'Sample Destruction'
                   WHEN t.idfsTestStatus = 10001004 --Preliminary
               THEN
                       'Validation'
                   WHEN t.idfsTestStatus = 19000502 --Marked for Deletion
               THEN
                       'Test Deletion'
               END AS ActionRequested,
               ISNULL(TestCompleted.blnExists, 0) AS TestCompletedIndicator,
               m.PreviousSampleStatusID AS PreviousSampleStatusTypeID,
               t.PreviousTestStatusID AS PreviousTestStatusTypeID,
               m.LabModuleSourceIndicator,
               m.idfHumanCase AS HumanDiseaseReportID,
               m.idfVetCase AS VeterinaryDiseaseReportID,
               m.idfMonitoringSession AS MonitoringSessionID,
               m.idfVectorSurveillanceSession AS VectorSessionID,
               m.idfVector AS VectorID,
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
               COUNT(*) OVER () AS TotalRowCount,
               @FavoriteCount AS FavoriteCount
        FROM @FinalResults res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.ID
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                ON sampleType.idfsReference = m.idfsSampleType
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfMaterial = m.idfMaterial
                   AND tom.intRowStatus = 0
            LEFT JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
                ON diseaseName.idfsReference = m.DiseaseID
            LEFT JOIN @MonitoringSessionDiseases msDiseases
                ON msDiseases.ID = m.idfMonitoringSession
            LEFT JOIN @VectorSessionDiseases vsDiseases
                ON vsDiseases.ID = m.idfVectorSurveillanceSession
            LEFT JOIN dbo.tlbDepartment d
                ON d.idfDepartment = m.idfInDepartment
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164) functionalArea
                ON functionalArea.idfsReference = d.idfsDepartmentName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                ON testNameType.idfsReference = t.idfsTestName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                ON testStatusType.idfsReference = t.idfsTestStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                ON testResultType.idfsReference = t.idfsTestResult
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                ON testCategoryType.idfsReference = t.idfsTestCategory
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000110) accessionConditionType
                ON accessionConditionType.idfsReference = m.idfsAccessionCondition
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000015) sampleStatusType
                ON sampleStatusType.idfsReference = m.idfsSampleStatus
			outer apply
			(
                SELECT top 1 cast(1 as bit) as blnExists
                FROM dbo.tlbTesting t3
                WHERE t3.idfsTestStatus IN (   10001003,
                                                        --In Progress
                                                10001004 --Preliminary
                                            )
                        AND t3.idfMaterial = m.idfMaterial
                        AND t3.intRowStatus = 0
                        AND t3.blnNonLaboratoryTest = 0
			) TestNotCompleted
			outer apply
			(
                SELECT top 1 cast(1 as bit) as blnExists
                FROM dbo.tlbTesting t2
                WHERE t2.idfsTestStatus IN (   10001001,
                                                        --Final
                                                10001006 --Amended
                                            )
                        AND t2.idfMaterial = m.idfMaterial
                        AND t2.intRowStatus = 0
                        AND t2.blnNonLaboratoryTest = 0
			) TestCompleted
            ORDER BY m.blnAccessioned,
                     m.idfsSampleStatus DESC,
                     m.idfsAccessionCondition,
                     COALESCE(m.datAccession, m.datFieldCollectionDate, m.datEnteringDate) DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
