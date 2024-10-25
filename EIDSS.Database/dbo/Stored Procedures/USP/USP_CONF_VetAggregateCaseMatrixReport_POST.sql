/*******************************************************
NAME						: [USP_CONF_VetAggregateCaseMatrixReport_POST]	


Description					: Saves Entries For Vet Aggregate Case Matrix Report

Author						: Lamont Mitchell

Revision History
		
			Name							Date								Change Detail
			Lamont Mitchell					01/24/19							Initial Created
*******************************************************/
CREATE PROCEDURE [dbo].[USP_CONF_VetAggregateCaseMatrixReport_POST]
	

@idfAggrVetCaseMTX	BIGINT NULL,
@idfVersion				BIGINT NULL, 
@idfsDiagnosis			BIGINT NULL, 
@intNumRow				INT	





AS BEGIN
	DECLARE @returnMsg					VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode					BIGINT = 0;
	Declare @idfsReferenceType			BIGINT ;

	SET NOCOUNT ON;
		Declare @SupressSelect table
	( 
		retrunCode int,
		returnMessage varchar(200)
	)
	BEGIN TRY
		IF EXISTS (SELECT * FROM [dbo].[tlbAggrVetCaseMTX] WHERE idfVersion = @idfVersion AND idfsDiagnosis = @idfsDiagnosis )
			BEGIN
				UPDATE [dbo].[tlbAggrVetCaseMTX]
				SET
				[intRowStatus] =		0
				WHERE [idfVersion] =	@idfVersion
				AND idfsDiagnosis =  @idfsDiagnosis
			END
			BEGIN
			INSERT INTO @SupressSelect
			EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAggrVetCaseMTX', @idfAggrVetCaseMTX OUTPUT
			INSERT INTO [tlbAggrVetCaseMTX]
			   (
						idfAggrVetCaseMTX
						,idfVersion
					   ,idfsDiagnosis
					   ,intNumRow
					   ,intRowStatus
					   
				)
			VALUES	
			   (
						@idfAggrVetCaseMTX
						,@idfVersion
					   ,@idfsDiagnosis
					   ,@intNumRow
					   ,1
				)
			END
			SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage',@idfAggrVetCaseMTX 'idfAggrVetCaseMTX'
		END TRY
		BEGIN CATCH
				THROW;
		END CATCH
END
