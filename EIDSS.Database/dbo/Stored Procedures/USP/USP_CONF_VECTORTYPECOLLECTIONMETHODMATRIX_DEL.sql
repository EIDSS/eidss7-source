-- ================================================================================================
-- Name: USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_DEL
--
-- Description: Deactivates a vector type to collection type relationships
--
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date        Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		03/04/2019	Initial Release
-- Stephen Long     04/14/2023 Added site alert logic.
--
-- exec USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_DEL 6704450000000
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_DEL]
(
    @idfCollectionMethodForVectorType BIGINT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    DECLARE @ReturnCode INT = 0,
            @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );
    BEGIN TRY
        UPDATE dbo.trtCollectionMethodForVectorType
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(),
            AuditUpdateUser = @AuditUserName
        WHERE idfCollectionMethodForVectorType = @idfCollectionMethodForVectorType;

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                       @EventTypeId,
                                       @UserId,
                                       @idfCollectionMethodForVectorType,
                                       NULL,
                                       @SiteId,
                                       NULL,
                                       @SiteId,
                                       @LocationId,
                                       @AuditUserName;

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
