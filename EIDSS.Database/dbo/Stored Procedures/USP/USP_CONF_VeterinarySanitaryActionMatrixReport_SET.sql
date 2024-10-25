-- ================================================================================================
-- Name: USP_CONF_VeterinarySanitaryActionMatrixReport_SET
--
-- Description: Saves entries for veterinary aggregate action sanitary actions matrix.
-- 
-- Author: Lamont Mitchell
--
-- Revision History:
-- Name                         Date       Change Detail
-- ---------------------------- ---------- -------------------------------------------------------
-- Lamont Mitchell              03/04/2019 Initial Created
-- Stephen Long                 07/15/2022 Added site alert and renamed sproc to standard SET.
-- Leo Tracchia					10/24/2022 Removed select from @Disease for IdfVersion, replaced with @idfVersion
-- Ann Xiong					02/24/2023 Implemented Data Audit
-- Ann Xiong					03/08/2023 Added check for @idfDataAuditEvent IS NULL to only create @idfDataAuditEvent once
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_VeterinarySanitaryActionMatrixReport_SET]
    @idfAggrSanitaryActionMTX BIGINT NULL,
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
    DECLARE @Disease TABLE
    (
        IntNumRow INT,
        --IdfVersion BIGINT,
        IdfAggrSanitaryActionMTX BIGINT,
        IdfsSanitaryAction BIGINT
    );

	--Data Audit--
	declare @idfsDataAuditEventType bigint = NULL;
	declare @idfsObjectType bigint = 10017003;                         -- Matrix for Aggregate Reports
	declare @idfObject bigint = @idfAggrSanitaryActionMTX;
	declare @idfObjectTable_tlbAggrSanitaryActionMTX bigint = 12666690000000;
	declare @idfDataAuditEvent bigint= NULL;

	DECLARE @tlbAggrSanitaryActionMTX_BeforeEdit TABLE
	(
        		AggrSanitaryActionMTXID BIGINT,
        		IntNumRow INT
	);
	DECLARE @tlbAggrSanitaryActionMTX_AfterEdit TABLE
	(
        		AggrSanitaryActionMTXID BIGINT,
        		IntNumRow INT
	);

	--Data Audit--

    SET NOCOUNT ON;

    BEGIN TRY
        SET @JsonString = @inJsonString;
        IF EXISTS
        (
            SELECT *
            FROM dbo.tlbAggrSanitaryActionMTX
            WHERE idfVersion = @idfVersion
        )
        BEGIN
            UPDATE dbo.tlbAggrSanitaryActionMTX
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfVersion = @idfVersion;
        END

        INSERT INTO @Disease
        (
            IntNumRow,
            --IdfVersion,
            IdfAggrSanitaryActionMTX,
            IdfsSanitaryAction
        )
        SELECT *
        FROM
            OPENJSON(@JsonString)
            WITH
            (
                IntNumRow INT,
                --IdfVersion BIGINT,
                IdfAggrSanitaryActionMTX BIGINT,
                IdfsSanitaryAction BIGINT
            );
        DECLARE @rowCount INT = 0;
        SET @rowCount =
        (
            SELECT MAX(IntNumRow) FROM @Disease
        );
        DECLARE @_int INT = 0;
        WHILE @_int <= @rowCount
        BEGIN

            IF EXISTS
            (
                SELECT *
                FROM dbo.tlbAggrSanitaryActionMTX
                WHERE idfVersion = @idfVersion
                      AND idfsSanitaryAction =
                      (
                          SELECT IdfsSanitaryAction FROM @Disease WHERE IntNumRow = @_int
                      )
            )
            BEGIN
                DECLARE @aggCaseMtxId BIGINT;
                SET @aggCaseMtxId =
                (
                    SELECT idfAggrSanitaryActionMTX
                    FROM dbo.tlbAggrSanitaryActionMTX
                    WHERE idfVersion = @idfVersion
                          AND idfsSanitaryAction =
                          (
                              SELECT IdfsSanitaryAction FROM @Disease WHERE IntNumRow = @_int
                          )
                );

                -- Data audit
                INSERT INTO @tlbAggrSanitaryActionMTX_BeforeEdit
                (
                        AggrSanitaryActionMTXID,
                        IntNumRow
                 )
                 SELECT 	idfAggrSanitaryActionMTX,
                    		intNumRow
                 FROM		dbo.tlbAggrSanitaryActionMTX
                 WHERE		idfAggrSanitaryActionMTX = @aggCaseMtxId;

                -- End data audit

                UPDATE dbo.tlbAggrSanitaryActionMTX
                SET intRowStatus = 0,
                    intNumRow = @_int,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsSanitaryAction =
                (
                    SELECT IdfsSanitaryAction FROM @Disease WHERE IntNumRow = @_int
                )
                      AND idfVersion = @idfVersion
                      --(
                      --    SELECT IdfVersion FROM @Disease WHERE IntNumRow = @_int
                      --)
                      AND idfAggrSanitaryActionMTX = @aggCaseMtxId;

                -- Data audit
                INSERT INTO @tlbAggrSanitaryActionMTX_AfterEdit
                (
                        AggrSanitaryActionMTXID,
                        IntNumRow
                 )
                 SELECT 	idfAggrSanitaryActionMTX,
                    		intNumRow
                 FROM		dbo.tlbAggrSanitaryActionMTX
                 WHERE		idfAggrSanitaryActionMTX = @aggCaseMtxId;

        	    IF @idfDataAuditEvent IS NULL
        	    BEGIN 
					--  tauDataAuditEvent  Event Type- Edit 
					set @idfsDataAuditEventType =10016003;
					-- insert record into tauDataAuditEvent - 
					EXEC USSP_GBL_DataAuditEvent_GET @UserId, @SiteId, @idfsDataAuditEventType,@idfsObjectType,@aggCaseMtxId, @idfObjectTable_tlbAggrSanitaryActionMTX, @idfDataAuditEvent OUTPUT
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
                           @idfObjectTable_tlbAggrSanitaryActionMTX,
                           12666730000000,
                           a.AggrSanitaryActionMTXID,
                           NULL,
                           b.IntNumRow,
                           a.IntNumRow
                FROM @tlbAggrSanitaryActionMTX_AfterEdit AS a
                        FULL JOIN @tlbAggrSanitaryActionMTX_BeforeEdit AS b
                            ON a.AggrSanitaryActionMTXID = b.AggrSanitaryActionMTXID
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
                    EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAggrSanitaryActionMTX',
                                                   @idfAggrSanitaryActionMTX OUTPUT;

                    INSERT INTO dbo.tlbAggrSanitaryActionMTX
                    (
                        idfAggrSanitaryActionMTX,
                        idfVersion,
                        idfsSanitaryAction,
                        intNumRow,
                        intRowStatus,
                        AuditCreateDTM,
                        AuditCreateUser
                    )
                    SELECT @idfAggrSanitaryActionMTX,
                           @idfVersion,
                           IdfsSanitaryAction,
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
						EXEC USSP_GBL_DataAuditEvent_GET @UserId, @SiteId, @idfsDataAuditEventType,@idfsObjectType,@idfAggrSanitaryActionMTX, @idfObjectTable_tlbAggrSanitaryActionMTX, @idfDataAuditEvent OUTPUT
        			END

					INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tlbAggrSanitaryActionMTX, @idfAggrSanitaryActionMTX)
					--Data Audit--
                END
            END

            SET @_int = @_int + 1;
        END

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfAggrSanitaryActionMTX,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfAggrSanitaryActionMTX AS 'idfAggrSanitaryActionMTX';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END

