-- ================================================================================================
-- Name: USP_REF_VectorSubType_SET
--
-- Description:	Creates or updates vector sub-types.
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		10/18/2018 Initial release.
-- Lamont Mitchell	01/03/2019 Aliased Return Columns and Supressed Selects from Stored Procs
-- Ricky Moss		01/17/2019 Merged with USP_REF_VECTORSUBTYPE_DOESEXIST
-- Ricky Moss		01/24/2019 Added vector type exist clause to verify if vector sub type exists
-- Ricky Moss		02/11/2019 Checks to see when updating a vector sub type that the name does 
--                             not exist in another reference
-- Ricky Moss		02/18/2019 Refactored the check duplicates
-- Ricky Moss		04/10/2020 Refactored to reactivate inactive references and resolved 
--                             translated value updates
-- Ann Xiong		04/05/2021 Fixed a bug when updating strCode
-- Ann Xiong		04/12/2021 Refactored to make use of USSP_GBL_BaseReference_SET, and to change 
--                             the branch decisions for insert/update.
-- Mark Wilson		08/04/2021 Updated checks for duplicates and call is now to 
--                             USP_GBL_BaseReference_Set
-- Stephen Long     07/18/2022 Added site alert logic.
--
/*

 exec USP_REF_VectorSubType_SET NULL, 65340040000864, 'Mark subTypeTest2', 'Mark subTypeTest2', NULL, 100000, 'en-US'
 exec USP_REF_VectorSubType_SET 389445040003863, 65340040000864, 'Mark subTypeTest2', 'Mark subTypeTest99', NULL, 100000, 'en-US'
 exec USP_REF_VectorSubType_SET 389445040003825, 389445040002857, N'Vector Species Type8 National2', N'Vector Species Type8', N'9', 2, 'en-US'

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_VectorSubType_SET]
    @idfsVectorSubType BIGINT = NULL,
    @idfsVectorType BIGINT,
    @strName NVARCHAR(200),
    @strDefault VARCHAR(200),
    @strCode VARCHAR(50),
    @intOrder INT,
    @LangID NVARCHAR(50),
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
AS
DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @ReturnCode BIGINT = 0,
        @existingDefault BIGINT = 0;

DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);
BEGIN
    BEGIN TRY
        IF @idfsVectorSubType IS NULL
        BEGIN -- this is an insert.  check if the strDefault is a duplicate
            IF EXISTS
            (
                SELECT *
                FROM dbo.trtBaseReference
                WHERE strDefault = @strDefault
                      AND idfsReferenceType = 19000141
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
                WHERE idfsBaseReference <> @idfsVectorSubType
                      AND strDefault = @strDefault
                      AND idfsReferenceType = 19000141
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
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_BaseReference_SET @ReferenceID = @idfsVectorSubType OUTPUT,
                                               @ReferenceType = 19000141,
                                               @LangID = @LangID,
                                               @DefaultName = @strDefault,
                                               @NationalName = @strName,
                                               @HACode = NULL,
                                               @Order = @intOrder,
                                               @System = 0,
                                               @User = @AuditUserName;
            IF NOT EXISTS
            (
                SELECT *
                FROM dbo.trtVectorSubType
                WHERE idfsVectorSubType = @idfsVectorSubType
            )
            BEGIN
                INSERT INTO dbo.trtVectorSubType
                (
                    idfsVectorSubType,
                    idfsVectorType,
                    strCode,
                    intRowStatus,
                    rowguid,
                    strMaintenanceFlag,
                    strReservedAttribute,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateDTM,
                    AuditUpdateUser
                )
                VALUES
                (@idfsVectorSubType,
                 @idfsVectorType,
                 @strCode,
                 0  ,
                 NEWID(),
                 'ADD',
                 'EIDSS7 Vector Sub-Type',
                 10519001,
                 N'[{"idfsVectorSubType":' + CAST(@idfsVectorSubType AS NVARCHAR(300)) + '}]',
                 GETDATE(),
                 @AuditUserName
                );

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                               @EventTypeId,
                                               @UserId,
                                               @idfsVectorSubType,
                                               NULL,
                                               @SiteId,
                                               NULL,
                                               @SiteId,
                                               @LocationId,
                                               @AuditUserName;
            END
            ELSE
            BEGIN
                UPDATE dbo.trtVectorSubType
                SET idfsVectorType = @idfsVectorType,
                    strCode = @strCode,
                    SourceSystemNameID = ISNULL(SourceSystemNameID, 10519001),
                    SourceSystemKeyValue = N'[{"idfsVectorSubType":' + CAST(@idfsVectorSubType AS NVARCHAR(300)) + '}]',
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsVectorSubType = @idfsVectorSubType
                      AND idfsVectorType = @idfsVectorType;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                               @EventTypeId,
                                               @UserId,
                                               @idfsVectorSubType,
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
               @idfsVectorSubType AS idfsVectorSubType;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH

END

