-- ================================================================================================
-- Name: USP_CONF_HumanAggregateCaseMatrixReport_SET
--
-- Description: Saves Entries For Human Aggregate Case Matrix Report FROM A JSON STRING
-- 
-- Author: Lamont Mitchell
--
-- Revision History:
-- Name                         Date       Change Detail
-- ---------------------------- ---------- -------------------------------------------------------
-- Lamont Mitchell              03/04/2019 Initial Created
-- Stephen Long                 07/15/2022 Added site alert and renamed sproc to standard SET.
-- Leo Tracchia					10/24/2022 Removed select from @Disease for IdfVersion, replaced with @idfVersion
-- Ann Xiong					02/21/2023 Implemented Data Audit
-- Ann Xiong					03/08/2023 Added check for @idfDataAuditEvent IS NULL to only create @idfDataAuditEvent once
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_HumanAggregateCaseMatrixReport_SET]
    @idfAggrHumanCaseMTX BIGINT NULL,
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
        IdfsDiagnosis BIGINT
    );

	--Data Audit--
	declare @idfUserId BIGINT = @UserId;
	declare @idfSiteId BIGINT = @SiteId;
	declare @idfsDataAuditEventType bigint = NULL;
	declare @idfsObjectType bigint = 10017003;                         -- Matrix for Aggregate Reports
	declare @idfObject bigint = @idfAggrHumanCaseMTX;
	declare @idfObjectTable_tlbAggrHumanCaseMTX bigint = 12666620000000;
	declare @idfDataAuditEvent bigint= NULL;

	DECLARE @tlbAggrHumanCaseMTX_BeforeEdit TABLE
	(
        		AggrHumanCaseMTXID BIGINT,
        		IntNumRow INT
	);
	DECLARE @tlbAggrHumanCaseMTX_AfterEdit TABLE
	(
        		AggrHumanCaseMTXID BIGINT,
        		IntNumRow INT
	);
	--Data Audit--

    SET NOCOUNT ON;

    BEGIN TRY
        SET @JsonString = @inJsonString;
        IF EXISTS
        (
            SELECT *
            FROM dbo.tlbAggrHumanCaseMTX
            WHERE idfVersion = @idfVersion
        )
        BEGIN
            UPDATE dbo.tlbAggrHumanCaseMTX
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfVersion = @idfVersion;
        END

        INSERT INTO @Disease
        SELECT *
        FROM
            OPENJSON(@inJsonString)
            WITH
            (
                IntNumRow INT,
                --IdfVersion BIGINT,
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
                FROM dbo.tlbAggrHumanCaseMTX
                WHERE idfVersion = @idfVersion
                      AND idfsDiagnosis =
                      (
                          SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                      )
            )
            BEGIN
                DECLARE @aggHumanCaseMtxId BIGINT;
                SET @aggHumanCaseMtxId =
                (
                    SELECT idfAggrHumanCaseMTX
                    FROM dbo.tlbAggrHumanCaseMTX
                    WHERE idfVersion = @idfVersion
                          AND idfsDiagnosis =
                          (
                              SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                          )
                );

                -- Data audit
                INSERT INTO @tlbAggrHumanCaseMTX_BeforeEdit
                (
                        AggrHumanCaseMTXID,
                        intNumRow
                 )
                 SELECT 	idfAggrHumanCaseMTX,
                    		intNumRow
                 FROM		dbo.tlbAggrHumanCaseMTX
                 WHERE		idfVersion = @idfVersion
                          AND idfsDiagnosis =
                          (
                              SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                          )

                -- End data audit

                UPDATE dbo.tlbAggrHumanCaseMTX
                SET intRowStatus = 0,
                    intNumRow = @_int,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsDiagnosis =
                (
                    SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                )
                      AND idfVersion = @IdfVersion
                      --(
                      --    SELECT IdfVersion FROM @Disease WHERE IntNumRow = @_int
                      --)
                      AND idfAggrHumanCaseMTX = @aggHumanCaseMtxId;

                -- Data audit
                INSERT INTO @tlbAggrHumanCaseMTX_AfterEdit
                (
                        AggrHumanCaseMTXID,
                        IntNumRow
                 )
                 SELECT 	idfAggrHumanCaseMTX,
                    		intNumRow
                 FROM		dbo.tlbAggrHumanCaseMTX
                 WHERE		idfVersion = @idfVersion
                          AND idfsDiagnosis =
                          (
                              SELECT IdfsDiagnosis FROM @Disease WHERE IntNumRow = @_int
                          )

        	    IF @idfDataAuditEvent IS NULL
        	    BEGIN 
					--  tauDataAuditEvent  Event Type- Edit 
					set @idfsDataAuditEventType =10016003;
					-- insert record into tauDataAuditEvent - 
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@aggHumanCaseMtxId, @idfObjectTable_tlbAggrHumanCaseMTX, @idfDataAuditEvent OUTPUT
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
                    SELECT @idfDataAuditEvent,
                           @idfObjectTable_tlbAggrHumanCaseMTX,
                           12666660000000,
                           a.AggrHumanCaseMTXID,
                           NULL,
                           b.IntNumRow,
                           a.IntNumRow
                    FROM @tlbAggrHumanCaseMTX_AfterEdit AS a
                        FULL JOIN @tlbAggrHumanCaseMTX_BeforeEdit AS b
                            ON a.AggrHumanCaseMTXID = b.AggrHumanCaseMTXID
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
                    EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAggrHumanCaseMTX',
                                                   @idfAggrHumanCaseMTX OUTPUT;

                    INSERT INTO dbo.tlbAggrHumanCaseMTX
                    (
                        idfAggrHumanCaseMTX,
                        idfVersion,
                        idfsDiagnosis,
                        intNumRow,
                        intRowStatus,
                        AuditCreateDTM,
                        AuditCreateUser
                    )
                    SELECT @idfAggrHumanCaseMTX,
                           @IdfVersion,
                           IdfsDiagnosis,
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
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfAggrHumanCaseMTX, @idfObjectTable_tlbAggrHumanCaseMTX, @idfDataAuditEvent OUTPUT
					END

					INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tlbAggrHumanCaseMTX, @idfAggrHumanCaseMTX)
					--Data Audit--
                END
            END

            SET @_int = @_int + 1;
        END

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USSP_ADMIN_EVENT_SET-1,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfAggrHumanCaseMTX,
                                        NULL,
                                        @EventSiteId,
                                        NULL,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfAggrHumanCaseMTX AS 'idfAggrHumanCaseMTX';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END

