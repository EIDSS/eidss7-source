

--*************************************************************
-- Name 				:	USP_HUM_HUMAN_DISEASE_SET_DEDUP
-- Description			:	Insert OR UPDATE human disease record
--          
-- Author               :	Mandar Kulkarni
-- Revision History
--	Name			Date		Change Detail
-- TEST

--	Testing code:
--  exec USP_HUM_HUMAN_DISEASE_SET_DEDUP  null, 27, null, '(new)',784050000000
CREATE  PROCEDURE [dbo].[USP_HUM_HUMAN_DISEASE_SET_DEDUP]
(
	--@SupersededHumanDiseaseID			BIGINT,
	@LanguageID								NVARCHAR(50),
	@idfHumanCase							BIGINT = NULL , -- tlbHumanCase.idfHumanCase Primary Key
	@idfHumanCaseRelatedTo         			BIGINT = NULL,
	@idfHuman								BIGINT = NULL, -- tlbHumanCase.idfHuman
	@idfHumanActual							BIGINT, -- tlbHumanActual.idfHumanActual
	@strHumanCaseId							NVARCHAR(200) = '(new)',
	@idfsFinalDiagnosis						BIGINT, -- tlbhumancase.idfsTentativeDiagnosis/idfsFinalDiagnosis
	@datDateOfDiagnosis						DATETIME = NULL, --tlbHumanCase.datTentativeDiagnosisDate/datFinalDiagnosisDate
	@datNotificationDate					DATETIME = NULL, --tlbHumanCase.DatNotIFicationDate
	@idfsFinalState							BIGINT = NULL, --tlbHumanCase.idfsFinalState
	@strLocalIdentifier            			NVARCHAR(200)=NULL,

	@idfSentByOffice						BIGINT = NULL, -- tlbHumanCase.idfSentByOffice
	@strSentByFirstName						NVARCHAR(200)= NULL,--tlbHumanCase.strSentByFirstName
	@strSentByPatronymicName				NVARCHAR(200)= NULL, --tlbHumancase.strSentByPatronymicName
	@strSentByLastName						NVARCHAR(200)= NULL, --tlbHumanCase.strSentByLastName
	@idfSentByPerson						BIGINT = NULL, --tlbHumcanCase.idfSentByPerson

	@idfReceivedByOffice					BIGINT = NULL,-- tlbHumanCase.idfReceivedByOffice
	@strReceivedByFirstName					NVARCHAR(200)= NULL, --tlbHumanCase.strReceivedByFirstName
	@strReceivedByPatronymicName			NVARCHAR(200)= NULL, --tlbHumanCase.strReceivedByPatronymicName
	@strReceivedByLastName					NVARCHAR(200)= NULL, --tlbHuanCase.strReceivedByLastName
	@idfReceivedByPerson					BIGINT = NULL, -- tlbHumanCase.idfReceivedByPerson

	@idfsHospitalizationStatus				BIGINT = NULL,  -- tlbHumanCase.idfsHospitalizationStatus
	@idfHospital							BIGINT = NULL, -- tlbHumanCase.idfHospital
	@strCurrentLocation						NVARCHAR(200)= NULL, -- tlbHumanCase.strCurrentLocation
	@datOnSetDate							DATETIME = NULL,	-- tlbHumanCase.datOnSetDate
	--@idfsInitialCaseClassification		BIGINT = NULL, -- tlbHumanCase.idfsInitialCaseStatus 
	@idfsInitialCaseStatus					BIGINT = NULL, -- tlbHumanCase.idfsInitialCaseStatus
	--@strComments							NVARCHAR(MAX)= NULL, --strClinicalNotes
	@idfsYNPreviouslySoughtCare				BIGINT = NULL,	--idfsYNPreviouslySoughtCare
	@datFirstSoughtCareDate					DATETIME = NULL, --tlbHumanCase.datFirstSoughtCareDate

	@idfSoughtCareFacility					BIGINT = NULL, --tlbHumanCase.idfSoughtCareFacility
	@idfsNonNotIFiableDiagnosis				BIGINT = NULL,	--tlbHumanCase.idfsNonNotIFiableDiagnosis
	@idfsYNHospitalization					BIGINT = NULL, -- tlbHumanCase.idfsYNHospitalization
	@datHospitalizationDate					DATETIME = NULL,  --tlbHumanCase.datHospitalizationDate 
	@datDischargeDate						DATETIME = NULL,	-- tlbHumanCase.datDischargeDate
	@strHospitalName						NVARCHAR(200)= NULL, --tlbHumanCase.strHospitalizationPlace  
	@idfsYNAntimicrobialTherapy				BIGINT = NULL, --  tlbHumanCase.idfsYNAntimicrobialTherapy 
	@strAntibioticName						NVARCHAR(200)= NULL, -- tlbHumanCase.strAntimicrobialTherapyName
	@strDosage								NVARCHAR(200)= NULL, --tlbHumanCase.strDosage
	--(idfs		)DoseMeasurements			BIGINT, --??
	@datFirstAdministeredDate				DATETIME = NULL, -- tlbHumanCase.datFirstAdministeredDate
	@strAntibioticComments					NVARCHAR(MAX)= NULL, -- tlbHumanCase.strClinicalNotes , or strSummaryNotes
	@idfsYNSpecIFicVaccinationAdministered	BIGINT = NULL, --  tlbHumanCase.idfsYNSpecIFicVaccinationAdministered
	--@VaccinationName						NVARCHAR(200) = NULL,  --tlbHumanCase.VaccinationName
	--@VaccinationDate						DATETIME = NULL, --tlbHumanCase.VaccinationDate
	@idfInvestigatedByOffice				BIGINT = NULL, -- tlbHumanCase.idfInvestigatedByOffice 
	@StartDateofInvestigation				DATETIME = NULL, -- tlbHumanCase.datInvestigationStartDate
	@idfsYNRelatedToOutbreak				BIGINT = NULL, -- tlbHumanCase.idfsYNRelatedToOutbreak
	@idfOutbreak							BIGINT = NULL, --idfOutbreak  
	@idfsYNExposureLocationKnown			BIGINT = NULL, --tlbHumanCase.idfsYNExposureLocationKnown
	@idfPointGeoLocation					BIGINT = NULL, --tlbHumanCase.idfPointGeoLocation
	@datExposureDate						DATETIME = NULL, -- tlbHumanCase.datExposureDate 
	@idfsGeoLocationType					BIGINT = NULL, --tlbGeolocation.idfsGeoLocationType
	@strLocationDescription					NVARCHAR(MAX) = NULL, --tlbGeolocation.Description
	@idfsLocationCountry					BIGINT = NULL, --tlbGeolocation.idfsCountry 
	@idfsLocationRegion						BIGINT = NULL, --tlbGeolocation.idfsRegion
	@idfsLocationRayon						BIGINT = NULL,--tlbGeolocation.idfsRayon
	@idfsLocationSettlement					BIGINT = NULL,--tlbGeolocation.idfsSettlement
	@intLocationLatitude					FLOAT = NULL, --tlbGeolocation.Latittude
	@intLocationLongitude					FLOAT = NULL,--tlbGeolocation.Longitude
	@intElevation                  			BIGINT = NULL,--GISSettlement.intElevation
	@idfsLocationGroundType					BIGINT = NULL, --tlbGeolocation.GroundType
	@intLocationDistance					FLOAT = NULL, --tlbGeolocation.Distance
	@intLocationDirection          			FLOAT = NULL, --tlbGeolocation.Alignment	
	@strForeignAddress             			NVARCHAR(MAX) = NULL, --tlbGeolocation.strForeignAddress 
	@strNote								NVARCHAR(MAX)=NULL, --tlbhumancase.strNote
	--@idfsFinalClassIFication				BIGINT = NULL, --tlbHuanCase.idfsFinalCaseStatus
	@idfsFinalCaseStatus					BIGINT = NULL, --tlbHuanCase.idfsFinalCaseStatus 
	@idfsOutcome							BIGINT = NULL, -- --tlbHumanCase.idfsOutcome 
	@datDateofDeath							DATETIME = NULL, -- tlbHumanCase.datDateOfDeath 
	@idfsCaseProgressStatus					BIGINT = 10109001,	--	tlbHumanCase.reportStatus, default = In-process
	@idfPersonEnteredBy						BIGINT = NULL,
	@strClinicalNotes						NVARCHAR(2000) = NULL,
	@idfsYNSpecimenCollected				BIGINT = NULL,
	@idfsYNTestsConducted					BIGINT = NULL,
	@DiseaseReportTypeID					BIGINT = NULL, 
	@blnClinicalDiagBasis          			BIT = NULL,
	@blnLabDiagBasis						BIT = NULL,
	@blnEpiDiagBasis						BIT = NULL,
	@DateofClassification					DATETIME = NULL,
	@strSummaryNotes						NVARCHAR(MAX) = NULL,
	@idfEpiObservation						BIGINT = NULL,
	@idfCSObservation						BIGINT = NULL,
	@idfInvestigatedByPerson				BIGINT =NULL,
	@strEpidemiologistsName        			NVARCHAR(MAX) = NULL,
	@idfsNotCollectedReason					BIGINT = NULL,
	@strNotCollectedReason         			NVARCHAR(200)= NULL,
	@SamplesParameters						NVARCHAR(MAX) = NULL,
	@TestsParameters						NVARCHAR(MAX) = NULL,
	@TestsInterpretationParameters			NVARCHAR(MAX) = NULL,
	@AntiviralTherapiesParameters			NVARCHAR(MAX) = NULL,
	@VaccinationsParameters					NVARCHAR(MAX) = NULL,
	@ContactsParameters						NVARCHAR(MAX) = NULL,
	@Notifications							NVARCHAR(MAX) = NULL,
	@idfsHumanAgeType						BIGINT = NULL,
	@intPatientAge							INT = NULL,
	@datCompletionPaperFormDate				DATETIME =NULL,
	@RowStatus								INT,
	@idfsSite								BIGINT = NULL,
	@AuditUser								NVARCHAR(100) = '',
	@idfParentMonitoringSession				BIGINT = NULL

 --@Samples						tlbHdrMaterialGetListSPType READONLY, 
 --@Tests							tlbHdrTestGetListSPType READONLY
 --, 
 --@Contacts						tlbHdrContactGetListSPType READONLY

)
AS
DECLARE @returnCode					INT = 0 
DECLARE	@returnMsg					NVARCHAR(MAX) = 'SUCCESS' 
DECLARE @RowID BIGINT = NULL
,@RowAction NCHAR = NULL
,@OrderNumber INT
,@SampleID BIGINT
,@SampleTypeID BIGINT = NULL
,@HumanID BIGINT
,@HumanMasterID BIGINT = NULL
,@CollectedByPersonID BIGINT = NULL
,@CollectedByOrganizationID BIGINT = NULL
,@CollectionDate DATETIME = NULL
,@SentDate DATETIME = NULL
,@EIDSSLocalOrFieldSampleID NVARCHAR(200) = NULL
,@SampleStatusTypeID BIGINT = NULL
,@EIDSSLaboratorySampleID NVARCHAR(200) = NULL
,@SentToOrganizationID BIGINT = NULL
,@ReadOnlyIndicator BIT = NULL
,@AccessionDate DATETIME = NULL
,@AccessionConditionTypeID BIGINT = NULL
,@AccessionComment NVARCHAR(200) = NULL
,@AccessionByPersonID BIGINT = NULL
,@CurrentSiteID BIGINT = NULL
,@TestID BIGINT
,@TestNameTypeID BIGINT = NULL
,@TestCategoryTypeID BIGINT = NULL
,@TestResultTypeID BIGINT = NULL
,@TestStatusTypeID BIGINT
,@BatchTestID BIGINT = NULL
,@TestNumber INT = NULL
,@StartedDate DATETIME2 = NULL
,@ResultDate DATETIME2 = NULL
,@TestedByPersonID BIGINT = NULL
,@TestedByOrganizationID BIGINT = NULL
,@ResultEnteredByOrganizationID BIGINT = NULL
,@ResultEnteredByPersonID BIGINT = NULL
,@ValidatedByOrganizationID BIGINT = NULL
,@ValidatedByPersonID BIGINT = NULL
,@NonLaboratoryTestIndicator BIT
,@ExternalTestIndicator BIT = NULL
,@PerformedByOrganizationID BIGINT = NULL
,@ReceivedDate DATETIME2 = NULL
,@ContactPersonName NVARCHAR(200) = NULL
,@TestHumanCaseID BIGINT = NULL
,@TestInterpretationID BIGINT
,@InterpretedStatusTypeID BIGINT = NULL
,@InterpretedByOrganizationID BIGINT = NULL
,@InterpretedByPersonID BIGINT = NULL
,@TestingInterpretations BIGINT
,@ValidatedStatusIndicator BIT = NULL
,@ReportSessionCreatedIndicator BIT = NULL
,@ValidatedComment NVARCHAR(200) = NULL
,@InterpretedComment NVARCHAR(200) = NULL
,@ValidatedDate DATETIME = NULL
,@InterpretedDate DATETIME = NULL
,@NotificationID BIGINT
,@NotificationObjectTypeID BIGINT = NULL
,@NotificationTypeID BIGINT = NULL
,@TargetSiteTypeID BIGINT = NULL
,@NotificationObjectID BIGINT = NULL
,@TargetUserID BIGINT = NULL
,@TargetSiteID BIGINT = NULL
,@Payload NVARCHAR(MAX) = NULL
,@LoginSite NVARCHAR(20) = NULL
,@MonitoringSessionActionID BIGINT
,@ActionTypeID BIGINT
,@ActionStatusTypeID BIGINT
,@ActionDate DATETIME = NULL
,@Comments NVARCHAR(500) = NULL
,@DiseaseID BIGINT
,@idfMonitoringSessionToDiagnosis BIGINT
,@DateEntered DATETIME = GETDATE()


