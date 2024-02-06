

-- ================================================================================================
-- Name: USP_OMM_VETERINARY_DISEASE_SET
--
-- Description:	Inserts or updates veterinary "case" for the avian and livestock veterinary disease 
-- report use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Doug Albanese    04/24/2018 Initial release.
-- Stephen Long     06/25/2019 Added farm owner parameters for vet farm copy calls.
-- Stephen Long     12/23/2019 Added NULLS to account for farm latitude and longitude parameters on
--                             ussp vet farm copy.
-- Stephen Long     04/24/2020 Added NULL to USSP_VET_ANIMAL_SET for new parameter clinical signs 
--                             indicator.
-- Mark Wilson      10/06/2021 Added elevation (NULL) to USP_GBL_ADDRESS_SET.
-- Mark Wilson      10/20/2021 Added elevation (NULL) to USP_GBL_ADDRESS_SET. Also updated all USSP calls 
--                             to pass @User
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_VETERINARY_DISEASE_SET] 
(
	@VeterinaryDiseaseReportID BIGINT = NULL,
	@FarmID BIGINT = NULL,
	@FarmMasterID BIGINT = NULL,
	@FarmOwnerID BIGINT = NULL,
	@DiseaseID BIGINT = NULL,
	@PersonEnteredByID BIGINT = NULL,
	@PersonReportedByID BIGINT = NULL,
	@PersonInvestigatedByID BIGINT = NULL,
	@SiteID BIGINT = NULL,
	@ReportDate DATETIME = NULL,
	@AssignedDate DATETIME = NULL,
	@InvestigationDate DATETIME = NULL,
	@EIDSSFieldAccessionID NVARCHAR(200) = NULL,
	@RowStatus INT = NULL,
	@ReportedByOrganizationID BIGINT = NULL,
	@InvestigatedByOrganizationID BIGINT = NULL,
	@ReportTypeID BIGINT = NULL,
	@ClassificationTypeID BIGINT = NULL,
	@OutbreakID BIGINT = NULL,
	@EnteredDate DATETIME = NULL,
	@EIDSSReportID NVARCHAR(200) = NULL,
	@StatusTypeID BIGINT = NULL,
	@MonitoringSessionID BIGINT = NULL,
	@ReportCategoryTypeID BIGINT = NULL,
	@FarmTotalAnimalQuantity INT = NULL,
	@FarmSickAnimalQuantity INT = NULL,
	@FarmDeadAnimalQuantity INT = NULL,
	@OriginalVeterinaryDiseaseReportID BIGINT = NULL,
	@FarmEpidemiologicalObservationID BIGINT = NULL,
	@ControlMeasuresObservationID BIGINT = NULL,
	@HerdsOrFlocks NVARCHAR(MAX) = NULL,
	@Species NVARCHAR(MAX) = NULL,
	@ClinicalInformation NVARCHAR(MAX) = NULL,
	@AnimalsInvestigations NVARCHAR(MAX) = NULL,
	@Contacts NVARCHAR(MAX) = NULL,
	@Vaccinations NVARCHAR(MAX) = NULL,
	@Samples NVARCHAR(MAX) = NULL,
	@PensideTests NVARCHAR(MAX) = NULL,
	@LabTests NVARCHAR(MAX) = NULL,
	@TestInterpretations NVARCHAR(MAX) = NULL,
	@ReportLogs NVARCHAR(MAX) = NULL,
	@idfReportedByOffice BIGINT = NULL,
	@idfPersonReportedBy BIGINT = NULL,
	@idfReceivedByOffice BIGINT = NULL,
	@idfReceivedByPerson BIGINT = NULL,
	@IsPrimaryCaseFlag INT = 0,
	@OutbreakCaseStatusId BIGINT = NULL,
	@OutbreakCaseClassificationID BIGINT = NULL,
	@idfsCountry BIGINT = NULL,
	@idfsRegion BIGINT = NULL,
	@idfsRayon BIGINT = NULL,
--	@idfsSettlementType BIGINT = NULL,
	@idfsSettlement BIGINT = NULL,
	@strStreetName NVARCHAR(200) = NULL,
	@strHouse NVARCHAR(200) = NULL,
	@strBuilding NVARCHAR(200) = NULL,
	@strApartment NVARCHAR(200) = NULL,
	@strPostCode NVARCHAR(200) = NULL,
	@dblLatitude FLOAT = NULL,
	@dblLongitude FLOAT = NULL,
	@CaseMonitorings NVARCHAR(MAX) = NULL,
	@User NVARCHAR(200) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @vetLocation BIGINT = NULL
		DECLARE @ReturnCode INT = 0;
		DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
		DECLARE @SupressSelect TABLE (
			ReturnCode INT,
			ReturnMessage NVARCHAR(MAX)
			);
		DECLARE @RowAction CHAR = NULL,
			@RowID BIGINT = NULL,
			@HerdID BIGINT = NULL,
			@HerdMasterID BIGINT = NULL,
			@EIDSSHerdID NVARCHAR(200) = NULL,
			@SickAnimalQuantity INT = NULL,
			@TotalAnimalQuantity INT = NULL,
			@DeadAnimalQuantity INT = NULL,
			@Comments NVARCHAR(2000) = NULL,
			@NewFarmOwnerID BIGINT = NULL,
			@SpeciesID BIGINT = NULL,
			@SpeciesMasterID BIGINT = NULL,
			@SpeciesTypeID BIGINT = NULL,
			@StartOfSignsDate DATETIME = NULL,
			@AverageAge NVARCHAR(200) = NULL,
			@ObservationID BIGINT = NULL,
			@AnimalID BIGINT = NULL,
			@idfsAnimalGender BIGINT = NULL,
			@idfsAnimalCondition BIGINT = NULL,
			@idfsAnimalAge BIGINT = NULL,
			@strAnimalCode NVARCHAR(200) = NULL,
			@AnimalName NVARCHAR(200) = NULL,
			@Color NVARCHAR(200) = NULL,
			@AnimalDescription NVARCHAR(200) = NULL,
			@VaccinationID BIGINT,
			@VaccinationTypeID BIGINT = NULL,
			@RouteTypeID BIGINT = NULL,
			@VaccinationDate DATETIME = NULL,
			@Manufacturer NVARCHAR(200) = NULL,
			@LotNumber NVARCHAR(200) = NULL,
			@NumberVaccinated INT = NULL,
			@SampleID BIGINT,
			@SampleTypeID BIGINT = NULL,
			@CollectedByPersonID BIGINT = NULL,
			@CollectedByOrganizationID BIGINT = NULL,
			@CollectionDate DATETIME = NULL,
			@SentDate DATETIME = NULL,
			@EIDSSLocalOrFieldSampleID NVARCHAR(200) = NULL,
			@SampleStatusTypeID BIGINT = NULL,
			@EIDSSLaboratorySampleID NVARCHAR(200) = NULL,
			@SentToOrganizationID BIGINT = NULL,
			@ReadOnlyIndicator BIT = 0,
			@BirdStatusTypeID BIGINT = NULL,
			@PensideTestID BIGINT = NULL,
			@PensideTestResultTypeID BIGINT = NULL,
			@PensideTestNameTypeID BIGINT = NULL,
			@TestedByPersonID BIGINT = NULL,
			@TestedByOrganizationID BIGINT = NULL,
			@TestDate DATETIME = NULL,
			@PensideTestCategoryTypeID BIGINT = NULL,
			@TestID BIGINT = NULL,
			@TestNameTypeID BIGINT = NULL,
			@TestCategoryTypeID BIGINT = NULL,
			@TestResultTypeID BIGINT = NULL,
			@TestStatusTypeID BIGINT,
			@BatchTestID BIGINT = NULL,
			@StartedDate DATETIME = NULL,
			@ResultDate DATETIME = NULL,
			@ResultEnteredByOrganizationID BIGINT = NULL,
			@ResultEnteredByPersonID BIGINT = NULL,
			@ValidatedByOrganizationID BIGINT = NULL,
			@ValidatedByPersonID BIGINT = NULL,
			@NonLaboratoryTestIndicator BIT,
			@ExternalTestIndicator BIT = NULL,
			@PerformedByOrganizationID BIGINT = NULL,
			@ReceivedDate DATETIME = NULL,
			@ContactPersonName NVARCHAR(200) = NULL,
			@TestInterpretationID BIGINT,
			@InterpretedStatusTypeID BIGINT = NULL,
			@InterpretedByOrganizationID BIGINT = NULL,
			@InterpretedByPersonID BIGINT = NULL,
			@TestingInterpretations BIGINT,
			@ValidatedStatusIndicator BIT = NULL,
			@ReportSessionCreatedIndicator BIT = NULL,
			@ValidatedComment NVARCHAR(200) = NULL,
			@InterpretedComment NVARCHAR(200) = NULL,
			@ValidatedDate DATETIME = NULL,
			@InterpretedDate DATETIME = NULL,
			@VeterinaryDiseaseReportLogID BIGINT,
			@LogStatusTypeID BIGINT = NULL,
			@LoggedByPersonID BIGINT = NULL,
			@LogDate DATETIME = NULL,
			@ActionRequired NVARCHAR(200) = NULL,
			@idfContactCasePerson BIGINT = NULL,
			@idfHumanActual BIGINT,
			@ContactName NVARCHAR(200),
			@ContactRelationshipTypeID BIGINT = NULL,
			@Relation NVARCHAR(200),
			@DateOfLastContact DATETIME,
			@PlaceOfLastContact NVARCHAR(200),
			@ContactStatusId BIGINT = NULL,
			@ContactStatus NVARCHAR(200),
			@ContactComments NVARCHAR(200),
			@ContactType NVARCHAR(200),
			@idfsPersonContactType BIGINT = NULL,
			@OutbreakCaseContactUID BIGINT = NULL,
			@OutBreakCaseReportUID BIGINT = NULL,
			@strOutbreakCaseID NVARCHAR(200) = NULL,
			@ContactTypeID BIGINT = NULL,
			@idfHuman BIGINT = NULL,
			@idfsTestName BIGINT = NULL,
			@idfsTestCategory BIGINT = NULL,
			@idfsTestResult BIGINT = NULL,
			@idfsTestStatus BIGINT = NULL,
			@idfTesting BIGINT = NULL,
			@idfsDiagnosis BIGINT = NULL,
			@idfMaterial BIGINT = NULL,
			@strBarcode NVARCHAR(200) = NULL,
			@datConcludedDate DATETIME,
			@intRowStatus BIGINT = NULL,
			@idfObservation BIGINT = NULL,
			@datMonitoringDate DATETIME = NULL,
			@idfInvestigatedByOffice BIGINT = NULL,
			@idfInvestigatedByPerson BIGINT = NULL,
			@strAdditionalComments NVARCHAR(500) = NULL,
			@idfsLocation BIGINT = COALESCE(@idfsSettlement, @idfsRayon, @idfsRegion, @idfsCountry)

		/*Predetermine The Outbreak Report Id for the upcoming section*/
		SELECT @OutbreakCaseReportUID = OutbreakCaseReportUID
		FROM OutbreakCaseReport
		WHERE idfVetCase = @VeterinaryDiseaseReportID

		DECLARE @HerdsOrFlocksTemp TABLE (
			idfHerd BIGINT NULL,
			idfHerdActual BIGINT NULL,
			strHerdCode NVARCHAR(200) NULL,
			intSickAnimalQty BIGINT NULL,
			intTotalAnimalQty BIGINT NULL,
			intDeadAnimalQty BIGINT NULL,
			Comments NVARCHAR(MAX) NULL,
			intRowStatus BIGINT NULL,
			RowAction NVARCHAR(1) NULL
			)
		DECLARE @SpeciesTemp TABLE (
			SpeciesID BIGINT NOT NULL,
			SpeciesMasterID BIGINT NOT NULL,
			SpeciesTypeID BIGINT NOT NULL,
			HerdID BIGINT NOT NULL,
			SickAnimalQuantity INT NULL,
			TotalAnimalQuantity INT NULL,
			DeadAnimalQuantity INT NULL,
			StartOfSignsDate DATETIME2 NULL,
			AverageAge NVARCHAR(200) NULL,
			ObservationID BIGINT NULL,
			Comments NVARCHAR(2000) NULL,
			RowStatus INT NOT NULL,
			RowAction CHAR(1) NULL,
			idfHerdActual BIGINT NOT NULL
			);
		DECLARE @ClinicalInformationTemp TABLE (
			langId NVARCHAR(200) NULL,
			idfHerd BIGINT NOT NULL,
			Herd NVARCHAR(200) NULL,
			idfsClinical BIGINT NOT NULL,
			idfsSpeciesType BIGINT NULL,
			SpeciesType NVARCHAR(200) NULL,
			idfsStatus BIGINT NULL,
			idfsInvestigationPerformed BIGINT NULL
			);
		DECLARE @AnimalsTemp TABLE (
			idfAnimal BIGINT NULL,
			idfsAnimalGender BIGINT NULL,
			idfsAnimalCondition BIGINT NULL,
			idfsAnimalAge BIGINT NULL,
			idfsSpeciesType BIGINT NULL,
			idfSpecies BIGINT NULL,
			ObservationId BIGINT NULL,
			strAnimalCode NVARCHAR(200) NULL,
			strName NVARCHAR(200) NULL,
			strColor NVARCHAR(200) NULL,
			strDescription NVARCHAR(200) NULL,
			intRowStatus BIGINT NULL,
			idfsClinical BIGINT NULL,
			idfHerd BIGINT NULL,
			strHerdCode NVARCHAR(200) NULL,
			Species NVARCHAR(200) NULL,
			Age NVARCHAR(200) NULL,
			Sex NVARCHAR(200) NULL,
			idfStatus BIGINT NULL,
			STATUS NVARCHAR(200) NULL,
			RowAction NVARCHAR(1) NULL
			)
		DECLARE @VaccinationsTemp TABLE (
			idfVaccination BIGINT NOT NULL,
			idfVetCase BIGINT NULL,
			idfSpecies BIGINT NULL,
			idfsSpeciesType BIGINT NULL,
			idfsVaccinationType BIGINT NULL,
			idfsVaccinationRoute BIGINT NULL,
			idfsDiagnosis BIGINT NULL,
			datVaccinationDate DATETIME2 NULL,
			strManufacturer NVARCHAR(200) NULL,
			strLotNumber NVARCHAR(200) NULL,
			intNumberVaccinated INT NULL,
			strNote NVARCHAR(2000) NULL,
			intRowStatus INT NULL,
			RowAction NVARCHAR(1) NULL,
			Name NVARCHAR(200) NULL,
			Species NVARCHAR(200) NULL,
			VaccinationType NVARCHAR(200) NULL,
			Route NVARCHAR(200) NULL
			)
		DECLARE @SamplesTemp TABLE (
			idfMaterial BIGINT NOT NULL,
			idfsSampleType BIGINT NULL,
			strFieldBarcode NVARCHAR(200) NULL,
			idfAnimal BIGINT NULL,
			strAnimalCode NVARCHAR(200) NULL,
			idfSpecies BIGINT NULL,
			Species NVARCHAR(200) NULL,
			idfsBirdStatus BIGINT NULL,
			BirdStatus NVARCHAR(200) NULL,
			datFieldCollectionDate DATETIME2 NULL,
			idfFieldCollectedByOffice BIGINT NULL,
			FieldCollectedByOffice NVARCHAR(200) NULL,
			idfFieldCollectedByPerson BIGINT NULL,
			FieldColectedByPerson NVARCHAR(200) NULL,
			idfSendToOffice BIGINT NULL,
			SendToOffice NVARCHAR(200) NULL,
			strNote NVARCHAR(200) NULL,
			intRowStatus INT NULL,
			RowAction NVARCHAR(1) NULL
			);
		DECLARE @PensideTestsTemp TABLE (
			idfPensideTest BIGINT NOT NULL,
			strFieldBarcode NVARCHAR(200) NULL,
			idfMaterial BIGINT NULL,
			idfsSampleType BIGINT NULL,
			SampleType NVARCHAR(200) NULL,
			idfSpecies BIGINT NULL,
			Species NVARCHAR(200) NULL,
			strAnimalCode NVARCHAR(200) NULL,
			idfsPensideTestName BIGINT NULL,
			TestName NVARCHAR(200) NULL,
			idfsPensideTestResult BIGINT NULL,
			Result NVARCHAR(200) NULL,
			intRowStatus INT NOT NULL,
			RowAction NVARCHAR(1) NULL
			);
		DECLARE @LabTestsTemp TABLE (
			idfTesting BIGINT NULL,
			idfsTestName BIGINT NULL,
			idfsTestCategory BIGINT NULL,
			idfsTestResult BIGINT NULL,
			idfsTestStatus BIGINT NULL,
			idfsDiagnosis BIGINT NULL,
			idfMaterial BIGINT NULL,
			intRowStatus INT NULL,
			strBarCode NVARCHAR(200) NULL,
			SampleType NVARCHAR(200) NULL,
			Species NVARCHAR(200) NULL,
			idfSpecies BIGINT NULL,
			strFieldBarcode NVARCHAR(200) NULL,
			Animal NVARCHAR(200) NULL,
			idfAnimal BIGINT NULL,
			TestName NVARCHAR(200) NULL,
			TestCategory NVARCHAR(200) NULL,
			TestResult NVARCHAR(200) NULL,
			TestStatus NVARCHAR(200) NULL,
			TestDisease NVARCHAR(200) NULL,
			datConcludedDate DATETIME2 NULL,
			RowAction NVARCHAR(1)
			)

		BEGIN TRANSACTION;

		INSERT INTO @HerdsOrFlocksTemp
		SELECT *
		FROM OPENJSON(@HerdsOrFlocks) WITH (
				idfHerd BIGINT,
				idfHerdActual BIGINT,
				strHerdCode NVARCHAR(200),
				intSickAnimalQty BIGINT,
				intTotalAnimalQty BIGINT,
				intDeadAnimalQty BIGINT,
				Comments NVARCHAR(MAX),
				intRowStatus BIGINT,
				RowAction NVARCHAR(1)
				)

		INSERT INTO @SpeciesTemp
		SELECT *
		FROM OPENJSON(@Species) WITH (
				idfSpecies BIGINT,
				idfSpeciesActual BIGINT,
				idfsSpeciesType BIGINT,
				idfHerd BIGINT,
				intSickAnimalQty INT,
				intTotalAnimalQty INT,
				intDeadAnimalQty INT,
				datStartOfSignsDate DATETIME2,
				intAverageAge NVARCHAR(200),
				ObservationId BIGINT,
				strNote NVARCHAR(2000),
				intRowStatus INT,
				RowAction CHAR(1),
				idfHerdActual BIGINT
				);

		INSERT INTO @ClinicalInformationTemp
		SELECT *
		FROM OPENJSON(@ClinicalInformation) WITH (
				langId NVARCHAR(200),
				idfHerd BIGINT,
				Herd NVARCHAR(200),
				idfsClinical BIGINT,
				idfsSpeciesType BIGINT,
				SpeciesType NVARCHAR(200),
				idfsStatus BIGINT,
				idfsInvestigationPerformed BIGINT
				);

		INSERT INTO @AnimalsTemp
		SELECT *
		FROM OPENJSON(@AnimalsInvestigations) WITH (
				idfAnimal BIGINT,
				idfsAnimalGender BIGINT,
				idfsAnimalCondition BIGINT,
				idfsAnimalAge BIGINT,
				idfsSpeciesType BIGINT,
				idfSpecies BIGINT,
				ObservationId BIGINT,
				strAnimalCode NVARCHAR(200),
				strName NVARCHAR(200),
				strColor NVARCHAR(200),
				strDescription NVARCHAR(200),
				intRowStatus BIGINT,
				idfsClinical BIGINT,
				idfHerd BIGINT,
				strHerdCode NVARCHAR(200),
				Species NVARCHAR(200),
				Age NVARCHAR(200),
				Sex NVARCHAR(200),
				idfStatus BIGINT,
				STATUS NVARCHAR(200),
				RowAction NVARCHAR(1)
				)

		SET @Vaccinations = REPLACE(@Vaccinations, '"0001-01-01T00:00:00"', 'null')

		INSERT INTO @VaccinationsTemp
		SELECT *
		FROM OPENJSON(@Vaccinations) WITH (
				idfVaccination BIGINT,
				idfVetCase BIGINT,
				idfSpecies BIGINT,
				idfsSpeciesType BIGINT,
				idfsVaccinationType BIGINT,
				idfsVaccinationRoute BIGINT,
				idfsDiagnosis BIGINT,
				datVaccinationDate DATETIME2,
				strManufacturer NVARCHAR(200),
				strLotNumber NVARCHAR(200),
				intNumberVaccinated INT,
				strNote NVARCHAR(2000),
				intRowStatus INT,
				RowAction NVARCHAR(1),
				Name NVARCHAR(200),
				Species NVARCHAR(200),
				VaccinationType NVARCHAR(200),
				Route NVARCHAR(200)
				);

		SET @Samples = REPLACE(@Samples, '"0001-01-01T00:00:00"', 'null')

		INSERT INTO @SamplesTemp
		SELECT *
		FROM OPENJSON(@Samples) WITH (
				idfMaterial BIGINT,
				idfsSampleType BIGINT,
				strFieldBarcode NVARCHAR(200),
				idfAnimal BIGINT,
				strAnimalCode NVARCHAR(200),
				idfSpecies BIGINT,
				Species NVARCHAR(200),
				idfsBirdStatus BIGINT,
				BirdStatus NVARCHAR(200),
				datFieldCollectionDate DATETIME2,
				idfFieldCollectedByOffice BIGINT,
				FieldCollectedByOffice NVARCHAR(200),
				idfFieldCollectedByPerson BIGINT,
				FieldColectedByPerson NVARCHAR(200),
				idfSendToOffice BIGINT,
				SendToOffice NVARCHAR(200),
				strNote NVARCHAR(200),
				intRowStatus INT,
				RowAction NVARCHAR(1)
				);

		INSERT INTO @PensideTestsTemp
		SELECT *
		FROM OPENJSON(@PensideTests) WITH (
				idfPensideTest BIGINT,
				strFieldBarcode NVARCHAR(200),
				idfMaterial BIGINT,
				idfsSampleType BIGINT,
				SampleType NVARCHAR(200),
				idfSpecies BIGINT,
				Species NVARCHAR(200),
				strAnimalCode NVARCHAR(200),
				idfsPensideTestName BIGINT,
				TestName NVARCHAR(200),
				idfsPensideTestResult BIGINT,
				Result NVARCHAR(200),
				intRowStatus INT,
				RowAction NVARCHAR(1)
				);

		SET @LabTests = REPLACE(@LabTests, '"0001-01-01T00:00:00"', 'null')

		INSERT INTO @LabTestsTemp
		SELECT *
		FROM OPENJSON(@LabTests) WITH (
				idfTesting BIGINT,
				idfsTestName BIGINT,
				idfsTestCategory BIGINT,
				idfsTestResult BIGINT,
				idfsTestStatus BIGINT,
				idfsDiagnosis BIGINT,
				idfMaterial BIGINT,
				intRowStatus INT,
				strBarCode NVARCHAR(200),
				SampleType NVARCHAR(200),
				Species NVARCHAR(200),
				idfSpecies BIGINT,
				strFieldBarcode NVARCHAR(200),
				Animal NVARCHAR(200),
				idfAnimal BIGINT,
				TestName NVARCHAR(200),
				TestCategory NVARCHAR(200),
				TestResult NVARCHAR(200),
				TestStatus NVARCHAR(200),
				TestDisease NVARCHAR(200),
				datConcludedDate DATETIME2,
				RowAction NVARCHAR(1)
				);

		-- Set farm address 
		IF @idfsCountry IS NOT NULL
			AND @idfsRayon IS NOT NULL
			AND @idfsRegion IS NOT NULL
		BEGIN
			EXECUTE dbo.USSP_GBL_ADDRESS_SET 
				@GeolocationID = @vetLocation OUTPUT,
				@ResidentTypeID = NULL,
				@GroundTypeID = NULL,
				@GeolocationTypeID = NULL,
				@LocationID = @idfsLocation,
				@Apartment = @strApartment,
				@Building = @strBuilding,
				@StreetName = @strStreetName,
				@House = @strHouse,
				@PostalCodeString = @strPostCode,
				@DescriptionString = NULL,
				@Distance = NULL,
				@Latitude = @dblLatitude,
				@Longitude = @dblLongitude,
				@Elevation = NULL, -- Elevation
				@Accuracy = NULL,
				@Alignment = NULL,
				@ForeignAddressIndicator = 0,
				@ForeignAddressString = NULL,
				@GeolocationSharedIndicator = 1,
				@ReturnCode = @ReturnCode OUTPUT,
				@ReturnMessage = @ReturnMessage OUTPUT;
		END
		-- this is a new Vet Disease Report
		IF NOT EXISTS (SELECT * FROM dbo.tlbVetCase	WHERE idfVetCase = @VeterinaryDiseaseReportID AND intRowStatus = 0)
		BEGIN
			IF @ReportCategoryTypeID = 10012004 --Avian
			BEGIN
				UPDATE dbo.tlbFarmActual
				SET intAvianTotalAnimalQty = @TotalAnimalQuantity,
					intAvianSickAnimalQty = @SickAnimalQuantity,
					intAvianDeadAnimalQty = @DeadAnimalQuantity,
					idfFarmAddress = @vetLocation,
					AuditUpdateDTM = GETDATE(),
					AuditUpdateUser = @User
					
				WHERE idfFarmActual = @FarmMasterID;

				--INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_VET_FARM_COPY 
					@FarmMasterID = @FarmMasterID,
					@AvianTotalAnimalQuantity = @FarmTotalAnimalQuantity,
					@AvianSickAnimalQuantity = @FarmSickAnimalQuantity,
					@AvianDeadAnimalQuantity = @FarmDeadAnimalQuantity,
					@LivestockTotalAnimalQuantity = NULL,
					@LivestockSickAnimalQuantity = NULL,
					@LivestockDeadAnimalQuantity = NULL,
					@Latitude = NULL,
					@Longitude = NULL,
					@MonitoringSessionID = @MonitoringSessionID,
					@ObservationID = NULL,
					@FarmOwnerID = @FarmOwnerID,
					@FarmID = @FarmID OUTPUT,
					@NewFarmOwnerID = @NewFarmOwnerID OUTPUT,
					@AuditUser = @User;

				IF @NewFarmOwnerID <> NULL
				BEGIN
					SET @FarmOwnerID = @NewFarmOwnerID;
				END;
			END
			ELSE --Livestock
			BEGIN
				UPDATE dbo.tlbFarmActual
				SET intLivestockTotalAnimalQty = @TotalAnimalQuantity,
					intLivestockSickAnimalQty = @SickAnimalQuantity,
					intLivestockDeadAnimalQty = @DeadAnimalQuantity,
					idfFarmAddress = @vetLocation,
					AuditUpdateUser = @User,
					AuditUpdateDTM = GETDATE()
				WHERE idfFarmActual = @FarmMasterID;

				--INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_VET_FARM_COPY
					@FarmMasterID = @FarmMasterID,
					@AvianTotalAnimalQuantity = NULL,
					@AvianSickAnimalQuantity = NULL,
					@AvianDeadAnimalQuantity = NULL,
					@LivestockTotalAnimalQuantity = @FarmTotalAnimalQuantity,
					@LivestockSickAnimalQuantity = @FarmSickAnimalQuantity,
					@LivestockDeadAnimalQuantity = @FarmDeadAnimalQuantity,
					@Latitude = NULL,
					@Longitude = NULL,
					@MonitoringSessionID = @MonitoringSessionID,
					@ObservationID = NULL,
					@FarmOwnerID = @FarmOwnerID,
					@FarmID = @FarmID OUTPUT,
					@NewFarmOwnerID = @NewFarmOwnerID OUTPUT,
					@AuditUser = @User;

				IF @NewFarmOwnerID <> NULL
				BEGIN
					SET @FarmOwnerID = @NewFarmOwnerID;
				END;
			END

			INSERT INTO @SupressSelect
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 
				@tableNAme = 'tlbVetCase',
				@idfsKey = @VeterinaryDiseaseReportID OUTPUT;

			INSERT INTO @SupressSelect
			EXECUTE dbo.USP_GBL_NextNumber_GET 
				@ObjectName = 'Vet Disease Report',
				@NextNumberValue = @EIDSSReportID OUTPUT,
				@InstallationSite = NULL

			INSERT INTO dbo.tlbVetCase
			(
			    idfVetCase,
			    idfFarm,
			    idfsFinalDiagnosis,
			    idfPersonEnteredBy,
			    idfPersonReportedBy,
			    idfPersonInvestigatedBy,
			    idfsSite,
			    datReportDate,
			    datAssignedDate,
			    datInvestigationDate,
			    datFinalDiagnosisDate,
			    strTestNotes,
			    strSummaryNotes,
			    strClinicalNotes,
			    strFieldAccessionID,
			    rowguid,
			    idfsYNTestsConducted,
			    intRowStatus,
			    idfReportedByOffice,
			    idfInvestigatedByOffice,
			    idfsCaseReportType,
			    strDefaultDisplayDiagnosis,
			    idfsCaseClassification,
			    idfOutbreak,
			    datEnteredDate,
			    strCaseID,
			    idfsCaseProgressStatus,
			    strSampleNotes,
			    idfParentMonitoringSession,
			    idfsCaseType,
			    SourceSystemNameID,
			    SourceSystemKeyValue,
			    AuditCreateUser,
			    AuditCreateDTM,
			    AuditUpdateUser,
			    AuditUpdateDTM,
			    idfReceivedByOffice,
			    idfReceivedByPerson
			)
			VALUES 
			(
				@VeterinaryDiseaseReportID,
				@FarmID,
				@DiseaseID,
				@PersonEnteredByID,
				@idfPersonReportedBy,
				@PersonInvestigatedByID,
				@SiteID,
				@ReportDate,
				@AssignedDate,
				@InvestigationDate,
				NULL,
				NULL,
				NULL,
				NULL,
				@EIDSSFieldAccessionID,
				NEWID(),
				NULL,
				@RowStatus,
				@idfReportedByOffice,
				@InvestigatedByOrganizationID,
				@ReportTypeID,
				NULL,
				@ClassificationTypeID,
				@OutbreakID,
				@EnteredDate,
				@EIDSSReportID,
				@StatusTypeID,
				NULL,
				@MonitoringSessionID,
				@ReportCategoryTypeID,
				10519001,
				'[{"idfVetCase":' + CAST(@VeterinaryDiseaseReportID AS NVARCHAR(300)) + '}]',
				@User,
				GETDATE(),
				@User,
				GETDATE(),
				@idfReceivedByOffice,
				@idfReceivedByPerson
				
			);

		END

		-- Else this is an update to an existing vet disease Report
		ELSE
		BEGIN
			IF @ReportCategoryTypeID = 10012004 --Avian
			BEGIN
				UPDATE dbo.tlbFarmActual
				SET intAvianTotalAnimalQty = @TotalAnimalQuantity,
					intAvianSickAnimalQty = @SickAnimalQuantity,
					intAvianDeadAnimalQty = @DeadAnimalQuantity,
					idfFarmAddress = @vetLocation,
					AuditUpdateDTM = GETDATE(),
					AuditUpdateUser = @User
				WHERE idfFarmActual = @FarmMasterID;

				--INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_VET_FARM_COPY 
					@FarmMasterID = @FarmMasterID,
					@AvianTotalAnimalQuantity = @FarmTotalAnimalQuantity,
					@AvianSickAnimalQuantity = @FarmSickAnimalQuantity,
					@AvianDeadAnimalQuantity = @FarmDeadAnimalQuantity,
					@LivestockTotalAnimalQuantity = NULL,
					@LivestockSickAnimalQuantity = NULL,
					@LivestockDeadAnimalQuantity = NULL,
					@Latitude = NULL,
					@Longitude = NULL,
					@MonitoringSessionID = @MonitoringSessionID,
					@ObservationID = NULL,
					@FarmOwnerID = @FarmOwnerID,
					@FarmID = @FarmID OUTPUT,
					@NewFarmOwnerID = @NewFarmOwnerID OUTPUT,
					@AuditUser = @User;

				IF @NewFarmOwnerID <> NULL
				BEGIN
					SET @FarmOwnerID = @NewFarmOwnerID;
				END;
			END
			ELSE --Livestock
			BEGIN
				UPDATE dbo.tlbFarmActual
				SET intLivestockTotalAnimalQty = @TotalAnimalQuantity,
					intLivestockSickAnimalQty = @SickAnimalQuantity,
					intLivestockDeadAnimalQty = @DeadAnimalQuantity,
					idfFarmAddress = @vetLocation,
					AuditUpdateDTM = GETDATE(),
					AuditUpdateUser = @User
				WHERE idfFarmActual = @FarmMasterID;

				--INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_VET_FARM_COPY 
					@FarmMasterID = @FarmMasterID,
					@AvianTotalAnimalQuantity = NULL,
					@AvianSickAnimalQuantity = NULL,
					@AvianDeadAnimalQuantity = NULL,
					@LivestockTotalAnimalQuantity = @FarmTotalAnimalQuantity,
					@LivestockSickAnimalQuantity = @FarmSickAnimalQuantity,
					@LivestockDeadAnimalQuantity = @FarmDeadAnimalQuantity,
					@Latitude = NULL,
					@Longitude = NULL,
					@MonitoringSessionID = @MonitoringSessionID,
					@ObservationID = NULL,
					@FarmOwnerID = @FarmOwnerID,
					@FarmID = @FarmID OUTPUT,
					@NewFarmOwnerID = @NewFarmOwnerID OUTPUT,
					@AuditUser = @User;

				IF @NewFarmOwnerID <> NULL
				BEGIN
					SET @FarmOwnerID = @NewFarmOwnerID;
				END;
			END
		END;

		UPDATE dbo.tlbVetCase
		SET idfFarm = @FarmID,
			idfsFinalDiagnosis = @DiseaseID,
			idfPersonEnteredBy = @PersonEnteredByID,
			idfReportedByOffice = @idfReportedByOffice,
			idfPersonReportedBy = @idfPersonReportedBy,
			idfReceivedByOffice = @idfReceivedByOffice,
			idfReceivedByPerson = @idfReceivedByPerson,
			idfPersonInvestigatedBy = @PersonInvestigatedByID,
			idfsSite = @SiteID,
			datReportDate = @ReportDate,
			datAssignedDate = @AssignedDate,
			datInvestigationDate = @InvestigationDate,
			datFinalDiagnosisDate = NULL,
			strTestNotes = NULL,
			strSummaryNotes = NULL,
			strClinicalNotes = NULL,
			strFieldAccessionID = @EIDSSFieldAccessionID,
			idfsYNTestsConducted = NULL,
			intRowStatus = @RowStatus,
			idfInvestigatedByOffice = @InvestigatedByOrganizationID,
			idfsCaseReportType = @ReportTypeID,
			idfsCaseClassification = @ClassificationTypeID,
			idfOutbreak = @OutbreakID,
			datEnteredDate = @EnteredDate,
			--strCaseID = @EIDSSReportID,
			idfsCaseProgressStatus = @StatusTypeID,
			strSampleNotes = NULL,
			idfParentMonitoringSession = @MonitoringSessionID,
			idfsCaseType = @ReportCategoryTypeID,
			AuditUpdateUser = @User,
			AuditUpdateDTM = GETDATE()
		WHERE idfVetCase = @VeterinaryDiseaseReportID;

		WHILE EXISTS (
				SELECT *
				FROM @HerdsOrFlocksTemp
				)
		BEGIN
			SELECT TOP 1 @RowID = idfHerd,
				@HerdID = idfHerd,
				@EIDSSHerdID = strHerdCode,
				@HerdMasterID = idfHerdActual,
				@SickAnimalQuantity = intSickAnimalQty,
				@TotalAnimalQuantity = intTotalAnimalQty,
				@DeadAnimalQuantity = intDeadAnimalQty,
				@Comments = Comments,
				@RowStatus = intRowStatus,
				@RowAction = RowAction
			FROM @HerdsOrFlocksTemp;

			UPDATE @AnimalsTemp
			SET idfHerd = @HerdID
			WHERE strHerdCode = @EIDSSHerdID;

			IF @HerdMasterID < 0
			BEGIN
				SET @RowAction = 'I'

				INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_VET_HERD_MASTER_SET 
					@AuditUser = @User,
					@HerdMasterID = @HerdMasterID OUTPUT,
					@FarmMasterID = @FarmMasterID,
					@EIDSSHerdID = @EIDSSHerdID OUTPUT,
					@SickAnimalQuantity = @SickAnimalQuantity,
					@TotalAnimalQuantity = @TotalAnimalQuantity,
					@DeadAnimalQuantity = @DeadAnimalQuantity,
					@Note = @Comments,
					@RowStatus = @RowStatus,
					@RowAction = @RowAction;

				UPDATE @HerdsOrFlocksTemp
				SET idfHerdActual = @HerdMasterID,
					strHerdCode = @EIDSSHerdID
				WHERE idfHerdActual = @HerdMasterID;
			END;

			IF @RowAction = 'D'
			BEGIN
				SET @RowStatus = 1;
			END

			INSERT INTO @SupressSelect
			EXECUTE dbo.USSP_VET_HERD_SET
				@AuditUser = @User,
				@HerdID = @HerdID OUTPUT,
				@HerdMasterID = @HerdMasterID,
				@FarmID = @FarmID,
				@EIDSSHerdID = @EIDSSHerdID,
				@SickAnimalQuantity = @SickAnimalQuantity,
				@TotalAnimalQuantity = @TotalAnimalQuantity,
				@DeadAnimalQuantity = @DeadAnimalQuantity,
				@Note = @Comments,
				@RowStatus = @RowStatus,
				@RowAction = @RowAction;

			UPDATE @SpeciesTemp
			SET idfHerdActual = @HerdMasterID,
				HerdID = @HerdID
			WHERE HerdID = @RowID;

			UPDATE @AnimalsTemp
			SET idfHerd = @HerdID
			WHERE idfHerd = @RowID;

			DELETE
			FROM @HerdsOrFlocksTemp
			WHERE idfHerd = @RowID;
		END;

		--an outbreak reference must be created now, in order to tie in the tlbVetCase record to the Outbreak Session...via a case report
		IF (@OutbreakCaseReportUID IS NULL OR @OutbreakCaseReportUID = - 1)
		BEGIN
			INSERT INTO @SupressSelect
			EXEC dbo.USP_GBL_NEXTKEYID_GET 'OutbreakCaseReport',
				@OutBreakCaseReportUID OUTPUT;

			INSERT INTO @SupressSelect
			EXEC dbo.USP_GBL_NextNumber_GET 'Vet Outbreak Case',
				@strOutbreakCaseID OUTPUT,
				NULL;

			INSERT INTO OutbreakCaseReport (
				OutbreakCaseReportUID,
				idfOutbreak,
				strOutbreakCaseID,
				idfHumanCase,
				idfVetCase,
				OutbreakCaseObservationId,
				OutbreakCaseStatusId,
				OutbreakCaseClassificationID,
				isPrimaryCaseFlag,
				rowguid,
				introwStatus,
				AuditCreateUser,
				AuditCreateDTM,
				AuditUpdateUser,
				AuditUpdateDTM
				)
			VALUES (
				@OutBreakCaseReportUID,
				@OutbreakID,
				@strOutbreakCaseID,
				NULL,
				@VeterinaryDiseaseReportID,
				@ControlMeasuresObservationID,
				@OutbreakCaseStatusId,
				@OutbreakCaseClassificationID,
				@IsPrimaryCaseFlag,
				NEWID(),
				0,
				@User,
				GETDATE(),
				@User,
				GETDATE()
				)
		END
		ELSE
		BEGIN
			UPDATE OutbreakCaseReport
			SET OutbreakCaseStatusId = @OutbreakCaseStatusId,
				OutbreakCaseClassificationID = @OutbreakCaseClassificationID,
				isPrimaryCaseFlag = @IsPrimaryCaseFlag,
				introwStatus = 0,
				AuditUpdateUser = @User,
				AuditUpdateDTM = GETDATE(),
				OutbreakCaseObservationID = @ControlMeasuresObservationID
			WHERE OutbreakCaseReportUID = @OutbreakCaseReportUID
		END

		/*Species*/
		WHILE EXISTS (SELECT * FROM @SpeciesTemp)
		BEGIN
			SELECT TOP 1 @RowID = SpeciesID,
				@SpeciesID = SpeciesID,
				@SpeciesMasterID = SpeciesMasterID,
				@SpeciesTypeID = SpeciesTypeID,
				@HerdID = HerdID,
				@HerdMasterID = idfHerdActual,
				@StartOfSignsDate = CONVERT(DATETIME, StartOfSignsDate),
				@AverageAge = AverageAge,
				@SickAnimalQuantity = SickAnimalQuantity,
				@TotalAnimalQuantity = TotalAnimalQuantity,
				@DeadAnimalQuantity = DeadAnimalQuantity,
				@Comments = Comments,
				@RowStatus = RowStatus,
				@RowAction = RowAction
			FROM @SpeciesTemp;

			IF @SpeciesMasterID < 0
			BEGIN
				SET @RowAction = 'I'

				INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_VET_SPECIES_MASTER_SET
					@AuditUser = @User,
					@SpeciesMasterID = @SpeciesMasterID OUTPUT,
					@SpeciesTypeID = @SpeciesTypeID,
					@HerdMasterID = @HerdMasterID,
					@StartOfSignsDate = @StartOfSignsDate,
					@AverageAge = @AverageAge,
					@SickAnimalQuantity = @SickAnimalQuantity,
					@TotalAnimalQuantity = @TotalAnimalQuantity,
					@DeadAnimalQuantity = @DeadAnimalQuantity,
					@Note = @Comments,
					@RowStatus = @RowStatus,
					@RowAction = @RowAction;

				UPDATE @SpeciesTemp
				SET SpeciesMasterID = @SpeciesMasterID
				WHERE SpeciesMasterID = @SpeciesMasterID;
			END;

			INSERT INTO @SupressSelect
			EXECUTE dbo.USSP_VET_SPECIES_SET
				@SpeciesID = @SpeciesID OUTPUT,
				@SpeciesMasterID = @SpeciesMasterID,
				@SpeciesTypeID = @SpeciesTypeID,
				@HerdID = @HerdID,
				@ObservationID = @ObservationID,
				@StartOfSignsDate = @StartOfSignsDate,
				@AverageAge = @AverageAge,
				@SickAnimalQuantity = @SickAnimalQuantity,
				@TotalAnimalQuantity = @TotalAnimalQuantity,
				@DeadAnimalQuantity = @DeadAnimalQuantity,
				@Comments = @Comments,
				@RowStatus = @RowStatus,
				@RowAction = @RowAction,
				@AuditUserName = @User;

			UPDATE @AnimalsTemp
			SET idfSpecies = @SpeciesID
			WHERE idfSpecies = @RowID;

			UPDATE @VaccinationsTemp
			SET idfSpecies = @SpeciesID
			WHERE idfSpecies = @RowID;

			UPDATE @SamplesTemp
			SET idfSpecies = @SpeciesID
			WHERE idfSpecies = @RowID;

			UPDATE @PensideTestsTemp
			SET idfSpecies = @SpeciesID,
				idfsSampleType = @SpeciesTypeID
			WHERE idfSpecies = @RowId;

			DELETE
			FROM @SpeciesTemp
			WHERE SpeciesID = @RowID;
		END;

		

		/*Animals*/
		WHILE EXISTS (
				SELECT *
				FROM @AnimalsTemp
				)
		BEGIN
			SELECT TOP 1 @RowID = idfAnimal,
				@AnimalID = idfAnimal,
				@idfsAnimalGender = idfsAnimalGender,
				@idfsAnimalCondition = idfsAnimalCondition,
				@idfsAnimalAge = idfsAnimalAge,
				@SpeciesID = idfSpecies,
				@ObservationID = ObservationID,
				@AnimalDescription = strDescription,
				@strAnimalCode = strAnimalCode,
				@AnimalName = strName,
				@Color = strColor,
				@RowStatus = intRowStatus,
				@RowAction = RowAction
			FROM @AnimalsTemp;

			IF @AnimalID < 0
			BEGIN
				SET @RowAction = 'I'
			END

			INSERT INTO @SupressSelect
			EXECUTE dbo.USSP_VET_ANIMAL_SET 
				@AuditUser = @User,
				@AnimalID = @AnimalID OUTPUT,
				@AnimalGenderTypeID = @idfsAnimalGender,
				@AnimalConditionTypeID = @idfsAnimalCondition,
				@AnimalAgeTypeID = @idfsAnimalAge,
				@SpeciesID = @SpeciesID,
				@ObservationID = @ObservationID,
				@AnimalDescription = @AnimalDescription,
				@EIDSSAnimalID = @strAnimalCode,
				@AnimalName =@AnimalName,
				@Color = @Color,
				@ClinicalSignsIndicator = NULL, -- Clinical signs indicator
				@RowStatus = @RowStatus,
				@RowAction = @RowAction;

			UPDATE @SamplesTemp
			SET idfAnimal = @AnimalID
			WHERE idfAnimal = @RowID;

			DELETE
			FROM @AnimalsTemp
			WHERE idfAnimal = @RowID;
		END;


		/*Vaccinations*/
		WHILE EXISTS (SELECT * FROM @VaccinationsTemp)
		BEGIN
			SELECT TOP 1 @RowID = idfVaccination,
				@VaccinationID = idfVaccination,
				@SpeciesID = idfSpecies,
				@VaccinationTypeID = idfsVaccinationType,
				@RouteTypeID = idfsVaccinationRoute,
				@DiseaseID = idfsDiagnosis,
				@VaccinationDate = CONVERT(DATETIME, datVaccinationDate),
				@Manufacturer = strManufacturer,
				@LotNumber = strLotNumber,
				@NumberVaccinated = intNumberVaccinated,
				@Comments = strNote,
				@RowStatus = intRowStatus,
				@RowAction = RowAction
			FROM @VaccinationsTemp;

			IF @VaccinationID < 0
			BEGIN
				SET @RowAction = 'I'
			END

			INSERT INTO @SupressSelect
			EXECUTE dbo.USSP_VET_VACCINATION_SET 
				@AuditUser = @User,
				@VaccinationID = @VaccinationID OUTPUT,
				@VeterinaryDieaseReportID = @VeterinaryDiseaseReportID,
				@SpeciesID = @SpeciesID,
				@VaccinationTypeID = @VaccinationTypeID,
				@VaccinationRouteTypeID = @RouteTypeID,
				@DiseaseID = @DiseaseID,
				@VaccinationDate = @VaccinationDate,
				@Manufacturer = @Manufacturer,
				@LotNumber = @LotNumber,
				@NumberVaccinated = @NumberVaccinated,
				@Comments = @Comments,
				@RowStatus = @RowStatus,
				@RowAction = @RowAction;

			DELETE
			FROM @VaccinationsTemp
			WHERE idfVaccination = @RowID;
		END;

		--@OutBreakCaseReportUID
		IF @Contacts IS NOT NULL
			EXEC USSP_OMM_CONTACT_SET NULL,
				@Contacts,
				@User = @User,
				@tOutbreakCaseReportUID = @OutbreakCaseReportUID,
				@FunctionCall = 1;

		/*Samples*/
		WHILE EXISTS (
				SELECT *
				FROM @SamplesTemp
				)
		BEGIN
			SELECT TOP 1 @RowID = idfMaterial,
				@SampleID = idfMaterial,
				@SampleTypeID = idfsSampleType,
				@SpeciesID = idfSpecies,
				@AnimalID = idfAnimal,
				@EIDSSLocalOrFieldSampleID = strFieldBarCode,
				@CollectedByPersonID = idfFieldCollectedByPerson,
				@CollectedByOrganizationID = idfFieldCollectedByOffice,
				@CollectionDate = CONVERT(DATETIME, datFieldCollectionDate),
				@Comments = strNote,
				@RowStatus = intRowStatus,
				@SentToOrganizationID = idfSendToOffice,
				@BirdStatusTypeID = idfsBirdStatus,
				@RowAction = RowAction
			FROM @SamplesTemp;

			IF @SampleID < 0
			BEGIN
				SET @RowAction = 'I'
			END

			INSERT INTO @SupressSelect
			EXECUTE dbo.USSP_GBL_SAMPLE_SET 
				@AuditUser = @User,
				@SampleID = @SampleID OUTPUT,
				@SampleTypeID = @SampleTypeID,
				@RootSampleID = NULL,
				@ParentSampleID = NULL,
				@HumanID = @FarmOwnerID,
				@SpeciesID = @SpeciesID,
				@AnimalID = @AnimalID,
				@VectorID = NULL,
				@MonitoringSessionID = @MonitoringSessionID,
				@VectorSessionID = NULL,
				@HumanDiseaseReportID = NULL,
				@VeterinaryDiseaseReportID = @VeterinaryDiseaseReportID,
				@CollectionDate = @CollectionDate,
				@CollectedByPersonID = @CollectedByPersonID,
				@CollectedByOrganizationID = @CollectedByOrganizationID,
				@SentDate = @SentDate,
				@SentToOrganizationID = @SentToOrganizationID,
				@EIDSSLocalFieldSampleID = @EIDSSLocalOrFieldSampleID,
				@SiteID = @SiteID,
				@EnteredDate = @EnteredDate,
				@ReadOnlyIndicator = @ReadOnlyIndicator,
				@SampleStatusTypeID = @SampleStatusTypeID,
				@Comments = @Comments,
				@CurrentSiteID = @SiteID,
				@DiseaseID = @DiseaseID,
				@BirdStatusTypeID = @BirdStatusTypeID,
				@RowStatus = @RowStatus,
				@RowAction = @RowAction;

			UPDATE @PensideTestsTemp
			SET idfMaterial = @SampleID
			WHERE idfMaterial = @RowID;

			UPDATE @LabTestsTemp
			SET idfMaterial = @SampleID
			WHERE strFieldBarcode = @EIDSSLocalOrFieldSampleID;

			DELETE
			FROM @SamplesTemp
			WHERE idfMaterial = @RowID;
		END;

		WHILE EXISTS (
				SELECT *
				FROM @PensideTestsTemp
				)
		BEGIN
			SELECT TOP 1 @RowId = idfPensideTest,
				@EIDSSLocalOrFieldSampleID = strFieldBarCode,
				@SampleID = idfMaterial,
				@PensideTestResultTypeID = idfsPensideTestResult,
				@PensideTestNameTypeID = idfsPensideTestName,
				@RowStatus = intRowStatus,
				@TestedByPersonID = NULL,
				@TestedByOrganizationID = NULL,
				@DiseaseID = NULL,
				@TestDate = NULL,
				@PensideTestCategoryTypeID = NULL,
				@RowAction = RowAction
			FROM @PensideTestsTemp;

			IF @RowId < 0
			BEGIN
				SET @RowAction = 'I'
			END

			IF @RowAction = 'D'
			BEGIN
				UPDATE dbo.tlbPensideTest
				SET intRowStatus = 1
				WHERE idfPensideTest = @RowId
			END
			ELSE
			BEGIN
				INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_VET_PENSIDE_TEST_SET 
					@AuditUser = @User,
					@PensideTestID = @PensideTestID OUTPUT,
					@SampleID = @SampleID,
					@PensideTestResultTypeID = @PensideTestResultTypeID,
					@PensideTestNameTypeID = @PensideTestNameTypeID,
					@TestedByPersonID = @TestedByPersonID,
					@TestedByOrganizationID = @TestedByOrganizationID,
					@DiseaseID = @DiseaseID,
					@TestDate = @TestDate,
					@PensideTestCategoryTypeID = @PensideTestCategoryTypeID,
					@RowStatus = @RowStatus,
					@RowAction = @RowAction;
			END

			DELETE
			FROM @PensideTestsTemp
			WHERE idfPensideTest = @RowID;
		END;

		WHILE EXISTS (
				SELECT *
				FROM @LabTestsTemp
				)
		BEGIN
			SELECT TOP 1 @RowId = idfTesting,
				@idfTesting = idfTesting,
				@idfsTestName = idfsTestName,
				@idfsTestCategory = idfsTestCategory,
				@idfsTestResult = idfsTestResult,
				@idfsTestStatus = idfsTestStatus,
				@idfsDiagnosis = idfsDiagnosis,
				@idfMaterial = idfMaterial,
				@datConcludedDate = CONVERT(DATETIME, datConcludedDate),
				@intRowStatus = intRowStatus,
				@RowAction = RowAction
			FROM @LabTestsTemp

			IF @RowId < 0
			BEGIN
				SET @RowAction = 'I'
			END

			INSERT INTO @SupressSelect
			EXECUTE dbo.USSP_OMM_VET_TEST_SET 
				@idfTesting = @idfTesting OUTPUT,
				@idfsTestName = @idfsTestName,
				@idfsTestCategory = @idfsTestCategory,
				@idfsTestResult = @idfsTestResult,
				@idfsTestStatus = @idfsTestStatus,
				@idfsDiagnosis = @idfsDiagnosis,
				@idfMaterial = @idfMaterial,
				@datConcludedDate = @datConcludedDate,
				@intRowStatus = @intRowStatus,
				@RowAction = @RowAction,
				@User = @User

			DELETE
			FROM @LabTestsTemp
			WHERE idfTesting = @RowID;
		END;

		EXEC USSP_OMM_CASE_MONITORING_SET @CaseMonitorings = @CaseMonitorings, @idfVetCase = @VeterinaryDiseaseReportID

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

		SELECT @ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage,
			@VeterinaryDiseaseReportID VeterinaryDiseaseReportID,
			@strOutbreakCaseID EIDSSReportID,
			@OutbreakID idfOutbreak;
	END TRY

	BEGIN CATCH
		IF @@Trancount > 0
			ROLLBACK TRANSACTION;

		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage,
			@VeterinaryDiseaseReportID VeterinaryDiseaseReportID,
			@strOutbreakCaseID EIDSSReportID,
			@OutbreakID idfOutbreak;

		THROW;
	END CATCH
END
