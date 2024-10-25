-- ================================================================================================
-- Name: USP_REF_CASECLASSIFICATION_SET
--
-- Description:	Get the Case Classification for reference listings.
--                      
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss       10/02/2018 Initial release.
-- Ricky Moss		10/04/2018 Updated the update piece of the stored procedure
-- Ricky Moss		12/19/2018 Removed return codes and id variables and merge SET and DOESEXIST 
--                             Stored procedures
-- Ricky Moss		01/02/2019 Added return codes
-- Ricky Moss		01/27/2019 Added case classification id value and english name already exists
-- Ricky Moss		02/10/2019 Checks to see when updating a case classification that the name 
--                             does not exists in another reference and updates English value
-- Ricky Moss		07/19/2019 Refactoring to check for duplicates
-- Ricky Moss		07/22/2019 Refactoring to check for duplicates
-- Ricky Moss		02/17/2020 Refactored to check for duplicates and update translated values
-- Ann Xiong		04/12/2021 Refactored to make use of USSP_GBL_BaseReference_SET, and to change 
--                             the branch decisions for insert/update.
-- Mark Wilson		08/04/2021 Updated to check for duplicates and to call 
--                             USP_GBL_BaseReference_SET
-- Mark Wilson		10/04/2021 Updated ISNULL on update set for SourceSystemKeyValue
-- Stephen Long     07/18/2022 Added site alert logic.

/*
exec USP_REF_CASECLASSIFICATION_SET 389445040003870, 'MarkWilson_Testnew', 'Test Locally 25', 1, 1, 'en-US', 6, 32
exec USP_REF_CASECLASSIFICATION_SET NULL, 'MarkWilson_Test99', 'Test 726-7', 0, 1, 'en-US', 8, 96

*/
-- ============================================================================
CREATE PROCEDURE [dbo].[USP_REF_CASECLASSIFICATION_SET]
(
    @idfsCaseClassification BIGINT = NULL,
    @strDefault NVARCHAR(200),
    @strName NVARCHAR(200),
    @blnInitialHumanCaseClassification BIT,
    @blnFinalHumanCaseClassification BIT,
    @LangID NVARCHAR(50) = NULL,
    @intOrder INT,
    @intHACode INT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN

    DECLARE @ReturnCode INT = 0,
            @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
            @existingDefault BIGINT = 0,
            @bNewRecord BIT = 0;

    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );

    BEGIN TRY

        IF @idfsCaseClassification IS NULL
        BEGIN -- this is an insert.  check if the strDefault is a duplicate
            IF EXISTS
            (
                SELECT *
                FROM dbo.trtBaseReference
                WHERE strDefault = @strDefault
                      AND idfsReferenceType = 19000011
                      AND intRowStatus = 0
            )
            BEGIN
                SET @existingDefault = 1;
            END
        END
        ELSE
        BEGIN -- this is an update.  check if the strDefault is a duplicate
            IF EXISTS
            (
                SELECT *
                FROM dbo.trtBaseReference
                WHERE idfsBaseReference <> @idfsCaseClassification
                      AND strDefault = @strDefault
                      AND idfsReferenceType = 19000011
                      AND intRowStatus = 0
            )
            BEGIN
                SET @existingDefault = 1;
            END
        END

        IF @existingDefault = 1 -- No need to go any further, as the strDefault is a duplicate
        BEGIN
            SELECT @ReturnMessage = 'DOES EXIST';
        END
        ELSE -- there is no duplicate, so continue
        BEGIN
            INSERT INTO @SuPpressSelect
            EXEC dbo.USP_GBL_BaseReference_SET @ReferenceID = @idfsCaseClassification OUTPUT,
                                               @ReferenceType = 19000011,
                                               @LangID = @LangID,
                                               @DefaultName = @strDefault,
                                               @NationalName = @strName,
                                               @HACode = @intHACode,
                                               @Order = @intOrder,
                                               @System = 0,
                                               @User = @AuditUserName;

            IF NOT EXISTS
            (
                SELECT *
                FROM dbo.trtCaseClassification
                WHERE idfsCaseClassification = @idfsCaseClassification
            )
            BEGIN
                INSERT INTO dbo.trtCaseClassification
                (
                    idfsCaseClassification,
                    blnInitialHumanCaseClassification,
                    blnFinalHumanCaseClassification,
                    intRowStatus,
                    rowguid,
                    strMaintenanceFlag,
                    strReservedAttribute,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateDTM,
                    AuditCreateUser
                )
                VALUES
                (@idfsCaseClassification,
                 @blnInitialHumanCaseClassification,
                 @blnFinalHumanCaseClassification,
                 0  ,
                 NEWID(),
                 'ADD',
                 'EIDSS7 Classification Type',
                 10519001,
                 N'[{"idfsCaseClassification":' + CAST(@idfsCaseClassification AS NVARCHAR(300)) + '}]',
                 GETDATE(),
                 @AuditUserName
                );

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                               @EventTypeId,
                                               @UserId,
                                               @idfsCaseClassification,
                                               NULL,
                                               @SiteId,
                                               NULL,
                                               @SiteId,
                                               @LocationId,
                                               @AuditUserName;
            END
            ELSE
            BEGIN
                UPDATE dbo.trtCaseClassification
                SET blnInitialHumanCaseClassification = @blnInitialHumanCaseClassification,
                    blnFinalHumanCaseClassification = @blnFinalHumanCaseClassification,
                    SourceSystemNameID = ISNULL(SourceSystemNameID, 10519001),
                    SourceSystemKeyValue = ISNULL(
                                                     SourceSystemKeyValue,
                                                     N'[{"idfsCaseClassification":'
                                                     + CAST(@idfsCaseClassification AS NVARCHAR(300)) + '}]'
                                                 ),
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsCaseClassification = @idfsCaseClassification;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                               @EventTypeId,
                                               @UserId,
                                               @idfsCaseClassification,
                                               NULL,
                                               @SiteId,
                                               NULL,
                                               @SiteId,
                                               @LocationId,
                                               @AuditUserName;
            END
        END

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage,
               @idfsCaseClassification AS idfsCaseClassification;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END

