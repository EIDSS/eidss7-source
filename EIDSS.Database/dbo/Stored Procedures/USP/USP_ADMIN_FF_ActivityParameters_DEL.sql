

-- ================================================================================================
-- Name: USP_ADMIN_FF_ActivityParameters_DEL
-- Description: Deletes the Activity Parameter
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru    11/28/2018	Initial release for new API.
-- Doug Albanese	08/10/2021	Added corresponding BEGIN TRANSACTION
-- Mark Wilson		09/30/2021	Added @User and changed delete to intRowStatus = 0 and added Audit info
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ActivityParameters_DEL]
(
	@idfsParameter BIGINT,
	@idfObservation BIGINT,
	@idfRow BIGINT,
	@User NVARCHAR(100)
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	DECLARE
		@returnCode BIGINT = 0,
		@returnMsg  NVARCHAR(MAX) = 'Success'       
	
	BEGIN TRY
		BEGIN TRANSACTION

			UPDATE dbo.tlbActivityParameters
			SET intRowStatus = 1,
				AuditUpdateDTM = GETDATE(),
				AuditUpdateUser = @User
			WHERE idfsParameter = @idfsParameter 
			AND idfObservation = @idfObservation 
			AND idfRow = @idfRow

		COMMIT TRANSACTION;
		SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
