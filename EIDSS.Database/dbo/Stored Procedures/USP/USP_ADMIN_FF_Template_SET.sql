-- ================================================================================================
-- Name: USP_ADMIN_FF_Template_SET
--
-- Description: Save the template.
--          
-- Revision History:
-- Name	            Date       Change
-- ---------------- ---------- --------------------------------------------------------------------
-- Kishore Kodru    11/28/2018 Initial release for new API.
-- Doug Albanese	04/22/2020 Refactored to work with POCO
-- Doug Albanese	05/11/2020 Correction for when duplicate template names show up. Adding numbers 
--                             at the end of the name to indicated more than one of the same.
-- Doug Albanese	09/24/2020 Removed the duplication issue for tagging with an incrementing number
-- Doug Albanese	10/20/2020 Added Auditing Information
-- Doug Albanese	01/13/2021 Added "FunctionCall" parameter to override suppression techniques
-- Doug Albanese	01/14/2021 Correct the output to show...depending on the CopyOnly parameter 
--                             value
-- Doug Albanese	01/21/2021 Swapped out USP_GBL_BaseReference_SET, with USSP_GBL_BaseReference_SET
-- Doug Albanese	01/26/2021 Refactored
-- Doug Albanese	05/03/2021 Corrected the return values for ReturnCode and ReturnMessage to 
--                             match the application APIPostResponseModel
-- Doug Albanese	07/12/2021 Corrected the saving routine for when -1 is passed as a Form 
--                             Template id.
-- Doug Albanese	07/14/2021 Removed "Auto Naming" for new templates with Form Type name
-- Doug Albanese	07/14/2021 Swapped USP_GBL_BaseReference_SET for USSP_GBL_BaseReference_SET
-- Doug Albanese	06/02/2022 Added logic to remove all UNI selected templates, for the given form 
--                             type being modified - (Except for current template being saved)
-- Stephen Long     07/13/2022 Added site alert logic.
-- Doug Albanese	09/15/2022	 Realignment against new parameters in SP USP_ADMIN_EVENT_SET
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Template_SET]
(
    @idfsFormType BIGINT,
    @DefaultName NVARCHAR(400),
    @NationalName NVARCHAR(600) = NULL,
    @strNote NVARCHAR(200) = NULL,
    @LangID NVARCHAR(50),
    @blnUNI BIT = NULL,
    @idfsFormTemplate BIGINT,
    @intRowStatus INT = 0,
    @User NVARCHAR(50) = '',
    @FunctionCall INT = 0,
    @CopyOnly INT = 0, --For use by USP_ADMIN_FF_Copy_Template only
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    )

    DECLARE @ReturnCode BIGINT = 200,
            @ReturnMessage NVARCHAR(MAX) = 'Success',
            @EventId BIGINT = -1,
            @EventSiteId BIGINT = @SiteId,
            @EventObjectId BIGINT = @idfsFormTemplate,
            @EventUserId BIGINT = @UserId,
            @EventDiseaseId BIGINT = NULL,
            @EventLocationId BIGINT = @LocationId,
            @EventInformationString NVARCHAR(MAX) = NULL,
            @EventLoginSiteId BIGINT = @SiteId;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF (@idfsFormTemplate < 0)
        BEGIN
            IF (@blnUNI IS NULL)
                SET @blnUNI = 0;

            DECLARE @FormType NVARCHAR(50);

            SELECT @FormType = COALESCE(TN.Name, BR.strDefault)
            FROM dbo.trtBaseReference BR
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000033) TN
                    ON TN.idfsReference = BR.idfsBaseReference
            WHERE idfsBaseReference = @idfsFormType;

            SET @idfsFormTemplate = NULL;
        END

        IF @CopyOnly = 0
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USSP_GBL_BaseReference_SET @ReferenceID = @idfsFormTemplate OUTPUT,
                                                @ReferenceType = 19000033,
                                                @LangID = @LangID,
                                                @DefaultName = @DefaultName,
                                                @NationalName = @NationalName,
                                                @HACode = 0,
                                                @Order = 0,
                                                @System = 0;
        END

        IF EXISTS
        (
            SELECT 1
            FROM dbo.ffFormTemplate
            WHERE idfsFormTemplate = @idfsFormTemplate
        )
        BEGIN
            UPDATE dbo.ffFormTemplate
            SET idfsFormType = @idfsFormType,
                strNote = @strNote,
                blnUNI = @blnUNI,
                intRowStatus = @intRowStatus,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @User
            WHERE idfsFormTemplate = @idfsFormTemplate;
        END
        ELSE
        BEGIN
            IF NOT EXISTS
            (
                SELECT TOP 1
                    1
                FROM dbo.ffFormTemplate
                WHERE idfsFormTemplate = @idfsFormTemplate
            )
            BEGIN
                INSERT INTO dbo.ffFormTemplate
                (
                    idfsFormTemplate,
                    idfsFormType,
                    strNote,
                    intRowStatus,
                    blnUNI,
                    AuditCreateDTM,
                    AuditCreateUser,
                    SourceSystemNameID,
                    SourceSystemKeyValue
                )
                VALUES
                (@idfsFormTemplate,
                 @idfsFormType,
                 @strNote,
                 0  ,
                 @blnUNI,
                 GETDATE(),
                 @User,
                 10519001,
                 '[{"idfsFormTemplate":' + CAST(@idfsFormTemplate AS NVARCHAR(300)) + '}]'
                );
            END
        END

        --Remove all UNI selections from templates for the given form type, except for this current record
        IF @idfsFormType IS NOT NULL
           AND @idfsFormTemplate IS NOT NULL
           AND @blnUNI = 1
        BEGIN
            UPDATE dbo.ffFormTemplate
            SET blnUNI = 0
            WHERE idfsFormType = @idfsFormType
                  AND idfsFormTemplate <> @idfsFormTemplate
                  AND intRowStatus = 0;

			IF @FunctionCall = 0
				BEGIN

					INSERT INTO @SuppressSelect
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
				END
			ELSE
				BEGIN
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
				END
        END

        IF @FunctionCall = 0
        BEGIN
            SELECT @ReturnCode AS ReturnCode,
                   @ReturnMessage AS ReturnMessage,
                   @idfsFormTemplate AS idfsFormTemplate;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
           AND @FunctionCall = 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END
