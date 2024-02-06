-- ================================================================================================
-- Name: USP_CONF_AggregateSetting_SET		
--
-- Description: Creates and updates entries for aggregate settings.
-- 
-- Author: Lamont Mitchell
-- 
-- Revision History:
-- Name							Date       Change Detail
-- ---------------------------- ---------- -------------------------------------------------------
-- Lamont Mitchell              11/27/2018 Initial Created
-- Stephen Long                 07/08/2022 Added site alert and audit logic.
-- Ann Xiong					01/19/2022 Added scripts to allow each site to define its own Aggregate Settings
-- Ann Xiong					01/31/2022 Updated to insert second and third level site aggregate settings.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_AggregateSetting_SET]
    @AggregateSettingRecords NVARCHAR(MAX) = NULL,
    @Events NVARCHAR(MAX) = NULL,
    @AuditUserName NVARCHAR(200)
AS
BEGIN
    DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
            @ReturnCode BIGINT = 0,
            @AggregateDiseaseReportTypeId BIGINT = NULL,
            @CustomizationPackageId BIGINT = NULL,
			@SiteId BIGINT = NULL,
            @StatisticalAreaTypeId BIGINT = NULL,
            @StatisticalPeriodTypeId BIGINT = NULL,
            @idfsReferenceType BIGINT,
            @EventId BIGINT,
            @EventTypeId BIGINT = NULL,
            @EventSiteId BIGINT = NULL,
            @EventObjectId BIGINT = NULL,
            @EventUserId BIGINT = NULL,
            @EventDiseaseId BIGINT = NULL,
            @EventLocationId BIGINT = NULL,
            @EventInformationString NVARCHAR(MAX) = NULL,
            @EventLoginSiteId BIGINT = NULL;
    DECLARE @AggregateSettingRecordsTemp TABLE
    (
        AggregateDiseaseReportTypeId BIGINT NOT NULL,
        CustomizationPackageId BIGINT NOT NULL,
		SiteId BIGINT NULL,
        StatisticalAreaTypeId BIGINT NOT NULL,
        StatisticalPeriodTypeId BIGINT NOT NULL
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
	declare @idfsObjectType bigint = 10017007;
	declare @idfObject bigint = NULL;
	declare @idfObjectTable_tlbAggrSettings bigint = 76030000000;
	declare @idfDataAuditEvent bigint= NULL; 

	DECLARE @tlbAggrSettings_BeforeEdit TABLE
	(
	  SiteId bigint,
	  idfsAggrCaseType bigint,
	  idfCustomizationPackage bigint, 
      idfsStatisticAreaType bigint, 
      idfsStatisticPeriodType bigint
	)
	DECLARE @tlbAggrSettings_AfterEdit TABLE
	(
	  SiteId bigint,
	  idfsAggrCaseType bigint,
	  idfCustomizationPackage bigint, 
      idfsStatisticAreaType bigint, 
      idfsStatisticPeriodType bigint
	)
	
	--Data Audit--
	-- Get and Set UserId and SiteId
	select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation(@AuditUserName) userInfo
	--Data Audit--

    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );

    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO @AggregateSettingRecordsTemp
        SELECT *
        FROM
            OPENJSON(@AggregateSettingRecords)
            WITH
            (
                AggregateDiseaseReportTypeId BIGINT,
                CustomizationPackageId BIGINT,
				SiteId BIGINT,
                StatisticalAreaTypeId BIGINT,
                StatisticalPeriodTypeId BIGINT
            );

        WHILE EXISTS (SELECT * FROM @AggregateSettingRecordsTemp)
        BEGIN
            SELECT TOP 1
                @AggregateDiseaseReportTypeId = AggregateDiseaseReportTypeId,
                @CustomizationPackageId = CustomizationPackageId,
				@SiteId = SiteId,
                @StatisticalAreaTypeId = StatisticalAreaTypeId,
                @StatisticalPeriodTypeId = StatisticalPeriodTypeId
            FROM @AggregateSettingRecordsTemp;

			SET @idfObject = @AggregateDiseaseReportTypeId --CONVERT(NVARCHAR,@SiteId) + CONVERT(NVARCHAR,@AggregateDiseaseReportTypeId);

            IF EXISTS
            (
                SELECT idfsAggrCaseType,
                       idfCustomizationPackage,
					   idfsSite,
                       idfsStatisticAreaType,
                       idfsStatisticPeriodType
                FROM dbo.tstAggrSetting
                WHERE idfsAggrCaseType = @AggregateDiseaseReportTypeId
                      AND idfCustomizationPackage = @CustomizationPackageId
					  AND idfsSite = @SiteId
                      AND intRowStatus = 0
            )
            BEGIN

				Delete from @tlbAggrSettings_BeforeEdit
				insert into @tlbAggrSettings_BeforeEdit (SiteId, idfsAggrCaseType ,idfCustomizationPackage, idfsStatisticAreaType,idfsStatisticPeriodType)
				select idfsSite, idfsAggrCaseType, idfCustomizationPackage, idfsStatisticAreaType, idfsStatisticPeriodType 
					from tstAggrSetting where idfsAggrCaseType = @AggregateDiseaseReportTypeId AND idfCustomizationPackage = @CustomizationPackageId AND idfsSite = @SiteId AND intRowStatus = 0

                UPDATE dbo.tstAggrSetting
                SET idfsStatisticAreaType = @StatisticalAreaTypeId,
                    idfsStatisticPeriodType = @StatisticalPeriodTypeId,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsAggrCaseType = @AggregateDiseaseReportTypeId
                      AND idfCustomizationPackage = @CustomizationPackageId
					  AND idfsSite = @SiteId
                      AND intRowStatus = 0;
					  
				Delete from @tlbAggrSettings_AfterEdit
				insert into @tlbAggrSettings_AfterEdit (SiteId, idfsAggrCaseType ,idfCustomizationPackage, idfsStatisticAreaType,idfsStatisticPeriodType)
				select idfsSite, idfsAggrCaseType, idfCustomizationPackage, idfsStatisticAreaType, idfsStatisticPeriodType 
					from tstAggrSetting where idfsAggrCaseType = @AggregateDiseaseReportTypeId AND idfCustomizationPackage = @CustomizationPackageId AND idfsSite = @SiteId AND intRowStatus = 0
				
				--DataAudit-- 
				IF EXISTS 
				(
					select *
					from @tlbAggrSettings_BeforeEdit a  inner join @tlbAggrSettings_AfterEdit b on a.SiteId = b.SiteId 
						and a.idfsAggrCaseType = b.idfsAggrCaseType and a.idfCustomizationPackage = b.idfCustomizationPackage
					where ((a.idfsStatisticAreaType <> b.idfsStatisticAreaType) 
						or(a.idfsStatisticAreaType is not null and b.idfsStatisticAreaType is null)
						or(a.idfsStatisticAreaType is null and b.idfsStatisticAreaType is not null))
						OR
						((a.idfsStatisticPeriodType <> b.idfsStatisticPeriodType) 
						or(a.idfsStatisticPeriodType is not null and b.idfsStatisticPeriodType is null)
						or(a.idfsStatisticPeriodType is null and b.idfsStatisticPeriodType is not null))
				)
				BEGIN
					--  tauDataAuditEvent  Event Type- Edit 
					set @idfsDataAuditEventType = 10016003;
					-- insert record into tauDataAuditEvent - 
					INSERT INTO @SuppressSelect
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbAggrSettings, @idfDataAuditEvent OUTPUT

					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, idfObjectTable, idfColumn, 
						idfObject, idfObjectDetail, 
						strOldValue, strNewValue)
					select @idfDataAuditEvent,@idfObjectTable_tlbAggrSettings, 4578190000000,
						@idfObject,null,
						a.idfsStatisticAreaType,b.idfsStatisticAreaType 
					from @tlbAggrSettings_BeforeEdit a  inner join @tlbAggrSettings_AfterEdit b on a.SiteId = b.SiteId 
						and a.idfsAggrCaseType = b.idfsAggrCaseType and a.idfCustomizationPackage = b.idfCustomizationPackage
					where (a.idfsStatisticAreaType <> b.idfsStatisticAreaType) 
						or(a.idfsStatisticAreaType is not null and b.idfsStatisticAreaType is null)
						or(a.idfsStatisticAreaType is null and b.idfsStatisticAreaType is not null)
				
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, idfObjectTable, idfColumn, 
						idfObject, idfObjectDetail, 
						strOldValue, strNewValue)
					select @idfDataAuditEvent,@idfObjectTable_tlbAggrSettings, 4578200000000,
						@idfObject,null,
						a.idfsStatisticPeriodType,b.idfsStatisticPeriodType 
					from @tlbAggrSettings_BeforeEdit a  inner join @tlbAggrSettings_AfterEdit b on a.SiteId = b.SiteId 
						and a.idfsAggrCaseType = b.idfsAggrCaseType and a.idfCustomizationPackage = b.idfCustomizationPackage
					where (a.idfsStatisticPeriodType <> b.idfsStatisticPeriodType) 
						or(a.idfsStatisticPeriodType is not null and b.idfsStatisticPeriodType is null)
						or(a.idfsStatisticPeriodType is null and b.idfsStatisticPeriodType is not null)
				END
				--DataAudit-- 
            END
            ELSE
            BEGIN
                --INSERT INTO @SuppressSelect
                --EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tstAggrSetting',
                --                                  @AggregateDiseaseReportTypeId OUTPUT;

                INSERT INTO dbo.tstAggrSetting
                (
                    idfsAggrCaseType,
                    idfCustomizationPackage,
					idfsSite,
                    idfsStatisticAreaType,
                    idfsStatisticPeriodType,
                    AuditCreateDTM,
                    AuditCreateUser,
                    SourceSystemKeyValue,
                    SourceSystemNameID
                )
                VALUES
                (@AggregateDiseaseReportTypeId,
                 @CustomizationPackageId,
				 @SiteId,
                 @StatisticalAreaTypeId,
                 @StatisticalPeriodTypeId,
                 GETDATE(),
                 @AuditUserName,
                 '[{"idfsAggrCaseType":' + CAST(@AggregateDiseaseReportTypeId AS NVARCHAR(300))
                 + ',"idfCustomizationPackage":' + CAST(@CustomizationPackageId AS NVARCHAR(300)) + '}]',
                 10519001
                );

				
				--Data Audit--
				-- tauDataAuditEvent Event Type - Create 
				set @idfsDataAuditEventType =10016001;
						-- insert record into tauDataAuditEvent - 
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbAggrSettings, @idfDataAuditEvent OUTPUT

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
					values ( @idfDataAuditEvent, @idfObjectTable_tlbAggrSettings, @idfObject)
				--Data Audit--

                UPDATE @EventsTemp
                SET ObjectId = @AggregateDiseaseReportTypeId
                WHERE ObjectId = 0;
            END

            DELETE FROM @AggregateSettingRecordsTemp
            WHERE AggregateDiseaseReportTypeId = @AggregateDiseaseReportTypeId;
        END

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

        SELECT @ReturnCode 'ReturnCode',
               @ReturnMessage 'ReturnMessage';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END



