

--*************************************************************
-- Name 				: USP_VCTS_SURVEILLANCE_SESSION_DEL
-- Description			: Mark a vector surveillance session inactive
--							including all of its subordinate detailed collections,
--							aggregate collections, and disease lists.
--          
-- Author               : Harold Pryor
-- Revision History
--		Name		Date			Change Detail
-- Harold Pryor		05/21/2018		Updated to implement cascading delete
-- Mike Kornegay	04/22/2022		Changed name from USP_VCTS_VecSession_DEL to USP_VCTS_SURVEILLANCE_SESSION_DEL 
-- Lamont Mitchell	05/26/2022		Added check for child objects and dependents
-- Mike Kornegay	08/04/2022		Fixed up formatting and added logic to check for aggregate collections.
--
-- Testing code:
--*************************************************************

 
CREATE PROCEDURE [dbo].[USP_VCTS_SURVEILLANCE_SESSION_DEL]
(	 
	@idfVectorSurveillanceSession   BIGINT
)
AS

DECLARE @returnCode INT = 0;
DECLARE @returnMsg  NVARCHAR(max) = 'SUCCESS'

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION			
			
		
				
				IF EXISTS ( SELECT * FROM dbo.tlbMaterial WHERE intRowStatus = 0 AND idfVectorSurveillanceSession = @idfVectorSurveillanceSession)
				BEGIN
						SET @returnCode = 1
						SET @returnMsg ='Unable to delete this record as it contains dependent child objects'
						SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'
				END
				ELSE IF EXISTS(SELECT * FROM dbo.tlbTesting  WHERE intRowStatus = 0 AND idfMaterial in (select idfMaterial from dbo.tlbMaterial where idfVectorSurveillanceSession = @idfVectorSurveillanceSession) )
				BEGIN
						SET @returnCode = 1
						SET @returnMsg ='Unable to delete this record as it contains dependent child objects'
						SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'
				END
				ELSE IF EXISTS(SELECT * FROM dbo.tlbVector WHERE intRowStatus = 0 AND idfVectorSurveillanceSession = @idfVectorSurveillanceSession   )
				BEGIN
						SET @returnCode = 2
						SET @returnMsg ='Unable to delete this record as it is dependent on another object.'
						SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'
				END
				ELSE IF EXISTS(SELECT * FROM dbo.tlbVectorSurveillanceSessionSummary WHERE intRowStatus = 0 AND idfVectorSurveillanceSession = @idfVectorSurveillanceSession   )
				BEGIN
						SET @returnCode = 2
						SET @returnMsg ='Unable to delete this record as it is dependent on another object.'
						SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'
				END
				ELSE 
				BEGIN

						UPDATE	dbo.tlbVectorSurveillanceSession
						SET		intRowStatus = 1
						WHERE	idfVectorSurveillanceSession = @idfVectorSurveillanceSession 

						update dbo.tlbVector 
						SET		intRowStatus = 1
						WHERE	idfVectorSurveillanceSession = @idfVectorSurveillanceSession 
				
						update dbo.tlbMaterial
						SET		intRowStatus = 1
						WHERE	idfVectorSurveillanceSession = @idfVectorSurveillanceSession 

						update dbo.tlbTesting 
						SET		intRowStatus = 1
						WHERE	idfMaterial in (select idfMaterial from dbo.tlbMaterial where idfVectorSurveillanceSession = @idfVectorSurveillanceSession) 


						update dbo.tlbVectorSurveillanceSessionSummary
						SET		intRowStatus = 1
						WHERE	idfVectorSurveillanceSession  = @idfVectorSurveillanceSession 

						update dbo.tlbVectorSurveillanceSessionSummaryDiagnosis
						SET		intRowStatus = 1
						WHERE	idfsVSSessionSummary in (select idfsVSSessionSummary from dbo.tlbVectorSurveillanceSessionSummary where idfVectorSurveillanceSession  = @idfVectorSurveillanceSession) 

						SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'
		
  				
					IF @@TRANCOUNT > 0 
					COMMIT;

			END
	END TRY

	BEGIN CATCH
	
			IF @@TRANCOUNT  > 0 
				ROLLBACK

			SET @returnCode = ERROR_NUMBER()
			SET @returnMsg = 
				'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
				+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
				+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
				+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
				+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
				+ ' ErrorMessage: '+ ERROR_MESSAGE()

			SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'
	
	
	END CATCH
END -- Stored Proc END


