-- ================================================================================================
-- Name: USSP_GBL_OBSERVATION_SET
--
-- Description:	Inserts or updates observation records for various use cases.
--
-- Revision History:
-- Name  Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/16/2020 Initial release.
-- Stephen Long     12/08/2022 Added data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_OBSERVATION_SET]
(
    @ObservationID BIGINT OUTPUT,
    @FormTemplateID BIGINT = NULL,
    @SiteID BIGINT,
    @RowStatus INT,
    @RowAction INT,
    @AuditUserName NVARCHAR(200),
    @DataAuditEventID BIGINT,
    @EIDSSObjectID NVARCHAR(200)
)
AS
DECLARE @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectID BIGINT = NULL,
        @ObjectTableID BIGINT = 75640000000; -- tlbObservation

BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;

        IF @RowAction = 1
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbObservation', @ObservationID OUTPUT;

            INSERT INTO dbo.tlbObservation
            (
                idfObservation,
                idfsFormTemplate,
                intRowStatus,
                strMaintenanceFlag,
                idfsSite,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser
            )
            VALUES
            (@ObservationID,
             @FormTemplateID,
             @RowStatus,
             NULL,
             @SiteID,
             10519001,
             '[{"idfObservation":' + CAST(@ObservationID AS NVARCHAR(300)) + '}]',
             @AuditUserName
            );

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailCreate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                strObject
            )
            VALUES
            (@DataAuditEventID,
             @ObjectTableID,
             @ObservationID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSObjectID
            );
        -- End data audit
        END
        ELSE
        BEGIN
            UPDATE dbo.tlbObservation
            SET idfObservation = @ObservationID,
                idfsFormTemplate = @FormTemplateID,
                intRowStatus = @RowStatus,
                idfsSite = @SiteID
            WHERE idfObservation = @ObservationID;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
