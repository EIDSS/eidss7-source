-- ================================================================================================
-- Name: USP_ADMIN_EMPLOYEE_EVENTSUBSCRIPTION_SET	
-- 
-- Description:  When a new employee record is created, each event subscrption is created for that 
-- user ID.  The user can opt to turn the subscription ON or OFF.
--
-- Revision History:
--		
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mandar Kulkarni  04/20/2022 Initial release.
-- Stephen Long     06/29/2022 Added source system key value and name ID.
-- Stephen Long     07/05/2022 Switched receive alert flag to true to match the use case.
-- Stephen Long     09/01/2022 Removed transaction and rollback as this is called in a nested 
--                             manner, and changed event types table variable select from base 
--                             reference to trtEventType.
--
-- Testing Code:
-- EXEC USP_ADMIN_EMPLOYEE_EVENTSUBSCRIPTION_SET 53337910000000
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEE_EVENTSUBSCRIPTION_SET] (@idfUserID BIGINT)
AS

DECLARE @EventTypes AS TABLE (EventNameID BIGINT NOT NULL);

INSERT INTO @EventTypes
SELECT idfsEventTypeID 
FROM dbo.trtEventType
WHERE intRowStatus = 0;
BEGIN
    DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS';
    DECLARE @returnCode BIGINT = 0;
    DECLARE @EventNameID BIGINT;

    BEGIN TRY
        WHILE EXISTS (SELECT * FROM @EventTypes)
        BEGIN
            SELECT TOP 1
                @EventNameID = EventNameID
            FROM @EventTypes;

            -- Create a record for each event type for a given user if record doesn't exists.
            IF NOT EXISTS
            (
                SELECT TOP (1)
                    EventNameID
                FROM dbo.EventSubscription
                WHERE EventNameID = @EventNameID
                      AND idfUserID = @idfUserID
            )
            BEGIN
                INSERT INTO dbo.EventSubscription
                (
                    EventNameID,
                    ReceiveAlertFlag,
                    idfUserId,
                    intRowStatus,
                    rowguid,
                    AuditCreateUser,
                    AuditCreateDTM,
                    SourceSystemKeyValue,
                    SourceSystemNameID
                )
                VALUES
                (   @EventNameId, -- EventNameID - bigint
                    1,            -- ReceiveAlertFlag - bit
                    @idfUserID,   -- idfUserId BIGINT
                    0,            -- intRowStatus - int
                    NEWID(),      -- rowguid - uniqueidentifier
                    DEFAULT,      -- AuditCreateUser - nvarchar(200)
                    GETDATE(),    -- AuditCreateDTM 
                    '[{"EventNameID":' + CAST(@EventNameId AS NVARCHAR(300)) + '}]',
                    10519001
                );
            END

            DELETE TOP (1)
            FROM @EventTypes;
        END

        SELECT @returnCode as ReturnCode,
               @returnMsg as ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;

END

