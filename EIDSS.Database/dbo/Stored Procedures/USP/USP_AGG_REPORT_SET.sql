﻿-- ================================================================================================
-- Name: USP_AGG_REPORT_SET
--
-- Description: Inserts and updates human and veterinary aggregate disease reports, and veterinary 
-- aggregate action report records.
--          
-- Author: Stephen Long
-- Revision History:
--
-- Name                     Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Stephen Long             05/17/2022 Initial release.
-- Stephen Long             07/06/2022 Updates for site alerts to call new stored procedure.
-- Manickandan Govindarajan 02/06/2022 Data Audit SAUC30 and 31
-- Stephen Long             03/06/2023 Updated object type ID for human aggregate to use 7.0 
--                                     version.
--
-- Testing code:
--
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_AGG_REPORT_SET]
    @AggregateReportID BIGINT = NULL,
    @EIDSSAggregateReportID NVARCHAR(200) = NULL,
    @AggregateReportTypeID BIGINT,
    @GeographicalAdministrativeUnitID BIGINT = NULL,   -- Geographical Statistical Area Type
    @OrganizationalAdministrativeUnitID BIGINT = NULL, -- Organizational Statistical Area Type
    @ReceivedByOrganizationID BIGINT,
    @ReceivedByPersonID BIGINT,
    @SentByOrganizationID BIGINT,
    @SentByPersonID BIGINT,
    @EnteredByOrganizationID BIGINT,
    @EnteredByPersonID BIGINT,
    @CaseObservationID BIGINT = NULL,
    @CaseObservationFormTemplateID BIGINT = NULL,
    @DiagnosticObservationID BIGINT = NULL,
    @DiagnosticObservationFormTemplateID BIGINT = NULL,
    @ProphylacticObservationID BIGINT = NULL,
    @ProphylacticObservationFormTemplateID BIGINT = NULL,
    @SanitaryObservationID BIGINT = NULL,
    @SanitaryObservationFormTemplateID BIGINT = NULL,
    @CaseVersion BIGINT = NULL,
    @DiagnosticVersion BIGINT = NULL,
    @ProphylacticVersion BIGINT = NULL,
    @SanitaryVersion BIGINT = NULL,
    @ReceivedByDate DATETIME,
    @SentByDate DATETIME,
    @EnteredByDate DATETIME,
    @StartDate DATETIME,
    @FinishDate DATETIME,
    @SiteID BIGINT,
    @AuditUserName NVARCHAR(200),
    @UserID BIGINT,
    @Events NVARCHAR(MAX) = NULL
AS
DECLARE @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @RowID BIGINT,
        @EventId BIGINT,
        @EventTypeId BIGINT = NULL,
        @EventSiteId BIGINT = NULL,
        @EventObjectId BIGINT = NULL,
        @EventUserId BIGINT = NULL,
        @EventDiseaseId BIGINT = NULL,
        @EventLocationId BIGINT = NULL,
        @EventInformationString NVARCHAR(MAX) = NULL,
        @EventLoginSiteId BIGINT = NULL;
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage VARCHAR(200)
);
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

-- Data audit
DECLARE @idfsDataAuditEventType BIGINT,
        @idfsObjectType BIGINT,
  @idfObject BIGINT,
  @idfObjectTable_tlbAggrCase BIGINT = 75420000000,
  @idfDataAuditEvent BIGINT,
  @idfUserID BIGINT = @UserID,
  @idfSiteId BIGINT = @SiteID,
  @CaseObservation_table BIGINT;
