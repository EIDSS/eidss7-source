-- ================================================================================================
-- Name: USSP_ADMIN_FF_DATA_AUDIT_SET
--
-- Description:	Inserts or updates data audit records for all activity parameters of an 
-- observation record.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/28/2022 Initial release.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_ADMIN_FF_DATA_AUDIT_SET]
    @AuditUserName NVARCHAR(200),
    @DataAuditEventID BIGINT,
    @ObservationID BIGINT
AS
DECLARE @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @ObjectID BIGINT = NULL,
        @ObjectTableID BIGINT = 75410000000, -- tlbActivityParameters
        @ActivityParameterID BIGINT,
        @AnswerValue SQL_VARIANT;
DECLARE @ActivityParameters TABLE
(
    ActivityParameterID BIGINT,
    AnswerValue SQL_VARIANT
);
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        INSERT INTO @ActivityParameters
        SELECT idfActivityParameters,
               varValue
        FROM dbo.tlbActivityParameters
        WHERE idfObservation = @ObservationID
              AND intRowStatus = 0;

        WHILE EXISTS (SELECT * FROM @ActivityParameters)
        BEGIN
            SELECT TOP 1
                @ActivityParameterID = ActivityParameterID,
                @AnswerValue = AnswerValue
            FROM @ActivityParameters;

            INSERT INTO dbo.tauDataAuditDetailCreate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser
            )
            VALUES
            (@DataAuditEventID,
             @ObjectTableID,
             @ActivityParameterID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName
            );

            DELETE FROM @ActivityParameters
            WHERE ActivityParameterID = @ActivityParameterID;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;