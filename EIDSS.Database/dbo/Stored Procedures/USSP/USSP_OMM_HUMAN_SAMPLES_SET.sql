--******************************************************************************************************************************
-- Name 				: USSP_OMM_HUMAN_SAMPLES_SET
-- Description			: add update delete Human Disease Report Samples
--          
-- Author               : JWJ
-- Revision History
--	Name			 Date		 Change Detail
--	--------------	 ----------	 -----------------------------------------------------------------------------------------------
--	Doug Albanese	 07/09/2019	 Created
--	Doug Albanese	 04/27/2022	 Refactored to include relative fields only
--	Doug Albanese	 10/04/2022	 Made corrections for RowAction to use the new numbering system
-- Doug Albanese	 10/25/2022	 Assignment of idfMaterialTemp was corrected to use SampleID
--******************************************************************************************************************************

CREATE PROCEDURE [dbo].[USSP_OMM_HUMAN_SAMPLES_SET]
	@idfHumanActual					BIGINT,
	@idfHumanCase					BIGINT,
	@SamplesParameters				NVARCHAR(MAX) = NULL,
	@TestsParameters				NVARCHAR(MAX) = NULL,
	@idfsFinalDiagnosis				BIGINT = NULL,
	@User							NVARCHAR(100) = NULL
AS
Begin
	SET NOCOUNT ON;
	
	DECLARE @idfMaterialTemp		BIGINT = NULL /*Temporary transfer when the insert occurs so that NEW tests are updated with the correct id*/

	/*This section is a copy from the USSP_OMM_HUMAN_TESTS_SET so that the idfMaterial, when created as a new ID, can be tied to the tests associated with it.*/
	DECLARE
		@idfHuman				BIGINT = NULL,
		@idfTesting				BIGINT = NULL,			--(Test Identity), tlbTesting: idfTesting
		@idfTestValidation		BIGINT = NULL,
		@idfMaterial			BIGINT = NULL,			--(Sample Identity), tlbMaterial: idfMaterial			
		@idfsSampleType			BIGINT = NULL,			--"Sample Type", tlbMaterial: idfsSampleType
		@strFieldBarcode		NVARCHAR(200) = NULL,	--"Field Sample ID", tlbMaterial: strFieldBarcode
		@strBarcode				NVARCHAR(200) = NULL,	--"Lab Sample ID", tlbMaterial: strBarCode
		@idfsTestName			BIGINT = NULL,			--"Test Name", tlbTesting: idfsTestName
		@idfsTestResult			BIGINT = NULL,			--"Test Result", tlbTesting: idfsTestResult
		@idfsTestStatus			BIGINT = NULL,			--"Test Status", tlbTesting: idfsTestStatus
		@datConcludedDate		DATETIME2 = NULL,		--"Test Name", tlbTesting: idfsTestName
		@idfsTestCategory		BIGINT = NULL,			--"Test Category", tlbTesting: idfsTestName
		@idfsInterpretedStatus	BIGINT = NULL,			--"Rule In / Rule Out", tlbTestValidation: idfsInterpretedStatus
		@strInterpretedComment	NVARCHAR(200) = NULL,	--"Comments", tlbTestValidation: strInterpretedComment
		@datInterpretationDate	DATETIME2 = NULL,		--"Date Interpreted", tlbTestValidation: datInterpretationDate
		@idfInterpretedByPerson	BIGINT = NULL,			--"Interpreted By", tlbTestValidation: idfInterpretedByPerson
		@blnValidateStatus		INT = NULL,				--"Validated (Y/N)", tlbTestValidation: blnValidateStatus
		@strValidateComment		NVARCHAR(200) = NULL,	--"Comments", tlbTestValidation: strValidateComment
		@datValidationDate		DATETIME2 = NULL,		--"Date Validated", tlbTestValidation: datValidationDate
		@idfValidatedByPerson	BIGINT = NULL,			--"Validated By", tlbTestValidation: idfValidatedByPerson
		@RowAction				INT = NULL,				--(Row Action), Designation for record manipulation... Delete, Read Only, Insert
		@intRowStatus			INT	= NULL				--(Row Status), Designation to indicate a deleted record (1 = Deleted, 0 = Active)

		SELECT
				TOP 1
				@idfHuman = idfHuman
		FROM
				tlbHuman
		WHERE
				idfHumanActual = @idfHumanActual
		ORDER BY 
				AuditCreateDTM DESC
		
		DECLARE  @TestsTemp TABLE (	
				TestID					BIGINT NULL, --
				SampleID				BIGINT NULL, --
				strFieldBarcode			NVARCHAR(200) NULL,
				strBarcode				NVARCHAR(200) NULL,
				TestNameTypeID			BIGINT NULL, --
				TestResultTypeID		BIGINT NULL, --
				TestStatusTypeID		BIGINT NULL,
				TestCategoryTypeID		BIGINT NULL,
				idfsInterpretedStatus	BIGINT NULL,
				strInterpretedComment	NVARCHAR(200) NULL,
				datInterpretationDate	DATETIME2 NULL,
				idfInterpretedByPerson	BIGINT NULL,
				blnValidateStatus		INT NULL,
				strValidateComment		NVARCHAR(200) NULL,
				datValidationDate		DATETIME2 NULL,
				idfValidatedByPerson	BIGINT NULL,
				RowAction				INT NULL
	)
	
	INSERT INTO	@TestsTemp 
	SELECT * FROM OPENJSON(@TestsParameters) 
			WITH (
				TestID					BIGINT, --
				SampleID				BIGINT, --
				strFieldBarcode			NVARCHAR(200),
				strBarcode				NVARCHAR(200),
				TestNameTypeID			BIGINT, --
				TestResultTypeID		BIGINT, --
				TestStatusTypeID		BIGINT, --
				TestCategoryTypeID		BIGINT,
				idfsInterpretedStatus	BIGINT,
				strInterpretedComment	NVARCHAR(200),
				datInterpretationDate	DATETIME2,
				idfInterpretedByPerson	BIGINT,
				blnValidateStatus		INT,
				strValidateComment		NVARCHAR(200),
				datValidationDate		DATETIME2,
				idfValidatedByPerson	BIGINT,
				RowAction				INT				
				);
   
	DECLARE
		@datFieldCollectionDate		DATETIME2 = NULL,
		@CollectedByOffice			NVARCHAR(200) = NULL,
		@idfFieldCollectedByOffice	BIGINT = NULL,
		@CollectedByPerson			NVARCHAR(200) = NULL,
		@idfFieldCollectedByPerson	BIGINT = NULL,
		@datFieldSentDate			DATETIME2 = NULL,
		@idfSendToOffice			BIGINT = NULL,
		@SentToOffice				NVARCHAR(200) = NULL,
		@strNote					NVARCHAR(500) = NULL
	
		SELECT
				TOP 1
				@idfHuman = idfHuman
		FROM
				tlbHuman
		WHERE
				idfHumanActual = @idfHumanActual
		ORDER BY 
				AuditCreateDTM DESC
		
	DECLARE  @SamplesTemp TABLE (	
			SampleID					BIGINT,
			SampleTypeID				BIGINT,
			EIDSSLocalOrFieldSampleID	NVARCHAR(200),
			CollectionDate				DATETIME2,
			CollectedByOrganizationID	BIGINT,
			CollectedByPersonID			BIGINT,
			SentDate					DATETIME2,
			SentToOrganizationID		BIGINT,
			Comments					NVARCHAR(500),
			RowStatus					INT,
			RowAction					INT			
	)
	
	INSERT INTO	@SamplesTemp 
	SELECT * FROM OPENJSON(@SamplesParameters) 
			WITH (
					SampleID					BIGINT,
					SampleTypeID				BIGINT,
					EIDSSLocalOrFieldSampleID	NVARCHAR(200),
					CollectionDate				DATETIME2,
					CollectedByOrganizationID	BIGINT,
					CollectedByPersonID			BIGINT,
					SentDate					DATETIME2,
					SentToOrganizationID		BIGINT,
					Comments					NVARCHAR(500),
					RowStatus					INT,
					RowAction					INT	
				);
	BEGIN TRY  
		WHILE EXISTS (SELECT * FROM @SamplesTemp)
			BEGIN
				SELECT TOP 1
					@idfMaterial = SampleID,
					@idfMaterialTemp = SampleID,
					@idfsSampleType = SampleTypeID,
					@strFieldBarcode = EIDSSLocalOrFieldSampleID,
					@datFieldCollectionDate = CollectionDate,
					@idfFieldCollectedByOffice = CollectedByOrganizationID,
					@idfFieldCollectedByPerson = CollectedByPersonID,
					@datFieldSentDate = SentDate,
					@idfSendToOffice = SentToOrganizationID,
					@strNote = Comments,
					@intRowStatus = RowStatus,
					@RowAction = RowAction					
				FROM @SamplesTemp

				--Because of different App-Side usage, the following will force the upcoming record existence test to abide by the negative number test
				IF @RowAction = 1 --INSERT
				  BEGIN
					 SET @idfMaterial = -1
				  END

				IF NOT EXISTS(SELECT TOP 1 idfMaterial FROM tlbMaterial WHERE idfMaterial = @idfMaterial)
					BEGIN
						EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbMaterial', @idfMaterial OUTPUT;

						/*Update any associated new Test with the  new Sample being inserted*/
						UPDATE @TestsTemp
						SET SampleID = @idfMaterial
						WHERE SampleID = @idfMaterialTemp

						INSERT INTO		dbo.tlbMaterial
						(						
							idfHumanCase,
							idfHuman,
							idfMaterial,
							idfsSampleType,
							strFieldBarcode,
							datFieldCollectionDate,
							idfFieldCollectedByOffice,
							idfFieldCollectedByPerson,
							datFieldSentDate,
							idfSendToOffice,
							strNote,
							intRowStatus,
							AuditCreateUser,
							AuditCreateDTM
						)
						VALUES
						(					
							@idfHumanCase,
							@idfHuman,
							@idfMaterial,
							@idfsSampleType,
							@strFieldBarcode,
							@datFieldCollectionDate,
							@idfFieldCollectedByOffice,
							@idfFieldCollectedByPerson,
							@datFieldSentDate,
							@idfSendToOffice,
							@strNote,
							@intRowStatus,
							@User,
							GETDATE()
						)
					END
				ELSE
					BEGIN
						IF @RowAction = 3 --DELETE
							BEGIN
								SET @intRowStatus = 1
							END
						ELSE
							BEGIN
								SET @intRowStatus = 0
							END

						UPDATE dbo.tlbMaterial
						SET 
							idfsSampleType = @idfsSampleType,
							strFieldBarcode = @strFieldBarcode,
							datFieldCollectionDate = @datFieldCollectionDate,
							idfFieldCollectedByOffice = @idfFieldCollectedByOffice,
							idfFieldCollectedByPerson = @idfFieldCollectedByPerson,
							datFieldSentDate = @datFieldSentDate,
							idfSendToOffice = @idfSendToOffice,
							strNote = @strNote,
							intRowStatus = @intRowStatus,
							AuditUpdateUser = @User,
							AuditUpdateDTM = GETDATE()
						WHERE	
							idfMaterial = @idfMaterial
					END
					
					SET ROWCOUNT 1						
					DELETE FROM @SamplesTemp
					SET ROWCOUNT 0
			END	

		SET @TestsParameters =
			(SELECT
				TestID,
				SampleID,
				strFieldBarcode,
				strBarcode,
				TestNameTypeID,
				TestResultTypeID,
				TestStatusTypeID,
				TestCategoryTypeID,
				idfsInterpretedStatus,
				strInterpretedComment,
				datInterpretationDate,
				idfInterpretedByPerson,
				blnValidateStatus,
				strValidateComment,
				datValidationDate,
				idfValidatedByPerson,
				RowAction
			FROM
				@TestsTemp
			FOR JSON PATH)

		If @TestsParameters IS NOT NULL
			EXEC USSP_OMM_HUMAN_TESTS_SET @idfsFinalDiagnosis, @idfHumanActual, @idfHumanCase,@TestsParameters, @User = @User;

	END TRY
	BEGIN CATCH
		THROW;
		
	END CATCH
END
