--*************************************************************
-- Name 				: [[USSP_VCT_SAMPLE_DETAILEDCOLLECTIONS_SET]]
-- Description			: add update delete Sample For Vector
--          
-- Author               : JWJ
-- Revision History
--		Name		Date       Change Detail
-- ---------------- ---------- --------------------------------
--Lamont Mitchell  11-22-21			Initial
--*************************************************************
CREATE PROCEDURE [dbo].[USSP_VCT_SAMPLE_DETAILEDCOLLECTIONS_SET] 
  	@SAMPLEPARAMETERS	NVARCHAR(MAX) = NULL,
	@AuditUser NVARCHAR(100)  =''
AS
Begin
	SET NOCOUNT ON;
	Declare @SupressSelect table
		( retrunCode int,
			returnMessage varchar(200)
		)
	
	Declare @LangID NVARCHAR(50) = NULL
	Declare @idfMaterial BIGINT = NULL
	Declare @strFieldBarcode NVARCHAR(200) = NULL
	Declare @idfsSampleType BIGINT = NULL
	Declare @idfVectorSurveillanceSession BIGINT = NULL
	Declare @idfVector BIGINT = NULL
	Declare @idfSendToOffice BIGINT = NULL
	Declare @idfFieldCollectedByOffice BIGINT = NULL
	Declare @strNote NVARCHAR(500) = NULL
	Declare @datFieldCollectionDate DATETIME = NULL
	Declare @EnteredDate DATETIME = NULL
	Declare @SiteID BIGINT
	Declare @idfsDiagnosis BIGINT
	Declare @intRowStatus	int
	Declare @idfsSite       int = 1
	Declare @RowAction nvarchar(1)
	DECLARE @ReturnCode	INT = 0 
	DECLARE	@ReturnMessage	NVARCHAR(MAX) = 'SUCCESS'



	--SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage', @idfHumanCase 'idfHumanCase';
		 	--Check if there are no samples associated to report.  If not Update the Samples Collected Flag to No / False
			
	


	DECLARE  @SamplesTemp TABLE (				
			[idfMaterial] [BIGINT],
			[strFieldBarcode] [NVARCHAR],
			[idfsSampleType] [BIGINT],
			[idfVectorSurveillanceSession] [BIGINT],
			[idfVector] [BIGINT],
			[idfSendToOffice] [BIGINT],
			[idfFieldCollectedByOffice] [BIGINT],
			[strNote] [NVARCHAR],
			[datFieldCollectionDate] [DATETIME],
			[EnteredDate] [DATETIME],
			[SiteID] [BIGINT],
			[idfsDiagnosis] [BIGINT],
			[intRowStatus] [int],
			[RowAction] [nvarchar](1)
			)


	INSERT INTO	@SamplesTemp 
	SELECT * FROM OPENJSON(@SAMPLEPARAMETERS) 
			WITH (
			[idfMaterial] [BIGINT],
			[strFieldBarcode] [NVARCHAR],
			[idfsSampleType] [BIGINT],
			[idfVectorSurveillanceSession] [BIGINT],
			[idfVector] [BIGINT],
			[idfSendToOffice] [BIGINT],
			[idfFieldCollectedByOffice] [BIGINT],
			[strNote] [NVARCHAR],
			[datFieldCollectionDate] [DATETIME],
			[EnteredDate] [DATETIME],
			[SiteID] [BIGINT],
			[idfsDiagnosis] [BIGINT],
			[intRowStatus] [int],
			[RowAction] [nvarchar](1)
				);
	BEGIN TRY  
		WHILE EXISTS (SELECT * FROM @SamplesTemp)
			BEGIN
				SELECT TOP 1
				@idfMaterial = idfMaterial,
				@strFieldBarcode = strFieldBarcode,
				@idfsSampleType = idfsSampleType,
				@idfVectorSurveillanceSession = idfVectorSurveillanceSession ,
				@idfVector =idfVector ,
				@idfSendToOffice =  idfSendToOffice ,
				@idfFieldCollectedByOffice = idfFieldCollectedByOffice,
				@strNote = strNote ,
				@datFieldCollectionDate = datFieldCollectionDate,
				@EnteredDate = EnteredDate ,
				@SiteID = SiteID ,
				@idfsDiagnosis = idfsDiagnosis ,
				@intRowStatus = intRowStatus ,
				@RowAction =  RowAction 
				FROM @SamplesTemp
	

		--IF NOT EXISTS(SELECT * from tlbMaterial WHERE idfVector = @idfVector AND intRowStatus = 0)
		
				INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_GBL_SAMPLE_SET 
				@LangID,
				@idfMaterial OUTPUT,
				@idfsSampleType,
				NULL, 
				NULL, 
				NULL,
				NULL,
				NULL,
				@idfVector,
				NULL,
				@idfVectorSurveillanceSession,
				NULL,
				NULL,
				@datFieldCollectionDate,
				NULL,
				@idfFieldCollectedByOffice,
				Null,
				@idfSendToOffice,
				@strFieldBarcode,
				@SiteID,
				@EnteredDate,
				0,
				NULL,
				@strNote,
				NULL,
				@idfsDiagnosis,
				NULL,
				@intRowStatus,
				@RowAction;

			SET ROWCOUNT 1
					DELETE Top(1) FROM @SamplesTemp
					--SET ROWCOUNT 0
			END		--end loop, WHILE EXISTS (SELECT * FROM @SamplesTemp)
			

			
	END TRY
		BEGIN CATCH
		
			SET @ReturnCode = ERROR_NUMBER()
			SET @ReturnMessage = 
					'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
					+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
					+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
					+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
					+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
					+ ' ErrorMessage: '+ ERROR_MESSAGE();
		
	END CATCH
	SELECT 
		@ReturnCode AS ReturnCode
	   ,@ReturnMessage AS ReturnMesssage
END