DECLARE @tlbAggrCase_BeforeEdit TABLE
(
    datEnteredByDate datetime,
    datFinishDate datetime,
    datReceivedByDate datetime,
    datSentByDate datetime,
    datStartDate datetime,
    idfAggrCase bigint,
    idfsAggrCaseType bigint,
    idfsAdministrativeUnit bigint,
    idfReceivedByOffice bigint,
    idfReceivedByPerson bigint,
    idfSentByOffice bigint,
    idfSentByPerson bigint,
    idfEnteredByOffice bigint,
    idfEnteredByPerson bigint,
    idfCaseObservation bigint,
    idfDiagnosticObservation bigint,
    idfProphylacticObservation bigint,
    idfSanitaryObservation bigint,
    idfVersion bigint,
    idfDiagnosticVersion bigint,
    idfProphylacticVersion bigint,
    idfSanitaryVersion bigint,
    strCaseID varchar(200)
);
DECLARE @tlbAggrCase_AfterEdit TABLE
(
    datEnteredByDate datetime,
    datFinishDate datetime,
    datReceivedByDate datetime,
    datSentByDate datetime,
    datStartDate datetime,
    idfAggrCase bigint,
    idfsAggrCaseType bigint,
    idfsAdministrativeUnit bigint,
    idfReceivedByOffice bigint,
    idfReceivedByPerson bigint,
    idfSentByOffice bigint,
    idfSentByPerson bigint,
    idfEnteredByOffice bigint,
    idfEnteredByPerson bigint,
    idfCaseObservation bigint,
    idfDiagnosticObservation bigint,
    idfProphylacticObservation bigint,
    idfSanitaryObservation bigint,
    idfVersion bigint,
    idfDiagnosticVersion bigint,
    idfProphylacticVersion bigint,
    idfSanitaryVersion bigint,
    strCaseID varchar(200)
);
-- End data audit

BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        -- Data audit
        IF @AggregateReportTypeID = 10102001
            SET @idfsObjectType = 10017077; -- Human aggregate disease report
        IF @AggregateReportTypeID = 10102002
            SET @idfsObjectType = 10017005;
        IF @AggregateReportTypeID = 10102003
            SET @idfsObjectType = 10017004;
        --End data audit

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

        IF EXISTS
        (
            SELECT *
            FROM dbo.tlbAggrCase
            WHERE idfAggrCase = @AggregateReportID
        )
        BEGIN
            SET @idfsDataAuditEventType = 10016003;
            SET @idfObject = @AggregateReportID;

            --Data Audit
            -- insert record into tauDataAuditEvent
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @idfUserID,
                                                      @idfSiteId,
                                                      @idfsDataAuditEventType,
                                                      @idfsObjectType,
                                                      @idfObject,
                                                      @idfObjectTable_tlbAggrCase,
                                                      @EIDSSAggregateReportID, 
                                                      @idfDataAuditEvent OUTPUT;

            UPDATE dbo.tauDataAuditEvent
            SET strMainObject = @EIDSSAggregateReportID
            WHERE idfDataAuditEvent = @idfDataAuditEvent;

            --Data Audit

            IF NOT @CaseObservationID IS NULL
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_AGG_OBSERVATION_SET @CaseObservationID,
                                                 @CaseObservationFormTemplateID,
                                                 @idfDataAuditEvent;

                UPDATE dbo.tauDataAuditDetailCreate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @CaseObservationID
                      AND idfDataAuditEvent IS NULL;

                UPDATE dbo.tauDataAuditDetailUpdate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @CaseObservationID
                      AND idfDataAuditEvent IS NULL;
            END

            IF NOT @DiagnosticObservationID IS NULL
            BEGIN
                print '@DiagnosticObservationID'
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_AGG_OBSERVATION_SET @DiagnosticObservationID,
                                                 @DiagnosticObservationFormTemplateID,
                                                 @idfDataAuditEvent;

                UPDATE dbo.tauDataAuditDetailCreate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @DiagnosticObservationID
                      AND idfDataAuditEvent IS NULL;


                UPDATE dbo.tauDataAuditDetailUpdate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @DiagnosticObservationID
                      AND idfDataAuditEvent IS NULL;
            END

            IF NOT @ProphylacticObservationID IS NULL
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_AGG_OBSERVATION_SET @ProphylacticObservationID,
                                                 @ProphylacticObservationFormTemplateID,
                                                 @idfDataAuditEvent;
                UPDATE dbo.tauDataAuditDetailCreate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @ProphylacticObservationID
                      AND idfDataAuditEvent IS NULL;

                UPDATE dbo.tauDataAuditDetailUpdate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @ProphylacticObservationID
                      AND idfDataAuditEvent IS NULL;
            END

            IF NOT @SanitaryObservationID IS NULL
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_AGG_OBSERVATION_SET @SanitaryObservationID,
                                                 @SanitaryObservationFormTemplateID,
                                                 @idfDataAuditEvent;
                UPDATE dbo.tauDataAuditDetailCreate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @SanitaryObservationID
                      AND idfDataAuditEvent IS NULL;

                UPDATE dbo.tauDataAuditDetailUpdate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @SanitaryObservationID
                      AND idfDataAuditEvent IS NULL;


            END


            insert into @tlbAggrCase_BeforeEdit
            (
                datEnteredByDate,
                datFinishDate,
                datReceivedByDate,
                datSentByDate,
                datStartDate,
                idfAggrCase,
                idfsAggrCaseType,
                idfsAdministrativeUnit,
                idfReceivedByOffice,
                idfReceivedByPerson,
                idfSentByOffice,
                idfSentByPerson,
                idfEnteredByOffice,
                idfEnteredByPerson,
                idfCaseObservation,
                idfDiagnosticObservation,
                idfProphylacticObservation,
                idfSanitaryObservation,
                idfVersion,
                idfDiagnosticVersion,
                idfProphylacticVersion,
                idfSanitaryVersion,
                strCaseID
            )
            select datEnteredByDate,
                   datFinishDate,
                   datReceivedByDate,
                   datSentByDate,
                   datStartDate,
                   idfAggrCase,
                   idfsAggrCaseType,
                   idfsAdministrativeUnit,
                   idfReceivedByOffice,
                   idfReceivedByPerson,
                   idfSentByOffice,
                   idfSentByPerson,
                   idfEnteredByOffice,
                   idfEnteredByPerson,
                   idfCaseObservation,
                   idfDiagnosticObservation,
                   idfProphylacticObservation,
                   idfSanitaryObservation,
                   idfVersion,
                   idfDiagnosticVersion,
                   idfProphylacticVersion,
                   idfSanitaryVersion,
                   strCaseID
            from tlbAggrCase
            where idfAggrCase = @AggregateReportID;


            UPDATE dbo.tlbAggrCase
            SET idfsAggrCaseType = @AggregateReportTypeID,
                idfsAdministrativeUnit = @GeographicalAdministrativeUnitID,
                idfOffice = @OrganizationalAdministrativeUnitID,
                idfReceivedByOffice = @ReceivedByOrganizationID,
                idfReceivedByPerson = @ReceivedByPersonID,
                idfSentByOffice = @SentByOrganizationID,
                idfSentByPerson = @SentByPersonID,
                idfCaseObservation = @CaseObservationID,
                idfDiagnosticObservation = @DiagnosticObservationID,
                idfProphylacticObservation = @ProphylacticObservationID,
                idfSanitaryObservation = @SanitaryObservationID,
                idfVersion = @CaseVersion,
                idfDiagnosticVersion = @DiagnosticVersion,
                idfProphylacticVersion = @ProphylacticVersion,
                idfSanitaryVersion = @SanitaryVersion,
                datReceivedByDate = @ReceivedByDate,
                datSentByDate = @SentByDate,
                datStartDate = @StartDate,
                datFinishDate = @FinishDate,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName,
                idfsSite = @SiteID
            WHERE idfAggrCase = @AggregateReportID;

            --Data Audit
            insert into @tlbAggrCase_AfterEdit
            (
                datEnteredByDate,
                datFinishDate,
                datReceivedByDate,
                datSentByDate,
                datStartDate,
                idfAggrCase,
                idfsAggrCaseType,
                idfsAdministrativeUnit,
                idfReceivedByOffice,
                idfReceivedByPerson,
                idfSentByOffice,
                idfSentByPerson,
                idfEnteredByOffice,
                idfEnteredByPerson,
                idfCaseObservation,
                idfDiagnosticObservation,
                idfProphylacticObservation,
                idfSanitaryObservation,
                idfVersion,
                idfDiagnosticVersion,
                idfProphylacticVersion,
                idfSanitaryVersion,
                strCaseID
            )
            select datEnteredByDate,
                   datFinishDate,
                   datReceivedByDate,
                   datSentByDate,
                   datStartDate,
                   idfAggrCase,
                   idfsAggrCaseType,
                   idfsAdministrativeUnit,
                   idfReceivedByOffice,
                   idfReceivedByPerson,
                   idfSentByOffice,
                   idfSentByPerson,
                   idfEnteredByOffice,
                   idfEnteredByPerson,
                   idfCaseObservation,
                   idfDiagnosticObservation,
                   idfProphylacticObservation,
                   idfSanitaryObservation,
                   idfVersion,
                   idfDiagnosticVersion,
                   idfProphylacticVersion,
                   idfSanitaryVersion,
                   strCaseID
            from tlbAggrCase
            where idfAggrCase = @AggregateReportID;

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   78200000000,
                   a.idfAggrCase,
                   null,
                   a.datEnteredByDate,
                   b.datEnteredByDate
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.datEnteredByDate <> b.datEnteredByDate)
                  or (
                         a.datEnteredByDate is not null
                         and b.datEnteredByDate is null
                     )
                  or (
                         a.datEnteredByDate is null
                         and b.datEnteredByDate is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   78210000000,
                   a.idfAggrCase,
                   null,
                   a.datFinishDate,
                   b.datFinishDate
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.datFinishDate <> b.datFinishDate)
                  or (
                         a.datFinishDate is not null
                         and b.datFinishDate is null
                     )
                  or (
                         a.datFinishDate is null
                         and b.datFinishDate is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   78220000000,
                   a.idfAggrCase,
                   null,
                   a.datReceivedByDate,
                   b.datReceivedByDate
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.datReceivedByDate <> b.datReceivedByDate)
                  or (
                         a.datReceivedByDate is not null
                         and b.datReceivedByDate is null
                     )
                  or (
                         a.datReceivedByDate is null
                         and b.datReceivedByDate is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   78230000000,
                   a.idfAggrCase,
                   null,
                   a.datSentByDate,
                   b.datSentByDate
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.datSentByDate <> b.datSentByDate)
                  or (
                         a.datSentByDate is not null
                         and b.datSentByDate is null
                     )
                  or (
                         a.datSentByDate is null
                         and b.datSentByDate is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   78240000000,
                   a.idfAggrCase,
                   null,
                   a.datStartDate,
                   b.datStartDate
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.datStartDate <> b.datStartDate)
                  or (
                         a.datStartDate is not null
                         and b.datStartDate is null
                     )
                  or (
                         a.datStartDate is null
                         and b.datStartDate is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   78260000000,
                   a.idfAggrCase,
                   null,
                   a.idfsAggrCaseType,
                   b.idfsAggrCaseType
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfsAggrCaseType <> b.idfsAggrCaseType)
                  or (
                         a.idfsAggrCaseType is not null
                         and b.idfsAggrCaseType is null
                     )
                  or (
                         a.idfsAggrCaseType is null
                         and b.idfsAggrCaseType is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577520000000,
                   a.idfAggrCase,
                   null,
                   a.idfsAdministrativeUnit,
                   b.idfsAdministrativeUnit
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfsAdministrativeUnit <> b.idfsAdministrativeUnit)
                  or (
                         a.idfsAdministrativeUnit is not null
                         and b.idfsAdministrativeUnit is null
                     )
                  or (
                         a.idfsAdministrativeUnit is null
                         and b.idfsAdministrativeUnit is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577530000000,
                   a.idfAggrCase,
                   null,
                   a.idfReceivedByOffice,
                   b.idfReceivedByOffice
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfReceivedByOffice <> b.idfReceivedByOffice)
                  or (
                         a.idfReceivedByOffice is not null
                         and b.idfReceivedByOffice is null
                     )
                  or (
                         a.idfReceivedByOffice is null
                         and b.idfReceivedByOffice is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577540000000,
                   a.idfAggrCase,
                   null,
                   a.idfReceivedByPerson,
                   b.idfReceivedByPerson
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfReceivedByPerson <> b.idfReceivedByPerson)
                  or (
                         a.idfReceivedByPerson is not null
                         and b.idfReceivedByPerson is null
                     )
                  or (
                         a.idfReceivedByPerson is null
                         and b.idfReceivedByPerson is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577550000000,
                   a.idfAggrCase,
                   null,
                   a.idfSentByOffice,
                   b.idfSentByOffice
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfSentByOffice <> b.idfSentByOffice)
                  or (
                         a.idfSentByOffice is not null
                         and b.idfSentByOffice is null
                     )
                  or (
                         a.idfSentByOffice is null
                         and b.idfSentByOffice is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577560000000,
                   a.idfAggrCase,
                   null,
                   a.idfSentByPerson,
                   b.idfSentByPerson
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfSentByPerson <> b.idfSentByPerson)
                  or (
                         a.idfSentByPerson is not null
                         and b.idfSentByPerson is null
                     )
                  or (
                         a.idfSentByPerson is null
                         and b.idfSentByPerson is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577570000000,
                   a.idfAggrCase,
                   null,
                   a.idfEnteredByOffice,
                   b.idfEnteredByOffice
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfEnteredByOffice <> b.idfEnteredByOffice)
                  or (
                         a.idfEnteredByOffice is not null
                         and b.idfEnteredByOffice is null
                     )
                  or (
                         a.idfEnteredByOffice is null
                         and b.idfEnteredByOffice is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577580000000,
                   a.idfAggrCase,
                   null,
                   a.idfEnteredByPerson,
                   b.idfEnteredByPerson
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfEnteredByPerson <> b.idfEnteredByPerson)
                  or (
                         a.idfEnteredByPerson is not null
                         and b.idfEnteredByPerson is null
                     )
                  or (
                         a.idfEnteredByPerson is null
                         and b.idfEnteredByPerson is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577590000000,
                   a.idfAggrCase,
                   null,
                   a.idfCaseObservation,
                   b.idfCaseObservation
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfCaseObservation <> b.idfCaseObservation)
                  or (
                         a.idfCaseObservation is not null
                         and b.idfCaseObservation is null
                     )
                  or (
                         a.idfCaseObservation is null
                         and b.idfCaseObservation is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577600000000,
                   a.idfAggrCase,
                   null,
                   a.idfDiagnosticObservation,
                   b.idfDiagnosticObservation
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfDiagnosticObservation <> b.idfDiagnosticObservation)
                  or (
                         a.idfDiagnosticObservation is not null
                         and b.idfDiagnosticObservation is null
                     )
                  or (
                         a.idfDiagnosticObservation is null
                         and b.idfDiagnosticObservation is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577610000000,
                   a.idfAggrCase,
                   null,
                   a.idfProphylacticObservation,
                   b.idfProphylacticObservation
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfProphylacticObservation <> b.idfProphylacticObservation)
                  or (
                         a.idfProphylacticObservation is not null
                         and b.idfProphylacticObservation is null
                     )
                  or (
                         a.idfProphylacticObservation is null
                         and b.idfProphylacticObservation is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577620000000,
                   a.idfAggrCase,
                   null,
                   a.idfSanitaryObservation,
                   b.idfSanitaryObservation
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfSanitaryObservation <> b.idfSanitaryObservation)
                  or (
                         a.idfSanitaryObservation is not null
                         and b.idfSanitaryObservation is null
                     )
                  or (
                         a.idfSanitaryObservation is null
                         and b.idfSanitaryObservation is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577630000000,
                   a.idfAggrCase,
                   null,
                   a.idfVersion,
                   b.idfVersion
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfVersion <> b.idfVersion)
                  or (
                         a.idfVersion is not null
                         and b.idfVersion is null
                     )
                  or (
                         a.idfVersion is null
                         and b.idfVersion is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577640000000,
                   a.idfAggrCase,
                   null,
                   a.idfDiagnosticVersion,
                   b.idfDiagnosticVersion
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfDiagnosticVersion <> b.idfDiagnosticVersion)
                  or (
                         a.idfDiagnosticVersion is not null
                         and b.idfDiagnosticVersion is null
                     )
                  or (
                         a.idfDiagnosticVersion is null
                         and b.idfDiagnosticVersion is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577650000000,
                   a.idfAggrCase,
                   null,
                   a.idfProphylacticVersion,
                   b.idfProphylacticVersion
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfProphylacticVersion <> b.idfProphylacticVersion)
                  or (
                         a.idfProphylacticVersion is not null
                         and b.idfProphylacticVersion is null
                     )
                  or (
                         a.idfProphylacticVersion is null
                         and b.idfProphylacticVersion is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577660000000,
                   a.idfAggrCase,
                   null,
                   a.idfSanitaryVersion,
                   b.idfSanitaryVersion
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.idfSanitaryVersion <> b.idfSanitaryVersion)
                  or (
                         a.idfSanitaryVersion is not null
                         and b.idfSanitaryVersion is null
                     )
                  or (
                         a.idfSanitaryVersion is null
                         and b.idfSanitaryVersion is not null
                     )

            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            select @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   4577670000000,
                   a.idfAggrCase,
                   null,
                   a.strCaseID,
                   b.strCaseID
            from @tlbAggrCase_BeforeEdit a
                inner join @tlbAggrCase_AfterEdit b
                    on a.idfAggrCase = b.idfAggrCase
            where (a.strCaseID <> b.strCaseID)
                  or (
                         a.strCaseID is not null
                         and b.strCaseID is null
                     )
                  or (
                         a.strCaseID is null
                         and b.strCaseID is not null
                     )

        --Data Audit
        END
        ELSE
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAggrCase', @AggregateReportID OUTPUT;

            IF ISNULL(@EIDSSAggregateReportID, N'') = N''
               OR LEFT(ISNULL(@EIDSSAggregateReportID, N''), 4) = '(new'
            BEGIN
                DECLARE @ObjectName NVARCHAR(600);

                SET @ObjectName = CASE @AggregateReportTypeID
                                      WHEN 10102001 THEN
                                          'Human Aggregate Disease Report' --tstNextNumbers.idfsNumberName = 10057001
                                      WHEN 10102002 THEN
                                          'Vet Aggregate Disease Report'   --tstNextNumbers.idfsNumberName = 10057003
                                      WHEN 10102003 THEN
                                          'Vet Aggregate Action'           --tstNextNumbers.idfsNumberName = 10057002
                                  END;

                INSERT INTO @SuppressSelect
                EXEC dbo.USP_GBL_NextNumber_GET @ObjectName,
                                                @EIDSSAggregateReportID OUTPUT,
                                                NULL;
            END

            SET @idfsDataAuditEventType = 10016001;
            SET @idfObject = @AggregateReportID;

            DECLARE @MatrixTypeID BIGINT;
            SET @MatrixTypeID = CASE @AggregateReportTypeID
                                    WHEN 10102001 -- Human Aggregate Disease Report
            THEN
                                        71190000000 --tstNextNumbers.idfsNumberName = 10057001
                                    WHEN 10102002 -- Veterinary Aggregate Disease Report
            THEN
                                        71090000000 --tstNextNumbers.idfsNumberName = 10057003
                                END;

            INSERT INTO dbo.tlbAggrCase
            (
                idfAggrCase,
                idfsAggrCaseType,
                idfsAdministrativeUnit,
                idfOffice,
                idfReceivedByOffice,
                idfReceivedByPerson,
                idfSentByOffice,
                idfSentByPerson,
                idfEnteredByOffice,
                idfEnteredByPerson,
                idfCaseObservation,
                idfDiagnosticObservation,
                idfProphylacticObservation,
                idfSanitaryObservation,
                idfVersion,
                idfDiagnosticVersion,
                idfProphylacticVersion,
                idfSanitaryVersion,
                datReceivedByDate,
                datSentByDate,
                datEnteredByDate,
                datStartDate,
                datFinishDate,
                strCaseID,
                idfsSite,
                AuditCreateDTM,
                AuditCreateUser,
                SourceSystemKeyValue,
                SourceSystemNameID
            )
            VALUES
            (@AggregateReportID,
             @AggregateReportTypeID,
             @GeographicalAdministrativeUnitID,
             @OrganizationalAdministrativeUnitID,
             @ReceivedByOrganizationID,
             @ReceivedByPersonID,
             @SentByOrganizationID,
             @SentByPersonID,
             @EnteredByOrganizationID,
             @EnteredByPersonID,
             @CaseObservationID,
             @DiagnosticObservationID,
             @ProphylacticObservationID,
             @SanitaryObservationID,
             @CaseVersion,
             @DiagnosticVersion,
             @ProphylacticVersion,
             @SanitaryVersion,
             @ReceivedByDate,
             @SentByDate,
             @EnteredByDate,
             @StartDate,
             @FinishDate,
             @EIDSSAggregateReportID,
             @SiteID,
             GETDATE(),
             @AuditUserName,
             '[{"idfAggrCase":' + CAST(@AggregateReportID AS NVARCHAR(300)) + '}]',
             10519001
            );

            --Data Audit--

            --Data Audit
            -- insert record into tauDataAuditEvent
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @idfUserID,
                                                      @idfSiteId,
                                                      @idfsDataAuditEventType,
                                                      @idfsObjectType,
                                                      @idfObject,
                                                      @idfObjectTable_tlbAggrCase,
                                                      @EIDSSAggregateReportID, 
                                                      @idfDataAuditEvent OUTPUT;

            UPDATE dbo.tauDataAuditEvent
            SET strMainObject = @EIDSSAggregateReportID
            WHERE idfDataAuditEvent = @idfDataAuditEvent;

            INSERT INTO dbo.tauDataAuditDetailCreate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                strObject
            )
            VALUES
            (@idfDataAuditEvent, @idfObjectTable_tlbAggrCase, @AggregateReportID, @EIDSSAggregateReportID);
            --Data Audit

            IF NOT @CaseObservationID IS NULL
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_AGG_OBSERVATION_SET @CaseObservationID,
                                                 @CaseObservationFormTemplateID,
                                                 @idfDataAuditEvent;
                UPDATE dbo.tauDataAuditDetailCreate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @CaseObservationID
                      AND idfDataAuditEvent IS NULL;

                UPDATE dbo.tauDataAuditDetailUpdate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @CaseObservationID
                      AND idfDataAuditEvent IS NULL;
            END

            IF NOT @DiagnosticObservationID IS NULL
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_AGG_OBSERVATION_SET @DiagnosticObservationID,
                                                 @DiagnosticObservationFormTemplateID,
                                                 @idfDataAuditEvent;
                UPDATE dbo.tauDataAuditDetailCreate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @DiagnosticObservationID
                      AND idfDataAuditEvent IS NULL;

                UPDATE dbo.tauDataAuditDetailUpdate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @DiagnosticObservationID
                      AND idfDataAuditEvent IS NULL;
            END

            IF NOT @ProphylacticObservationID IS NULL
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_AGG_OBSERVATION_SET @ProphylacticObservationID,
                                                 @ProphylacticObservationFormTemplateID,
                                                 @idfDataAuditEvent;

                UPDATE dbo.tauDataAuditDetailCreate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @ProphylacticObservationID
                      AND idfDataAuditEvent IS NULL;

                UPDATE dbo.tauDataAuditDetailUpdate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @ProphylacticObservationID
                      AND idfDataAuditEvent IS NULL;
            END

            IF NOT @SanitaryObservationID IS NULL
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_AGG_OBSERVATION_SET @SanitaryObservationID,
                                                 @SanitaryObservationFormTemplateID,
                                                 @idfDataAuditEvent;

                UPDATE dbo.tauDataAuditDetailCreate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @SanitaryObservationID
                      AND idfDataAuditEvent IS NULL;

                UPDATE dbo.tauDataAuditDetailUpdate
                SET idfDataAuditEvent = @idfDataAuditEvent,
                    strObject = @EIDSSAggregateReportID
                WHERE idfObjectDetail = @SanitaryObservationID
                      AND idfDataAuditEvent IS NULL;

            END

            UPDATE @EventsTemp
            SET ObjectId = @AggregateReportID
            WHERE ObjectId = 0;
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

        IF @@TRANCOUNT > 0
            COMMIT;

        SELECT @ReturnCode 'ReturnCode',
               @ReturnMessage 'ReturnMessage',
               @AggregateReportID 'AggregateReportID',
               @CaseVersion 'CaseVersion',
               @EIDSSAggregateReportID 'EIDSSAggregateReportID';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;
    END CATCH
END