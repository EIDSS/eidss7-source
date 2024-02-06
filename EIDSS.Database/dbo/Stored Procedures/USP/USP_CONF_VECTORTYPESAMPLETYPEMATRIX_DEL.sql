-- ==========================================================================================
-- Name:		EXEC USP_CONF_VECTORTYPESAMPLETYPEMATRIX_DEL
-- Description:	Removes vector type to sample type matrix a vector type sample type id
-- Author:		Ricky Moss
-- Revision History:
-- Name             Date        Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		04/01/2019	Initial Release
-- Stephen Long     04/14/2023 Added site alert logic.
--
-- EXEC USP_CONF_VECTORTYPESAMPLETYPEMATRIX_DEL 6706830000003, 1
-- ==========================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_VECTORTYPESAMPLETYPEMATRIX_DEL]
(
	@idfSampleTypeForVectorType BIGINT,
	@deleteAnyway BIT,
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
		UPDATE dbo.trtSampleTypeForVectorType 
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(),
            AuditUpdateUser = @AuditUserName
        WHERE idfSampleTypeForVectorType = @idfSampleTypeForVectorType;

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                       @EventTypeId,
                                       @UserId,
                                       @idfSampleTypeForVectorType,
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
