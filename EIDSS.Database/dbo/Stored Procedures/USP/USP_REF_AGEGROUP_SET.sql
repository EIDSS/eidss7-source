-- ================================================================================================
-- Name: USP_REF_AGEGROUP_SET
-- Description:	Get the Case Classification for reference listings.
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		09/25/2018 Initial release.
-- Ricky Moss		12/19/2018 Remove the return codes
-- Ricky Moss		01/02/2019 Add the return codes and replaced 
--                             dbo.FN_GBL_LanguageCode_GET(@LangID)
-- Ricky Moss		01/03/2019 returnMessage param returns 'ALREADY EXISTS' if new Age Group 
--                             already exists
-- Ricky Moss		02/10/2019Checks to see when updating a age group that the name does not 
--                             exists in another reference
-- Ricky Moss		06/20/2019 Correct duplicate prevention issue and Reactivate inactive species 
--                             types if trying to re-add
-- Ricky Moss		02/17/2020 Refactored to check for duplicates and update translated values
-- Mark Wilson		07/08/2021 refactored for consistency
-- Stephen Long     07/16/2022 Added site alert logic.
--
/*

 exec USP_REF_AGEGROUP_SET NULL, 'MarkTest2', 'TranslationMarkTest', 0, 0, 10042003, 'en-US', 10
 exec USP_REF_AGEGROUP_SET NULL, '13-24', 'Translated_13-24', 0, 0, 10042003, 'en-US', 10
 exec USP_REF_AGEGROUP_SET 389445040002342, '@DefaultName', 'TranslationMarkyTest', 0, 0, 10042003, 'en-US', 10
 
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_AGEGROUP_SET]
(
    @idfsAgeGroup BIGINT = NULL,
    @strDefault NVARCHAR(200),
    @strName NVARCHAR(200),
    @intLowerBoundary INT,
    @intUpperBoundary INT,
    @idfsAgeType BIGINT,
    @LangID NVARCHAR(50) = NULL,
    @intOrder INT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    DECLARE @ReturnCode INT
        = 0,
            @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
            @existingDefault BIGINT,
            @existingName BIGINT,
            @DuplicateDefault INT = 0, -- updated to capture 0 or 1. 1 indicates a duplicate and will not execute the set.
            @idfCustomizationPackage BIGINT,
            @idfsLanguage BIGINT = (
                                       SELECT idfsBaseReference
                                       FROM dbo.trtBaseReference
                                       WHERE strBaseReferenceCode = @LangID
                                   );  -- capture the idfsLanguage for the translation

    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );

    BEGIN TRY

        IF @idfsAgeGroup IS NULL
        BEGIN -- this is an insert.  check if the strDefault is a duplicate
            IF EXISTS
            (
                SELECT *
                FROM dbo.trtBaseReference
                WHERE strDefault = @strDefault
                      AND idfsReferenceType = 19000146
                      AND trtBaseReference.intRowStatus = 0
            )
            BEGIN
                SET @DuplicateDefault = 1;
            END
        END
        ELSE
        BEGIN -- this is an update.  check if the strDefault is a duplicate
            IF EXISTS
            (
                SELECT *
                FROM dbo.trtBaseReference
                WHERE idfsBaseReference <> @idfsAgeGroup
                      AND strDefault = @strDefault
                      AND idfsReferenceType = 19000146
                      AND trtBaseReference.intRowStatus = 0
            )
            BEGIN
                SET @DuplicateDefault = 1;
            END
        END

        IF @DuplicateDefault = 1 -- No need to go any further, as the strDefault is a duplicate
        BEGIN
            SELECT @ReturnMessage = 'DOES EXIST';
        END
        ELSE -- there is no duplicate, so continue
        BEGIN
            EXEC dbo.USP_GBL_BaseReference_SET @ReferenceID = @idfsAgeGroup OUTPUT,
                                               @ReferenceType = 19000146,
                                               @LangID = @LangID,
                                               @DefaultName = @strDefault,
                                               @NationalName = @strName,
                                               @HACode = 2,
                                               @Order = @intOrder,
                                               @System = 0,
                                               @User = @AuditUserName;

            IF EXISTS
            (
                SELECT *
                FROM dbo.trtDiagnosisAgeGroup
                WHERE idfsDiagnosisAgeGroup = @idfsAgeGroup
            ) -- there is a record, so update it
            BEGIN
                UPDATE dbo.trtDiagnosisAgeGroup
                SET intLowerBoundary = @intLowerBoundary,
                    intUpperBoundary = @intUpperBoundary,
                    idfsAgeType = @idfsAgeType,
                    intRowStatus = 0,
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE()
                WHERE [idfsDiagnosisAgeGroup] = @idfsAgeGroup;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                               @EventTypeId,
                                               @UserId,
                                               @idfsAgeGroup,
                                               NULL,
                                               @SiteId,
                                               NULL,
                                               @SiteId,
                                               @LocationId,
                                               @AuditUserName;
            END
            ELSE -- There is no record, so insert it
            BEGIN

                INSERT INTO dbo.trtDiagnosisAgeGroup
                (
                    idfsDiagnosisAgeGroup,
                    intLowerBoundary,
                    intUpperBoundary,
                    idfsAgeType,
                    intRowStatus,
                    rowguid,
                    strMaintenanceFlag,
                    strReservedAttribute,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser,
                    AuditCreateDTM,
                    AuditUpdateUser,
                    AuditUpdateDTM
                )
                VALUES
                (@idfsAgeGroup,
                 @intLowerBoundary,
                 @intUpperBoundary,
                 @idfsAgeType,
                 0  ,
                 NEWID(),
                 N'ADD',
                 N'EIDSS7 Reference Data',
                 10519001,
                 N'[{"idfsBaseReference":' + CAST(@idfsAgeGroup AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 GETDATE(),
                 @AuditUserName,
                 GETDATE()
                );

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                               @EventTypeId,
                                               @UserId,
                                               @idfsAgeGroup,
                                               NULL,
                                               @SiteId,
                                               NULL,
                                               @SiteId,
                                               @LocationId,
                                               @AuditUserName;
            END

        END

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfsAgeGroup AS 'idfsAgeGroup';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
