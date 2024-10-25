-- ================================================================================================
-- Name: USP_ILI_Aggregate_Delete
--
-- Description: Deletes data for ILI Aggregate  
--          
-- Author: Arnold Kennedy
--
-- Revision History:
-- Name                     Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Mark Wilson				04/22/2019 Updated to DELETE instead of UPDATE
-- Leo Tracchia             09/05/2021 Removed hard deletes, updated to soft deletes.
-- Stephen Long             12/01/2022 Added data audit logic for SAUC30 and 31.
-- Stephen Long             03/06/2023 Fix to use correct object type on data audit.
--
-- Testing code:
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ILI_Aggregate_Delete]
(
    @idfAggregateHeader AS BIGINT, -- This can be deleted and you can retrieve the value from the detail row if preferred
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnMessage VARCHAR(MAX) = 'Success',
        @ReturnCode BIGINT = 0,
        @DataAuditEventTypeid BIGINT = 10016002,
        @ObjectTypeID BIGINT = 10017075,                       -- ILI aggregate
        @ObjectID BIGINT = @idfAggregateHeader,
        @ObjectAggregateHeaderTableID BIGINT = 50791690000000, -- tlbBasicSyndromicSurveillanceAggregateHeader
        @ObjectAggregateDetailTableID BIGINT = 50791790000000, -- tlbBasicSyndromicSurveillanceAggregateDetail
        @DataAuditEventID BIGINT,
        @UserID BIGINT,
        @SiteID BIGINT,
        @EIDSSObjectID NVARCHAR(200) = (
                                           SELECT strFormID
                                           FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader
                                           WHERE idfAggregateHeader = @idfAggregateHeader
                                       );
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        --Data audit
        SELECT @UserID = a.userid,
               @SiteID = a.siteid
        FROM dbo.FN_UserSiteInformation(@AuditUserName) a;

        EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @UserID,
                                                  @SiteID,
                                                  @DataAuditEventTypeID,
                                                  @ObjectTypeID,
                                                  @ObjectID,
                                                  @ObjectAggregateHeaderTableID,
                                                  @EIDSSObjectID, 
                                                  @DataAuditEventID OUTPUT;

        INSERT INTO dbo.tauDataAuditDetailDelete
        (
            idfDataAuditEvent,
            idfObjectTable,
            idfObject,
            AuditCreateUser,
            strObject
        )
        SELECT @DataAuditEventID,
               @ObjectAggregateDetailTableID,
               idfAggregateDetail,
               @AuditUserName,
               @EIDSSObjectID
        FROM dbo.tlbBasicSyndromicSurveillanceAggregateDetail
        WHERE idfAggregateHeader = @idfAggregateHeader 
              AND intRowStatus = 0;
        -- End data audit

        UPDATE dbo.tlbBasicSyndromicSurveillanceAggregateDetail
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(), 
            AuditUpdateUser = @AuditUserName
        WHERE idfAggregateHeader = @idfAggregateHeader;

        UPDATE dbo.tlbBasicSyndromicSurveillanceAggregateHeader
        SET intRowStatus = 1, 
            AuditUpdateDTM = GETDATE(), 
            AuditUpdateUser = @AuditUserName
        WHERE idfAggregateHeader = @idfAggregateHeader;

        -- Data audit
        INSERT INTO dbo.tauDataAuditDetailDelete
        (
            idfDataAuditEvent,
            idfObjectTable,
            idfObject,
            AuditCreateUser,
            strObject
        )
        VALUES
        (@DataAuditEventID, @ObjectAggregateHeaderTableID, @ObjectID, @AuditUserName, @EIDSSObjectID);
        -- End data audit

        IF @@TRANCOUNT > 0
            COMMIT;

        SELECT @ReturnCode 'ReturnCode',
               @ReturnMessage 'ReturnMessage';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        SET @ReturnMessage
            = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: '
              + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
              + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: '
              + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();

        SET @ReturnCode = ERROR_NUMBER();

        SELECT @ReturnCode 'ReturnCode',
               @ReturnMessage 'ReturnMessage';
    END CATCH
END
