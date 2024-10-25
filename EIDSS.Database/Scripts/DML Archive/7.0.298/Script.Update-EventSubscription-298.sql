/*
Author:			Stephen Long
Date:			10/07/2022
Description:	Update records in EventSubscription to pick all site alert event types for all users.
Note:           -Be sure the record exists in table
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

DECLARE @UserTable TABLE (UserID BIGINT NOT NULL);
DECLARE @EventTypes TABLE (EventTypeID BIGINT NOT NULL);
DECLARE @UserID BIGINT;

DELETE FROM dbo.EventSubscription;

INSERT INTO @EventTypes
SELECT idfsEventTypeID
FROM dbo.trtEventType
WHERE intRowStatus = 0;

INSERT INTO @UserTable
SELECT idfUserID
FROM dbo.tstUserTable
WHERE intRowStatus = 0;

WHILE EXISTS (SELECT * FROM @UserTable)
BEGIN
    SELECT TOP 1
        @UserID = UserID
    FROM @UserTable;

    INSERT INTO dbo.EventSubscription
    (
        EventNameID,
        ReceiveAlertFlag,
        AlertRecipient,
        intRowStatus,
        strMaintenanceFlag,
        strReservedAttribute,
        AuditCreateDTM,
        AuditCreateUser,
        AuditUpdateDTM,
        AuditUpdateUser,
        SourceSystemKeyValue,
        SourceSystemNameID,
        idfUserID
    )
    SELECT et.EventTypeID,
           1,
           NULL,
           0,
           NULL,
           NULL,
           GETDATE(),
           'longs',
           GETDATE(),
           'longs',
           '[{"EventNameID":' + CAST(et.EventTypeID AS NVARCHAR(300)) + '}]',
           10519001,
           @UserID
    FROM @EventTypes et;

    DELETE FROM @UserTable
    WHERE UserID = @UserID;
END;
GO