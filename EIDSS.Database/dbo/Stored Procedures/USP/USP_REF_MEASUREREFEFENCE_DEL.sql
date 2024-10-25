-- ================================================================================================
-- Name: USP_REF_MEASUREREFEFENCE_DEL
-- 
-- Description:	Removes the measure type from the active measure type reference listing.
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss       10/26/2018 Initial release.
-- Stephen Long     10/31/2022 Added site alert logic.
--
-- exec USP_REF_MEASUREREFEFENCE_DEL 952180000000, 19000074, 0
-- exec USP_REF_MEASUREREFEFENCE_DEL 952250000000, 19000079, 1
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_MEASUREREFEFENCE_DEL]
(
    @IdfsAction BIGINT,
    @IdfsMeasureList BIGINT,
    @DeleteAnyway BIT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    BEGIN TRY
        DECLARE @ReturnCode INT = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );

        IF @IdfsMeasureList = 19000074
        BEGIN
            IF NOT EXISTS
            (
                SELECT idfAggrProphylacticActionMTX
                FROM dbo.tlbAggrProphylacticActionMTX
                WHERE idfsProphilacticAction = @IdfsAction
            )
               OR @DeleteAnyway = 1
            BEGIN
                UPDATE dbo.trtProphilacticAction
                SET intRowStatus = 1,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsProphilacticAction = @IdfsAction
                      AND intRowStatus = 0;

                UPDATE dbo.trtBaseReference
                SET intRowStatus = 1,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsBaseReference = @IdfsAction
                      AND intRowStatus = 0;

                UPDATE dbo.trtStringNameTranslation
                SET intRowStatus = 1,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsBaseReference = @IdfsAction
                      AND intRowStatus = 0;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                               @EventTypeId,
                                               @UserId,
                                               @IdfsAction,
                                               NULL,
                                               @SiteId,
                                               NULL,
                                               @SiteId,
                                               @LocationId,
                                               @AuditUserName;
            END
            ELSE IF EXISTS
            (
                SELECT idfAggrProphylacticActionMTX
                FROM dbo.tlbAggrProphylacticActionMTX
                WHERE idfsProphilacticAction = @IdfsAction
            )
            BEGIN
                SELECT @ReturnCode = -1;
                SELECT @ReturnMessage = 'IN USE';
            END
        END
        ELSE
        BEGIN
            IF NOT EXISTS
            (
                SELECT idfAggrSanitaryActionMTX
                FROM dbo.tlbAggrSanitaryActionMTX
                WHERE idfsSanitaryAction = @IdfsAction
            )
               OR @DeleteAnyway = 1
            BEGIN
                UPDATE dbo.trtSanitaryAction
                SET intRowStatus = 1,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsSanitaryAction = @IdfsAction
                      AND intRowStatus = 0;

                UPDATE dbo.trtBaseReference
                SET intRowStatus = 1,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsBaseReference = @IdfsAction
                      AND intRowStatus = 0;

                UPDATE dbo.trtStringNameTranslation
                SET intRowStatus = 1,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsBaseReference = @IdfsAction
                      AND intRowStatus = 0;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                               @EventTypeId,
                                               @UserId,
                                               @IdfsAction,
                                               NULL,
                                               @SiteId,
                                               NULL,
                                               @SiteId,
                                               @LocationId,
                                               @AuditUserName;
            END
            ELSE IF EXISTS
            (
                SELECT idfAggrSanitaryActionMTX
                FROM dbo.tlbAggrSanitaryActionMTX
                WHERE idfsSanitaryAction = @IdfsAction
            )
            BEGIN
                SELECT @ReturnCode = -1;
                SELECT @ReturnMessage = 'IN USE';
            END
        END

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
