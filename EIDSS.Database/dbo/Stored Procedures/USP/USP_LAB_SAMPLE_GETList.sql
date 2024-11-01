SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================================
-- Name: USP_LAB_SAMPLE_GETList
--
-- Description:	Get sample list for the laboratory module use case LUC01.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     07/18/2018 Initial release.
-- Stephen Long	    12/19/2018 Added pagination logic.
-- Stephen Long     01/14/2019 Split out search functionality (where conditions) for better 
--                             performance on this procedure.
-- Stephen Long     01/30/2019 Added sample disease reference join and removed the vector 
--                             surveillance session joins as they are no longer needed.
-- Stephen Long     02/11/2019 Fix to the value used for the test completed indicator.  It was 
--                             using the wrong base reference value.
-- Stephen Long     02/21/2019 Changed field collection and field sent to collection and sent to 
--                             be consistent on naming.  Added parent sample ID to support the 
--                             edit transfer use case.
-- Stephen Long     03/28/2019 Removed test status 'Not Started' as criteria for the test assigned 
--                             indicator and test assigned count.
-- Stephen Long     06/22/2019 Removal of herd join and joined species on the sample table.
-- Stephen Long     07/01/2019 Corrected reference type on monitoring session category.
-- Stephen Long     07/09/2019 Added human master ID to select as placeholder for model.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     07/17/2019 Added vector join and field vector ID to the patient/species/vector.
-- Stephen Long     07/28/2019 Corrected sample kind ID where clause for aliquots/derivatives.
-- Stephen Long     08/12/2019 Corrected parenthesis for POCO error on sample kind where clause.
-- Stephen Long     08/30/2019 Removed commented out IF ELSE for individual sample.
-- Stephen Long     09/11/2019 Added sample destroyed status to sample status where clause.  Added 
--                             pagination set 0 to bring back "all" records.
-- Stephen Long     09/26/2019 Added sample list parameter and where clause.
-- Stephen Long     10/03/2019 Added comma to split sample list delimeter.
-- Stephen Long     10/17/2019 Added intRowStatus and non-laboratory test check on test completed 
--                             and test assigned indicators, and test assigned count.
-- Stephen Long     01/21/2020 Converted site ID to site list for site filtration.
-- Stephen Long     02/19/2020 Corrected left joins needing intRowStatus = 0.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     03/16/2020 Added sample status type of transferred out to include in the list.
-- Stephen Long     04/16/2020 Correction on vector surveillance session disease ID's and names.
-- Stephen Long     04/20/2020 Added vector type ID and vector species type ID to the model.
-- Stephen Long     05/05/2020 Added transfer status type ID of final when sample status type ID 
--                             is transferred out.
-- Stephen Long     06/21/2020 Added additional criteria to show samples with a final or amended 
--                             test to be selected within the accession timeframe.
-- Stephen Long     06/30/2020 Added additional criteria to pull back transferred in records after
--                             accessioned in.
-- Stephen Long     07/06/2020 Added lab module source indicator to model.
-- Stephen Long     10/27/2020 Removed test assigned indicator, and split out queries for better 
--                             performance.
-- Stephen Long     10/29/2020 Added test unassigned and test completed parameters and where 
--                             criteria.
-- Stephen Long     10/31/2020 Correct disease report/session query where criteria; prevent dups.
-- Stephen Long     11/28/2020 Added configurable site filtration rules.
-- Stephen Long     12/15/2020 Changed join for vector surveillance session diseases to the sample
--                             table.
-- Stephen Long     12/31/2020 Correct record and unaccessioned counts.
-- Stephen Long     01/21/2021 Change counts from distinct count to group by with sub-query.
-- Stephen Long     02/08/2021 Change where criteria to handle null organization for the central
--                             data repository.
-- Stephen Long     06/28/2021 Applied new pagination parameters.
-- Mark Wilson		08/11/2021 updated to join tlbMonitoringSessionToDiagnosis
-- Stephen Long     09/18/2021 Removed unneeded fields and joins to improve performance.
-- Stephen Long     12/14/2021 Added sample status date to the query.
-- Stephen Long     02/03/2022 Corrected monitoring session to diagnosis join.
-- Stephen Long     02/07/2022 Removed unneeded joins on the disease fields.
-- Stephen Long     02/17/2022 Fix on where criteria for test status types.
-- Stephen Long     03/10/2022 Changed note to comment and transfer count to transferred count.
-- Stephen Long     03/24/2022 Added final results table variable to account for duplicates that 
--                             may return from filtration rules.
-- Stephen Long     04/15/2022 Fix to filtration query grouping.
-- Stephen Long     05/17/2022 Removed primary key from monitoring and vector session disease 
--                             table variables.
-- Stephen Long     05/20/2022 Added string agg to session diseases.
-- Stephen Long     05/23/2022 Added check on testing table to only look for laboratory tests and
--                             rejected samples check within sample window.
-- Stephen Long     06/20/2022 Added row status check when looking for parent samples.
-- Stephen Long     06/28/2022 Added check to include transferred out samples only when the 
--                             transfer is final and within the accession date window.
-- Stephen Long     07/26/2022 Updated case statement on disease id and name.
-- Stephen Long     08/17/2022 Added collection and entered date to the default sort order.
-- Stephen Long     09/21/2022 Removed test status types of final and amended from the in 
--                             repository samples within the accession date window check.  Changed 
--                             rejected samples to use collection date or entered date against the 
--                             date window (number of days for samples to stay in the list).
-- Stephen Long     10/04/2022 Bug fix on item 5057; don't show marked for deletion or marked 
--                             for destruction in the default listing.
-- Stephen Long     10/21/2022 Added display disease names separated by comma.
-- Stephen Long     11/03/2022 Added date to the table variable to store the collection date, if 
--                             available, otherwise entered date.  Sort order for default base on 
--                             this new date field.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/03/2023 Added check for user's site identifier when the sent to organization 
--                             is not present.
-- Stephen Long     01/10/2023 Updated for site filtration queries.
-- Stephen Long     02/07/2023 Fix for rejected samples - bug 5610.
-- Stephen Long     03/02/2023 Added sent to organization sent to site ID and where criteria.
-- Stephen Long     03/09/2023 Added filtration indicator logic.
-- Stephen Long     03/29/2023 Added default rule check for configurable filtration.
-- Stephen Long     04/12/2023 Fix for 5818 and 5819.
-- 
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_LAB_SAMPLE_GETList]
		@LanguageID = N'en-US',
		@SampleID = NULL,
		@ParentSampleID = NULL,
		@DaysFromAccessionDate = 60,
		@SampleList = NULL,
		@TestUnassignedIndicator = NULL,
		@TestCompletedIndicator = NULL,
		@UserID = 161287150000872, --rykermase
		@UserEmployeeID = 420664190000872,
		@UserSiteID = 864,
		@UserOrganizationID = 758210000000,
		@UserSiteGroupID = NULL,
		@Page = 1,
		@PageSize = 100,
		@SortColumn = N'AccessionDate',
		@SortOrder = N'ASC'

