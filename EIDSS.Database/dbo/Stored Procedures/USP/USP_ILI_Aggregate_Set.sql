-- ================================================================================================
-- Name: USP_ILI_Aggregate_Set
--
-- Description: Insert and update for ILI aggregate forms.
--          
-- Author: Arnold Kennedy
--
-- Revision History:
-- Name                    Date       Change Detail
-- ----------------------- ---------- ------------------------------------------------------------
-- Lamont Mitchell         07/13/2019 Udated to include FormId
-- Ann Xiong               02/28/2020 Modified to save a list of rows instead of one single row to 
--                                    table tlbBasicSyndromicSurveillanceAggregateDetail 
-- Leo Tracchia            03/13/2022 Altered logic for better handling of updates
-- Stephen Long            07/12/2022 Added events parameter and site alert logic.
-- Stephen Long            12/01/2022 Added data audit logic for SAUC30 and 31.
-- Stephen Long            03/06/2023 Fix to use correct object type on data audit.
-- Stephen Long            03/09/2023 Moved data event audit call after EIDSS ID is obtained.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ILI_Aggregate_Set]
(
    @idfAggregateHeader BIGINT = -1,
    @idfEnteredBy BIGINT,
    @idfsSite BIGINT,
    @intYear INT,
    @intWeek INT,
    @datStartDate DATETIME,
    @datFinishDate DATETIME,
    @strFormId VARCHAR(MAX) = NULL,
    @RowStatus INT,
    @AuditUserName NVARCHAR(200),
    @ILITables NVARCHAR(MAX),
    @Events NVARCHAR(MAX) = NULL
)
AS
BEGIN
    DECLARE @ReturnCode INT = 0,
            @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
            @EventID BIGINT,
            @EventTypeID BIGINT = NULL,
            @EventSiteID BIGINT = NULL,
            @EventObjectID BIGINT = NULL,
            @EventUserID BIGINT = NULL,
            @EventDiseaseID BIGINT = NULL,
            @EventLocationID BIGINT = NULL,
            @EventInformationString NVARCHAR(MAX) = NULL,
            @EventLoginSiteID BIGINT = NULL,
                                                    -- Data audit
            @AuditUserID BIGINT = NULL,
            @AuditSiteID BIGINT = NULL,
            @DataAuditEventID BIGINT = NULL,
            @DataAuditEventTypeID BIGINT = NULL,
            @ObjectTypeID BIGINT = 10017075,        -- ILI aggregate
            @ObjectID BIGINT = @idfAggregateHeader,
            @ObjectTableID BIGINT = 50791690000000; -- tlbBasicSyndromicSurveillanceAggregateHeader
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );
    DECLARE @idfHospital BIGINT,
            @idfAggregateDetail BIGINT,
            @intAge0_4 INT = NULL,
            @intAge5_14 INT = NULL,
            @intAge15_29 INT = NULL,
            @intAge30_64 INT = NULL,
            @intAge65 INT = NULL,
            @inTotalILI INT = NULL,
            @intTotalAdmissions INT = NULL,
            @intILISamples INT = NULL,
            @RowID BIGINT = NULL,
            @RowAction CHAR(1) = NULL;
    DECLARE @ILITablesTemp TABLE
    (
        idfAggregateDetail BIGINT NOT NULL,
        idfHospital BIGINT NULL,
        intAge0_4 INT,
        intAge5_14 INT,
        intAge15_29 INT,
        intAge30_64 INT,
        intAge65 INT,
        inTotalILI INT,
        intTotalAdmissions INT,
        intILISamples INT,
        RowStatus INT NULL,
        RowAction CHAR(1) NULL,
        RowId BIGINT
    );
    DECLARE @ILIAggregateHeaderBeforeEdit TABLE
    (
        AggregateHeaderID BIGINT,
        FormID NVARCHAR(200),
        DateEntered DATETIME,
        DateLastSaved DATETIME,
        EnteredByID BIGINT,
        YearValue INT,
        WeekValue INT,
        StartDate DATETIME,
        FinishDate DATETIME
    );
    DECLARE @ILIAggregateHeaderAfterEdit TABLE
    (
        AggregateHeaderID BIGINT,
        FormID NVARCHAR(200),
        DateEntered DATETIME,
        DateLastSaved DATETIME,
        EnteredByID BIGINT,
        YearValue INT,
        WeekValue INT,
        StartDate DATETIME,
        FinishDate DATETIME
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

    BEGIN TRY
        BEGIN TRANSACTION

        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        INSERT INTO @ILITablesTemp
        SELECT *
        FROM
            OPENJSON(@ILITables)
            WITH
            (
                IdfAggregateDetail BIGINT,
                IdfHospital BIGINT,
                IntAge0_4 INT,
                IntAge5_14 INT,
                IntAge15_29 INT,
                IntAge30_64 INT,
                IntAge65 INT,
                InTotalILI INT,
                IntTotalAdmissions INT,
                IntILISamples INT,
                RowStatus INT,
                RowAction CHAR(1),
                RowId BIGINT
            );

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

        -- Update the header if this is an edit
        IF EXISTS
        (
            SELECT *
            FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader
            WHERE idfAggregateHeader = @idfAggregateHeader
        )
        BEGIN
            -- Data audit
            SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @idfAggregateHeader,
                                                      @ObjectTableID,
                                                      @strFormID, 
                                                      @DataAuditEventID OUTPUT;

            INSERT INTO @ILIAggregateHeaderBeforeEdit
            (
                AggregateHeaderID,
                FormID,
                DateEntered,
                DateLastSaved,
                EnteredByID,
                YearValue,
                WeekValue,
                StartDate,
                FinishDate
            )
            SELECT idfAggregateHeader,
                   strFormID,
                   datDateEntered,
                   datDateLastSaved,
                   idfEnteredBy,
                   intYear,
                   intWeek,
                   datStartDate,
                   datFinishDate
            FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader
            WHERE idfAggregateHeader = @idfAggregateHeader;
            -- End data audit

            UPDATE dbo.tlbBasicSyndromicSurveillanceAggregateHeader
            SET intYear = @intYear,
                intWeek = @intWeek,
                datStartDate = @datStartDate,
                datFinishDate = @datFinishDate,
                datDateLastSaved = GETDATE(),
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfAggregateHeader = @idfAggregateHeader;

            -- Data audit
            INSERT INTO @ILIAggregateHeaderAfterEdit
            (
                AggregateHeaderID,
                FormID,
                DateEntered,
                DateLastSaved,
                EnteredByID,
                YearValue,
                WeekValue,
                StartDate,
                FinishDate
            )
            SELECT idfAggregateHeader,
                   strFormID,
                   datDateEntered,
                   datDateLastSaved,
                   idfEnteredBy,
                   intYear,
                   intWeek,
                   datStartDate,
                   datFinishDate
            FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader
            WHERE idfAggregateHeader = @idfAggregateHeader;

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue, 
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   50791710000000,
                   a.AggregateHeaderID,
                   NULL,
                   b.FormID,
                   a.FormID,
                   a.FormID
            FROM @ILIAggregateHeaderAfterEdit AS a
                FULL JOIN @ILIAggregateHeaderBeforeEdit AS b
                    ON a.AggregateHeaderID = b.AggregateHeaderID
            WHERE (a.FormID <> b.FormID)
                  OR (
                         a.FormID IS NOT NULL
                         AND b.FormID IS NULL
                     )
                  OR (
                         a.FormID IS NULL
                         AND b.FormID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue, 
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   50791720000000,
                   a.AggregateHeaderID,
                   NULL,
                   b.DateEntered,
                   a.DateEntered, 
                   a.FormID
            FROM @ILIAggregateHeaderAfterEdit AS a
                FULL JOIN @ILIAggregateHeaderBeforeEdit AS b
                    ON a.AggregateHeaderID = b.AggregateHeaderID
            WHERE (a.DateEntered <> b.DateEntered)
                  OR (
                         a.DateEntered IS NOT NULL
                         AND b.DateEntered IS NULL
                     )
                  OR (
                         a.DateEntered IS NULL
                         AND b.DateEntered IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   50791730000000,
                   a.AggregateHeaderID,
                   NULL,
                   b.DateLastSaved,
                   a.DateLastSaved,
                   a.FormID
            FROM @ILIAggregateHeaderAfterEdit AS a
                FULL JOIN @ILIAggregateHeaderBeforeEdit AS b
                    ON a.AggregateHeaderID = b.AggregateHeaderID
            WHERE (a.DateLastSaved <> b.DateLastSaved)
                  OR (
                         a.DateLastSaved IS NOT NULL
                         AND b.DateLastSaved IS NULL
                     )
                  OR (
                         a.DateLastSaved IS NULL
                         AND b.DateLastSaved IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue, 
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   50791740000000,
                   a.AggregateHeaderID,
                   NULL,
                   b.EnteredByID,
                   a.EnteredByID,
                   a.FormID 
            FROM @ILIAggregateHeaderAfterEdit AS a
                FULL JOIN @ILIAggregateHeaderBeforeEdit AS b
                    ON a.AggregateHeaderID = b.AggregateHeaderID
            WHERE (a.EnteredByID <> b.EnteredByID)
                  OR (
                         a.EnteredByID IS NOT NULL
                         AND b.EnteredByID IS NULL
                     )
                  OR (
                         a.EnteredByID IS NULL
                         AND b.EnteredByID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   50791750000000,
                   a.AggregateHeaderID,
                   NULL,
                   b.YearValue,
                   a.YearValue,
                   a.FormID
            FROM @ILIAggregateHeaderAfterEdit AS a
                FULL JOIN @ILIAggregateHeaderBeforeEdit AS b
                    ON a.AggregateHeaderID = b.AggregateHeaderID
            WHERE (a.YearValue <> b.YearValue)
                  OR (
                         a.YearValue IS NOT NULL
                         AND b.YearValue IS NULL
                     )
                  OR (
                         a.YearValue IS NULL
                         AND b.YearValue IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   50791760000000,
                   a.AggregateHeaderID,
                   NULL,
                   b.WeekValue,
                   a.WeekValue,
                   a.FormID
            FROM @ILIAggregateHeaderAfterEdit AS a
                FULL JOIN @ILIAggregateHeaderBeforeEdit AS b
                    ON a.AggregateHeaderID = b.AggregateHeaderID
            WHERE (a.WeekValue <> b.WeekValue)
                  OR (
                         a.WeekValue IS NOT NULL
                         AND b.WeekValue IS NULL
                     )
                  OR (
                         a.WeekValue IS NULL
                         AND b.WeekValue IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   50791770000000,
                   a.AggregateHeaderID,
                   NULL,
                   b.StartDate,
                   a.StartDate,
                   a.FormID 
            FROM @ILIAggregateHeaderAfterEdit AS a
                FULL JOIN @ILIAggregateHeaderBeforeEdit AS b
                    ON a.AggregateHeaderID = b.AggregateHeaderID
            WHERE (a.StartDate <> b.StartDate)
                  OR (
                         a.StartDate IS NOT NULL
                         AND b.StartDate IS NULL
                     )
                  OR (
                         a.StartDate IS NULL
                         AND b.StartDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   50791780000000,
                   a.AggregateHeaderID,
                   NULL,
                   b.FinishDate,
                   a.FinishDate,
                   a.FormID
            FROM @ILIAggregateHeaderAfterEdit AS a
                FULL JOIN @ILIAggregateHeaderBeforeEdit AS b
                    ON a.AggregateHeaderID = b.AggregateHeaderID
            WHERE (a.FinishDate <> b.FinishDate)
                  OR (
                         a.FinishDate IS NOT NULL
                         AND b.FinishDate IS NULL
                     )
                  OR (
                         a.FinishDate IS NULL
                         AND b.FinishDate IS NOT NULL
                     );
        -- End data audit
        END
        ELSE
        BEGIN
            -- Get new PK for insert
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbBasicSyndromicSurveillanceAggregateHeader',
                                               @idfAggregateHeader OUTPUT;
            END

            -- Get New Smartkey
            IF ISNULL(@strFormID, N'') = N''
               OR LEFT(ISNULL(@strFormID, N''), 4) = '(new'
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_GBL_NextNumber_GET 'Basic Syndromic Surveillance Aggregate Form',
                                                @strFormID OUTPUT,
                                                NULL;
            END

            -- Data audit
            SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @idfAggregateHeader,
                                                      @ObjectTableID,
                                                      @strFormID, 
                                                      @DataAuditEventID OUTPUT;
            -- End data audit
			Declare @getDate DateTime = GETDATE();
            INSERT INTO dbo.tlbBasicSyndromicSurveillanceAggregateHeader
            (
                idfAggregateHeader,
                strFormID,
                datDateEntered,
                datDateLastSaved,
                idfEnteredBy,
                idfsSite,
                intYear,
                intWeek,
                datStartDate,
                datFinishDate,
                datModificationForArchiveDate,
                strMaintenanceFlag,
                strReservedAttribute,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (   @idfAggregateHeader,
                @strFormID,
                @getDate,
                @getDate,
                @idfEnteredBy,
                @idfsSite,
                @intYear,
                @intWeek,
                @datStartDate,
                @datFinishDate,
                @getDate,
                'system',
                'V7 ILI Syndromic Surveillance Aggregate Form',
                10519001, -- EIDSS7
                '[{"idfAggregateHeader":' + CAST(@idfAggregateHeader AS NVARCHAR(300)) + '}]',
                GETDATE(),
                @AuditUserName
            );

            UPDATE @EventsTemp
            SET ObjectId = @idfAggregateHeader
            WHERE ObjectId = 0;

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailCreate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser, 
                strObject
            )
            VALUES
            (@DataAuditEventID,
             @ObjectTableID,
             @idfAggregateHeader,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName, 
             @strFormID
            );
        -- End data audit
        END

        WHILE EXISTS (SELECT * FROM @ILITablesTemp)
        BEGIN
            SELECT TOP 1
                @RowID = RowId,
                @idfAggregateDetail = idfAggregateDetail,
                @RowStatus = RowStatus,
                @idfHospital = idfHospital,
                @intAge0_4 = intAge0_4,
                @intAge5_14 = intAge5_14,
                @intAge15_29 = intAge15_29,
                @intAge30_64 = intAge30_64,
                @intAge65 = intAge65,
                @inTotalILI = inTotalILI,
                @intTotalAdmissions = intTotalAdmissions,
                @intILISamples = intILISamples,
                @RowAction = RowAction
            FROM @ILITablesTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ILI_Aggregate_Detail_SET @idfAggregateDetail,
                                                     @idfAggregateHeader,
                                                     @RowStatus,
                                                     @idfHospital,
                                                     @intAge0_4,
                                                     @intAge5_14,
                                                     @intAge15_29,
                                                     @intAge30_64,
                                                     @intAge65,
                                                     @inTotalILI,
                                                     @intTotalAdmissions,
                                                     @intILISamples,
                                                     @AuditUserName,
                                                     @DataAuditEventID, 
                                                     @strFormID, 
                                                     @RowAction;

            DELETE FROM @ILITablesTemp
            WHERE RowId = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @EventsTemp)
        BEGIN
            SELECT TOP 1
                @EventID = EventId,
                @EventTypeID = EventTypeId,
                @EventUserID = UserId,
                @EventObjectID = ObjectId,
                @EventSiteID = SiteId,
                @EventDiseaseID = DiseaseId,
                @EventLocationID = LocationId,
                @EventInformationString = InformationString,
                @EventLoginSiteID = LoginSiteId
            FROM @EventsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_ADMIN_EVENT_SET @EventID,
                                             @EventTypeID,
                                             @EventUserID,
                                             @EventObjectID,
                                             @EventDiseaseID,
                                             @EventSiteID,
                                             @EventInformationString,
                                             @EventLoginSiteID,
                                             @EventLocationID,
                                             @AuditUserName, 
                                             @DataAuditEventID, 
                                             @strFormID;

            DELETE FROM @EventsTemp
            WHERE EventId = @EventID;
        END;

        IF @@TRANCOUNT > 0
            COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;
    END CATCH
    SELECT @ReturnCode 'ReturnCode',
           @ReturnMessage 'ReturnMessage',
           @strFormID 'strFormID',
           @idfAggregateHeader 'idfAggregateHeader',
           @idfAggregateDetail 'idfAggregateDetail';
END
