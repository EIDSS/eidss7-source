-- ================================================================================================
-- Name: USP_GBL_NOTIFICATION_SET
--
-- Description:	Inserts or updates notification, notification shared and notification filtered for 
-- various use cases.
-- 
-- Field Notes:
--
-- Notification Object - ID of record such as human disease report
-- Notification Object Type - type of record associated with the object such as human disease 
-- report, veterinary disease report, outbreak, etc.
-- Target User ID - currently not used.
-- Target Site - currenty not used.
-- Target Site Type - currently not used.
-- Entering date - date when notification was created first time (for notification that are 
-- transferred from intermediate sites).
-- strPayload - custom data related with notification
-- LoginSite - ID of organization login site where initial event that raise notification was 
-- created.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/01/2018 Initial release.
-- Stephen Long     02/04/2019 Revamped for new API.
-- Stephen Long     03/01/2019 Made notification ID required.
-- Stephen Long     09/24/2021 Removed language parameter as it is not needed. Added audit user 
--                             name.
-- Stephen Long     01/03/2022 Removed transaction as this should be called from another stored 
--                             procedure; not directly from the application/API.
-- Stephen Long     07/06/2022 Added notification user and neighboring site to get all users of the
--                             target site and any neighboring sites set by filtration rules.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_NOTIFICATION_SET]
(
    @NotificationID BIGINT OUTPUT,
    @NotificationTypeID BIGINT = NULL,
    @UserID BIGINT = NULL,
    @NotificationObjectID BIGINT = NULL,
    @NotificationObjectTypeID BIGINT = NULL,
    @TargetUserID BIGINT = NULL,
    @TargetSiteID BIGINT = NULL,
    @TargetSiteTypeID BIGINT = NULL,
    @SiteID BIGINT = NULL,
    @Payload NVARCHAR(MAX) = NULL,
    @LoginSite NVARCHAR(20) = NULL,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ReturnCode INT = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
                @NeighboringSiteID BIGINT = NULL,
                @NotificationUserID BIGINT = NULL,
                @NotificationSiteID BIGINT = NULL,
                @NotificationSiteTypeID BIGINT = NULL;
        DECLARE @NotificationUsers TABLE
        (
            UserID BIGINT NOT NULL,
            SiteID BIGINT NOT NULL,
            SiteTypeID BIGINT NOT NULL
        );
        DECLARE @NeighboringSites TABLE (
    		AccessRuleID BIGINT, 
	    	SiteID BIGINT
	    );
	    DECLARE @SiteAccessRuleGrantee TABLE (
		    AccessRuleID BIGINT
	    );

        -- Get all users of the target site that have subscribed to the notificatio type.
        INSERT INTO @NotificationUsers
        SELECT u.idfUserID,
               u.idfsSite,
               s.idfsSiteType
        FROM dbo.tstUserTable u
            INNER JOIN dbo.tstSite s
                ON s.idfsSite = u.idfsSite
            INNER JOIN dbo.EventSubscription e
                ON e.idfUserID = u.idfUserID
                   AND e.EventNameID = @NotificationTypeID
        WHERE u.idfsSite = @TargetSiteID
              AND u.intRowStatus = 0
              AND e.ReceiveAlertFlag = 1;

        -- Get all users of the target site's neighboring sites based on filtration rules.
        -- Logged in user site ID is a grantor, then get list of grantee sites.
		INSERT INTO @NeighboringSites
		SELECT ar.AccessRuleID,
			ara.ActorSiteID
		FROM dbo.AccessRule ar
		INNER JOIN dbo.AccessRuleActor ara ON ara.AccessRuleID = ar.AccessRuleID
			AND ara.intRowStatus = 0
		WHERE ar.intRowStatus = 0
			AND ar.BorderingAreaRuleIndicator = 1		
			AND ar.GrantingActorSiteID = @SiteID
			AND ara.ActorSiteID IS NOT NULL
			AND ara.ActorSiteID <> @SiteID
		GROUP BY ara.ActorSiteID, 
			ar.AccessRuleID;

		-- Logged in user site ID access rules as a grantee.
		INSERT INTO @SiteAccessRuleGrantee
		SELECT ara.AccessRuleID
		FROM dbo.AccessRuleActor ara
		INNER JOIN dbo.AccessRule ar ON ar.AccessRuleID = ara.AccessRuleID 
			AND ar.intRowStatus = 0
		WHERE ara.ActorSiteID = @SiteID
			AND ara.intRowStatus = 0
			AND ar.BorderingAreaRuleIndicator = 1;

		-- Select all grantee sites that the site is also a grantee of.
		INSERT INTO @NeighboringSites
		SELECT sg.AccessRuleID, 
			ara.ActorSiteID 
		FROM @SiteAccessRuleGrantee sg
		INNER JOIN dbo.AccessRuleActor ara ON ara.AccessRuleID = sg.AccessRuleID
			AND ara.intRowStatus = 0
		WHERE ara.ActorSiteID <> @SiteID 
			AND ara.ActorSiteID IS NOT NULL 
		GROUP BY ara.ActorSiteID, 
			sg.AccessRuleID;

        WHILE EXISTS (SELECT * FROM @NeighboringSites)
        BEGIN
            SELECT TOP 1
                @NeighboringSiteID = SiteID
            FROM @NeighboringSites;

            -- Get all users of the neighboring site.
            INSERT INTO @NotificationUsers
            SELECT u.idfUserID,
                   u.idfsSite,
                   s.idfsSiteType
            FROM dbo.tstUserTable u
                INNER JOIN dbo.tstSite s
                    ON s.idfsSite = u.idfsSite
                INNER JOIN dbo.EventSubscription e
                    ON e.idfUserID = u.idfUserID
                       AND e.EventNameID = @NotificationTypeID
            WHERE u.idfsSite = @NeighboringSiteID
                  AND u.intRowStatus = 0
                  AND e.ReceiveAlertFlag = 1;

            DELETE FROM @NeighboringSites
            WHERE SiteID = @NeighboringSiteID;
        END

        IF NOT EXISTS
        (
            SELECT *
            FROM dbo.tstNotification
            WHERE idfNotification = @NotificationID
        )
        BEGIN
            WHILE EXISTS (SELECT * FROM @NotificationUsers)
            BEGIN
                SELECT TOP 1
                    @NotificationUserID = UserID,
                    @NotificationSiteID = SiteID,
                    @NotificationSiteTypeID = SiteTypeID
                FROM @NotificationUsers;

                EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tstNotification',
                                                  @NotificationID OUTPUT;

                INSERT INTO dbo.tstNotificationStatus
                (
                    idfNotification,
                    intProcessed,
                    AuditCreateDTM,
                    AuditCreateUser
                )
                VALUES
                (@NotificationID, 0, GETDATE(), @AuditUserName);

                -- Notifications are added to tstNotificationShared if the notification must be replicated to all sites.
                -- Currently these notification types are: Reference Table Change, AVR Update and Settlement Change.
                IF (@NotificationTypeID IN (   10056001,
                                                        -- Reference Table Change
                                               10056013,
                                                        -- AVR Update
                                               10056014 -- Settlement Change
                                           )
                   )
                BEGIN
                    INSERT INTO dbo.tstNotificationShared
                    (
                        idfNotificationShared,
                        idfsNotificationObjectType,
                        idfsNotificationType,
                        idfsTargetSiteType,
                        idfUserID,
                        idfNotificationObject,
                        idfTargetUserID,
                        idfsTargetSite,
                        idfsSite,
                        datCreationDate,
                        datEnteringDate,
                        strPayload,
                        strMaintenanceFlag,
                        AuditCreateDTM,
                        AuditCreateUser
                    )
                    VALUES
                    (@NotificationID,
                     @NotificationObjectTypeID,
                     @NotificationTypeID,
                     @NotificationSiteTypeID,
                     @UserID,
                     @NotificationObjectID,
                     @NotificationUserID,
                     @NotificationSiteID,
                     @SiteID,
                     GETDATE(),
                     GETDATE(),
                     @Payload,
                     @LoginSite,
                     GETDATE(),
                     @AuditUserName
                    );
                END;
                ELSE
                BEGIN
                    --10056002	Test Results Received
                    --10056005	Report/Case Disease Change
                    --10056006	Report/Case Status Change
                    --10056008	Human Disease Report/Case
                    --10056011	Outbreak Report
                    --10056012	Veterinary Disease Report/Case
                    --10056062  Laboratory Test Result Rejected
                    INSERT INTO dbo.tstNotification
                    (
                        idfNotification,
                        idfsNotificationObjectType,
                        idfsNotificationType,
                        idfsTargetSiteType,
                        idfUserID,
                        idfNotificationObject,
                        idfTargetUserID,
                        idfsTargetSite,
                        idfsSite,
                        datCreationDate,
                        datEnteringDate,
                        strPayload,
                        strMaintenanceFlag,
                        AuditCreateDTM,
                        AuditCreateUser
                    )
                    VALUES
                    (@NotificationID,
                     @NotificationObjectTypeID,
                     @NotificationTypeID,
                     @NotificationSiteTypeID,
                     @UserID,
                     @NotificationObjectID,
                     @NotificationUserID,
                     @NotificationSiteID,
                     @SiteID,
                     GETDATE(),
                     GETDATE(),
                     CONVERT(TEXT, @Payload),
                     @LoginSite,
                     GETDATE(),
                     @AuditUserName
                    );
                END;

                IF (@NotificationTypeID = 10056061) -- ForcedReplicationConfirmed
                BEGIN -- Update filtration record for created notification, it will be delivered to the target site.
                    DECLARE @NotificationFilteredID BIGINT;

                    EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tflNotificationFiltered',
                                                      @NotificationFilteredID OUTPUT;

                    DECLARE @SiteGroupID BIGINT;

                    SELECT TOP 1
                        @SiteGroupID = g.idfSiteGroup
                    FROM dbo.tflSiteGroup g
                        INNER JOIN dbo.tflSiteToSiteGroup sg
                            ON sg.idfSiteGroup = g.idfSiteGroup
                        INNER JOIN dbo.tstSite s
                            ON s.idfsSite = sg.idfsSite
                    WHERE sg.idfsSite = @NotificationSiteID
                          AND g.idfsRayon IS NULL
                          AND g.idfsCentralSite IS NULL
                          AND s.idfsSiteType = 10085007; -- Create filtration record on slvl level only.

                    IF NOT @SiteGroupID IS NULL
                    BEGIN
                        INSERT INTO dbo.tflNotificationFiltered
                        (
                            idfNotificationFiltered,
                            idfNotification,
                            idfSiteGroup,
                            AuditCreateDTM,
                            AuditCreateUser
                        )
                        VALUES
                        (@NotificationFilteredID, @NotificationID, @SiteGroupID, GETDATE(), @AuditUserName);
                    END;
                END;

                DELETE FROM @NotificationUsers
                WHERE UserID = @NotificationUserID
                      AND SiteID = @NotificationSiteID;
            END;
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
