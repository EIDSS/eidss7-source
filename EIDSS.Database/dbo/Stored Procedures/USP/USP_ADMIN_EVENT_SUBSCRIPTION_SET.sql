-- ================================================================================================
-- Name: USP_ADMIN_EVENT_SUBSCRIPTION_SET
--
-- Description: Saves Entries For Event Subscriptions
--
-- Author: Stephen Long
--
-- Revision History:
-- Name                   Date       Change Detail
-- ---------------------- ---------- -------------------------------------------------------------
-- Stephen Long           07/01/2022 Initial release
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EVENT_SUBSCRIPTION_SET] (
    @Subscriptions NVARCHAR(MAX) NULL,
    @UserName NVARCHAR(200)
    )
AS
BEGIN
    DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS';
    DECLARE @ReturnCode BIGINT = 0;

    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @SubscriptionsTemp TABLE
        (
            RowId INT,
            EventTypeId BIGINT,
            ReceiveAlertIndicator BIT,
            UserId BIGINT
        )

        INSERT INTO @SubscriptionsTemp
        (
            RowId,
            EventTypeId,
            ReceiveAlertIndicator,
            UserId
        )
        SELECT RowId,
               EventTypeId,
               ReceiveAlertIndicator,
               UserId
        FROM
            OPENJSON(@Subscriptions)
            WITH
            (
                RowId INT,
                EventTypeId BIGINT,
                ReceiveAlertIndicator BIT,
                UserId BIGINT
            );

        DECLARE @RowCount INT = 0;
        DECLARE @EventTypeId BIGINT;
        DECLARE @ReceiveAlertIndicator BIT;
        DECLARE @UserId BIGINT;

        SET @RowCount =
        (
            SELECT MAX(RowId) FROM @SubscriptionsTemp
        );

        DECLARE @_int INT = 0;
        
        WHILE @_int <= @RowCount
        BEGIN
            SET @EventTypeId =
            (
                SELECT EventTypeId FROM @SubscriptionsTemp WHERE RowId = @_int
            );
            SET @ReceiveAlertIndicator =
            (
                SELECT ReceiveAlertIndicator FROM @SubscriptionsTemp WHERE RowId = @_int
            );
            SET @UserId = 
            (
                SELECT UserId FROM @SubscriptionsTemp WHERE RowId = @_int
            );

            IF EXISTS
            (
                SELECT *
                FROM dbo.EventSubscription
                WHERE EventNameID =
                (
                    SELECT EventTypeId FROM @SubscriptionsTemp WHERE EventTypeId = @EventTypeId AND UserId = @UserId
                ) AND idfUserID = @UserId
            )
            BEGIN
                UPDATE dbo.EventSubscription
                SET intRowStatus = 0,
                    ReceiveAlertFlag = @ReceiveAlertIndicator,
                    idfUserID = @UserId, 
                    AuditUpdateUser = @UserName,
                    AuditUpdateDTM = GETDATE()
                WHERE EventNameID = @EventTypeId 
                      AND idfUserID = @UserId 
            END
            ELSE
            BEGIN
                INSERT INTO dbo.EventSubscription
                (
                    EventNameID,
                    ReceiveAlertFlag,
                    AuditCreateUser,
                    AuditCreateDTM,
                    intRowStatus,
                    idfUserID, 
                    SourceSystemNameID
                )
                SELECT EventTypeID,
                       ReceiveAlertIndicator,
                       @UserName,
                       GETDATE(),
                       0,
                       @UserId, 
                       10519001
                FROM @SubscriptionsTemp
                WHERE RowId = @_int;
            END

            SET @_int = @_int + 1;
        END

        SELECT @ReturnCode 'ReturnCode',
               @ReturnMessage 'ReturnMessage';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
