-- ================================================================================================
-- Name: USSP_OMM_CONVERT_CONTACT_Set
-- Description: Inserts a new case for a contact being converted to a case.
--          
-- Revision History:
-- Name                    Date       Change Detail
-- ----------------------- ---------- ------------------------------------------------------------
-- Stephen Long            06/05/2022 Initial release
-- Stephen Long            10/25/2022 Added logic to convert veterinary contact to a veterinary 
--                                    case.
-- Ann Xiong			   03/09/2023  Modified to pass parameter '@DataAuditEventTypeID' when call USP_VET_DISEASE_REPORT_SET
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_OMM_CONVERT_CONTACT_Set]
(
    @OutbreakID BIGINT = NULL,
    @CaseContactID BIGINT, 
    @HumanMasterID BIGINT,
    @HumanID BIGINT, 
    @FarmMasterID BIGINT = NULL, 
    @GeolocationID BIGINT = NULL,
    @LocationID BIGINT = NULL,
    @Street NVARCHAR(200) = NULL,
    @Apartment NVARCHAR(200) = NULL,
    @Building NVARCHAR(200) = NULL,
    @House NVARCHAR(200) = NULL,
    @PostalCode NVARCHAR(200) = NULL,
    @Latitude FLOAT = NULL,
    @Longitude FLOAT = NULL,
    @Elevation FLOAT = NULL,
    @CaseStatusTypeID BIGINT = NULL,
    @CaseClassificationTypeID BIGINT = NULL,
    @AuditUserName NVARCHAR(100) = NULL
)
AS
BEGIN
    DECLARE @ReturnCode INT = 0,
            @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
            @CaseID BIGINT = NULL,
            @EIDSSCaseID NVARCHAR(50) = NULL,
            @DiseaseReportID BIGINT = NULL;

    BEGIN TRY
        IF @FarmMasterID IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'OutbreakCaseReport', @CaseID OUTPUT;

            EXEC dbo.USP_GBL_NextNumber_GET 'Human Outbreak Case',
                                            @EIDSSCaseID OUTPUT,
                                            NULL;

            EXEC dbo.USP_OMM_HUMAN_DISEASE_SET @DiseaseReportID OUTPUT,
                                               @idfHuman = @HumanID, 
                                               @strHumanCaseId = @EIDSSCaseID,
                                               @OutbreakCaseReportUID = @CaseID,
                                               @idfHumanActual = @HumanMasterID,
                                               @idfsFinalDiagnosis = NULL,
                                               @datDateOfDiagnosis = NULL,
                                               @datNotificationDate = NULL,
                                               @idfsFinalState = NULL,
                                               @idfSentByOffice = NULL,
                                               @idfSentByPerson = NULL,
                                               @idfReceivedByOffice = NULL,
                                               @idfReceivedByPerson = NULL,
                                               @idfHospital = NULL,
                                               @datOnSetDate = NULL,
                                               @idfsYNHospitalization = NULL,
                                               @datHospitalizationDate = NULL,
                                               @datDischargeDate = NULL,
                                               @strHospitalName = NULL,
                                               @idfsYNAntimicrobialTherapy = NULL,
                                               @strClinicalNotes = NULL,
                                               @strNote = NULL,
                                               @idfsYNSpecIFicVaccinationAdministered = NULL,
                                               @idfInvestigatedByOffice = NULL,
                                               @idfInvestigatedByPerson = NULL,
                                               @StartDateofInvestigation = NULL,
                                               @idfOutbreak = @OutbreakID,
                                               @CaseGeoLocationID = @GeolocationID,
                                               @CaseidfsLocation = @LocationID,
                                               @CasestrStreetName = @Street,
                                               @CasestrApartment = @Apartment,
                                               @CasestrBuilding = @Building,
                                               @CasestrHouse = @House,
                                               @CaseidfsPostalCode = @PostalCode,
                                               @CasestrLatitude = @Latitude,
                                               @CasestrLongitude = @Longitude,
                                               @CasestrElevation = @Elevation,
                                               @SamplesParameters = NULL,
                                               @idfsYNSpecimenCollected = NULL,
                                               @idfsYNTestsConducted = NULL,
                                               @TestsParameters = NULL,
                                               @AntiviralTherapiesParameters = NULL,
                                               @VaccinationsParameters = NULL,
                                               @CaseMonitoringsParameters = NULL,
                                               @User = @AuditUserName,
                                               @idfEpiObservation = NULL,
                                               @idfCSObservation = NULL;

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
            (@CaseID,
             @OutbreakID,
             @EIDSSCaseID,
             @DiseaseReportID,
             NULL,
             @CaseStatusTypeID,
             @CaseClassificationTypeID,
             0  ,
             0  ,
             @AuditUserName,
             GETDATE(),
             NULL,
             NULL
            );
        END
        ELSE
        BEGIN
            DECLARE @SiteID BIGINT = (SELECT idfsSite FROM dbo.tlbOutbreak WHERE idfOutbreak = @OutbreakID);
            DECLARE @DiseaseID BIGINT = (SELECT idfsDiagnosisOrDiagnosisGroup FROM dbo.tlbOutbreak WHERE idfOutbreak = @OutbreakID);
            DECLARE @ReportTypeID BIGINT = (SELECT vc.idfsCaseType FROM dbo.OutbreakCaseContact occ
                INNER JOIN dbo.OutbreakCaseReport ocr 
                    ON ocr.OutBreakCaseReportUID = occ.OutBreakCaseReportUID 
                INNER JOIN dbo.tlbVetCase vc 
                    ON vc.idfVetCase = ocr.idfVetCase 
                WHERE occ.OutbreakCaseContactUID = @CaseContactID);
            DECLARE @EnteredDate DATETIME = GETDATE();

            EXEC dbo.USP_VET_DISEASE_REPORT_SET @DiseaseReportID = -1,
                                                @EIDSSReportID = NULL,
                                                @FarmID = NULL,
                                                @FarmMasterID = @FarmMasterID,
                                                @FarmOwnerID = NULL,
                                                @MonitoringSessionID = NULL,
                                                @OutbreakID = @OutbreakID,
                                                @RelatedToDiseaseReportID = NULL,
                                                @EIDSSFieldAccessionID = NULL,
                                                @DiseaseID = @DiseaseID,
                                                @EnteredByPersonID = NULL,
                                                @ReportedByOrganizationID = NULL,
                                                @ReportedByPersonID = NULL,
                                                @InvestigatedByOrganizationID = NULL,
                                                @InvestigatedByPersonID = NULL,
                                                @ReceivedByOrganizationID = NULL,
                                                @ReceivedByPersonID = NULL,
                                                @SiteID = @SiteID,
                                                @DiagnosisDate = NULL,
                                                @EnteredDate = @EnteredDate, 
                                                @ReportDate = NULL,
                                                @AssignedDate = NULL,
                                                @InvestigationDate = NULL,
                                                @RowStatus = 0,
                                                @ReportTypeID = NULL,
                                                @ClassificationTypeID = NULL,
                                                @StatusTypeID = 10109001, -- In Progress
                                                @ReportCategoryTypeID = @ReportTypeID, -- Avian or Livestock
                                                @FarmTotalAnimalQuantity = NULL,
                                                @FarmSickAnimalQuantity = NULL,
                                                @FarmDeadAnimalQuantity = NULL,
                                                @FarmLatitude = NULL,
                                                @FarmLongitude = NULL,
                                                @FarmEpidemiologicalObservationID = NULL,
                                                @ControlMeasuresObservationID = NULL,
                                                @TestsConductedIndicator = NULL,
												@DataAuditEventTypeID =  NULL,
                                                @AuditUserName = @AuditUserName,
                                                @FlocksOrHerds = NULL,
                                                @Species = NULL,
                                                @Animals = NULL,
                                                @Vaccinations = NULL,
                                                @Samples = NULL,
                                                @PensideTests = NULL,
                                                @LaboratoryTests = NULL,
                                                @LaboratoryTestInterpretations = NULL,
                                                @CaseLogs = NULL,
                                                @ClinicalInformation = NULL,
                                                @Contacts = NULL,
                                                @CaseMonitorings = NULL,
                                                @Events = NULL,
                                                @UserID = 0,
                                                @LinkLocalOrFieldSampleIDToReportID = 0,
                                                @OutbreakCaseIndicator = 1,
                                                @OutbreakCaseReportUID = NULL,
                                                @OutbreakCaseStatusTypeID = NULL,
                                                @OutbreakCaseQuestionnaireObservationID = NULL,
                                                @PrimaryCaseIndicator = 0;
        END;

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
