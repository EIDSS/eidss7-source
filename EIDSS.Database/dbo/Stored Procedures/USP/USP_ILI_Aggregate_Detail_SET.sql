-- ================================================================================================
-- Name: USP_ILI_Aggregate_Detail_SET
--
-- Description:	Inserts or updates Hospital/Sentinel Station Name for the human module ILI 
-- Aggregate edit/set up use cases
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ann Xiong        02/28/2020 Initial release
-- Ann Xiong        03/05/2020 update RowStatus
-- Leo Tracchia	    03/13/2022 Altered logic to better handle updates
-- Stephen Long     07/12/2022 Removed language id parameter as it is not needed, and added source
--                             system key value.
-- Stephen Long     12/01/2022 Added data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ILI_Aggregate_Detail_SET]
(
    @idfAggregateDetail BIGINT,
    @idfAggregateHeader BIGINT,
    @RowStatus INT,
    @idfHospital BIGINT = NULL,
    @intAge0_4 INT = NULL,
    @intAge5_14 INT = NULL,
    @intAge15_29 INT = NULL,
    @intAge30_64 INT = NULL,
    @intAge65 INT = NULL,
    @inTotalILI INT = NULL,
    @intTotalAdmissions INT = NULL,
    @intILISamples INT = NULL,
    @AuditUserName NVARCHAR(200),
    @DataAuditEventID BIGINT = NULL,
    @EIDSSObjectID NVARCHAR(200) = NULL,
    @RowAction CHAR(1) NULL
)
AS
-- Data audit
DECLARE @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @ObjectID BIGINT = @idfAggregateDetail,
        @ObjectTableID BIGINT = 50791790000000; -- tlbBasicSyndromicSurveillanceAggregateDetail
