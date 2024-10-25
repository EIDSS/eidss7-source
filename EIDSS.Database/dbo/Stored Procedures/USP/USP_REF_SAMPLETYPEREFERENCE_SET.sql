-- ================================================================================================
-- Name: dbo.USP_REF_SAMPLETYPEREFERENCE_SET
-- Description:	Add and Update a sample type
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		10/01/2018 Initial release.
-- Ricky Moss		12/13/2018 Removed return code
-- Ricky Moss		01/02/2019 Replaced fnGetLanguageCode with FN_GBL_LanguageCode_GET function
-- Ricky Moss		02/10/2019hecks to see when updating a sample type that the name does not 
--                             exists in another reference and updates English value
-- Ricky Moss		06/18/2019 Correct duplicate prevention issue (Bug #3447) and Reactivate 
--                             inactive sample types if trying to re-add
-- Ricky Moss		06/22/2019 Added customization and string translation
-- Steven Verner	03/26/2019 Added transaction
-- Ann Xiong		04/12/2021 Refactored to make use of USSP_GBL_BaseReference_SET, and to change 
--                             the branch decisions for insert/update.
-- Mark Wilson		08/03/2021 Refactored to make use of USP_GBL_BaseReference_SET
-- Mandar Kulkarni  08/09/2021 Added a new parameter to accept and set LOINC Number.
-- Stephen Long     07/18/2022 Added site alert logic.
-- Stephen Long     11/01/2022 Changed parameter name @idfsSampleType to @IdfsSampleType.
--
/*  Test code

exec USP_REF_SAMPLETYPEREFERENCE_SET NULL, 'Test Again 44','Test Again 64',  '100.0',  NULL, 224, 0, 'en-US'
exec USP_REF_SAMPLETYPEREFERENCE_SET 389445040003864, 'Test Again 48', 'Test Again 4', '99.0', null, 98, 0, 'en-US'

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_SAMPLETYPEREFERENCE_SET]
(
    @IdfsSampleType BIGINT = NULL,
    @strDefault VARCHAR(200),
    @strName NVARCHAR(200),
    @strSampleCode NVARCHAR(50),
    @LOINC_NUM NVARCHAR(255),
    @intHACode INT,
    @intOrder INT,
    @LangID NVARCHAR(50),
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    DECLARE @ReturnMessage NVARCHAR(max) = N'SUCCESS',
            @ReturnCode INT = 0,
            @existingDefault BIGINT,
            @existingName BIGINT,
            @DuplicateDefault INT = 0; -- updated to capture 0 or 1. 1 indicates a duplicate and will not execute the set.
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );
    BEGIN TRY
        BEGIN TRANSACTION

        IF @IdfsSampleType IS NULL
        BEGIN -- this is an insert.  check if the strDefault is a duplicate
            IF EXISTS
            (
                SELECT *
                FROM dbo.trtBaseReference
                WHERE strDefault = @strDefault
                      AND idfsReferenceType = 19000087
                      AND intRowStatus = 0
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
                WHERE idfsBaseReference <> @IdfsSampleType
                      AND strDefault = @strDefault
                      AND idfsReferenceType = 19000087
                      AND intRowStatus = 0
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
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_BaseReference_SET @ReferenceID = @IdfsSampleType OUTPUT,
                                               @ReferenceType = 19000087,
                                               @LangID = @LangID,
                                               @DefaultName = @strDefault,
                                               @NationalName = @strName,
                                               @HACode = @intHACode,
                                               @Order = @intOrder,
                                               @System = 0,
                                               @User = @AuditUserName;

            IF EXISTS
            (
                SELECT *
                FROM dbo.trtSampleType
                WHERE idfsSampleType = @IdfsSampleType
            )
            BEGIN
                UPDATE dbo.trtSampleType
                SET strSampleCode = @strSampleCode,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName,
                    intRowStatus = 0,
                    SourceSystemKeyValue = N'[{"idfsSampleType":' + CAST(@IdfsSampleType AS NVARCHAR(300)) + '}]'
                WHERE idfsSampleType = @IdfsSampleType;

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
            END
            ELSE
            BEGIN
                INSERT INTO dbo.trtSampleType
                (
                    idfsSampleType,
                    strSampleCode,
                    intRowStatus,
                    rowguid,
                    strMaintenanceFlag,
                    strReservedAttribute,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser,
                    AuditCreateDTM
                )
                VALUES
                (@IdfsSampleType,
                 @strSampleCode,
                 0  ,
                 NEWID(),
                 N'EIDSS7 Sample Type',
                 N'ADD',
                 10519001,
                 N'[{"idfsSampleType":' + CAST(@IdfsSampleType AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 GETDATE()
                );

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
            END

            -- Insert/Updated for LOINC Number
            IF EXISTS
            (
                SELECT *
                FROM dbo.LOINCEidssMapping
                WHERE idfsBaseReference = @IdfsSampleType
            )
            BEGIN
                UPDATE dbo.LOINCEidssMapping
                SET LOINC_NUM = @LOINC_NUM,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName,
                    intRowStatus = 0,
                    SourceSystemKeyValue = N'[{"idfsBaseReference":' + CAST(@IdfsSampleType AS NVARCHAR(300)) + '}]'
                WHERE idfsBaseReference = @IdfsSampleType;
            END
            ELSE
            BEGIN
                INSERT INTO dbo.LOINCEidssMapping
                (
                    idfsBaseReference,
                    idfsReferenceType,
                    LOINC_NUM,
                    intRowStatus,
                    rowguid,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser,
                    AuditCreateDTM
                )
                VALUES
                (   @IdfsSampleType,                                                           -- idfsBaseReference - bigint
                    19000087,                                                                  -- idfsReferenceType - bigint
                    @LOINC_NUM,                                                                -- LOINC_NUM - nvarchar(255)
                    0,                                                                         -- intRowStatus - int
                    NEWID(),                                                                   -- rowguid - uniqueidentifier
                    10519001,                                                                  -- SourceSystemNameID - bigint
                    N'[{"idfsBaseReference":' + CAST(@IdfsSampleType AS NVARCHAR(300)) + '}]', -- SourceSystemKeyValue - nvarchar(max)
                    @AuditUserName,
                    GETDATE()                                                                  -- AuditCreateDTM - datetime
                );
            END
        END

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage,
               @idfsSampleType AS idfsSampleType;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Transaction uncommittable
        IF (XACT_STATE()) = -1
            ROLLBACK TRANSACTION;

        -- Transaction committable
        IF (XACT_STATE()) = 1
            COMMIT TRANSACTION;
        THROW;
    END CATCH
END



