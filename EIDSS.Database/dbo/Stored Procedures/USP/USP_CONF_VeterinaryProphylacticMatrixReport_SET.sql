-- ================================================================================================
-- Name: USP_CONF_VeterinaryProphylacticMatrixReport_SET
--
-- Description: Saves Entries For Veterinary Aggregate Case Matrix Report.
-- 
-- Author: Lamont Mitchell
--
-- Revision History:
-- Name                         Date       Change Detail
-- ---------------------------- ---------- -------------------------------------------------------
-- Lamont Mitchell              03/04/2019 Initial Created
-- Stephen Long                 07/15/2022 Added site alert and renamed sproc to standard SET.
-- Leo Tracchia                 10/06/2022 Fix for bug 5202 ADM 16 - Vet Prophylactic Measure Matrix #456 
-- Leo Tracchia					10/24/2022 Removed select from @Disease for IdfVersion, replaced with @idfVersion
-- Ann Xiong					02/23/2023 Implemented Data Audit
-- Ann Xiong					03/08/2023 Added check for @idfDataAuditEvent IS NULL to only create @idfDataAuditEvent once
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_VeterinaryProphylacticMatrixReport_SET]
    @idfAggrProphylacticActionMTX BIGINT NULL,
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
        IdfAggrProphylacticActionMTX BIGINT, 
        IdfsProphilacticAction BIGINT,
        IdfsSpeciesType BIGINT,
        IdfsDiagnosis BIGINT
    );

	--Data Audit--
	declare @idfsDataAuditEventType bigint = NULL;
	declare @idfsObjectType bigint = 10017003;                         -- Matrix for Aggregate Reports
	declare @idfObject bigint = @idfAggrProphylacticActionMTX;
	declare @idfObjectTable_tlbAggrProphylacticActionMTX bigint = 75440000000;
	declare @idfDataAuditEvent bigint= NULL;

	DECLARE @tlbAggrProphylacticActionMTX_BeforeEdit TABLE
	(
        		AggrProphylacticActionMTXID BIGINT,
        		IntNumRow INT
	);
	DECLARE @tlbAggrProphylacticActionMTX_AfterEdit TABLE
	(
        		AggrProphylacticActionMTXID BIGINT,
        		IntNumRow INT
	);

	--Data Audit--

    SET NOCOUNT ON;

    BEGIN TRY
        SET @JsonString = @inJsonString;
        IF EXISTS
        (
            SELECT *
            FROM dbo.tlbAggrProphylacticActionMTX
            WHERE idfVersion = @idfVersion
        )
        BEGIN
            UPDATE dbo.tlbAggrProphylacticActionMTX
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfVersion = @idfVersion;
        END

        INSERT INTO @Disease
        (
            IntNumRow,
            --IdfVersion,
            IdfAggrProphylacticActionMTX,
            IdfsProphilacticAction,
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
                IdfAggrProphylacticActionMTX BIGINT, 
                IdfsProphilacticAction BIGINT,
                IdfsSpeciesType BIGINT,
                IdfsDiagnosis BIGINT
            );
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
                FROM dbo.tlbAggrProphylacticActionMTX
                WHERE idfVersion = @idfVersion
                      AND idfsDiagnosis =
                      (
                          SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                      )
                      AND idfsSpeciesType =
                      (
                          SELECT IdfsSpeciesType FROM @Disease WHERE IntNumRow = @_int
                      )
                      AND idfsProphilacticAction =
                      (
                          SELECT IdfsProphilacticAction FROM @Disease WHERE IntNumRow = @_int
                      )
            )
            BEGIN
                -- Data audit
                DECLARE @aggCaseMtxId BIGINT;

                SET @aggCaseMtxId =
                (
                    SELECT	idfAggrProphylacticActionMTX
                 	  FROM	dbo.tlbAggrProphylacticActionMTX
                	  WHERE idfVersion = @idfVersion
                      		AND idfsDiagnosis =
                      		(
                          		SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                      		)
                      		AND idfsSpeciesType =
                      		(
                          		SELECT IdfsSpeciesType FROM @Disease WHERE IntNumRow = @_int
                      		)
                      		AND idfsProphilacticAction =
                      		(
                          		SELECT IdfsProphilacticAction FROM @Disease WHERE IntNumRow = @_int
                      		)
                );

                INSERT INTO @tlbAggrProphylacticActionMTX_BeforeEdit
                (
                        AggrProphylacticActionMTXID,
                        IntNumRow
                 )
                 SELECT 	idfAggrProphylacticActionMTX,
                    		intNumRow
                 FROM		dbo.tlbAggrProphylacticActionMTX
                 WHERE		idfAggrProphylacticActionMTX = @aggCaseMtxId;

                -- End data audit

                UPDATE dbo.tlbAggrProphylacticActionMTX
                SET intRowStatus = 0,
                    intNumRow = @_int,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsDiagnosis =
                (
                    SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                )
                      AND idfVersion = @idfVersion
                      --(
                      --    SELECT IdfVersion FROM @Disease WHERE IntNumRow = @_int
                      --)
                      AND idfsSpeciesType =
                      (
                          SELECT IdfsSpeciesType FROM @Disease WHERE IntNumRow = @_int
                      )
                      AND idfsProphilacticAction =
                      (
                          SELECT IdfsProphilacticAction FROM @Disease WHERE IntNumRow = @_int
                      );

                -- Data audit
                INSERT INTO @tlbAggrProphylacticActionMTX_AfterEdit
                (
                        AggrProphylacticActionMTXID,
                        IntNumRow
                 )
                 SELECT 	idfAggrProphylacticActionMTX,
                    		intNumRow
                 FROM		dbo.tlbAggrProphylacticActionMTX
                 WHERE		idfAggrProphylacticActionMTX = @aggCaseMtxId;

        	    IF @idfDataAuditEvent IS NULL
        	    BEGIN 
					--  tauDataAuditEvent  Event Type- Edit 
					set @idfsDataAuditEventType =10016003;
					-- insert record into tauDataAuditEvent - 
					EXEC USSP_GBL_DataAuditEvent_GET @UserId, @SiteId, @idfsDataAuditEventType,@idfsObjectType,@aggCaseMtxId, @idfObjectTable_tlbAggrProphylacticActionMTX, @idfDataAuditEvent OUTPUT
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
                           @idfObjectTable_tlbAggrProphylacticActionMTX,
                           12666680000000,
                           a.AggrProphylacticActionMTXID,
                           NULL,
                           b.IntNumRow,
                           a.IntNumRow
                FROM @tlbAggrProphylacticActionMTX_AfterEdit AS a
                        FULL JOIN @tlbAggrProphylacticActionMTX_BeforeEdit AS b
                            ON a.AggrProphylacticActionMTXID = b.AggrProphylacticActionMTXID
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
                    EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAggrProphylacticActionMTX',
                                                   @idfAggrProphylacticActionMTX OUTPUT;

                    INSERT INTO dbo.tlbAggrProphylacticActionMTX
                    (
                        idfAggrProphylacticActionMTX,
                        idfVersion,
                        idfsDiagnosis,
                        idfsSpeciesType,
                        idfsProphilacticAction,
                        intNumRow,
                        intRowStatus,
                        AuditCreateDTM,
                        AuditCreateUser
                    )
                    SELECT @idfAggrProphylacticActionMTX,
                           --IdfVersion,
						   @idfVersion,
                           IdfsDiagnosis,
                           IdfsSpeciesType,
                           IdfsProphilacticAction,
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
						EXEC USSP_GBL_DataAuditEvent_GET @UserId, @SiteId, @idfsDataAuditEventType,@idfsObjectType,@idfAggrProphylacticActionMTX, @idfObjectTable_tlbAggrProphylacticActionMTX, @idfDataAuditEvent OUTPUT
        			END

					INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tlbAggrProphylacticActionMTX, @idfAggrProphylacticActionMTX)
					--Data Audit--
                END
            END

            SET @_int = @_int + 1;
        END

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfAggrProphylacticActionMTX,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfAggrProphylacticActionMTX AS 'idfAggrProphylacticActionMTX'
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
