-- ================================================================================================
-- Name: USP_CONF_VeterinaryAggregateCaseMatrixReport_SET
--
-- Description: Saves entries for veterinary aggregate case matrix report.
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
CREATE PROCEDURE [dbo].[USP_CONF_VeterinaryAggregateCaseMatrixReport_SET]
    @idfAggrVetCaseMTX BIGINT NULL,
    @idfVersion BIGINT NULL,
    @inJsonString VARCHAR(MAX) NULL,
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
    Declare @Disease Table
    (
        IntNumRow INT,
        IdfAggrVetCaseMTX BIGINT,
        --IdfVersion BIGINT,
        IdfsDiagnosis BIGINT,
        IdfsSpeciesType BIGINT
    );

	--Data Audit--
	declare @idfsDataAuditEventType bigint = NULL;
	declare @idfsObjectType bigint = 10017003;                         -- Matrix for Aggregate Reports
	declare @idfObject bigint = @idfAggrVetCaseMTX;
	declare @idfObjectTable_tlbAggrVetCaseMTX bigint = 75450000000;
	declare @idfDataAuditEvent bigint= NULL;

	DECLARE @tlbAggrVetCaseMTX_BeforeEdit TABLE
	(
        		AggrVetCaseMTXID BIGINT,
        		IntNumRow INT
	);
	DECLARE @tlbAggrVetCaseMTX_AfterEdit TABLE
	(
        		AggrVetCaseMTXID BIGINT,
        		IntNumRow INT
	);

	--Data Audit--

    SET NOCOUNT ON;

    BEGIN TRY
        SET @JsonString = @inJsonString;
        IF EXISTS
        (
            SELECT *
            FROM dbo.tlbAggrVetCaseMTX
            WHERE idfVersion = @idfVersion
        )
        BEGIN
            UPDATE dbo.tlbAggrVetCaseMTX
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfVersion = @idfVersion;

        END

        INSERT INTO @Disease
        (
            IdfAggrVetCaseMTX,
            --IdfVersion,
            IdfsDiagnosis,
            IdfsSpeciesType,
            IntNumRow
        )
        SELECT *
        FROM
            OPENJSON(@JsonString)
            WITH
            (
                IdfAggrVetCaseMTX BIGINT,
                --IdfVersion BIGINT,
                IdfsDiagnosis BIGINT,
                IdfsSpeciesType BIGINT,
                IntNumRow INT
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
                FROM dbo.tlbAggrVetCaseMTX
                WHERE idfVersion = @idfVersion
					--(
					--	SELECT IdfVersion FROM @Disease WHERE IntNumRow = @_int
					--)
                      AND idfsDiagnosis =
                      (
                          SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                      )
                      AND idfsSpeciesType =
                      (
                          SELECT IdfsSpeciesType FROM @Disease WHERE IntNumRow = @_int
                      )
            )
            BEGIN
                DECLARE @aggVeterinaryCaseMtxId BIGINT;
                SET @aggVeterinaryCaseMtxId =
                (
                    SELECT idfAggrVetCaseMTX
                    FROM dbo.tlbAggrVetCaseMTX
                    WHERE idfVersion = @idfVersion
                          AND idfsDiagnosis =
                          (
                              SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                          )
                          AND idfsSpeciesType =
                          (
                              SELECT IdfsSpeciesType FROM @Disease WHERE IntNumRow = @_int
                          )
                )

                -- Data audit
                INSERT INTO @tlbAggrVetCaseMTX_BeforeEdit
                (
                        AggrVetCaseMTXID,
                        IntNumRow
                 )
                 SELECT 	idfAggrVetCaseMTX,
                    		intNumRow
                 FROM		dbo.tlbAggrVetCaseMTX
                 WHERE		idfVersion = @idfVersion
                          AND idfsDiagnosis =
                          (
                              SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                          )
                      AND idfsSpeciesType =
                      (
                          SELECT IdfsSpeciesType FROM @Disease WHERE IntNumRow = @_int
                      );

                -- End data audit

                UPDATE dbo.tlbAggrVetCaseMTX
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
                      );

                -- Data audit
                INSERT INTO @tlbAggrVetCaseMTX_AfterEdit
                (
                        AggrVetCaseMTXID,
                        IntNumRow
                 )
                 SELECT 	idfAggrVetCaseMTX,
                    		intNumRow
                 FROM		dbo.tlbAggrVetCaseMTX
                 WHERE		idfVersion = @idfVersion
                          AND idfsDiagnosis =
                          (
                              SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                          )
						AND idfsSpeciesType =
						(
							SELECT IdfsSpeciesType FROM @Disease WHERE IntNumRow = @_int
						);

        	        IF @idfDataAuditEvent IS NULL
        	        BEGIN 
						--  tauDataAuditEvent  Event Type- Edit 
			    		set @idfsDataAuditEventType =10016003;
			    		-- insert record into tauDataAuditEvent - 
			    		EXEC USSP_GBL_DataAuditEvent_GET @UserId, @SiteId, @idfsDataAuditEventType,@idfsObjectType,@aggVeterinaryCaseMtxId, @idfObjectTable_tlbAggrVetCaseMTX, @idfDataAuditEvent OUTPUT
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
                           @idfObjectTable_tlbAggrVetCaseMTX,
                           12666750000000,
                           a.AggrVetCaseMTXID,
                           NULL,
                           b.IntNumRow,
                           a.IntNumRow
                FROM @tlbAggrVetCaseMTX_AfterEdit AS a
                        FULL JOIN @tlbAggrVetCaseMTX_BeforeEdit AS b
                            ON a.AggrVetCaseMTXID = b.AggrVetCaseMTXID
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
                    EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAggrVetCaseMTX',
                                                   @idfAggrVetCaseMTX OUTPUT;
                    INSERT INTO dbo.tlbAggrVetCaseMTX
                    (
                        idfAggrVetCaseMTX,
                        idfVersion,
                        idfsDiagnosis,
                        idfsSpeciesType,
                        intNumRow,
                        intRowStatus,
                        AuditCreateDTM,
                        AuditCreateUser
                    )
                    SELECT @idfAggrVetCaseMTX,
                           @IdfVersion,
                           IdfsDiagnosis,
                           IdfsSpeciesType,
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
						EXEC USSP_GBL_DataAuditEvent_GET @UserId, @SiteId, @idfsDataAuditEventType,@idfsObjectType,@idfAggrVetCaseMTX, @idfObjectTable_tlbAggrVetCaseMTX, @idfDataAuditEvent OUTPUT
        	        END

					INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tlbAggrVetCaseMTX, @idfAggrVetCaseMTX)
					--Data Audit--
                END
            END

            SET @_int = @_int + 1;
        END

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfAggrVetCaseMTX,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfAggrVetCaseMTX AS 'idfAggrVetCaseMTX';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
