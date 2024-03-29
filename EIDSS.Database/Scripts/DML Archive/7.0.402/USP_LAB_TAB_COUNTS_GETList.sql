SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================================
-- Name: USP_LAB_TAB_COUNTS_GETList
--
-- Description:	Gets a list of counts for each laboratory module tab: samples (un-accessioned), 
-- testing (in progress tests), transferred, my favorites, batches (in progress) and approvals.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     10/18/2021 Initial release.
-- Stephen Long     12/21/2021 Removed filtration rules as these are the default counts.
-- Stephen Long     02/10/2022 Added send to office on transfer count.
-- Stephen Long     04/15/2022 Fix to account for filtration counts.
-- Stephen Long     07/26/2022 Simplified where criteria on testing in progress count.
-- Stephen Long     08/10/2022 Corrected where criteria on batches in progress count; include only
--                             batches with at least one test.
-- Stephen Long     10/11/2022 Added check for closed batch test status to display test records 
--                             ready for validation.
-- Stephen Long     10/23/2022 Added non-laboratory test indicator to where criteria on test 
--                             records for approval.
-- Stephen Long     01/03/2023 Added check for user's site identifier when the sent to organization 
--                             is not present.
-- Stephen Long     01/14/2023 Updated for site filtration queries.
-- Stephen Long     03/02/2023 Added sent to organization sent to site ID and where criteria.
-- Stephen Long     03/29/2023 Fixed un-accessioned samples to only look at sent to organization.
-- 
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_LAB_TAB_COUNTS_GETList]
		@DaysFromAccessionDate = 60,
		@UserID = 161287150000872, --rykermase
		@UserEmployeeID = 420664190000872,
		@UserSiteID = 864,
		@UserOrganizationID = 758210000000,
		@UserSiteGroupID = NULL

SELECT	'Return Value' = @return_value

