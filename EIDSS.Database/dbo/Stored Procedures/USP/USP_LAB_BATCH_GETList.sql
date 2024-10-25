-- ================================================================================================
-- Name: USP_LAB_BATCH_GETList
--
-- Description:	Get laboratory batch list for the various laboratory use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/10/2018 Initial release.
-- Stephen Long     12/19/2018 Added pagination logic.
-- Stephen Long     01/25/2019 Changed where clause to look at batch test row status instead of 
--                             test.
-- Stephen Long     02/01/2019 Added sample disease reference join and removed the vector 
--                             surveillance session joins as they are no longer needed.
-- Stephen Long     02/19/2019 Removed positive and negative control and reagent lot numbers.
--                             Added organization ID parameter.
-- Stephen Long     03/25/2019 Added the overall batch test test name type ID and name.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     09/14/2019 Added pagination set 0 to bring back "all" records.
-- Stephen Long     01/22/2020 Added site list parameter for site filtration.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     04/23/2020 Correction on disease ID and disease name; add vector surveillance 
--                             session.
-- Stephen Long     04/26/2020 Added sent to organization ID to the model.
-- Stephen Long     11/28/2020 Added configurable site filtration rules.
-- Stephen Long     12/16/2020 Changed join for vector surveillance session diseases to the sample
--                             table.
-- Stephen Long     12/31/2020 Change function on reference data to handle inactive records.
-- Mark Wilson		08/16/2021 Join tlbMonitoringSessionToDiagnosis to get diagnosis
-- Stephen Long     09/25/2021 Added new pagination and order by.
-- Stephen Long     12/08/2021 Changed pagination logic and removed option recompile.
-- Stephen Long     04/21/2022 Added final results to remove duplicates from filtration.
-- Stephen Long     07/26/2022 Changed from repair to reference repair function.
-- Stephen Long     08/08/2022 Added where criteria to only return batches with tests.
-- Stephen Long     10/24/2022 Moved where clause check on tests count to insert of final results.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/12/2023 Updated for site filtration queries.
--
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_LAB_BATCH_GETList]
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
CREATE PROCEDURE [dbo].[USP_LAB_BATCH_GETList]
(
    @LanguageID NVARCHAR(50),
    @UserID BIGINT,
    @UserEmployeeID BIGINT,
    @UserOrganizationID BIGINT = NULL,
    @UserSiteID BIGINT,
    @UserSiteGroupID BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        BatchStatusTypeID BIGINT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL,
        BatchStatusTypeID BIGINT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL,
        TestsCount INT NOT NULL
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
    DECLARE @Favorites XML,
            @InProgressCount INT = 0;

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

        SET @Favorites =
        (
            SELECT PreferenceDetail
            FROM dbo.UserPreference Laboratory
            WHERE idfUserID = @UserID
                  AND ModuleConstantID = 10508006
                  AND intRowStatus = 0
        );

        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbBatchTest b
        WHERE b.idfPerformedByOffice = @UserOrganizationID
              AND b.idfsSite = @UserSiteID
              AND b.intRowStatus = 0;

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
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               ar.ReadPermissionIndicator,
               ar.AccessToPersonalDataPermissionIndicator,
               ar.AccessToGenderAndAgeDataPermissionIndicator,
               ar.WritePermissionIndicator,
               ar.DeletePermissionIndicator
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
              AND @UserSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               ar.ReadPermissionIndicator,
               ar.AccessToPersonalDataPermissionIndicator,
               ar.AccessToGenderAndAgeDataPermissionIndicator,
               ar.WritePermissionIndicator,
               ar.DeletePermissionIndicator
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
              AND ar.GrantingActorSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's employee group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               ar.ReadPermissionIndicator,
               ar.AccessToPersonalDataPermissionIndicator,
               ar.AccessToGenderAndAgeDataPermissionIndicator,
               ar.WritePermissionIndicator,
               ar.DeletePermissionIndicator
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
              AND ar.GrantingActorSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's ID level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               ar.ReadPermissionIndicator,
               ar.AccessToPersonalDataPermissionIndicator,
               ar.AccessToGenderAndAgeDataPermissionIndicator,
               ar.WritePermissionIndicator,
               ar.DeletePermissionIndicator
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
              AND ar.GrantingActorSiteGroupID IS NOT NULL
              AND ar.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               ar.ReadPermissionIndicator,
               ar.AccessToPersonalDataPermissionIndicator,
               ar.AccessToGenderAndAgeDataPermissionIndicator,
               ar.WritePermissionIndicator,
               ar.DeletePermissionIndicator
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
              AND @UserSiteGroupID IS NOT NULL
              AND sgs.idfsSite = b.idfsSite;

        -- 
        -- Apply at the user's site level, granted by a site.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
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
            INNER JOIN dbo.tlbBatchTest b
                ON b.intRowStatus = 0
        WHERE ar.GrantingActorSiteID IS NOT NULL
              AND b.idfsSite = ar.GrantingActorSiteID;

        -- 
        -- Apply at the user's employee group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
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
            INNER JOIN dbo.tlbBatchTest b
                ON b.intRowStatus = 0
        WHERE ar.GrantingActorSiteID IS NOT NULL
              AND b.idfsSite = ar.GrantingActorSiteID;

        -- 
        -- Apply at the user's ID level, granted by a site.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
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
            INNER JOIN dbo.tlbBatchTest b
                ON b.intRowStatus = 0
        WHERE ar.GrantingActorSiteID IS NOT NULL
              AND b.idfsSite = ar.GrantingActorSiteID;

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

        INSERT INTO @FinalResults
        SELECT ID,
               MAX(res.BatchStatusTypeID),
               MAX(ReadPermissionIndicator),
               MAX(AccessToPersonalDataPermissionIndicator),
               MAX(AccessToGenderAndAgeDataPermissionIndicator),
               MAX(WritePermissionIndicator),
               MAX(DeletePermissionIndicator),
               (
                   SELECT COUNT(idfTesting)
                   FROM dbo.tlbTesting
                   WHERE idfBatchTest = res.ID
                         AND intRowStatus = 0
               ) AS TestsCount
        FROM @Results res
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
        GROUP BY ID;

        DELETE FROM @FinalResults
        WHERE TestsCount = 0;

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        SET @InProgressCount =
        (
            SELECT IIF(
                       SUM(   CASE
                                  WHEN BatchStatusTypeID = 10001003 --In Progress
                              THEN
                                      1
                                  ELSE
                                      0
                              END
                          ) IS NULL,
                       0,
                       SUM(   CASE
                                  WHEN BatchStatusTypeID = 10001003 --In Progress
                              THEN
                                      1
                                  ELSE
                                      0
                              END
                          ))
            FROM @FinalResults res
                INNER JOIN dbo.tlbBatchTest b
                    ON b.idfBatchTest = res.ID
                       AND b.intRowStatus = 0
            WHERE b.idfPerformedByOffice = @UserOrganizationID
                  AND b.idfsSite = @UserSiteID
                  AND b.intRowStatus = 0
                  AND
                  (
                      SELECT COUNT(t.idfTesting)
                      FROM dbo.tlbTesting t
                      WHERE t.idfBatchTest = b.idfBatchTest
                  ) > 0
        );

        SELECT b.idfBatchTest AS BatchTestID,
               b.strBarcode AS EIDSSBatchTestID,
               b.idfsBatchStatus AS BatchStatusTypeID,
               batchStatusType.name AS BatchStatusTypeName,
               b.idfPerformedByOffice AS PerformedByOrganizationID,
               b.idfPerformedByPerson AS PerformedByPersonID,
               b.idfResultEnteredByOffice AS ResultEnteredByOrganizationID,
               b.idfResultEnteredByPerson AS ResultEnteredByPersonID,
               b.idfValidatedByOffice AS ValidatedByOrganizationID,
               b.idfValidatedByPerson AS ValidatedByPersonID,
               b.idfsTestName AS BatchTestTestNameTypeID,
               batchTestTestNameType.name AS BatchTestTestNameTypeName,
               b.TestRequested,
               b.idfObservation AS ObservationID,
               b.datPerformedDate AS PerformedDate,
               b.datValidatedDate AS ValidationDate,
               b.idfsSite AS SiteID,
               (
                   SELECT TOP 1
                       idfsDiagnosis
                   FROM dbo.tlbTesting
                   WHERE idfBatchTest = b.idfBatchTest
                         AND intRowStatus = 0
               ) AS DiseaseID,
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
               @InProgressCount AS InProgressCount,
               res.TestsCount
        FROM @FinalResults res
            INNER JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = res.ID
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) batchTestTestNameType
                ON batchTestTestNameType.idfsReference = b.idfsTestName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) batchStatusType
                ON batchStatusType.idfsReference = b.idfsBatchStatus;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
