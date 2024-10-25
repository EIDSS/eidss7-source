

--*************************************************************
-- Name 				: USP_VCTS_SESSIONSUMMARY_DEL
-- Description			: 
--          
-- Author               : Harold Pryor
-- Revision History
--		Name       Date       Change Detail
--  Harold Pryor  5/22/2018  Initial Creation
--
-- Testing code:
--*************************************************************

 
CREATE PROCEDURE [dbo].[USP_VCTS_SESSIONSUMMARY_DEL]
(	 
	@idfsVSSessionSummary		   BIGINT
)
AS

DECLARE @ReturnCode INT = 0
DECLARE @ReturnMessage  NVARCHAR(max) = 'SUCCESS'

BEGIN
	BEGIN TRY
				IF EXISTS(select idfsVSSessionSummary from dbo.tlbVectorSurveillanceSessionSummary where idfsVSSessionSummary  = @idfsVSSessionSummary)
					Begin
						update dbo.tlbVectorSurveillanceSessionSummary
						SET		intRowStatus = 1
						WHERE	idfsVSSessionSummary  = @idfsVSSessionSummary

						update  dbo.tlbVectorSurveillanceSessionSummaryDiagnosis
						SET		intRowStatus = 1
						WHERE	idfsVSSessionSummary = @idfsVSSessionSummary
					End
	END TRY
	BEGIN CATCH
		BEGIN 
		

			SET @ReturnCode = ERROR_NUMBER()
			SET @ReturnMessage = 
				'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
				+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
				+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
				+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
				+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
				+ ' ErrorMessage: '+ ERROR_MESSAGE()
		END

	END CATCH
			SELECT @ReturnCode AS ReturnCode, @ReturnMessage AS ReturnMessage	
END 