SELECT	'Return Value' = @return_value

GO
*/
-- ================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_LAB_SAMPLE_GETList]
(
    @LanguageID NVARCHAR(50),
    @SampleID BIGINT = NULL,
    @ParentSampleID BIGINT = NULL,
    @DaysFromAccessionDate INT,
    @SampleList VARCHAR(MAX) = NULL,
    @TestUnassignedIndicator BIT = NULL,
    @TestCompletedIndicator BIT = NULL,
    @FiltrationIndicator BIT = 1, 
    @UserID BIGINT,
    @UserEmployeeID BIGINT,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT = NULL,
    @UserSiteGroupID BIGINT = NULL,
    @SortColumn VARCHAR(200) = 'Default'
)
AS
BEGIN
    SET NOCOUNT ON;

	declare @DFrom datetime, @DTo datetime
	set @DTo = GETDATE()
	set	@DFrom = dateadd(day, -isnull(@DaysFromAccessionDate, 15), cast(@DTo as date))

    DECLARE @UnaccessionedCount INT = 0,
            @TotalRowCount INT = 0;
			--TODO: replace variable tables with temporary tables or functions if needed
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
        AccessionedIndicator BIT NOT NULL,
        AccessionConditionTypeID BIGINT NULL,
        DestructionDate DATETIME NULL, 
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
        AccessionedIndicator BIT NOT NULL,
        AccessionConditionTypeID BIGINT NULL,
        DestructionDate DATETIME NULL, 
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
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
    DECLARE @SampleListTable TABLE (ID BIGINT NOT NULL);
	/*		--TODO: Reapply Permissions to sites
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

    IF @SampleList IS NOT NULL
        INSERT INTO @SampleListTable
        SELECT CAST([Value] AS BIGINT)
        FROM dbo.FN_GBL_SYS_SplitList(@SampleList, NULL, ',')

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

        SET @Favorites =
        (
            SELECT PreferenceDetail
            FROM dbo.UserPreference Laboratory
            WHERE idfUserID = @UserID
                  AND ModuleConstantID = 10508006
                  AND intRowStatus = 0
        );

        IF @SampleID IS NOT NULL
           OR @SampleList IS NOT NULL
           OR @ParentSampleID IS NOT NULL
        BEGIN
            INSERT INTO @FinalResults
            SELECT m.idfMaterial,
                   m.blnAccessioned,
                   m.idfsAccessionCondition,
                   m.datDestructionDate,
                   1,
               CASE
                   WHEN m.idfsSite = @UserSiteID OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN m.idfsSite = @UserSiteID OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN m.idfsSite = @UserSiteID OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN m.idfsSite = @UserSiteID OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END
            FROM dbo.tlbMaterial m
            WHERE m.intRowStatus = 0
                  AND (
                          @SampleList IS NULL
                          OR exists (
                              SELECT 1 FROM @SampleListTable slt where slt.[ID] = m.idfMaterial
                                    )
                      )
                  AND (
                          @SampleID IS NULL
                          OR m.idfMaterial = @SampleID
                      )
                  AND (
                          @ParentSampleID IS NULL
                          OR m.idfParentMaterial = @ParentSampleID
                      );
        END
        ELSE
        BEGIN
            INSERT INTO @Results
            SELECT m.idfMaterial,
                   m.blnAccessioned,
                   m.idfsAccessionCondition,
                   m.datDestructionDate,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbMaterial m
            WHERE m.intRowStatus = 0
                  AND m.blnReadOnly = 0
                  AND m.idfsSampleType <> 10320001 -- Unknown
                  AND (
                          (
                              /*m.idfSendToOffice = @UserOrganizationID
                              AND*/ m.idfsCurrentSite = @UserSiteID
                              AND m.datAccession >= @DFrom
                              AND m.TestUnassignedIndicator = 1
                              AND @TestUnassignedIndicator IS NOT NULL
                              AND m.blnAccessioned = 1
                              --AND m.datAccession IS NOT NULL
                              AND m.strBarcode IS NOT NULL 
                              AND (m.idfsAccessionCondition IS NOT NULL AND m.idfsAccessionCondition <> 10108003) -- Rejected
                              AND m.idfsSampleStatus = 10015007 -- In Repository
                          )
                          OR (
                                 /*m.idfSendToOffice = @UserOrganizationID
                                 AND*/ m.idfsCurrentSite = @UserSiteID
	                             AND m.datAccession >= @DFrom
                                 AND m.TestCompletedIndicator = 1
                                 AND (m.idfsAccessionCondition IS NOT NULL AND m.idfsAccessionCondition <> 10108003) -- Rejected
                                 AND @TestCompletedIndicator IS NOT NULL
                             )
                          OR (
                                 m.blnAccessioned = 0
                                 AND m.idfsAccessionCondition IS NULL
                                 AND m.idfsSampleStatus IS NULL
                                 and m.datDestructionDate IS NULL 
                                 AND m.idfSendToOffice = @UserOrganizationID 
								 AND	(	m.datFieldCollectionDate >= @DFrom
											OR	(	m.datFieldCollectionDate is null
													and m.datEnteringDate >= @DFrom
												)
										)
                                 AND @TestCompletedIndicator IS NULL
                                 AND @TestUnassignedIndicator IS NULL
                             )
                          OR ( -- Accessioned in with no in progress, preliminary tests assigned, deleted or destroyed
                                 /*m.idfSendToOffice = @UserOrganizationID
                                 AND*/ m.idfsCurrentSite = @UserSiteID
                                 AND (m.TestUnassignedIndicator = 1 OR m.TestCompletedIndicator = 1)
                                 AND (	(	m.idfsSampleStatus IN (10015007, 10015008)-- In Repository, Deleted--TODO: Remove???
											AND m.datAccession >= @DFrom
										)
										OR	(	m.idfsSampleStatus = 10015009-- Destroyed
												and m.datDestructionDate >= @DFrom
											)
									)
                                 AND @TestUnassignedIndicator IS NULL
                                 AND @TestCompletedIndicator IS NULL
                             )
                          OR (
                                 /*m.idfSendToOffice = @UserOrganizationID
                                 AND*/ m.idfsCurrentSite = @UserSiteID
								 AND m.datOutOfRepositoryDate >= @DFrom
                                 AND m.idfsSampleStatus = 10015010 -- Transferred Out
                                 AND not exists
                                 (
                                     SELECT 1
                                     FROM dbo.tlbTransferOutMaterial tom
                                         INNER JOIN dbo.tlbTransferOUT tr
                                             ON tr.idfTransferOut = tom.idfTransferOut
                                     WHERE tom.idfMaterial = m.idfMaterial
                                           AND tr.intRowStatus = 0
                                           AND tr.idfsTransferStatus = 10001003 -- Final
                                 )
                                 AND @TestCompletedIndicator IS NULL
                                 AND @TestUnassignedIndicator IS NULL
                             ) -- Transferred Out and Final
                          OR (
                                 /*m.idfSendToOffice = @UserOrganizationID
                                 AND*/ m.idfsCurrentSite = @UserSiteID
								 AND (	m.datDestructionDate >= @DFrom
										--TODO: Remove when verified non-blank datDestructionDate for Rejected Samples
										OR	(	m.datDestructionDate is null
												and m.datAccession >= @DFrom
											)
									 )
                                 AND m.idfsAccessionCondition = 10108003 -- Rejected Sample
                                 AND @TestCompletedIndicator IS NULL
                                 AND @TestUnassignedIndicator IS NULL
                             )
                      );
        END

        -- =======================================================================================
        -- CONFIGURABLE FILTRATION RULES
        -- 
        -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
        -- overlap the non-configurable rules.
        -- =======================================================================================
        --
        -- Apply at the user's site group level, granted by a site group.
        --
        IF @UserOrganizationID IS NOT NULL --First-level sites (central data repository, general data repository, etc.) do not filter results.
        BEGIN
            INSERT INTO @Results
            SELECT m.idfMaterial,
                   m.blnAccessioned,
                   m.idfsAccessionCondition,
                   m.datDestructionDate,
                   ar.ReadPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ar.DeletePermissionIndicator
            FROM dbo.tlbMaterial m
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = m.idfsSite
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
            WHERE m.intRowStatus = 0
                  AND @UserSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT m.idfMaterial,
                   m.blnAccessioned,
                   m.idfsAccessionCondition,
                   m.datDestructionDate,
                   ar.ReadPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ar.DeletePermissionIndicator
            FROM dbo.tlbMaterial m
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = m.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule ar
                    ON ar.AccessRuleID = ara.AccessRuleID
                       AND ar.intRowStatus = 0
                       AND ar.DefaultRuleIndicator = 0
            WHERE m.intRowStatus = 0
                  AND ar.GrantingActorSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT m.idfMaterial,
                   m.blnAccessioned,
                   m.idfsAccessionCondition,
                   m.datDestructionDate,
                   ar.ReadPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ar.DeletePermissionIndicator
            FROM dbo.tlbMaterial m
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = m.idfsSite
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
            WHERE m.intRowStatus = 0
                  AND ar.GrantingActorSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT m.idfMaterial,
                   m.blnAccessioned,
                   m.idfsAccessionCondition,
                   m.datDestructionDate,
                   ar.ReadPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ar.DeletePermissionIndicator
            FROM dbo.tlbMaterial m
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = m.idfsSite
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
            WHERE m.intRowStatus = 0
                  AND ar.GrantingActorSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @Results
            SELECT m.idfMaterial,
                   m.blnAccessioned,
                   m.idfsAccessionCondition,
                   m.datDestructionDate,
                   ar.ReadPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ar.DeletePermissionIndicator
            FROM dbo.tlbMaterial m
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfSiteGroup = @UserSiteGroupID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule ar
                    ON ar.AccessRuleID = ara.AccessRuleID
                       AND ar.intRowStatus = 0
                       AND ar.DefaultRuleIndicator = 0
            WHERE m.intRowStatus = 0
                  AND @UserSiteGroupID IS NOT NULL
                  AND sgs.idfsSite = m.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @Results
            SELECT m.idfMaterial,
                   m.blnAccessioned,
                   m.idfsAccessionCondition,
                   m.datDestructionDate,
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
                INNER JOIN dbo.tlbMaterial m
                    ON m.intRowStatus = 0
            WHERE ar.GrantingActorSiteID IS NOT NULL
                  AND ar.DefaultRuleIndicator = 0
                  AND m.idfsSite = ar.GrantingActorSiteID;

            DECLARE @UserEmployeeGroupID BIGINT = (
                                                      SELECT TOP 1
                                                          egm.idfEmployeeGroup
                                                      FROM dbo.tlbEmployeeGroupMember egm
                                                      WHERE egm.idfEmployee = @UserEmployeeID
                                                            AND egm.intRowStatus = 0
                                                  );

            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @Results
            SELECT m.idfMaterial,
                   m.blnAccessioned,
                   m.idfsAccessionCondition,
                   m.datDestructionDate,
                   ar.ReadPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ar.DeletePermissionIndicator
            FROM dbo.AccessRuleActor ara
                INNER JOIN dbo.AccessRule ar
                    ON ar.AccessRuleID = ara.AccessRuleID
                       AND ar.intRowStatus = 0
                       AND ar.DefaultRuleIndicator = 0
                       AND ar.GrantingActorSiteID IS NOT NULL
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfsSite = ar.GrantingActorSiteID
                       AND m.intRowStatus = 0
            WHERE ara.ActorEmployeeGroupID = @UserEmployeeGroupID
                  AND ara.intRowStatus = 0;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @Results
            SELECT m.idfMaterial,
                   m.blnAccessioned,
                   m.idfsAccessionCondition,
                   m.datDestructionDate,
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
                INNER JOIN dbo.tlbMaterial m
                    ON m.intRowStatus = 0
            WHERE ar.GrantingActorSiteID IS NOT NULL
                  AND ar.DefaultRuleIndicator = 0
                  AND m.idfsSite = ar.GrantingActorSiteID;
        END;

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        /*
		--TODO: Reapply Permissions to sites
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

        IF @SortColumn <> 'Query'
        BEGIN
            INSERT INTO @FinalResults
            SELECT res.ID,
                   res.AccessionedIndicator,
                   MAX(res.AccessionConditionTypeID),
                   MAX(res.DestructionDate), 
                   MAX(res.ReadPermissionIndicator),
                   MAX(res.AccessToPersonalDataPermissionIndicator),
                   MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
                   MAX(res.WritePermissionIndicator),
                   MAX(res.DeletePermissionIndicator)
            FROM @Results res
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = res.ID
                                      AND m.intRowStatus = 0
            WHERE (res.ReadPermissionIndicator IN ( 1, 3, 5 )
                  AND m.blnReadOnly = 0
                  AND m.idfsSampleType <> 10320001 -- Unknown
                  AND (
                          (
                              m.datAccession >= @DFrom
                              AND m.TestUnassignedIndicator = 1
                              AND @TestUnassignedIndicator IS NOT NULL
                              AND m.blnAccessioned = 1
                              AND m.datAccession IS NOT NULL
                              AND m.strBarcode IS NOT NULL 
                              AND m.idfsAccessionCondition IS NOT NULL
                              AND m.idfsSampleStatus = 10015007 -- In Repository
                          )
                          OR (
                                 m.datAccession >= @DFrom
                                 AND m.TestCompletedIndicator = 1
                                 AND @TestCompletedIndicator IS NOT NULL
                             )
                          OR (
                                 m.blnAccessioned = 0
								 AND	(	m.datFieldCollectionDate >= @DFrom
											OR	(	m.datFieldCollectionDate is null
													and m.datEnteringDate >= @DFrom
												)
										)
                                 AND m.idfsAccessionCondition IS NULL
                                 AND m.idfsSampleStatus IS NULL
                                 and m.datDestructionDate IS NULL 
                                 AND @TestCompletedIndicator IS NULL
                                 AND @TestUnassignedIndicator IS NULL
                             )
                          OR ( -- Accessioned in with no in progress, preliminary tests assigned, deleted or destroyed
                                 (m.TestUnassignedIndicator = 1 OR m.TestCompletedIndicator = 1)
                                 AND (	(	m.idfsSampleStatus IN (10015007, 10015008)-- In Repository, Deleted--TODO: Remove???
											AND m.datAccession >= @DFrom
										)
										OR	(	m.idfsSampleStatus = 10015009-- Destroyed
												and m.datDestructionDate >= @DFrom
											)
									)
                                 AND @TestUnassignedIndicator IS NULL
                                 AND @TestCompletedIndicator IS NULL
                             )
                          OR (
                                 m.datOutOfRepositoryDate >= @DFrom
                                 AND m.idfsSampleStatus = 10015010 -- Transferred Out
                                 AND not exists
                                 (
                                     SELECT 1
                                     FROM dbo.tlbTransferOutMaterial tom
                                         INNER JOIN dbo.tlbTransferOUT tr
                                             ON tr.idfTransferOut = tom.idfTransferOut
                                     WHERE tom.idfMaterial = m.idfMaterial
                                           AND tr.intRowStatus = 0
                                           AND tr.idfsTransferStatus = 10001003 -- Final
                                 )
                                 AND @TestCompletedIndicator IS NULL
                                 AND @TestUnassignedIndicator IS NULL
                             ) -- Transferred Out and Final
                          OR (
								 (	m.datDestructionDate >= @DFrom
									--TODO: Remove when verified non-blank datDestructionDate for Rejected Samples
									OR	(	m.datDestructionDate is null
											and m.datAccession >= @DFrom
										)
								 )
                                 AND @TestCompletedIndicator IS NULL
                                 AND @TestUnassignedIndicator IS NULL
                                 AND m.idfsAccessionCondition = 10108003 -- Rejected Sample
                             )
                      )
                      )
            GROUP BY res.ID, 
                     res.AccessionedIndicator;
        END

        SET @TotalRowCount =
        (
            SELECT COUNT(ID) FROM @FinalResults
        );
        SET @UnaccessionedCount =
        (
            SELECT COUNT(ID)
            FROM @FinalResults
            WHERE AccessionedIndicator = 0
                  AND AccessionConditionTypeID IS NULL
                  AND DestructionDate IS NULL 
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

        SELECT m.idfMaterial AS SampleID,
               m.strBarcode AS EIDSSLaboratorySampleID,
               CASE
                   WHEN f.SampleID IS NULL THEN
                       0
                   ELSE
                       1
               END AS FavoriteIndicator,
               m.idfRootMaterial AS RootSampleID,
               m.idfParentMaterial AS ParentSampleID,
               m.idfsSampleType AS SampleTypeID,
               sampleType.name AS SampleTypeName,
               m.idfHuman AS HumanID,
               m.strCalculatedHumanName AS PatientOrFarmOwnerName,
               m.idfSpecies AS SpeciesID,
               m.idfAnimal AS AnimalID,
               a.strAnimalCode AS EIDSSAnimalID,
               m.idfVector AS VectorID,
               m.idfMonitoringSession AS MonitoringSessionID,
               m.idfVectorSurveillanceSession AS VectorSessionID,
               m.idfHumanCase AS HumanDiseaseReportID,
               m.idfVetCase AS VeterinaryDiseaseReportID,
               m.strCalculatedCaseID AS EIDSSReportOrSessionID,
               '' AS ReportOrSessionTypeName,
               m.TestCompletedIndicator,
			   coalesce(CAST(m.DiseaseID AS NVARCHAR(MAX)), msDiseases.DiseaseIdentifiers, vsDiseases.DiseaseIdentifiers, N'') AS DiseaseID,
			   coalesce(diseaseName.[name], msDiseases.DiseaseNames, vsDiseases.DiseaseNames, N'') AS DiseaseName,
			   coalesce(diseaseName.[name], msDiseases.DisplayDiseaseNames, vsDiseases.DisplayDiseaseNames, N'') AS DisplayDiseaseName,
               m.idfInDepartment AS FunctionalAreaID,
               functionalArea.name AS FunctionalAreaName,
               m.idfSubdivision AS FreezerSubdivisionID,
               m.StorageBoxPlace,
               m.datFieldCollectionDate AS CollectionDate,
               m.idfFieldCollectedByPerson AS CollectedByPersonID,
               m.idfFieldCollectedByOffice AS CollectedByOrganizationID,
               m.datFieldSentDate AS SentDate,
               m.idfSendToOffice AS SentToOrganizationID,
               m.idfsSite AS SiteID,
               m.strFieldBarcode AS EIDSSLocalOrFieldSampleID,
               m.datEnteringDate AS EnteredDate,
               m.datOutOfRepositoryDate AS OutOfRepositoryDate,
               m.idfMarkedForDispositionByPerson AS MarkedForDispositionByPersonID,
               m.blnReadOnly AS ReadOnlyIndicator,
               m.blnAccessioned AS AccessionIndicator,
               m.datAccession AS AccessionDate,
               m.idfsAccessionCondition AS AccessionConditionTypeID,
               CASE
                   WHEN m.blnAccessioned = 0
                        AND m.idfsAccessionCondition IS NULL THEN
                       'Un-accessioned'
                   WHEN (m.blnAccessioned = 1 and m.idfsSampleStatus IS NULL/*TODO: what is the case?*/) THEN
                       accessionConditionType.[name]
                   WHEN m.idfsSampleStatus = 10015007 --In Repository
               THEN
                       accessionConditionType.[name]
                   ELSE
                       sampleStatusType.[name]
               END AS AccessionConditionOrSampleStatusTypeName,
               m.idfAccesionByPerson AS AccessionByPersonID,
               m.idfsSampleStatus AS SampleStatusTypeID,
               m.datSampleStatusDate AS SampleStatusDate,
               m.strCondition AS AccessionComment,
               m.idfsDestructionMethod AS DestructionMethodTypeID,
               m.datDestructionDate AS DestructionDate,
               m.idfDestroyedByPerson AS DestroyedByPersonID,
               CASE
                   WHEN m.TestUnassignedIndicator = 1 THEN
                       0
                   ELSE
                       1
               END AS TestAssignedCount,
               m.TransferIndicator AS TransferredCount,
               m.strNote AS Comment,
               m.idfsCurrentSite AS CurrentSiteID,
               m.idfsBirdStatus AS BirdStatusTypeID,
               m.idfMainTest AS MainTestID,
               m.idfsSampleKind AS SampleKindTypeID,
               m.PreviousSampleStatusID AS PreviousSampleStatusTypeID,
               m.LabModuleSourceIndicator,
               m.intRowStatus AS RowStatus,
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
               @TotalRowCount AS TotalRowCount,
               @UnaccessionedCount AS UnaccessionedSampleCount
        FROM @FinalResults res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.ID
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                ON sampleType.idfsReference = m.idfsSampleType
            LEFT JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'BIGINT')
                FROM @favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON f.SampleID = res.ID
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
                ON diseaseName.idfsReference = m.DiseaseID
            LEFT JOIN @MonitoringSessionDiseases msDiseases
                ON msDiseases.ID = m.idfMonitoringSession
            LEFT JOIN @VectorSessionDiseases vsDiseases
                ON vsDiseases.ID = m.idfVectorSurveillanceSession
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000015) sampleStatusType
                ON sampleStatusType.idfsReference = m.idfsSampleStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000110) accessionConditionType
                ON accessionConditionType.idfsReference = m.idfsAccessionCondition
            LEFT JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
            LEFT JOIN dbo.tlbDepartment d
                ON d.idfDepartment = m.idfInDepartment
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164) functionalArea
                ON functionalArea.idfsReference = d.idfsDepartmentName

        ORDER BY m.blnAccessioned,
                 m.idfsSampleStatus DESC,
                 m.idfsAccessionCondition,
                 COALESCE(m.datAccession, m.datFieldCollectionDate, m.datEnteringDate) DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
