-- ================================================================================================
-- Name: USSP_OMM_CASE_MONITORING_SET
--
-- Description: Add or update a case monitoring for outbreak cases.
--          
-- Author: Doug Albanese
--
-- Revision History:
-- Name                     Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Doug Albanese            04/23/2020 Initial Release
-- Stephen Long             04/12/2022 Cleaned up formatting, and updated Source fields.
-- Stephen Long             04/28/2022 Fix to size of additional comments field.
-- Stephen Long             06/22/2022 Added human and veterinary disease report identifiers to the 
--                                     table variable.
-- Stephen Long             06/24/2022 Correction on table variable to match JSON - observation ID.
-- Stephen Long             06/27/2022 Remove suppress select from create of case monitoring.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_OMM_CASE_MONITORING_SET]
    @CaseMonitorings NVARCHAR(MAX),
    @HumanDiseaseReportID BIGINT = NULL,
    @VeterinaryDiseaseReportID BIGINT = NULL,
    @User NVARCHAR(200) = ''
AS
Begin
    SET NOCOUNT ON;

    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage VARCHAR(200)
    );

    DECLARE @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @CaseMonitoringID BIGINT = NULL,
        @ObservationID BIGINT = NULL,
        @InvestigatedByOrganizationID BIGINT = NULL,
        @InvestigatedByPersonID BIGINT = NULL,
        @AdditionalComments NVARCHAR(MAX) = NULL,
        @MonitoringDate DATETIME = NULL,
        @RowStatus INT = 0;

    DECLARE @CaseMonitoringTemp TABLE
    (
        CaseMonitoringID BIGINT NULL,
        HumanDiseaseReportID BIGINT NULL, 
        VeterinaryDiseaseReportID BIGINT NULL, 
        ObservationID BIGINT NULL,
        InvestigatedByOrganizationID BIGINT NULL,
        InvestigatedByPersonID BIGINT NULL,
        AdditionalComments NVARCHAR(MAX) NULL,
        MonitoringDate DATETIME NULL,
        RowStatus INT
    )

    INSERT INTO @CaseMonitoringTemp
    SELECT *
    FROM
        OPENJSON(@CaseMonitorings)
        WITH
        (
            CaseMonitoringID BIGINT,
            HumanDiseaseReportID BIGINT, 
            VeterinaryDiseaseReportID BIGINT, 
            ObservationID BIGINT,
            InvestigatedByOrganizationID BIGINT,
            InvestigatedByPersonID BIGINT,
            AdditionalComments NVARCHAR(MAX),
            MonitoringDate DATETIME2,
            RowStatus INT
        );

    -- New human case is being created, so set the human disease report ID from the parameter.
    IF @HumanDiseaseReportID IS NOT NULL
    BEGIN
        UPDATE @CaseMonitoringTemp
        SET HumanDiseaseReportID = @HumanDiseaseReportID;
    END

    -- New veterinary case is being created, so set the veterinary disease report ID from the parameter.
    IF @VeterinaryDiseaseReportID IS NOT NULL
    BEGIN
        UPDATE @CaseMonitoringTemp
        SET VeterinaryDiseaseReportID = @VeterinaryDiseaseReportID;
    END

    BEGIN TRY
        WHILE EXISTS (SELECT CaseMonitoringID FROM @CaseMonitoringTemp)
        BEGIN
            SELECT TOP 1
                @CaseMonitoringID = CaseMonitoringID,
                @HumanDiseaseReportID = HumanDiseaseReportID, 
                @VeterinaryDiseaseReportID = VeterinaryDiseaseReportID, 
                @ObservationID = ObservationID,
                @InvestigatedByOrganizationID = InvestigatedByOrganizationID,
                @InvestigatedByPersonID = InvestigatedByPersonID,
                @AdditionalComments = AdditionalComments,
                @MonitoringDate = MonitoringDate,
                @RowStatus = RowStatus
            FROM @CaseMonitoringTemp;

            IF (@CaseMonitoringID < 0)
            BEGIN
                EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbOutbreakCaseMonitoring',
                                               @CaseMonitoringID OUTPUT;

                INSERT INTO dbo.tlbOutbreakCaseMonitoring
                (
                    idfOutbreakCaseMonitoring,
                    idfVetCase,
                    idfHumanCase,
                    idfObservation,
                    idfInvestigatedByOffice,
                    idfInvestigatedByPerson,
                    strAdditionalComments,
                    datMonitoringDate,
                    intRowStatus,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser,
                    AuditCreateDTM
                )
                VALUES
                (@CaseMonitoringID,
                 @VeterinaryDiseaseReportID,
                 @HumanDiseaseReportID,
                 @ObservationID,
                 @InvestigatedByOrganizationID,
                 @InvestigatedByPersonID,
                 @AdditionalComments,
                 @MonitoringDate,
                 0,
                 10519001,
                 '[{"idfOutbreakCaseMonitoring":' + CAST(@CaseMonitoringID AS NVARCHAR(300)) + '}]',
                 @User,
                 GETDATE()
                );
            END
            ELSE
            BEGIN
                UPDATE dbo.tlbOutbreakCaseMonitoring
                SET idfInvestigatedByOffice = @InvestigatedByOrganizationID,
                    idfInvestigatedByPerson = @InvestigatedByPersonID,
                    strAdditionalComments = @AdditionalComments,
                    datMonitoringDate = @MonitoringDate,
                    idfObservation = @ObservationID, 
                    intRowStatus = @RowStatus,
                    AuditUpdateUser = @User,
                    AuditUpdateDTM = GETDATE()
                WHERE idfOutbreakCaseMonitoring = @CaseMonitoringID;
            END

            SET ROWCOUNT 1;
            DELETE FROM @CaseMonitoringTemp;
            SET ROWCOUNT 0;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
