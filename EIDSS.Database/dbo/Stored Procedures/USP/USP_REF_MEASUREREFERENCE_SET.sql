-- ================================================================================================
-- Name: USP_REF_MEASUREREFERENCE_SET
-- 
-- Description:	Get the measure list references for reference listings.
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		10/22/2018 Initial release.
-- Ricky Moss		01/18/2019 Remove return codes;
-- Ricky Moss		12/29/2019 Refactoring to check duplicates
-- Ricky Moss		05/12/2020 Updated Translated Value resolution
-- Leo Tracchia		07/07/2021 Removed 'INSERT INTO trtStringNameTranslation...' unnecessary 
-- Leo Tracchia		08/03/2021 Removed logic for checking duplicates on National value. Only 
--                             Default value is required for duplication check.
-- Leo Tracchia		08/09/2021 Fixed logic for duplication check.
-- Stephen Long     07/18/2022 Added site alert logic.
-- Ann Xiong     09/27/2022 Refactored to save the 'National Value' field.

-- exec USP_REF_MEASUREREFERENCE_SET NULL, 19000074, 'Test-1229', 'Test-1229', '', 0, 'en'
-- exec USP_REF_MEASUREREFERENCE_SET 58218970000309, 19000074, 'Test 1229', 'Test 1229', '3', 0, 'en'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_MEASUREREFERENCE_SET]
    @idfsBaseReference BIGINT = NULL,
    @idfsReferenceType BIGINT,
    @strDefault VARCHAR(200),
    @strName NVARCHAR(200),
    @strActionCode NVARCHAR(200),
    @intOrder INT,
    @LangID NVARCHAR(50),
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
AS
DECLARE @ReturnMessage NVARCHAR(MAX) = N'SUCCESS',
        @ReturnCode BIGINT = 0,
        @existingDefault BIGINT,
        @existingName BIGINT;

DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);