SET @AuditUser = ISNULL(@AuditUser, '')

DECLARE @SamplesTemp TABLE (
	SampleID BIGINT NOT NULL
	,SampleTypeID BIGINT NULL
	,SampleStatusTypeID BIGINT NULL
	,CollectionDate DATETIME2 NULL
	,CollectedByOrganizationID BIGINT NULL
	,CollectedByPersonID BIGINT NULL
	,SentDate DATETIME2 NULL
	,SentToOrganizationID BIGINT NULL
	,EIDSSLocalOrFieldSampleID NVARCHAR(200) NULL
	,Comments NVARCHAR(200) NULL
	,SiteID BIGINT NOT NULL
	,CurrentSiteID BIGINT NULL
	,DiseaseID BIGINT NULL
	,ReadOnlyIndicator BIT NULL
	,HumanID BIGINT NULL
	,HumanMasterID BIGINT NULL
	,RowStatus INT NOT NULL
	,RowAction CHAR(1) NULL
	);

DECLARE @TestsTemp TABLE (
	TestID BIGINT NOT NULL
	,TestNameTypeID BIGINT NULL
	,TestCategoryTypeID BIGINT NULL
	,TestResultTypeID BIGINT NULL
	,TestStatusTypeID BIGINT NOT NULL
	,DiseaseID BIGINT NULL
	,SampleID BIGINT NULL
	,BatchTestID BIGINT NULL
	,ObservationID BIGINT NULL
	,TestNumber INT NULL
	,Comments NVARCHAR NULL
	,StartedDate DATETIME2 NULL
	,ResultDate DATETIME2 NULL
	,TestedByOrganizationID BIGINT NULL
	,TestedByPersonID BIGINT NULL
	,ResultEnteredByOrganizationID BIGINT NULL
	,ResultEnteredByPersonID BIGINT NULL
	,ValidatedByOrganizationID BIGINT NULL
	,ValidatedByPersonID BIGINT NULL
	,ReadOnlyIndicator BIT NOT NULL
	,NonLaboratoryTestIndicator BIT NOT NULL
	,ExternalTestIndicator BIT NULL
	,PerformedByOrganizationID BIGINT NULL
	,ReceivedDate DATETIME2 NULL
	,ContactPersonName NVARCHAR(200) NULL
	,RowStatus INT NOT NULL
	,RowAction CHAR(1) NULL
	);

