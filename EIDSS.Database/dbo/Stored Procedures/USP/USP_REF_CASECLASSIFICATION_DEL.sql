-- ============================================================================
-- Name: USP_REF_CASECLASSIFICATION_DEL
--
-- Description:	Removes a case classification from the active list.
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		10/03/2018	Initial release.
-- Ricky Moss		12/12/2018	Removed return code
-- Ricky Moss		12/19/2018	Merge CANDEL and DEL stored procedures
-- Ricky Moss		01/02/2019	Added deleteAnyway paramater
-- Stephen Long     10/31/2022 Added site alert logic.
--
-- exec USP_REF_CASECLASSIFICATION_DEL 12137920000000, 0
-- ============================================================================
CREATE PROCEDURE [dbo].[USP_REF_CASECLASSIFICATION_DEL]
(
    @IdfsCaseClassification BIGINT,
    @DeleteAnyway BIT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    BEGIN TRY
        DECLARE @ReturnCode INT = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );

        IF NOT EXISTS
        (
            SELECT idfVetCase
            FROM dbo.tlbVetCase
            WHERE idfsCaseClassification = @IdfsCaseClassification
        )
           OR @DeleteAnyway = 1
        BEGIN
            UPDATE dbo.trtCaseClassification
            SET intRowStatus = 1
            WHERE idfsCaseClassification = @IdfsCaseClassification
                  and intRowStatus = 0

            UPDATE dbo.trtBaseReference
            SET intRowStatus = 1
            WHERE idfsBaseReference = @IdfsCaseClassification
                  AND intRowStatus = 0

            UPDATE dbo.trtStringNameTranslation
            SET intRowStatus = 1
            WHERE idfsBaseReference = @IdfsCaseClassification

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
            SELECT @ReturnCode = -1;
            SELECT @ReturnMessage = 'IN USE';
        END

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
