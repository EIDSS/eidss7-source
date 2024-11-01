SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================================
-- Name: USP_LAB_TEST_GETList
--
-- Description:	Get laboratory tests list for the various lab use cases.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     10/18/2018 Initial release.
-- Stephen Long     12/19/2018 Added pagination logic.
-- Stephen Long     01/18/2019 Added row selection indicator.
-- Stephen Long     01/30/2019 Added sample disease reference join, and removed the vector 
--                             surveillance session joins as they are no longer needed.
-- Stephen Long     02/12/2019 Added sample ID parameter.
-- Stephen Long     02/21/2019 Added root and parent sample ID's to the select list.  Added 
--                             test status type ID, batch test ID, site ID and test ID parameters.
-- Stephen Long     03/28/2019 Added EIDSS local/field sample ID field.
--                             Changed batch test portion of the where clause to bring back test 
--                             records with a null batch test/in progress unless an actual 
--                             batch test records is specified.  The Testing grid on the labor-
--                             atory module should exclude tests associated with a batch.  These 
--                             display on the Batches tab.
-- Stephen Long     04/03/2019 Changed tests where clause to look at the performed by organization 
--                             instead of sample sent to organization.
-- Stephen Long     04/27/2019 Added EIDSS batch ID, observation ID and batch status type name for 
--                             additional test information.
-- Stephen Long     07/02/2019 Updated joins for sample type and test status type from left to 
--                             inner.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     07/29/2019 Correction on test status typeID where clause conditions.
-- Stephen Long     08/28/2019 Added @TestID null check on the test status type id where clause.
-- Stephen Long     09/03/2019 Added send to organization as part of the where clause.
-- Stephen Long     09/14/2019 Added pagination set 0 to bring back "all" records.
-- Stephen Long     09/26/2019 Added null OR portion on SiteID and OrganizationID where clauses.
-- Stephen Long     10/03/2019 Added test id parameter if/else.
-- Stephen Long     10/22/2019 Added test list parameter and where clause.
-- Stephen Long     01/22/2020 Converted site ID to site list for site filtration.
-- Stephen Long     02/03/2020 Added non-laboratory test indicator where clause.
-- Stephen Long     02/19/2020 Corrected left joins needing intRowStatus = 0.
-- Stephen Long     03/10/2020 Added additional test status types: amended and final and days from 
--                             accession date.
-- Stephen Long     04/07/2020 Added option of no pagination for batch tests.
-- Stephen Long     04/26/2020 Added sent to organization ID to the model.
-- Stephen Long     06/06/2020 Added batch status type ID to the model.
-- Stephen Long     06/11/2020 Correction on where clause criteria for batch tests in final or 
--                             amended status.
-- Stephen Long     09/16/2020 Removed test status type preliminary as these should only show in 
--                             the approvals query.
-- Stephen Long     11/28/2020 Added configurable site filtration rules.
-- Stephen Long     12/31/2020 Change function on reference data to handle inactive records.
-- Stephen Long     01/21/2021 Change function on reference data to handle inactive records.
-- Stephen Long     09/25/2021 Added new pagination and order by.
-- Stephen Long     11/16/2021 Changed to use select row over instead of with cte.
-- Stephen Long     12/17/2021 Removed filtration rules; only apply on advanced search.
-- Stephen Long     12/18/2021 Changed left to inner join on accession condition and sample 
--                             status types.
-- Stephen Long     04/20/2022 Changed to include preliminary in the testing list for tests 
--                             not associated with a batch.
-- Stephen Long     05/24/2022 Added additional test status types for batch of in progress.
-- Stephen Long     05/25/2022 Fix for GIT item 326.
-- Stephen Long     07/25/2022 Removed option (recompile).
-- Stephen Long     08/12/2022 Removed preliminary from where criteria for default list.
-- Stephen Long     08/29/2012 Bug fix on DevOps item 4404.
-- Stephen Long     10/18/2022 Fix on external test indicator to use the field on the testing 
--                             table.
-- Stephen Long     10/21/2022 Added human disease report, veterinary disease report, monitoring 
--                             session and vector identifiers to the query.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/11/2023 Updated for site filtration queries.
-- Stephen Long     03/02/2023 Updated initial query where to use site ID instead of sent to 
--                             organization.
-- Stephen Long     03/09/2023 Added filtration indicator logic.
-- Stephen Long     03/15/2023 Fix on default sort order.
-- Stephen Long     03/29/2023 Fix on accession condition or sample status type name case.
--
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_LAB_TEST_GETList]
		@LanguageID = N'en-US',
		@TestStatusTypeID = NULL,
		@SampleID = NULL,
		@TestID = NULL,
		@BatchTestID = NULL,
		@TestList = NULL,
		@DaysFromAccessionDate = 60,
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
CREATE OR ALTER PROCEDURE [dbo].[USP_LAB_TEST_GETList]
(
    @LanguageID NVARCHAR(50),
    @TestStatusTypeID BIGINT = NULL,
    @SampleID BIGINT = NULL,
    @TestID BIGINT = NULL,
    @BatchTestID BIGINT = NULL,
    @TestList VARCHAR(MAX) = NULL,
    @DaysFromAccessionDate INT = NULL,
    @FiltrationIndicator BIT = 1,
    @UserID BIGINT,
    @UserEmployeeID BIGINT,
    @UserOrganizationID BIGINT = NULL,
    @UserSiteID BIGINT,
    @UserSiteGroupID BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

	declare @DFrom datetime, @DTo datetime
	set @DTo = GETDATE()
	set	@DFrom = dateadd(day, -isnull(@DaysFromAccessionDate, 15), cast(@DTo as date))

    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        TestStatusTypeID BIGINT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL,
        TestStatusTypeID BIGINT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
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
    DECLARE @Favorites XML,
            @InProgressCount INT;

    BEGIN TRY
	/*		--TODO: Reapply Permissions to sites
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

        IF @TestID IS NULL
           AND @TestList IS NULL
           AND @SampleID IS NULL 
        BEGIN
            INSERT INTO @Results
            SELECT t.idfTesting,
                   t.idfsTestStatus,
                   1,
                   CASE
                       WHEN m.idfsSite = @UserSiteID
                            OR @FiltrationIndicator = 0 THEN
                           1
                       ELSE
                           0
                   END,
                   CASE
                       WHEN m.idfsSite = @UserSiteID
                            OR @FiltrationIndicator = 0 THEN
                           1
                       ELSE
                           0
                   END,
                   CASE
                       WHEN m.idfsSite = @UserSiteID
                            OR @FiltrationIndicator = 0 THEN
                           1
                       ELSE
                           0
                   END,
                   CASE
                       WHEN m.idfsSite = @UserSiteID
                            OR @FiltrationIndicator = 0 THEN
                           1
                       ELSE
                           0
                   END
            FROM dbo.tlbTesting t
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                    ON disease.idfsReference = t.idfsDiagnosis
                LEFT JOIN dbo.tlbBatchTest b
                    ON b.idfBatchTest = t.idfBatchTest
                       AND b.intRowStatus = 0
            WHERE t.intRowStatus = 0
                  AND t.idfsTestName IS NOT NULL
                  AND t.blnNonLaboratoryTest = 0
                  AND (
						  m.idfsCurrentSite = @UserSiteID
                      )
	              AND (		--TODO: Apply proper rule for Sample Status when it's ready
						(	(	m.datDestructionDate >= @DFrom
								OR	(	m.datDestructionDate is null
										and m.datAccession >= @DFrom
									)
							)
							and (m.idfsSampleStatus is null or m.idfsSampleStatus <> 10015010) -- Transferred Out
						)
						OR	(	m.datOutOfRepositoryDate >= @DFrom
                                 AND m.idfsSampleStatus = 10015010 -- Transferred Out
							)
						OR @DaysFromAccessionDate IS NULL
                  )
                  AND (
                          t.idfsTestStatus = @TestStatusTypeID
                          OR @TestStatusTypeID IS NULL
                      )
                  AND (
                          (
                              t.idfBatchTest IS NULL
                              AND t.idfsTestStatus IN (   10001001, --Final
                                                          10001007, --Deleted
                                                          10001003, --In Progress
                                                          10001006
                                                      ) --Amended
                          )
                          OR (
                                 t.idfBatchTest IS NOT NULL
                                 AND b.idfsBatchStatus = 10001003 --In Progress
                                 AND t.idfsTestStatus IN (   10001001, --Final 
                                                             10001003, -- In Progress
                                                             10001004, --Preliminary
                                                             10001006
                                                         ) --Amended
                             )
                          OR (
                                 t.idfBatchTest IS NOT NULL
                                 AND b.idfsBatchStatus = 10001001 --Closed
                                 AND t.idfsTestStatus IN (   10001001, --Final 
                                                             10001003, -- In Progress
                                                             10001004, --Preliminary
                                                             10001006
                                                         ) --Amended
                             )
                      )
                  AND (
                          (t.idfBatchTest = @BatchTestID)
                          OR @BatchTestID IS NULL
                      );
        END
        ELSE
        BEGIN
            INSERT INTO @Results
            SELECT t.idfTesting,
                   t.idfsTestStatus,
                   1,
                   CASE
                       WHEN m.idfsSite = @UserSiteID
                            OR @FiltrationIndicator = 0 THEN
                           1
                       ELSE
                           0
                   END,
                   CASE
                       WHEN m.idfsSite = @UserSiteID
                            OR @FiltrationIndicator = 0 THEN
                           1
                       ELSE
                           0
                   END,
                   CASE
                       WHEN m.idfsSite = @UserSiteID
                            OR @FiltrationIndicator = 0 THEN
                           1
                       ELSE
                           0
                   END,
                   CASE
                       WHEN m.idfsSite = @UserSiteID
                            OR @FiltrationIndicator = 0 THEN
                           1
                       ELSE
                           0
                   END
            FROM dbo.tlbTesting t
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
            WHERE t.intRowStatus = 0
                  AND (
                          t.idfTesting = @TestID
                          OR @TestID IS NULL
                      )
                  AND (
                          t.idfMaterial = @SampleID
                          OR @SampleID IS NULL
                      )
                  AND (
                          exists (
							SELECT 1
                            FROM dbo.FN_GBL_SYS_SplitList(@TestList, NULL, ',')
							WHERE cast(t.idfTesting as nvarchar(20)) = cast([Value] as nvarchar) collate Cyrillic_General_CI_AS
                                )
                          OR @TestList IS NULL
                      );

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
            SELECT t.idfTesting,
                   t.idfsTestStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbTesting t
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = m.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE t.intRowStatus = 0
                  AND t.blnNonLaboratoryTest = 0
                  AND t.idfsTestName IS NOT NULL
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT t.idfTesting,
                   t.idfsTestStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbTesting t
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = m.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE t.intRowStatus = 0
                  AND t.blnNonLaboratoryTest = 0
                  AND t.idfsTestName IS NOT NULL
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT t.idfTesting,
                   t.idfsTestStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbTesting t
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = m.idfsSite
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
            WHERE t.intRowStatus = 0
                  AND t.blnNonLaboratoryTest = 0
                  AND t.idfsTestName IS NOT NULL
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT t.idfTesting,
                   t.idfsTestStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbTesting t
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = m.idfsSite
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
            WHERE t.intRowStatus = 0
                  AND t.blnNonLaboratoryTest = 0
                  AND t.idfsTestName IS NOT NULL
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @Results
            SELECT t.idfTesting,
                   t.idfsTestStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbTesting t
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE t.intRowStatus = 0
                  AND t.blnNonLaboratoryTest = 0
                  AND t.idfsTestName IS NOT NULL
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND sgs.idfsSite = m.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @Results
            SELECT t.idfTesting,
                   t.idfsTestStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbTesting t
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE t.intRowStatus = 0
                  AND t.blnNonLaboratoryTest = 0
                  AND t.idfsTestName IS NOT NULL
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND a.GrantingActorSiteID = m.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @Results
            SELECT t.idfTesting,
                   t.idfsTestStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbTesting t
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
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
            WHERE t.intRowStatus = 0
                  AND t.blnNonLaboratoryTest = 0
                  AND t.idfsTestName IS NOT NULL
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND a.GrantingActorSiteID = m.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @Results
            SELECT t.idfTesting,
                   t.idfsTestStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbTesting t
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
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
            WHERE t.intRowStatus = 0
                  AND t.blnNonLaboratoryTest = 0
                  AND t.idfsTestName IS NOT NULL
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND a.GrantingActorSiteID = m.idfsSite;
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
	/*		--TODO: Reapply Permissions to sites
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT t.idfTesting
            FROM dbo.tlbTesting t
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
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
            WHERE t.intRowStatus = 0
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = eg.idfEmployeeGroup -- Default role
        );

        --
        -- Apply level 1 site filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbTesting t
                ON t.idfTesting = res.ID
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = m.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003 -- Read permission
              AND NOT EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = m.idfsSite
        );

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT t.idfTesting
            FROM dbo.tlbTesting t
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = m.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );
		*/

        INSERT INTO @FinalResults
        SELECT res.ID,
               res.TestStatusTypeID,
               MAX(res.ReadPermissionIndicator),
               MAX(res.AccessToPersonalDataPermissionIndicator),
               MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
               MAX(res.WritePermissionIndicator),
               MAX(res.DeletePermissionIndicator)
        FROM @Results res
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
        GROUP BY res.ID,
                 res.TestStatusTypeID;

        SET @InProgressCount =
        (
            SELECT COUNT(   CASE
                                WHEN TestStatusTypeID = 10001003 --In Progress
                            THEN
                                    ID
                                ELSE
                                    NULL
                            END
                        )
            FROM @FinalResults res
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = res.ID
                       AND t.intRowStatus = 0
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.tlbBatchTest b
                    ON b.idfBatchTest = t.idfBatchTest
                       AND b.intRowStatus = 0
            WHERE t.intRowStatus = 0
                  AND (
                          t.idfTesting = @TestID
                          OR @TestID IS NULL
                      )
                  AND t.idfsTestName IS NOT NULL
                  AND t.blnNonLaboratoryTest = 0
                  AND (
						  m.idfsCurrentSite = @UserSiteID
                      )
	              AND (		--TODO: Apply proper rule for Sample Status when it's ready
						(	(	m.datDestructionDate >= @DFrom
								OR	(	m.datDestructionDate is null
										and m.datAccession >= @DFrom
									)
							)
							and (m.idfsSampleStatus is null or m.idfsSampleStatus <> 10015010) -- Transferred Out
						)
						OR	(	m.datOutOfRepositoryDate >= @DFrom
                                 AND m.idfsSampleStatus = 10015010 -- Transferred Out
							)
						OR @DaysFromAccessionDate IS NULL
                  )
                  AND (
                          exists (
							SELECT 1
                            FROM dbo.FN_GBL_SYS_SplitList(@TestList, NULL, ',')
							WHERE cast(t.idfTesting as nvarchar(20)) = cast([Value] as nvarchar) collate Cyrillic_General_CI_AS
                                )
                          OR @TestList IS NULL
                      )
                  AND (
                          t.idfsTestStatus = @TestStatusTypeID
                          OR @TestStatusTypeID IS NULL
                      )
                  AND (
                          (
                              t.idfBatchTest IS NULL
                              AND t.idfsTestStatus IN (   10001001, --Final
                                                          10001003, --In Progress
                                                          10001006
                                                      ) --Amended
                          )
                          OR (
                                 t.idfBatchTest IS NOT NULL
                                 AND b.idfsBatchStatus = 10001003 --In Progress
                                 AND t.idfsTestStatus IN (   10001001, --Final 
                                                             10001004, --Preliminary
                                                             10001006  --Amended
                                                         )
                             )
                          OR (
                                 t.idfBatchTest IS NOT NULL
                                 AND b.idfsBatchStatus = 10001001 --Closed
                                 AND t.idfsTestStatus IN (   10001001, --Final 
                                                             10001003, -- In Progress
                                                             10001004, --Preliminary
                                                             10001006
                                                         ) --Amended
                             )
                      )
                  AND (
                          t.idfMaterial = @SampleID
                          OR @SampleID IS NULL
                      )
                  AND (
                          (t.idfBatchTest = @BatchTestID)
                          OR @BatchTestID IS NULL
                      )
        );

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        SELECT t.idfTesting AS TestID,
               CASE
                   WHEN f.SampleID IS NULL THEN
                       0
                   ELSE
                       1
               END AS FavoriteIndicator,
               m.idfsSite AS SiteID,
               m.idfsCurrentSite AS CurrentSiteID,
               t.idfsTestName AS TestNameTypeID,
               t.idfsTestCategory AS TestCategoryTypeID,
               t.idfsTestResult AS TestResultTypeID,
               t.idfsTestStatus AS TestStatusTypeID,
               t.PreviousTestStatusID AS PreviousTestStatusTypeID,
               t.idfsDiagnosis AS DiseaseID,
               m.idfMaterial AS SampleID,
               m.idfRootMaterial AS RootSampleID,
               m.idfParentMaterial AS ParentSampleID,
               m.idfSendToOffice AS SentToOrganizationID,
               t.idfBatchTest AS BatchTestID,
               t.idfObservation AS ObservationID,
               t.intTestNumber AS TestNumber,
               t.strNote AS Note,
               t.datStartedDate AS StartedDate,
               t.datConcludedDate AS ResultDate,
               t.idfTestedByOffice AS TestedByOrganizationID,
               t.idfTestedByPerson AS TestedByPersonID,
               t.idfResultEnteredByOffice AS ResultEnteredByOrganizationID,
               t.idfResultEnteredByPerson AS ResultEnteredByPersonID,
               t.idfValidatedByOffice AS ValidatedByOrganizationID,
               t.idfValidatedByPerson AS ValidatedByPersonID,
               t.blnReadOnly AS ReadOnlyIndicator,
               t.blnNonLaboratoryTest AS NonLaboratoryTestIndicator,
               t.blnExternalTest AS ExternalTestIndicator,
               t.idfPerformedByOffice AS PerformedByOrganizationID,
               t.datReceivedDate AS ReceivedDate,
               t.strContactPerson AS ContactPersonName,
               m.strCalculatedCaseID AS EIDSSReportOrSessionID,
               m.strCalculatedHumanName AS PatientOrFarmOwnerName,
               sampleType.name AS SampleTypeName,
               disease.name AS DiseaseName,
               m.strBarcode AS EIDSSLaboratorySampleID,
               m.strFieldBarcode AS EIDSSLocalOrFieldSampleID,
               testNameType.name AS TestNameTypeName,
               testStatusType.name AS TestStatusTypeName,
               testResultType.name AS TestResultTypeName,
               testCategoryType.name AS TestCategoryTypeName,
               m.datAccession AS AccessionDate,
               functionalArea.name AS FunctionalAreaName,
               m.idfsAccessionCondition AS AccessionConditionTypeID,
               m.idfsSampleStatus AS SampleStatusTypeID,
               CASE
                   WHEN m.blnAccessioned = 0
                        AND m.idfsSampleStatus IS NULL
                        AND m.idfsAccessionCondition IS NULL THEN
                       'Un-accessioned'
                   WHEN (m.blnAccessioned = 1 and m.idfsSampleStatus IS NULL/*TODO: what is the case?*/) THEN
                       accessionConditionType.name
                   WHEN m.idfsSampleStatus = 10015007 --In Repository
               THEN
                       accessionConditionType.name
                   ELSE
                       sampleStatusType.name
               END AS AccessionConditionOrSampleStatusTypeName,
               m.strCondition AS AccessionComment,
               a.strAnimalCode AS EIDSSAnimalID,
               ISNULL(transf.intCount,0) AS TransferCount,
               tro.idfTransferOut AS TransferID,
               t.idfHumanCase AS HumanDiseaseReportID,
               t.idfVetCase AS VeterinaryDiseaseReportID,
               t.idfMonitoringSession AS MonitoringSessionID,
               t.idfVector AS VectorID,
               t.intRowStatus AS RowStatus,
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
               @InProgressCount AS InProgressCount
        FROM @FinalResults res
            INNER JOIN dbo.tlbTesting t
                ON t.idfTesting = res.ID
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) disease
                ON disease.idfsReference = t.idfsDiagnosis
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                ON sampleType.idfsReference = m.idfsSampleType
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                ON testStatusType.idfsReference = t.idfsTestStatus
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000110) accessionConditionType
                ON accessionConditionType.idfsReference = m.idfsAccessionCondition
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000015) sampleStatusType
                ON sampleStatusType.idfsReference = m.idfsSampleStatus
            LEFT JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'bigint')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
            LEFT JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfMaterial = m.idfMaterial
                   AND tom.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOUT tro
                ON tro.idfTransferOut = tom.idfTransferOut
                   AND tro.intRowStatus = 0
            LEFT JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
            LEFT JOIN dbo.tlbDepartment d
                ON d.idfDepartment = m.idfInDepartment
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164) functionalArea
                ON functionalArea.idfsReference = d.idfsDepartmentName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                ON testNameType.idfsReference = t.idfsTestName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                ON testResultType.idfsReference = t.idfsTestResult
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                ON testCategoryType.idfsReference = t.idfsTestCategory
			outer apply
			(	SELECT COUNT(NULLIF(tom2.idfTransferOUT, 0)) as intCount
                   FROM dbo.tlbTransferOutMaterial tom2
                   WHERE tom2.idfMaterial = m.idfMaterial
                         AND tom2.intRowStatus = 0
			) transf
            ORDER BY m.strBarcode DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
