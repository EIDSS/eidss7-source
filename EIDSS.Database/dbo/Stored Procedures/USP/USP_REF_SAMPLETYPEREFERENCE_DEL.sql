--=================================================================================================
-- Author: Ricky Moss
--
-- Description:	Removes a sample type reference record from the active list.
--							
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		09/26/2018 Initial Release
-- Ricky Moss		12/12/2018 Removed return code and reference id variables
-- Ricky Moss		01/03/2018 Added the deleteAnyway parameter
-- Mandar Kulkarni	08/09/2021 Added coded to delete LOINC NUMBER record as a child.
-- Stephen Long     11/01/2022 Added site alert logic.
--
-- Test Code:
-- exec USP_REF_SAMPLETYPEREFERENCE_DEL 55615180000085, 0
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_SAMPLETYPEREFERENCE_DEL]
(
    @IdfsSampleType BIGINT,
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
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
                @inUse BIT = 0;
        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );

        IF (
               NOT EXISTS
        (
            SELECT idfMonitoringSession
            FROM dbo.MonitoringSessionToSampleType
            WHERE idfsSampleType = @IdfsSampleType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfSampleTypeForVectorType
            FROM dbo.trtSampleTypeForVectorType
            WHERE idfsSampleType = @IdfsSampleType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfCampaignToDiagnosis
            FROM dbo.tlbCampaignToDiagnosis
            WHERE idfsSampleType = @IdfsSampleType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfMonitoringSessionSummary
            FROM dbo.tlbMonitoringSessionSummarySample
            WHERE idfsSampleType = @IdfsSampleType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfMonitoringSessionToDiagnosis
            FROM dbo.tlbMonitoringSessionToDiagnosis
            WHERE idfsSampleType = @IdfsSampleType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfMaterialForDisease
            FROM dbo.trtMaterialForDisease
            WHERE idfsSampleType = @IdfsSampleType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfSampleTypeForVectorType
            FROM dbo.trtSampleTypeForVectorType
            WHERE idfsSampleType = @IdfsSampleType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfTestForDisease
            FROM dbo.trtTestForDisease
            WHERE idfsSampleType = @IdfsSampleType
                  and intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfMaterial
            FROM dbo.tlbMaterial
            WHERE idfsSampleType = @IdfsSampleType
                  AND intRowStatus = 0
        )
           )
            SELECT @inUse = 0;
        ELSE
            SELECT @inUse = 1;

        IF @inUse = 0
           OR @DeleteAnyway = 1
        BEGIN
            UPDATE dbo.trtSampleType
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsSampleType = @IdfsSampleType
                  AND intRowStatus = 0;

            UPDATE dbo.trtBaseReference
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @IdfsSampleType
                  AND intRowStatus = 0;

            UPDATE dbo.trtStringNameTranslation
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @idfsSampleType;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @IdfsSampleType,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;

            -- Delete after checking if child record exists, 
            IF EXISTS
            (
                SELECT TOP 1
                    idfsBaseReference
                FROM dbo.LOINCEidssMapping
                WHERE idfsBaseReference = @idfsSampleType
            )
                UPDATE dbo.LOINCEidssMapping
                SET intRowStatus = 1,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsBaseReference = @idfsSampleType;
        END
        ELSE
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
