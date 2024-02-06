-- ================================================================================================
-- Name: USP_LAB_FREEZER_SET
--
-- Description:	Inserts or updates freezer for the laboratory use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/29/2018 Initial release.
-- Stephen Long     01/25/2019 Added box place availability.
-- Stephen Long     03/06/2019 Changed the get next number object name paramater value from the ID 
--                             to the name.
-- Stephen Long     03/28/2019 Changed Notes parameter to FreezerNote.
-- Stephen Long     03/04/2020 Changed box size type from int to bigint.
-- Stephen Long     03/24/2020 Added rack barcode.
-- Stephen Long     03/30/2020 Added audit user name parameter.
-- Leo Tracchia     09/15/2020 Added update for subdivions if intRowStatus = 1
-- Leo Tracchia		11/04/2021 Added logic to correctly update barcode
-- Stephen Long     02/22/2023 Added data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_FREEZER_SET]
(
    @LanguageID NVARCHAR(50),
    @FreezerID BIGINT,
    @StorageTypeID BIGINT,
    @OrganizationID BIGINT,
    @FreezerName NVARCHAR(200) = NULL,
    @FreezerNote NVARCHAR(200) = NULL,
    @EIDSSFreezerID NVARCHAR(200) = NULL,
    @Building NVARCHAR(200) = NULL,
    @Room NVARCHAR(200) = NULL,
    @RowStatus INT,
    @FreezerSubdivisions NVARCHAR(MAX) = NULL,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ReturnCode INT = 0,
            @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
                                                                   -- Data audit
            @AuditUserID BIGINT = NULL,
            @AuditSiteID BIGINT = NULL,
            @DataAuditEventID BIGINT = NULL,
            @DataAuditEventTypeID BIGINT = NULL,
            @ObjectTypeID BIGINT = 10017044,                       -- Repository Scheme
            @ObjectTableFreezerID BIGINT = 75560000000,            -- tlbFreezer
            @ObjectTableFreezerSubdivisionID BIGINT = 75570000000, -- tlbFreezerSubdivision
            @RowID BIGINT,
            @FreezerSubdivisionID BIGINT,
            @SubdivisionTypeID BIGINT = NULL,
            @ParentFreezerSubdivisionID BIGINT = NULL,
            @EIDSSFreezerSubdivisionID NVARCHAR(200) = NULL,
            @FreezerSubdivisionName NVARCHAR(200) = NULL,
            @SubdivisionNote NVARCHAR(200) = NULL,
            @NumberOfLocations INT = NULL,
            @BoxSizeTypeID BIGINT = NULL,
            @BoxPlaceAvailability NVARCHAR(MAX) = NULL,
            @RowAction CHAR = NULL;
    DECLARE @FreezerBeforeEdit TABLE
    (
        FreezerID BIGINT,
        StorageTypeID BIGINT,
        FreezerName NVARCHAR(200),
        FreezerNote NVARCHAR(200),
        EIDSSFreezerID NVARCHAR(200),
        RowStatus INT,
        Building NVARCHAR(200),
        Room NVARCHAR(200)
    );
    DECLARE @FreezerAfterEdit TABLE
    (
        FreezerID BIGINT,
        StorageTypeID BIGINT,
        FreezerName NVARCHAR(200),
        FreezerNote NVARCHAR(200),
        EIDSSFreezerID NVARCHAR(200),
        RowStatus INT,
        Building NVARCHAR(200),
        Room NVARCHAR(200)
    );
    DECLARE @FreezerSubdivisionBeforeEdit TABLE
    (
        FreezerSubdivisionID BIGINT NOT NULL,
        SubdivisionTypeID BIGINT NULL,
        FreezerID BIGINT NOT NULL,
        ParentFreezerSubdivisionID BIGINT NULL,
        EIDSSFreezerSubdivisionID NVARCHAR(200) NULL,
        FreezerSubdivisionName NVARCHAR(200) NULL,
        SubdivisionNote NVARCHAR(200) NULL,
        NumberOfLocations INT NULL,
        BoxSizeTypeID BIGINT NULL,
        BoxPlaceAvailability NVARCHAR(4000) NULL,
        RowStatus INT NOT NULL
    );
    DECLARE @FreezerSubdivisionAfterEdit TABLE
    (
        FreezerSubdivisionID BIGINT NOT NULL,
        SubdivisionTypeID BIGINT NULL,
        FreezerID BIGINT NOT NULL,
        ParentFreezerSubdivisionID BIGINT NULL,
        EIDSSFreezerSubdivisionID NVARCHAR(200) NULL,
        FreezerSubdivisionName NVARCHAR(200) NULL,
        SubdivisionNote NVARCHAR(200) NULL,
        NumberOfLocations INT NULL,
        BoxSizeTypeID BIGINT NULL,
        BoxPlaceAvailability NVARCHAR(4000) NULL,
        RowStatus INT NOT NULL
    );
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );
    DECLARE @FreezerSubdivisionTemp TABLE
    (
        FreezerSubdivisionID BIGINT NOT NULL,
        SubdivisionTypeID BIGINT NULL,
        FreezerID BIGINT NOT NULL,
        ParentFreezerSubdivisionID BIGINT NULL,
        OrganizationID BIGINT NOT NULL,
        EIDSSFreezerSubdivisionID NVARCHAR(200) NULL,
        FreezerSubdivisionName NVARCHAR(200) NULL,
        SubdivisionNote NVARCHAR(200) NULL,
        NumberOfLocations INT NULL,
        BoxSizeTypeID BIGINT NULL,
        BoxPlaceAvailability NVARCHAR(MAX) NULL,
        RowStatus INT NOT NULL,
        RowAction CHAR NULL
    );
    BEGIN TRY
        BEGIN TRANSACTION;
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;

        IF @EIDSSFreezerID IS NULL
        BEGIN
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = 'Freezer Barcode',
                                               @NextNumberValue = @EIDSSFreezerID OUTPUT,
                                               @InstallationSite = @OrganizationID;
        END;

        IF NOT EXISTS
        (
            SELECT *
            FROM dbo.tlbFreezer
            WHERE idfFreezer = @FreezerID
                  AND intRowStatus = 0
        )
        BEGIN
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'tlbFreezer',
                                              @idfsKey = @FreezerID OUTPUT;

            SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @FreezerID,
                                                      @ObjectTableFreezerID,
                                                      @EIDSSFreezerID,
                                                      @DataAuditEventID OUTPUT;

            INSERT INTO dbo.tlbFreezer
            (
                idfFreezer,
                idfsStorageType,
                idfsSite,
                strFreezerName,
                strNote,
                strBarcode,
                intRowStatus,
                LocBuildingName,
                LocRoom,
                AuditCreateUser
            )
            VALUES
            (@FreezerID,
             @StorageTypeID,
             @OrganizationID,
             @FreezerName,
             @FreezerNote,
             @EIDSSFreezerID,
             @RowStatus,
             @Building,
             @Room,
             @AuditUserName
            );

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
             @ObjectTableFreezerID,
             @FreezerID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableFreezerID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSFreezerID
            );
        -- End data audit
        END;
        ELSE
        BEGIN
            -- Data audit
            INSERT INTO @FreezerBeforeEdit
            SELECT idfFreezer,
                   idfsStorageType,
                   strFreezerName,
                   strNote,
                   strBarcode,
                   intRowStatus,
                   LocBuildingName,
                   LocRoom
            FROM dbo.tlbFreezer
            WHERE idfFreezer = @FreezerID;
            -- End data audit

            IF @FreezerSubdivisions IS NULL
               AND @RowStatus = 1
            BEGIN
                UPDATE tlbFreezer
                SET intRowStatus = @RowStatus
                WHERE idfFreezer = @FreezerID

                UPDATE tlbFreezerSubdivision
                SET intRowStatus = @RowStatus
                WHERE idfFreezer = @FreezerID
            END
            ELSE
            BEGIN
                UPDATE dbo.tlbFreezer
                SET idfsStorageType = @StorageTypeID,
                    idfsSite = @OrganizationID,
                    strFreezerName = @FreezerName,
                    strNote = @FreezerNote,
                    strBarcode = @EIDSSFreezerID,
                    intRowStatus = @RowStatus,
                    LocBuildingName = @Building,
                    LocRoom = @Room,
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE()
                WHERE idfFreezer = @FreezerID;
            END

            -- Data audit
            INSERT INTO @FreezerAfterEdit
            SELECT idfFreezer,
                   idfsStorageType,
                   strFreezerName,
                   strNote,
                   strBarcode,
                   intRowStatus,
                   LocBuildingName,
                   LocRoom
            FROM dbo.tlbFreezer
            WHERE idfFreezer = @FreezerID;

            SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @FreezerID,
                                                      @ObjectTableFreezerID,
                                                      @EIDSSFreezerID,
                                                      @DataAuditEventID OUTPUT;

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
                   @ObjectTableFreezerID,
                   79000000000,
                   a.FreezerID,
                   NULL,
                   b.StorageTypeID,
                   a.StorageTypeID,
                   @AuditUserName,
                   @EIDSSFreezerID
            FROM @FreezerAfterEdit a
                FULL JOIN @FreezerBeforeEdit b
                    ON a.FreezerID = b.FreezerID
            WHERE (a.StorageTypeID <> b.StorageTypeID)
                  OR (
                         a.StorageTypeID IS NOT NULL
                         AND b.StorageTypeID IS NULL
                     )
                  OR (
                         a.StorageTypeID IS NULL
                         AND b.StorageTypeID IS NOT NULL
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
                   @ObjectTableFreezerID,
                   79010000000,
                   a.FreezerID,
                   NULL,
                   b.EIDSSFreezerID,
                   a.EIDSSFreezerID,
                   @AuditUserName,
                   @EIDSSFreezerID
            FROM @FreezerAfterEdit a
                FULL JOIN @FreezerBeforeEdit b
                    ON a.FreezerID = b.FreezerID
            WHERE (a.EIDSSFreezerID <> b.EIDSSFreezerID)
                  OR (
                         a.EIDSSFreezerID IS NOT NULL
                         AND b.EIDSSFreezerID IS NULL
                     )
                  OR (
                         a.EIDSSFreezerID IS NULL
                         AND b.EIDSSFreezerID IS NOT NULL
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
                   @ObjectTableFreezerID,
                   79020000000,
                   a.FreezerID,
                   NULL,
                   b.FreezerName,
                   a.FreezerName,
                   @AuditUserName,
                   @EIDSSFreezerID
            FROM @FreezerAfterEdit a
                FULL JOIN @FreezerBeforeEdit b
                    ON a.FreezerID = b.FreezerID
            WHERE (a.FreezerName <> b.FreezerName)
                  OR (
                         a.FreezerName IS NOT NULL
                         AND b.FreezerName IS NULL
                     )
                  OR (
                         a.FreezerName IS NULL
                         AND b.FreezerName IS NOT NULL
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
                   @ObjectTableFreezerID,
                   79030000000,
                   a.FreezerID,
                   NULL,
                   b.FreezerNote,
                   a.FreezerNote,
                   @AuditUserName,
                   @EIDSSFreezerID
            FROM @FreezerAfterEdit a
                FULL JOIN @FreezerBeforeEdit b
                    ON a.FreezerID = b.FreezerID
            WHERE (a.FreezerNote <> b.FreezerNote)
                  OR (
                         a.FreezerNote IS NOT NULL
                         AND b.FreezerNote IS NULL
                     )
                  OR (
                         a.FreezerNote IS NULL
                         AND b.FreezerNote IS NOT NULL
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
                   @ObjectTableFreezerID,
                   51586990000043,
                   a.FreezerID,
                   NULL,
                   b.Building,
                   a.Building,
                   @AuditUserName,
                   @EIDSSFreezerID
            FROM @FreezerAfterEdit a
                FULL JOIN @FreezerBeforeEdit b
                    ON a.FreezerID = b.FreezerID
            WHERE (a.Building <> b.Building)
                  OR (
                         a.Building IS NOT NULL
                         AND b.Building IS NULL
                     )
                  OR (
                         a.Building IS NULL
                         AND b.Building IS NOT NULL
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
                   @ObjectTableFreezerID,
                   51586990000044,
                   a.FreezerID,
                   NULL,
                   b.Room,
                   a.Room,
                   @AuditUserName,
                   @EIDSSFreezerID
            FROM @FreezerAfterEdit a
                FULL JOIN @FreezerBeforeEdit b
                    ON a.FreezerID = b.FreezerID
            WHERE (a.Room <> b.Room)
                  OR (
                         a.Room IS NOT NULL
                         AND b.Room IS NULL
                     )
                  OR (
                         a.Room IS NULL
                         AND b.Room IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailRestore
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                idfObjectDetail,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableFreezerID,
                   a.FreezerID,
                   NULL,
                   @AuditUserName,
                   @EIDSSFreezerID
            FROM @FreezerAfterEdit AS a
                FULL JOIN @FreezerBeforeEdit AS b
                    ON a.FreezerID = b.FreezerID
            WHERE a.RowStatus = 0
                  AND b.RowStatus = 1;
        END;

        INSERT INTO @FreezerSubdivisionTemp
        SELECT *
        FROM
            OPENJSON(@FreezerSubdivisions)
            WITH
            (
                FreezerSubdivisionID BIGINT,
                SubdivisionTypeID BIGINT,
                FreezerID BIGINT,
                ParentFreezerSubdivisionID BIGINT,
                OrganizationID BIGINT,
                EIDSSFreezerSubdivisionID NVARCHAR(200),
                FreezerSubdivisionName NVARCHAR(200),
                SubdivisionNote NVARCHAR(200),
                NumberOfLocations INT,
                BoxSizeTypeID BIGINT,
                BoxPlaceAvailability NVARCHAR(MAX),
                RowStatus INT,
                RowAction CHAR
            );

        WHILE EXISTS (SELECT * FROM @FreezerSubdivisionTemp)
        BEGIN
            SELECT TOP 1
                @RowID = FreezerSubdivisionID,
                @FreezerSubdivisionID = FreezerSubdivisionID,
                @SubdivisionTypeID = SubdivisionTypeID,
                @ParentFreezerSubdivisionID = ParentFreezerSubdivisionID,
                @OrganizationID = OrganizationID,
                @EIDSSFreezerSubdivisionID = EIDSSFreezerSubdivisionID,
                @FreezerSubdivisionName = FreezerSubdivisionName,
                @SubdivisionNote = SubdivisionNote,
                @NumberOfLocations = NumberOfLocations,
                @BoxSizeTypeID = BoxSizeTypeID,
                @BoxPlaceAvailability = BoxPlaceAvailability,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @FreezerSubdivisionTemp;

            IF @RowAction = 'I'
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'tlbFreezerSubdivision',
                                                  @idfsKey = @FreezerSubdivisionID OUTPUT;

                IF (
                       @SubdivisionTypeID = 39890000000
                       AND (
                               TRIM(@EIDSSFreezerSubdivisionID) = N''
                               OR @EIDSSFreezerSubdivisionID IS NULL
                           )
                   ) --Box
                BEGIN
                    INSERT INTO @SuppressSelect
                    EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N'Box Barcode',
                                                       @NextNumberValue = @EIDSSFreezerSubdivisionID OUTPUT,
                                                       @InstallationSite = NULL;
                END
                ELSE IF (
                            @SubdivisionTypeID = 39900000000
                            AND (
                                    TRIM(@EIDSSFreezerSubdivisionID) = N''
                                    OR @EIDSSFreezerSubdivisionID IS NULL
                                )
                        ) -- Shelf
                BEGIN
                    INSERT INTO @SuppressSelect
                    EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N'Shelf Barcode',
                                                       @NextNumberValue = @EIDSSFreezerSubdivisionID OUTPUT,
                                                       @InstallationSite = NULL;
                END
                ELSE IF (
                            @SubdivisionTypeID = 10093001
                            AND (
                                    TRIM(@EIDSSFreezerSubdivisionID) = N''
                                    OR @EIDSSFreezerSubdivisionID IS NULL
                                )
                        ) -- Rack
                BEGIN
                    INSERT INTO @SuppressSelect
                    EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N'Rack Barcode',
                                                       @NextNumberValue = @EIDSSFreezerSubdivisionID OUTPUT,
                                                       @InstallationSite = NULL;
                END;

                INSERT INTO dbo.tlbFreezerSubdivision
                (
                    idfSubdivision,
                    idfsSubdivisionType,
                    idfFreezer,
                    idfParentSubdivision,
                    idfsSite,
                    strBarcode,
                    strNameChars,
                    strNote,
                    intCapacity,
                    intRowStatus,
                    BoxSizeID,
                    BoxPlaceAvailability,
                    AuditCreateUser
                )
                VALUES
                (@FreezerSubdivisionID,
                 @SubdivisionTypeID,
                 @FreezerID,
                 @ParentFreezerSubdivisionID,
                 @OrganizationID,
                 @EIDSSFreezerSubdivisionID,
                 @FreezerSubdivisionName,
                 @SubdivisionNote,
                 @NumberOfLocations,
                 @RowStatus,
                 @BoxSizeTypeID,
                 @BoxPlaceAvailability,
                 @AuditUserName
                );

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
                 @ObjectTableFreezerSubdivisionID,
                 @FreezerSubdivisionID,
                 10519001,
                 '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                 + CAST(@ObjectTableFreezerSubdivisionID AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 @EIDSSFreezerSubdivisionID
                );
            -- End data audit
            END;
            ELSE
            BEGIN
                IF (
                       @SubdivisionTypeID = 39890000000
                       AND (
                               TRIM(@EIDSSFreezerSubdivisionID) = N''
                               OR @EIDSSFreezerSubdivisionID IS NULL
                           )
                   ) --Box
                BEGIN
                    INSERT INTO @SuppressSelect
                    EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N'Box Barcode',
                                                       @NextNumberValue = @EIDSSFreezerSubdivisionID OUTPUT,
                                                       @InstallationSite = NULL;
                END
                ELSE IF (
                            @SubdivisionTypeID = 39900000000
                            AND (
                                    TRIM(@EIDSSFreezerSubdivisionID) = N''
                                    OR @EIDSSFreezerSubdivisionID IS NULL
                                )
                        ) -- Shelf
                BEGIN
                    INSERT INTO @SuppressSelect
                    EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N'Shelf Barcode',
                                                       @NextNumberValue = @EIDSSFreezerSubdivisionID OUTPUT,
                                                       @InstallationSite = NULL;
                END
                ELSE IF (
                            @SubdivisionTypeID = 10093001
                            AND (
                                    TRIM(@EIDSSFreezerSubdivisionID) = N''
                                    OR @EIDSSFreezerSubdivisionID IS NULL
                                )
                        ) -- Rack
                BEGIN
                    INSERT INTO @SuppressSelect
                    EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N'Rack Barcode',
                                                       @NextNumberValue = @EIDSSFreezerSubdivisionID OUTPUT,
                                                       @InstallationSite = NULL;
                END;

                -- Data audit
                INSERT INTO @FreezerSubdivisionBeforeEdit
                SELECT idfSubdivision,
                       idfsSubdivisionType,
                       idfFreezer,
                       idfParentSubdivision,
                       strBarcode,
                       strNameChars,
                       strNote,
                       intCapacity,
                       intRowStatus,
                       BoxSizeID,
                       BoxPlaceAvailability
                FROM dbo.tlbFreezerSubdivision
                WHERE idfSubdivision = @FreezerSubdivisionID;
                -- End data audit

                UPDATE dbo.tlbFreezerSubdivision
                SET idfsSubdivisionType = @SubdivisionTypeID,
                    idfFreezer = @FreezerID,
                    idfParentSubdivision = @ParentFreezerSubdivisionID,
                    idfsSite = @OrganizationID,
                    strBarcode = @EIDSSFreezerSubdivisionID,
                    strNameChars = @FreezerSubdivisionName,
                    strNote = @SubdivisionNote,
                    intCapacity = @NumberOfLocations,
                    intRowStatus = @RowStatus,
                    BoxSizeID = @BoxSizeTypeID,
                    BoxPlaceAvailability = @BoxPlaceAvailability,
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE()
                WHERE idfSubdivision = @FreezerSubdivisionID;

                -- Data audit
                INSERT INTO @FreezerSubdivisionAfterEdit
                SELECT idfSubdivision,
                       idfsSubdivisionType,
                       idfFreezer,
                       idfParentSubdivision,
                       strBarcode,
                       strNameChars,
                       strNote,
                       intCapacity,
                       intRowStatus,
                       BoxSizeID,
                       BoxPlaceAvailability
                FROM dbo.tlbFreezerSubdivision
                WHERE idfSubdivision = @FreezerSubdivisionID;

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
                       @ObjectTableFreezerSubdivisionID,
                       79050000000,
                       a.FreezerSubdivisionID,
                       NULL,
                       b.SubdivisionTypeID,
                       a.SubdivisionTypeID,
                       @AuditUserName,
                       @EIDSSFreezerSubdivisionID
                FROM @FreezerSubdivisionAfterEdit a
                    FULL JOIN @FreezerSubdivisionBeforeEdit b
                        ON a.FreezerSubdivisionID = b.FreezerSubdivisionID
                WHERE (a.SubdivisionTypeID <> b.SubdivisionTypeID)
                      OR (
                             a.SubdivisionTypeID IS NOT NULL
                             AND b.SubdivisionTypeID IS NULL
                         )
                      OR (
                             a.SubdivisionTypeID IS NULL
                             AND b.SubdivisionTypeID IS NOT NULL
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
                       @ObjectTableFreezerSubdivisionID,
                       79060000000,
                       a.FreezerSubdivisionID,
                       NULL,
                       b.EIDSSFreezerSubdivisionID,
                       a.EIDSSFreezerSubdivisionID,
                       @AuditUserName,
                       @EIDSSFreezerSubdivisionID
                FROM @FreezerSubdivisionAfterEdit a
                    FULL JOIN @FreezerSubdivisionBeforeEdit b
                        ON a.FreezerSubdivisionID = b.FreezerSubdivisionID
                WHERE (a.EIDSSFreezerSubdivisionID <> b.EIDSSFreezerSubdivisionID)
                      OR (
                             a.EIDSSFreezerSubdivisionID IS NOT NULL
                             AND b.EIDSSFreezerSubdivisionID IS NULL
                         )
                      OR (
                             a.EIDSSFreezerSubdivisionID IS NULL
                             AND b.EIDSSFreezerSubdivisionID IS NOT NULL
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
                       @ObjectTableFreezerSubdivisionID,
                       79070000000,
                       a.FreezerSubdivisionID,
                       NULL,
                       b.FreezerSubdivisionName,
                       a.FreezerSubdivisionName,
                       @AuditUserName,
                       @EIDSSFreezerSubdivisionID
                FROM @FreezerSubdivisionAfterEdit a
                    FULL JOIN @FreezerSubdivisionBeforeEdit b
                        ON a.FreezerSubdivisionID = b.FreezerSubdivisionID
                WHERE (a.FreezerSubdivisionName <> b.FreezerSubdivisionName)
                      OR (
                             a.FreezerSubdivisionName IS NOT NULL
                             AND b.FreezerSubdivisionName IS NULL
                         )
                      OR (
                             a.FreezerSubdivisionName IS NULL
                             AND b.FreezerSubdivisionName IS NOT NULL
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
                       @ObjectTableFreezerSubdivisionID,
                       79080000000,
                       a.FreezerSubdivisionID,
                       NULL,
                       b.SubdivisionNote,
                       a.SubdivisionNote,
                       @AuditUserName,
                       @EIDSSFreezerSubdivisionID
                FROM @FreezerSubdivisionAfterEdit a
                    FULL JOIN @FreezerSubdivisionBeforeEdit b
                        ON a.FreezerSubdivisionID = b.FreezerSubdivisionID
                WHERE (a.SubdivisionNote <> b.SubdivisionNote)
                      OR (
                             a.SubdivisionNote IS NOT NULL
                             AND b.SubdivisionNote IS NULL
                         )
                      OR (
                             a.SubdivisionNote IS NULL
                             AND b.SubdivisionNote IS NOT NULL
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
                       @ObjectTableFreezerSubdivisionID,
                       749100000000,
                       a.FreezerSubdivisionID,
                       NULL,
                       b.FreezerID,
                       a.FreezerID,
                       @AuditUserName,
                       @EIDSSFreezerSubdivisionID
                FROM @FreezerSubdivisionAfterEdit a
                    FULL JOIN @FreezerSubdivisionBeforeEdit b
                        ON a.FreezerSubdivisionID = b.FreezerSubdivisionID
                WHERE (a.FreezerID <> b.FreezerID)
                      OR (
                             a.FreezerID IS NOT NULL
                             AND b.FreezerID IS NULL
                         )
                      OR (
                             a.FreezerID IS NULL
                             AND b.FreezerID IS NOT NULL
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
                       @ObjectTableFreezerSubdivisionID,
                       749110000000,
                       a.FreezerSubdivisionID,
                       NULL,
                       b.ParentFreezerSubdivisionID,
                       a.ParentFreezerSubdivisionID,
                       @AuditUserName,
                       @EIDSSFreezerSubdivisionID
                FROM @FreezerSubdivisionAfterEdit a
                    FULL JOIN @FreezerSubdivisionBeforeEdit b
                        ON a.FreezerSubdivisionID = b.FreezerSubdivisionID
                WHERE (a.ParentFreezerSubdivisionID <> b.ParentFreezerSubdivisionID)
                      OR (
                             a.ParentFreezerSubdivisionID IS NOT NULL
                             AND b.ParentFreezerSubdivisionID IS NULL
                         )
                      OR (
                             a.ParentFreezerSubdivisionID IS NULL
                             AND b.ParentFreezerSubdivisionID IS NOT NULL
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
                       @ObjectTableFreezerSubdivisionID,
                       749120000000,
                       a.FreezerSubdivisionID,
                       NULL,
                       b.NumberOfLocations,
                       a.NumberOfLocations,
                       @AuditUserName,
                       @EIDSSFreezerSubdivisionID
                FROM @FreezerSubdivisionAfterEdit a
                    FULL JOIN @FreezerSubdivisionBeforeEdit b
                        ON a.FreezerSubdivisionID = b.FreezerSubdivisionID
                WHERE (a.NumberOfLocations <> b.NumberOfLocations)
                      OR (
                             a.NumberOfLocations IS NOT NULL
                             AND b.NumberOfLocations IS NULL
                         )
                      OR (
                             a.NumberOfLocations IS NULL
                             AND b.NumberOfLocations IS NOT NULL
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
                       @ObjectTableFreezerSubdivisionID,
                       51586990000041,
                       a.FreezerSubdivisionID,
                       NULL,
                       b.BoxPlaceAvailability,
                       a.BoxPlaceAvailability,
                       @AuditUserName,
                       @EIDSSFreezerSubdivisionID
                FROM @FreezerSubdivisionAfterEdit a
                    FULL JOIN @FreezerSubdivisionBeforeEdit b
                        ON a.FreezerSubdivisionID = b.FreezerSubdivisionID
                WHERE (a.BoxPlaceAvailability <> b.BoxPlaceAvailability)
                      OR (
                             a.BoxPlaceAvailability IS NOT NULL
                             AND b.BoxPlaceAvailability IS NULL
                         )
                      OR (
                             a.BoxPlaceAvailability IS NULL
                             AND b.BoxPlaceAvailability IS NOT NULL
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
                       @ObjectTableFreezerSubdivisionID,
                       51586990000042,
                       a.FreezerSubdivisionID,
                       NULL,
                       b.BoxSizeTypeID,
                       a.BoxSizeTypeID,
                       @AuditUserName,
                       @EIDSSFreezerSubdivisionID
                FROM @FreezerSubdivisionAfterEdit a
                    FULL JOIN @FreezerSubdivisionBeforeEdit b
                        ON a.FreezerSubdivisionID = b.FreezerSubdivisionID
                WHERE (a.BoxSizeTypeID <> b.BoxSizeTypeID)
                      OR (
                             a.BoxSizeTypeID IS NOT NULL
                             AND b.BoxSizeTypeID IS NULL
                         )
                      OR (
                             a.BoxSizeTypeID IS NULL
                             AND b.BoxSizeTypeID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailRestore
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject,
                    idfObjectDetail,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableFreezerSubdivisionID,
                       a.FreezerSubdivisionID,
                       NULL,
                       @AuditUserName,
                       @EIDSSFreezerSubdivisionID
                FROM @FreezerSubdivisionAfterEdit AS a
                    FULL JOIN @FreezerSubdivisionBeforeEdit AS b
                        ON a.FreezerSubdivisionID = b.FreezerSubdivisionID
                WHERE a.RowStatus = 0
                      AND b.RowStatus = 1;
            END;

            UPDATE @FreezerSubdivisionTemp
            SET ParentFreezerSubdivisionID = @FreezerSubdivisionID
            WHERE ParentFreezerSubdivisionID = @RowID;

            DELETE FROM @FreezerSubdivisionTemp
            WHERE FreezerSubdivisionID = @RowID;
        END;

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @FreezerID FreezerID,
               @EIDSSFreezerID EIDSSFreezerID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @FreezerID FreezerID,
               @EIDSSFreezerID EIDSSFreezerID;
        THROW;
    END CATCH;
END;
