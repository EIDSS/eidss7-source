-- ================================================================================================
-- Name: USP_HAS_MONITORING_SESSION_SET
--
-- Description: Insert/update for monitoring session records for the human module.
--          
-- Revision History:
-- Name				Date	   Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long		07/06/2019 Initial release.
-- Ann Xiong		01/17/2020 Fixed an issue in Persons & Samples grid where saving a new row 
--                             will change the Person ID of several previous rows to be the same 
--                             as the newly added row.
-- Stephen Long		03/09/2020 Added current site ID to the update sample set call.
-- Ann Xiong		03/20/2020 Added the following information from the AS Session to the new 
--								Disease Report:
--								Disease Report field “Report Status” – “In progress”	
--								Disease Report field “Case classification” field - <blank>
--								Disease Report field “Report Type” – “Active”
--								Disease Report field “Entered by Name” with the user name who 
--                              created this Disease Report
--								Disease Report field “Date Entered” with the current date when 
--                              this Disease Report was created
-- Ann Xiong		03/30/2020 Update SET idfHumanCase in tlbMaterial and set 
--							   idfsYNSpecimenCollected and idfsYNTestsConducted.
-- Ann Xiong		04/14/2020 Changed to use "SSH" prefix instead of SSV for Human Active 
--							   Surveillance Session.
-- Stephen Long		12/20/2020 Updated USSP_GBL_TEST_SET call with four new parameters.
-- Doug Albanese	01/12/2022 Refactored, due to table change for storing multiple disease 
--                             against a session.  Added supress to an EXECUTE statement that was 
--                             preventing EF from generating a return model
-- Doug Albanese	01/13/2022 Refactored to use new location hierarchy
-- Doug Albanese	01/14/2022 Refactoring json conversion tables to not require PKs, until 
--                             automatically generated
-- Doug Albanese	01/18/2022 Clean up of "collections" to include required fields for foreign 
--                             records
-- Doug Albanese	01/24/2022 Final refactoring for successful save from the app.
-- Doug Albanese	02/02/2022 Minor refactoring to save SampleId to Tests collection
-- Doug Albanese	03/25/2022 Updated to make use of "RowAction" on the disease combination
-- Doug Albanese	05/23/2022 Removed idfsCurrentSite, to prevent clashing with lab.
-- Doug Albanese	06/16/2022 Changed out the value used for NonLaboratoryTestIndicator from 0 to 
--                             1
-- Doug Albanese	06/16/2022 Added "Notifications" for processing, and User ID for auditing 
--                             purposes
-- Stephen Long     07/06/2022 Updates for site alerts to call new stored procedure.
-- Doug Albanese	07/19/2022 Corrected the enumeration of multiple site alerts
-- Doug Albanese	08/01/2022 Added a replacement feature of the word "New", to have the EIDSS 
--                             Session ID, in place.
-- Doug Albanese	08/26/2022 Adjusted supression, because of changes made to USSP_GBL_SAMPLE_SET
-- Doug Albanese    10/17/2022 Added a condition to pick up any idfHumancase ids that belong to an 
--                             existing Test to maintain the "Connected" status.
-- Stephen Long     10/18/2022 Added samples to diseases parameter and logic.
-- Leo Tracchia		12/05/2022 Added statements for Audit logging 
-- Leo Tracchia		12/06/2022 Added fix for auditing logic
-- Stephen Long     12/09/2022 Added EIDSSObjectID parameter to to samples, tests and test 
--                             interpretations calls.
-- Doug Albanese    12/23/2022 Corrected the overwriting of @idfNewHuman with @HumanID for new 
--                             Sample Inserts
-- Stephen Long     03/20/2023 Changed to data audit call with strMainObject.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HAS_MONITORING_SESSION_SET]
(
    @LanguageID NVARCHAR(50),
    @MonitoringSessionID BIGINT = NULL,
    @MonitoringSessionStatusTypeID BIGINT = NULL,
    @idfsLocation BIGINT = NULL,
    @EnteredByPersonID BIGINT = NULL,
    @CampaignID BIGINT = NULL,
    @SiteID BIGINT,
    @EIDSSSessionID NVARCHAR(50) = NULL,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @SessionCategoryTypeID BIGINT = NULL,
    @RowStatus INT,
    @CreateDiseaseReportHumanID BIGINT = NULL,
    @AuditUserName NVARCHAR(200),
    @DiseaseCombinations NVARCHAR(MAX),
    @SampleTypeCombinations NVARCHAR(MAX),
    @Samples NVARCHAR(MAX),
    @SamplesToDiseases NVARCHAR(MAX) = NULL,
    @Tests NVARCHAR(MAX),
    @Actions NVARCHAR(MAX),
    @Events NVARCHAR(MAX) = NULL,
    @UserId BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @NewHumanID BIGINT = NULL,
                @ReturnCode INT = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
                @EventId BIGINT,
                @EventTypeId BIGINT = NULL,
                @EventSiteId BIGINT = NULL,
                @EventObjectId BIGINT = NULL,
                @EventUserId BIGINT = NULL,
                @EventDiseaseId BIGINT = NULL,
                @EventLocationId BIGINT = NULL,
                @EventInformationString NVARCHAR(MAX) = NULL,
                @EventLoginSiteId BIGINT = NULL;

        /* Get an 'On-The-Fly' translation for the word "New". To be used, to replace the "New" indicator on Samples / Tests.*/
        DECLARE @Translated_New NVARCHAR(50);

        DECLARE @ExecReturn TABLE
        (
            strDefault NVARCHAR(200),
            name NVARCHAR(200),
            LongName NVARCHAR(200)
        );

        INSERT INTO @ExecReturn
        EXEC dbo.USP_GBL_BaseReferenceTranslation_Get @LanguageId = 'en-us',
                                                      @idfsBaseReference = 10140000;

        SELECT @Translated_New = [name]
        FROM @ExecReturn;
        /*End 'On-The-Fly' translation.*/

        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage VARCHAR(200)
        );

        DECLARE @CampaignName NVARCHAR(50);
        DECLARE @CampaignTypeID BIGINT = NULL;
        DECLARE @CampaignStartDate DATETIME = NULL;
        DECLARE @CampaignEndDate DATETIME = NULL;

        IF @CampaignID IS NOT NULL
        BEGIN
            SELECT @CampaignTypeID = idfsCampaignType,
                   @CampaignName = strCampaignname,
                   @CampaignStartDate = datCampaignDateStart,
                   @CampaignEndDate = datCampaignDateEnd
            FROM dbo.tlbCampaign
            WHERE idfCampaign = @CampaignID;
        END

        DECLARE @RowID BIGINT = NULL,
                @RowAction NCHAR = NULL,
                @MonitoringSessionToDiseaseID BIGINT,
                @MonitoringSessionToSampleTypeID BIGINT,
                @OrderNumber INT,
                @SampleID BIGINT,
                @SampleTypeID BIGINT = NULL,
                @HumanID BIGINT,
                @HumanMasterID BIGINT = NULL,
                @CollectedByPersonID BIGINT = NULL,
                @CollectedByOrganizationID BIGINT = NULL,
                @CollectionDate DATETIME = NULL,
                @SentDate DATETIME = NULL,
                @EIDSSLocalOrFieldSampleID NVARCHAR(200) = NULL,
                @SampleStatusTypeID BIGINT = NULL,
                @EIDSSLaboratorySampleID NVARCHAR(200) = NULL,
                @SentToOrganizationID BIGINT = NULL,
                @ReadOnlyIndicator BIT = NULL,
                @AccessionDate DATETIME = NULL,
                @AccessionConditionTypeID BIGINT = NULL,
                @AccessionComment NVARCHAR(200) = NULL,
                @AccessionByPersonID BIGINT = NULL,
                --,@CurrentSiteID BIGINT = NULL
                @TestID BIGINT,
                @TestNameTypeID BIGINT = NULL,
                @TestCategoryTypeID BIGINT = NULL,
                @TestResultTypeID BIGINT = NULL,
                @TestStatusTypeID BIGINT,
                @BatchTestID BIGINT = NULL,
                @TestNumber INT = NULL,
                @StartedDate DATETIME2 = NULL,
                @ResultDate DATETIME2 = NULL,
                @TestedByPersonID BIGINT = NULL,
                @TestedByOrganizationID BIGINT = NULL,
                @ResultEnteredByOrganizationID BIGINT = NULL,
                @ResultEnteredByPersonID BIGINT = NULL,
                @ValidatedByOrganizationID BIGINT = NULL,
                @ValidatedByPersonID BIGINT = NULL,
                @NonLaboratoryTestIndicator BIT,
                @ExternalTestIndicator BIT = NULL,
                @PerformedByOrganizationID BIGINT = NULL,
                @ReceivedDate DATETIME2 = NULL,
                @ContactPersonName NVARCHAR(200) = NULL,
                @TestMonitoringSessionID BIGINT = NULL,
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
                @MonitoringSessionActionID BIGINT,
                @ActionTypeID BIGINT,
                @ActionStatusTypeID BIGINT,
                @ActionDate DATETIME = NULL,
                @Comments NVARCHAR(500) = NULL,
                @DiseaseID BIGINT,
                @idfMonitoringSessionToDiagnosis BIGINT,
                @DateEntered DATETIME = GETDATE(),
                @idfHumanCase_Test BIGINT = NULL,
                @MonitoringSessionToMaterialID BIGINT = NULL;

        DECLARE @DiseaseCombinationsTemp TABLE
        (
            MonitoringSessionToDiseaseID BIGINT NULL,
            DiseaseID BIGINT NOT NULL,
            OrderNumber INT NOT NULL,
            SampleTypeID BIGINT NULL,
            Comments NVARCHAR(MAX),
            RowStatus INT NOT NULL,
            RowAction CHAR(1)
        );

        DECLARE @SampleTypeCombinationsTemp TABLE
        (
            MonitoringSessionToSampleTypeID BIGINT NOT NULL,
            SampleTypeID BIGINT NULL,
            OrderNumber INT NOT NULL,
            RowStatus INT NOT NULL,
            RowAction CHAR(1)
        );

        DECLARE @SamplesTemp TABLE
        (
            SampleID BIGINT NOT NULL,
            SampleTypeID BIGINT NULL,
            SampleStatusTypeID BIGINT NULL,
            CollectionDate DATETIME2 NULL,
            CollectedByOrganizationID BIGINT NULL,
            CollectedByPersonID BIGINT NULL,
            SentDate DATETIME2 NULL,
            SentToOrganizationID BIGINT NULL,
            EIDSSLocalOrFieldSampleID NVARCHAR(200) NULL,
            Comments NVARCHAR(200) NULL,
            SiteID BIGINT NOT NULL,
            --,CurrentSiteID BIGINT NULL
            DiseaseID BIGINT NULL,
            ReadOnlyIndicator BIT NULL,
            HumanID BIGINT NULL,
            HumanMasterID BIGINT NULL,
            RowStatus INT NOT NULL,
            RowAction CHAR(1) NULL
        );

        DECLARE @SamplesToDiseasesTemp TABLE
        (
            MonitoringSessionToMaterialID BIGINT NOT NULL,
            MonitoringSessionID BIGINT NULL,
            SampleID BIGINT NOT NULL,
            SampleTypeID BIGINT NULL,
            DiseaseID BIGINT NOT NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );

        DECLARE @TestsTemp TABLE
        (
            TestID BIGINT NOT NULL,
            TestNameTypeID BIGINT NULL,
            TestCategoryTypeID BIGINT NULL,
            TestResultTypeID BIGINT NULL,
            TestStatusTypeID BIGINT NOT NULL,
            DiseaseID BIGINT NULL,
            SampleID BIGINT NULL,
            BatchTestID BIGINT NULL,
            ObservationID BIGINT NULL,
            TestNumber INT NULL,
            Comments NVARCHAR NULL,
            StartedDate DATETIME2 NULL,
            ResultDate DATETIME2 NULL,
            TestedByOrganizationID BIGINT NULL,
            TestedByPersonID BIGINT NULL,
            ResultEnteredByOrganizationID BIGINT NULL,
            ResultEnteredByPersonID BIGINT NULL,
            ValidatedByOrganizationID BIGINT NULL,
            ValidatedByPersonID BIGINT NULL,
            ReadOnlyIndicator BIT NOT NULL,
            NonLaboratoryTestIndicator BIT NOT NULL,
            ExternalTestIndicator BIT NULL,
            PerformedByOrganizationID BIGINT NULL,
            ReceivedDate DATETIME2 NULL,
            ContactPersonName NVARCHAR(200) NULL,
            RowStatus INT NOT NULL,
            RowAction CHAR(1) NULL
        );

        DECLARE @ActionsTemp TABLE
        (
            MonitoringSessionActionID BIGINT NOT NULL,
            EnteredByPersonID BIGINT NULL,
            ActionTypeID BIGINT NULL,
            ActionStatusTypeID BIGINT NULL,
            ActionDate DATETIME2 NULL,
            Comments NVARCHAR(500) NULL,
            RowStatus INT NOT NULL,
            RowAction CHAR(1) NULL
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

        --Data Audit--

        DECLARE @idfUserId BIGINT = NULL;
        DECLARE @idfSiteId BIGINT = NULL;
        DECLARE @idfsDataAuditEventType bigint = NULL;
        DECLARE @idfsObjectType bigint = 10017063; --select * from trtBaseReference where idfsBaseReference = 10017063
        DECLARE @idfObject bigint = @MonitoringSessionID;
        DECLARE @idfObjectTable_tlbMonitoringSession bigint = 707040000000;
        DECLARE @idfObjectTable_tlbCampaign bigint = 706900000000;
        DECLARE @idfDataAuditEvent bigint = NULL;

        DECLARE @tlbMonitoringSession_BeforeEdit TABLE
        (
            idfMonitoringSession bigint,
            idfsMonitoringSessionStatus bigint,
            idfsLocation bigint,
            idfPersonEnteredBy bigint,
            idfCampaign bigint,
            idfsSite bigint,
            datEnteredDate datetime,
            datStartDate datetime,
            datEndDate datetime,
            SessionCategoryID bigint,
            AuditUpdateUser nvarchar(200)
        );

        DECLARE @tlbMonitoringSession_AfterEdit TABLE
        (
            idfMonitoringSession bigint,
            idfsMonitoringSessionStatus bigint,
            idfsLocation bigint,
            idfPersonEnteredBy bigint,
            idfCampaign bigint,
            idfsSite bigint,
            datEnteredDate datetime,
            datStartDate datetime,
            datEndDate datetime,
            SessionCategoryID bigint,
            AuditUpdateUser nvarchar(200)
        );

        DECLARE @tlbCampaign_BeforeEdit TABLE
        (
            idfCampaign bigint,
            strCampaignName nvarchar(200),
            idfsCampaignType bigint,
            datCampaignDateStart datetime,
            datCampaignDateEnd datetime
        );

        DECLARE @tlbCampaign_AfterEdit TABLE
        (
            idfCampaign bigint,
            strCampaignName nvarchar(200),
            idfsCampaignType bigint,
            datCampaignDateStart datetime,
            datCampaignDateEnd datetime
        );

        --Data Audit--

        --BEGIN TRANSACTION;

        SET @DiseaseCombinations = REPLACE(@DiseaseCombinations, '"0001-01-01T00:00:00"', 'null');

        INSERT INTO @DiseaseCombinationsTemp
        SELECT *
        FROM
            OPENJSON(@DiseaseCombinations)
            WITH
            (
                MonitoringSessionToDiseaseID BIGINT,
                DiseaseID BIGINT,
                OrderNumber INT,
                SampleTypeID BIGINT,
                Comments NVARCHAR(MAX),
                RowStatus INT,
                RowAction CHAR(1)
            );

        SET @SampleTypeCombinations = REPLACE(@SampleTypeCombinations, '"0001-01-01T00:00:00"', 'null');

        INSERT INTO @SampleTypeCombinationsTemp
        SELECT *
        FROM
            OPENJSON(@SampleTypeCombinations)
            WITH
            (
                MonitoringSessionToSampleTypeID BIGINT,
                SampleTypeID BIGINT,
                OrderNumber INT,
                RowStatus INT,
                RowAction CHAR(1)
            );

        SET @Samples = REPLACE(@Samples, '"0001-01-01T00:00:00"', 'null');

        INSERT INTO @SamplesTemp
        SELECT *
        FROM
            OPENJSON(@Samples)
            WITH
            (
                SampleID BIGINT,
                SampleTypeID BIGINT,
                SampleStatusTypeID BIGINT,
                CollectionDate DATETIME2,
                CollectedByOrganizationID BIGINT,
                CollectedByPersonID BIGINT,
                SentDate DATETIME2,
                SentToOrganizationID BIGINT,
                EIDSSLocalOrFieldSampleID NVARCHAR(200),
                Comments NVARCHAR(200),
                SiteID BIGINT,
                --,CurrentSiteID BIGINT
                DiseaseID BIGINT,
                ReadOnlyIndicator BIT,
                HumanID BIGINT,
                HumanMasterID BIGINT,
                RowStatus INT,
                RowAction CHAR(1)
            );

        INSERT INTO @SamplesToDiseasesTemp
        SELECT *
        FROM
            OPENJSON(@SamplesToDiseases)
            WITH
            (
                MonitoringSessionToMaterialID BIGINT,
                MonitoringSessionID BIGINT,
                SampleID BIGINT,
                SampleTypeID BIGINT,
                DiseaseID BIGINT,
                RowStatus INT,
                RowAction INT
            );

        SET @Tests = REPLACE(@Tests, '"0001-01-01T00:00:00"', 'null');

        INSERT INTO @TestsTemp
        SELECT *
        FROM
            OPENJSON(@Tests)
            WITH
            (
                TestID BIGINT,
                TestNameTypeID BIGINT,
                TestCategoryTypeID BIGINT,
                TestResultTypeID BIGINT,
                TestStatusTypeID BIGINT,
                DiseaseID BIGINT,
                SampleID BIGINT,
                BatchTestID BIGINT,
                ObservationID BIGINT,
                TestNumber INT,
                Comments NVARCHAR(500),
                StartedDate DATETIME2,
                ResultDate DATETIME2,
                TestedByOrganizationID BIGINT,
                TestedByPersonID BIGINT,
                ResultEnteredByOrganizationID BIGINT,
                ResultEnteredByPersonID BIGINT,
                ValidatedByOrganizationID BIGINT,
                ValidatedByPersonID BIGINT,
                ReadOnlyIndicator BIT,
                NonLaboratoryTestIndicator BIT,
                ExternalTestIndicator BIT,
                PerformedByOrganizationID BIGINT,
                ReceivedDate DATETIME2,
                ContactPersonName NVARCHAR(200),
                RowStatus INT,
                RowAction CHAR(1)
            );


        SET @Actions = REPLACE(@Actions, '"0001-01-01T00:00:00"', 'null');

        INSERT INTO @ActionsTemp
        SELECT *
        FROM
            OPENJSON(@Actions)
            WITH
            (
                MonitoringSessionActionID BIGINT,
                EnteredByPersonID BIGINT,
                ActionTypeID BIGINT,
                ActionStatusTypeID BIGINT,
                ActionDate DATETIME2,
                Comments NVARCHAR(500),
                RowStatus INT,
                RowAction CHAR(1)
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

        --Data Audit--
        -- Get and Set UserId and SiteId
        --SELECT @idfUserId = userInfo.UserId, @idfSiteId = UserInfo.SiteId FROM dbo.FN_UserSiteInformation(@UserId) userInfo

        SELECT @idfUserId = tu.idfUserID,
               @idfSiteId = tu.idfsSite
        FROM dbo.AspNetUsers u
            INNER JOIN dbo.tstUserTable tu
                on u.idfUserID = tu.idfUserID
        WHERE u.idfUserID = @UserId;

        --Data Audit--

        IF EXISTS
        (
            SELECT *
            FROM dbo.tlbMonitoringSession
            WHERE idfMonitoringSession = @MonitoringSessionID
        )
        BEGIN

            --  tauDataAuditEvent  Event Type - Edit 
            SET @idfsDataAuditEventType = 10016003;

            -- insert record into tauDataAuditEvent - 
            INSERT INTO @SuppressSelect
            EXEC dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @idfUserId,
                                                   @idfSiteId,
                                                   @idfsDataAuditEventType,
                                                   @idfsObjectType,
                                                   @idfObject,
                                                   @idfObjectTable_tlbMonitoringSession,
                                                   @EIDSSSessionID,
                                                   @idfDataAuditEvent OUTPUT;

            INSERT INTO @tlbMonitoringSession_BeforeEdit
            (
                idfMonitoringSession,
                idfsMonitoringSessionStatus,
                idfsLocation,
                idfPersonEnteredBy,
                idfCampaign,
                idfsSite,
                datEnteredDate,
                datStartDate,
                datEndDate,
                SessionCategoryID,
                AuditUpdateUser
            )
            SELECT idfMonitoringSession,
                   idfsMonitoringSessionStatus,
                   idfsLocation,
                   idfPersonEnteredBy,
                   idfCampaign,
                   idfsSite,
                   datEnteredDate,
                   datStartDate,
                   datEndDate,
                   SessionCategoryID,
                   AuditUpdateUser
            FROM tlbMonitoringSession
            WHERE idfMonitoringSession = @MonitoringSessionID;

            UPDATE dbo.tlbMonitoringSession
            SET idfsMonitoringSessionStatus = @MonitoringSessionStatusTypeID,
                idfsLocation = @idfsLocation,
                idfPersonEnteredBy = @EnteredByPersonID,
                idfCampaign = @CampaignID,
                idfsSite = @SiteID,
                datEnteredDate = GETDATE(),
                datStartDate = @StartDate,
                datEndDate = @EndDate,
                SessionCategoryID = @SessionCategoryTypeID,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSession = @MonitoringSessionID;

            INSERT INTO @tlbMonitoringSession_AfterEdit
            (
                idfMonitoringSession,
                idfsMonitoringSessionStatus,
                idfsLocation,
                idfPersonEnteredBy,
                idfCampaign,
                idfsSite,
                datEnteredDate,
                datStartDate,
                datEndDate,
                SessionCategoryID,
                AuditUpdateUser
            )
            SELECT idfMonitoringSession,
                   idfsMonitoringSessionStatus,
                   idfsLocation,
                   idfPersonEnteredBy,
                   idfCampaign,
                   idfsSite,
                   datEnteredDate,
                   datStartDate,
                   datEndDate,
                   SessionCategoryID,
                   AuditUpdateUser
            FROM tlbMonitoringSession
            WHERE idfMonitoringSession = @MonitoringSessionID;

            --idfsMonitoringSessionStatus
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
                   @idfObjectTable_tlbMonitoringSession,
                   707060000000,
                   a.idfMonitoringSession,
                   null,
                   a.idfsMonitoringSessionStatus,
                   b.idfsMonitoringSessionStatus
            from @tlbMonitoringSession_BeforeEdit a
                inner join @tlbMonitoringSession_AfterEdit b
                    on a.idfMonitoringSession = b.idfMonitoringSession
            where (a.idfsMonitoringSessionStatus <> b.idfsMonitoringSessionStatus)
                  or (
                         a.idfsMonitoringSessionStatus is not null
                         and b.idfsMonitoringSessionStatus is null
                     )
                  or (
                         a.idfsMonitoringSessionStatus is null
                         and b.idfsMonitoringSessionStatus is not null
                     );

            --idfPersonEnteredBy
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
                   @idfObjectTable_tlbMonitoringSession,
                   707110000000,
                   a.idfMonitoringSession,
                   null,
                   a.idfPersonEnteredBy,
                   b.idfPersonEnteredBy
            from @tlbMonitoringSession_BeforeEdit a
                inner join @tlbMonitoringSession_AfterEdit b
                    on a.idfMonitoringSession = b.idfMonitoringSession
            where (a.idfPersonEnteredBy <> b.idfPersonEnteredBy)
                  or (
                         a.idfPersonEnteredBy is not null
                         and b.idfPersonEnteredBy is null
                     )
                  or (
                         a.idfPersonEnteredBy is null
                         and b.idfPersonEnteredBy is not null
                     );

            --idfCampaign
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
                   @idfObjectTable_tlbMonitoringSession,
                   707120000000,
                   a.idfMonitoringSession,
                   null,
                   a.idfCampaign,
                   b.idfCampaign
            from @tlbMonitoringSession_BeforeEdit a
                inner join @tlbMonitoringSession_AfterEdit b
                    on a.idfMonitoringSession = b.idfMonitoringSession
            where (a.idfCampaign <> b.idfCampaign)
                  or (
                         a.idfCampaign is not null
                         and b.idfCampaign is null
                     )
                  or (
                         a.idfCampaign is null
                         and b.idfCampaign is not null
                     );

            --datEnteredDate
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
                   @idfObjectTable_tlbMonitoringSession,
                   707130000000,
                   a.idfMonitoringSession,
                   null,
                   a.datEnteredDate,
                   b.datEnteredDate
            from @tlbMonitoringSession_BeforeEdit a
                inner join @tlbMonitoringSession_AfterEdit b
                    on a.idfMonitoringSession = b.idfMonitoringSession
            where (a.datEnteredDate <> b.datEnteredDate)
                  or (
                         a.datEnteredDate is not null
                         and b.datEnteredDate is null
                     )
                  or (
                         a.datEnteredDate is null
                         and b.datEnteredDate is not null
                     );

            --datStartDate
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
                   @idfObjectTable_tlbMonitoringSession,
                   4578670000000,
                   a.idfMonitoringSession,
                   null,
                   a.datStartDate,
                   b.datStartDate
            from @tlbMonitoringSession_BeforeEdit a
                inner join @tlbMonitoringSession_AfterEdit b
                    on a.idfMonitoringSession = b.idfMonitoringSession
            where (a.datStartDate <> b.datStartDate)
                  or (
                         a.datStartDate is not null
                         and b.datStartDate is null
                     )
                  or (
                         a.datStartDate is null
                         and b.datStartDate is not null
                     );

            --datEndDate
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
                   @idfObjectTable_tlbMonitoringSession,
                   4578680000000,
                   a.idfMonitoringSession,
                   null,
                   a.datEndDate,
                   b.datEndDate
            from @tlbMonitoringSession_BeforeEdit a
                inner join @tlbMonitoringSession_AfterEdit b
                    on a.idfMonitoringSession = b.idfMonitoringSession
            where (a.datEndDate <> b.datEndDate)
                  or (
                         a.datEndDate is not null
                         and b.datEndDate is null
                     )
                  or (
                         a.datEndDate is null
                         and b.datEndDate is not null
                     );

            INSERT INTO @tlbCampaign_BeforeEdit
            (
                idfCampaign,
                strCampaignName,
                idfsCampaignType,
                datCampaignDateStart,
                datCampaignDateEnd
            )
            SELECT idfCampaign,
                   strCampaignName,
                   idfsCampaignType,
                   datCampaignDateStart,
                   datCampaignDateEnd
            FROM tlbCampaign
            WHERE idfCampaign = @CampaignID;

            UPDATE dbo.tlbCampaign
            SET strCampaignName = @CampaignName,
                idfsCampaignType = @CampaignTypeID,
                datCampaignDateStart = @CampaignStartDate,
                datCampaignDateEnd = @CampaignEndDate
            WHERE idfCampaign = @CampaignID;

            INSERT INTO @tlbCampaign_AfterEdit
            (
                idfCampaign,
                strCampaignName,
                idfsCampaignType,
                datCampaignDateStart,
                datCampaignDateEnd
            )
            SELECT idfCampaign,
                   strCampaignName,
                   idfsCampaignType,
                   datCampaignDateStart,
                   datCampaignDateEnd
            FROM tlbCampaign
            WHERE idfCampaign = @CampaignID;

            --strCampaignName
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
                   @idfObjectTable_tlbCampaign,
                   706970000000,
                   a.idfCampaign,
                   null,
                   a.strCampaignName,
                   b.strCampaignName
            from @tlbCampaign_BeforeEdit a
                inner join @tlbCampaign_AfterEdit b
                    on a.idfCampaign = b.idfCampaign
            where (a.strCampaignName <> b.strCampaignName)
                  or (
                         a.strCampaignName is not null
                         and b.strCampaignName is null
                     )
                  or (
                         a.strCampaignName is null
                         and b.strCampaignName is not null
                     );

            --idfsCampaignType
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
                   @idfObjectTable_tlbCampaign,
                   706920000000,
                   a.idfCampaign,
                   null,
                   a.idfsCampaignType,
                   b.idfsCampaignType
            from @tlbCampaign_BeforeEdit a
                inner join @tlbCampaign_AfterEdit b
                    on a.idfCampaign = b.idfCampaign
            where (a.idfsCampaignType <> b.idfsCampaignType)
                  or (
                         a.idfsCampaignType is not null
                         and b.idfsCampaignType is null
                     )
                  or (
                         a.idfsCampaignType is null
                         and b.idfsCampaignType is not null
                     );

            --datCampaignDateStart
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
                   @idfObjectTable_tlbCampaign,
                   706940000000,
                   a.idfCampaign,
                   null,
                   a.datCampaignDateStart,
                   b.datCampaignDateStart
            from @tlbCampaign_BeforeEdit a
                inner join @tlbCampaign_AfterEdit b
                    on a.idfCampaign = b.idfCampaign
            where (a.datCampaignDateStart <> b.datCampaignDateStart)
                  or (
                         a.datCampaignDateStart is not null
                         and b.datCampaignDateStart is null
                     )
                  or (
                         a.datCampaignDateStart is null
                         and b.datCampaignDateStart is not null
                     );

            --datCampaignDateEnd
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
                   @idfObjectTable_tlbCampaign,
                   706950000000,
                   a.idfCampaign,
                   null,
                   a.datCampaignDateEnd,
                   b.datCampaignDateEnd
            from @tlbCampaign_BeforeEdit a
                inner join @tlbCampaign_AfterEdit b
                    on a.idfCampaign = b.idfCampaign
            where (a.datCampaignDateEnd <> b.datCampaignDateEnd)
                  or (
                         a.datCampaignDateEnd is not null
                         and b.datCampaignDateEnd is null
                     )
                  or (
                         a.datCampaignDateEnd is null
                         and b.datCampaignDateEnd is not null
                     );

            UPDATE @EventsTemp
            SET ObjectId = @MonitoringSessionID
            WHERE ObjectId = 0;
        END
        ELSE
        BEGIN
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbMonitoringSession',
                                              @MonitoringSessionID OUTPUT;

            EXECUTE dbo.USP_GBL_NextNumber_GET 'Human Active Surveillance Session',
                                               @EIDSSSessionID OUTPUT,
                                               NULL;

            INSERT INTO dbo.tlbMonitoringSession
            (
                idfMonitoringSession,
                idfsMonitoringSessionStatus,
                idfsLocation,
                idfPersonEnteredBy,
                idfCampaign,
                idfsSite,
                datEnteredDate,
                strMonitoringSessionID,
                datStartDate,
                datEndDate,
                SessionCategoryID,
                intRowStatus,
                AuditCreateUser
            )
            VALUES
            (@MonitoringSessionID,
             @MonitoringSessionStatusTypeID,
             @idfsLocation,
             @EnteredByPersonID,
             @CampaignID,
             @SiteID,
             GETDATE(),
             @EIDSSSessionID,
             @StartDate,
             @EndDate,
             @SessionCategoryTypeID,
             0  ,
             @AuditUserName
            );

            UPDATE @EventsTemp
            SET ObjectId = @MonitoringSessionID
            WHERE ObjectId = 0;

            --Data Audit--

            -- tauDataAuditEvent Event Type - Create 
            set @idfsDataAuditEventType = 10016001;

            -- insert record into tauDataAuditEvent - 
            INSERT INTO @SuppressSelect
            EXEC dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @idfUserId,
                                                   @idfSiteId,
                                                   @idfsDataAuditEventType,
                                                   @idfsObjectType,
                                                   @idfObject,
                                                   @idfObjectTable_tlbMonitoringSession,
                                                   @EIDSSSessionID,
                                                   @idfDataAuditEvent OUTPUT;

            INSERT INTO tauDataAuditDetailCreate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject
            )
            VALUES
            (@idfDataAuditEvent, @idfObjectTable_tlbMonitoringSession, @MonitoringSessionID);

        --Data Audit--
        END

        WHILE EXISTS (SELECT * FROM @DiseaseCombinationsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = MonitoringSessionToDiseaseID,
                @DiseaseID = DiseaseID,
                @SampleTypeID = SampleTypeID,
                @OrderNumber = OrderNumber,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @DiseaseCombinationsTemp;

            SET @idfMonitoringSessionToDiagnosis = @RowID;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_HAS_MonitoringSessionToDiagnosis_SET @LanguageID,
                                                                  @idfDataAuditEvent,
                                                                  @idfMonitoringSessionToDiagnosis OUTPUT,
                                                                  @MonitoringSessionID,
                                                                  @DiseaseID,
                                                                  @OrderNumber,
                                                                  NULL,
                                                                  @SampleTypeID,
                                                                  @Comments,
                                                                  @AuditUserName,
                                                                  @RowAction;

            DELETE FROM @DiseaseCombinationsTemp
            WHERE MonitoringSessionToDiseaseID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @SampleTypeCombinationsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = MonitoringSessionToSampleTypeID,
                @MonitoringSessionToSampleTypeID = MonitoringSessionToSampleTypeID,
                @OrderNumber = OrderNumber,
                @RowStatus = RowStatus,
                @SampleTypeID = SampleTypeID,
                @RowAction = RowAction
            FROM @SampleTypeCombinationsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_HAS_MONITORING_SESSION_TO_SAMPLE_TYPE_SET @LanguageID,
                                                                       @idfDataAuditEvent,
                                                                       @MonitoringSessionToSampleTypeID,
                                                                       @MonitoringSessionID,
                                                                       @OrderNumber,
                                                                       @RowStatus,
                                                                       @SampleTypeID,
                                                                       @RowAction,
                                                                       @AuditUserName;

            DELETE FROM @SampleTypeCombinationsTemp
            WHERE MonitoringSessionToSampleTypeID = @RowID;
        END;


        WHILE EXISTS (SELECT * FROM @SamplesTemp)
        BEGIN
            SELECT TOP 1
                @RowID = SampleID,
                @SampleID = SampleID,
                @SampleTypeID = SampleTypeID,
                @CollectedByPersonID = CollectedByPersonID,
                @CollectedByOrganizationID = CollectedByOrganizationID,
                @CollectionDate = CAST(CollectionDate AS DATETIME),
                @SentDate = CAST(SentDate AS DATETIME),
                @EIDSSLocalOrFieldSampleID = EIDSSLocalOrFieldSampleID,
                @SampleStatusTypeID = SampleStatusTypeID,
                @Comments = Comments,
                @SiteID = SiteID,
                --,@CurrentSiteID = CurrentSiteID
                @RowStatus = RowStatus,
                @SentToOrganizationID = SentToOrganizationID,
                @DiseaseID = DiseaseID,
                @ReadOnlyIndicator = ReadOnlyIndicator,
                @HumanID = HumanID,
                @HumanMasterID = HumanMasterID,
                @RowAction = RowAction
            FROM @SamplesTemp;

            SET @EIDSSLocalOrFieldSampleID
                = REPLACE(@EIDSSLocalOrFieldSampleID, @Translated_New + '-', @EIDSSSessionID + '-');

            IF @RowAction = 'I'
            BEGIN
                DECLARE @idfNewHuman BIGINT = NULL;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_HUM_COPY_HUMAN_SET @HumanMasterID,
                                                    @idfDataAuditEvent,
                                                    @AuditUserName,
                                                    @idfNewHuman OUTPUT,
                                                    @ReturnCode OUTPUT,
                                                    @ReturnMessage OUTPUT;

                SELECT @HumanID = @idfNewHuman;
            END;

            EXECUTE dbo.USSP_GBL_SAMPLES_SET @AuditUserName = @AuditUserName,
                                             @DataAuditEventID = @idfDataAuditEvent,
                                             @EIDSSObjectID = @EIDSSSessionID,
                                             @SampleID = @SampleID OUTPUT,
                                             @SampleTypeID = @SampleTypeID,
                                             @RootSampleID = NULL,
                                             @ParentSampleID = NULL,
                                             @HumanID = @HumanID,
                                             @SpeciesID = NULL,
                                             @AnimalID = NULL,
                                             @VectorID = NULL,
                                             @MonitoringSessionID = @MonitoringSessionID,
                                             @VectorSessionID = NULL,
                                             @HumanDiseaseReportID = NULL,
                                             @VeterinaryDiseaseReportID = NULL,
                                             @CollectionDate = @CollectionDate,
                                             @CollectedByPersonID = @CollectedByPersonID,
                                             @CollectedByOrganizationID = @CollectedByOrganizationID,
                                             @SentDate = @SentDate,
                                             @SentToOrganizationID = @SentToOrganizationID,
                                             @EIDSSLocalFieldSampleID = @EIDSSLocalOrFieldSampleID,
                                             @SiteID = @SiteID,
                                             @EnteredDate = @DateEntered,
                                             @ReadOnlyIndicator = @ReadOnlyIndicator,
                                             @SampleStatusTypeID = @SampleStatusTypeID,
                                             @Comments = @Comments,
                                             @CurrentSiteID = NULL,
                                             @DiseaseID = @DiseaseID,
                                             @BirdStatusTypeID = NULL,
                                             @RowStatus = @RowStatus,
                                             @RowAction = @RowAction;

            UPDATE @SamplesToDiseasesTemp
            SET SampleID = @SampleID
            WHERE SampleID = @RowID;

            UPDATE @TestsTemp
            SET SampleID = @SampleID
            WHERE SampleID = @RowID;

            DELETE FROM @SamplesTemp
            WHERE SampleID = @RowID;

            DELETE FROM dbo.tlbMonitoringSessionToMaterial
            WHERE idfMaterial = @SampleID;
        END;

        WHILE EXISTS (SELECT * FROM @SamplesToDiseasesTemp)
        BEGIN
            SELECT TOP 1
                @RowID = MonitoringSessionToMaterialID,
                @MonitoringSessionToMaterialID = MonitoringSessionToMaterialID,
                @SampleID = SampleID,
                @SampleTypeID = SampleTypeID,
                @DiseaseID = DiseaseID,
                @RowAction = RowAction,
                @RowStatus = RowStatus
            FROM @SamplesToDiseasesTemp;

            --insert or update the diseases for this sample
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_AS_SAMPLE_TO_DISEASE_SET @AuditUserName,
                                                      @idfDataAuditEvent,
                                                      @MonitoringSessionToMaterialID,
                                                      @MonitoringSessionID,
                                                      @SampleID,
                                                      @DiseaseID,
                                                      @SampleTypeID,
                                                      @RowStatus,
                                                      @RowAction;

            DELETE FROM @SamplesToDiseasesTemp
            WHERE MonitoringSessionToMaterialID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @TestsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = TestID,
                @TestID = TestID,
                @TestNameTypeID = TestNameTypeID,
                @TestCategoryTypeID = TestCategoryTypeID,
                @TestResultTypeID = TestResultTypeID,
                @TestStatusTypeID = TestStatusTypeID,
                @DiseaseID = DiseaseID,
                @SampleID = SampleID,
                @Comments = Comments,
                @RowStatus = RowStatus,
                @StartedDate = StartedDate,
                @ResultDate = ResultDate,
                @TestedByOrganizationID = TestedByOrganizationID,
                @TestedByPersonID = TestedByPersonID,
                @ResultEnteredByOrganizationID = ResultEnteredByOrganizationID,
                @ResultEnteredByPersonID = ResultEnteredByPersonID,
                @ValidatedByOrganizationID = ValidatedByOrganizationID,
                @ValidatedByPersonID = ValidatedByPersonID,
                @ReadOnlyIndicator = ReadOnlyIndicator,
                @NonLaboratoryTestIndicator = NonLaboratoryTestIndicator,
                @ExternalTestIndicator = ExternalTestIndicator,
                @PerformedByOrganizationID = PerformedByOrganizationID,
                @ReceivedDate = ReceivedDate,
                @ContactPersonName = ContactPersonName,
                @RowAction = RowAction
            FROM @TestsTemp;

            SELECT @idfHumanCase_Test = idfHumanCase
            FROM tlbTesting
            WHERE idfTesting = @TestID

            SET @EIDSSLocalOrFieldSampleID
                = REPLACE(@EIDSSLocalOrFieldSampleID, @Translated_New + '-', @EIDSSSessionID + '-');

            --If record is being soft-deleted, then check if the test record was originally created 
            --in the laboaratory module.  If it was, then disassociate the test record from the 
            --human monitoring session, so that the test record remains in the laboratory module 
            --for further action.
            IF @RowStatus = 1
               AND @NonLaboratoryTestIndicator = 1
            BEGIN
                SET @RowStatus = 0;
                SET @TestMonitoringSessionID = NULL;
            END
            ELSE
            BEGIN
                SET @TestMonitoringSessionID = @MonitoringSessionID;
            END;


            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_TESTS_SET @TestID OUTPUT,
                                           @TestNameTypeID,
                                           @TestCategoryTypeID,
                                           @TestResultTypeID,
                                           @TestStatusTypeID,
                                           @DiseaseID,
                                           @SampleID,
                                           NULL,
                                           NULL,
                                           NULL,
                                           @Comments,
                                           @RowStatus,
                                           @StartedDate,
                                           @ResultDate,
                                           @TestedByOrganizationID,
                                           @TestedByPersonID,
                                           @ResultEnteredByOrganizationID,
                                           @ResultEnteredByPersonID,
                                           @ValidatedByOrganizationID,
                                           @ValidatedByPersonID,
                                           @ReadOnlyIndicator,
                                           @NonLaboratoryTestIndicator,
                                           @ExternalTestIndicator,
                                           @PerformedByOrganizationID,
                                           @ReceivedDate,
                                           @ContactPersonName,
                                           @TestMonitoringSessionID,
                                           NULL,
                                           @idfHumanCase_Test,
                                           NULL,
                                           @AuditUserName,
                                           @idfDataAuditEvent,
                                           @EIDSSSessionID,
                                           @RowAction;

            DELETE FROM @TestsTemp
            WHERE TestID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @ActionsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = MonitoringSessionActionID,
                @MonitoringSessionActionID = MonitoringSessionActionID,
                @EnteredByPersonID = EnteredByPersonID,
                @ActionTypeID = ActionTypeID,
                @ActionStatusTypeID = ActionStatusTypeID,
                @ActionDate = ActionDate,
                @Comments = Comments,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @ActionsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_HAS_MONITORING_SESSION_ACTION_SET @LanguageID,
                                                               @idfDataAuditEvent,
                                                               @MonitoringSessionActionID OUTPUT,
                                                               @MonitoringSessionID,
                                                               @EnteredByPersonID,
                                                               @ActionTypeID,
                                                               @ActionStatusTypeID,
                                                               @ActionDate,
                                                               @Comments,
                                                               @RowStatus,
                                                               @RowAction,
                                                               @AuditUserName;

            DELETE FROM @ActionsTemp
            WHERE MonitoringSessionActionID = @RowID;
        END;


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

        DECLARE @HumanDiseaseReportID BIGINT = NULL;
        DECLARE @EIDSSReportID NVARCHAR(200) = NULL;

        IF (@CreateDiseaseReportHumanID IS NOT NULL)
        BEGIN
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbHumanCase',
                                              @HumanDiseaseReportID OUTPUT;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NextNumber_GET 'Human Disease Report',
                                               @EIDSSReportID OUTPUT,
                                               NULL;

            DECLARE @PersonID NVARCHAR(50) = NULL;
            DECLARE @Name NVARCHAR(200) = NULL;

            INSERT INTO dbo.tlbHumanCase
            (
                idfHumanCase,
                strCaseID,
                idfHuman,
                idfParentMonitoringSession,
                idfsFinalDiagnosis,
                idfsSite,
                idfsCaseProgressStatus,
                idfsInitialCaseStatus,
                idfsFinalCaseStatus,
                DiseaseReportTypeID,
                idfPersonEnteredBy,
                idfsYNSpecimenCollected,
                idfsYNTestsConducted,
                datEnteredDate
            )
            VALUES
            (   @HumanDiseaseReportID,
                @EIDSSReportID,
                @CreateDiseaseReportHumanID,
                @MonitoringSessionID,
                NULL, --@DiseaseID
                @SiteID,
                10109001,
                NULL,
                NULL,
                4578940000001,
                @EnteredByPersonID,
                10100001,
                10100001,
                GETDATE()
            );

            UPDATE dbo.tlbMaterial
            SET idfHumanCase = @HumanDiseaseReportID
            WHERE idfMonitoringSession = @MonitoringSessionID
                  AND idfHuman = @CreateDiseaseReportHumanID;
        END;

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        THROW;
    END CATCH

    SELECT @ReturnCode AS ReturnCode,
           @ReturnMessage AS ReturnMessage,
           @MonitoringSessionID AS MonitoringSessionID,
           @EIDSSSessionID AS EIDSSSessionID,
           @HumanDiseaseReportID AS HumanDiseaseReportID;
END