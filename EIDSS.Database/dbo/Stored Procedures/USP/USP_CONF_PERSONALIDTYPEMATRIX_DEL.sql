-- ================================================================================================
-- Name: USP_CONF_PERSONALIDTYPEMATRIX_DEL
--
-- Description: Removes a personal id type matrix
--
-- Author: Ricky Moss
--
-- Revision History:
-- Name						Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Ricky Moss				07/10/2019	Initial Release
-- Stephen Long             04/14/2023 Added site alert logic.
--
-- EXEC USP_CONF_PERSONALIDTYPEMATRIX_DEL 52433900000002
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_PERSONALIDTYPEMATRIX_DEL]
(
    @idfBaseReferenceAttribute BIGINT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);
BEGIN
    BEGIN TRY
        DELETE FROM dbo.trtBaseReferenceAttribute
        WHERE idfsBaseReference = @idfBaseReferenceAttribute;

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                       @EventTypeId,
                                       @UserId,
                                       @idfBaseReferenceAttribute,
                                       NULL,
                                       @SiteId,
                                       NULL,
                                       @SiteId,
                                       @LocationId,
                                       @AuditUserName;

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW
    END CATCH
END
