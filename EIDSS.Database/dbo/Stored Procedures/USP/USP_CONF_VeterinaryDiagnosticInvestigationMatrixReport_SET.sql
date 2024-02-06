-- ================================================================================================
-- Name: USP_CONF_VeterinaryDiagnosticInvestigationMatrixReport_SET
--
-- Description: Saves entries for veterinary aggregate action diagnostic investigation matrix.
-- 
-- Author: Lamont Mitchell
--
-- Revision History:
-- Name                         Date       Change Detail
-- ---------------------------- ---------- -------------------------------------------------------
-- Lamont Mitchell              03/04/2019 Initial Created
-- Stephen Long                 07/15/2022 Added site alert and renamed sproc to standard SET.
-- Leo Tracchia					10/24/2022 Removed select from @Disease for IdfVersion, replaced with @idfVersion
-- Ann Xiong					02/23/2023 Implemented Data Audit
-- Ann Xiong					03/08/2023 Added check for @idfDataAuditEvent IS NULL to only create @idfDataAuditEvent once
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_VeterinaryDiagnosticInvestigationMatrixReport_SET]
    @idfAggrDiagnosticActionMTX BIGINT NULL,
    @idfVersion BIGINT NULL,
    @inJsonString Varchar(Max) NULL,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
AS
BEGIN
    DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
            @ReturnCode BIGINT = 0,
            @idfsReferenceType BIGINT,
            @JsonString VARCHAR(MAX),
            @EventId BIGINT = -1,
            @EventSiteId BIGINT = @SiteId,
            @EventUserId BIGINT = @UserId,
            @EventDiseaseId BIGINT = NULL,
            @EventLocationId BIGINT = @LocationId,
            @EventInformationString NVARCHAR(MAX) = NULL,
            @EventLoginSiteId BIGINT = @SiteId;
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );
    DECLARE @Disease TABLE
    (
        IntNumRow INT,
        --IdfVersion BIGINT,
        IdfAggrDiagnosticActionMTX BIGINT,
        IdfsDiagnosticAction BIGINT,
        IdfsSpeciesType BIGINT,
        IdfsDiagnosis BIGINT
    );

		--Data Audit--
	declare @idfsDataAuditEventType bigint = NULL;
	declare @idfsObjectType bigint = 10017003;                         -- Matrix for Aggregate Reports
	declare @idfObject bigint = @idfAggrDiagnosticActionMTX;
	declare @idfObjectTable_tlbAggrDiagnosticActionMTX bigint = 75430000000;
	declare @idfDataAuditEvent bigint= NULL;

	DECLARE @tlbAggrDiagnosticActionMTX_BeforeEdit TABLE
	(
        		AggrDiagnosticActionMTXID BIGINT,
        		IntNumRow INT
	);
	DECLARE @tlbAggrDiagnosticActionMTX_AfterEdit TABLE
	(
        		AggrDiagnosticActionMTXID BIGINT,
        		IntNumRow INT
	);

	--Data Audit--

    SET NOCOUNT ON;

    BEGIN TRY
        SET @JsonString = @inJsonString;
        IF EXISTS
        (
            SELECT *
            FROM dbo.tlbAggrDiagnosticActionMTX
            WHERE idfVersion = @idfVersion
        )
        BEGIN
            UPDATE dbo.tlbAggrDiagnosticActionMTX
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfVersion = @idfVersion;
        END

        INSERT INTO @Disease
        (
            IntNumRow,
            --IdfVersion,
            IdfAggrDiagnosticActionMTX,
            IdfsDiagnosticAction,
            IdfsSpeciesType,
            IdfsDiagnosis
        )
        SELECT *
        FROM
            OPENJSON(@JsonString)
            WITH
            (
                IntNumRow INT,
                --IdfVersion BIGINT,
                IdfAggrDiagnosticActionMTX BIGINT,
                IdfsDiagnosticAction BIGINT,
                IdfsSpeciesType BIGINT,
                IdfsDiagnosis BIGINT
            )
        DECLARE @rowCount INT = 0;
        SET @rowCount =
        (
            SELECT MAX(IntNumRow) FROM @Disease
        );
        DECLARE @_int INT = 1;
        WHILE @_int <= @rowCount
        BEGIN
            IF EXISTS
            (
                SELECT *
                FROM dbo.tlbAggrDiagnosticActionMTX
                WHERE idfVersion = @idfVersion
                      AND idfsDiagnosis =
                      (
                          SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                      )
                      AND idfsSpeciesType =
                      (
                          SELECT IdfsSpeciesType FROM @Disease WHERE IntNumRow = @_int
                      )
                      AND idfsDiagnosticAction =
                      (
                          SELECT IdfsDiagnosticAction FROM @Disease WHERE IntNumRow = @_int
                      )
            )
            BEGIN
                DECLARE @aggCaseMtxId BIGINT;

                SET @aggCaseMtxId =
                (
                    SELECT idfAggrDiagnosticActionMTX
                    FROM dbo.tlbAggrDiagnosticActionMTX
                    WHERE idfVersion = @idfVersion
                          AND idfsDiagnosis =
                          (
                              SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                          )
                          AND idfsSpeciesType =
                          (
                              SELECT IdfsSpeciesType FROM @Disease WHERE IntNumRow = @_int
                          )
                          AND idfsDiagnosticAction =
                          (
                              SELECT IdfsDiagnosticAction FROM @Disease WHERE IntNumRow = @_int
                          )
                );

                -- Data audit
                INSERT INTO @tlbAggrDiagnosticActionMTX_BeforeEdit
                (
                        AggrDiagnosticActionMTXID,
                        IntNumRow
                 )
                 SELECT 	idfAggrDiagnosticActionMTX,
                    		intNumRow
                 FROM		dbo.tlbAggrDiagnosticActionMTX
                 WHERE		idfAggrDiagnosticActionMTX = @aggCaseMtxId;

                -- End data audit

                UPDATE dbo.tlbAggrDiagnosticActionMTX
                SET intRowStatus = 0,
                    intNumRow = @_int,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsDiagnosis =
                (
                    SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                )
                      AND idfsSpeciesType =
                      (
                          SELECT IdfsSpeciesType FROM @Disease WHERE IntNumRow = @_int
                      )
                      AND idfsDiagnosticAction =
                      (
                          SELECT IdfsDiagnosticAction FROM @Disease WHERE IntNumRow = @_int
                      )
                      AND idfVersion = @idfVersion
                      --(
                      --    SELECT IdfVersion FROM @Disease WHERE IntNumRow = @_int
                      --)
                      AND idfAggrDiagnosticActionMTX = @aggCaseMtxId;

                -- Data audit
                INSERT INTO @tlbAggrDiagnosticActionMTX_AfterEdit
                (
                        AggrDiagnosticActionMTXID,
                        IntNumRow
                 )
                 SELECT 	idfAggrDiagnosticActionMTX,
                    		intNumRow
                 FROM		dbo.tlbAggrDiagnosticActionMTX
                 WHERE		idfAggrDiagnosticActionMTX = @aggCaseMtxId;

        	    IF @idfDataAuditEvent IS NULL
        	    BEGIN 
					--  tauDataAuditEvent  Event Type- Edit 
					set @idfsDataAuditEventType =10016003;
					-- insert record into tauDataAuditEvent - 
					EXEC USSP_GBL_DataAuditEvent_GET @UserId, @SiteId, @idfsDataAuditEventType,@idfsObjectType,@aggCaseMtxId, @idfObjectTable_tlbAggrDiagnosticActionMTX, @idfDataAuditEvent OUTPUT
        	    END

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfColumn,
                        idfObject,
                        idfObjectDetail,
                        strOldValue,
                        strNewValue
                )
                SELECT	@idfDataAuditEvent,
                           @idfObjectTable_tlbAggrDiagnosticActionMTX,
                           12666610000000,
                           a.AggrDiagnosticActionMTXID,
                           NULL,
                           b.IntNumRow,
                           a.IntNumRow
                FROM @tlbAggrDiagnosticActionMTX_AfterEdit AS a
                        FULL JOIN @tlbAggrDiagnosticActionMTX_BeforeEdit AS b
                            ON a.AggrDiagnosticActionMTXID = b.AggrDiagnosticActionMTXID
                WHERE (a.IntNumRow <> b.IntNumRow)
                          OR (
                                 a.IntNumRow IS NOT NULL
                                 AND b.IntNumRow IS NULL
                             )
                          OR (
                                 a.IntNumRow IS NULL
                                 AND b.IntNumRow IS NOT NULL
                             );

                -- End data audit
            END
            ELSE
            BEGIN
                IF EXISTS (SELECT * FROM @Disease WHERE IntNumRow = @_int)
                BEGIN
                    INSERT INTO @SuppressSelect
                    EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAggrDiagnosticActionMTX',
                                                   @idfAggrDiagnosticActionMTX OUTPUT;
                    INSERT INTO dbo.tlbAggrDiagnosticActionMTX
                    (
                        idfAggrDiagnosticActionMTX,
                        idfVersion,
                        idfsDiagnosis,
                        idfsSpeciesType,
                        idfsDiagnosticAction,
                        intNumRow,
                        intRowStatus,
                        AuditCreateDTM,
                        AuditCreateUser
                    )
                    SELECT @idfAggrDiagnosticActionMTX,
                           @idfVersion,
                           IdfsDiagnosis,
                           IdfsSpeciesType,
                           IdfsDiagnosticAction,
                           IntNumRow,
                           0,
                           GETDATE(),
                           @AuditUserName
                    FROM @Disease
                    WHERE IntNumRow = @_int;

					--Data Audit--
        	        IF @idfDataAuditEvent IS NULL
        	        BEGIN 
						-- tauDataAuditEvent Event Type - Create 
						set @idfsDataAuditEventType =10016001;
						-- insert record into tauDataAuditEvent - 
						EXEC USSP_GBL_DataAuditEvent_GET @UserId, @SiteId, @idfsDataAuditEventType,@idfsObjectType,@idfAggrDiagnosticActionMTX, @idfObjectTable_tlbAggrDiagnosticActionMTX, @idfDataAuditEvent OUTPUT
        			END

					INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tlbAggrDiagnosticActionMTX, @idfAggrDiagnosticActionMTX)
					--Data Audit--
                END
            END

            SET @_int = @_int + 1;
        END

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfAggrDiagnosticActionMTX,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfAggrDiagnosticActionMTX AS 'idfAggrDiagnosticActionMTX'
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END