DECLARE @TestsInterpretationParametersTemp TABLE
(
    TestInterpretationID BIGINT NOT NULL,
    DiseaseID BIGINT NULL,
    InterpretedStatusTypeID BIGINT NULL,
    ValidatedByOrganizationID BIGINT NULL,
    ValidatedByPersonID BIGINT NULL,
    InterpretedByOrganizationID BIGINT NULL,
    InterpretedByPersonID BIGINT NULL,
    TestID BIGINT NOT NULL,
    ValidatedStatusIndicator BIT NULL,
    ReportSessionCreatedIndicator BIT NULL,
    ValidatedComment NVARCHAR(200) NULL,
    InterpretedComment NVARCHAR(200) NULL,
    ValidatedDate DATETIME NULL,
    InterpretedDate DATETIME NULL,
    ReadOnlyIndicator BIT NOT NULL,
    RowStatus INT NOT NULL,
    RowAction INT NULL
);
DECLARE @NotificationsTemp TABLE
(
    NotificationID BIGINT NOT NULL,
    NotificationTypeID BIGINT NULL,
    UserID BIGINT NULL,
    NotificationObjectID BIGINT NULL,
    NotificationObjectTypeID BIGINT NULL,
    TargetUserID BIGINT NULL,
    TargetSiteID BIGINT NULL,
    TargetSiteTypeID BIGINT NULL,
    SiteID BIGINT NULL,
    Payload NVARCHAR(MAX) NULL,
    LoginSite NVARCHAR(20) NULL
);
DECLARE @SuppressSelect TABLE (
	ReturnCode INT
	,ReturnMessage VARCHAR(200)
);

