-- ================================================================================================
-- Name: USP_ADMIN_EVENT_SET
--
-- Description:	Inserts or updates the event table for SAUC55 and SAUC56.
-- 
-- Field Notes:
--
-- Object - ID of record such as human disease report
-- LoginSite - ID of organization login site where initial event that raise notification was 
-- created.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     07/06/2022 Initial release.
-- Stephen Long     07/11/2022 Added third party site alert events.
-- Stephen Long     07/12/2022 Added vector surveillance session third party site alerts.
-- Stephen Long     09/15/2022 Added note parameter.  Temporarily removed!
-- Stephen Long     10/05/2022 Fix for event type ID when third party site event is already passed 
--                             in, and where from site ID to login site ID on event users.
-- Stephen Long     03/13/2023 Changed site ID where criteria from the user table to the employee 
--                             table as user table's site ID was no longer getting updated.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EVENT_SET]
(
    @EventId BIGINT,
    @EventTypeId BIGINT,
    @UserId BIGINT,
    @ObjectId BIGINT = NULL,
    @DiseaseId BIGINT = NULL,
    @SiteId BIGINT = NULL,
    @InformationString NVARCHAR(MAX) = NULL,
    --@Note NVARCHAR(MAX) = NULL, 
    @LoginSiteId BIGINT = NULL,
    @LocationId BIGINT = NULL,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ReturnCode INT = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
                @NeighboringSiteId BIGINT = NULL,
                @EventUserId BIGINT = NULL,
                @EventSiteId BIGINT = NULL;
        DECLARE @EventUsers TABLE
        (
            UserId BIGINT NOT NULL,
            SiteId BIGINT NOT NULL
        );
        DECLARE @NeighboringSites TABLE
        (
            AccessRuleId BIGINT,
            SiteId BIGINT
        );
        DECLARE @SiteAccessRuleGrantee TABLE (AccessRuleId BIGINT);

        -- Get all users of the target site that have subscribed to the notification type.
        INSERT INTO @EventUsers
        SELECT u.idfUserID,
               e.idfsSite
        FROM dbo.tstUserTable u
            INNER JOIN dbo.EventSubscription es
                ON es.idfUserID = u.idfUserID
                   AND es.EventNameID = @EventTypeId
            INNER JOIN dbo.tlbEmployee e 
                   ON e.idfEmployee = u.idfPerson
        WHERE e.idfsSite = @LoginSiteId
              AND u.intRowStatus = 0
              AND es.ReceiveAlertFlag = 1;

        -- Get all users of the target site's neighboring sites based on filtration rules.
        -- Logged in user site ID is a grantor, then get list of grantee sites.
        INSERT INTO @NeighboringSites
        SELECT ar.AccessRuleID,
               ara.ActorSiteID
        FROM dbo.AccessRule ar
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.AccessRuleID = ar.AccessRuleID
                   AND ara.intRowStatus = 0
        WHERE ar.intRowStatus = 0
              AND ar.BorderingAreaRuleIndicator = 1
              AND ar.GrantingActorSiteID = @LoginSiteId
              AND ara.ActorSiteID IS NOT NULL
              AND ara.ActorSiteID <> @LoginSiteId
        GROUP BY ara.ActorSiteID,
                 ar.AccessRuleID;

        -- Logged in user site ID access rules as a grantee.
        INSERT INTO @SiteAccessRuleGrantee
        SELECT ara.AccessRuleID
        FROM dbo.AccessRuleActor ara
            INNER JOIN dbo.AccessRule ar
                ON ar.AccessRuleID = ara.AccessRuleID
                   AND ar.intRowStatus = 0
        WHERE ara.ActorSiteID = @LoginSiteId
              AND ara.intRowStatus = 0
              AND ar.BorderingAreaRuleIndicator = 1;

        -- Select all grantee sites that the site is also a grantee of.
        INSERT INTO @NeighboringSites
        SELECT sg.AccessRuleID,
               ara.ActorSiteID
        FROM @SiteAccessRuleGrantee sg
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.AccessRuleID = sg.AccessRuleID
                   AND ara.intRowStatus = 0
        WHERE ara.ActorSiteID <> @LoginSiteId
              AND ara.ActorSiteID IS NOT NULL
        GROUP BY ara.ActorSiteID,
                 sg.AccessRuleID;

        WHILE EXISTS (SELECT * FROM @NeighboringSites)
        BEGIN
            SELECT TOP 1
                @NeighboringSiteId = SiteId
            FROM @NeighboringSites;

            -- Get all users of the neighboring site.
            INSERT INTO @EventUsers
            SELECT u.idfUserID,
                   e.idfsSite
            FROM dbo.tstUserTable u
                INNER JOIN dbo.EventSubscription es
                    ON es.idfUserID = u.idfUserID
                       AND es.EventNameID = @EventTypeId
                INNER JOIN dbo.tlbEmployee e 
                   ON e.idfEmployee = u.idfPerson
            WHERE e.idfsSite = @NeighboringSiteId
                  AND u.intRowStatus = 0
                  AND es.ReceiveAlertFlag = 1;

            DELETE FROM @NeighboringSites
            WHERE SiteID = @NeighboringSiteId;
        END

        WHILE EXISTS (SELECT * FROM @EventUsers)
        BEGIN
            SELECT TOP 1
                @EventUserId = UserId,
                @EventSiteId = SiteId
            FROM @EventUsers;

            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tstEvent', @EventId OUTPUT;

            -- Change to the third party site alert/event type id.
            IF @EventSiteId <> @SiteId
            BEGIN
                SET @EventTypeId = CASE WHEN @EventTypeId = 10025503 THEN
                    10025504
                WHEN @EventTypeId = 10025501 THEN
                    10025502
                WHEN @EventTypeId = 10025505 THEN
                    10025506
                WHEN @EventTypeId = 10025507 THEN
                    10025508
                WHEN @EventTypeId = 10025509 THEN
                    10025512
                WHEN @EventTypeId = 10025510 THEN
                    10025511
                WHEN @EventTypeId = 10025037 THEN
                    10025038
                WHEN @EventTypeId = 10025041 THEN
                    10025042
                WHEN @EventTypeId = 10025043 THEN
                    10025044
                WHEN @EventTypeId = 10025045 THEN
                    10025046
                WHEN @EventTypeId = 10025047 THEN
                    10025048
                WHEN @EventTypeId = 10025077 THEN
                    10025078
                WHEN @EventTypeId = 10025079 THEN
                    10025080
                WHEN @EventTypeId = 10025081 THEN
                    10025082
                WHEN @EventTypeId = 10025099 THEN
                    10025100
                WHEN @EventTypeId = 10025097 THEN
                    10025098
                WHEN @EventTypeId = 10025129 THEN
                    10025130
                WHEN @EventTypeId = 10025101 THEN
                    10025102
                WHEN @EventTypeId = 10025103 THEN
                    10025104
                WHEN @EventTypeId = 10025105 THEN
                    10025106
                WHEN @EventTypeId = 10025107 THEN
                    10025108
                WHEN @EventTypeId = 10025085 THEN
                    10025086
                WHEN @EventTypeId = 10025087 THEN
                    10025088
                WHEN @EventTypeId = 10025089 THEN
                    10025090
                WHEN @EventTypeId = 10025091 THEN
                    10025092
                WHEN @EventTypeId = 10025093 THEN
                    10025094
                WHEN @EventTypeId = 10025095 THEN
                    10025096
                WHEN @EventTypeId = 10025067 THEN
                    10025068
                WHEN @EventTypeId = 10025071 THEN
                    10025072
                WHEN @EventTypeId = 10025073 THEN
                    10025074
                WHEN @EventTypeId = 10025075 THEN
                    10025076
                WHEN @EventTypeId = 10025513 THEN
                    10025514
                WHEN @EventTypeId = 10025517 THEN
                    10025518
                WHEN @EventTypeId = 10025519 THEN
                    10025520
                WHEN @EventTypeId = 10025525 THEN
                    10025526
                WHEN @EventTypeId = 10025049 THEN
                    10025050
                WHEN @EventTypeId = 10025051 THEN
                    10025052
                WHEN @EventTypeId = 10025053 THEN
                    10025054
                WHEN @EventTypeId = 10025055 THEN
                    10025056
                WHEN @EventTypeId = 10025057 THEN
                    10025058
                WHEN @EventTypeId = 10025059 THEN
                    10025060
                WHEN @EventTypeId = 10025061 THEN
                    10025062
                WHEN @EventTypeId = 10025065 THEN
                    10025066
                WHEN @EventTypeId = 10025069 THEN
                    10025070
                WHEN @EventTypeId = 10025527 THEN
                    10025528
                WHEN @EventTypeId = 10025529 THEN
                    10025530
                WHEN @EventTypeId = 10025537 THEN
                    10025538
                WHEN @EventTypeId = 10025539 THEN
                    10025540
                WHEN @EventTypeId = 10025563 THEN
                    10025564
                ELSE
                    @EventTypeId
                END
            END

            INSERT INTO dbo.tstEvent
            (
                idfEventID,
                idfsEventTypeID,
                idfObjectID,
                strInformationString,
                --strNote, 
                datEventDatatime,
                idfUserID,
                intProcessed,
                idfsSite,
                idfsDiagnosis,
                idfsLoginSite,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateDTM,
                AuditCreateUser,
                idfsLocation
            )
            VALUES
            (@EventId,
             @EventTypeId,
             @ObjectId,
             @InformationString,
             --@Note, 
             GETDATE(),
             @EventUserId,
             0  ,
             @EventSiteId,
             @DiseaseId,
             @LoginSiteId,
             10519001,
             '[{"idfEventID":' + CAST(@EventId AS NVARCHAR(300)) + '}]',
             GETDATE(),
             @AuditUserName,
             @LocationId
            );

            DELETE FROM @EventUsers
            WHERE UserId = @EventUserId
                  AND SiteId = @EventSiteId;
        END;
    END TRY
    BEGIN CATCH
        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        THROW;
    END CATCH;

    SELECT @ReturnCode ReturnCode,
           @ReturnMessage ReturnMessage;
END;
