

--*************************************************************
-- Name 				: USP_VCTS_VECT_DEL
-- Description			: 
--          
-- Author               : Harold Pryor
-- Revision History
--		Name       Date       Change Detail
--  Harold Pryor   05/22/2018  Initial Creation
--  Mike Kornegay  08/05/2022  Added logic to check for samples and field tests.
--
-- Testing code:
--*************************************************************

 
CREATE PROCEDURE [dbo].[USP_VCTS_VECT_DEL]
(	 
	@IdfVector		   BIGINT
)
AS

DECLARE @ReturnCode INT = 0;
DECLARE @ReturnMesssage  NVARCHAR(max) = 'SUCCESS'

BEGIN
	BEGIN TRY
			IF EXISTS ( SELECT * FROM dbo.tlbMaterial WHERE intRowStatus = 0 AND idfVector = @IdfVector)
				BEGIN
						SET @ReturnCode = 1
						SET @ReturnMesssage ='Unable to delete this record as it contains dependent child objects'
						SELECT @ReturnCode 'ReturnCode', @ReturnMesssage 'ReturnMessage'
				END
			ELSE IF EXISTS(SELECT * FROM dbo.tlbTesting  WHERE intRowStatus = 0 AND idfMaterial in (select idfMaterial from dbo.tlbMaterial where idfVector = @IdfVector) )
				BEGIN
						SET @ReturnCode = 1
						SET @ReturnMesssage ='Unable to delete this record as it contains dependent child objects'
						SELECT @ReturnCode 'ReturnCode', @ReturnMesssage 'ReturnMessage'
				END
			ELSE 
				IF EXISTS(SELECT * FROM tlbVector WHERE idfVector = @IdfVector)
				BEGIN
					update dbo.tlbVector 
					SET		intRowStatus = 1
					WHERE	idfVector = @idfVector

					update dbo.tlbMaterial
					SET		intRowStatus = 1
					WHERE	idfVector = @idfVector
				
					update dbo.tlbTesting 
					SET		intRowStatus = 1
					WHERE	idfVector = @IdfVector 
				END
	END TRY
	BEGIN CATCH
		BEGIN
			SET @ReturnCode = ERROR_NUMBER()
			SET @ReturnMesssage = 
				'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
				+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
				+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
				+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
				+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
				+ ' ErrorMessage: '+ ERROR_MESSAGE()
		END
	END CATCH
	  SELECT @ReturnCode AS ReturnCode, @ReturnMesssage AS ReturnMessage
END 


