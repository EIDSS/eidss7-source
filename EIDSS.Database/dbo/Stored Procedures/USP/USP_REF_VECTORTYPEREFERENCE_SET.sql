-- ================================================================================================
-- Name: USP_VECTORTYPEREFERENCE_SET
--
-- Description:	Creates or updates vector types.
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		10/11/2018 Initial release.
-- Lamont Mitchell	01/03/2019 Aliased Returned Columns and Supressed Stored Procs
-- Ricky Moss		01/11/2019 Merged USP_VECTORTYPEREFERENCE_DOESEXIST 
--                             AND USP_VECTORTYPEREFERENCE_SET stored procedures
-- Ricky Moss		02/11/2019 Checks to see when updating a vector type that the name does not 
--                             exists in another reference
-- Ricky Moss		07/09/2019 Refactored duplication check and reactivated inactive vector type
-- Ricky Moss		02/18/2020 Refactoring to check for duplicates and added customization to base 
--                             reference
-- Ricky Moss		04/19/2020 Reactivate inactive reference 
-- Ricky Moss		05/05/2020 Refactor to resolve updating issues
-- Minal Shah		05/05/2021 Refactor to remove extra outuput parameter.
-- Leo Tracchia		06/23/2021 Added duplication check on Default value.
-- Stephen Long     07/18/2022 Added site alert logic.
--
-- exec USP_REF_VECTORTYPEREFERENCE_SET NULL, 'Test 8', 'Test 8', '', 0, 0, 'en'
-- exec USP_REF_VECTORTYPEREFERENCE_SET 55615180000044, 'Test the first time', 'Test the first time', '', 1, 0, 'en'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_VECTORTYPEREFERENCE_SET]
    @idfsVectorType BIGINT = NULL,
    @strDefault VARCHAR(200),
    @strName NVARCHAR(200),
    @strCode NVARCHAR(200),
    @bitCollectionByPool BIT,
    @intOrder INT,
    @LangID NVARCHAR(50),
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
AS
BEGIN

    DECLARE @ReturnCode INT = 0,
            @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
            @existingDefault BIGINT,
            @existingName BIGINT;
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );

    BEGIN TRY
        SELECT @existingDefault =
        (
            SELECT TOP 1
                (idfsReference)
            FROM dbo.fn_gbl_reference_getlist(@langId, 19000140)
            WHERE strDefault = @strDefault
        )

        IF (
               @existingDefault IS NOT NULL
               AND @existingDefault <> @idfsVectorType
           )
           OR (
                  @existingDefault IS NOT NULL
                  AND @idfsVectorType IS NULL
              )
        BEGIN
            SELECT @ReturnMessage = 'DOES EXIST';
            IF @existingDefault IS NOT NULL
                SELECT @idfsVectorType = @existingDefault;
        END
        ELSE
        BEGIN
            DECLARE @bNewRecord BIT = 0;

            IF @idfsVectorType IS NULL
            BEGIN
                SET @bNewRecord = 1;
                INSERT INTO @SuppressSelect
                EXEC USP_GBL_NEXTKEYID_GET 'trtBaseReference', @idfsVectorType OUTPUT;
            END

            EXEC dbo.USSP_GBL_BaseReference_SET @idfsVectorType OUTPUT,
                                                19000140,
                                                @LangID,
                                                @strDefault,
                                                @strName,
                                                null,
                                                @intOrder,
                                                0

            IF @bNewRecord = 1
            BEGIN
                INSERT INTO dbo.trtVectorType
                (
                    idfsVectorType,
                    strCode,
                    bitCollectionByPool,
                    intRowStatus,
                    AuditCreateDTM,
                    AuditCreateUser
                )
                VALUES
                (@idfsVectorType, @strCode, @bitCollectionByPool, 0, GETDATE(), @AuditUserName);
            END
            ELSE
            BEGIN
                UPDATE dbo.trtVectorType
                SET strCode = @strCode,
                    bitCollectionByPool = @bitCollectionByPool,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsVectorType = @idfsVectorType;
            END

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @idfsVectorType,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;
        END

        SELECT @ReturnMessage AS 'ReturnMessage',
               @ReturnCode AS 'ReturnCode',
               @idfsVectorType AS 'idfsVectorType';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