BEGIN
	BEGIN TRY
		SET @SamplesParameters = REPLACE(@SamplesParameters, '"0001-01-01T00:00:00"', 'null')

		INSERT INTO @SamplesTemp
		SELECT *
 		FROM OPENJSON(@SamplesParameters) WITH (
				SampleID BIGINT
				,SampleTypeID BIGINT
				,SampleStatusTypeID BIGINT
				,CollectionDate DATETIME2
				,CollectedByOrganizationID BIGINT
				,CollectedByPersonID BIGINT
				,SentDate DATETIME2
				,SentToOrganizationID BIGINT
				,EIDSSLocalOrFieldSampleID NVARCHAR(200)
				,Comments NVARCHAR(200)
				,SiteID BIGINT
				,CurrentSiteID BIGINT
				,DiseaseID BIGINT
				,ReadOnlyIndicator BIT
				,HumanID BIGINT
				,HumanMasterID BIGINT
				,RowStatus INT
				,RowAction CHAR(1)
				);

		SET @TestsParameters = REPLACE(@TestsParameters, '"0001-01-01T00:00:00"', 'null')
		
		INSERT INTO @TestsTemp
		SELECT *
		FROM OPENJSON(@TestsParameters) WITH (
				TestID BIGINT
				,TestNameTypeID BIGINT
				,TestCategoryTypeID BIGINT
				,TestResultTypeID BIGINT
				,TestStatusTypeID BIGINT
				,DiseaseID BIGINT
				,SampleID BIGINT
				,BatchTestID BIGINT
				,ObservationID BIGINT
				,TestNumber INT
				,Comments NVARCHAR(500)
				,StartedDate DATETIME2
				,ResultDate DATETIME2
				,TestedByOrganizationID BIGINT
				,TestedByPersonID BIGINT
				,ResultEnteredByOrganizationID BIGINT
				,ResultEnteredByPersonID BIGINT
				,ValidatedByOrganizationID BIGINT
				,ValidatedByPersonID BIGINT
				,ReadOnlyIndicator BIT
				,NonLaboratoryTestIndicator BIT
				,ExternalTestIndicator BIT
				,PerformedByOrganizationID BIGINT
				,ReceivedDate DATETIME2
				,ContactPersonName NVARCHAR(200)
				,RowStatus INT
				,RowAction CHAR(1)
				);
		


        INSERT INTO @TestsInterpretationParametersTemp
        SELECT *
        FROM
            OPENJSON(@TestsInterpretationParameters)
            WITH
            (
                TestInterpretationID BIGINT,
                DiseaseID BIGINT,
                InterpretedStatusTypeID BIGINT,
                ValidatedByOrganizationID BIGINT,
                ValidatedByPersonID BIGINT,
                InterpretedByOrganizationID BIGINT,
                InterpretedByPersonID BIGINT,
                TestID BIGINT,
                ValidatedStatusIndicator BIT,
                ReportSessionCreatedIndicator BIT,
                ValidatedComment NVARCHAR(200),
                InterpretedComment NVARCHAR(200),
                ValidatedDate DATETIME2,
                InterpretedDate DATETIME2,
                ReadOnlyIndicator BIT,
                RowStatus INT,
                RowAction INT
            );

			INSERT INTO @NotificationsTemp
        SELECT *
        FROM
            OPENJSON(@Notifications)
            WITH
            (
                NotificationID BIGINT,
                NotificationTypeID BIGINT,
                UserID BIGINT,
                NotificationObjectID BIGINT,
                NotificationObjectTypeID BIGINT,
                TargetUserID BIGINT,
                TargetSiteID BIGINT,
                TargetSiteTypeID BIGINT,
                SiteID BIGINT,
                Payload NVARCHAR(MAX),
                LoginSite BIGINT
            );
			
		BEGIN TRANSACTION
		
			DECLARE @SupressSELECT TABLE
			( retrunCode INT,
			  returnMessage VARCHAR(200)
			)
			DECLARE @SupressSELECTHumanCase TABLE
			( retrunCode INT,
			  returnMessage VARCHAR(200)--,
			 -- idfHumanCase BIGINT
			)
			DECLARE @SupressSELECTHuman TABLE
			( 
			retrunCode INT,
			  returnMessage VARCHAR(200),
			  idfHuman BIGINT
			)
			
			DECLARE @SupressSELECTGeoLocation TABLE
			( returnCode INT,
			  returnMsg VARCHAR(200),
			  idfGeoLocation BIGINT
			)


			SET @DiseaseID = @idfsFinalDiagnosis

			DECLARE @HumanDiseasereportRelnUID BIGINT
			 
			DECLARE @COPYHUMANACTUALTOHUMAN_ReturnCode INT = 0

			-- Create a human record FROM Human Actual if not already present
			IF @idfHumanActual IS NOT NULL-- AND @idfHumanCase IS  NULL
				BEGIN
				--INSERT INTO @SuppressSelect
				INSERT INTO		@SupressSELECTHumanCase
				EXEC USP_HUM_COPYHUMANACTUALTOHUMAN @idfHumanActual, @idfHuman OUTPUT, @returnCode OUTPUT, @returnMsg OUTPUT
				--SET @COPYHUMANACTUALTOHUMAN_ReturnCode = dbo.FN_COPYHUMANACTUALTOHUMAN(@idfHumanActual, @idfHuman)
					IF @returnCode <> 0 
						BEGIN
							--SELECT @returnCode, @returnMsg
							RETURN
						END
				END

			--TODO: Needs to be refactored to use Hierarchy
			-- Insert or update geolocation record if any of the information is provided
			IF	@idfsLocationGroundType IS NOT NULL OR @idfsGeoLocationType IS NOT NULL OR
				@idfsLocationCountry IS NOT NULL OR @idfsLocationRegion IS NOT NULL OR
				@idfsLocationRayon IS NOT NULL OR @idfsLocationSettlement IS NOT NULL OR
				@strLocationDescription IS NOT NULL OR @intLocationLatitude IS NOT NULL OR
				@intLocationLongitude IS NOT NULL OR  @intLocationDistance IS NOT NULL OR
				@intLocationDirection IS NOT NULL OR @strForeignAddress IS NOT NULL OR
				@intElevation IS NOT NULL
			BEGIN
				-- Set geo location 
				IF @idfPointGeoLocation IS NULL
					BEGIN
						INSERT INTO @SupressSELECT
								EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation', @idfPointGeoLocation OUTPUT
					END

				BEGIN
					INSERT INTO @SupressSELECTGeoLocation
					EXECUTE [dbo].[USP_HUMAN_DISEASE_GEOLOCATION_SET]
												@idfPointGeoLocation ,
												@idfsLocationGroundType,
												@idfsGeoLocationType,
												@idfsLocationCountry,
												@idfsLocationRegion,
												@idfsLocationRayon,
												@idfsLocationSettlement,
												@strLocationDescription,
												@intLocationLatitude,
												@intLocationLongitude,
												NULL,
												@intLocationDistance,
												@intLocationDirection,
												@strForeignAddress,
												1,
												@intElevation,
												@AuditUser
				END	
			END
