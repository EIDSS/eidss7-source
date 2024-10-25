-- ================================================================================================
-- Name: [USP_OMM_Case_Set]
-- Description: Insert/Update for Outbreak Case
--          
-- Author: Doug Albanese
-- Revision History
--	Name			Date		Change Detail
--  Doug Albanese	5/21/2020	Moved the Case Monitoring SP call to this SP from USP_OMM_HUMAN_DISEASE_SET
--	Doug Albanese	10/12/2020	Corrected Audit information
--	Doug Albanese	10/01/2021	Cleaned up and prepped for EF
--	Doug Albanese	04/19/2022	Refactored to use location hierarchy
--	Doug Albanese	04/21/2022	Formatted and some refactoring
--	Doug Albanese	04/27/2022	Refactored paramters to eliminate unused 
--	Doug Albanese	04/28/2022	Further Clean up to align with json array detection
--	Doug Albanese	04/30/2022	Added idfHumanCase to contacts USSP
--	Doug Albanese	05/02/2022	Refactored Antimicrobial
--	Doug Albanese	05/06/2022	Corrected "Start Date of Investigation"...wrong parameter used previously
--	Doug Albanese	05/06/2022	Corrected Street/Postalcode data types
--  Stephen Long    05/21/2022  Fix to idfsSite on call to USP_ADMIN_FF_COPY_OBSERVATION.
--                              Added begin transaction and commit transaction.
--	Doug Albanese	05/23/2022	Supression on USSP_OMM_CONTACT_SET was nested too deep. Using Functional Call only to get around
--	Doug Albanese	06/01/2022	Removal of transaction block to allow nested calls to function properly.
--	Doug Albanese	07/01/2022	Changes to fix the Copy process of an observation and flex form template for use within an outbreak case
-- Stephen Long     07/18/2022  Added site alert logic.
-- Doug Albanese    09/22/2022  Removed supression on USP_ADMIN_FF_Copy_Observation
-- Doug Albanese    10/19/2022  Corrected the "@StartDateofInvestigation" to have the right parameter passed.
-- Doug Albanese    10/25/2022  Put the Case Questionnnaire in the right location on the Outbreak Case Report side.
-- Doug Albanese    12/29/2022  Added Return Message to denote the use of an imported diseased report to an outbreak.
-- Doug Albanese    01/06/2023  Removed the copy process for the "clinical signs" flex form for the moment. It is causing POCO issues
-- Doug Albanese	07/06/2023	Added a routine to map tlbContactedCasePerson to OutbreakCaseContact
-- ================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_OMM_Case_Set]
(
    @LangID NVARCHAR(50),
    @intRowStatus INT = 0,
    @User NVARCHAR(100) = NULL,

    --Outbreak Case Details
    @OutbreakCaseReportUID BIGINT = -1,
    @idfOutbreak BIGINT = NULL,
    @idfHumanCase BIGINT = -1,
    @idfVetCase BIGINT = NULL,
    @OutbreakCaseObservationID BIGINT = NULL,

    --Human Disease related items for creation
    @idfHumanActual BIGINT = -1,
    @idfsDiagnosisOrDiagnosisGroup BIGINT = -1,

    --Notification
    @datNotificationDate DATETIME = NULL,
    @idfSentByOffice BIGINT = NULL,
    @idfSentByPerson BIGINT = NULL,
    @idfReceivedByOffice BIGINT = NULL,
    @idfReceivedByPerson BIGINT = NULL,

    --Case Location
    @CaseGeoLocationID BIGINT = NULL,
    @CaseidfsLocation BIGINT = NULL,
    @CasestrStreetName NVARCHAR(200) = NULL,
    @CasestrApartment NVARCHAR(200) = NULL,
    @CasestrBuilding NVARCHAR(200) = NULL,
    @CasestrHouse NVARCHAR(200) = NULL,
    @CaseidfsPostalCode NVARCHAR(200) = NULL,
    @CasestrLatitude FLOAT = NULL,
    @CasestrLongitude FLOAT = NULL,
    @CasestrElevation FLOAT = NULL,

    --Clinical Information
    @CaseStatusID BIGINT = NULL,
    @datOnSetDate DATETIME = NULL,
    @datFinalDiagnosisDate DATETIME = NULL,
    @idfHospital BIGINT = NULL,
    @strHospitalName NVARCHAR(200) = NULL,
    @datHospitalizationDate DATETIME = NULL,
    @datDischargeDate DATETIME = NULL,
    @Antimicrobials NVARCHAR(MAX) = NULL,
    @vaccinations NVARCHAR(MAX) = NULL,
    @strClinicalNotes NVARCHAR(500) = NULL,
    @idfsYNHospitalization BIGINT = NULL,
    @idfsYNAntimicrobialTherapy BIGINT = NULL,
    @idfsYNSpecIFicVaccinationAdministered BIGINT = NULL,
    @StartDateofInvestigation DATETIME = NULL,
    @idfCSObservation BIGINT = NULL,

    --Outbreak Investigation
    @OutbreakCaseClassificationID BIGINT = NULL,
    @idfInvestigatedByOffice BIGINT = NULL,
    @idfInvestigatedByPerson BIGINT = NULL,
    @datInvestigationStartDate DATETIME = NULL,
    @IsPrimaryCaseFlag NVARCHAR(1) = NULL,
    @strNote NVARCHAR(500) = NULL,
    @idfEpiObservation BIGINT = NULL,

    --Case Monitoring
    @CaseMonitorings NVARCHAR(MAX) = NULL,

    --Contacts
    @CaseContacts NVARCHAR(MAX) = NULL,

    --Samples
    @idfsYNSpecimenCollected BIGINT = NULL,
    @CaseSamples NVARCHAR(MAX) = NULL,

    --Tests
    @idfsYNTestsConducted BIGINT = NULL,
    @CaseTests NVARCHAR(MAX) = NULL,
    @Events NVARCHAR(MAX) = NULL
)
AS
BEGIN
    DECLARE @returnCode INT = 0
    DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS'
    DECLARE @SiteID BIGINT = (
                                 SELECT idfsSite FROM dbo.tlbOutbreak WHERE idfOutbreak = @idfOutbreak
                             )
    DECLARE @outbreakLocation BIGINT = NULL
    DECLARE @idfHuman BIGINT = NULL
    DECLARE @strHumanCaseId NVARCHAR(200)
    DECLARE @idfsFinalState BIGINT = NULL

    DECLARE @idfContactCasePerson BIGINT
    DECLARE @ContactRelationshipTypeID BIGINT
    DECLARE @DateOfLastContact DATETIME
    DECLARE @datDateOfLastContact DATETIME2
    DECLARE @PlaceOfLastContact NVARCHAR(200)
    DECLARE @ContactStatusID BIGINT
    DECLARE @DateOfLastContact2 VARCHAR(10)
    DECLARE @idfsPersonContactType BIGINT
    DECLARE @idfContactedCasePerson BIGINT
    DECLARE @SQL VARCHAR(MAX)
    DECLARE @RowID BIGINT = NULL
    DECLARE @OutbreakCaseContactUID BIGINT = NULL
    DECLARE @ContactComments NVARCHAR(200) = NULL
    DECLARE @ContactTypeID BIGINT = NULL
	DECLARE @ContactedHumanCasePersonID BIGINT = NULL
	DECLARE @ContactComment NVARCHAR(2000) = NULL
	DECLARE @ContactHumanID BIGINT = NULL

    DECLARE @PrepCollections INT = 0
    DECLARE @ExecuteHumanSP INT = 0
    DECLARE @CreateOutbreakCase INT = 0
    DECLARE @ExecuteVetSP INT = 0
    DECLARE @HumanSamplesTemp NVARCHAR(MAX) = NULL
    DECLARE @HumanContactsTemp NVARCHAR(MAX) = NULL

    DECLARE @idfsFormTemplate BIGINT
    DECLARE @idfsFormTemplateNew BIGINT

    DECLARE @strCaseID NVARCHAR(50) = NULL
    DECLARE @idfObservation BIGINT = NULL

    DECLARE @EventId BIGINT,
            @EventTypeId BIGINT = NULL,
            @EventSiteId BIGINT = NULL,
            @EventObjectId BIGINT = NULL,
            @EventUserId BIGINT = NULL,
            @EventDiseaseId BIGINT = NULL,
            @EventLocationId BIGINT = NULL,
            @EventInformationString NVARCHAR(MAX) = NULL,
            @EventLoginSiteId BIGINT = NULL;

    DECLARE @EventsTemp TABLE
    (
        EventId BIGINT NOT NULL,
        EventTypeId BIGINT NULL,
        UserId BIGINT NULL,
        SiteId BIGINT NULL,
        LoginSiteId BIGINT NULL,
        ObjectId BIGINT NULL,
        DiseaseId BIGINT NULL,
        LocationId BIGINT NULL,
        InformationString NVARCHAR(MAX) NULL
    );

    SET NOCOUNT ON

    BEGIN TRY
        --BEGIN TRANSACTION;

        if (@idfCSObservation = 0)
            SET @idfCSObservation = NULL

        --Because of the JSON Table data being passed, the value of NULL is converted to a string. In these cases, they must be set to a True NULL
        IF (@Antimicrobials = 'NULL' OR @Antimicrobials = '[]')
            SET @Antimicrobials = NULL
        IF (@vaccinations = 'NULL' OR @vaccinations = '[]')
            SET @vaccinations = NULL
        IF (@CaseMonitorings = 'NULL' OR @CaseMonitorings = '[]')
            SET @CaseMonitorings = NULL
        IF (@CaseContacts = 'NULL' OR @CaseContacts = '[]')
            SET @CaseContacts = NULL
        IF (@CaseSamples = 'NULL' OR @CaseSamples = '[]')
            SET @CaseSamples = NULL
        IF (@CaseTests = 'NULL' OR @CaseTests = '[]')
            SET @CaseTests = NULL

        --Table calls for NCHAR, but we are going to need an integer to convert into boolean
        IF (@IsPrimaryCaseFlag = 't')
        BEGIN
            SET @IsPrimaryCaseFlag = 1
        END
        ELSE
        BEGIN
            SET @IsPrimaryCaseFlag = 0
        END

        Declare @SupressSelect table
        (
            retrunCode int,
            returnMsg varchar(200)
        )

        INSERT INTO @EventsTemp
        SELECT *
        FROM
            OPENJSON(@Events)
            WITH
            (
                EventId BIGINT,
                EventTypeId BIGINT,
                UserId BIGINT,
                SiteId BIGINT,
                LoginSiteId BIGINT,
                ObjectId BIGINT,
                DiseaseId BIGINT,
                LocationId BIGINT,
                InformationString NVARCHAR(MAX)
            );

        --This condition was added later, after I found out that I created a bad architecture
        IF @idfVetCase IS NOT NULL
        BEGIN
            SET @ExecuteVetSP = 1

            IF EXISTS
            (
                SELECT OutBreakCaseReportUID
                FROM dbo.OutbreakCaseReport
                WHERE OutBreakCaseReportUID = @OutBreakCaseReportUID
            )
            BEGIN
                --Case is already created
                --This can only be an update of information across the outbreak and human case elements.
                UPDATE dbo.OutbreakCaseReport
                SET idfOutbreak = @idfOutbreak,
                    OutbreakCaseObservationID = @OutbreakCaseObservationID,
                    OutbreakCaseStatusID = @CaseStatusID,
                    OutbreakCaseClassificationID = @OutbreakCaseClassificationID,
                    IsPrimaryCaseFlag = @IsPrimaryCaseFlag,
                    intRowStatus = @intRowStatus,
                    AuditUpdateUser = @User,
                    AuditUpdateDTM = GETDATE()
                WHERE OutBreakCaseReportUID = @OutBreakCaseReportUID

            END
            ELSE
            BEGIN
                --At this point, the outbreak case doesn't exist.
                --This means, it could be an import or a creation from the outbreak side.
                --regardless of this situation, we need to get an idea for the Outbreak case being created.
                INSERT INTO @SupressSelect
                EXEC dbo.USP_GBL_NEXTKEYID_GET 'OutbreakCaseReport',
                                               @OutBreakCaseReportUID OUTPUT;

                DECLARE @strOutbreakCaseID NVARCHAR(200)

                --If a human case id was passed, we are performing an import
                IF @idfVetCase IS NOT NULL
                   AND @idfVetCase <> -1
                BEGIN
                    --To keep duplicate imports from occuring, check to make sure a record doesn't already exist within the case listing of the outbreak session
                    IF NOT EXISTS
                    (
                        SELECT OutBreakCaseReportUID
                        FROM dbo.OutbreakCaseReport
                        WHERE idfOutbreak = @idfOutbreak
                              AND idfVetCase = @idfVetCase
                              AND intRowStatus = 0
                    )
                    BEGIN
                        INSERT INTO @SupressSelect
                        EXEC dbo.USP_GBL_NextNumber_GET 'Vet Outbreak Case',
                                                        @strOutbreakCaseID OUTPUT,
                                                        NULL;

                        INSERT INTO dbo.OutbreakCaseReport
                        (
                            OutbreakCaseReportUID,
                            idfOutbreak,
                            strOutbreakCaseID,
                            --idfHumanCase,
                            idfVetCase,
                            OutbreakCaseObservationId,
                            OutbreakCaseStatusId,
                            OutbreakCaseClassificationID,
                            isPrimaryCaseFlag,
                            introwStatus,
                            AuditCreateUser,
                            AuditCreateDTM,
                            AuditUpdateUser,
                            AuditUpdateDTM
                        )
                        VALUES
                        (   @OutBreakCaseReportUID,
                            @idfOutbreak,
                            @strOutbreakCaseID,
                            --NULL,
                            @idfVetCase,
                            @idfEpiObservation,
                            @CaseStatusID,
                            @OutbreakCaseClassificationID,
                            @IsPrimaryCaseFlag,
                            0,
                            @User,
                            GETDATE(),
                            NULL,
                            NULL
                        )
                    END
                    --Tie the outbreak case and the human case together, using the outbreak session id (idfOutbreak)
                    --This will complete the import process, as all information pertain to the case will now be
                    --joined in a "getdetails", when retrieved on the outbreak side.
                    UPDATE dbo.tlbVetCase
                    SET idfOutbreak = @idfOutbreak
                    WHERE idfVetCase = @idfVetCase

                    SELECT @idfObservation = idfObservation
                    FROM dbo.tlbVetCase
                    WHERE idfVetCase = @idfVetCase

                    --INSERT INTO @SupressSelect
                    EXEC dbo.USP_ADMIN_FF_Copy_Observation @idfObservation = @idfObservation,
                                                           @User = @User,
                                                           @idfsSite = @SiteID
                    UPDATE dbo.OutbreakCaseReport
                    SET OutbreakCaseObservationID = @idfObservation
                    WHERE OutBreakCaseReportUID = @OutBreakCaseReportUID
                END
            END
        END
        ELSE
        BEGIN
            IF EXISTS
            (
                SELECT OutBreakCaseReportUID
                FROM dbo.OutbreakCaseReport
                WHERE OutBreakCaseReportUID = @OutBreakCaseReportUID
            )
            BEGIN
                --Case is already created
                --This can only be an update of information across the outbreak and human case elements.
                UPDATE dbo.OutbreakCaseReport
                SET idfOutbreak = @idfOutbreak,
                    OutbreakCaseObservationID = @OutbreakCaseObservationID,
                    OutbreakCaseStatusID = @CaseStatusID,
                    OutbreakCaseClassificationID = @OutbreakCaseClassificationID,
                    IsPrimaryCaseFlag = @IsPrimaryCaseFlag,
                    intRowStatus = @intRowStatus,
                    AuditUpdateUser = @User,
                    AuditUpdateDTM = GETDATE()
                WHERE OutBreakCaseReportUID = @OutBreakCaseReportUID

                SET @PrepCollections = 1
                SET @ExecuteHumanSP = 1
            END
            ELSE
            BEGIN
                --At this point, the outbreak case doesn't exist.
                --This means, it could be an import or a creation from the outbreak side.

                --regardless of this situation, we need to get an id for the Outbreak case being created.
                INSERT INTO @SupressSelect
                EXEC dbo.USP_GBL_NEXTKEYID_GET 'OutbreakCaseReport',
                                               @OutBreakCaseReportUID OUTPUT;

                --If a human case id was passed, we are performing an import
                IF @idfHumanCase IS NOT NULL
                   AND @idfHumanCase <> -1
                BEGIN
                    IF EXISTS
                    (
						SELECT
						   1
						FROM 
						   tlbHumanCase
						WHERE 
						   (idfOutbreak IS NULL OR idfOutbreak = NULL) AND
						   idfHumanCase = @idfHumanCase
                    )
					   BEGIN
						   --It doesn't exist, so we need to create a case "smart id", on the outbreak side, for the item being imported.
						   INSERT INTO @SupressSelect
						   EXEC dbo.USP_GBL_NextNumber_GET 'Human Outbreak Case',
														   @strOutbreakCaseID OUTPUT,
														   NULL;

						   --Generate a shell record in the case table to denote the item from the human case being imported
						   --Below is the minimal amount of fields needed to create the case. All other information will be entered
						   --during the editing phase
						   INSERT INTO dbo.OutbreakCaseReport
						   (
							   OutBreakCaseReportUID,
							   idfOutbreak,
							   strOutbreakCaseID,
							   idfHumanCase,
							   intRowStatus,
							   AuditCreateUser,
							   AuditCreateDTM,
							   AuditUpdateUser,
							   AuditUpdateDTM
						   )
						   VALUES
						   (@OutBreakCaseReportUID,
							@idfOutbreak,
							@strOutbreakCaseID,
							@idfHumanCase,
							0  ,
							@User,
							GETDATE(),
							NULL,
							NULL
						   )

						   /*Temp solution??? To tie in datFinalDiagnosisDate with datTentativeDiagnosisDate*/
						   UPDATE dbo.tlbHumanCase
						   SET datFinalDiagnosisDate = datTentativeDiagnosisDate,
							   AuditUpdateUser = @User
						   WHERE idfHumanCase = @idfHumanCase
								 AND datFinalDiagnosisDate IS NULL

						   UPDATE dbo.tlbHumanCase
						   SET idfOutbreak = @idfOutbreak,
							   AuditUpdateUser = @User
						   WHERE idfHumanCase = @idfHumanCase

						   SELECT @idfEPIObservation = idfEPIObservation,
								  @idfCSObservation = idfCSObservation
						   FROM dbo.tlbHumanCase
						   WHERE idfHumanCase = @idfHumanCase

						   SELECT
							  @DateOfLastContact = datDateOfLastContact,
							  @ContactedHumanCasePersonID = idfContactedCasePerson,
							  @PlaceOfLastContact = strPlaceInfo,
							  @ContactComment = strComments,
							  @ContactTypeID = idfsPersonContactType,
							  @ContactHumanID = idfHuman
						   FROM
							  tlbContactedCasePerson

						   SET @CaseContacts = CONCAT('[{',
						   '"DateOfLastContact":"', @DateOfLastContact, '",',
						   '"CaseContactID":-1,',
						   '"ContactedHumanCasePersonID":', @ContactedHumanCasePersonID , ',',
						   '"PlaceOfLastContact":"', @PlaceOfLastContact, '",',
						   '"Comment":"', @ContactComment, '",',
						   '"ContactTypeID":', @ContactTypeID, ',',
						   '"ContactStatusID":10517002,',
						   '"ContactRelationshipTypeID":10014001,',
						   '"ContactTracingObservationID":null,',
						   '"HumanID":', @ContactHumanID, ',',
						   '"FarmMasterID":null,',
						   '"RowStatus":0,',
						   '"RowAction":1',
						   '}]')


						   --IF COALESCE(@idfEpiObservation, 0) > 0
						   --BEGIN
							  -- SELECT @idfsFormTemplate = idfsFormTemplate
							  -- FROM tlbObservation
							  -- WHERE idfObservation = @idfEPIObservation

							  -- INSERT INTO @SupressSelect
							  -- EXEC dbo.USP_ADMIN_FF_Copy_Observation @idfObservation = @idfEPIObservation OUTPUT,
									--								  @User = @User,
									--								  @idfsSite = @SiteID

							  -- EXEC USP_OMM_FF_Copy_Template @LangId = @LangId,
									--						 @idfsFormTemplate = @idfsFormTemplate,
									--						 @User = @User,
									--						 @idfsSite = @SiteID,
									--						 @idfsNewFormType = 10034501

							  -- SELECT @idfsFormTemplateNew = idfsFormTemplate
							  -- FROM ffFormTemplate
							  -- WHERE AuditCreateUser = @User
									-- AND idfsFormType = 10034501
									-- AND idfsFormTemplate = @idfsFormTemplate

							  -- UPDATE tlbObservation
							  -- SET idfsFormTemplate = @idfsFormTemplateNew
							  -- WHERE idfObservation = @idfObservation
									-- AND idfsFormTemplate = @idfsFormTemplate
						   --END

						   IF COALESCE(@idfCSObservation, 0) > 0
						   BEGIN
							   INSERT INTO @SupressSelect
							   EXEC dbo.USP_ADMIN_FF_Copy_Observation @idfObservation = @idfCSObservation,
																	  @User = @User,
																	  @idfsSite = @SiteID

							   UPDATE dbo.OutbreakCaseReport
							   SET OutbreakCaseObservationID = @idfCSObservation,
								   AuditUpdateUser = @User
							   WHERE OutBreakCaseReportUID = @OutBreakCaseReportUID
						   END
					   END
					ELSE
						BEGIN
						   SET @returnMsg = 'EXISTING_OUTBREAK_CASE'
						END
                END
                ELSE
                BEGIN
                    --At this point, the data being passed is only pertaining to the manual creation of
                    --a Human Case from the outbreak side.
                    SET @CreateOutbreakCase = 1
                    SET @PrepCollections = 1
                    SET @ExecuteHumanSP = 1

                END
            END
        END

		
        IF @ExecuteHumanSP = 1
        BEGIN
            INSERT INTO @SupressSelect
            EXEC dbo.USP_OMM_HUMAN_DISEASE_SET @idfHumanCase OUTPUT,
                                               @strHumanCaseId = @strHumanCaseId,
                                               @OutbreakCaseReportUID = @OutbreakCaseReportUID,
                                               @idfHumanActual = @idfHumanActual,
                                               @idfsFinalDiagnosis = @idfsDiagnosisOrDiagnosisGroup,
                                               @datDateOfDiagnosis = @datFinalDiagnosisDate,
                                               @datNotificationDate = @datNotificationDate,
                                               @idfsFinalState = @idfsFinalState,
                                               @idfSentByOffice = @idfSentByOffice,
                                               @idfSentByPerson = @idfSentByPerson,
                                               @idfReceivedByOffice = @idfReceivedByOffice,
                                               @idfReceivedByPerson = @idfReceivedByPerson,
                                               @idfHospital = @idfHospital,
                                               @datOnSetDate = @datOnSetDate,
                                               @idfsYNHospitalization = @idfsYNHospitalization,
                                               @datHospitalizationDate = @datHospitalizationDate,
                                               @datDischargeDate = @datDischargeDate,
                                               @strHospitalName = @strHospitalName,
                                               @idfsYNAntimicrobialTherapy = @idfsYNAntimicrobialTherapy,
                                               @strClinicalNotes = @strClinicalNotes,
                                               @strNote = @strNote,
                                               @idfsYNSpecIFicVaccinationAdministered = @idfsYNSpecIFicVaccinationAdministered,
                                               @idfInvestigatedByOffice = @idfInvestigatedByOffice,
                                               @idfInvestigatedByPerson = @idfInvestigatedByPerson,
                                               @StartDateofInvestigation = @StartDateofInvestigation,
                                               @idfOutbreak = @idfOutbreak,
                                               @CaseGeoLocationID = @CaseGeoLocationID,
                                               @CaseidfsLocation = @CaseidfsLocation,
                                               @CasestrStreetName = @CasestrStreetName,
                                               @CasestrApartment = @CasestrApartment,
                                               @CasestrBuilding = @CasestrBuilding,
                                               @CasestrHouse = @CasestrHouse,
                                               @CaseidfsPostalCode = @CaseidfsPostalCode,
                                               @CasestrLatitude = @CasestrLatitude,
                                               @CasestrLongitude = @CasestrLongitude,
                                               @CasestrElevation = @CasestrElevation,
                                               @SamplesParameters = @CaseSamples,
                                               @idfsYNSpecimenCollected = @idfsYNSpecimenCollected,
                                               @idfsYNTestsConducted = @idfsYNTestsConducted,
                                               @TestsParameters = @CaseTests,
                                               @AntiviralTherapiesParameters = @Antimicrobials,
                                               @VaccinationsParameters = @vaccinations,
                                               @CaseMonitoringsParameters = @CaseMonitorings,
                                               @User = @User,
                                               @idfEpiObservation = @idfEpiObservation,
                                               @idfCSObservation = @idfCSObservation

            INSERT INTO @SupressSelect
            EXEC dbo.USSP_OMM_CASE_MONITORING_SET @CaseMonitorings = @CaseMonitorings,
                                                  @HumanDiseaseReportID = @idfHumanCase,
                                                  @User = @User

            --Update the tblHumanCase with the Outbreak Id related by the import process.
            UPDATE tlbHumanCase
            SET idfOutbreak = @idfOutbreak,
                AuditUpdateUser = @User
            WHERE idfHumanCase = @idfHumanCase
        END

        IF @CreateOutbreakCase = 1
        BEGIN
            --Create the outbreak case, with full information
            INSERT INTO @SupressSelect
            EXEC dbo.USP_GBL_NextNumber_GET 'Human Outbreak Case',
                                            @strOutbreakCaseID OUTPUT,
                                            NULL;

            INSERT INTO dbo.OutbreakCaseReport
            (
                OutBreakCaseReportUID,
                idfOutbreak,
                strOutbreakCaseID,
                idfHumanCase,
                idfVetCase,
                OutbreakCaseStatusID,
                OutbreakCaseClassificationID,
                IsPrimaryCaseFlag,
                intRowStatus,
                AuditCreateUser,
                AuditCreateDTM,
                AuditUpdateUser,
                AuditUpdateDTM
            )
            VALUES
            (@OutBreakCaseReportUID,
             @idfOutbreak,
             @strOutbreakCaseID,
             @idfHumanCase,
             @idfVetCase,
             @CaseStatusID,
             @OutbreakCaseClassificationID,
             @IsPrimaryCaseFlag,
             COALESCE(@intRowStatus, 0),
             @User,
             GETDATE(),
             NULL,
             NULL
            )
        END

        --Add/Update any contacts
        IF @CaseContacts IS NOT NULL
        BEGIN
            --INSERT INTO @SupressSelect
            EXEC dbo.USSP_OMM_CONTACT_SET @idfHumanCase,
                                          @CaseContacts,
                                          @User = @User,
                                          @OutbreakCaseReportUID = @OutbreakCaseReportUID,
                                          @FunctionCall = 1;
        END

        WHILE EXISTS (SELECT * FROM @EventsTemp)
        BEGIN
            SELECT TOP 1
                @EventId = EventId,
                @EventTypeId = EventTypeId,
                @EventUserId = UserId,
                @EventObjectId = ObjectId,
                @EventSiteId = SiteId,
                @EventDiseaseId = DiseaseId,
                @EventLocationId = LocationId,
                @EventInformationString = InformationString,
                @EventLoginSiteId = LoginSiteId
            FROM @EventsTemp;

            INSERT INTO @SupressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                            @EventTypeId,
                                            @EventUserId,
                                            @EventObjectId,
                                            @EventDiseaseId,
                                            @EventSiteId,
                                            @EventInformationString,
                                            @EventLoginSiteId,
                                            @EventLocationId,
                                            @User;

            DELETE FROM @EventsTemp
            WHERE EventId = @EventId;
        END;

        SELECT @returnCode AS ReturnCode,
               @returnMsg AS ReturnMessage,
               @strOutbreakCaseID AS strOutbreakCaseId,
               @OutbreakCaseReportUID AS OutbreakCaseReportUID;
    END TRY
    BEGIN CATCH

        THROW;
    END CATCH
END