BEGIN

    BEGIN TRY

        SELECT @existingDefault =
        (
            SELECT TOP 1
                (idfsReference)
            FROM dbo.fn_gbl_reference_getlist(@langId, @idfsReferenceType)
            WHERE strDefault = @strDefault
        );

        IF (
               @existingDefault IS NOT NULL
               AND @existingDefault <> @idfsBaseReference
           )
           OR (
                  @existingDefault IS NOT NULL
                  AND @idfsBaseReference IS NULL
              )
        BEGIN
            SELECT @ReturnMessage = 'DOES EXIST';
            --IF @existingDefault IS NOT NULL
            --    SELECT @idfsBaseReference = @existingDefault;
            --ELSE
            --    SELECT @idfsBaseReference = @existingName;
        END
		ELSE
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_BaseReference_SET @ReferenceID = @idfsBaseReference OUTPUT,
                                                  @ReferenceType = @idfsReferenceType,
                                                  @LangID = @LangID,
                                                  @DefaultName = @strDefault,
                                                  @NationalName = @strName,
                                                  @HACode = 32,
                                                  @Order = @intOrder,
                                                  @System = 0,
                                                  @User = @AuditUserName;
        --ELSE IF (
        --            (
        --                EXISTS
        --     (
        --         SELECT trtBaseReference.idfsBaseReference
        --         FROM dbo.trtBaseReference
        --         WHERE strDefault = @strDefault
        --               AND idfsReferenceType = @idfsReferenceType
        --               AND intRowStatus = 1
        --     )
        --                OR EXISTS
        --     (
        --         SELECT dbo.trtBaseReference.idfsBaseReference
        --         FROM dbo.trtBaseReference
        --             JOIN dbo.trtStringNameTranslation
        --                 ON dbo.trtBaseReference.idfsBaseReference = dbo.trtStringNameTranslation.idfsBaseReference
        --         WHERE strTextString = @strName
        --               AND idfsReferenceType = @idfsReferenceType
        --               AND dbo.trtBaseReference.intRowStatus = 1
        --     )
        --            )
        --            AND @idfsBaseReference is NULL
        --        )
        --BEGIN
        --    SELECT @idfsBaseReference =
        --    (
        --        SELECT trtBaseReference.idfsBaseReference
        --        FROM dbo.trtBaseReference
        --        WHERE strDefault = @strDefault
        --              AND idfsReferenceType = @idfsReferenceType
        --              AND intRowStatus = 1
        --    )

        --    IF @idfsBaseReference IS NULL
        --    BEGIN
        --        SELECT @idfsBaseReference =
        --        (
        --            SELECT dbo.trtBaseReference.idfsBaseReference
        --            FROM dbo.trtBaseReference
        --                JOIN dbo.trtStringNameTranslation
        --                    ON dbo.trtBaseReference.idfsBaseReference = dbo.trtStringNameTranslation.idfsBaseReference
        --            WHERE strTextString = @strName
        --                  AND idfsReferenceType = @idfsReferenceType
        --                  AND dbo.trtBaseReference.intRowStatus = 1
        --        );
        --    END

        --    IF @idfsReferenceType = 19000079 --SANITARY					
        --        UPDATE dbo.trtSanitaryAction
        --        SET strActionCode = @strActionCode,
        --            intRowStatus = 0,
        --            AuditUpdateDTM = GETDATE(),
        --            AuditUpdateUser = @AuditUserName
        --        WHERE idfsSanitaryAction = @idfsBaseReference;

        --    ELSE IF (@idfsReferenceType = 19000074) --PROPHYLACTIC 					
        --        UPDATE dbo.trtProphilacticAction
        --        SET strActionCode = @strActionCode,
        --            intRowStatus = 0,
        --            AuditUpdateDTM = GETDATE(),
        --            AuditUpdateUser = @AuditUserName
        --        WHERE idfsProphilacticAction = @idfsBaseReference;

        --    UPDATE dbo.trtBaseReference
        --    SET strDefault = @strDefault,
        --        intOrder = @intOrder,
        --        intRowStatus = 0,
        --        AuditUpdateDTM = GETDATE(),
        --        AuditUpdateUser = @AuditUserName
        --    WHERE idfsBaseReference = @idfsBaseReference;

        --    UPDATE dbo.trtStringNameTranslation
        --    SET strTextString = @strName,
        --        intRowStatus = 0,
        --        AuditUpdateDTM = GETDATE(),
        --        AuditUpdateUser = @AuditUserName
        --    WHERE idfsBaseReference = @idfsBaseReference
        --          AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID);

        --    INSERT INTO @SuppressSelect
        --    EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
        --                                   @EventTypeId,
        --                                   @UserId,
        --                                   @idfsBaseReference,
        --                                   NULL,
        --                                   @SiteId,
        --                                   NULL,
        --                                   @SiteId,
        --                                   @LocationId,
        --                                   @AuditUserName;
        --END
        --ELSE 
		IF @existingDefault IS NOT NULL
		--IF EXISTS
  --      (
  --          SELECT idfsBaseReference
  --          FROM dbo.trtBaseReference
  --          WHERE idfsBaseReference = @idfsBaseReference
  --                AND idfsReferenceType = @idfsReferenceType
  --                --AND intRowStatus = 0
  --      )
        BEGIN
            IF @idfsReferenceType = 19000079 --SANITARY		
                UPDATE dbo.trtSanitaryAction
                SET strActionCode = @strActionCode,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsSanitaryAction = @idfsBaseReference;
            ELSE IF (@idfsReferenceType = 19000074) --PROPHYLACTIC 			
                UPDATE dbo.trtProphilacticAction
                SET strActionCode = @strActionCode,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsProphilacticAction = @idfsBaseReference;

            --UPDATE dbo.trtBaseReference
            --SET strDefault = @strDefault,
            --    intOrder = @intOrder,
            --    AuditUpdateDTM = GETDATE(),
            --    AuditUpdateUser = @AuditUserName
            --WHERE idfsBaseReference = @idfsBaseReference;

            --UPDATE dbo.trtStringNameTranslation
            --SET strTextString = @strName,
            --    AuditUpdateDTM = GETDATE(),
            --    AuditUpdateUser = @AuditUserName
            --WHERE idfsBaseReference = @idfsBaseReference
            --      AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID);

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @idfsBaseReference,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;
        END
        ELSE
        BEGIN
            --INSERT INTO @SuppressSelect
            --EXECUTE dbo.USP_GBL_BaseReference_SET @ReferenceID = @idfsBaseReference OUTPUT,
            --                                      @ReferenceType = @idfsReferenceType,
            --                                      @LangID = @LangID,
            --                                      @DefaultName = @strDefault,
            --                                      @NationalName = @strName,
            --                                      @HACode = 32,
            --                                      @Order = @intOrder,
            --                                      @System = 0,
            --                                      @User = @AuditUserName;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @idfsBaseReference,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;

            IF @idfsReferenceType = 19000079 --SANITARY			
                INSERT INTO dbo.trtSanitaryAction
                (
                    idfsSanitaryAction,
                    strActionCode,
                    intRowStatus,
                    AuditCreateDTM,
                    AuditCreateUser
                )
                VALUES
                (@idfsBaseReference, @strActionCode, 0, GETDATE(), @AuditUserName);
            ELSE IF (@idfsReferenceType = 19000074) -- PROPHYLACTIC 
                INSERT INTO dbo.trtProphilacticAction
                (
                    idfsProphilacticAction,
                    strActionCode,
                    intRowStatus,
                    AuditCreateDTM,
                    AuditCreateUser
                )
                VALUES
                (@idfsBaseReference, @strActionCode, 0, GETDATE(), @AuditUserName);
        END

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfsBaseReference AS 'idfsBaseReference';
    END TRY
    BEGIN CATCH
        THROW
    END CATCH

END
