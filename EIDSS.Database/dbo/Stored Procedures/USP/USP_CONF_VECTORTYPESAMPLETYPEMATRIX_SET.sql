-- ================================================================================================
-- Name: USP_CONF_VECTORTYPESAMPLETYPEMATRIX_SET
--
-- Description:	Creates vector type to sample type matrix a sample type id and vector type id
--
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		04/01/2019 Initial Release
-- Stephen Long     07/13/2022 Added site alert logic.
--
-- EXEC USP_CONF_VECTORTYPESAMPLETYPEMATRIX_SET NULL, 6619310000000, 6618550000000
-- EXEC USP_CONF_VECTORTYPESAMPLETYPEMATRIX_SET NULL, 6619350000000, 6618560000000
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_VECTORTYPESAMPLETYPEMATRIX_SET]
(
    @idfSampleTypeForVectorType BIGINT = NULL,
    @idfsVectorType BIGINT,
    @idfsSampleType BIGINT,
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
            SELECT idfSampleTypeforVectorType
            FROM dbo.trtSampleTypeForVectorType
            WHERE idfsSampleType = @idfsSampleType
                  AND idfsVectorType = @idfsVectorType
                  AND intRowStatus = 0
        )
               AND @idfSampleTypeForVectorType IS NULL
           )
           OR (
                  EXISTS
        (
            SELECT idfSampleTypeforVectorType
            FROM dbo.trtSampleTypeForVectorType
            WHERE idfsSampleType = @idfsSampleType
                  AND idfsVectorType = @idfsVectorType
                  AND idfSampleTypeForVectorType <> @idfSampleTypeForVectorType
                  AND intRowStatus = 0
        )
                  AND @idfSampleTypeForVectorType IS NOT NULL
              )
        BEGIN
            SELECT @ReturnCode = 1;
            SELECT @idfSampleTypeForVectorType =
            (
                SELECT idfSampleTypeforVectorType
                FROM dbo.trtSampleTypeForVectorType
                where idfsSampleType = @idfsSampleType
                      AND idfsVectorType = @idfsVectorType
                      AND intRowStatus = 0
            );
            SELECT @ReturnMessage = 'DOES EXIST';
        END
        ELSE IF EXISTS
             (
                 SELECT idfSampleTypeforVectorType
                 FROM dbo.trtSampleTypeForVectorType
                 WHERE idfsVectorType = @idfsVectorType
                       AND idfSampleTypeForVectorType = @idfSampleTypeForVectorType
                       AND intRowStatus = 0
             )
                AND @idfSampleTypeForVectorType IS NOT NULL
            UPDATE dbo.trtSampleTypeForVectorType
            SET idfsSampleType = @idfsSampleType,
                AuditUpdateDTM = GETDATE(), 
                AuditUpdateUser = @AuditUserName
            WHERE idfSampleTypeForVectorType = @idfSampleTypeForVectorType;
        ELSE IF EXISTS
             (
                 SELECT idfSampleTypeforVectorType
                 FROM dbo.trtSampleTypeForVectorType
                 WHERE idfsSampleType = @idfsSampleType
                       AND idfsVectorType = @idfsVectorType
                       AND intRowStatus = 1
             )
                AND @idfSampleTypeForVectorType IS NULL
        BEGIN
            UPDATE dbo.trtSampleTypeForVectorType
            SET intRowStatus = 0,
                AuditUpdateDTM = GETDATE(), 
                AuditUpdateUser = @AuditUserName
            WHERE idfsSampleType = @idfsSampleType
                  AND idfsVectorType = @idfsVectorType;
        END
        ELSE
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtSampleTypeForVectorType',
                                           @idfSampleTypeForVectorType OUTPUT;

            INSERT INTO dbo.trtSampleTypeForVectorType
            (
                idfSampleTypeForVectorType,
                idfsVectorType,
                idfsSampleType,
                intRowStatus,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@idfSampleTypeForVectorType, @idfsVectorType, @idfsSampleType, 0, GETDATE(), @AuditUserName);

            INSERT INTO dbo.trtSampleTypeForVectorTypeToCP
            (
                idfSampleTypeForVectorType,
                idfCustomizationPackage,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@idfSampleTypeForVectorType, dbo.FN_GBL_CustomizationPackage_GET(), GETDATE(), @AuditUserName);
        END

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfSampleTypeForVectorType,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfSampleTypeForVectorType AS 'idfSampleTypeForVectorType';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
