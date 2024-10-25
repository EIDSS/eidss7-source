

--*************************************************************
-- Name 				: USP_VCTS_SAMPLE_DEL
-- Description			: 
--          
-- Author               : Harold Pryor
-- Revision History
--		Name       Date       Change Detail
--  Harold Pryor  5/21/2018  Initial Creation
-- LAMONT MITCHELL 01/25/2022 ADDED SUPRESSS AND ALIASED COLUMN HEADERS
-- Testing code:
--*************************************************************

 
CREATE PROCEDURE [dbo].[USP_VCTS_SAMPLE_DEL]
(	 
	@idfMaterial		   BIGINT
)
AS

DECLARE @returnCode INT = 0;
DECLARE @returnMsg  NVARCHAR(max) = 'SUCCESS'

	DECLARE @SupressSelect TABLE (
		ReturnCode INT,
		ReturnMessage VARCHAR(200),
		idfMaterial BIGINT
		);
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION			
			BEGIN
			--INSERT INTO @SupressSelect
			 --EXEC dbo.USSP_GBL_MATERIAL_DEL  @idfMaterial  THIS PROC DOES NOT EXISTS , CAUSED ISSUES  BECAUSE NO WARNING DISPLAYED IN SSMS
				update tlbMaterial
				set intRowStatus = 1 where idfMaterial = @idfMaterial;
			END
			IF @@TRANCOUNT > 0 
			COMMIT;
	END TRY
	BEGIN CATCH
		BEGIN 
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


		END
	END CATCH
				SELECT @returnCode As ReturnCode, @returnMsg As ReturnMessage
END


