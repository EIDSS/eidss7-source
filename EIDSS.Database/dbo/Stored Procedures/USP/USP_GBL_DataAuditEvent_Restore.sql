-- ================================================================================================
-- Author:		Manickandan Govindarajan
-- Create date: 11/14/2022
-- Description:	Restore Data Audit 
-- 
-- Revision History:
-- Name                     Date       Change
-- ------------------------ ---------- -----------------------------------------------------------
-- Mike Kornegay            11/17/2022 Remove CONCAT in dynamic query string.
-- Manickandan Govindarajan 11/17/2022 changed the field type of @Object
-- Manickandan Govindarajan 11/17/2022 Added logic to find the selected record is restored already
-- Stephen Long             03/08/2023 Fix to pass strMainObject to restore data audit event.
-- 
-- exec USP_GBL_DataAuditEvent_Restore 58397190000001, 1100 ,155576240001452
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_DataAuditEvent_Restore]
    @UserId BIGINT,
    @SiteId BIGINT,
    @idfDataAuditEvent BIGINT
AS
BEGIN
    DECLARE @tauDataAuditDetailDeleteTable AS TABLE
    (
        idfObjectTable BIGINT,
        idfObject BIGINT,
        idfObjectTableName VARCHAR(255)
    );

    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage VARCHAR(200)
    );

    DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS';
    DECLARE @returnCode BIGINT = 0;
    DECLARE @idfsDataAuditEventType BIGINT = 10016005;
    DECLARE @idfsObjectType BIGINT;
    DECLARE @idfObject BIGINT;
    DECLARE @idfObjectTable BIGINT;
    DECLARE @auditEventId BIGINT;
    DECLARE @primaryColumnName VARCHAR(255);
    DECLARE @Cmd VARCHAR(2000);
    DECLARE @mainTableName VARCHAR(255);
    DECLARE @mainObject VARCHAR(255);
    DECLARE @strMainObject NVARCHAR(200);
    DECLARE @SQL NVARCHAR(2000);
    DECLARE @Param NVARCHAR(200);
    DECLARE @intRowStatus INT = -1;
    DECLARE @maxIdfDataAuditEvent BIGINT;

    SET NOCOUNT ON;

    BEGIN TRY
        SELECT @mainTableName = tt.strName,
               @mainObject = au.idfMainObject
        FROM dbo.tauDataAuditEvent au
            INNER JOIN dbo.tauTable tt
                ON au.idfMainObjectTable = tt.idfTable
        WHERE au.idfDataAuditEvent = @idfDataAuditEvent;

        SELECT @maxIdfDataAuditEvent = MAX(idfDataAuditEvent)
        FROM dbo.tauDataAuditEvent
        WHERE idfMainObject = @mainObject;
        IF (@maxIdfDataAuditEvent = @idfDataAuditEvent)
        BEGIN
            SELECT @primaryColumnName = C.COLUMN_NAME
            FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS T
                JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE C
                    ON C.CONSTRAINT_NAME = T.CONSTRAINT_NAME
            WHERE C.TABLE_NAME = @mainTableName
                  AND T.CONSTRAINT_TYPE = 'PRIMARY KEY';

            SET @SQL
                = N'SELECT @intRowStatus = intRowStatus FROM ' + @mainTableName + ' WHERE ' + @primaryColumnName
                  + ' = ' + @mainObject;
            SET @Param = N'@intRowStatus INT OUTPUT';

            INSERT INTO @SuppressSelect
            EXECUTE sp_executesql @SQL, @Param, @intRowStatus = @intRowStatus OUTPUT;

            SET @SQL
                = 'UPDATE ' + @mainTableName + ' SET auditUpdateDTM = GETDATE()  WHERE ' + @primaryColumnName + ' = '
                  + @mainObject;
            EXECUTE (@SQL);

            IF (@intRowStatus = 1)
            BEGIN
                BEGIN TRANSACTION

                SELECT @idfObject = idfMainObject,
                       @idfsObjectType = idfsDataAuditObjectType,
                       @idfObjectTable = idfMainObjectTable,
                       @strMainObject = strMainObject
                FROM dbo.tauDataAuditEvent
                WHERE idfDataAuditEvent = @idfDataAuditEvent;

                INSERT INTO @tauDataAuditDetailDeleteTable
                (
                    idfObjectTableName,
                    idfObject,
                    idfObjectTable
                )
                SELECT tt.strName,
                       d.idfObject,
                       d.idfObjectTable
                FROM dbo.tauDataAuditDetailDelete d
                    INNER JOIN dbo.tauTable tt
                        on d.idfObjectTable = tt.idfTable
                WHERE d.idfDataAuditEvent = @idfDataAuditEvent;

                DECLARE restore_cursor CURSOR FOR
                SELECT idfObjectTable,
                       idfObject,
                       idfObjectTableName
                FROM @tauDataAuditDetailDeleteTable;

                OPEN restore_cursor;
                DECLARE @ObjectTable BIGINT;
                DECLARE @Object VARCHAR(100);
                DECLARE @ObjectTableName VARCHAR(255);
                FETCH NEXT FROM restore_cursor
                INTO @ObjectTable,
                     @Object,
                     @ObjectTableName
                WHILE (@@FETCH_STATUS = 0)
                BEGIN
                    SELECT @primaryColumnName = C.COLUMN_NAME
                    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS T
                        JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE C
                            ON C.CONSTRAINT_NAME = T.CONSTRAINT_NAME
                    WHERE C.TABLE_NAME = @ObjectTableName
                          AND T.CONSTRAINT_TYPE = 'PRIMARY KEY';

                    SET @Cmd
                        = 'UPDATE ' + @ObjectTableName + ' SET intRowStatus = 0 WHERE ' + @primaryColumnName + ' = '
                          + @Object;
                    EXECUTE (@Cmd);
                    FETCH NEXT FROM restore_cursor
                    INTO @ObjectTable,
                         @Object,
                         @ObjectTableName;
                END
                CLOSE restore_cursor;
                DEALLOCATE restore_cursor;

                INSERT INTO @SuppressSelect
                -- Get the current event id for this user from the local context table...
                EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @UserId,
                                                          @SiteId,
                                                          @idfsDataAuditEventType,
                                                          @idfsObjectType,
                                                          @idfObject,
                                                          @idfObjectTable,
                                                          @strMainObject,
                                                          @auditEventId OUTPUT;

                IF @@TRANCOUNT > 0
                BEGIN
                    COMMIT;
                END

                SELECT @ReturnCode ReturnCode,
                       @returnMsg ReturnMessage,
                       @intRowStatus RecordStatus;
            END
            ELSE
            BEGIN
                SET @intRowStatus = 0;
                SELECT @ReturnCode ReturnCode,
                       @returnMsg ReturnMessage,
                       @intRowStatus RecordStatus;
            END
        END
        ELSE
        BEGIN
            SET @intRowStatus = 0;
            SELECT @ReturnCode ReturnCode,
                   @returnMsg ReturnMessage,
                   @intRowStatus RecordStatus;
        END
    END TRY
    BEGIN CATCH
        SET @returnCode = ERROR_NUMBER();
        SET @returnMsg
            = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: '
              + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
              + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: '
              + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();

        SELECT @returnCode 'ReturnCode',
               @returnMsg 'ReturnMessage',
               @intRowStatus RecordStatus;

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH
END