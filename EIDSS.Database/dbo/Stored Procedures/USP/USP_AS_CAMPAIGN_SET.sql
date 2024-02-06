-- ================================================================================================
-- Name: USP_AS_CAMPAIGN_SET
--
-- Description: Insert/update active surveillance campaign record for the human module.
--          
-- Revision History:
-- Name						Date       Change Detail
-- ------------------		---------- -----------------------------------------------------------------
-- Stephen Long				07/06/2019 Initial release.
-- Stephen Long				09/30/2020 Added site ID to insert and update.
-- Manickandan Govindarajan 11/25/2020 Updated correct parameter for USP_GBL_NextNumber_GET to get the correct SCH Prefix
-- Mark Wilson				08/19/2021 Updated to handle multiple diagnosis per Campaign
-- Lamont Mitchell			08/25/2001 Removed Output declaration from @idfCampaign
-- Mark Wilson				08/27/2021 added code to clear tlbCampaignToDiagnosis
-- Mark Wilson				10/13/2021 reviewed for location udpates. minor edits
-- Mani						Consolidated for Both Human and Vet 
-- Stephen Long             07/11/2022 Added events parameter and logic for site alerts.
-- Manickandan Govindarajan 11/16/2022 - Implemented DataAudit

-- Testing code:
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_AS_CAMPAIGN_SET]
(
    @LanguageID NVARCHAR(50),
    @idfCampaign BIGINT NULL,
    @CampaignTypeID BIGINT,
    @CampaignStatusTypeID BIGINT,
    @CampaignDateStart DATETIME,
    @CampaignDateEnd DATETIME,
    @strCampaignID NVARCHAR(50),
    @CampaignName NVARCHAR(200),
    @CampaignAdministrator NVARCHAR(200),
    @Conclusion NVARCHAR(MAX),
    @SiteID BIGINT,
    @CampaignCategoryTypeID BIGINT,
    @AuditUserName NVARCHAR(200),
    @CampaignToDiagnosisCombo NVARCHAR(MAX), -- idfCampaignToDiagnosis, idfsDiagnosis, intOrder,  intPlannedNumber, idfsSpeciesType, idfsSampleType, Comments, AuditUser
    @MonitoringSessions NVARCHAR(MAX),
    @Events NVARCHAR(MAX) = NULL
)
AS
BEGIN

    DECLARE @idfRow INT
    DECLARE @ReturnCode INT = 0
    DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS'
    DECLARE @ObjectName NVARCHAR(100) = NULL
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage VARCHAR(200)
    )
    DECLARE @idfCampaignToDiagnosis BIGINT = NULL,
            @idfsDiagnosis BIGINT = NULL,
            @intOrder INT = NULL,
            @intPlannedNumber INT = NULL,
            @idfsSpeciesType BIGINT = NULL,
            @idfsSampleType BIGINT = NULL,
            @Comments NVARCHAR(500) = NULL,
            @RowID BIGINT = NULL,
            @idfMonitoringSession BIGINT = NULL,
            @EventId BIGINT,
            @EventTypeId BIGINT = NULL,
            @EventSiteId BIGINT = NULL,
            @EventObjectId BIGINT = NULL,
            @EventUserId BIGINT = NULL,
            @EventDiseaseId BIGINT = NULL,
            @EventLocationId BIGINT = NULL,
            @EventInformationString NVARCHAR(MAX) = NULL,
            @EventLoginSiteId BIGINT = NULL;

    DECLARE @tlbCampaignToDiagnosis TABLE
    (
        idfRow INT IDENTITY(1, 1) NOT NULL,
        idfCampaignToDiagnosis BIGINT NOT NULL,
        idfsDiagnosis BIGINT NULL,
        intOrder INT NOT NULL,
        intPlannedNumber INT NULL,
        idfsSpeciesType BIGINT NULL,
        idfsSampleType BIGINT NULL,
        Comments NVARCHAR(MAX) NULL
    );

    DECLARE @tlbMonitoringSession TABLE
    (
        idfMonitoringSession BIGINT NOT NULL,
        deleteFlag BIT NOT NULL
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
	declare @idfUserId BIGINT =NULL;
	declare @idfSiteId BIGINT = NULL;
	declare @idfsDataAuditEventType bigint =NULL;
	declare @idfsObjectType bigint; -- Need to review the value
	declare @idfObject bigint =@idfCampaign;
	declare @idfObjectTable_tlbCampaign bigint  = 706900000000;
	declare @idfDataAuditEvent bigint= NULL;
	declare @idfObjectTable_tlbCampaignToDiagnosis bigint =707000000000;
	declare @idfObjectTable_tlbMonitoringSession bigint =707040000000;

	DECLARE @tlbCampaign_BeforeEdit TABLE
	(
	  CampaignId bigint,
	  CampaignTypeID bigint,
	  CampaignStatusTypeID bigint,
      CampaignDateStart datetime,
      CampaignDateEnd datetime,
      strCampaignID varchar(255),
      strCampaignName varchar(255),
      strCampaignAdministrator varchar(255),
      strComments varchar(255),
      CampaignCategoryID bigint
	)
	DECLARE @tlbCampaign_AfterEdit TABLE
	(
	  CampaignId bigint,
	  CampaignTypeID bigint,
	  CampaignStatusTypeID bigint,
      CampaignDateStart datetime,
      CampaignDateEnd datetime,
      strCampaignID varchar(255),
      strCampaignName varchar(255),
      strCampaignAdministrator varchar(255),
      strComments varchar(255),
      CampaignCategoryID bigint
	)

	--Data Audit--


	DECLARE @idfCampaignToDiagnosisDelete TABLE
	(
		idfObject bigint,
		idfTable bigint
	);
	DECLARE @idfCampaignToDiagnosisInsert TABLE
	(
		idfObject bigint,
		idfTable bigint
	);
	DECLARE @tlbMonitoringSessionDelete TABLE
	(
		idfObject bigint,
		idfTable bigint
	);

	--Data Audit--

    BEGIN TRY
        BEGIN TRANSACTION

        INSERT INTO @tlbCampaignToDiagnosis
        (
            idfCampaignToDiagnosis,
            idfsDiagnosis,
            intOrder,
            intPlannedNumber,
            idfsSpeciesType, -- no Sample Type for human
            idfsSampleType,
            Comments
        )
        SELECT *
        FROM
            OPENJSON(@CampaignToDiagnosisCombo)
            WITH
            (
                idfCampaignToDiagnosis BIGINT,
                idfsDiagnosis BIGINT,
                intOrder INT,
                intPlannedNumber INT,
                idfsSpeciesType BIGINT,
                idfsSampleType BIGINT,
                Comments NVARCHAR(MAX)
            );

        INSERT INTO @tlbMonitoringSession
        SELECT *
        FROM
            OPENJSON(@MonitoringSessions)
            WITH
            (
                idfMonitoringSession BIGINT,
                deleteFlag BIT
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
		select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation(@AuditUserName) userInfo
		--Data Audit--


		if @CampaignCategoryTypeID = 10501001
		BEGIN
			set @idfsObjectType=10017061;
		END
		ELSE IF @CampaignCategoryTypeID = 10501002
		BEGIN
			set @idfsObjectType=10017073;
		END

        IF NOT EXISTS
        (
            SELECT *
            FROM dbo.tlbCampaign
            WHERE idfCampaign = @idfCampaign
                  AND intRowStatus = 0
        )
        BEGIN
            IF @CampaignCategoryTypeID = 10501001
                SET @ObjectName = 'Human Active Surveillance Campaign';
            ELSE
                SET @ObjectName = 'Vet Active Surveillance Campaign';

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbCampaign', @idfCampaign OUTPUT;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName,
                                               @strCampaignID OUTPUT,
                                               NULL;
            INSERT INTO dbo.tlbCampaign
            (
                idfCampaign,
                idfsCampaignType,
                idfsCampaignStatus,
                datCampaignDateStart,
                datCampaignDateEnd,
                strCampaignID,
                strCampaignName,
                strCampaignAdministrator,
                strConclusion,
                intRowStatus,
                rowguid,
                CampaignCategoryID,
                idfsSite,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                AuditCreateDTM,
                AuditUpdateUser,
                AuditUpdateDTM
            )
            VALUES
            (@idfCampaign,
             @CampaignTypeID,
             @CampaignStatusTypeID,
             @CampaignDateStart,
             @CampaignDateEnd,
             @strCampaignID,
             @CampaignName,
             @CampaignAdministrator,
             @Conclusion,
             0  ,
             NEWID(),
             @CampaignCategoryTypeID,
             @SiteID,
             10519001,
             '[{"idfCampaign":' + CAST(@idfCampaign AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             GETDATE(),
             @AuditUserName,
             GETDATE()
            );

			--Data Audit--
			-- tauDataAuditEvent Event Type - Create 
			set @idfsDataAuditEventType =10016001;
					-- insert record into tauDataAuditEvent - 
			INSERT INTO @SuppressSelect
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfCampaign, @idfObjectTable_tlbCampaign, @idfDataAuditEvent OUTPUT

			INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
				values ( @idfDataAuditEvent, @idfObjectTable_tlbCampaign, @idfCampaign)
			--Data Audit--

            UPDATE @EventsTemp
            SET ObjectId = @idfCampaign
            WHERE ObjectId = 0;

        END
        ELSE
        BEGIN
	
			insert into @tlbCampaign_BeforeEdit ( CampaignId,CampaignTypeID ,CampaignStatusTypeID,CampaignDateStart,CampaignDateEnd,strCampaignID,strCampaignName,strCampaignAdministrator,strComments)
			select idfCampaign, idfsCampaignType,idfsCampaignStatus, datCampaignDateStart, datCampaignDateEnd,strCampaignAdministrator, strCampaignName,strCampaignAdministrator, strComments from tlbCampaign where idfCampaign =@idfCampaign;

            UPDATE dbo.tlbCampaign
            SET idfsCampaignType = @CampaignTypeID,
                idfsCampaignStatus = @CampaignStatusTypeID,
                datCampaignDateStart = @CampaignDateStart,
                datCampaignDateEnd = @CampaignDateEnd,
                strCampaignID = @strCampaignID,
                strCampaignName = @CampaignName,
                strCampaignAdministrator = @CampaignAdministrator,
                strConclusion = @Conclusion,
                CampaignCategoryID = @CampaignCategoryTypeID,
                idfsSite = @SiteID,
                intRowStatus = 0, -- no reason to update a deleted record
                SourceSystemNameID = ISNULL(SourceSystemNameID, 10519001),
                SourceSystemKeyValue = ISNULL(
                                                 SourceSystemKeyValue,
                                                 '[{"idfCampaign":' + CAST(@idfCampaign AS NVARCHAR(300)) + '}]'
                                             ),
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfCampaign = @idfCampaign;

			insert into @tlbCampaign_AfterEdit (CampaignId, CampaignTypeID ,CampaignStatusTypeID,CampaignDateStart,CampaignDateEnd,strCampaignID,strCampaignName,strCampaignAdministrator,strComments)
			select idfCampaign, idfsCampaignType,idfsCampaignStatus, datCampaignDateStart, datCampaignDateEnd,strCampaignAdministrator, strCampaignName,strCampaignAdministrator, strComments  from tlbCampaign where idfCampaign =@idfCampaign;
			
			--DataAudit-- 
			--  tauDataAuditEvent  Event Type- Edit 
			set @idfsDataAuditEventType =10016003;
			-- insert record into tauDataAuditEvent - 
			INSERT INTO @SuppressSelect
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbCampaign, @idfDataAuditEvent OUTPUT

			--INSERT INTO tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfObject )
				--values ( @idfDataAuditEvent, @idfObjectTable_tlbCampaign, @idfCampaign)
				
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbCampaign, 706920000000,
				a.CampaignId,null,
				a.CampaignCategoryID,b.CampaignCategoryID 
			from @tlbCampaign_BeforeEdit a  inner join @tlbCampaign_AfterEdit b on a.CampaignId = b.CampaignId
			where (a.CampaignCategoryID <> b.CampaignCategoryID) 
				or(a.CampaignCategoryID is not null and b.CampaignCategoryID is null)
				or(a.CampaignCategoryID is null and b.CampaignCategoryID is not null)
				
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbCampaign, 706950000000,
				a.CampaignId,null,
				a.CampaignDateEnd,b.CampaignDateEnd 
			from @tlbCampaign_BeforeEdit a  inner join @tlbCampaign_AfterEdit b on a.CampaignId = b.CampaignId
			where (a.CampaignDateEnd <> b.CampaignDateEnd) 
				or(a.CampaignDateEnd is not null and b.CampaignDateEnd is null)
				or(a.CampaignDateEnd is null and b.CampaignDateEnd is not null)
						
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbCampaign, 706940000000,
				a.CampaignId,null,
				a.CampaignDateStart,b.CampaignDateStart 
			from @tlbCampaign_BeforeEdit a  inner join @tlbCampaign_AfterEdit b on a.CampaignId = b.CampaignId
			where (a.CampaignDateStart <> b.CampaignDateStart) 
				or(a.CampaignDateStart is not null and b.CampaignDateStart is null)
				or(a.CampaignDateStart is null and b.CampaignDateStart is not null)
			
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbCampaign, 706930000000,
				a.CampaignId,null,
				a.CampaignStatusTypeID,b.CampaignStatusTypeID 
			from @tlbCampaign_BeforeEdit a  inner join @tlbCampaign_AfterEdit b on a.CampaignId = b.CampaignId
			where (a.CampaignStatusTypeID <> b.CampaignStatusTypeID) 
				or(a.CampaignStatusTypeID is not null and b.CampaignStatusTypeID is null)
				or(a.CampaignStatusTypeID is null and b.CampaignStatusTypeID is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbCampaign, 706920000000,
				a.CampaignId,null,
				a.CampaignTypeID,b.CampaignTypeID 
			from @tlbCampaign_BeforeEdit a  inner join @tlbCampaign_AfterEdit b on a.CampaignId = b.CampaignId
			where (a.CampaignTypeID <> b.CampaignTypeID) 
				or(a.CampaignTypeID is not null and b.CampaignTypeID is null)
				or(a.CampaignTypeID is null and b.CampaignTypeID is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbCampaign, 706980000000,
				a.CampaignId,null,
				a.strCampaignAdministrator,b.strCampaignAdministrator 
			from @tlbCampaign_BeforeEdit a  inner join @tlbCampaign_AfterEdit b on a.CampaignId = b.CampaignId
			where (a.strCampaignAdministrator <> b.strCampaignAdministrator) 
				or(a.strCampaignAdministrator is not null and b.strCampaignAdministrator is null)
				or(a.strCampaignAdministrator is null and b.strCampaignAdministrator is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbCampaign, 706970000000,
				a.CampaignId,null,
				a.strCampaignName,b.strCampaignName 
			from @tlbCampaign_BeforeEdit a  inner join @tlbCampaign_AfterEdit b on a.CampaignId = b.CampaignId
			where (a.strCampaignName <> b.strCampaignName) 
				or(a.strCampaignName is not null and b.strCampaignName is null)
				or(a.strCampaignName is null and b.strCampaignName is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbCampaign, 706960000000,
				a.CampaignId,null,
				a.strCampaignID,b.strCampaignID 
			from @tlbCampaign_BeforeEdit a  inner join @tlbCampaign_AfterEdit b on a.CampaignId = b.CampaignId
			where (a.strCampaignID <> b.strCampaignID) 
				or(a.strCampaignID is not null and b.strCampaignID is null)
				or(a.strCampaignID is null and b.strCampaignID is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbCampaign, 706990000000,
				a.CampaignId,null,
				a.strComments,b.strComments 
			from @tlbCampaign_BeforeEdit a  inner join @tlbCampaign_AfterEdit b on a.CampaignId = b.CampaignId
			where (a.strComments <> b.strComments) 
				or(a.strComments is not null and b.strComments is null)
				or(a.strComments is null and b.strComments is not null)
			--DataAudit-- 

        END

		
        -----------------------------------------------------------------------------------------------------------------------------
        -- This is in the case of updates so that all associated records would be deleted, then re-stored by the following udpates.
        -----------------------------------------------------------------------------------------------------------------------------

        UPDATE dbo.tlbCampaignToDiagnosis
        SET intRowStatus = 1
        WHERE idfCampaign = @idfCampaign

		--Data Audit-- Delete
		if (@@ROWCOUNT>0)
		BEGIN
			insert into @idfCampaignToDiagnosisDelete(idfObject,idfTable)
			select idfCampaignToDiagnosis,@idfObjectTable_tlbCampaignToDiagnosis from tlbCampaignToDiagnosis WHERE idfCampaign = @idfCampaign and intRowStatus = 1

			INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, idfTable, idfObject FROM @idfCampaignToDiagnosisDelete
		END
		--Data Audit--

        WHILE EXISTS (SELECT * FROM @tlbCampaignToDiagnosis) -- process the temp table created from the parameter @CampaignToDiagnosisCombo 
        BEGIN

            SET @idfRow =
            (
                SELECT MIN(idfRow) FROM @tlbCampaignToDiagnosis
            )

            SELECT @RowID = idfCampaignToDiagnosis,
                   @idfsDiagnosis = idfsDiagnosis,
                   @intOrder = intOrder,
                   @intPlannedNumber = intPlannedNumber,
                   @idfsSpeciesType = idfsSpeciesType,
                   @idfsSampleType = idfsSampleType,
                   @Comments = Comments
            FROM @tlbCampaignToDiagnosis
            WHERE idfRow = @idfRow

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_HAS_CampaignToDiagnosis_SET @RowID,
                                                         @idfCampaign,
                                                         @idfsDiagnosis,
                                                         @intOrder,
                                                         @intPlannedNumber,
                                                         @idfsSpeciesType,
                                                         @idfsSampleType,
                                                         @Comments,
                                                         @AuditUserName

            DELETE FROM @tlbCampaignToDiagnosis
            WHERE idfRow = @idfRow

        END;
		
		--Data Audit-- Create
		if EXISTS(select top 1 idfCampaignToDiagnosis from tlbCampaignToDiagnosis where idfCampaign = @idfCampaign)
		BEGIN

			INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, @idfObjectTable_tlbCampaignToDiagnosis, idfCampaignToDiagnosis FROM tlbCampaignToDiagnosis WHERE idfCampaign = @idfCampaign and intRowStatus = 0
		END
		--Data Audit--

		--Data Audit-- Update
			INSERT INTO tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, @idfObjectTable_tlbMonitoringSession, idfMonitoringSession FROM @tlbMonitoringSession 
		--Data Audit--

        WHILE EXISTS (SELECT * FROM @tlbMonitoringSession WHERE deleteFlag = 0)
        BEGIN
            SELECT TOP 1
                @idfMonitoringSession = idfMonitoringSession
            FROM @tlbMonitoringSession;

            UPDATE dbo.tlbMonitoringSession
            SET idfCampaign = @idfCampaign,
                AuditUpdateDTM = GETDATE(),
                AuditCreateUser = @AuditUserName
            WHERE idfMonitoringSession = @idfMonitoringSession

            DELETE FROM @tlbMonitoringSession
            WHERE idfMonitoringSession = @idfMonitoringSession
                  AND deleteFlag = 0;
        END;

        WHILE EXISTS (SELECT * FROM @tlbMonitoringSession WHERE deleteFlag = 1)
        BEGIN
            SELECT TOP 1
                @idfMonitoringSession = idfMonitoringSession
            FROM @tlbMonitoringSession;

            UPDATE dbo.tlbMonitoringSession
            SET idfCampaign = null,
                AuditUpdateDTM = GETDATE(),
                AuditCreateUser = @AuditUserName
            WHERE idfMonitoringSession = @idfMonitoringSession

            DELETE FROM @tlbMonitoringSession
            WHERE idfMonitoringSession = @idfMonitoringSession
                  AND deleteFlag = 1;
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

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @idfCampaign idfCampaign,
               @strCampaignID strCampaignID;

    END TRY
    BEGIN CATCH
        IF @@Trancount > 0
            ROLLBACK TRANSACTION;

        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @idfCampaign idfCampaign,
               @strCampaignID strCampaignID;

        THROW;
    END CATCH
END
