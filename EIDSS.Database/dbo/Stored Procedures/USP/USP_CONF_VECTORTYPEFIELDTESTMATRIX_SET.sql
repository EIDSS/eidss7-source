-- ================================================================================================
-- Name: USP_CONF_VECTORTYPEFIELDTESTMATRIX_SET
--
-- Description:	Creates vector type to field test matrix
--
-- Author: Ricky Moss
--
-- Revision History:
-- Name                     Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Ricky Moss		        04/02/2019 Initial Release
-- Stephen Long             07/13/2022 Added site alert logic.
--
-- EXEC USP_CONF_VECTORTYPEFIELDTESTMATRIX_SET NULL, 6619310000000, 6619120000000
-- EXEC USP_CONF_VECTORTYPEFIELDTESTMATRIX_SET NULL, 6619350000000, 6619280000000
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_VECTORTYPEFIELDTESTMATRIX_SET]
(
    @idfPensideTestTypeForVectorType BIGINT = NULL,
    @idfsVectorType BIGINT,
    @idfsPensideTestName BIGINT,
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
            SELECT idfPensideTestTypeForVectorType
            FROM dbo.trtPensideTestTypeForVectorType
            WHERE idfsPensideTestName = @idfsPensideTestName
                  AND idfsVectorType = @idfsVectorType
                  AND intRowStatus = 0
        )
               AND @idfPensideTestTypeForVectorType IS NULL
           )
           OR (
                  EXISTS
        (
            SELECT idfPensideTestTypeForVectorType
            FROM dbo.trtPensideTestTypeForVectorType
            WHERE idfsPensideTestName = @idfsPensideTestName
                  AND idfsVectorType = @idfsVectorType
                  AND idfPensideTestTypeForVectorType <> @idfPensideTestTypeForVectorType
                  AND intRowStatus = 0
        )
                  AND @idfPensideTestTypeForVectorType IS NOT NULL
              )
        BEGIN
            SELECT @ReturnCode = 1;
            SELECT @idfPensideTestTypeForVectorType =
            (
                SELECT idfPensideTestTypeForVectorType
                FROM dbo.trtPensideTestTypeForVectorType
                WHERE idfsPensideTestName = @idfsPensideTestName
                      AND idfsVectorType = @idfsVectorType
                      AND intRowStatus = 0
            );
            SELECT @ReturnMessage = 'DOES EXIST';
        END
        ELSE IF EXISTS
             (
                 SELECT idfPensideTestTypeForVectorType
                 FROM dbo.trtPensideTestTypeForVectorType
                 where idfPensideTestTypeForVectorType = @idfPensideTestTypeForVectorType
                       AND idfsVectorType = @idfsVectorType
                       AND intRowStatus = 0
             )
                AND @idfPensideTestTypeForVectorType IS NOT NULL
        BEGIN
            UPDATE dbo.trtPensideTestTypeForVectorType
            SET idfsPensideTestName = @idfsPensideTestName,
                AuditUpdateDTM = GETDATE(), 
                AuditUpdateUser = @AuditUserName 
            WHERE idfPensideTestTypeForVectorType = @idfPensideTestTypeForVectorType
                  AND idfsVectorType = @idfsVectorType;
        END
        ELSE IF EXISTS
             (
                 SELECT idfPensideTestTypeForVectorType
                 FROM dbo.trtPensideTestTypeForVectorType
                 WHERE idfsPensideTestName = @idfsPensideTestName
                       AND idfsVectorType = @idfsVectorType
                       AND intRowStatus = 1
             )
                AND @idfPensideTestTypeForVectorType IS NULL
        BEGIN
            UPDATE dbo.trtPensideTestTypeForVectorType
            SET intRowStatus = 0,
                AuditUpdateDTM = GETDATE(), 
                AuditUpdateUser = @AuditUserName
            WHERE idfsPensideTestName = @idfsPensideTestName
                  AND idfsVectorType = @idfsVectorType;
        END
        ELSE
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtPensideTestTypeForVectorType',
                                           @idfPensideTestTypeForVectorType OUTPUT;

            INSERT INTO dbo.trtPensideTestTypeForVectorType
            (
                idfPensideTestTypeForVectorType,
                idfsVectorType,
                idfsPensideTestName,
                intRowStatus,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@idfPensideTestTypeForVectorType, @idfsVectorType, @idfsPensideTestName, 0, GETDATE(), @AuditUserName);

            INSERT INTO dbo.trtPensideTestTypeForVectorTypeToCP
            (
                idfPensideTestTypeForVectorType,
                idfCustomizationPackage, 
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@idfPensideTestTypeForVectorType, dbo.FN_GBL_CustomizationPackage_GET(), GETDATE(), @AuditUserName);
        END

        INSERT INTO @SuppressSelect 
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfPensideTestTypeForVectorType,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfPensideTestTypeForVectorType AS 'idfPensideTestTypeForVectorType';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
