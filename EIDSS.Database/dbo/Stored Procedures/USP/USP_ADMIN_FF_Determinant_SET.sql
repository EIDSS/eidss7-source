-- ================================================================================================
-- Name: USP_ADMIN_FF_Determinant_GET
--
-- Description: Retrieves the list of Determinants 
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	------------------------------------------------------------------
-- Doug Albanese	5/27/2020	Initial release for new API.
-- Doug Albanese	10/20/2020	Added audit information for Update method
-- Doug Albanese	01/18/2021	Changes to allow usage from the Template Copy procedure
-- Stephen Long     07/13/2022  Added site alert logic.
-- Doug Albanese	09/15/2022	 Realignment against new parameters in SP USP_ADMIN_EVENT_SET
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Determinant_SET]
(
    @idfsDiagnosisGroup BIGINT,
    @idfsFormTemplate BIGINT,
    @User NVARCHAR(200) = NULL,
    @intRowStatus INT = 0,
    @FunctionCall INT = 0,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @ReturnCode BIGINT = 200,
                @ReturnMessage NVARCHAR(MAX) = 'Success',
                @EventId BIGINT = -1,
                @EventSiteId BIGINT = @SiteId,
                @EventObjectId BIGINT = @idfsFormTemplate,
                @EventUserId BIGINT = @UserId,
                @EventDiseaseId BIGINT = NULL,
                @EventLocationId BIGINT = @LocationId,
                @EventInformationString NVARCHAR(MAX) = NULL,
                @EventLoginSiteId BIGINT = @SiteId,
                @idfDeterminantValue BIGINT = NULL;

        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );

        IF EXISTS
        (
            SELECT idfDeterminantValue
            FROM dbo.ffDeterminantValue
            WHERE idfsFormTemplate = @idfsFormTemplate
                  AND idfsBaseReference = @idfsDiagnosisGroup
        )
        BEGIN
            SELECT @idfDeterminantValue = idfDeterminantValue
            FROM dbo.ffDeterminantValue
            WHERE idfsFormTemplate = @idfsFormTemplate
                  AND idfsBaseReference = @idfsDiagnosisGroup;

            UPDATE dbo.ffDeterminantValue
            SET intRowStatus = @intRowStatus,
                AuditUpdateUser = @User,
                AuditUpdateDTM = GETDATE()
            WHERE idfDeterminantValue = @idfDeterminantValue;
        END
        ELSE
        BEGIN
            IF @FunctionCall = 0
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_GBL_NEXTKEYID_GET 'ffDeterminantValue',
                                               @idfDeterminantValue OUTPUT;
            END
            ELSE
            BEGIN
                EXEC dbo.USP_GBL_NEXTKEYID_GET 'ffDeterminantValue',
                                               @idfDeterminantValue OUTPUT;
            END

            INSERT INTO dbo.ffDeterminantValue
            (
                idfDeterminantValue,
                idfsFormTemplate,
                idfsBaseReference,
                intRowStatus,
                AuditCreateUser,
                AuditCreateDTM,
                SourceSystemNameID,
                SourceSystemKeyValue
            )
            VALUES
            (@idfDeterminantValue,
             @idfsFormTemplate,
             @idfsDiagnosisGroup,
             0  ,
             @User,
             GETDATE(),
             10519001,
             '[{"idfDeterminantValue":' + CAST(@idfDeterminantValue AS NVARCHAR(300)) + '}]'
            );
        END

        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @EventObjectId,
                                        @EventDiseaseId,
                                        @EventSiteId,
										--'',
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @User;

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
           AND @FunctionCall = 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END

