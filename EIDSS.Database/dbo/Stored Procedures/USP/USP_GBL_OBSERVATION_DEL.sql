
-- ============================================================================
-- Name: USP_GBL_OBSERVATION_DEL

-- Description:	Deletes observation records and associated activity parameters 
-- for various use cases.
--
-- Revision History:
-- Name  Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Stephen Long     06/17/2019 Initial release.
-- ============================================================================
CREATE PROCEDURE [dbo].[USP_GBL_OBSERVATION_DEL]
(
	@ObservationID BIGINT = NULL
)
AS

DECLARE @ReturnCode INT = 0;
DECLARE	@ReturnMessage NVARCHAR(MAX) = 'SUCCESS';

BEGIN
	SET NOCOUNT ON;

    BEGIN TRY
		BEGIN TRANSACTION

		UPDATE dbo.tlbActivityParameters 
		SET intRowStatus = 1 
		WHERE idfObservation = @ObservationID;

		UPDATE dbo.tlbObservation
		SET intRowStatus = 1
		WHERE idfObservation = @ObservationID;

		IF @@TRANCOUNT > 0 AND @ReturnCode = 0
			COMMIT;

		SELECT @ReturnCode 'ReturnCode', @ReturnMessage 'ReturnMessage'
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END
