--*************************************************************
-- Name 				: USSP_HUMAN_DISEASE_SAMPLES_SET
-- Description			: add update delete Human Disease Report Samples
--          
-- Author               : JWJ
-- Revision History
--		Name		Date       Change Detail
-- ---------------- ---------- --------------------------------
-- JWJ				20180703		created 
-- HAP              20181112     Updated to only execute dbo.USP_GBL_NextNumber_GET 10057019 when user leaves strFieldBarCode blank.
-- HAP				20181206	 Removed updating Primary Key column for tlbMaterial update.
-- HAP              20181221     Changed @Samples parameter to NVARCHAR(MAX).
-- LJM				01/02/19	 Changed @idfHumanCase from Output parameter and Added to Select Statment.  Added Temp Table to Surpress output from internal Stored Procs
-- HAP              03/22/19     Added @idfHuman and @DiseaseID input parameters. Also updated to save idfHuman, idfRootMaterial, idfParentMaterial,strBarcode, idfsSite, DiseaseID, and datEnteringDate in tlbMaterial table 
--LJM				03/01/19	Modified added ROWAction to update Records for Soft Delete
--LJM				10-12-20	Updated SP to Accept ROWGUID for succesful Update And SoftDelete.  Modified Code update the temp table after iteration
--LJM				11/02/2020  Added Check for Samples Collected, and Unknown. Updated Materials Table based on values of idfsYNSpecimenCollected in tlbhumancase table
-- Stephen Long     02/16/2022 Added idfsSite to the table variable.
-- Testing code:
-- exec USSP_HUMAN_DISEASE_SAMPLES_SET null
--*************************************************************
CREATE PROCEDURE [dbo].[USSP_HUMAN_DISEASE_SAMPLES_SET] 
    @idfHuman  BIGINT = NULL,
	@idfHumanCase BIGINT = NULL,
	@strHumanCaseID NVARCHAR(100)='',
	@DiseaseID BIGINT = NULL,
	@SamplesParameters	NVARCHAR(MAX) = NULL,
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
		@RowAction NVARCHAR(1)
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
				INSERT INTO @SupressSelect
				EXEC				
						dbo.USP_GBL_NEXTKEYID_GET 'tlbMaterial', @idfMaterial OUTPUT;
				
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
			
		
			SET ROWCOUNT 1
					DELETE TOP(1) FROM @SamplesTemp
					--SET ROWCOUNT 0
			END		--end loop, WHILE EXISTS (SELECT * FROM @SamplesTemp)
			

			
	END TRY
	BEGIN CATCH
		THROW;
		
	END CATCH
END
