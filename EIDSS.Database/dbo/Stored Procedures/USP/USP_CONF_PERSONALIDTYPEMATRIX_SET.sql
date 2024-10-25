-- ================================================================================================
-- Name: USP_CONF_PERSONALIDTYPEMATRIX_SET
--
-- Description: Creates a personal identification type matrix record.
--
-- Author: Ricky Moss
--
-- Revision History:
-- Name						Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Ricky Moss				07/10/2019 Initial Release
-- Ricky Moss				08/10/2019 Duplicate Prevention
-- Stephen Long             07/13/2022 Added site alert logic.
-- 
-- USP_CONF_PERSONALIDTYPEMATRIX_SET 58010200000000, 'Numeric', 4, 0
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_PERSONALIDTYPEMATRIX_SET]
(
    @idfPersonalIDType BIGINT,
    @strFieldType NVARCHAR(50),
    @Length INT,
    @intOrder INT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @ReturnCode BIGINT = 0,
        @idfPersonalIDAttributeType BIGINT = NULL,
        @EventId BIGINT = -1,
        @EventSiteId BIGINT = @SiteId,
        @EventUserId BIGINT = @UserId,
        @EventDiseaseId BIGINT = NULL,
        @EventLocationId BIGINT = @LocationId,
        @EventInformationString NVARCHAR(MAX) = NULL,
        @EventLoginSiteId BIGINT = @SiteId;
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);
BEGIN
    BEGIN TRY
        IF NOT EXISTS
        (
            SELECT idfsBaseReference
            FROM dbo.trtBaseReferenceAttribute
            WHERE idfsBaseReference = @idfPersonalIDType
        )
        BEGIN
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'trtBaseReferenceAttribute',
                                              @idfPersonalIDAttributeType OUTPUT;

            INSERT INTO dbo.trtBaseReferenceAttribute
            (
                idfBaseReferenceAttribute,
                idfsBaseReference,
                idfAttributeType,
                varValue,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (   @idfPersonalIDAttributeType,
                @idfPersonalIDType,
                (
                    SELECT idfAttributeType
                    FROM trtAttributeType
                    WHERE strAttributeTypeName = 'PIT-DataType'
                ),
                @strFieldType,
                GETDATE(),
                @AuditUserName
            );

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'trtBaseReferenceAttribute',
                                              @idfPersonalIDAttributeType OUTPUT;

            INSERT INTO dbo.trtBaseReferenceAttribute
            (
                idfBaseReferenceAttribute,
                idfsBaseReference,
                idfAttributeType,
                varValue,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (   @idfPersonalIDAttributeType,
                @idfPersonalIDType,
                (
                    SELECT idfAttributeType
                    FROM dbo.trtAttributeType
                    WHERE strAttributeTypeName = 'PIT-MaxLength'
                ),
                @Length,
                GETDATE(),
                @AuditUserName
            );

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'trtBaseReferenceAttribute',
                                              @idfPersonalIDAttributeType OUTPUT;

            INSERT INTO dbo.trtBaseReferenceAttribute
            (
                idfBaseReferenceAttribute,
                idfsBaseReference,
                idfAttributeType,
                varValue,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (   @idfPersonalIDAttributeType,
                @idfPersonalIDType,
                (
                    SELECT idfAttributeType
                    FROM trtAttributeType
                    WHERE strAttributeTypeName = 'PIT-DisplayOrder'
                ),
                @intOrder,
                GETDATE(),
                @AuditUserName
            );

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                            @EventTypeId,
                                            @EventUserId,
                                            @idfPersonalIDAttributeType,
                                            @EventDiseaseId,
                                            @EventSiteId,
                                            @EventInformationString,
                                            @EventLoginSiteId,
                                            @EventLocationId,
                                            @AuditUserName;
        END
        ELSE
        BEGIN
            SELECT @ReturnMessage = 'DOES EXIST';
            SELECT @idfPersonalIDAttributeType =
            (
                SELECT TOP 1
                    (idfsBaseReference)
                FROM dbo.trtBaseReferenceAttribute
                WHERE idfsBaseReference = @idfPersonalIDType
            );
        END

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfPersonalIDAttributeType AS 'idfPersonalIDAttributeType';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
