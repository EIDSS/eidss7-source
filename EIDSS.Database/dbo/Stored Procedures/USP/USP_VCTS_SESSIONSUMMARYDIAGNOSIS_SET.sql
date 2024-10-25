
--*************************************************************
-- Name 				: USP_VCTS_SESSIONSUMMARYDIAGNOSIS_SET
-- Description			: Vector Sessions Summary Diagnosis Insert & Update
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name       Date       Change Detail
--
--
-- Testing code:
--*************************************************************

CREATE PROCEDURE [dbo].[USP_VCTS_SESSIONSUMMARYDIAGNOSIS_SET]
(
     @idfsVSSessionSummaryDiagnosis BIGINT = NULL,
	 @idfsVSSessionSummary BIGINT = NULL,
	 @idfsDiagnosis BIGINT = NULL,
	 @intPositiveQuantity BIGINT = NULL
)
AS

DECLARE @returnCode					INT = 0 
DECLARE	@returnMsg					NVARCHAR(max) = 'SUCCESS' 

DECLARE @SupressSelect TABLE
	( 
		retrunCode INT,
		returnMsg VARCHAR(200)
	)

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		IF NOT EXISTS (	SELECT idfsVSSessionSummaryDiagnosis FROM [dbo].[tlbVectorSurveillanceSessionSummaryDiagnosis]
						WHERE idfsVSSessionSummaryDiagnosis = @idfsVSSessionSummaryDiagnosis
						)
			BEGIN
				INSERT INTO @SupressSelect
				EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbVectorSurveillanceSessionSummaryDiagnosis', @idfsVSSessionSummaryDiagnosis OUTPUT
	
				INSERT INTO [dbo].[tlbVectorSurveillanceSessionSummaryDiagnosis]
						(
							[idfsVSSessionSummaryDiagnosis]
						   ,[idfsVSSessionSummary]
						   ,[idfsDiagnosis]
						   ,[intPositiveQuantity]
						)
				VALUES
						(
							@idfsVSSessionSummaryDiagnosis
							,@idfsVSSessionSummary
							,@idfsDiagnosis 
							,@intPositiveQuantity
						)
			END
		ELSE 
			BEGIN
				UPDATE	[dbo].[tlbVectorSurveillanceSessionSummaryDiagnosis]
				SET 	[idfsVSSessionSummary] = @idfsVSSessionSummary
						,[idfsDiagnosis] = @idfsDiagnosis
						,[intPositiveQuantity] = @intPositiveQuantity    
				WHERE 	[idfsVSSessionSummaryDiagnosis] = @idfsVSSessionSummaryDiagnosis
			END

		IF @@TRANCOUNT > 0 AND @returnCode =0
			COMMIT

	END TRY

	BEGIN CATCH
			IF @@Trancount = 1 
				ROLLBACK
				SET @returnCode = ERROR_NUMBER()
				SET @returnMsg = 
			   'ErrorNumber: ' + convert(varchar, ERROR_NUMBER() ) 
			   + ' ErrorSeverity: ' + convert(varchar, ERROR_SEVERITY() )
			   + ' ErrorState: ' + convert(varchar,ERROR_STATE())
			   + ' ErrorProcedure: ' + isnull(ERROR_PROCEDURE() ,'')
			   + ' ErrorLine: ' +  convert(varchar,isnull(ERROR_LINE() ,''))
			   + ' ErrorMessage: '+ ERROR_MESSAGE();
			   THROW;

	END CATCH

	SELECT 
		@returnCode AS ReturnCode
		,@returnMsg AS ReturnMsg
		,@idfsVSSessionSummaryDiagnosis AS idfsVSSessionSummaryDiagnosis

END
