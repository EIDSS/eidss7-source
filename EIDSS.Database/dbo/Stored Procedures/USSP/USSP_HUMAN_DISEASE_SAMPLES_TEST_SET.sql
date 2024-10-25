
--*************************************************************
-- Name 				: USSP_HUMAN_DISEASE_SAMPLES_TEST_SET
-- Description			: add update delete Human Disease Report Samples and Test
--          
-- Author               : JWJ
-- Revision History
--		Name		Date       Change Detail
-- ---------------- ---------- --------------------------------
-- Minal Shah		20220219		created 

-- Testing code:
-- exec USSP_HUMAN_DISEASE_SAMPLES_SET null
--*************************************************************
CREATE PROCEDURE [dbo].[USSP_HUMAN_DISEASE_SAMPLES_TEST_SET] 
    @idfHuman  BIGINT = NULL,
	@idfHumanCase BIGINT = NULL,
	@strHumanCaseID NVARCHAR(100)='',
	@DiseaseID BIGINT = NULL,
	@SamplesParameters	NVARCHAR(MAX) = NULL,
	@TestsParameters NVARCHAR(MAX) = NULL,
	@AuditUser NVARCHAR(100)  =''
	
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @SupressSelect TABLE
			( retrunCode INT,
			  returnMessage VARCHAR(200)
			)
	DECLARE
	--	@idfHumanCase	bigint,
		@idfMaterial	BIGINT,
		@strBarcode	NVARCHAR(200),
		@strFieldBarcode	NVARCHAR(200),
		@blnNumberingSchema INT = 0,
		@idfsSampleType	BIGINT,
		@strSampleTypeName	NVARCHAR(2000),
		@datFieldCollectionDate	DATETIME2,
		@idfSendToOffice	BIGINT,
		@strSendToOffice	NVARCHAR(2000),
		@idfFieldCollectedByOffice	BIGINT,
		@strFieldCollectedByOffice	NVARCHAR(2000),
		@datFieldSentDate	DATETIME2,
		@strNote	NVARCHAR(500),
		@datAccession	DATETIME2,
		@idfsAccessionCondition	BIGINT,
		@strCondition	NVARCHAR(200),
		@idfsRegion	BIGINT,
		@strRegionName	NVARCHAR(300),
		@idfsRayon	BIGINT,
		@strRayonName	NVARCHAR(300),
		@blnAccessioned	INT,
		@RecordAction	VARCHAR(1),
		@idfsSampleKind	BIGINT,
		@SampleKindTypeName	NVARCHAR(2000),
		@idfsSampleStatus	BIGINT,
		@SampleStatusTypeName	NVARCHAR(2000),
		@idfFieldCollectedByPerson	BIGINT,
		@datSampleStatusDate	DATETIME2,
		@sampleGuid	UNIQUEIDENTIFIER,
		@intRowStatus	INT,	
		@idfsSite       INT = 1,
		@RowAction NVARCHAR(1),
		@idfMaterialTemp BIGINT;
	DECLARE @returnCode	INT = 0;
	DECLARE	@returnMsg	NVARCHAR(MAX) = 'SUCCESS';



	--SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage', @idfHumanCase 'idfHumanCase';
		 	--Check if there are no samples associated to report.  If not Update the Samples Collected Flag to No / False
			
	



	DECLARE  @SamplesTemp TABLE (				
					[idfHumanCase] [bigint],
					[idfMaterial] [bigint],
					[strBarcode] [nvarchar](200),
					[strFieldBarcode] [nvarchar](200),
					[blnNumberingSchema] [INT],
					[idfsSampleType] [bigint],
					[strSampleTypeName] [nvarchar](2000),
					[datFieldCollectionDate] [datetime2],
					[idfSendToOffice] [bigint],
					[strSendToOffice] [nvarchar](2000),
					[idfFieldCollectedByOffice] [bigint],
					[strFieldCollectedByOffice] [nvarchar](2000),
					[datFieldSentDate] [datetime2],
					[strNote] [nvarchar](500),
					[datAccession] [datetime2],
					[idfsAccessionCondition] [bigint],
					[strCondition] [nvarchar](200),
					[idfsRegion] [bigint],
					[strRegionName] [nvarchar](300),
					[idfsRayon] [bigint],
					[strRayonName] [nvarchar](300),
					[blnAccessioned] [int],
					[RecordAction] [varchar](1),
					[idfsSampleKind] [bigint],
					[SampleKindTypeName] [nvarchar](2000),
					[idfsSampleStatus] [bigint],
					[SampleStatusTypeName] [nvarchar](2000),
					[idfFieldCollectedByPerson] [bigint],
					[datSampleStatusDate] [datetime2],
					[sampleGuid] [uniqueidentifier],
					[intRowStatus] [int],
					RowAction [nvarchar](1),
					[idfsSite] [bigint]
			)


	INSERT INTO	@SamplesTemp 
	SELECT * FROM OPENJSON(@SamplesParameters) 
			WITH (
					[idfHumanCase] [bigint],
					[idfMaterial] [bigint],
					[strBarcode] [nvarchar](200),
					[strFieldBarcode] [nvarchar](200),
					[blnNumberingSchema] [INT],
					[idfsSampleType] [bigint],
					[strSampleTypeName] [nvarchar](2000),
					[datFieldCollectionDate] [datetime2],
					[idfSendToOffice] [bigint],
					[strSendToOffice] [nvarchar](2000),
					[idfFieldCollectedByOffice] [bigint],
					[strFieldCollectedByOffice] [nvarchar](2000),
					[datFieldSentDate] [datetime2],
					[strNote] [nvarchar](500),
					[datAccession] [datetime2],
					[idfsAccessionCondition] [bigint],
					[strCondition] [nvarchar](200),
					[idfsRegion] [bigint],
					[strRegionName] [nvarchar](300),
					[idfsRayon] [bigint],
					[strRayonName] [nvarchar](300),
					[blnAccessioned] [int],
					[RecordAction] [varchar](1),
					[idfsSampleKind] [bigint],
					[SampleKindTypeName] [nvarchar](2000),
					[idfsSampleStatus] [bigint],
					[SampleStatusTypeName] [nvarchar](2000),
					[idfFieldCollectedByPerson] [bigint],
					[datSampleStatusDate] [datetime2],
					[sampleGuid] [uniqueidentifier],
					[intRowStatus] [int],
					[RowAction] [nvarchar](1),
					[idfsSite] [bigint]
				);


	--Test Add

	DECLARE
		--@idfHumanCase	bigint,
		--@idfMaterial BIGINT,
		--@strBarcode NVARCHAR(200),
		--@strFieldBarcode NVARCHAR(200),
		--@idfsSampleType BIGINT,
		--@strSampleTypeName NVARCHAR(2000),
		--@datFieldCollectionDate DATETIME2,
		--@idfSendToOffice BIGINT,
		--@strSendToOffice NVARCHAR(2000),
		--@idfFieldCollectedByOffice BIGINT,
		--@strFieldCollectedByOffice NVARCHAR(2000),
		--@datFieldSentDate DATETIME2,
		--@idfsSampleKind BIGINT,
		--@sampleKindTypeName NVARCHAR(2000),
		--@idfsSampleStatus BIGINT,
		--@sampleStatusTypeName NVARCHAR(2000),
		--@idfFieldCollectedByPerson BIGINT,
		--@datSampleStatusDate DATETIME2,
		--@sampleGuid UNIQUEIDENTIFIER,
		@idfTesting BIGINT,
		@idfTestingNew BIGINT,
		@idfsTestName BIGINT,
		@idfsTestCategory BIGINT,
		@idfsTestResult BIGINT,
		@idfsTestStatus BIGINT,
		@idfsDiagnosis BIGINT,
		@strTestStatus NVARCHAR(2000),
		@name NVARCHAR(2000),
		@datReceivedDate DATETIME2,
		@datConcludedDate DATETIME2,
		@idfTestedByPerson BIGINT,
		@idfTestedByOffice BIGINT,
		@idfValidatedByOffice BIGINT,
		@idfValidatedByPerson BIGINT,
		@idfInterpretedByOffice BIGINT,
		@idfInterpretedByPerson BIGINT,
		@blnCaseCreated BIT,
		@idfsInterpretedStatus BIGINT,
		@strInterpretedComment NVARCHAR(2000),
		@datInterpretedDate DATETIME2,
		@strInterpretedBy NVARCHAR(2000),
		@blnValidateStatus BIT,
		@strValidateComment NVARCHAR(2000),
		@datValidationDate DATETIME2,
		@strValidatedBy NVARCHAR(2000),
		@strAccountName NVARCHAR(2000),
		@testGuid UNIQUEIDENTIFIER,
		--@intRowStatus INT,
		@idfTestValidation BIGINT = NULL
		--@RowAction NVARCHAR(1)
	--DECLARE @returnCode INT = 0;
	DECLARE @idfTestValidationTemp BIGINT = NULL
	DECLARE @idfPersonTemp BIGINT = NULL
	--DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';
	DECLARE @TestsTemp AS TABLE (
           [idfHumanCase] [BIGINT],
            [idfMaterial] [bigint],
            [strBarcode] [nvarchar](200),
            [strFieldBarcode] [nvarchar](200),
            [idfsSampleType] [bigint],
            [strSampleTypeName] [nvarchar](2000),
            [datFieldCollectionDate] [datetime2],
            [idfSendToOffice] [bigint],
            [strSendToOffice] [nvarchar](2000),
            [idfFieldCollectedByOffice] [bigint],
            [strFieldCollectedByOffice] [nvarchar](2000),
            [datFieldSentDate] [datetime2],
            [idfsSampleKind] [bigint],
            [SampleKindTypeName] [nvarchar](2000),
            [idfsSampleStatus] [bigint],
            [SampleStatusTypeName] [nvarchar](2000),
            [idfFieldCollectedByPerson] [bigint],
            [datSampleStatusDate] [datetime2],
--            [sampleGuid] [uniqueidentifier],
            [idfTesting] [bigint],
            [idfsTestName] [bigint],
            [idfsTestCategory] [bigint],
			[strTestCategory] NVARCHAR(2000),
            [idfsTestResult] [bigint],
            [idfsTestStatus] [bigint],
            [idfsDiagnosis] [bigint],
			[strDiagnosis] NVARCHAR(2000),
            [strTestStatus] [nvarchar](2000),
			[strTestResult] NVARCHAR(2000),
            [name] [nvarchar](2000),
            [datReceivedDate] [datetime2],
            [datConcludedDate] [datetime2],
            [idfTestedByPerson] [bigint],
            [idfTestedByOffice] [bigint],
            [datInterpretedDate] [datetime2],
            [idfsInterpretedStatus] [bigint],
            [strInterpretedComment] [nvarchar](2000),
            [strInterpretedBy] [nvarchar](2000),
            [strInterpretedStatus] [nvarchar](2000),
            [datValidationDate] [datetime2],
            [blnValidateStatus] [bit],
            [strValidateComment] [nvarchar](2000),
            [strValidatedBy] [nvarchar](2000),
            [strAccountName] [nvarchar](2000),
--			[testGuid] NVARCHAR(MAX),
            [intRowStatus] [int],
			[strTestedByPerson] NVARCHAR(2000),
			[strTestedByOffice] NVARCHAR(2000),
			[blnNonLaboratoryTest] BIT,
            [idfValidatedByPerson] [bigint],
            [idfInterpretedByPerson] [BIGINT],
            [filterTestByDisease] BIT,
			[idfsYNTestsConducted] BIGINT,
			[RowAction] [nvarchar](1)
		)

	INSERT INTO @TestsTemp
	SELECT *
	FROM OPENJSON(@TestsParameters) WITH (
           [idfHumanCase] [BIGINT],
            [idfMaterial] [bigint],
            [strBarcode] [nvarchar](200),
            [strFieldBarcode] [nvarchar](200),
            [idfsSampleType] [bigint],
            [strSampleTypeName] [nvarchar](2000),
            [datFieldCollectionDate] [datetime2],
            [idfSendToOffice] [bigint],
            [strSendToOffice] [nvarchar](2000),
            [idfFieldCollectedByOffice] [bigint],
            [strFieldCollectedByOffice] [nvarchar](2000),
            [datFieldSentDate] [datetime2],
            [idfsSampleKind] [bigint],
            [SampleKindTypeName] [nvarchar](2000),
            [idfsSampleStatus] [bigint],
            [SampleStatusTypeName] [nvarchar](2000),
            [idfFieldCollectedByPerson] [bigint],
            [datSampleStatusDate] [datetime2],
--            [sampleGuid] [uniqueidentifier],
            [idfTesting] [bigint],
            [idfsTestName] [bigint],
            [idfsTestCategory] [bigint],
			[strTestCategory] NVARCHAR(2000),
            [idfsTestResult] [bigint],
            [idfsTestStatus] [bigint],
            [idfsDiagnosis] [bigint],
			[strDiagnosis] NVARCHAR(2000),
            [strTestStatus] [nvarchar](2000),
			[strTestResult] NVARCHAR(2000),
            [name] [nvarchar](2000),
            [datReceivedDate] [datetime2],
            [datConcludedDate] [datetime2],
            [idfTestedByPerson] [bigint],
            [idfTestedByOffice] [bigint],
            [datInterpretedDate] [datetime2],
            [idfsInterpretedStatus] [bigint],
            [strInterpretedComment] [nvarchar](2000),
            [strInterpretedBy] [nvarchar](2000),
            [strInterpretedStatus] [nvarchar](2000),
            [datValidationDate] [datetime2],
            [blnValidateStatus] [bit],
            [strValidateComment] [nvarchar](2000),
            [strValidatedBy] [nvarchar](2000),
            [strAccountName] [nvarchar](2000),
--			[testGuid] NVARCHAR(MAX),
			[intRowStatus] [int],
			[strTestedByPerson] NVARCHAR(2000),
			[strTestedByOffice] NVARCHAR(2000),
			[blnNonLaboratoryTest] BIT,
            [idfValidatedByPerson] [bigint],
            [idfInterpretedByPerson] [BIGINT],
            [filterTestByDisease] BIT,
			[idfsYNTestsConducted] BIGINT,
			[RowAction] [nvarchar](1)
			)

	BEGIN TRY  
		WHILE EXISTS (SELECT * FROM @SamplesTemp)
			BEGIN
				SELECT TOP 1
					--@idfHumanCase	=idfHumanCase,
					@idfMaterial	=idfMaterial,
					@strBarcode	=strBarcode,
					@strFieldBarcode	=strFieldBarcode,
					@blnNumberingSchema = blnNumberingSchema,
					@idfsSampleType	=idfsSampleType,
					--@strSampleTypeName	=strSampleTypeName
					@datFieldCollectionDate	=datFieldCollectionDate,
					@idfSendToOffice	=idfSendToOffice,
					--@strSendToOffice	=strSendToOffice,
					@idfFieldCollectedByOffice	=idfFieldCollectedByOffice,
					--@strFieldCollectedByOffice	=strFieldCollectedByOffice,
					@datFieldSentDate	=datFieldSentDate,
					@strNote	=strNote,
					@datAccession	=datAccession,
					@idfsAccessionCondition	=idfsAccessionCondition,
					@strCondition	=strCondition,					
					@idfsSampleKind	=idfsSampleKind,
					--@SampleKindTypeName	=SampleKindTypeName,
					@idfsSampleStatus	=idfsSampleStatus,
					--@SampleStatusTypeName	=SampleStatusTypeName,
					@idfFieldCollectedByPerson	=idfFieldCollectedByPerson,
					--@datSampleStatusDate	=datSampleStatusDate,
					@sampleGuid	= sampleGuid,
					@intRowStatus	=intRowStatus,
					@RowAction = RowAction,
					@idfsSite = idfsSite
				FROM @SamplesTemp

  --      If @idfSendToOffice > 0 
		--BEGIN
  --       set @idfsSite = (select idfsSite from [dbo].[tlbOffice] where idfoffice = @idfSendToOffice)

		-- IF @idfsSite IS NULL 
		-- BEGIN
		--	SET @idfsSite = 1
		-- END

		--END		

		IF NOT EXISTS(SELECT * FROM tlbMaterial WHERE @idfMaterial = idfMaterial AND intRowStatus = 0)
		BEGIN

				SET @idfMaterialTemp = @idfMaterial
				INSERT INTO @SupressSelect
				EXEC				
						dbo.USP_GBL_NEXTKEYID_GET 'tlbMaterial', @idfMaterial OUTPUT;

						--UPDATE @TestsTemp
						--SET idfMaterial = @idfMaterial
						--WHERE idfMaterial = @idfMaterialTemp

						UPDATE @TestsTemp
						SET idfMaterial = @idfMaterial
						WHERE strFieldBarcode = @strFieldBarcode
				
				--Local/field sample ID.  Only system assign when user leaves blank.
				IF	(LEFT(@strFieldBarcode,4) = 'NEW-' AND @blnNumberingSchema = 1) 
					BEGIN
						INSERT INTO @SupressSelect
						EXEC dbo.USP_GBL_NextNumber_GET 'Sample Field Barcode', @strFieldBarCode OUTPUT , NULL --N'AS Session'
					END 
				ELSE IF (LEFT(@strFieldBarcode,4) = 'NEW-' AND @blnNumberingSchema = 2)
					BEGIN
						IF @strHumanCaseID IS NOT NULL 
						BEGIN
							DECLARE @maxID INT, @oldStrFieldBarCode NVARCHAR(100)

							IF @oldStrFieldBarCode IS NOT NULL 
							BEGIN
								SET @strFieldBarcode = @oldStrFieldBarCode
								SET @maxID = MAX(RIGHT(@strFieldBarcode,CHARINDEX('-', (REVERSE(@strFieldBarcode))) - 1))+1
							END

							IF @maxID IS NULL 
								BEGIN
									SET @strFieldBarcode = @strHumanCaseID + '-01'
								END
							ELSE
								BEGIN
									SET @strFieldBarcode = @strHumanCaseID + '-0'+ CONVERT(NVARCHAR(2),@maxID)
								END

							SET @oldStrFieldBarCode = @strFieldBarcode

						END
					END

				INSERT INTO		dbo.tlbMaterial
				(						
					idfHumanCase,
					idfMaterial,
					strBarcode,
					strFieldBarcode,
					idfsSampleType,
					idfParentMaterial,
					idfRootMaterial,
					idfHuman,
					datEnteringDate,
					idfsSite,
					DiseaseID,
					--strSampleTypeName,
					datFieldCollectionDate,
					idfSendToOffice,
					--strSendToOffice,
					idfFieldCollectedByOffice,
					--strFieldCollectedByOffice,
					datFieldSentDate,
					strNote,

					datAccession,
					idfsAccessionCondition,
					strCondition,					
					idfsSampleKind,
					--SampleKindTypeName,
					idfsSampleStatus,
					--SampleStatusTypeName,
					idfFieldCollectedByPerson,
					--datSampleStatusDate,
					intRowStatus,
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateUser,
					rowguid
				)
				VALUES
				(					
					@idfHumanCase,
					@idfMaterial,
					NULL,
					@strFieldBarcode,
					@idfsSampleType,
					NULL,
					@idfMaterial,
					@idfHuman,
					GETDATE(),
					@idfsSite,
					@DiseaseID,
					--strSampleTypeName,
					@datFieldCollectionDate,
					@idfSendToOffice,
					--strSendToOffice,
					@idfFieldCollectedByOffice,
					--@strFieldCollectedByOffice,
					@datFieldSentDate,
					@strNote,
					@datAccession,
					@idfsAccessionCondition,
					@strCondition,
					@idfsSampleKind,
					--SampleKindTypeName,
					@idfsSampleStatus,
					--SampleStatusTypeName,
					@idfFieldCollectedByPerson,
					--datSampleStatusDate,
					@intRowStatus,
					10519001,
					'[{"idfMaterial":' + CAST(@idfMaterial AS NVARCHAR(300)) + '}]',
					@AuditUser,
					NEWID()
				)
				--Add Test


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



				UPDATE dbo.tlbMaterial
				SET 
					idfHumanCase=	@idfHumanCase,
					strBarcode=	@strBarcode,
					strFieldBarcode=	@strFieldBarcode,
					idfsSampleType=	@idfsSampleType,
					idfsSite = @idfsSite,
					DiseaseID = @DiseaseID,
					--strSampleTypeName=	@strSampleTypeName,
					datFieldCollectionDate=	@datFieldCollectionDate,
					idfSendToOffice=	@idfSendToOffice,
					--strSendToOffice=	@strSendToOffice,
					idfFieldCollectedByOffice=	@idfFieldCollectedByOffice,
					--strFieldCollectedByOffice=	@strFieldCollectedByOffice,
					datFieldSentDate=	@datFieldSentDate,
					strNote=	@strNote,
					datAccession=	@datAccession,
					idfsAccessionCondition=	@idfsAccessionCondition,
					strCondition=	@strCondition,
					idfsSampleKind=	@idfsSampleKind,
					--SampleKindTypeName=	@SampleKindTypeName,
					idfsSampleStatus=	@idfsSampleStatus,
					--SampleStatusTypeName=	@SampleStatusTypeName,
					idfFieldCollectedByPerson=	@idfFieldCollectedByPerson,
					--datSampleStatusDate=	@datSampleStatusDate,
					rowGuid=	@sampleGuid,
					intRowStatus=	@intRowStatus,
					AuditUpdateUser = @AuditUser


				WHERE	idfMaterial = @idfMaterial;
			END
			
			SET @TestsParameters =
			(
			SELECT 
				--@idfHumanCase=	idfHumanCase,
				idfMaterial,
				strBarcode,
				strFieldBarcode,				
				idfTesting,
				idfsTestName,
				idfsTestCategory,
				idfsTestResult,
				idfsTestStatus,
				idfsDiagnosis,				
				--idfValidatedByOffice,
				idfValidatedByPerson,
				--NULL,
				idfInterpretedByPerson,
				--NULL,
				datReceivedDate,
				--NULL,
				idfTestedByPerson,
				idfTestedByOffice,
				idfsInterpretedStatus,
				strInterpretedComment,
				datInterpretedDate,
				strInterpretedBy,
				blnValidateStatus,
				strValidateComment,
				datValidationDate,
				strValidatedBy,
				strAccountName,
				intRowStatus,
				RowAction
			FROM @TestsTemp
			FOR JSON PATH)

			IF @TestsParameters IS NOT NULL
				EXEC USSP_HUMAN_DISEASE_TESTS_SET @idfHumanCase,@TestsParameters,@AuditUser;
		
			SET ROWCOUNT 1
					DELETE TOP(1) FROM @SamplesTemp
					--SET ROWCOUNT 0
			END		--end loop, WHILE EXISTS (SELECT * FROM @SamplesTemp)
			

			
	END TRY
	BEGIN CATCH
		THROW;
		
	END CATCH
END
