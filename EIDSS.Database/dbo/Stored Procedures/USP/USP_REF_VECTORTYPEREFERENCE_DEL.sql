--=================================================================================================
-- Name: USP_REF_VECTORTYPEREFERENCE_DEL
--
-- Description:	Removes vector type from active list of vector types.
--							
-- Author: Ricky Moss.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		2018/09/26 Initial Release
-- Ricky Moss		12/13/2018 Removed return code
-- Stephen Long     11/01/2022 Added site alert logic.
-- 
-- Test Code:
-- exec USP_REF_VECTORTYPEREFERENCE_DEL 55615180000050, 0
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_VECTORTYPEREFERENCE_DEL]
(
    @idfsVectorType BIGINT,
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

        IF (
               NOT EXISTS
        (
            SELECT idfCollectionMethodForVectorType
            FROM dbo.trtCollectionMethodForVectorType
            WHERE idfsVectorType = @idfsVectorType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfPensideTestTypeForVectorType
            FROM dbo.trtPensideTestTypeForVectorType
            WHERE idfsVectorType = @idfsVectorType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfSampleTypeForVectorType
            FROM dbo.trtSampleTypeForVectorType
            WHERE idfsVectorType = @idfsVectorType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfsVectorSubType
            FROM dbo.trtVectorSubType
            WHERE idfsVectorType = @idfsVectorType
                  AND intRowStatus = 0
        )
           )
           OR @deleteAnyway = 1
        BEGIN
            UPDATE dbo.trtVectorType
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsVectorType = @idfsVectorType
                  and intRowStatus = 0;

            UPDATE dbo.trtBaseReference
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @idfsVectorType
                  AND intRowStatus = 0;

            UPDATE dbo.trtStringNameTranslation
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @idfsVectorType;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @idfsVectorType,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;
        END
        ELSE IF EXISTS
             (
                 SELECT idfCollectionMethodForVectorType
                 FROM dbo.trtCollectionMethodForVectorType
                 WHERE idfsVectorType = @idfsVectorType
                       AND intRowStatus = 0
             )
                OR EXISTS
             (
                 SELECT idfPensideTestTypeForVectorType
                 FROM dbo.trtPensideTestTypeForVectorType
                 WHERE idfsVectorType = @idfsVectorType
                       AND intRowStatus = 0
             )
                OR EXISTS
             (
                 SELECT idfSampleTypeForVectorType
                 FROM dbo.trtSampleTypeForVectorType
                 WHERE idfsVectorType = @idfsVectorType
                       AND intRowStatus = 0
             )
                OR EXISTS
             (
                 SELECT idfsVectorSubType
                 FROM dbo.trtVectorSubType
                 WHERE idfsVectorType = @idfsVectorType
                       AND intRowStatus = 0
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
END