DECLARE @ILIAggregateDetailBeforeEdit TABLE
(
    AggregateDetailID BIGINT,
    AggregateHeaderID BIGINT,
    HospitalID BIGINT,
    Age0To4 INT,
    Age5To14 INT,
    Age15To29 INT,
    Age30To64 INT,
    Age65 INT,
    TotalILI INT,
    TotalAdmissions INT,
    ILISamples INT
);
DECLARE @ILIAggregateDetailAfterEdit TABLE
(
    AggregateDetailID BIGINT,
    AggregateHeaderID BIGINT,
    HospitalID BIGINT,
    Age0To4 INT,
    Age5To14 INT,
    Age15To29 INT,
    Age30To64 INT,
    Age65 INT,
    TotalILI INT,
    TotalAdmissions INT,
    ILISamples INT
);
-- End data audit
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        IF (@idfAggregateDetail IS NULL OR @idfAggregateDetail = 0)
        BEGIN
            IF (EXISTS
            (
                SELECT idfAggregateDetail
                FROM dbo.tlbBasicSyndromicSurveillanceAggregateDetail
                WHERE idfHospital = @idfHospital
                      AND idfAggregateHeader = @idfAggregateHeader
            )
               )
            BEGIN
                SELECT @idfAggregateDetail = idfAggregateDetail
                FROM dbo.tlbBasicSyndromicSurveillanceAggregateDetail
                WHERE idfHospital = @idfHospital
                      AND idfAggregateHeader = @idfAggregateHeader;

                -- Data audit
                INSERT INTO @ILIAggregateDetailBeforeEdit
                (
                    AggregateDetailID,
                    AggregateHeaderID,
                    HospitalID,
                    Age0To4,
                    Age5To14,
                    Age15To29,
                    Age30To64,
                    Age65,
                    TotalILI,
                    TotalAdmissions,
                    ILISamples
                )
                SELECT idfAggregateDetail,
                       idfAggregateHeader,
                       idfHospital,
                       intAge0_4,
                       intAge5_14,
                       intAge15_29,
                       intAge30_64,
                       intAge65,
                       inTotalILI,
                       intTotalAdmissions,
                       intILISamples
                FROM dbo.tlbBasicSyndromicSurveillanceAggregateDetail
                WHERE idfAggregateDetail = @idfAggregateDetail;
                -- End data audit

                UPDATE dbo.tlbBasicSyndromicSurveillanceAggregateDetail
                SET idfHospital = @idfHospital,
                    intAge0_4 = @intAge0_4,
                    intAge5_14 = @intAge5_14,
                    intAge15_29 = @intAge15_29,
                    intAge30_64 = @intAge30_64,
                    intAge65 = @intAge65,
                    inTotalILI = @inTotalILI,
                    intTotalAdmissions = @intTotalAdmissions,
                    intILISamples = @intILISamples,
                    intRowStatus = @RowStatus,
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE()
                WHERE idfAggregateDetail = @idfAggregateDetail;

                -- Data audit
                INSERT INTO @ILIAggregateDetailAfterEdit
                (
                    AggregateDetailID,
                    AggregateHeaderID,
                    HospitalID,
                    Age0To4,
                    Age5To14,
                    Age15To29,
                    Age30To64,
                    Age65,
                    TotalILI,
                    TotalAdmissions,
                    ILISamples
                )
                SELECT idfAggregateDetail,
                       idfAggregateHeader,
                       idfHospital,
                       intAge0_4,
                       intAge5_14,
                       intAge15_29,
                       intAge30_64,
                       intAge65,
                       inTotalILI,
                       intTotalAdmissions,
                       intILISamples
                FROM dbo.tlbBasicSyndromicSurveillanceAggregateDetail
                WHERE idfAggregateDetail = @idfAggregateDetail;

                IF @RowStatus = 0
                BEGIN
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
                           50791810000000,
                           a.AggregateDetailID,
                           NULL,
                           b.AggregateHeaderID,
                           a.AggregateHeaderID,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ILIAggregateDetailAfterEdit AS a
                        FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                            ON a.AggregateDetailID = b.AggregateDetailID
                    WHERE (a.AggregateHeaderID <> b.AggregateHeaderID)
                          OR (
                                 a.AggregateHeaderID IS NOT NULL
                                 AND b.AggregateHeaderID IS NULL
                             )
                          OR (
                                 a.AggregateHeaderID IS NULL
                                 AND b.AggregateHeaderID IS NOT NULL
                             )

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
                           50791820000000,
                           a.AggregateDetailID,
                           NULL,
                           b.HospitalID,
                           a.HospitalID,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ILIAggregateDetailAfterEdit AS a
                        FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                            ON a.AggregateDetailID = b.AggregateDetailID
                    WHERE (a.HospitalID <> b.HospitalID)
                          OR (
                                 a.HospitalID IS NOT NULL
                                 AND b.HospitalID IS NULL
                             )
                          OR (
                                 a.HospitalID IS NULL
                                 AND b.HospitalID IS NOT NULL
                             )

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
                           50791830000000,
                           a.AggregateDetailID,
                           NULL,
                           b.Age0To4,
                           a.Age0To4,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ILIAggregateDetailAfterEdit AS a
                        FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                            ON a.AggregateDetailID = b.AggregateDetailID
                    WHERE (a.Age0To4 <> b.Age0To4)
                          OR (
                                 a.Age0To4 IS NOT NULL
                                 AND b.Age0To4 IS NULL
                             )
                          OR (
                                 a.Age0To4 IS NULL
                                 AND b.Age0To4 IS NOT NULL
                             )

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
                           50815350000000,
                           a.AggregateDetailID,
                           NULL,
                           b.Age5To14,
                           a.Age5To14,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ILIAggregateDetailAfterEdit AS a
                        FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                            ON a.AggregateDetailID = b.AggregateDetailID
                    WHERE (a.Age5To14 <> b.Age5To14)
                          OR (
                                 a.Age5To14 IS NOT NULL
                                 AND b.Age5To14 IS NULL
                             )
                          OR (
                                 a.Age5To14 IS NULL
                                 AND b.Age5To14 IS NOT NULL
                             )

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
                           50791850000000,
                           a.AggregateDetailID,
                           NULL,
                           b.Age15To29,
                           a.Age15To29,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ILIAggregateDetailAfterEdit AS a
                        FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                            ON a.AggregateDetailID = b.AggregateDetailID
                    WHERE (a.Age15To29 <> b.Age15To29)
                          OR (
                                 a.Age15To29 IS NOT NULL
                                 AND b.Age15To29 IS NULL
                             )
                          OR (
                                 a.Age15To29 IS NULL
                                 AND b.Age15To29 IS NOT NULL
                             )

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
                           50791860000000,
                           a.AggregateDetailID,
                           NULL,
                           b.Age30To64,
                           a.Age30To64,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ILIAggregateDetailAfterEdit AS a
                        FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                            ON a.AggregateDetailID = b.AggregateDetailID
                    WHERE (a.Age30To64 <> b.Age30To64)
                          OR (
                                 a.Age30To64 IS NOT NULL
                                 AND b.Age30To64 IS NULL
                             )
                          OR (
                                 a.Age30To64 IS NULL
                                 AND b.Age30To64 IS NOT NULL
                             )

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
                           50791870000000,
                           a.AggregateDetailID,
                           NULL,
                           b.Age65,
                           a.Age65,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ILIAggregateDetailAfterEdit AS a
                        FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                            ON a.AggregateDetailID = b.AggregateDetailID
                    WHERE (a.Age65 <> b.Age65)
                          OR (
                                 a.Age65 IS NOT NULL
                                 AND b.Age65 IS NULL
                             )
                          OR (
                                 a.Age65 IS NULL
                                 AND b.Age65 IS NOT NULL
                             )

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
                           50791880000000,
                           a.AggregateDetailID,
                           NULL,
                           b.TotalILI,
                           a.TotalILI,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ILIAggregateDetailAfterEdit AS a
                        FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                            ON a.AggregateDetailID = b.AggregateDetailID
                    WHERE (a.TotalILI <> b.TotalILI)
                          OR (
                                 a.TotalILI IS NOT NULL
                                 AND b.TotalILI IS NULL
                             )
                          OR (
                                 a.TotalILI IS NULL
                                 AND b.TotalILI IS NOT NULL
                             )

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
                           50791890000000,
                           a.AggregateDetailID,
                           NULL,
                           b.TotalAdmissions,
                           a.TotalAdmissions,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ILIAggregateDetailAfterEdit AS a
                        FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                            ON a.AggregateDetailID = b.AggregateDetailID
                    WHERE (a.TotalAdmissions <> b.TotalAdmissions)
                          OR (
                                 a.TotalAdmissions IS NOT NULL
                                 AND b.TotalAdmissions IS NULL
                             )
                          OR (
                                 a.TotalAdmissions IS NULL
                                 AND b.TotalAdmissions IS NOT NULL
                             )

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
                           50791900000000,
                           a.AggregateDetailID,
                           NULL,
                           b.ILISamples,
                           a.ILISamples,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ILIAggregateDetailAfterEdit AS a
                        FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                            ON a.AggregateDetailID = b.AggregateDetailID
                    WHERE (a.ILISamples <> b.ILISamples)
                          OR (
                                 a.ILISamples IS NOT NULL
                                 AND b.ILISamples IS NULL
                             )
                          OR (
                                 a.ILISamples IS NULL
                                 AND b.ILISamples IS NOT NULL
                             )
                END
                ELSE
                BEGIN
                    INSERT INTO dbo.tauDataAuditDetailDelete
                    (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfObject,
                        AuditCreateUser,
                        strObject
                    )
                    VALUES
                    (@DataAuditEventid, @ObjectTableID, @idfAggregateDetail, @AuditUserName, @EIDSSObjectID);
                END
            -- End data audit
            END
            ELSE
            BEGIN
                EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbBasicSyndromicSurveillanceAggregateDetail',
                                               @idfAggregateDetail OUTPUT;

                INSERT INTO dbo.tlbBasicSyndromicSurveillanceAggregateDetail
                (
                    idfAggregateDetail,
                    idfAggregateHeader,
                    idfHospital,
                    intAge0_4,
                    intAge5_14,
                    intAge15_29,
                    intAge30_64,
                    intAge65,
                    inTotalILI,
                    intTotalAdmissions,
                    intILISamples,
                    rowguid,
                    strMaintenanceFlag,
                    strReservedAttribute,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser,
                    AuditCreateDTM
                )
                VALUES
                (@idfAggregateDetail,
                 @idfAggregateHeader,
                 @idfHospital,
                 @intAge0_4,
                 @intAge5_14,
                 @intAge15_29,
                 @intAge30_64,
                 @intAge65,
                 @inTotalILI,
                 @intTotalAdmissions,
                 @intILISamples,
                 NEWID(),
                 'system',
                 'V7 ILI Aggregate Form',
                 10519001,
                 '[{"idfAggregateDetail":' + CAST(@idfAggregateDetail AS NVARCHAR(300)) + ',"idfAggregateHeader":'
                 + CAST(@idfAggregateHeader AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 GETDATE()
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
                 @ObjectTableID,
                 @idfAggregateHeader,
                 10519001,
                 '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                 + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 @EIDSSObjectID
                );
            -- End data audit

            END
        END
        ELSE
        BEGIN
            -- Data audit
            INSERT INTO @ILIAggregateDetailBeforeEdit
            (
                AggregateDetailID,
                AggregateHeaderID,
                HospitalID,
                Age0To4,
                Age5To14,
                Age15To29,
                Age30To64,
                Age65,
                TotalILI,
                TotalAdmissions,
                ILISamples
            )
            SELECT idfAggregateDetail,
                   idfAggregateHeader,
                   idfHospital,
                   intAge0_4,
                   intAge5_14,
                   intAge15_29,
                   intAge30_64,
                   intAge65,
                   inTotalILI,
                   intTotalAdmissions,
                   intILISamples
            FROM dbo.tlbBasicSyndromicSurveillanceAggregateDetail
            WHERE idfAggregateDetail = @idfAggregateDetail;
            -- End data audit

            UPDATE dbo.tlbBasicSyndromicSurveillanceAggregateDetail
            SET idfHospital = @idfHospital,
                intAge0_4 = @intAge0_4,
                intAge5_14 = @intAge5_14,
                intAge15_29 = @intAge15_29,
                intAge30_64 = @intAge30_64,
                intAge65 = @intAge65,
                inTotalILI = @inTotalILI,
                intTotalAdmissions = @intTotalAdmissions,
                intILISamples = @intILISamples,
                intRowStatus = @RowStatus,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfAggregateDetail = @idfAggregateDetail;

            -- Data audit
            INSERT INTO @ILIAggregateDetailAfterEdit
            (
                AggregateDetailID,
                AggregateHeaderID,
                HospitalID,
                Age0To4,
                Age5To14,
                Age15To29,
                Age30To64,
                Age65,
                TotalILI,
                TotalAdmissions,
                ILISamples
            )
            SELECT idfAggregateDetail,
                   idfAggregateHeader,
                   idfHospital,
                   intAge0_4,
                   intAge5_14,
                   intAge15_29,
                   intAge30_64,
                   intAge65,
                   inTotalILI,
                   intTotalAdmissions,
                   intILISamples
            FROM dbo.tlbBasicSyndromicSurveillanceAggregateDetail
            WHERE idfAggregateDetail = @idfAggregateDetail;

            IF @RowStatus = 0
            BEGIN
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
                       50791810000000,
                       a.AggregateDetailID,
                       NULL,
                       b.AggregateHeaderID,
                       a.AggregateHeaderID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @ILIAggregateDetailAfterEdit AS a
                    FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                        ON a.AggregateDetailID = b.AggregateDetailID
                WHERE (a.AggregateHeaderID <> b.AggregateHeaderID)
                      OR (
                             a.AggregateHeaderID IS NOT NULL
                             AND b.AggregateHeaderID IS NULL
                         )
                      OR (
                             a.AggregateHeaderID IS NULL
                             AND b.AggregateHeaderID IS NOT NULL
                         )

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
                       50791820000000,
                       a.AggregateDetailID,
                       NULL,
                       b.HospitalID,
                       a.HospitalID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @ILIAggregateDetailAfterEdit AS a
                    FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                        ON a.AggregateDetailID = b.AggregateDetailID
                WHERE (a.HospitalID <> b.HospitalID)
                      OR (
                             a.HospitalID IS NOT NULL
                             AND b.HospitalID IS NULL
                         )
                      OR (
                             a.HospitalID IS NULL
                             AND b.HospitalID IS NOT NULL
                         )

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
                       50791830000000,
                       a.AggregateDetailID,
                       NULL,
                       b.Age0To4,
                       a.Age0To4,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @ILIAggregateDetailAfterEdit AS a
                    FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                        ON a.AggregateDetailID = b.AggregateDetailID
                WHERE (a.Age0To4 <> b.Age0To4)
                      OR (
                             a.Age0To4 IS NOT NULL
                             AND b.Age0To4 IS NULL
                         )
                      OR (
                             a.Age0To4 IS NULL
                             AND b.Age0To4 IS NOT NULL
                         )

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
                       50815350000000,
                       a.AggregateDetailID,
                       NULL,
                       b.Age5To14,
                       a.Age5To14,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @ILIAggregateDetailAfterEdit AS a
                    FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                        ON a.AggregateDetailID = b.AggregateDetailID
                WHERE (a.Age5To14 <> b.Age5To14)
                      OR (
                             a.Age5To14 IS NOT NULL
                             AND b.Age5To14 IS NULL
                         )
                      OR (
                             a.Age5To14 IS NULL
                             AND b.Age5To14 IS NOT NULL
                         )

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
                       50791850000000,
                       a.AggregateDetailID,
                       NULL,
                       b.Age15To29,
                       a.Age15To29,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @ILIAggregateDetailAfterEdit AS a
                    FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                        ON a.AggregateDetailID = b.AggregateDetailID
                WHERE (a.Age15To29 <> b.Age15To29)
                      OR (
                             a.Age15To29 IS NOT NULL
                             AND b.Age15To29 IS NULL
                         )
                      OR (
                             a.Age15To29 IS NULL
                             AND b.Age15To29 IS NOT NULL
                         )

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
                       50791860000000,
                       a.AggregateDetailID,
                       NULL,
                       b.Age30To64,
                       a.Age30To64,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @ILIAggregateDetailAfterEdit AS a
                    FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                        ON a.AggregateDetailID = b.AggregateDetailID
                WHERE (a.Age30To64 <> b.Age30To64)
                      OR (
                             a.Age30To64 IS NOT NULL
                             AND b.Age30To64 IS NULL
                         )
                      OR (
                             a.Age30To64 IS NULL
                             AND b.Age30To64 IS NOT NULL
                         )

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
                       50791870000000,
                       a.AggregateDetailID,
                       NULL,
                       b.Age65,
                       a.Age65,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @ILIAggregateDetailAfterEdit AS a
                    FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                        ON a.AggregateDetailID = b.AggregateDetailID
                WHERE (a.Age65 <> b.Age65)
                      OR (
                             a.Age65 IS NOT NULL
                             AND b.Age65 IS NULL
                         )
                      OR (
                             a.Age65 IS NULL
                             AND b.Age65 IS NOT NULL
                         )

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
                       50791880000000,
                       a.AggregateDetailID,
                       NULL,
                       b.TotalILI,
                       a.TotalILI,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @ILIAggregateDetailAfterEdit AS a
                    FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                        ON a.AggregateDetailID = b.AggregateDetailID
                WHERE (a.TotalILI <> b.TotalILI)
                      OR (
                             a.TotalILI IS NOT NULL
                             AND b.TotalILI IS NULL
                         )
                      OR (
                             a.TotalILI IS NULL
                             AND b.TotalILI IS NOT NULL
                         )

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
                       50791890000000,
                       a.AggregateDetailID,
                       NULL,
                       b.TotalAdmissions,
                       a.TotalAdmissions,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @ILIAggregateDetailAfterEdit AS a
                    FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                        ON a.AggregateDetailID = b.AggregateDetailID
                WHERE (a.TotalAdmissions <> b.TotalAdmissions)
                      OR (
                             a.TotalAdmissions IS NOT NULL
                             AND b.TotalAdmissions IS NULL
                         )
                      OR (
                             a.TotalAdmissions IS NULL
                             AND b.TotalAdmissions IS NOT NULL
                         )

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
                       50791900000000,
                       a.AggregateDetailID,
                       NULL,
                       b.ILISamples,
                       a.ILISamples,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @ILIAggregateDetailAfterEdit AS a
                    FULL JOIN @ILIAggregateDetailBeforeEdit AS b
                        ON a.AggregateDetailID = b.AggregateDetailID
                WHERE (a.ILISamples <> b.ILISamples)
                      OR (
                             a.ILISamples IS NOT NULL
                             AND b.ILISamples IS NULL
                         )
                      OR (
                             a.ILISamples IS NULL
                             AND b.ILISamples IS NOT NULL
                         )
            END
            ELSE
            BEGIN
                INSERT INTO dbo.tauDataAuditDetailDelete
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject,
                    AuditCreateUser,
                    strObject
                )
                VALUES
                (@DataAuditEventid, @ObjectTableID, @idfAggregateDetail, @AuditUserName, @EIDSSObjectID);
            END
        -- End data audit
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END

