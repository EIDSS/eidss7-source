-- ================================================================================================
-- Name: USP_ADMIN_EVENT_GETCount		
--
-- Description: Gets a count of event notifications for a user as defined in SAUC55 and SAUC56.
--
-- Author: Stephen Long
-- 
-- Revision History:
-- Name                        Date       Change Detail
-- --------------------------- ---------- --------------------------------------------------------
-- Stephen Long                03/17/2023 Initial release
-- Stephen Long                03/22/2023 Added nolock
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EVENT_GETCount]
(
    @LanguageId NVARCHAR(50),
    @UserId BIGINT,
    @DaysFromReadDate INT
)
AS
BEGIN
    BEGIN TRY
        SELECT COUNT(e.idfEventID) AS EventCount
        FROM dbo.tstEvent e WITH (NOLOCK)
            INNER JOIN dbo.trtEventType et
                ON et.idfsEventTypeID = e.idfsEventTypeID
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000155) notificationType
                ON notificationType.idfsReference = et.idfsEventSubscription
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000025) eventType
                ON eventType.idfsReference = e.idfsEventTypeID
        WHERE e.idfUserID = @UserId
              AND e.intProcessed = 0;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END