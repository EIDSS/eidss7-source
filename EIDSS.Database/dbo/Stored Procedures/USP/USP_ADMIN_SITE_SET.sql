-- ================================================================================================
-- Name: USP_ADMIN_SITE_SET
--
-- Description:	Inserts or updates an EIDSS site for SAUC29.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/14/2022 Initial release.
-- Stephen Long     03/14/2022 Added additional columns to suppress select for employee group set.
-- Stephen Long     05/17/2022 Added insert for a new organization association to a site.
-- Stephen Long     07/15/2022 Comment out access rule name field; need to add base reference 
--                             logic for the name.
-- Stephen Long     12/22/2022 Fixed site permissions to use new stored procedure for object 
--                             access set, and logic for the default employee group for new sites.
-- Stephen Long     01/10/2023 Fix to add default employee group for existing sites when it does 
--                             not exist.
-- Ann Xiong		02/01/2022 Updated to copy aggreatesettings of parent site or top level site 
--                             and insert those aggreatesettings to the table tstAggrSetting when create a new site
-- Mani Govindarajan02/5/2023  Added to call [USSP_GBL_SITE_CUSTOMUSERGROUUP_SET] for adding Custom Roles for the newly added site.
-- Ann Xiong		02/20/2023 Implemented Data Audit
-- Ann Xiong		03/06/2023 Called USSP_GBL_BASE_REFERENCE_SET instead of USP_GBL_BaseReference_SET to use its data auditing
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_SITE_SET]
(
    @LanguageID NVARCHAR(50),
    @SiteID BIGINT = NULL,
    @CustomizationPackageID BIGINT = NULL,
    @EIDSSSiteID NVARCHAR(36) = NULL,
    @ParentSiteID BIGINT = NULL,
    @SiteTypeID BIGINT = NULL,
    @SiteName NVARCHAR(200) = NULL,
    @SiteOrganizationID BIGINT = NULL,
    @HASCSiteID NVARCHAR(50) = NULL,
    @RowStatus INT,
    @Permissions NVARCHAR(MAX) = NULL,
    @Organizations NVARCHAR(MAX) = NULL,
    @UserName NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ReturnCode INT
            = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
                @RowAction CHAR = NULL,
                @RowID BIGINT = NULL,
                @OrganizationID BIGINT = NULL,
                @DefaultEmployeeGroupActorID BIGINT = -506, -- Default group for an EIDSS installation; not actually used for users/employees, but only as a template for other sites.
                @ObjectAccessID BIGINT = NULL,
                @ObjectOperationTypeID BIGINT = NULL,
                @ObjectTypeID BIGINT = NULL,
                @ObjectID BIGINT = NULL,
                @ActorID BIGINT = NULL,
                @PermissionTypeID INT = NULL;

        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );
        DECLARE @OrganizationsTemp TABLE
        (
            OrganizationID BIGINT NOT NULL,
            RowAction INT NOT NULL
        );
        DECLARE @ObjectAccessRecordsTemp TABLE
        (
            ObjectAccessID BIGINT NOT NULL,
            ObjectOperationTypeID BIGINT NOT NULL,
            ObjectTypeID BIGINT NOT NULL,
            ObjectID BIGINT NOT NULL,
            ActorID BIGINT NOT NULL,
            DefaultEmployeeGroupIndicator BIT NOT NULL,
            SiteID BIGINT NOT NULL,
            PermissionTypeID INT NOT NULL,
            RowStatus INT NOT NULL,
            RowAction CHAR(1) NULL
        );

		DECLARE @AggregateDiseaseReportTypeId BIGINT = NULL,
				@idfCustomizationPackage BIGINT = NULL,
				@idfsSite BIGINT = NULL,
				@StatisticalAreaTypeId BIGINT = NULL,
				@StatisticalPeriodTypeId BIGINT = NULL

		DECLARE @AggregateSettingRecordsTemp TABLE
		(
			AggregateDiseaseReportTypeId BIGINT NOT NULL,
			CustomizationPackageId BIGINT NOT NULL,
			SiteId BIGINT NULL,
			StatisticalAreaTypeId BIGINT NOT NULL,
			StatisticalPeriodTypeId BIGINT NOT NULL
		);

		--Data Audit--
		declare @idfUserId BIGINT = NULL;
		declare @idfSiteId BIGINT = NULL;
		declare @idfsDataAuditEventType bigint = NULL;
		declare @idfsObjectType bigint = 10017048;                         -- Site
		declare @idfObject bigint = @SiteID;
		declare @idfObjectTable_tstSite bigint = 76170000000;
		declare @idfDataAuditEvent bigint= NULL;
		declare @idfObjectTable_tlbEmployee bigint = 75520000000;
		declare @idfObjectTable_tlbEmployeeGroup bigint = 75530000000;
		declare @idfObjectTable_tstAggrSetting bigint = 76030000000;
		declare @idfObjectTable_tlbOffice bigint = 75650000000;

		DECLARE @tstSite_BeforeEdit TABLE
		(
			SiteID BIGINT,
			ParentSiteID BIGINT,
			SiteTypeID BIGINT,
			CustomizationPackageID BIGINT,
			SiteOrganizationID BIGINT,
			SiteName varchar(200),
			HASCSiteID varchar(50),
			EIDSSSiteID varchar(36)
		);
		DECLARE @tstSite_AfterEdit TABLE
		(
			SiteID BIGINT,
			ParentSiteID BIGINT,
			SiteTypeID BIGINT,
			CustomizationPackageID BIGINT,
			SiteOrganizationID BIGINT,
			SiteName varchar(200),
			HASCSiteID varchar(50),
			EIDSSSiteID varchar(36)
		);

		-- Get and Set UserId and SiteId
		select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation(@UserName) userInfo

		--Data Audit--

        BEGIN TRANSACTION;

        INSERT INTO @OrganizationsTemp
        SELECT *
        FROM
            OPENJSON(@Organizations)
            WITH
            (
                OrganizationID BIGINT,
                RowAction INT
            );

        INSERT INTO @ObjectAccessRecordsTemp
        SELECT *
        FROM
            OPENJSON(@Permissions)
            WITH
            (
                ObjectAccessID BIGINT,
                ObjectOperationTypeID BIGINT,
                ObjectTypeID BIGINT,
                ObjectID BIGINT,
                ActorID BIGINT,
                DefaultEmployeeGroupIndicator BIT,
                SiteID BIGINT,
                PermissionTypeID INT,
                RowStatus INT,
                RowAction CHAR(1)
            );

        IF (
               ISNULL(@EIDSSSiteID, N'') <> N''
               AND EXISTS
        (
            SELECT strSiteID
            FROM dbo.tstSite
            WHERE strSiteID = @EIDSSSiteID
        )
               AND @SiteID IS NULL
           )
        BEGIN
            SELECT @ReturnMessage = 'SITE ID DOES EXIST';

            SELECT @ReturnCode = 1;
        END

        IF @ReturnCode = 0
           AND (
                   ISNULL(@HASCSiteID, N'') <> N''
                   AND EXISTS
        (
            SELECT strHASCsiteID
            FROM dbo.tstSite
            WHERE strHASCsiteID = @HASCSiteID
        )
                   AND @SiteID IS NULL
               )
        BEGIN
            SELECT @ReturnMessage = 'HASC SITE ID DOES EXIST';

            SELECT @ReturnCode = 2;
        END

        IF @ReturnCode = 0
        BEGIN
            -- Create the Default Employee Group for the new site
            DECLARE @LanguageCode BIGINT = dbo.FN_GBL_LanguageCode_Get(@LanguageID),
                    @NewDefaultEmployeeGroupActorID BIGINT = NULL,
                    @NewDefaultEmployeeGroupNameID BIGINT = NULL;
            DECLARE @DefaultEmployeeGroupDefaultName NVARCHAR(200)
                =   (
                        SELECT strDefault
                        FROM dbo.trtBaseReference
                        WHERE idfsBaseReference = @DefaultEmployeeGroupActorID
                    ),
                    @DefaultEmployeeGroupNationalName NVARCHAR(200) = (
                                                                          SELECT strTextString
                                                                          FROM dbo.trtStringNameTranslation
                                                                          WHERE idfsBaseReference = @DefaultEmployeeGroupActorID
                                                                                AND idfsLanguage = @LanguageCode
                                                                      ),
                    @DefaultEmployeeGroupDescription NVARCHAR(200) = (
                                                                         SELECT strDescription
                                                                         FROM dbo.tlbEmployeeGroup
                                                                         WHERE idfEmployeeGroup = @DefaultEmployeeGroupActorID
                                                                     );

            IF NOT EXISTS
            (
                SELECT *
                FROM dbo.tstSite
                WHERE idfsSite = @SiteID
                      AND intRowStatus = 0
            )
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'tstSite',
                                                  @idfsKey = @SiteID OUTPUT;

                IF @CustomizationPackageID IS NULL
                BEGIN
                    SET @CustomizationPackageID = dbo.FN_GBL_CustomizationPackage_GET();
                END

                INSERT INTO dbo.tstSite
                (
                    idfsSite,
                    idfsParentSite,
                    idfsSiteType,
                    idfCustomizationPackage,
                    idfOffice,
                    strSiteName,
                    strHASCsiteID,
                    strSiteID,
                    blnIsWEB,
                    intRowStatus,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser
                )
                VALUES
                (@SiteID,
                 @ParentSiteID,
                 @SiteTypeID,
                 @CustomizationPackageID,
                 @SiteOrganizationID,
                 @SiteName,
                 @HASCSiteID,
                 @EIDSSSiteID,
                 0  ,
                 0  ,
                 10519001,
                 '[{"idfsSite":' + CAST(@SiteID AS NVARCHAR(300)) + '}]',
                 @UserName
                );

				--Data Audit--
				-- tauDataAuditEvent Event Type - Create 
				set @idfsDataAuditEventType =10016001;
				-- insert record into tauDataAuditEvent - 
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@SiteID, @idfObjectTable_tstSite, @idfDataAuditEvent OUTPUT

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tstSite, @SiteID)
				--Data Audit--

				INSERT INTO @SuppressSelect
				EXEC dbo.USSP_GBL_SITE_CUSTOMUSERGROUP_SET @SiteID

                SET @NewDefaultEmployeeGroupActorID =
                (
                    SELECT MIN(idfEmployee) - 1 FROM dbo.tlbEmployee
                );

                INSERT INTO @SuppressSelect
				EXECUTE dbo.USSP_GBL_BASE_REFERENCE_SET  @NewDefaultEmployeeGroupNameID OUTPUT,
                                                        19000022,
                                                        @LanguageID,
                                                        @DefaultEmployeeGroupDefaultName,
                                                        @DefaultEmployeeGroupNationalName,
                                                        226,
                                                        0,
                                                        1,
                                                        @UserName,
                                                        @idfDataAuditEvent,
                                                        NULL;
                --EXEC dbo.USP_GBL_BaseReference_SET @ReferenceID = @NewDefaultEmployeeGroupNameID OUTPUT,
                --                                   @ReferenceType = 19000022,
                --                                   @LangID = @LanguageID,
                --                                   @DefaultName = @DefaultEmployeeGroupDefaultName,
                --                                   @NationalName = @DefaultEmployeeGroupNationalName,
                --                                   @HACode = 226,
                --                                   @Order = 0,
                --                                   @System = 1,
                --                                   @User = @UserName;

                INSERT INTO dbo.tlbEmployee
                (
                    idfEmployee,
                    idfsEmployeeType,
                    idfsSite,
                    intRowStatus,
                    AuditCreateDTM,
                    AuditCreateUser
                )
                VALUES
                (@NewDefaultEmployeeGroupActorID, 10023001, @SiteID, 0, GETDATE(), @UserName);

				--Data Audit--
				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tlbEmployee, @NewDefaultEmployeeGroupActorID)
				--Data Audit--

                INSERT INTO dbo.tlbEmployeeGroup
                (
                    idfEmployeeGroup,
                    idfsEmployeeGroupName,
                    idfsSite,
                    strName,
                    strDescription,
                    intRowStatus,
                    AuditCreateDTM,
                    AuditCreateUser
                )
                VALUES
                (@NewDefaultEmployeeGroupActorID,
                 @NewDefaultEmployeeGroupNameID,
                 @SiteID,
                 @DefaultEmployeeGroupNationalName,
                 @DefaultEmployeeGroupDescription,
                 0  ,
                 GETDATE(),
                 @UserName
                );

				--Data Audit--
				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tlbEmployeeGroup, @NewDefaultEmployeeGroupActorID)
				--Data Audit--

                UPDATE @ObjectAccessRecordsTemp
                SET ActorID = @NewDefaultEmployeeGroupActorID
                WHERE DefaultEmployeeGroupIndicator = 1;

				IF EXISTS
				(
					SELECT 	a.idfsAggrCaseType,
                       		a.idfCustomizationPackage,
			     			a.idfsSite,
                       		a.idfsStatisticAreaType,
                       		a.idfsStatisticPeriodType
					FROM 	dbo.tstAggrSetting a
							INNER JOIN dbo.tstSite s ON s.idfsSite = @SiteID
					WHERE 	a.idfCustomizationPackage = @CustomizationPackageID
			    			AND a.idfsSite = s.idfsParentSite
                      		AND a.intRowStatus = 0
				)
				BEGIN
					INSERT INTO @AggregateSettingRecordsTemp
					SELECT	AGR.[idfsAggrCaseType]
							,AGR.[idfCustomizationPackage]
							,AGR.[idfsSite]
							,AGR.[idfsStatisticAreaType]
							,AGR.[idfsStatisticPeriodType]
					FROM	dbo.tstAggrSetting AS AGR
							LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000102) AGRC ON AGRC.idfsReference = AGR.idfsAggrCaseType
							LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000089) ART ON ART.idfsReference = AGR.idfsStatisticAreaType
							LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000091) PRT ON PRT.idfsReference = AGR.idfsStatisticPeriodType
							INNER JOIN dbo.tstSite s ON s.idfsSite = @SiteID
					WHERE	AGR.[idfCustomizationPackage] = @CustomizationPackageID
							AND AGR.[idfsSite] = s.idfsParentSite
							AND AGR.intRowStatus = 0;
				END
				ELSE
				BEGIN
					DECLARE @idfsSiteTop BIGINT;

					SELECT TOP 1	
							@idfsSiteTop = idfsSite
					FROM 	dbo.tstAggrSetting
					WHERE 	idfCustomizationPackage = @CustomizationPackageID
                      		AND intRowStatus = 0;

					INSERT INTO @AggregateSettingRecordsTemp
					SELECT	AGR.[idfsAggrCaseType]
							,AGR.[idfCustomizationPackage]
							,AGR.[idfsSite]
							,AGR.[idfsStatisticAreaType]
							,AGR.[idfsStatisticPeriodType]
					FROM	dbo.tstAggrSetting AS AGR
							LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000102) AGRC ON AGRC.idfsReference = AGR.idfsAggrCaseType
							LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000089) ART ON ART.idfsReference = AGR.idfsStatisticAreaType
							LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000091) PRT ON PRT.idfsReference = AGR.idfsStatisticPeriodType
							INNER JOIN dbo.tstSite s ON s.idfsSite = @SiteID
					WHERE	AGR.[idfCustomizationPackage] = @CustomizationPackageID
							AND AGR.[idfsSite] = @idfsSiteTop
							AND AGR.intRowStatus = 0;
				END

        WHILE EXISTS (SELECT * FROM @AggregateSettingRecordsTemp)
        BEGIN
            SELECT TOP 1
                @AggregateDiseaseReportTypeId = AggregateDiseaseReportTypeId,
                @idfCustomizationPackage = CustomizationPackageId,
				@idfsSite = SiteId,
                @StatisticalAreaTypeId = StatisticalAreaTypeId,
                @StatisticalPeriodTypeId = StatisticalPeriodTypeId
            FROM @AggregateSettingRecordsTemp;
            BEGIN

                INSERT INTO dbo.tstAggrSetting
                (
                    idfsAggrCaseType,
                    idfCustomizationPackage,
					idfsSite,
                    idfsStatisticAreaType,
                    idfsStatisticPeriodType,
					intRowStatus,
                    AuditCreateDTM,
                    AuditCreateUser,
                    SourceSystemKeyValue,
                    SourceSystemNameID
                )
                VALUES
                (	@AggregateDiseaseReportTypeId,
					@idfCustomizationPackage,
					@SiteID,
					@StatisticalAreaTypeId,
					@StatisticalPeriodTypeId,
					0,
					GETDATE(),
					@UserName,
					'[{"idfsAggrCaseType":' + CAST(@AggregateDiseaseReportTypeId AS NVARCHAR(300))
					+ ',"idfCustomizationPackage":' + CAST(@idfCustomizationPackage AS NVARCHAR(300)) + '}]',
					10519001
                );

				--Data Audit--
				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tstAggrSetting, @AggregateDiseaseReportTypeId)
				--Data Audit--
            END

            DELETE FROM @AggregateSettingRecordsTemp
            WHERE AggregateDiseaseReportTypeId = @AggregateDiseaseReportTypeId;
        END


            END
            ELSE
            BEGIN
				-- Data audit
                INSERT INTO @tstSite_BeforeEdit
                (
                        SiteID,
                        ParentSiteID,
                        SiteTypeID,
                        CustomizationPackageID,
                        SiteOrganizationID,
                        SiteName,
                        HASCSiteID,
                        EIDSSSiteID
               )
               SELECT	idfsSite,
                           idfsParentSite,
                           idfsSiteType,
                           idfCustomizationPackage,
                           idfOffice,
                           strSiteName,
                           strHASCsiteID,
                           strSiteID
               FROM dbo.tstSite
               WHERE idfsSite = @SiteID;
               -- End data audit

                UPDATE dbo.tstSite
                SET idfsSiteType = @SiteTypeID,
                    idfsParentSite = @ParentSiteID,
                    idfCustomizationPackage = @CustomizationPackageID,
                    idfOffice = @SiteOrganizationID,
                    strSiteName = @SiteName,
                    strHASCsiteID = @HASCSiteID,
                    strSiteID = @EIDSSSiteID,
                    intRowStatus = @RowStatus,
                    AuditUpdateUser = @UserName,
                    AuditUpdateDTM = GETDATE()
                WHERE idfsSite = @SiteID;

                -- Data audit
                INSERT INTO @tstSite_AfterEdit
                (
                        SiteID,
                        ParentSiteID,
                        SiteTypeID,
                        CustomizationPackageID,
                        SiteOrganizationID,
                        SiteName,
                        HASCSiteID,
                        EIDSSSiteID
                 )
                 SELECT idfsSite,
                           idfsParentSite,
                           idfsSiteType,
                           idfCustomizationPackage,
                           idfOffice,
                           strSiteName,
                           strHASCsiteID,
                           strSiteID
                FROM dbo.tstSite
                WHERE idfsSite = @SiteID;

			    --  tauDataAuditEvent  Event Type- Edit 
			    set @idfsDataAuditEventType =10016003;
			    -- insert record into tauDataAuditEvent - 
			    EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@SiteID, @idfObjectTable_tstSite, @idfDataAuditEvent OUTPUT

				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_tstSite, 4578830000000,
					a.SiteID,null,
					a.ParentSiteID,b.ParentSiteID 
				from @tstSite_BeforeEdit a  inner join @tstSite_AfterEdit b on a.SiteID = b.SiteID
				where (a.ParentSiteID <> b.ParentSiteID) 
					or(a.ParentSiteID is not null and b.ParentSiteID is null)
					or(a.ParentSiteID is null and b.ParentSiteID is not null)

				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_tstSite, 82070000000,
					a.SiteID,null,
					a.SiteTypeID,b.SiteTypeID 
				from @tstSite_BeforeEdit a  inner join @tstSite_AfterEdit b on a.SiteID = b.SiteID
				where (a.SiteTypeID <> b.SiteTypeID) 
					or(a.SiteTypeID is not null and b.SiteTypeID is null)
					or(a.SiteTypeID is null and b.SiteTypeID is not null)

				--insert into dbo.tauDataAuditDetailUpdate(
				--	idfDataAuditEvent, idfObjectTable, idfColumn, 
				--	idfObject, idfObjectDetail, 
				--	strOldValue, strNewValue)
				--select @idfDataAuditEvent,@idfObjectTable_tstSite, 51577500000000,
				--	a.SiteID,null,
				--	a.CustomizationPackageID,b.CustomizationPackageID 
				--from @tstSite_BeforeEdit a  inner join @tstSite_AfterEdit b on a.SiteID = b.SiteID
				--where (a.CustomizationPackageID <> b.CustomizationPackageID) 
				--	or(a.CustomizationPackageID is not null and b.CustomizationPackageID is null)
				--	or(a.CustomizationPackageID is null and b.CustomizationPackageID is not null)

				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_tstSite, 82040000000,
					a.SiteID,null,
					a.SiteOrganizationID,b.SiteOrganizationID 
				from @tstSite_BeforeEdit a  inner join @tstSite_AfterEdit b on a.SiteID = b.SiteID
				where (a.SiteOrganizationID <> b.SiteOrganizationID) 
					or(a.SiteOrganizationID is not null and b.SiteOrganizationID is null)
					or(a.SiteOrganizationID is null and b.SiteOrganizationID is not null)

				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_tstSite, 82100000000,
					a.SiteID,null,
					a.SiteName,b.SiteName
				from @tstSite_BeforeEdit a  inner join @tstSite_AfterEdit b on a.SiteID = b.SiteID
				where (a.SiteName <> b.SiteName) 
					or(a.SiteName is not null and b.SiteName is null)
					or(a.SiteName is null and b.SiteName is not null)

				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_tstSite, 82080000000,
					a.SiteID,null,
					a.HASCSiteID,b.HASCSiteID 
				from @tstSite_BeforeEdit a  inner join @tstSite_AfterEdit b on a.SiteID = b.SiteID
				where (a.HASCSiteID <> b.HASCSiteID) 
					or(a.HASCSiteID is not null and b.HASCSiteID is null)
					or(a.HASCSiteID is null and b.HASCSiteID is not null)

				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_tstSite, 869060000000,
					a.SiteID,null,
					a.EIDSSSiteID,b.EIDSSSiteID 
				from @tstSite_BeforeEdit a  inner join @tstSite_AfterEdit b on a.SiteID = b.SiteID
				where (a.EIDSSSiteID <> b.EIDSSSiteID) 
					or(a.EIDSSSiteID is not null and b.EIDSSSiteID is null)
					or(a.EIDSSSiteID is null and b.EIDSSSiteID is not null)

                    -- End data audit

                IF EXISTS
                (
                    SELECT *
                    FROM @ObjectAccessRecordsTemp
                    WHERE DefaultEmployeeGroupIndicator = 1
                          AND RowAction = 'I'
                          AND RowStatus = 0
                )
                BEGIN
                    SET @NewDefaultEmployeeGroupActorID =
                    (
                        SELECT MIN(idfEmployee) - 1 FROM dbo.tlbEmployee
                    );

                    INSERT INTO @SuppressSelect
                    EXEC dbo.USP_GBL_BaseReference_SET @ReferenceID = @NewDefaultEmployeeGroupNameID OUTPUT,
                                                       @ReferenceType = 19000022,
                                                       @LangID = @LanguageID,
                                                       @DefaultName = @DefaultEmployeeGroupDefaultName,
                                                       @NationalName = @DefaultEmployeeGroupNationalName,
                                                       @HACode = 226,
                                                       @Order = 0,
                                                       @System = 1,
                                                       @User = @UserName;

                    INSERT INTO dbo.tlbEmployee
                    (
                        idfEmployee,
                        idfsEmployeeType,
                        idfsSite,
                        intRowStatus,
                        AuditCreateDTM,
                        AuditCreateUser
                    )
                    VALUES
                    (@NewDefaultEmployeeGroupActorID, 10023001, @SiteID, 0, GETDATE(), @UserName);

					--Data Audit--
					INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tlbEmployee, @NewDefaultEmployeeGroupActorID)
					--Data Audit--

                    INSERT INTO dbo.tlbEmployeeGroup
                    (
                        idfEmployeeGroup,
                        idfsEmployeeGroupName,
                        idfsSite,
                        strName,
                        strDescription,
                        intRowStatus,
                        AuditCreateDTM,
                        AuditCreateUser
                    )
                    VALUES
                    (@NewDefaultEmployeeGroupActorID,
                     @NewDefaultEmployeeGroupNameID,
                     @SiteID,
                     @DefaultEmployeeGroupNationalName,
                     @DefaultEmployeeGroupDescription,
                     0  ,
                     GETDATE(),
                     @UserName
                    );

					--Data Audit--
					INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tlbEmployeeGroup, @NewDefaultEmployeeGroupActorID)
					--Data Audit--

                    UPDATE @ObjectAccessRecordsTemp
                    SET ActorID = @NewDefaultEmployeeGroupActorID
                    WHERE DefaultEmployeeGroupIndicator = 1;
                END
            END;

            WHILE EXISTS (SELECT * FROM @OrganizationsTemp)
            BEGIN
                SELECT TOP 1
                    @RowID = OrganizationID,
                    @OrganizationID = OrganizationID,
                    @RowAction = RowAction
                FROM @OrganizationsTemp;

                IF @RowAction = 1 -- Insert
                   OR @RowAction = 2 -- Update
                BEGIN
                    UPDATE dbo.tlbOffice
                    SET idfsSite = @SiteID,
                        AuditUpdateDTM = GETDATE(),
                        AuditUpdateUser = @UserName
                    WHERE idfOffice = @OrganizationID;
                END
                ELSE
                BEGIN
                    UPDATE dbo.tlbOffice
                    SET idfsSite = NULL,
                        AuditUpdateDTM = GETDATE(),
                        AuditUpdateUser = @UserName
                    WHERE idfOffice = @OrganizationID;
                END;

				--Data Audit-- Update
					INSERT INTO tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfObject )
						SELECT @idfDataAuditEvent, @idfObjectTable_tlbOffice, @OrganizationID 
				--Data Audit--

                DELETE FROM @OrganizationsTemp
                WHERE @OrganizationID = @RowID;
            END

            WHILE EXISTS (SELECT * FROM @ObjectAccessRecordsTemp)
            BEGIN
                SELECT TOP 1
                    @RowID = ObjectAccessID,
                    @ObjectAccessID = ObjectAccessID,
                    @ObjectOperationTypeID = ObjectOperationTypeID,
                    @ObjectTypeID = ObjectTypeID,
                    @ObjectID = @SiteID,
                    @ActorID = ActorID,
                    @PermissionTypeID = PermissionTypeID,
                    @RowStatus = RowStatus,
                    @RowAction = RowAction
                FROM @ObjectAccessRecordsTemp;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_ADMIN_OBJECT_ACCESS_SET @ObjectAccessID,
                                                         @ObjectOperationTypeID,
                                                         @ObjectTypeID,
                                                         @ObjectID,
                                                         @ActorID,
                                                         @SiteID,
                                                         @PermissionTypeID,
                                                         @RowStatus,
                                                         @UserName;

                DELETE FROM @ObjectAccessRecordsTemp
                WHERE ObjectAccessID = @RowID;
            END;
        END

        IF @@TRANCOUNT > 0
            COMMIT;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @SiteID KeyId,
               'SiteID' KeyIdName,
               @CustomizationPackageID AdditionalKeyId,
               'CustomizationPackageID' AdditionalKeyName;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;
    END CATCH
END

