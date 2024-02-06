--*************************************************************
-- Name 				: [USSP_VCT_AGGREGATE_DIAGNOSIS_SET]
-- Description			: add update delete Diagnosis List for Vector
--          
-- Author               : JWJ
-- Revision History
--		Name		Date       Change Detail
-- ---------------- ---------- --------------------------------
--Lamont Mitchell  11-22-21			Initial
--*************************************************************
CREATE PROCEDURE [dbo].[USSP_VCT_AGGREGATE_DISEASEDIAGNOSIS_SET] 
  	@DiseaseDiagnosisParameters	NVARCHAR(MAX) = NULL,
	@AuditUser NVARCHAR(100)  =''
AS
Begin
	SET NOCOUNT ON;
	Declare @SupressSelect table
		( retrunCode int,
			returnMessage varchar(200)
		)
	
	Declare @idfsVSSessionSummaryDiagnosis BIGINT = NULL
	Declare @idfsVSSessionSummary BIGINT = NULL
	Declare @idfsDiagnosis BIGINT = NULL
	Declare @intPositiveQuantity BIGINT = NULL
	Declare @intRowStatus	int
	Declare @idfsSite       int = 1
	Declare @RowAction nvarchar(1)
	DECLARE @ReturnCode	INT = 0 
	DECLARE	@ReturnMessage	NVARCHAR(MAX) = 'SUCCESS'



	--SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage', @idfHumanCase 'idfHumanCase';
		 	--Check if there are no samples associated to report.  If not Update the Samples Collected Flag to No / False
			
	


	DECLARE  @DiagnosisTemp TABLE (				
					[idfsVSSessionSummaryDiagnosis] [bigint],
					[idfsVSSessionSummary] [bigint],
					[idfsDiagnosis] [bigint],
					[intPositiveQuantity] [int],
					[intRowStatus] [int],
					RowAction [nvarchar](1)
			)


	INSERT INTO	@DiagnosisTemp 
	SELECT * FROM OPENJSON(@DiseaseDiagnosisParameters) 
			WITH (
					[idfsVSSessionSummaryDiagnosis] [bigint],
					[idfsVSSessionSummary] [bigint],
					[idfsDiagnosis] [bigint],
					[intPositiveQuantity] [int],
					[intRowStatus] [int],
					RowAction [nvarchar](1)
				);
	BEGIN TRY  
		WHILE EXISTS (SELECT * FROM @DiagnosisTemp)
			BEGIN
				SELECT TOP 1
				@idfsVSSessionSummaryDiagnosis = idfsVSSessionSummaryDiagnosis,
				@idfsVSSessionSummary = idfsVSSessionSummary,
				@idfsDiagnosis = idfsDiagnosis,
				@intPositiveQuantity = intPositiveQuantity,
				@returnCode	 = 0,
				@intRowStatus = intRowStatus,
				@RowAction = RowAction					
				FROM @DiagnosisTemp
	

		IF NOT EXISTS(SELECT * from tlbVectorSurveillanceSessionSummaryDiagnosis WHERE @idfsVSSessionSummaryDiagnosis = idfsVSSessionSummaryDiagnosis AND intRowStatus = 0)
		BEGIN
				INSERT INTO @SupressSelect
				EXEC				
					dbo.USP_GBL_NEXTKEYID_GET 'tlbVectorSurveillanceSessionSummaryDiagnosis', @idfsVSSessionSummaryDiagnosis OUTPUT;
					INSERT INTO		dbo.tlbVectorSurveillanceSessionSummaryDiagnosis
					(	
						idfsVSSessionSummaryDiagnosis,
						idfsVSSessionSummary,
						idfsDiagnosis,
						intPositiveQuantity,
						intRowStatus,
						AuditCreateUser
					)
					VALUES
					(	
						@idfsVSSessionSummaryDiagnosis,
						@idfsVSSessionSummary,
						@idfsDiagnosis,
						@intPositiveQuantity,
						0,
						@AuditUser
					)

			END
		ELSE
			BEGIN
			IF @RowAction = 'D' 
					BEGIN
						SET @intRowStatus = 1
					END
				ELSE
					BEGIN
						SET @intRowStatus = 0
					END

				UPDATE dbo.tlbVectorSurveillanceSessionSummaryDiagnosis
				SET 
					idfsVSSessionSummary =	@idfsVSSessionSummary,
					idfsDiagnosis=	@idfsDiagnosis,
					intPositiveQuantity=@intPositiveQuantity,
					intRowStatus =	@intRowStatus,
					AuditUpdateUser = @AuditUser
				WHERE	idfsVSSessionSummaryDiagnosis = @idfsVSSessionSummaryDiagnosis;
			END
			
		
			SET ROWCOUNT 1
					DELETE Top(1) FROM @DiagnosisTemp
					--SET ROWCOUNT 0
			END		--end loop, WHILE EXISTS (SELECT * FROM @SamplesTemp)
			

			
	END TRY
		BEGIN CATCH
			IF @@Trancount > 0
				ROLLBACK

			SET @ReturnCode = ERROR_NUMBER()
			SET @ReturnMessage = 
					'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
					+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
					+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
					+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
					+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
					+ ' ErrorMessage: '+ ERROR_MESSAGE();
			THROW;

	END CATCH
	SELECT 
		@ReturnCode AS ReturnCode
	   ,@ReturnMessage AS ReturnMesssage
END