--			SET @idfPointGeoLocation =(SELECT idfGeoLocation FROM @SupressSELECTGeoLocation) 

			IF NOT EXISTS (SELECT idfHumanCase FROM dbo.tlbHumanCase WHERE idfHumanCase = @idfHumanCase AND	intRowStatus = 0)
				BEGIN
					-- Get next key value
						INSERT INTO @SupressSELECT
						EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbHumanCase', @idfHumanCase OUTPUT

					-- Create a stringId for Human Case
					IF LEFT(ISNULL(@strHumanCaseID, '(new'),4) = '(new'
					BEGIN
						INSERT INTO @SupressSELECT
						EXEC dbo.USP_GBL_NextNumber_GET 'Human Disease Report', @strHumanCaseID OUTPUT , NULL --N'AS Session'
					END

					INSERT 
					INTO	tlbHumanCase
							(
							 idfHumanCase,		
							 idfHuman,
							 strCaseId,				
							 idfsFinalDiagnosis,
							 datTentativeDiagnosisDate,
							 datNotIFicationDate,			
							 idfsFinalState,
							 strLocalIdentifier,
							 idfSentByOffice,	
							 strSentByFirstName,	
							 strSentByPatronymicName,	
							 strSentByLastName,	
							 idfSentByPerson,
							 idfReceivedByOffice,	
							 strReceivedByFirstName,	
							 strReceivedByPatronymicName,	
							 strReceivedByLastName,	
							 idfReceivedByPerson,
							 idfsHospitalizationStatus,		
							 idfHospital,				
							 strCurrentLocation,				
							 datOnSetDate,			
							 idfsInitialCaseStatus ,	
							 idfsYNPreviouslySoughtCare,	
							 datFirstSoughtCareDate,		
							 idfSoughtCareFacility,			
							 idfsNonNotIFiableDiagnosis,	
							 idfsYNHospitalization,			
							 datHospitalizationDate,		
							 datDischargeDate,			
							 strHospitalizationPlace ,				
							 idfsYNAntimicrobialTherapy,	
							 strClinicalNotes,			
							 idfsYNSpecIFicVaccinationAdministered,
							 idfInvestigatedByOffice,	
							 datInvestigationStartDate,
							 idfsYNRelatedToOutbreak,	
							 idfOutbreak,					
							 idfPointGeoLocation,
							 idfsYNExposureLocationKnown,
							 datExposureDate,	
							 strNote,
							 idfsFinalCaseStatus,	
							 idfsOutcome,					
							 intRowStatus,
							 idfsCaseProgressStatus,
							 datModificationDate,
							 datEnteredDate,
							 idfPersonEnteredBy,
							 idfsYNSpecimenCollected,
							 idfsYNTestsConducted,
							 DiseaseReportTypeID,
							 blnClinicalDiagBasis,
							 blnLabDiagBasis,
							 blnEpiDiagBasis,
							 datFinalCaseClassificationDate,	
							 strsummarynotes,
							 idfEpiObservation,	
							 idfCSObservation,
							 idfInvestigatedByPerson,
							 strEpidemiologistsName,
							 idfsNotCollectedReason,
							 strNotCollectedReason,
							 idfsHumanAgeType,
							 intPatientAge,
							 datCompletionPaperFormDate,
							 idfsSite,
							 AuditCreateUser,
							 idfParentMonitoringSession
							 --datDateOfDeath,
							--@strCaseInvestigationOutbreakID, 
							--VaccinationName,
							--VaccinationDate,
							--@strComments,	
							)
					VALUES (
							 @idfHumanCase,
							 @idfHuman,		
							 @strHumanCaseId,				
							 @idfsFinalDiagnosis,					
							 @datDateOfDiagnosis,
							 @datNotificationDate,			
							 @idfsFinalState,
							 @strLocalIdentifier,
							 @idfSentByOffice,	
							 @strSentByFirstName,	
							 @strSentByPatronymicName,	
							 @strSentByLastName,	
							 @idfSentByPerson,	
							 @idfReceivedByOffice,	
							 @strReceivedByFirstName,	
							 @strReceivedByPatronymicName,	
							 @strReceivedByLastName,	
							 @idfReceivedByPerson,
							 @idfsHospitalizationStatus,		
							 @idfHospital,				
							 @strCurrentLocation,				
							 @datOnSetDate,			
							 @idfsInitialCaseStatus,	
							 @idfsYNPreviouslySoughtCare,	
							 @datFirstSoughtCareDate,		
							 @idfSoughtCareFacility,			
							 @idfsNonNotIFiableDiagnosis,	
							 @idfsYNHospitalization,			
							 @datHospitalizationDate,		
							 @datDischargeDate,			
							 @strHospitalName,	
							 @idfsYNAntimicrobialTherapy,			
							 @strClinicalNotes,			
							 @idfsYNSpecIFicVaccinationAdministered,
							 @idfInvestigatedByOffice,	
							 @StartDateofInvestigation ,
							 @idfsYNRelatedToOutbreak,	
							 @idfOutbreak,					
							 @idfPointGeoLocation,
							 @idfsYNExposureLocationKnown,
							 @datExposureDate,	
							 @strNote,
							 @idfsFinalCaseStatus,
							 @idfsOutcome,					
							 0,
							 @idfsCaseProgressStatus,
							 GETDATE(),			--datModificationDate	
							 GETDATE(),			--datEnteredDate		
							 @idfPersonEnteredBy,
							 @idfsYNSpecimenCollected,
							 @idfsYNTestsConducted,
							 @DiseaseReportTypeID,
							 @blnClinicalDiagBasis,
							 @blnLabDiagBasis,
							 @blnEpiDiagBasis,
							 @DateofClassification,
							 @strSummaryNotes,
							 @idfEpiObservation,
							 @idfCSObservation,
							 @idfInvestigatedByPerson,
							 @strEpidemiologistsName,
							 @idfsNotCollectedReason,
							 @strNotCollectedReason,
							 @idfsHumanAgeType,
							 @intPatientAge,
							 @datCompletionPaperFormDate,
							 @idfsSite,
							 @AuditUser,
							 @idfParentMonitoringSession
							--@datDateofDeath,
							--@idfsFinalClassIFication,
							--@strCaseInvestigationOutbreakID,
							--@VaccinationName,
							--@VaccinationDate, 
							--@strComments,
							--@idfsInitialCaseClassIFication,
							)

					DECLARE @RelatedToRoot BIGINT
				

					IF @idfHumanCaseRelatedTo IS NOT NULL
					BEGIN

					--EStablish the Root
						IF NOT EXISTS (SELECT * FROM HumanDiseaseReportRelationship WHERE (HumanDiseaseReportID = @idfHumanCaseRelatedTo) AND (RelatedToHumanDiseaseReportIdRoot IS NOT NULL)AND(intRowStatus =0))
						BEGIN
							SET @RelatedToRoot =  @idfHumanCaseRelatedTo
						END
					ELSE
						BEGIN
						SELECT @RelatedToRoot =  RelatedToHumanDiseaseReportIdRoot FROM HumanDiseaseReportRelationship WHERE (HumanDiseaseReportID = @idfHumanCaseRelatedTo) AND (RelatedToHumanDiseaseReportIdRoot IS NOT NULL) AND (intRowStatus =0)
						END
					--End establishing the Root

					    INSERT INTO @SupressSELECT
						EXEC dbo.USP_GBL_NEXTKEYID_GET 'HumanDiseaseReportRelationship', @HumanDiseasereportRelnUID OUTPUT;

						INSERT
						INTO HumanDiseaseReportRelationship
							(
								HumanDiseasereportRelnUID,
								HumanDiseaseReportID,
								RelateToHumanDiseaseReportID,
								RelatedToHumanDiseaseReportIdRoot,
								RelationshipTypeID,
								intRowStatus,
								AuditCreateUser,
								AuditCreateDTM,
								rowguid
							)
                         VALUES
							 (
								 @HumanDiseasereportRelnUID,
								 @idfHumanCase,
								 @idfHumanCaseRelatedTo,
								 @RelatedToRoot,
								 10503001, --Linked Copy Parent
								 0,
								 @AuditUser,
								 GETDATE(),
								 NEWID()
							 )
						END
				END
			ELSE
				BEGIN
					UPDATE dbo.tlbHumanCase
					SET							
							strCaseId =  @strHumanCaseId,
							idfsTentativeDiagnosis =  @idfsFinalDiagnosis,
							idfsFinalDiagnosis =  @idfsFinalDiagnosis,
							datTentativeDiagnosisDate =  @datDateOfDiagnosis,
							datFinalDiagnosisDate =  @datDateOfDiagnosis,
							datNotIFicationDate =  @datNotificationDate,
							idfsFinalState=  @idfsFinalState,

							idfSentByOffice =  @idfSentByOffice,
							strSentByFirstName =  @strSentByFirstName,
							strSentByPatronymicName =  @strSentByPatronymicName,
							strSentByLastName =  @strSentByLastName,
							--idfSentByPerson =  @idfSentByPerson,
							idfSentByPerson = @idfSentByPerson,

							idfReceivedByOffice =  @idfReceivedByOffice,
							strReceivedByFirstName =  @strReceivedByFirstName,
							strReceivedByPatronymicName =  @strReceivedByPatronymicName,
							strReceivedByLastName =  @strReceivedByLastName,
							--idfRecdByPerson =  @idfRecdByPerson,
							idfReceivedByPerson = @idfReceivedByPerson,
							strLocalIdentifier=@strLocalIdentifier,
							idfsHospitalizationStatus =  @idfsHospitalizationStatus,
							idfHospital =  @idfHospital,
							strCurrentLocation =  @strCurrentLocation,
							datOnSetDate =  @datOnSetDate,
							idfsInitialCaseStatus  =  @idfsInitialCaseStatus,	
							--@strComments =  --@strComments,
							idfsYNPreviouslySoughtCare = @idfsYNPreviouslySoughtCare,
							datFirstSoughtCareDate =  @datFirstSoughtCareDate,
							idfSoughtCareFacility =  @idfSoughtCareFacility	,
							idfsNonNotIFiableDiagnosis =  @idfsNonNotIFiableDiagnosis,
							idfsYNHospitalization =  @idfsYNHospitalization,
							datHospitalizationDate  =  @datHospitalizationDate,
							datDischargeDate =  @datDischargeDate,
							strHospitalizationPlace  =  @strHospitalName,
							idfsYNAntimicrobialTherapy =  @idfsYNAntimicrobialTherapy,
							--strClinicalNotes =  @strAntibioticComments,
							--strClinicalNotes = @strClinicalNotes + ' ' + @strAntibioticComments,
							strClinicalNotes=@strClinicalNotes,
							--VaccinationName = @VaccinationName,
							--VaccinationDate = @VaccinationDate,
							idfsYNSpecIFicVaccinationAdministered = @idfsYNSpecIFicVaccinationAdministered,
							idfInvestigatedByOffice =  @idfInvestigatedByOffice,
							datInvestigationStartDate = @StartDateofInvestigation, 
							idfsYNRelatedToOutbreak = @idfsYNRelatedToOutbreak,
							idfOutbreak =  @idfOutbreak,
							idfsYNExposureLocationKnown = @idfsYNExposureLocationKnown,
							idfPointGeoLocation =  @idfPointGeoLocation,
							datExposureDate =  @datExposureDate,
							strNote=@strNote,
							--idfsFinalCaseStatus  =  @idfsFinalClassIFication,			--finalCaseStatus is the classification
							idfsFinalCaseStatus  =  @idfsFinalCaseStatus,
							idfsOutcome =  @idfsOutcome,
							--datDateOfDeath =  @datDateofDeath,
							idfsCaseProgressStatus = @idfsCaseProgressStatus,
							datModificationDate = GETDATE(),
							idfsYNSpecimenCollected = @idfsYNSpecimenCollected,
							idfsYNTestsConducted = @idfsYNTestsConducted,
							DiseaseReportTypeID = @DiseaseReportTypeID,
							blnClinicalDiagBasis = @blnClinicalDiagBasis,
							blnLabDiagBasis = @blnLabDiagBasis,
							blnEpiDiagBasis	= @blnEpiDiagBasis,
							datFinalCaseClassificationDate = @DateofClassification,
							strsummarynotes = @strSummaryNotes,
							idfEpiObservation = @idfEpiObservation,
							idfCSObservation = @idfCSObservation,
							strEpidemiologistsName = @strEpidemiologistsName,
							idfsNotCollectedReason = @idfsNotCollectedReason,
							strNotCollectedReason =@strNotCollectedReason,
							idfsHumanAgeType = @idfsHumanAgeType,
							intPatientAge = @intPatientAge,
							datCompletionPaperFormDate = @datCompletionPaperFormDate,
							idfInvestigatedByPerson =  @idfInvestigatedByPerson,
							idfPersonEnteredBy = @idfPersonEnteredBy,
							idfsSite =@idfsSite,
							AuditUpdateUser = @AuditUser,
							idfParentMonitoringSession = @idfParentMonitoringSession

					WHERE	idfHumanCase = @idfHumanCase
					AND		intRowStatus = 0

				END
				
				----set Samples for this idfHumanCase	
			IF @SamplesParameters IS NOT NULL
			BEGIN
				
				WHILE EXISTS (
						SELECT *
						FROM @SamplesTemp
						)
				BEGIN
					SELECT TOP 1 @RowID = SampleID
						,@SampleID = SampleID
						,@SampleTypeID = SampleTypeID
						,@CollectedByPersonID = CollectedByPersonID
						,@CollectedByOrganizationID = CollectedByOrganizationID
						,@CollectionDate = CAST(CollectionDate AS DATETIME)
						,@SentDate = CAST(SentDate AS DATETIME)
						,@EIDSSLocalOrFieldSampleID = EIDSSLocalOrFieldSampleID
						,@SampleStatusTypeID = SampleStatusTypeID
						,@Comments = Comments
						,@idfsSite = SiteID
						,@CurrentSiteID = CurrentSiteID
						,@RowStatus = RowStatus
						,@SentToOrganizationID = SentToOrganizationID
						,@DiseaseID = DiseaseID
						,@ReadOnlyIndicator = ReadOnlyIndicator
						,@HumanID = HumanID
						,@HumanMasterID = HumanMasterID
						,@RowAction = RowAction
					FROM @SamplesTemp;
			
					INSERT INTO @SuppressSelect
					EXECUTE dbo.USSP_GBL_SAMPLE_SET 
						@AuditUserName = @AuditUser,
						@SampleID = @SampleID,
						@SampleTypeID = @SampleTypeID,
						@RootSampeleID = NULL,
						@ParentSampleID = NULL,
						@HumanID = @idfHuman,
						@SpeciedID = NULL,
						@AnimalID = NULL,
						@VectorID = NULL,
						@MonitoringSessionID = NULL,
						@VectorSessionID = NULL,
						@HumanDiseaseReportID = @idfHumanCase,
						@VeterinaryDiseaseReportID = NULL,
						@CollectionDate = @CollectionDate,
						@CollectedByPersonID = @CollectedByPersonID,
						@CollectedByOrganizationID = @CollectedByOrganizationID,
						@SentDate = @SentDate,
						@SentToOrganizationID = @SentToOrganizationID,
						@EIDSSLocalFieldSampleID = @EIDSSLocalOrFieldSampleID,
						@SiteID = @idfsSite,
						@EnteredDate = @DateEntered,
						@ReadOnlyIndicator = @ReadOnlyIndicator,
						@SampleStatusTypeID = @SampleStatusTypeID,
						@Comments = @Comments,
						@CurrentSiteID = @CurrentSiteID,
						@DiseaseID = @DiseaseID,
						@BirdStatusTypeID = NULL,
						@RowStatus = @RowStatus,
						@RowAction = @RowAction

						UPDATE @TestsTemp
						SET SampleID = @SampleID
						WHERE SampleID = @RowID

						DELETE
						FROM @SamplesTemp
						WHERE SampleID = @RowID
					END
				END		
			--	IF @TestsParameters IS NOT NULL
			--	BEGIN
			--		WHILE EXISTS (
			--				SELECT *
			--				FROM @TestsTemp
			--				)
			--		BEGIN
			--			SELECT TOP 1 @RowID = TestID
			--				,@TestID = TestID
			--				,@TestNameTypeID = TestNameTypeID
			--				,@TestCategoryTypeID = TestCategoryTypeID
			--				,@TestResultTypeID = TestResultTypeID
			--				,@TestStatusTypeID = TestStatusTypeID
			--				,@DiseaseID = DiseaseID
			--				,@SampleID = SampleID
			--				,@Comments = Comments
			--				,@RowStatus = RowStatus
			--				,@StartedDate = StartedDate
			--				,@ResultDate = ResultDate
			--				,@TestedByOrganizationID = TestedByOrganizationID
			--				,@TestedByPersonID = TestedByPersonID
			--				,@ResultEnteredByOrganizationID = ResultEnteredByOrganizationID
			--				,@ResultEnteredByPersonID = ResultEnteredByPersonID
			--				,@ValidatedByOrganizationID = ValidatedByOrganizationID
			--				,@ValidatedByPersonID = ValidatedByPersonID
			--				,@ReadOnlyIndicator = ReadOnlyIndicator
			--				,@NonLaboratoryTestIndicator = NonLaboratoryTestIndicator
			--				,@ExternalTestIndicator = ExternalTestIndicator
			--				,@PerformedByOrganizationID = PerformedByOrganizationID
			--				,@ReceivedDate = ReceivedDate
			--				,@ContactPersonName = ContactPersonName
			--				,@RowAction = RowAction
			--			FROM @TestsTemp;

			
			--			--If record is being soft-deleted, then check if the test record was originally created 
			--			--in the laboaratory module.  If it was, then disassociate the test record from the 
			--			--human monitoring session, so that the test record remains in the laboratory module 
			--			--for further action.
			--			IF @RowStatus = 1
			--				AND @NonLaboratoryTestIndicator = 0
			--			BEGIN
			--				SET @RowStatus = 0;
			--			END
			--			ELSE
			--			BEGIN
			--				SET @TestHumanCaseID = @TestHumanCaseId
			--			END;

			--			------set Tests for this idfHumanCase
			--			INSERT INTO @SuppressSelect
			--			EXECUTE dbo.USSP_GBL_TEST_SET 
			--				@LanguageID
			--				,@TestID OUTPUT
			--				,@TestNameTypeID
			--				,@TestCategoryTypeID
			--				,@TestResultTypeID
			--				,@TestStatusTypeID
			--				,@DiseaseID
			--				,@SampleID
			--				,NULL
			--				,NULL
			--				,NULL
			--				,@Comments
			--				,@RowStatus
			--				,@StartedDate
			--				,@ResultDate
			--				,@TestedByOrganizationID
			--				,@TestedByPersonID
			--				,@ResultEnteredByOrganizationID
			--				,@ResultEnteredByPersonID
			--				,@ValidatedByOrganizationID
			--				,@ValidatedByPersonID
			--				,@ReadOnlyIndicator
			--				,@NonLaboratoryTestIndicator
			--				,@ExternalTestIndicator
			--				,@PerformedByOrganizationID
			--				,@ReceivedDate
			--				,@ContactPersonName
			--				,NULL
			--				,NULL
			--				,@idfHumanCase
			--				,NULL
			--				,@AuditUser
			--				,@RowAction;


			--			UPDATE @TestsInterpretationParametersTemp
			--			SET TestID = @TestID
			--			WHERE TestID = @RowID

			--			DELETE
			--			FROM @TestsTemp
			--			WHERE TestID = @RowID;
			--		END;
			--	END		

		
			--Declare @sampleCount int
			--Set @sampleCount   = (SELECT Count(*) FROM tlbMaterial WHERE intRowStatus = 0 and idfHumanCase = @idfHumanCase)
			
			--IF  EXISTS(SELECT * FROM tlbHumanCase WHERE idfHumanCase = @idfHumanCase AND idfsYNSpecimenCollected = 10100002)
			--	Begin
			--		UPDATE tlbMaterial 
			--		SET		intRowStatus = 1,
			--				AuditUpdateUser = @AuditUser
			--		WHERE  idfHumanCase = @idfHumanCase
			--	END
			--ELSE IF EXISTS (SELECT * FROM tlbHumanCase WHERE idfHumanCase = @idfHumanCase AND idfsYNSpecimenCollected = 10100003 )
			--BEGIN
			--	UPDATE tlbHumanCase Set idfsNotCollectedReason =  NULL,
			--			AuditUpdateUser = @AuditUser
			--	WHERE idfHumanCase = @idfHumanCase;

			--	UPDATE tlbMaterial SET intRowStatus = 1,
			--			AuditUpdateUser = @AuditUser
			--	WHERE  idfHumanCase = @idfHumanCase;

			--END

			--ELSE IF EXISTS(SELECT * FROM tlbHumanCase WHERE idfHumanCase = @idfHumanCase AND idfsYNSpecimenCollected = 10100001)
			--BEGIN
			--	UPDATE tlbHumanCase
			--	SET		idfsNotCollectedReason =  NULL,
			--			AuditUpdateUser = @AuditUser
			--	WHERE idfHumanCase = @idfHumanCase
			--	IF	(@sampleCount= 0)
			--		BEGIN
			--			UPDATE tlbHumanCase
			--			SET idfsYNSpecimenCollected = NULL,
			--				AuditUpdateUser = @AuditUser
			--			WHERE idfHumanCase = @idfHumanCase
			--		END
			
			--END

			--IF @TestsInterpretationParameters IS NOT NULL
			--BEGIN
			--	WHILE EXISTS (SELECT * FROM @TestsInterpretationParametersTemp)
			--	BEGIN
			--		SELECT TOP 1
			--			@RowID = TestInterpretationID,
			--			@TestInterpretationID = TestInterpretationID,
			--			@DiseaseID = DiseaseID,
			--			@InterpretedStatusTypeID = InterpretedStatusTypeID,
			--			@ValidatedByOrganizationID = ValidatedByOrganizationID,
			--			@ValidatedByPersonID = ValidatedByPersonID,
			--			@InterpretedByOrganizationID = InterpretedByOrganizationID,
			--			@InterpretedByPersonID = InterpretedByPersonID,
			--			@TestID = TestID,
			--			@ValidatedStatusIndicator = ValidatedStatusIndicator,
			--			@ReportSessionCreatedIndicator = ReportSessionCreatedIndicator,
			--			@ValidatedComment = ValidatedComment,
			--			@InterpretedComment = InterpretedComment,
			--			@ValidatedDate = ValidatedDate,
			--			@InterpretedDate = InterpretedDate,
			--			@RowStatus = RowStatus,
			--			@ReadOnlyIndicator = ReadOnlyIndicator,
			--			@RowAction = RowAction
			--		FROM @TestsInterpretationParametersTemp;

			--		INSERT INTO @SuppressSelect
			--		EXECUTE dbo.USSP_GBL_TEST_INTERPRETATION_SET @AuditUser,
			--													 @TestInterpretationID OUTPUT,
			--													 @DiseaseID,
			--													 @InterpretedStatusTypeID,
			--													 @ValidatedByOrganizationID,
			--													 @ValidatedByPersonID,
			--													 @InterpretedByOrganizationID,
			--													 @InterpretedByPersonID,
			--													 @TestID,
			--													 @ValidatedStatusIndicator,
			--													 @ReportSessionCreatedIndicator,
			--													 @ValidatedComment,
			--													 @InterpretedComment,
			--													 @ValidatedDate,
			--													 @InterpretedDate,
			--													 @RowStatus,
			--													 @ReadOnlyIndicator,
			--													 @RowAction;

			--		DELETE FROM @TestsInterpretationParametersTemp
			--		WHERE TestInterpretationID = @RowID;
			--	END;
			--END

			-- WHILE EXISTS (SELECT * FROM @NotificationsTemp)
   --     BEGIN
   --         SELECT TOP 1
   --             @RowID = NotificationID,
   --             @NotificationID = NotificationID,
   --             @NotificationTypeID = NotificationTypeID,
   --             @idfHuman = UserID,
   --             @idfHumanCase = @idfHumanCase,
   --             @NotificationObjectTypeID = NotificationObjectTypeID,
   --             @TargetUserID = TargetUserID,
   --             @TargetSiteID = TargetSiteID,
   --             @TargetSiteTypeID = TargetSiteTypeID,
   --             @idfsSite = SiteID,
   --             @Payload = Payload,
   --             @LoginSite = LoginSite
   --         FROM @NotificationsTemp;

   --         INSERT INTO @SuppressSelect
   --         EXECUTE dbo.USP_GBL_NOTIFICATION_SET @NotificationID,
   --                                              @NotificationTypeID,
   --                                              @idfHuman,
   --                                              @idfHumanCase,
   --                                              @NotificationObjectTypeID,
   --                                              @TargetUserID,
   --                                              @TargetSiteID,
   --                                              @TargetSiteTypeID,
   --                                              @idfsSite,
   --                                              @Payload,
   --                                              @LoginSite,
   --                                              @AuditUser;

   --         DELETE FROM @NotificationsTemp
   --         WHERE NotificationID = @RowID;
   --     END;
			--	--------set AntiviralTherapies for this idfHumanCase
			--	IF @AntiviralTherapiesParameters IS NOT NULL
			--	EXEC USSP_HUMAN_DISEASE_ANTIVIRALTHERAPIES_SET @idfHumanCase,@AntiviralTherapiesParameters,0,@AuditUser	

			--	--------set Vaccinations for this idfHumanCase
			--	IF @VaccinationsParameters IS NOT NULL
			--	EXEC USSP_HUMAN_DISEASE_VACCINATIONS_SET @idfHumanCase,@VaccinationsParameters,0, @AuditUser;

			--	IF @ContactsParameters IS NOT NULL
			--	EXEC USSP_GBL_CONTACT_SET @ContactsParameters,@CurrentSiteID, @AuditUser,@idfHumanCase; 


				------ UPDATE tlbHuman IF datDateofDeath is provided.
				IF @datDateofDeath IS NOT NULL
					BEGIN
						UPDATE dbo.tlbHuman
						SET		datDateofDeath = @datDateofDeath,
								AuditUpdateUser = @AuditUser
						WHERE idfHuman = @idfHuman
					END
		
		IF @@TRANCOUNT > 0 
			COMMIT TRAN
        
		SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage',@idfHumanCase 'idfHumanCase', @strHumanCaseID 'strHumanCaseID',@idfHuman 'idfHuman'

	END TRY
	BEGIN CATCH
			SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage',@idfHumanCase 'idfHumanCase', @strHumanCaseID 'strHumanCaseID',@idfHuman 'idfHuman'
			IF @@Trancount > 0 
				ROLLBACK TRAN;

				THROW;

	END CATCH
	
END

