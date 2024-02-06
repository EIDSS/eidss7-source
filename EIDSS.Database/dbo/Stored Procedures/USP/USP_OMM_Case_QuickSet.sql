-- ================================================================================================
-- Name: USP_OMM_Case_QuickSet
--
-- Description: Update for selected outbreak cases' status and classification types and case 
-- monitorings.
--
-- Author: Doug Albanese
--
-- Revision History:
--
-- Name                      Date       Change Detail
-- ------------------------- ---------- ----------------------------------------------------------
-- Stephen Long              04/28/2022 Cleaned up formatting.
-- Stephen Long              06/22/2022 Added case monitorings parameter and call, and audit user 
--                                      name.
-- Stephen Long              07/19/2022 Added site alert logic.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_Case_QuickSet]
(
    @CaseIdentifiers NVARCHAR(MAX) = NULL,
    @StatusTypeId BIGINT = NULL,
    @ClassificationTypeId BIGINT = NULL, 
    @CaseMonitorings NVARCHAR(MAX) = NULL,
    @Events NVARCHAR(MAX) = NULL,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    DECLARE @ReturnCode INT = 0,
            @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
            @Records INT, 
            @EventId BIGINT,
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

    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );

    BEGIN TRY
        IF @StatusTypeId IS NOT NULL
        BEGIN
            UPDATE dbo.OutbreakCaseReport
            SET OutbreakCaseStatusID = @StatusTypeId
            WHERE OutbreakCaseReportUID IN (
                                              SELECT CAST([Value] AS BIGINT)
                                              FROM dbo.FN_GBL_SYS_SplitList(@CaseIdentifiers, NULL, ',')
                                          );
        END

        IF @ClassificationTypeId IS NOT NULL
        BEGIN
            UPDATE dbo.OutbreakCaseReport
            SET OutbreakCaseClassificationID = @ClassificationTypeId
            WHERE OutbreakCaseReportUID IN (
                                              SELECT CAST([Value] AS BIGINT)
                                              FROM dbo.FN_GBL_SYS_SplitList(@CaseIdentifiers, NULL, ',')
                                          );
        END

        IF @CaseMonitorings IS NOT NULL
        BEGIN
            EXEC dbo.USSP_OMM_CASE_MONITORING_SET @CaseMonitorings = @CaseMonitorings,
                                                  @HumanDiseaseReportID = NULL, 
                                                  @VeterinaryDiseaseReportID = NULL, 
                                                  @User = @AuditUserName;
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

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                            @EventTypeId,
                                            @EventUserId,
                                            @EventObjectId,
                                            @EventDiseaseId,
                                            @EventSiteId,
                                            @EventInformationString,
                                            @EventLoginSiteId,
                                            @EventLocationId,
                                            @AuditUserName;

            DELETE FROM @EventsTemp
            WHERE EventId = @EventId;
        END;

        SELECT @ReturnCode AS ReturnCode,
            @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
