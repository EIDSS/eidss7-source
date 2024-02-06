-- ================================================================================================
-- Name:		USP_CONF_VECTORTYPEFIELDTESTMATRIX_DEL
--
-- Description:	Removes vector type to field test matrix
--
-- Author:		Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		04/02/2019 Initial Release
-- Stephen Long     04/14/2023 Added site alert logic.
--
-- EXEC USP_CONF_VECTORTYPEFIELDTESTMATRIX_DEL 6706660000000, 1
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_VECTORTYPEFIELDTESTMATRIX_DEL]
(
    @idfPensideTestTypeForVectorType BIGINT,
    @deleteAnyway BIT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);
BEGIN
    BEGIN TRY
        UPDATE dbo.trtPensideTestTypeForVectorType
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(),
            AuditUpdateUser = @AuditUserName
        WHERE idfPensideTestTypeForVectorType = @idfPensideTestTypeForVectorType;

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                       @EventTypeId,
                                       @UserId,
                                       @idfPensideTestTypeForVectorType,
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
        THROW
    END CATCH
END
