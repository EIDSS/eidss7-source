-- ================================================================================================
-- Name: USP_OMM_Session_Set
-- 
-- Description: Insert/Update for Campaign Monitoring Session
--          
-- Author: Doug Albanese
-- Revision History:
-- Name	                     Date       Change Detail
-- ------------------------- ---------- ----------------------------------------------------------
-- Doug Albanese             10/08/2020 Adding Auditing information
-- Doug Albanese             09/02/2021 Refactored for cleaner model to contain only relavent 
--                                      parameters
-- Doug Albanese             09/08/2021 Replaced USP_GBL_ADDRESS_SET with USSP_GBL_ADDRESS_SET
-- Doug Albanese             09/10/2021 Removed SQL statements left in for debugging, supressed 
--                                      the use of USSP_GBL_ADDRESS_SET...which was recently 
--                                      swapped out
-- Mark Wilson	             09/13/2021 updated to use USP_GBL_ADDRESS_SET, corrected addl fields
-- Doug Albanese             09/14/2021 Corrected the parameters passed to USP_GBL_ADDRESS_SET
-- Mark Wilson               10/06/2021 updated to add Elevation to USP_GBL_ADDRESS_SET
-- Doug Albanese             11/02/2021 Remove condition to allow NULL storage of species 
--                                      parameters
-- Stephen Long              07/12/2022 Added events parameter for site alerts and removed language 
--                                      ID.
-- Mike Kornegay			 09/14/2022 Added null to note field for input to USP_ADMIN_EVENT_SET.
-- Doug Albanese			 03/08/2023	Implemented Data Auditing
-- Doug Albanese			 03/15/2023 Change over from idfGeoLocation to idfsLocation
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_Session_Set]
(
    @idfOutbreak BIGINT = NULL,
    @idfsDiagnosisOrDiagnosisGroup BIGINT = NULL,
    @idfsOutbreakStatus BIGINT = NULL,
    @OutbreakTypeId BIGINT = NULL,
    @idfsLocation BIGINT = NULL,
    @datStartDate DATETIME = NULL,
    @datCloseDate DATETIME = NULL,
    @strOutbreakID NVARCHAR(200) = NULL,
    @strDescription NVARCHAR(2000) = NULL,
    @intRowStatus INT = 0,
    @datModificationForArchiveDate DATETIME = NULL,
    @idfPrimaryCaseOrSession BIGINT = NULL,
    @idfsSite BIGINT,
    @outbreakParameters NVARCHAR(MAX) = NULL,
    @User NVARCHAR(200) = '',
    @Events NVARCHAR(MAX) = NULL
)
AS
BEGIN
    DECLARE @returnCode INT = 0,
            @returnMsg NVARCHAR(MAX) = 'SUCCESS',
            @EventId BIGINT,
            @EventTypeId BIGINT = NULL,
            @EventSiteId BIGINT = NULL,
            @EventObjectId BIGINT = NULL,
            @EventUserId BIGINT = NULL,
            @EventDiseaseId BIGINT = NULL,
            @EventLocationId BIGINT = NULL,
            @EventInformationString NVARCHAR(MAX) = NULL,
            @EventLoginSiteId BIGINT = NULL,

			-- Data audit
		   @AuditUserID BIGINT = NULL,
		   @AuditSiteID BIGINT = NULL,
		   @DataAuditEventID BIGINT = NULL,
		   @DataAuditEventTypeID BIGINT = NULL,
		   @ObjectTypeID BIGINT = 10017081,   
		   @ObjectID BIGINT = @idfOutbreak,
		   @ObjectTableID BIGINT = 75660000000; 

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

	DECLARE @OutbreakSessionBeforeEdit TABLE (
	  idfGeoLocation				   BIGINT,
	  idfOutbreak					   BIGINT,
	  idfsOutbreakStatus			   BIGINT,
	  datStartDate					   DATETIME,
	  datFinishDate					   DATETIME,
	  strOutbreakID					   NVARCHAR(200),
	  strDescription				   NVARCHAR(2000),
	  idfsDiagnosisOrDiagnosisGroup	   BIGINT,
	  idfPrimaryCaseOrSession		   BIGINT
	)

   DECLARE @OutbreakSessionAfterEdit TABLE (
	  idfGeoLocation				   BIGINT,
	  idfOutbreak					   BIGINT,
	  idfsOutbreakStatus			   BIGINT,
	  datStartDate					   DATETIME,
	  datFinishDate					   DATETIME,
	  strOutbreakID					   NVARCHAR(200),
	  strDescription				   NVARCHAR(2000),
	  idfsDiagnosisOrDiagnosisGroup	   BIGINT,
	  idfPrimaryCaseOrSession		   BIGINT
	)

    IF @idfsSite IS NULL
    BEGIN
        SELECT @returnCode as ReturnCode,
               @returnMsg as ReturnMessage,
               @idfOutbreak as idfOutbreak,
               @strOutbreakID as strOutbreakID;
    END
    ELSE
    BEGIN
        --DECLARE @outbreakLocation BIGINT = NULL;
        DECLARE @OutbreakSpeciesParameterUID BIGINT;
        DECLARE @OutbreakSpeciesTypeID BIGINT;
        DECLARE @CaseMonitoringDuration INT;
        DECLARE @CaseMonitoringFrequency INT;
        DECLARE @ContactTracingDuration INT;
        DECLARE @ContactTracingFrequency INT;

        DECLARE @ParameterSpeciesTypes TABLE (OutbreakSpeciesTypeID BIGINT);

        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );

		 -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@User) userInfo;
        -- End data audit


		 IF @idfOutbreak IS NULL
            BEGIN
			   --IF ISNULL(@idfOutbreak, -1) < 0
                --BEGIN
                  INSERT INTO @SuppressSelect
                  EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbOutbreak',
                                                @idfsKey = @idfOutbreak OUTPUT;

                  INSERT INTO @SuppressSelect
                  EXEC dbo.USP_GBL_NextNumber_GET @ObjectName = 'Outbreak Session',
                                                   @NextNumberValue = @strOutbreakID OUTPUT,
                                                   @InstallationSite = NULL;
                --END

                -- Data audit (Create)
                SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

				 INSERT INTO @SuppressSelect            
				 EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,                                                      
					@AuditSiteID,                                                      
					@DataAuditEventTypeID,                                                      
					@ObjectTypeID,                                                      
					@idfOutbreak,                                                      
					@ObjectTableID,                                                      
					@strOutbreakID,                                                       
					@DataAuditEventID OUTPUT;
            END
         ELSE
            BEGIN
			   SELECT
				  @strOutbreakID = strOutbreakID
			   FROM
				  tlbOutbreak
			   WHERE
				  idfOutbreak = @idfOutbreak

			   IF @intRowStatus = 1
				  BEGIN
					 -- Data audit (Delete)
					  SET @DataAuditEventTypeID = 10016002; -- Data audit edit event type
					   INSERT INTO @SuppressSelect            
					   EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,                                                      
						  @AuditSiteID,                                                      
						  @DataAuditEventTypeID,                                                      
						  @ObjectTypeID,                                                      
						  @idfOutbreak,                                                      
						  @ObjectTableID,                                                      
						  @strOutbreakID,                                                       
						  @DataAuditEventID OUTPUT;
				  END
			   ELSE
				  BEGIN
					  -- Data audit (Edit)
					  SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type

					   INSERT INTO @SuppressSelect            
					   EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,                                                      
						  @AuditSiteID,                                                      
						  @DataAuditEventTypeID,                                                      
						  @ObjectTypeID,                                                      
						  @idfOutbreak,                                                      
						  @ObjectTableID,                                                      
						  @strOutbreakID,                                                       
						  @DataAuditEventID OUTPUT;
				  END
            END
         -- End data audit

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

        BEGIN TRY
            SET @returnCode = 0;
            SET @returnMsg = 'SUCCESS';

            DECLARE @convertedParameters TABLE
            (
                OutbreakSpeciesParameterUID BIGINT,
                OutbreakSpeciesTypeID BIGINT NULL,
                CaseMonitoringDuration INT NULL,
                CaseMonitoringFrequency INT NULL,
                ContactTracingDuration INT NULL,
                ContactTracingFrequency INT NULL,
                intRowStatus INT
            );

            INSERT INTO @convertedParameters
            SELECT *
            FROM
                OPENJSON(@outbreakParameters)
                WITH
                (
                    OutbreakSpeciesParameterUID BIGINT,
                    OutbreakSpeciesTypeID BIGINT,
                    CaseMonitoringDuration INT,
                    CaseMonitoringFrequency INT,
                    ContactTracingDuration INT,
                    ContactTracingFrequency INT,
                    intRowStatus INT
                );

            IF EXISTS (SELECT * FROM dbo.tlbOutbreak WHERE idfOutbreak = @idfOutbreak)
            BEGIN
			   --Data Audit (Gather previous record items before edit)
			   INSERT INTO @OutbreakSessionBeforeEdit (
			   	  idfGeoLocation,
				  idfOutbreak,
				  idfsOutbreakStatus,
				  datStartDate,
				  datFinishDate,
				  strOutbreakID,
				  strDescription,
				  idfsDiagnosisOrDiagnosisGroup,
				  idfPrimaryCaseOrSession   
			   )
			   SELECT
				  idfGeoLocation,
				  idfOutbreak,
				  idfsOutbreakStatus,
				  datStartDate,
				  datFinishDate,
				  strOutbreakID,
				  strDescription,
				  idfsDiagnosisOrDiagnosisGroup,
				  idfPrimaryCaseOrSession  
			   FROM
				  tlbOutbreak
			   WHERE
				  idfOutbreak = @idfOutbreak
			   --Data Autdit End

                UPDATE dbo.tlbOutbreak
                SET idfsDiagnosisOrDiagnosisGroup = @idfsDiagnosisOrDiagnosisGroup,
                    idfsOutbreakStatus = @idfsOutbreakStatus,
                    OutbreakTypeID = @OutbreakTypeID,
                    idfsLocation = @idfsLocation,
                    datStartDate = @datStartDate,
                    datFinishDate = @datCloseDate,
                    strDescription = @strDescription,
                    intRowStatus = COALESCE(@intRowStatus, 0),
                    datModificationForArchiveDate = @datModificationForArchiveDate,
                    idfPrimaryCaseOrSession = @idfPrimaryCaseOrSession,
                    idfsSite = @idfsSite,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = ISNULL(@User, SUSER_NAME())
                WHERE idfOutbreak = @idfOutbreak;

			   --Data Audit (Gather previous record items before edit)
			   INSERT INTO @OutbreakSessionAfterEdit (
			   	  idfGeoLocation,
				  idfOutbreak,
				  idfsOutbreakStatus,
				  datStartDate,
				  datFinishDate,
				  strOutbreakID,
				  strDescription,
				  idfsDiagnosisOrDiagnosisGroup,
				  idfPrimaryCaseOrSession   
			   )
			   SELECT
				  idfGeoLocation,
				  idfOutbreak,
				  idfsOutbreakStatus,
				  datStartDate,
				  datFinishDate,
				  strOutbreakID,
				  strDescription,
				  idfsDiagnosisOrDiagnosisGroup,
				  idfPrimaryCaseOrSession  
			   FROM
				  tlbOutbreak
			   WHERE
				  idfOutbreak = @idfOutbreak
			   
			   INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       80160000000, --idfGeoLocation
                       a.idfOutbreak,
                       NULL,
                       b.idfGeoLocation,
                       a.idfGeoLocation,
                       @User,
                       @idfOutbreak
                FROM @OutbreakSessionAfterEdit AS a
                    FULL JOIN @OutbreakSessionBeforeEdit AS b
                        ON a.idfOutbreak = b.idfOutbreak
                WHERE (a.idfGeoLocation <> b.idfGeoLocation)
                      OR (
                             a.idfGeoLocation IS NOT NULL
                             AND b.idfGeoLocation IS NULL
                         )
                      OR (
                             a.idfGeoLocation IS NULL
                             AND b.idfGeoLocation IS NOT NULL
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
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       80190000000, --idfsOutbreakStatus
                       a.idfOutbreak,
                       NULL,
                       b.idfsOutbreakStatus,
                       a.idfsOutbreakStatus,
                       @User,
                       @idfOutbreak
                FROM @OutbreakSessionAfterEdit AS a
                    FULL JOIN @OutbreakSessionBeforeEdit AS b
                        ON a.idfOutbreak = b.idfOutbreak
                WHERE (a.idfsOutbreakStatus <> b.idfsOutbreakStatus)
                      OR (
                             a.idfsOutbreakStatus IS NOT NULL
                             AND b.idfsOutbreakStatus IS NULL
                         )
                      OR (
                             a.idfsOutbreakStatus IS NULL
                             AND b.idfsOutbreakStatus IS NOT NULL
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
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       746510000000, --datStartDate
                       a.idfOutbreak,
                       NULL,
                       b.datStartDate,
                       a.datStartDate,
                       @User,
                       @idfOutbreak
                FROM @OutbreakSessionAfterEdit AS a
                    FULL JOIN @OutbreakSessionBeforeEdit AS b
                        ON a.idfOutbreak = b.idfOutbreak
                WHERE (a.datStartDate <> b.datStartDate)
                      OR (
                             a.datStartDate IS NOT NULL
                             AND b.datStartDate IS NULL
                         )
                      OR (
                             a.datStartDate IS NULL
                             AND b.datStartDate IS NOT NULL
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
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       746520000000, --datFinishDate
                       a.idfOutbreak,
                       NULL,
                       b.datFinishDate,
                       a.datFinishDate,
                       @User,
                       @idfOutbreak
                FROM @OutbreakSessionAfterEdit AS a
                    FULL JOIN @OutbreakSessionBeforeEdit AS b
                        ON a.idfOutbreak = b.idfOutbreak
                WHERE (a.datFinishDate <> b.datFinishDate)
                      OR (
                             a.datFinishDate IS NOT NULL
                             AND b.datFinishDate IS NULL
                         )
                      OR (
                             a.datFinishDate IS NULL
                             AND b.datFinishDate IS NOT NULL
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
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       746540000000, --strDescription
                       a.idfOutbreak,
                       NULL,
                       b.strDescription,
                       a.strDescription,
                       @User,
                       @idfOutbreak
                FROM @OutbreakSessionAfterEdit AS a
                    FULL JOIN @OutbreakSessionBeforeEdit AS b
                        ON a.idfOutbreak = b.idfOutbreak
                WHERE (a.strDescription <> b.strDescription)
                      OR (
                             a.strDescription IS NOT NULL
                             AND b.strDescription IS NULL
                         )
                      OR (
                             a.strDescription IS NULL
                             AND b.strDescription IS NOT NULL
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
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       12675310000000, --idfsDiagnosisOrDiagnosisGroup
                       a.idfOutbreak,
                       NULL,
                       b.idfsDiagnosisOrDiagnosisGroup,
                       a.idfsDiagnosisOrDiagnosisGroup,
                       @User,
                       @idfOutbreak
                FROM @OutbreakSessionAfterEdit AS a
                    FULL JOIN @OutbreakSessionBeforeEdit AS b
                        ON a.idfOutbreak = b.idfOutbreak
                WHERE (a.idfsDiagnosisOrDiagnosisGroup <> b.idfsDiagnosisOrDiagnosisGroup)
                      OR (
                             a.idfsDiagnosisOrDiagnosisGroup IS NOT NULL
                             AND b.idfsDiagnosisOrDiagnosisGroup IS NULL
                         )
                      OR (
                             a.idfsDiagnosisOrDiagnosisGroup IS NULL
                             AND b.idfsDiagnosisOrDiagnosisGroup IS NOT NULL
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
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       12675370000000, --idfPrimaryCaseOrSession
                       a.idfOutbreak,
                       NULL,
                       b.idfPrimaryCaseOrSession,
                       a.idfPrimaryCaseOrSession,
                       @User,
                       @idfOutbreak
                FROM @OutbreakSessionAfterEdit AS a
                    FULL JOIN @OutbreakSessionBeforeEdit AS b
                        ON a.idfOutbreak = b.idfOutbreak
                WHERE (a.idfPrimaryCaseOrSession <> b.idfPrimaryCaseOrSession)
                      OR (
                             a.idfPrimaryCaseOrSession IS NOT NULL
                             AND b.idfPrimaryCaseOrSession IS NULL
                         )
                      OR (
                             a.idfPrimaryCaseOrSession IS NULL
                             AND b.idfPrimaryCaseOrSession IS NOT NULL
                         );
            -- End data audit
            END
            ELSE
            BEGIN
                INSERT INTO dbo.tlbOutbreak
                (
                    idfOutbreak,
                    idfsDiagnosisOrDiagnosisGroup,
                    idfsOutbreakStatus,
                    OutbreakTypeID,
                    idfsLocation,
                    datStartDate,
                    datFinishDate,
                    strOutbreakID,
                    strDescription,
                    intRowStatus,
                    rowguid,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    datModificationForArchiveDate,
                    idfPrimaryCaseOrSession,
                    idfsSite,
                    AuditCreateDTM,
                    AuditCreateUser,
                    AuditUpdateDTM,
                    AuditUpdateUser
                )
                VALUES
                (@idfOutbreak,
                 @idfsDiagnosisOrDiagnosisGroup,
                 @idfsOutbreakStatus,
                 @OutbreakTypeId,
                 @idfsLocation,
                 @datStartDate,
                 @datCloseDate,
                 @strOutbreakID,
                 @strDescription,
                 0  ,
                 NEWID(),
                 10519001,
                 '[{"idfOutbreak":' + CAST(@idfOutbreak AS NVARCHAR(300)) + '}]',
                 @datModificationForArchiveDate,
                 @idfPrimaryCaseOrSession,
                 @idfsSite,
                 GETDATE(),
                 ISNULL(@User, SUSER_NAME()),
                 GETDATE(),
                 ISNULL(@User, SUSER_NAME())
                );

                UPDATE @EventsTemp
                SET ObjectId = @idfOutbreak
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
                 @idfOutbreak,
                 10519001,
                 '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                 + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
                 @User,
                 @idfOutbreak
                );
			   -- End data audit


            END

            --Modifications to a Table Variable prevents Adding a column. Code was modified to produce this feild
            --Now we need to get a FK for each row and insert it one at a time so that the "Next Key" generation will be proper.
            WHILE
            (SELECT COUNT(OutbreakSpeciesTypeID) FROM @convertedParameters) > 0
            BEGIN
                --Identify the first Outbreak Species Type so that we can modify one row at a time.
                --Using table variable with species types only
                SELECT TOP 1
                    @OutbreakSpeciesParameterUID = OutbreakSpeciesParameterUID,
                    @OutbreakSpeciesTypeID = OutbreakSpeciesTypeID,
                    @CaseMonitoringDuration = CaseMonitoringDuration,
                    @CaseMonitoringFrequency = CaseMonitoringFrequency,
                    @ContactTracingDuration = ContactTracingDuration,
                    @ContactTracingFrequency = ContactTracingFrequency,
                    @intRowStatus = intRowStatus
                FROM @convertedParameters;

                IF EXISTS
                (
                    SELECT OutbreakSpeciesParameterUID
                    FROM dbo.OutbreakSpeciesParameter
                    WHERE OutbreakSpeciesParameterUID = @OutbreakSpeciesParameterUID
                )
                BEGIN
                    UPDATE dbo.OutbreakSpeciesParameter
                    SET CaseMonitoringDuration = @CaseMonitoringDuration,
                        CaseMonitoringFrequency = @CaseMonitoringFrequency,
                        ContactTracingDuration = @ContactTracingDuration,
                        ContactTracingFrequency = @ContactTracingFrequency,
                        intRowStatus = @intRowStatus,
                        AuditUpdateUser = ISNULL(@User, SUSER_NAME()),
                        AuditUpdateDTM = GETDATE()
                    WHERE OutbreakSpeciesParameterUID = @OutbreakSpeciesParameterUID;
                END
                ELSE
                BEGIN
                    --IF @CaseMonitoringDuration > 0 AND @ContactTracingDuration > 0
                    --	BEGIN
                    INSERT INTO @SuppressSelect
                    EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'OutbreakSpeciesParameter',
                                                   @idfsKey = @OutbreakSpeciesParameterUID OUTPUT;

                    --Update the JSON data that was converted over to a table variable
                    UPDATE @convertedParameters
                    SET OutbreakSpeciesParameterUID = @OutbreakSpeciesParameterUID
                    WHERE OutbreakSpeciesTypeID = @OutbreakSpeciesTypeID;

                    --Because USP_GBL_NEXTKEYID_GET will need to have the record in the destination table, we will have to insert it now,
                    --so that the next key will be generated.
                    INSERT INTO OutbreakSpeciesParameter
                    (
                        OutbreakSpeciesParameterUID,
                        idfOutbreak,
                        OutbreakSpeciesTypeID,
                        CaseMonitoringDuration,
                        CaseMonitoringFrequency,
                        ContactTracingDuration,
                        ContactTracingFrequency,
                        intRowStatus,
                        rowguid,
                        SourceSystemNameID,
                        SourceSystemKeyValue,
                        AuditCreateUser,
                        AuditCreateDTM
                    )
                    VALUES
                    (@OutbreakSpeciesParameterUID,
                     @idfOutbreak,
                     @OutbreakSpeciesTypeID,
                     @CaseMonitoringDuration,
                     @CaseMonitoringFrequency,
                     @ContactTracingDuration,
                     @ContactTracingFrequency,
                     0  ,
                     NEWID(),
                     10519001,
                     '[{"OutbreakSpeciesParameterUID":' + CAST(@OutbreakSpeciesParameterUID AS NVARCHAR(300)) + '}]',
                     ISNULL(@User, SUSER_NAME()),
                     GETDATE()
                    );
                --END
                END

                --Delete the Species type that we have been working with so that the loop will decrement and fall out when 0.
                SET ROWCOUNT 1;

                DELETE FROM @convertedParameters;

                SET ROWCOUNT 0;
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
												--null,
                                                @EventLoginSiteId,
                                                @EventLocationId,
                                                @User;

                DELETE FROM @EventsTemp
                WHERE EventId = @EventId;
            END;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT = 1
                ROLLBACK;

            SET @returnCode = ERROR_NUMBER();
            SET @returnMsg
                = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: '
                  + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
                  + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: '
                  + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();

            ; THROW;
        END CATCH

        SELECT @returnCode AS ReturnCode,
               @returnMsg AS ReturnMessage,
               @idfOutbreak AS idfOutbreak,
               @strOutbreakID AS strOutbreakID;
    END
END
