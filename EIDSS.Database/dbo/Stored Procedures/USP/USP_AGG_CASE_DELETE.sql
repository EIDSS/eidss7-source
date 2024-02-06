

-- ================================================================================================
-- Name: USP_AGG_CASE_DELETE
--
-- Description: Deletes aggregate case object.
--          
-- Author: Arnold Kennedy
--
-- Revision History:
--	Name			Date		Change Detail
--	---------------	----------	--------------------------------------------------------------------
--	AK				05/01/2019	Changed spobservation_delete to USP_observation_delete
--	Stephen Long	06/30/2019	Added dbo prefix to database object names.
--	Mark Wilson		10/21/2021	added @User and auditing information to delete
--	Doug Albanese	05/20/2022	Removed the deletion of observations, since it is causing historical records not to pull up the old answers
-- Testing code: 
/*
	DECLARE @ID BIGINT = 34390000806
	EXECUTE USP_AGG_CASE_DELETE  @ID, 'rykermase'

*/
--	@ID is AggregateCaseID
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_AGG_CASE_DELETE]
(	
	@ID AS BIGINT,
	@User NVARCHAR(100) = NULL
)
AS
DECLARE @ReturnCode INT = 0; 
DECLARE	@ReturnMessage NVARCHAR(MAX) = 'SUCCESS'; 
DECLARE @idfObservation BIGINT;

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		
		SELECT @idfObservation = idfCaseObservation
		FROM dbo.tlbAggrCase
		WHERE idfAggrCase = @ID;

		DELETE FROM dbo.tflAggrCaseFiltered 
		WHERE idfAggrCase = @ID;

		UPDATE dbo.tlbAggrCase
		SET intRowStatus = 1,
			AuditUpdateUser = @User,
			AuditUpdateDTM = GETDATE()
		WHERE idfAggrCase = @ID;

		--EXEC dbo.USP_OBSERVATION_DELETE
		--	@ID = @idfObservation,
		--	@User = @User

		IF @@TRANCOUNT > 0 
		  COMMIT;

		SELECT @ReturnCode 'ReturnCode', @ReturnMessage 'ReturnMessage';
	END TRY 
		BEGIN CATCH 
		IF @@TRANCOUNT > 0
			ROLLBACK;

		THROW;
	END CATCH
END