GO
*/
-- ================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_LAB_TAB_COUNTS_GETList]
(
    @DaysFromAccessionDate INT,
    @UserID BIGINT,
    @UserEmployeeID BIGINT,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT = NULL,
    @UserSiteGroupID BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

	declare @DFrom datetime, @DTo datetime
	set @DTo = GETDATE()
	set	@DFrom = dateadd(day, -isnull(@DaysFromAccessionDate, 15), cast(@DTo as date))

    DECLARE @SamplesUnaccessionedCount INT = 0,
            @TestingInProgressCount INT = 0,
            @TransferredCount INT = 0,
            @MyFavoritesCount INT = 0,
            @BatchesInProgressCount INT = 0,
            @ApprovalsCount INT = 0;
    DECLARE @Results TABLE (ID BIGINT NOT NULL);
    DECLARE @FinalResults TABLE (ID BIGINT NOT NULL);
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
    DECLARE @UserEmployeeGroupID BIGINT = (
                                              SELECT TOP 1
                                                  egm.idfEmployeeGroup
                                              FROM dbo.tlbEmployeeGroupMember egm
                                              WHERE egm.idfEmployee = @UserEmployeeID
                                                    AND egm.intRowStatus = 0
                                          );

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
        -- =======================================================================================
        -- Samples Tab Unaccessioned Count
        -- =======================================================================================
        INSERT INTO @Results
        SELECT m.idfMaterial
        FROM dbo.tlbMaterial m
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.idfSendToOffice = @UserOrganizationID 
              AND m.blnAccessioned = 0
              AND m.idfsAccessionCondition IS NULL
              AND m.datDestructionDate IS NULL 
              AND m.idfsSampleStatus IS NULL
			  AND (	m.datFieldCollectionDate >= @DFrom
					OR	(	m.datFieldCollectionDate is null
							and m.datEnteringDate >= @DFrom
						)
				  );

        -- =======================================================================================
        -- CONFIGURABLE SITE FILTRATION RULES
        -- 
        -- Apply configurable site filtration rules for use case SAUC34. Some of these rules may 
        -- overlap the non-configurable rules.
        -- =======================================================================================
        --
        -- Apply at the user's site group level, granted by a site group.
        --
        IF @UserOrganizationID IS NOT NULL --First-level sites (central data repository, general data repository, etc.) do not filter results.
        BEGIN
            INSERT INTO @Results
            SELECT m.idfMaterial
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
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND m.blnAccessioned = 0
                  AND m.idfsAccessionCondition IS NULL
                  AND m.idfsSampleStatus IS NULL
				  AND (	m.datFieldCollectionDate >= @DFrom
					OR	(	m.datFieldCollectionDate is null
							and m.datEnteringDate >= @DFrom
						)
				  )
                  AND @UserSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT m.idfMaterial
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
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND m.blnAccessioned = 0
                  AND m.idfsAccessionCondition IS NULL
                  AND m.idfsSampleStatus IS NULL
				  AND (	m.datFieldCollectionDate >= @DFrom
					OR	(	m.datFieldCollectionDate is null
							and m.datEnteringDate >= @DFrom
						)
				  )
                  AND ar.GrantingActorSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT m.idfMaterial
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
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND m.blnAccessioned = 0
                  AND m.idfsAccessionCondition IS NULL
                  AND m.idfsSampleStatus IS NULL
				  AND (	m.datFieldCollectionDate >= @DFrom
					OR	(	m.datFieldCollectionDate is null
							and m.datEnteringDate >= @DFrom
						)
				  )
                  AND ar.GrantingActorSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT m.idfMaterial
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
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND m.blnAccessioned = 0
                  AND m.idfsAccessionCondition IS NULL
                  AND m.idfsSampleStatus IS NULL
				  AND (	m.datFieldCollectionDate >= @DFrom
					OR	(	m.datFieldCollectionDate is null
							and m.datEnteringDate >= @DFrom
						)
				  )
                  AND ar.GrantingActorSiteGroupID IS NOT NULL
                  AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @Results
            SELECT m.idfMaterial
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
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND m.blnAccessioned = 0
                  AND m.idfsAccessionCondition IS NULL
                  AND m.idfsSampleStatus IS NULL
				  AND (	m.datFieldCollectionDate >= @DFrom
					OR	(	m.datFieldCollectionDate is null
							and m.datEnteringDate >= @DFrom
						)
				  )
                  AND @UserSiteGroupID IS NOT NULL
                  AND sgs.idfsSite = m.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @Results
            SELECT m.idfMaterial
            FROM dbo.AccessRule ar
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.tlbMaterial m
                    ON m.intRowStatus = 0
            WHERE ar.GrantingActorSiteID IS NOT NULL
                  AND ar.DefaultRuleIndicator = 0
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND m.blnAccessioned = 0
                  AND m.idfsAccessionCondition IS NULL
                  AND m.idfsSampleStatus IS NULL
				  AND (	m.datFieldCollectionDate >= @DFrom
					OR	(	m.datFieldCollectionDate is null
							and m.datEnteringDate >= @DFrom
						)
				  )
                  AND m.idfsSite = ar.GrantingActorSiteID;

            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @Results
            SELECT m.idfMaterial
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
                  AND ara.intRowStatus = 0
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND m.blnAccessioned = 0
                  AND m.idfsAccessionCondition IS NULL
                  AND m.idfsSampleStatus IS NULL
				  AND (	m.datFieldCollectionDate >= @DFrom
					OR	(	m.datFieldCollectionDate is null
							and m.datEnteringDate >= @DFrom
						)
				  )
                  AND m.idfsSite = ar.GrantingActorSiteID;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @Results
            SELECT m.idfMaterial
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
                  AND m.idfsSampleType <> 10320001 --Unknown
                  AND m.blnAccessioned = 0
                  AND m.idfsAccessionCondition IS NULL
                  AND m.idfsSampleStatus IS NULL
				  AND (	m.datFieldCollectionDate >= @DFrom
					OR	(	m.datFieldCollectionDate is null
							and m.datEnteringDate >= @DFrom
						)
				  )
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
            SELECT m.idfMaterial
            FROM dbo.tlbMaterial m
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = m.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );
		*/

        SET @SamplesUnaccessionedCount = 
        (
            SELECT COUNT(distinct [ID]) FROM @Results
        );

        -- =======================================================================================
        -- Testing Tab In Progress Count
        -- =======================================================================================
        SELECT @TestingInProgressCount = count(t.idfTesting)
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND t.idfsTestName IS NOT NULL
              AND t.idfsTestStatus = 10001003 --In Progress
              AND t.blnNonLaboratoryTest = 0
              AND m.idfsCurrentSite = @UserSiteID
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
                      t.idfBatchTest IS NULL
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus <> 10001001 --Closed
                         )
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

        SET @TestingInProgressCount =
        (
            SELECT COUNT(*) FROM @Results
        );
		*/

        -- =======================================================================================
        -- Transferred Tab Count
        -- =======================================================================================
        DELETE FROM @Results;
        DELETE FROM @FinalResults;

        INSERT INTO @Results
        SELECT tr.idfTransferOut
        FROM dbo.tlbTransferOUT tr
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
        WHERE (
                  tr.idfSendFromOffice = @UserOrganizationID
                  OR tr.idfSendToOffice = @UserOrganizationID
              )
              AND (tr.idfsTransferStatus IN (   10001003, --In Progress
                                                10001006  --Amended
                                            )
                  )
              AND tr.intRowStatus = 0;

        -- =======================================================================================
        -- CONFIGURABLE SITE FILTRATION RULES
        -- 
        -- Apply configurable site filtration rules for use case SAUC34. Some of these rules may 
        -- overlap the non-configurable rules.
        -- =======================================================================================
        --
        -- Apply at the user's site group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut
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
        WHERE tr.intRowStatus = 0
              AND @UserSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut
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
        WHERE tr.intRowStatus = 0
              AND ar.GrantingActorSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's employee group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut
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
        WHERE tr.intRowStatus = 0
              AND ar.GrantingActorSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's ID level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut
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
        WHERE tr.intRowStatus = 0
              AND ar.GrantingActorSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut
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
        WHERE tr.intRowStatus = 0
              AND @UserSiteGroupID IS NOT NULL
              AND sgs.idfsSite = tr.idfsSite;

        -- 
        -- Apply at the user's site level, granted by a site.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut
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
              AND tr.idfsSite = ar.GrantingActorSiteID;

        -- 
        -- Apply at the user's employee group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut
        FROM dbo.AccessRuleActor ara
            INNER JOIN dbo.AccessRule ar
                ON ar.AccessRuleID = ara.AccessRuleID
                   AND ar.intRowStatus = 0
                   AND ar.GrantingActorSiteID IS NOT NULL
            INNER JOIN dbo.tlbTransferOUT tr
                ON tr.intRowStatus = 0
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
        WHERE ara.ActorEmployeeGroupID = @UserEmployeeGroupID
              AND ara.intRowStatus = 0
              AND tr.idfsSite = ar.GrantingActorSiteID;

        -- 
        -- Apply at the user's ID level, granted by a site.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut
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
              AND tr.idfsSite = ar.GrantingActorSiteID;

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
            SELECT tr.idfTransferOut
            FROM dbo.tlbTransferOUT tr
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = tr.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE tr.intRowStatus = 0
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
            INNER JOIN dbo.tlbTransferOUT tr
                ON tr.idfTransferOut = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = tr.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003 -- Read permission
              AND NOT EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = tr.idfsSite
        );

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT tr.idfTransferOut
            FROM dbo.tlbTransferOUT tr
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = tr.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );
		*/


        SET @TransferredCount =
        (
            SELECT COUNT(distinct res.[ID]) FROM @Results res
            INNER JOIN dbo.tlbTransferOUT tr
                ON tr.idfTransferOut = res.ID
        WHERE tr.intRowStatus = 0
              AND tr.idfsTransferStatus IN (   10001003, --In Progress
                                               10001006  --Amended
                                           )
        );

        -- =======================================================================================
        -- My Favorites Tab Count
        -- =======================================================================================
        DELETE FROM @Results;
        DELETE FROM @FinalResults;

        SET @Favorites =
        (
            SELECT PreferenceDetail
            FROM dbo.UserPreference Laboratory
            WHERE idfUserID = @UserID
                  AND ModuleConstantID = 10508006
                  AND intRowStatus = 0
        );

        INSERT INTO @Results
        SELECT m.idfMaterial
        FROM dbo.tlbMaterial m
            INNER JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'bigint')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
        WHERE m.intRowStatus = 0;

        -- =======================================================================================
        -- CONFIGURABLE SITE FILTRATION RULES
        -- 
        -- Apply configurable site filtration rules for use case SAUC34. Some of these rules may 
        -- overlap the non-configurable rules.
        -- =======================================================================================
        --
        -- Apply at the user's site group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial
        FROM dbo.tlbMaterial m
            INNER JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'bigint')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = m.idfsSite
            INNER JOIN dbo.tstUserTable u
                ON u.idfPerson = @UserEmployeeID
                   AND u.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteGroupID = @UserSiteGroupID
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
        WHERE m.intRowStatus = 0
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial
        FROM dbo.tlbMaterial m
            INNER JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'bigint')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = m.idfsSite
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteID = @UserSiteID
                   AND ara.ActorEmployeeGroupID IS NULL
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
        WHERE m.intRowStatus = 0
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's employee group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial
        FROM dbo.tlbMaterial m
            INNER JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'bigint')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
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
        WHERE m.intRowStatus = 0
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's ID level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial
        FROM dbo.tlbMaterial m
            INNER JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'bigint')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
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
        WHERE m.intRowStatus = 0
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial
        FROM dbo.tlbMaterial m
            INNER JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'bigint')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
            INNER JOIN dbo.tflSiteToSiteGroup sgs
                ON sgs.idfSiteGroup = @UserSiteGroupID
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
        WHERE m.intRowStatus = 0
              AND sgs.idfsSite = m.idfsSite;

        -- 
        -- Apply at the user's site level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial
        FROM dbo.tlbMaterial m
            INNER JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'bigint')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteID = @UserSiteID
                   AND ara.ActorEmployeeGroupID IS NULL
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
        WHERE m.intRowStatus = 0
              AND a.GrantingActorSiteID = m.idfsSite;

        -- 
        -- Apply at the user's employee group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial
        FROM dbo.tlbMaterial m
            INNER JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'bigint')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
        WHERE m.intRowStatus = 0
              AND a.GrantingActorSiteID = m.idfsSite;

        -- 
        -- Apply at the user's ID level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial
        FROM dbo.tlbMaterial m
            INNER JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'bigint')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
            INNER JOIN dbo.tstUserTable u
                ON u.idfPerson = @UserEmployeeID
                   AND u.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorUserID = u.idfUserID
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
        WHERE m.intRowStatus = 0
              AND a.GrantingActorSiteID = m.idfsSite;

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
            SELECT m.idfMaterial
            FROM dbo.tlbMaterial m
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = m.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );
		*/

        SET @MyFavoritesCount =
        (
            SELECT COUNT(distinct [ID]) FROM @Results
        );

        -- =======================================================================================
        -- Batches Tab Count
        -- =======================================================================================
        DELETE FROM @Results;
        DELETE FROM @FinalResults;

        INSERT INTO @Results
        SELECT b.idfBatchTest
        FROM dbo.tlbBatchTest b
        WHERE b.idfPerformedByOffice = @UserOrganizationID
              AND b.idfsSite = @UserSiteID
              AND b.intRowStatus = 0
              AND exists
              (
                  SELECT 1
                  FROM dbo.tlbTesting t
                  WHERE t.idfBatchTest = b.idfBatchTest
              );

        -- =======================================================================================
        -- CONFIGURABLE SITE FILTRATION RULES
        -- 
        -- Apply configurable site filtration rules for use case SAUC34. Some of these rules may 
        -- overlap the non-configurable rules.
        -- =======================================================================================
        --
        -- Apply at the user's site group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tflSiteToSiteGroup AS grantingSGS
                ON grantingSGS.idfsSite = b.idfsSite
            INNER JOIN dbo.tstUserTable AS u
                ON u.idfPerson = @UserEmployeeID
                   AND u.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor AS ara
                ON ara.ActorSiteGroupID = @UserSiteGroupID
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule AS ar
                ON ar.AccessRuleID = ara.AccessRuleID
                   AND ar.intRowStatus = 0
        WHERE b.intRowStatus = 0
              AND exists
              (
                  SELECT 1
                  FROM dbo.tlbTesting t
                  WHERE t.idfBatchTest = b.idfBatchTest
              )
              AND @UserSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = b.idfsSite
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteID = @UserSiteID
                   AND ara.ActorEmployeeGroupID IS NULL
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule ar
                ON ar.AccessRuleID = ara.AccessRuleID
                   AND ar.intRowStatus = 0
        WHERE b.intRowStatus = 0
              AND exists
              (
                  SELECT 1
                  FROM dbo.tlbTesting t
                  WHERE t.idfBatchTest = b.idfBatchTest
              )
              AND ar.GrantingActorSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's employee group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = b.idfsSite
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule ar
                ON ar.AccessRuleID = ara.AccessRuleID
                   AND ar.intRowStatus = 0
        WHERE b.intRowStatus = 0
              AND exists
              (
                  SELECT 1
                  FROM dbo.tlbTesting t
                  WHERE t.idfBatchTest = b.idfBatchTest
              )
              AND ar.GrantingActorSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's ID level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = b.idfsSite
            INNER JOIN dbo.tstUserTable u
                ON u.idfPerson = @UserEmployeeID
                   AND u.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorUserID = u.idfUserID
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule ar
                ON ar.AccessRuleID = ara.AccessRuleID
                   AND ar.intRowStatus = 0
        WHERE b.intRowStatus = 0
              AND exists
              (
                  SELECT 1
                  FROM dbo.tlbTesting t
                  WHERE t.idfBatchTest = b.idfBatchTest
              )
              AND ar.GrantingActorSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tflSiteToSiteGroup sgs
                ON sgs.idfSiteGroup = @UserSiteGroupID
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule ar
                ON ar.AccessRuleID = ara.AccessRuleID
                   AND ar.intRowStatus = 0
        WHERE b.intRowStatus = 0
              AND exists
              (
                  SELECT 1
                  FROM dbo.tlbTesting t
                  WHERE t.idfBatchTest = b.idfBatchTest
              )
              AND @UserSiteGroupID IS NOT NULL
              AND sgs.idfsSite = b.idfsSite;

        -- 
        -- Apply at the user's site level, granted by a site.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest
        FROM dbo.AccessRule ar
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteID = @UserSiteID
                   AND ara.ActorEmployeeGroupID IS NULL
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.tlbBatchTest b
                ON b.intRowStatus = 0
        WHERE ar.GrantingActorSiteID IS NOT NULL
              AND b.idfsSite = ar.GrantingActorSiteID
              AND exists
              (
                  SELECT 1
                  FROM dbo.tlbTesting t
                  WHERE t.idfBatchTest = b.idfBatchTest
              );

        -- 
        -- Apply at the user's employee group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest
        FROM dbo.AccessRule ar
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.tlbBatchTest b
                ON b.intRowStatus = 0
        WHERE ar.GrantingActorSiteID IS NOT NULL
              AND b.idfsSite = ar.GrantingActorSiteID
              AND exists
              (
                  SELECT 1
                  FROM dbo.tlbTesting t
                  WHERE t.idfBatchTest = b.idfBatchTest
              );

        -- 
        -- Apply at the user's ID level, granted by a site.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest
        FROM dbo.AccessRule ar
            INNER JOIN dbo.tstUserTable u
                ON u.idfPerson = @UserEmployeeID
                   AND u.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorUserID = u.idfUserID
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.tlbBatchTest b
                ON b.intRowStatus = 0
        WHERE ar.GrantingActorSiteID IS NOT NULL
              AND b.idfsSite = ar.GrantingActorSiteID
              AND exists
              (
                  SELECT 1
                  FROM dbo.tlbTesting t
                  WHERE t.idfBatchTest = b.idfBatchTest
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
            SELECT b.idfBatchTest
            FROM dbo.tlbBatchTest b
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = b.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE b.intRowStatus = 0
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
            INNER JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = b.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003 -- Read permission
              AND NOT EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = b.idfsSite
        );

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT b.idfBatchTest
            FROM dbo.tlbBatchTest b
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = b.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );
		*/


        SET @BatchesInProgressCount =
        (
            SELECT COUNT(distinct res.[ID]) FROM @Results res
            INNER JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = res.ID
        WHERE b.idfsBatchStatus = 10001003 --In Progress
        );

        -- =======================================================================================
        -- Approvals Tab Count
        -- =======================================================================================
        DELETE FROM @Results;
        DELETE FROM @FinalResults;

        INSERT INTO @Results
        SELECT m.idfMaterial
        FROM dbo.tlbMaterial m
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.idfsSampleStatus IN (   10015002, --Marked for Deletion 
                                            10015003
                                        ) --Marked for Destruction
              AND (m.idfsCurrentSite = @UserSiteID);

        INSERT INTO @Results
        SELECT t.idfTesting
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
              AND (m.idfsCurrentSite = @UserSiteID);

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

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = m.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

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

        SET @ApprovalsCount =
        (
            SELECT COUNT(distinct ID) FROM @Results
        );

        SELECT @SamplesUnaccessionedCount AS SamplesTabCount,
               @TestingInProgressCount AS TestingTabCount,
               @TransferredCount AS TransferredTabCount,
               @MyFavoritesCount AS MyFavoritesTabCount,
               @BatchesInProgressCount AS BatchesTabCount,
               @ApprovalsCount AS ApprovalsTabCount;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
