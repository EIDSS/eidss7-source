--*************************************************************
-- Name 				: USP_VCTS_SESSIONSUMMARYDIAGNOSIS_SET
-- Description			: Vector Sessions Summary Diagnosis Delete
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name       Date       Change Detail
--
--
-- Testing code:
--*************************************************************

CREATE PROCEDURE [dbo].[USP_VCTS_SESSIONSUMMARYDIAGNOSIS_DEL]
(
     @idfsVSSessionSummaryDiagnosis BIGINT
)
AS
DECLARE @ReturnCode					INT = 0 
DECLARE	@ReturnMessage					NVARCHAR(max) = 'SUCCESS' 
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

			BEGIN
				DELETE
				FROM	[dbo].[tlbVectorSurveillanceSessionSummaryDiagnosis]
				WHERE 	[idfsVSSessionSummaryDiagnosis] = @idfsVSSessionSummaryDiagnosis
			END

		IF @@TRANCOUNT > 0 AND @ReturnCode =0
			COMMIT

		SELECT @ReturnCode ReturnCode , @ReturnMessage ReturnMessage
	END TRY

	BEGIN CATCH
			IF @@Trancount = 1 
				ROLLBACK
				SET @ReturnCode = ERROR_NUMBER()
				SET @ReturnMessage = 
			   'ErrorNumber: ' + convert(varchar, ERROR_NUMBER() ) 
			   + ' ErrorSeverity: ' + convert(varchar, ERROR_SEVERITY() )
			   + ' ErrorState: ' + convert(varchar,ERROR_STATE())
			   + ' ErrorProcedure: ' + isnull(ERROR_PROCEDURE() ,'')
			   + ' ErrorLine: ' +  convert(varchar,isnull(ERROR_LINE() ,''))
			   + ' ErrorMessage: '+ ERROR_MESSAGE()
			   ----select @LogErrMsg

			  SELECT @ReturnCode ReturnCode , @ReturnMessage ReturnMessage

	END CATCH
END
