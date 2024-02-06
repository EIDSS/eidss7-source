--*************************************************************
-- Name 				: USP_VCTS_DetailedCollections_Copy
-- Description			: Create replicas of the given idfVector ids
--          
-- Author               : Doug Albanese
-- Revision History
--	Name			Date			Change Detail
--	Doug Albanese	01/21/2020		Initial Creation
--	Doug Albanese	11/5/2020		Re-worked to get the copy to associate samples and tests for the new vector.
--	Doug Albanese	 10/20/2022		Create parameters to denote which parts of a vector, needs to be copyied.
--									Also changed the SP name to conform to standards
--	Mike Kornegay	01/26/2023		Correct return type to match APIPostReturn\
--	Mike Kornegay	02/03/2023		Changed fields that should be null upon copy. (Field Sample Id, Test Result, etc.)
--									and correct query to pull field tests.
--  Mike Kornegay	02/09/2023		Added DiseaseID to tlbMaterial.
--
--*************************************************************

CREATE PROCEDURE [dbo].[USP_VCTS_DetailedCollections_Copy]
(
    @idfVector							  BIGINT,
	@VectorData							  BIT = 0,
	@Samples							  BIT = 0,
	@Tests								  BIT = 0
)

AS 

BEGIN
	DECLARE @returnCode						INT = 0
	DECLARE	@returnMsg						NVARCHAR(max) = 'SUCCESS' 
	DECLARE @idfVectorNew					BIGINT

	DECLARE @SupressSelect TABLE
	( retrunCode INT,
		returnMsg NVARCHAR(200)
	)

	DECLARE @idfMaterials TABLE (
		idfMaterial BIGINT
	);

	DECLARE @idfTestings TABLE (
		idfTesting BIGINT,
		idfMaterial BIGINT
	);

	IF @Samples = 1
	  BEGIN
		 INSERT INTO @idfMaterials
			SELECT
			   DISTINCT idfMaterial
			FROM
			   tlbMaterial
			WHERE
			   idfVector = @idfVector
	  
		 IF @Tests = 1
			BEGIN
				INSERT INTO @idfTestings
				SELECT
					 DISTINCT t.idfTesting, t.idfMaterial
				  FROM			tlbTesting t
				  INNER JOIN	tlbMaterial m
				  ON			m.idfMaterial = t.idfMaterial
				  WHERE			m.idfVector = @idfVector

			END
	  END

	DECLARE @rowId							BIGINT
	DECLARE @idfMaterial					BIGINT
	DECLARE @idfMaterialNew					BIGINT
	DECLARE @idfVectorSurveillanceSession	BIGINT
	DECLARE @idfHostVector					BIGINT = NULL
	DECLARE @strVectorID					NVARCHAR(50)
	DECLARE @strFieldVectorID				NVARCHAR(50) = NULL
	DECLARE @idfLocation					BIGINT = NULL
	DECLARE @intElevation					BIGINT = NULL
	DECLARE @idfsSurrounding				BIGINT = NULL
	DECLARE @strGEOReferenceSources			NVARCHAR(500) = NULL
	DECLARE @idfCollectedByOffice			BIGINT
	DECLARE @idfCollectedByPerson			BIGINT = NULL
	DECLARE @datCollectionDateTime			DATETIME
	DECLARE @idfsCollectionMethod			BIGINT = NULL
	DECLARE @idfsBasisOfRecord				BIGINT = NULL
	DECLARE @idfsVectorType					BIGINT
	DECLARE @idfsVectorSubType				BIGINT
	DECLARE @intQuantity					INT
	DECLARE @idfsSex						BIGINT = NULL
	DECLARE @idfIdentIFiedByOffice			BIGINT = NULL
	DECLARE @idfIdentIFiedByPerson			BIGINT = NULL
	DECLARE @datIdentIFiedDateTime			DATETIME = NULL
	DECLARE @idfsIdentIFicationMethod		BIGINT = NULL
	DECLARE @idfObservation					BIGINT = NULL
	DECLARE @idfsDayPeriod					BIGINT = NULL
	DECLARE @strComment						NVARCHAR(500) = NULL
	DECLARE @idfsEctoparASitesCollected		BIGINT = NULL

	DECLARE @idfsSampleType 				BIGINT
	DECLARE @idfRootMaterial 				BIGINT = NULL
	DECLARE @idfParentMaterial 				BIGINT = NULL
	DECLARE @idfHuman 						BIGINT = NULL
	DECLARE @idfSpecies 					BIGINT = NULL
	DECLARE @idfAnimal 						BIGINT = NULL
	DECLARE @idfMonitoringSession 			BIGINT = NULL
	DECLARE @idfFieldCollectedByPerson 		BIGINT = NULL
	DECLARE @idfFieldCollectedByOffice 		BIGINT = NULL
	DECLARE @idfMainTest 					BIGINT = NULL
	DECLARE @datFieldCollectionDate 		DATETIME = NULL
	DECLARE @datFieldSentDate 				DATETIME = NULL
	DECLARE @strFieldBarcode 				NVARCHAR(200) = NULL
	DECLARE @strCalculatedCaseID 			NVARCHAR(200) = NULL
	DECLARE @strCalculatedHumanName 		NVARCHAR(700) = NULL
	DECLARE @idfSubdivision 				BIGINT = NULL	
	DECLARE @idfsSampleStatus 				BIGINT = NULL
	DECLARE @idfInDepartment 				BIGINT = NULL
	DECLARE @idfDestroyedByPerson 			BIGINT = NULL
	DECLARE @datEnteringDate 				DATETIME = NULL
	DECLARE @datDestructionDate 			DATETIME = NULL
	DECLARE @strBarcode 					NVARCHAR(200) = NULL
	DECLARE @strNote 						NVARCHAR(500) = NULL
	DECLARE @idfsSite 						BIGINT
	DECLARE @intRowStatus 					INT = 0
	DECLARE @idfSendToOffice 				BIGINT = NULL
	DECLARE @blnReadOnly 					BIT
	DECLARE @idfsBirdStatus 				BIGINT = NULL
	DECLARE @idfHumanCase 					BIGINT = NULL
	DECLARE @idfVetCase 					BIGINT = NULL
	DECLARE @datAccession 					DATETIME = NULL
	DECLARE @idfsAccessionCondition 		BIGINT = NULL
	DECLARE @strCondition 					NVARCHAR(200) = NULL
	DECLARE @idfAccesionByPerson 			BIGINT = NULL
	DECLARE @idfsDestructionMethod 			BIGINT = NULL
	DECLARE @idfsCurrentSite 				BIGINT = NULL
	DECLARE @idfsSampleKind 				BIGINT = NULL
	DECLARE @idfMarkedForDispositionByPerson BIGINT = NULL
	DECLARE @datOutOfRepositoryDate 		DATETIME = NULL
	DECLARE @strMaintenanceFlag 			NVARCHAR(20) = NULL

	DECLARE @idfTesting						BIGINT
	DECLARE @idfTestingNew					BIGINT
	DECLARE @idfsTestName					BIGINT = NULL
	DECLARE @idfsTestCategory				BIGINT = NULL
	DECLARE @idfsTestResult					BIGINT = NULL
	DECLARE @idfsTestStatus					BIGINT
	DECLARE @idfsDiagnosis					BIGINT
	DECLARE @idfBatchTest					BIGINT = NULL
	DECLARE @intTestNumber					INT = NULL
	DECLARE @datStartedDate					DATETIME = NULL
	DECLARE @datConcludedDate				DATETIME = NULL
	DECLARE @idfTestedByOffice				BIGINT = NULL
	DECLARE @idfTestedByPerson				BIGINT = NULL
	DECLARE @idfResultEnteredByOffice		BIGINT = NULL
	DECLARE @idfResultEnteredByPerson		BIGINT = NULL
	DECLARE @idfValidatedByOffice			BIGINT = NULL
	DECLARE @idfValidatedByPerson			BIGINT = NULL
	DECLARE @blnNonLaboratoryTest			BIT
	DECLARE @blnExternalTest				BIT = NULL
	DECLARE @idfPerformedByOffice			BIGINT = NULL
	DECLARE @datReceivedDate				DATETIME = NULL
	DECLARE @strContactPerson				NVARCHAR(200) = NULL

	BEGIN TRY
		 BEGIN
			   SELECT
					 @idfVectorSurveillanceSession = idfVectorSurveillanceSession, 
					 @idfHostVector = idfHostVector, 
					 @strFieldVectorID = strFieldVectorID, 
					 @idfLocation = idfLocation, 
					 @intElevation = intElevation, 
					 @idfsSurrounding = idfsSurrounding, 
					 @strGEOReferenceSources = strGEOReferenceSources, 
					 @idfCollectedByOffice = idfCollectedByOffice, 
					 @idfCollectedByPerson = idfCollectedByPerson, 
					 @datCollectionDateTime = datCollectionDateTime, 
					 @idfsCollectionMethod = idfsCollectionMethod, 
					 @idfsBASisOfRecord = idfsBASisOfRecord, 
					 @idfsVectorType = idfsVectorType, 
					 @idfsVectorSubType = idfsVectorSubType, 
					 @intQuantity = intQuantity, 
					 @idfsSex = idfsSex, 
					 @idfIdentIFiedByOffice = idfIdentIFiedByOffice, 
					 @idfIdentIFiedByPerson = idfIdentIFiedByPerson, 
					 @datIdentIFiedDateTime = datIdentIFiedDateTime, 
					 @idfsIdentIFicationMethod = idfsIdentIFicationMethod, 
					 @idfObservation = idfObservation,
					 @idfsDayPeriod = idfsDayPeriod,
					 @strComment = strComment,
					 @idfsEctoparASitesCollected = idfsEctoparASitesCollected
			   FROM
				  tlbVector
			   WHERE
					 idfVector = @idfVector

			   INSERT INTO @SupressSelect
			   EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbVector', @idfVectorNew OUTPUT

			   INSERT INTO @SupressSelect
			   EXEC dbo.USP_GBL_NextNumber_GET 'Vector Surveillance Vector', @strVectorID OUTPUT , NULL --N'AS Session'

			   INSERT INTO dbo.tlbVector
				  (
						idfVector, 
						idfVectorSurveillanceSession, 
						idfHostVector, 
						strVectorID, 
						strFieldVectorID, 
						idfLocation, 
						intElevation, 
						idfsSurrounding, 
						strGEOReferenceSources, 
						idfCollectedByOffice, 
						idfCollectedByPerson, 
						datCollectionDateTime, 
						idfsCollectionMethod, 
						idfsBasisOfRecord, 
						idfsVectorType, 
						idfsVectorSubType, 
						intQuantity, 
						idfsSex, 
						idfIdentIFiedByOffice, 
						idfIdentIFiedByPerson, 
						datIdentIFiedDateTime, 
						idfsIdentIFicationMethod, 
						idfObservation
						,idfsDayPeriod
						,strComment
						,idfsEctoparASitesCollected
				  )
			   VALUES
				  (
						@idfVectorNew, 
						@idfVectorSurveillanceSession, 
						@idfHostVector, 
						@strVectorID, 
						NULL, 
						@idfLocation, 
						@intElevation, 
						@idfsSurrounding, 
						@strGEOReferenceSources, 
						@idfCollectedByOffice, 
						@idfCollectedByPerson, 
						@datCollectionDateTime, 
						@idfsCollectionMethod, 
						@idfsBasisOfRecord, 
						@idfsVectorType, 
						@idfsVectorSubType, 
						@intQuantity, 
						@idfsSex, 
						@idfIdentifiedByOffice, 
						@idfIdentIFiedByPerson, 
						@datIdentIFiedDateTime, 
						@idfsIdentIFicationMethod, 
						@idfObservation,
						@idfsDayPeriod,
						@strComment,
						@idfsEctoparASitesCollected
			   )
		 END;
		
		 IF @Samples = 1
			BEGIN
			   WHILE EXISTS ( SELECT * FROM @idfMaterials )
				  BEGIN
					 SELECT
						TOP 1
						@rowId = idfMaterial
					 FROM 
						@idfMaterials

					 SELECT
						@idfsSampleType = idfsSampleType, 
						@idfRootMaterial = idfRootMaterial, 
						@idfParentMaterial = idfParentMaterial, 
						@idfsDiagnosis = DiseaseID,
						@idfHuman = idfHuman, 
						@idfSpecies = idfSpecies, 
						@idfAnimal = idfAnimal, 
						@idfMonitoringSession = idfMonitoringSession, 
						@idfFieldCollectedByPerson = idfFieldCollectedByPerson, 
						@idfFieldCollectedByOffice = idfFieldCollectedByOffice, 
						@idfMainTest = idfMainTest, 
						@datFieldCollectionDate = datFieldCollectionDate, 
						@datFieldSentDate = datFieldSentDate, 
						@strFieldBarcode = strFieldBarcode, 
						@strCalculatedCaseID = strCalculatedCaseID, 
						@strCalculatedHumanName = strCalculatedHumanName, 
						@idfVectorSurveillanceSession = idfVectorSurveillanceSession, 
						@idfVector = @idfVectorNew, 
						@idfSubdivision = idfSubdivision, 
						@idfsSampleStatus = idfsSampleStatus, 
						@idfInDepartment = idfInDepartment, 
						@idfDestroyedByPerson = idfDestroyedByPerson, 
						@datEnteringDate = datEnteringDate, 
						@datDestructionDate = datDestructionDate, 
						@strBarcode = strBarcode, 
						@strNote = strNote, 
						@idfsSite = idfsSite, 
						@intRowStatus = intRowStatus, 
						@idfSendToOffice = idfSendToOffice, 
						@blnReadOnly = blnReadOnly, 
						@idfsBirdStatus = idfsBirdStatus, 
						@idfHumanCase = idfHumanCase, 
						@idfVetCase = idfVetCase, 
						@datAccession = datAccession, 
						@idfsAccessionCondition = idfsAccessionCondition, 
						@strCondition = strCondition, 
						@idfAccesionByPerson = idfAccesionByPerson, 
						@idfsDestructionMethod = idfsDestructionMethod, 
						@idfsCurrentSite = idfsCurrentSite, 
						@idfsSampleKind = idfsSampleKind, 
						@idfMarkedForDispositionByPerson = idfMarkedForDispositionByPerson, 
						@datOutOfRepositoryDate = datOutOfRepositoryDate, 
						@strMaintenanceFlag = strMaintenanceFlag 
					 FROM
						tlbMaterial
					 WHERE
						idfMaterial = @rowId

					 INSERT INTO @SupressSelect
					 EXEC	dbo.USP_GBL_NEXTKEYID_GET 'tlbMaterial', @idfMaterialNew OUTPUT;

					 INSERT INTO @SupressSelect
					 EXEC	dbo.USP_GBL_NextNumber_GET 'Sample Field Barcode', @strBarcode OUTPUT, NULL 

					 --Update the temp table so that we will have the association between the new material and tests
					 UPDATE @idfTestings
					 SET idfMaterial = @idfMaterialNew
					 WHERE 
						idfMaterial = @rowid

					 INSERT INTO	dbo.tlbMaterial
						(						
								 idfMaterial, 
								 idfsSampleType, 
								 idfRootMaterial, 
								 idfParentMaterial, 
								 idfHuman, 
								 idfSpecies, 
								 idfAnimal, 
								 idfMonitoringSession, 
								 idfFieldCollectedByPerson, 
								 idfFieldCollectedByOffice, 
								 idfMainTest, 
								 datFieldCollectionDate, 
								 datFieldSentDate, 
								 strFieldBarcode, 
								 strCalculatedCaseID, 
								 strCalculatedHumanName, 
								 idfVectorSurveillanceSession, 
								 idfVector, 
								 idfSubdivision, 
								 idfsSampleStatus, 
								 idfInDepartment, 
								 idfDestroyedByPerson, 
								 datEnteringDate, 
								 datDestructionDate, 
								 strBarcode, 
								 strNote, 
								 idfsSite, 
								 intRowStatus, 
								 idfSendToOffice, 
								 blnReadOnly, 
								 idfsBirdStatus, 
								 idfHumanCase, 
								 idfVetCase, 
								 datAccession, 
								 idfsAccessionCondition, 
								 strCondition, 
								 idfAccesionByPerson, 
								 idfsDestructionMethod, 
								 idfsCurrentSite, 
								 idfsSampleKind, 
								 idfMarkedForDispositionByPerson, 
								 datOutOfRepositoryDate, 
								 strMaintenanceFlag,
								 DiseaseID
						)
						VALUES
						(
								 @idfMaterialNew, 
								 @idfsSampleType, 
								 @idfRootMaterial, 
								 @idfParentMaterial, 
								 @idfHuman, 
								 @idfSpecies, 
								 @idfAnimal, 
								 @idfMonitoringSession, 
								 @idfFieldCollectedByPerson, 
								 @idfFieldCollectedByOffice, 
								 @idfMainTest, 
								 @datFieldCollectionDate, 
								 @datFieldSentDate, 
								 NULL, 
								 @strCalculatedCaseID, 
								 @strCalculatedHumanName, 
								 @idfVectorSurveillanceSession, 
								 @idfVectorNew, 
								 @idfSubdivision, 
								 @idfsSampleStatus, 
								 @idfInDepartment, 
								 @idfDestroyedByPerson, 
								 @datEnteringDate, 
								 @datDestructionDate, 
								 @strBarcode, 
								 @strNote, 
								 @idfsSite, 
								 @intRowStatus, 
								 NULL, 
								 @blnReadOnly, 
								 @idfsBirdStatus, 
								 @idfHumanCase, 
								 @idfVetCase, 
								 @datAccession, 
								 @idfsAccessionCondition, 
								 @strCondition, 
								 @idfAccesionByPerson, 
								 @idfsDestructionMethod, 
								 @idfsCurrentSite, 
								 @idfsSampleKind, 
								 @idfMarkedForDispositionByPerson, 
								 @datOutOfRepositoryDate, 
								 @strMaintenanceFlag,
								 @idfsDiagnosis
						);
					
					 DELETE FROM @idfMaterials
					 WHERE idfMaterial = @rowId
				  END;
				  IF @Tests = 1
					 BEGIN
						WHILE EXISTS ( SELECT * FROM @idfTestings )
						   BEGIN
								 SELECT
									TOP 1
									@rowId = idfTesting
								 FROM 
									@idfTestings

								 SELECT
									@idfsTestName = idfsTestName, 
									@idfsTestCategory = idfsTestCategory, 
									@idfsTestResult = idfsTestResult, 
									@idfsTestStatus = idfsTestStatus, 
									@idfsDiagnosis = idfsDiagnosis, 
									@idfBatchTest = idfBatchTest, 
									@idfObservation = idfObservation, 
									@intTestNumber = intTestNumber, 
									@strNote = strNote, 
									@intRowStatus = intRowStatus, 
									@datStartedDate = datStartedDate, 
									@datConcludedDate = datConcludedDate, 
									@idfTestedByOffice = idfTestedByOffice, 
									@idfTestedByPerson = idfTestedByPerson, 
									@idfResultEnteredByOffice = idfResultEnteredByOffice, 
									@idfResultEnteredByPerson = idfResultEnteredByPerson, 
									@idfValidatedByOffice = idfValidatedByOffice, 
									@idfValidatedByPerson = idfValidatedByPerson, 
									@blnReadOnly = blnReadOnly, 
									@blnNonLaboratoryTest = blnNonLaboratoryTest, 
									@blnExternalTest = blnExternalTest, 
									@idfPerformedByOffice = idfPerformedByOffice, 
									@datReceivedDate = datReceivedDate, 
									@strContactPerson = strContactPerson, 
									@strMaintenanceFlag = strMaintenanceFlag
								 FROM
									tlbTesting
								 WHERE
									idfTesting = @rowId

								 INSERT INTO @SupressSelect
								 EXEC	dbo.USP_GBL_NEXTKEYID_GET 'tlbTesting', @idfTestingNew OUTPUT;

								 SELECT
									@idfMaterialNew = idfMaterial
								 FROM
									@idfTestings
								 WHERE
									idfTesting = @rowId

								 INSERT INTO	dbo.tlbTesting
								 (						
									   idfTesting, 
									   idfsTestName, 
									   idfsTestCategory, 
									   idfsTestResult, 
									   idfsTestStatus, 
									   idfsDiagnosis, 
									   idfMaterial, 
									   idfBatchTest, 
									   idfObservation, 
									   intTestNumber, 
									   strNote, 
									   intRowStatus, 
									   datStartedDate, 
									   datConcludedDate, 
									   idfTestedByOffice, 
									   idfTestedByPerson, 
									   idfResultEnteredByOffice, 
									   idfResultEnteredByPerson, 
									   idfValidatedByOffice, 
									   idfValidatedByPerson, 
									   blnReadOnly, 
									   blnNonLaboratoryTest, 
									   blnExternalTest, 
									   idfPerformedByOffice, 
									   datReceivedDate, 
									   strContactPerson, 
									   strMaintenanceFlag,
									   idfVector
								)
								 VALUES
								 (
									   @idfTestingNew, 
									   @idfsTestName, 
									   @idfsTestCategory, 
									   NULL, 
									   @idfsTestStatus, 
									   @idfsDiagnosis, 
									   @idfMaterialNew, 
									   @idfBatchTest, 
									   @idfObservation, 
									   @intTestNumber, 
									   @strNote, 
									   @intRowStatus, 
									   @datStartedDate, 
									   @datConcludedDate, 
									   @idfTestedByOffice, 
									   @idfTestedByPerson, 
									   @idfResultEnteredByOffice, 
									   @idfResultEnteredByPerson, 
									   @idfValidatedByOffice, 
									   @idfValidatedByPerson, 
									   @blnReadOnly, 
									   @blnNonLaboratoryTest, 
									   @blnExternalTest, 
									   @idfPerformedByOffice, 
									   @datReceivedDate, 
									   @strContactPerson, 
									   @strMaintenanceFlag,
									   @idfVectorNew
								 );
				
								 DELETE FROM @idfTestings
								 WHERE idfTesting = @rowId
						   END;
					 END
		 END
											
		IF @@TRANCOUNT > 0 AND @returnCode =0
			COMMIT
	END TRY

	BEGIN CATCH
			IF @@Trancount > 0
				ROLLBACK
				SET @returnCode = ERROR_NUMBER()
				SET @returnMsg = 
			   'ErrorNumber: ' + convert(varchar, ERROR_NUMBER() ) 
			   + ' ErrorSeverity: ' + convert(varchar, ERROR_SEVERITY() )
			   + ' ErrorState: ' + convert(varchar,ERROR_STATE())
			   + ' ErrorProcedure: ' + isnull(ERROR_PROCEDURE() ,'')
			   + ' ErrorLine: ' +  convert(varchar,isnull(ERROR_LINE() ,''))
			   + ' ErrorMessage: '+ ERROR_MESSAGE();
			   THROW;

	END CATCH

	SELECT 
		@returnCode AS ReturnCode
		,@returnMsg AS ReturnMessage

END
