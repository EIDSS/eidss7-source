-- ================================================================================================
-- Name: USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_DEL
--
-- Description:	Deletes an age group to statistical age group matrix
--
-- Author: Ricky Moss
-- Revision History:
-- Name                          Date       Change Detail
-- ----------------------------- ---------- ------------------------------------------------------
-- Ricky Moss                    04/03/2019 Initial Release
-- Stephen Long                  04/13/2023 Added site alert logic.
--
-- EXEC USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_DEL 51528390000001, 1
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_DEL]
(
    @idfDiagnosisAgeGroupToStatisticalAgeGroup BIGINT,
    @deleteAnyway BIT = 0,
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
        UPDATE dbo.trtDiagnosisAgeGroupToStatisticalAgeGroup
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(),
            AuditUpdateUser = @AuditUserName
        WHERE idfDiagnosisAgeGroupToStatisticalAgeGroup = @idfDiagnosisAgeGroupToStatisticalAgeGroup;

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                       @EventTypeId,
                                       @UserId,
                                       @idfDiagnosisAgeGroupToStatisticalAgeGroup,
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
