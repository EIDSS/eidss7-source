--**************************************************************************************************************************
-- Name 				: USSP_OMM_HUMAN_TESTS_SET
-- Description			: add update delete Human Case Tests
--          
-- Author               : RDA
-- Revision History
--	Name			 Date		 Change Detail
--	--------------	 ----------	 --------------------------------
--	Doug Albanese	 07/09/2019	 Created
--	Doug Albanese	 04/27/2022	 Refactored to include relative fields only
--  Doug Albanese	 10/04/2022	 Corrected the usage of RowAction to using the numbering system
-- Doug Albanese	 10/24/2022	 Added the idfHumanCase field so that "USP_HUM_Test_GetList" could operate for both Human Disease Report and Labratory
--**************************************************************************************************************************
CREATE PROCEDURE [dbo].[USSP_OMM_HUMAN_TESTS_SET]
	@idfsDiagnosis				BIGINT,
	@idfHumanActual				BIGINT,
	@idfHumanCase				BIGINT,
	@TestsParameters			NVARCHAR(MAX) = NULL,
	@User						NVARCHAR(100) = NULL
AS
Begin
	SET NOCOUNT ON;

	DECLARE
		
		@idfHuman				BIGINT = NULL,
		@TestID					BIGINT = NULL,			--(Test Identity), tlbTesting: TestID
		@idfTestValidation		BIGINT = NULL,
		@SampleID				BIGINT = NULL,			--(Sample Identity), tlbMaterial: SampleID			
		@strFieldBarcode		NVARCHAR(200) = NULL,	--"Field Sample ID", tlbMaterial: strFieldBarcode
		@strBarcode				NVARCHAR(200) = NULL,	--"Lab Sample ID", tlbMaterial: strBarCode
		@TestNameTypeID			BIGINT = NULL,			--"Test Name", tlbTesting: TestNameTypeID
		@TestResultTypeID		BIGINT = NULL,			--"Test Result", tlbTesting: TestResultTypeID
		@TestStatusTypeID		BIGINT = NULL,			--"Test Status", tlbTesting: TestStatusTypeID
		@TestCategoryTypeID		BIGINT = NULL,			--"Test Category", tlbTesting: TestNameTypeID
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
				TestID					BIGINT NULL,
				SampleID				BIGINT NULL,
				strFieldBarcode			NVARCHAR(200) NULL,
				strBarcode				NVARCHAR(200) NULL,
				TestNameTypeID			BIGINT NULL,
				TestResultTypeID		BIGINT NULL,
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
				TestID					BIGINT,
				SampleID				BIGINT,
				strFieldBarcode			NVARCHAR(200),
				strBarcode				NVARCHAR(200),
				TestNameTypeID			BIGINT,
				TestResultTypeID		BIGINT,
				TestStatusTypeID		BIGINT,
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


	BEGIN TRY  
	  
		WHILE EXISTS (SELECT * FROM @TestsTemp)
			BEGIN
				SELECT TOP 1
					@TestID = TestID,
					@SampleID = SampleID,
					@strFieldBarcode = strFieldBarcode,
					@strBarcode = strBarcode,
					@TestNameTypeID = TestNameTypeID,
					@TestResultTypeID = TestResultTypeID,
					@TestStatusTypeID = TestStatusTypeID,
					@TestCategoryTypeID = TestCategoryTypeID,
					@idfsInterpretedStatus = idfsInterpretedStatus,
					@strInterpretedComment = strInterpretedComment,
					@datInterpretationDate = datInterpretationDate,
					@idfInterpretedByPerson = idfInterpretedByPerson,
					@blnValidateStatus = blnValidateStatus,
					@strValidateComment = strValidateComment,
					@datValidationDate = datValidationDate,
					@idfValidatedByPerson = idfValidatedByPerson,
					@RowAction = RowAction			
				FROM @TestsTemp
				
				--Because of different App-Side usage, the following will force the upcoming record existence test to abide by the negative number test
				IF @RowAction = 1 --INSERT
				  BEGIN
					 SET @TestID = -1
				  END

				IF NOT EXISTS(SELECT TOP 1 idfTesting FROM tlbTesting WHERE idfTesting = @TestID)
					BEGIN
						
						--New records will require information from the tlbMaterial table.
						--We use strFieldBarCode of this "Test" batch, to obtain the id of the previously added Samples (SampleID)
						if (@SampleID IS NULL)
							BEGIN
								SELECT 
									TOP 1
									@SampleID = idfMaterial
								FROM
									tlbMaterial
								WHERE
									strFieldBarcode = @strFieldBarcode
								ORDER BY idfMaterial desc
							END

						EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbTesting', @TestID OUTPUT;
						
						INSERT INTO tlbTesting (
							idfTesting,
							idfsTestName,
							idfsTestCategory,
							idfsTestResult,
							idfsTestStatus,
							idfsDiagnosis,
							idfHumanCase,
							idfMaterial,
							intRowStatus,
							rowguid,
							AuditCreateDTM,
							AuditCreateUser
							)
						VALUES (
							@TestID,
							@TestNameTypeID,
							@TestCategoryTypeID,
							@TestResultTypeID,
							@TestStatusTypeID,
							@idfsDiagnosis,
							@idfHumanCase,
							@SampleID,
							0,
							NewID(),
							GETDATE(),
							@User
						)

						EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbTestValidation', @idfTestValidation OUTPUT;

						INSERT INTO tlbTestValidation (
							idfTestValidation,
							idfTesting,
							idfsDiagnosis,
							idfsInterpretedStatus,
							strInterpretedComment,
							datInterpretationDate,
							idfInterpretedByPerson,
							blnValidateStatus,
							strValidateComment,
							datValidationDate,
							idfValidatedByPerson,
							intRowStatus,
							rowguid,
							AuditCreateDTM,
							AuditCreateUser
						)
						VALUES(
							@idfTestValidation,
							@TestID,
							@idfsDiagnosis,
							@idfsInterpretedStatus,
							@strInterpretedComment,
							@datInterpretationDate,
							@idfInterpretedByPerson,
							@blnValidateStatus,
							@strValidateComment,
							@datValidationDate,
							@idfValidatedByPerson,
							0,
							NewID(),
							GETDATE(),
							@User
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

						UPDATE dbo.tlbTesting
						SET 
							idfsTestName = @TestNameTypeID,
							idfsTestCategory = @TestCategoryTypeID,
							idfsTestResult = @TestResultTypeID,
							idfsTestStatus = @TestStatusTypeID,
							idfsDiagnosis = @idfsDiagnosis,
							idfMaterial = @SampleID,
							intRowStatus = @intRowStatus,
							AuditUpdateDTM = GETDATE(),
							AuditUpdateUser = @User
						WHERE	
							idfTesting = @TestID

						UPDATE tlbTestValidation
						SET
							idfsInterpretedStatus = @idfsInterpretedStatus,
							strInterpretedComment = @strInterpretedComment,
							datInterpretationDate = @datInterpretationDate,
							idfInterpretedByPerson = @idfInterpretedByPerson,
							blnValidateStatus = @blnValidateStatus,
							strValidateComment = @strValidateComment,
							datValidationDate = @datValidationDate,
							idfValidatedByPerson = @idfValidatedByPerson,
							AuditUpdateDTM = GETDATE(),
							AuditUpdateUser = @User
						WHERE
							idfTestValidation = @idfTestValidation

					END
				
					SET ROWCOUNT 1						
					DELETE FROM @TestsTemp
					SET ROWCOUNT 0
			END	

	END TRY
	BEGIN CATCH
		THROW;
		
	END CATCH
END
