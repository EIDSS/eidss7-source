-- ================================================================================================
-- Name: USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_SET
--
-- Description: Creates a vector type to collection method relationship
--
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		03/04/2019 Initial Release
-- Stephen Long     07/13/2022 Added site alert logic.
--
-- exec USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_SET NULL, 6619360000000, 6703300000000
-- exec USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_SET NULL, 6619360000000, 6703240000000
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_SET]
(
    @idfCollectionMethodForVectorType BIGINT = NULL,
    @idfsVectorType BIGINT,
    @idfsCollectionMethod BIGINT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @ReturnCode BIGINT = 0,
        @EventId BIGINT = -1,
        @EventSiteId BIGINT = @SiteId,
        @EventUserId BIGINT = @UserId,
        @EventDiseaseId BIGINT = NULL,
        @EventLocationId BIGINT = @LocationId,
        @EventInformationString NVARCHAR(MAX) = NULL,
        @EventLoginSiteId BIGINT = @SiteId;
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);

BEGIN
    BEGIN TRY
        IF (
               EXISTS
        (
            SELECT idfCollectionMethodForVectorType
            FROM dbo.trtCollectionMethodForVectorType
            WHERE idfsVectorType = @idfsVectorType
                  AND idfsCollectionMethod = @idfsCollectionMethod
                  AND intRowStatus = 0
        )
               AND @idfCollectionMethodForVectorType IS NULL
           )
           OR (
                  EXISTS
        (
            SELECT idfCollectionMethodForVectorType
            FROM dbo.trtCollectionMethodForVectorType
            WHERE idfsVectorType = @idfsVectorType
                  AND idfsCollectionMethod = @idfsCollectionMethod
                  AND idfCollectionMethodForVectorType <> @idfCollectionMethodForVectorType
                  AND intRowStatus = 0
        )
                  AND @idfCollectionMethodForVectorType IS NOT NULL
              )
        BEGIN
            SELECT @ReturnCode = 1;
            SELECT @ReturnMessage = 'DOES EXIST';
            SELECT @idfCollectionMethodForVectorType =
            (
                SELECT idfCollectionMethodForVectorType
                FROM dbo.trtCollectionMethodForVectorType
                WHERE idfsVectorType = @idfsVectorType
                      AND idfsCollectionMethod = @idfsCollectionMethod
                      AND intRowStatus = 0
            );
        END
        ELSE IF EXISTS
        (
            SELECT idfCollectionMethodForVectorType
            FROM dbo.trtCollectionMethodForVectorType
            WHERE idfsVectorType = @idfsVectorType
                  AND idfsCollectionMethod = @idfsCollectionMethod
                  AND intRowStatus = 1
        )
        BEGIN
            UPDATE dbo.trtCollectionMethodForVectorType
            SET intRowStatus = 0,
                AuditUpdateDTM = GETDATE(), 
                AuditUpdateUser = @AuditUserName 
            WHERE idfsVectorType = @idfsVectorType
                  AND idfsCollectionMethod = @idfsCollectionMethod;

            SELECT @idfCollectionMethodForVectorType =
            (
                SELECT idfCollectionMethodForVectorType
                FROM dbo.trtCollectionMethodForVectorType
                WHERE idfsVectorType = @idfsVectorType
                      AND idfsCollectionMethod = @idfsCollectionMethod
                      AND intRowStatus = 0
            );
        END
        ELSE
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtCollectionMethodforVectorType',
                                           @idfCollectionMethodForVectorType OUTPUT;

            INSERT INTO dbo.trtCollectionMethodForVectorType
            (
                idfCollectionMethodForVectorType,
                idfsVectorType,
                idfsCollectionMethod,
                intRowStatus,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@idfCollectionMethodForVectorType, @idfsVectorType, @idfsCollectionMethod, 0, GETDATE(), @AuditUserName);

            INSERT INTO dbo.trtCollectionMethodForVectorTypeToCP
            (
                idfCollectionMethodForVectorType,
                idfCustomizationPackage,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@idfCollectionMethodForVectorType, dbo.FN_GBL_CustomizationPackage_GET(), GETDATE(), @AuditUserName);
        END

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfCollectionMethodForVectorType,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfCollectionMethodForVectorType AS 'idfCollectionMethodForVectorType';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
