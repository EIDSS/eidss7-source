-- ================================================================================================
-- Name: USP_REF_VectorSubType_DEL
-- Description:	Remove an active Vector Sub Type.
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		10/18/2018 Initial release.
-- Stephen Long     11/01/2022 Added site alert logic.
--
-- exec USP_REF_VectorSubType_DEL 6619330000000, 0
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_VectorSubType_DEL]
(
    @idfsVectorSubType BIGINT,
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

        IF NOT EXISTS
        (
            SELECT idfVectorSurveillanceSession
            FROM dbo.tlbVectorSurveillanceSessionSummary
            WHERE idfsVectorSubType = @idfsVectorSubType
                  and intRowStatus = 0
        )
           OR @deleteAnyway = 1
        BEGIN
            UPDATE dbo.trtVectorSubType
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsVectorSubType = @idfsVectorSubType
                  and intRowStatus = 0;

            UPDATE dbo.trtBaseReference
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @idfsVectorSubType
                  AND intRowStatus = 0;

            UPDATE dbo.trtStringNameTranslation
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @idfsVectorSubType;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @idfsVectorSubType,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;
        END
        ELSE IF EXISTS
        (
            SELECT idfVectorSurveillanceSession
            FROM dbo.tlbVectorSurveillanceSessionSummary
            WHERE idfsVectorSubType = @idfsVectorSubType
                  and intRowStatus = 0
        )
        BEGIN
            SELECT @ReturnCode = -1;
            SELECT @ReturnMessage = 'IN USE';
        END

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
end
