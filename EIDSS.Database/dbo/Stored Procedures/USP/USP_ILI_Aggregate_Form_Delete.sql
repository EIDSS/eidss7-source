

--*************************************************************
-- Name 				: USP_ILI_Aggregate_Form_Delete
-- Description			: Deletes FORM data for ILI Aggregate  
--          
-- Author               : Lamont Mitchell
-- Revision History
--		Name			Date        Change Detail
--		LJM				7/26/19		Initial
--		Leo Tracchia	09/08/2021	modified to remove delete on tlbBasicSyndromicSurveillanceAggregateHeader
--
-- Testing code:
--*************************************************************
CREATE PROCEDURE [dbo].[USP_ILI_Aggregate_Form_Delete]
(  
	
	--@formID				AS Varchar(max),
	@UserId				Varchar(Max),
	@idfAggregateDetail bigint
)  

AS  

DECLARE @returnMsg VARCHAR(MAX) = 'Success'
DECLARE @returnCode BIGINT = 0

BEGIN

	BEGIN TRY  	

		--DECLARE @MyTableVariable TABLE (
		--	headers INT
		--);

		--INSERT INTO @MyTableVariable
		--	Select idfAggregateHeader FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader where strFormID = @formID
		
		Update  dbo.tlbBasicSyndromicSurveillanceAggregateDetail
			Set intRowStatus = 1, 
			AuditUpdateUser = @UserId,
			AuditUpdateDTM = GETDATE()
			WHERE  idfAggregateDetail = @idfAggregateDetail 

		--Update  tlbBasicSyndromicSurveillanceAggregateHeader 
		--	Set intRowStatus = 1,
		--	AuditUpdateUser = @UserId,
		--	AuditUpdateDTM = GETDATE()
		--	WHERE  strFormID = @formID

		--IF @@TRANCOUNT > 0 
		--	COMMIT;

		SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMsg'

	END TRY  

	BEGIN CATCH 
		
		--SET @returnMsg = 
		--	'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
		--	+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
		--	+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
		--	+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
		--	+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
		--	+ ' ErrorMessage: '+ ERROR_MESSAGE()

		--SET @returnCode = ERROR_NUMBER()
		
		--SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMsg'

		THROW;

	END CATCH
END
