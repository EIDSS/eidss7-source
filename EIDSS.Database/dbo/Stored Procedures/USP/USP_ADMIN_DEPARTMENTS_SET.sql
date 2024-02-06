-- ================================================================================================
-- Name: USP_ADMIN_DEPARTMENTS_SET
--
-- Description: Adds or updates a department in an organization.
--
-- Author: Ricky Moss
-- 
-- Change Log:
-- Name 				Date       Description
-- -------------------- ---------- ---------------------------------------------------------------
-- Stephen Long		    12/13/2022 Initial release for data auditing for SAUC30 and 31.
-- Ann Xiong		02/17/2023 Found and fix a few issues when data audit Soft Delete
--
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_ADMIN_DEPARTMENTS_SET]
		@LanguageID = N'en-US',
		@DepartmentID = NULL,
		@OrganizationID = 48120000000,
		@DefaultName = N'DEP199',
		@NationalName = N'DEP1100',
		@DepartmentNameTypeID = NULL,
		@AuditUserName = N'rykermase',
		@DataAuditEventID = NULL, 
		@EIDSSObjectID = NULL, 
		@RowAction = NULL - values are R for read, I for insert, U for update and D for delete.

SELECT	'Return Value' = @return_value
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_DEPARTMENTS_SET]
(
    @LanguageID NVARCHAR(50),
    @DepartmentID BIGINT = NULL,
    @DefaultName NVARCHAR(200),
    @NationalName NVARCHAR(200),
    @OrganizationID BIGINT,
    @DepartmentNameTypeID BIGINT,
    @Order INT = 0,
    @AuditUserName NVARCHAR(200) = NULL,
    @DataAuditEventID BIGINT = NULL,
    @EIDSSObjectID NVARCHAR(200),
    @RowStatus INT = 0
)
AS
BEGIN
    DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
            @ReturnCode INT = 0,
                                                                      -- Data audit
            @AuditUserID BIGINT = NULL,
            @AuditSiteID BIGINT = NULL,
            @CustomizationPackageID BIGINT,
            @ObjectTypeID BIGINT = 10017016,                          -- Department
            @ObjectID BIGINT = @DepartmentID,
            @ObjectTableID BIGINT = 50815890000000,                   -- tlbDepartment
            @ObjectBaseReferenceTableID BIGINT = 75820000000,         -- trtBaseReference
            @ObjectStringNameTranslationTableID BIGINT = 75990000000; -- trtStringNameTranslation

    DECLARE @DepartmentAfterEdit TABLE
    (
        DepartmentID BIGINT,
        DepartmentNameBaseReferenceID BIGINT,
        OrganizationID BIGINT
    );
    DECLARE @DepartmentBeforeEdit TABLE
    (
        DepartmentID BIGINT,
        DepartmentNameBaseReferenceID BIGINT,
        OrganizationID BIGINT
    );

    BEGIN TRY
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        IF @RowStatus = 1 -- Soft Delete
        BEGIN
            IF @DepartmentNameTypeID IS NULL
            BEGIN
                SELECT @DepartmentNameTypeID = idfsDepartmentName
                FROM dbo.tlbDepartment
                WHERE idfDepartment = @DepartmentID;
            END

            UPDATE dbo.tlbDepartment
            SET intRowStatus = @RowStatus,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfDepartment = @DepartmentID;

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailDelete
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   @DepartmentID,
                   @AuditUserName,
                   @EIDSSObjectID;
            -- End data audit

            UPDATE dbo.trtBaseReference
            SET intRowStatus = @RowStatus,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @DepartmentNameTypeID
                  AND intRowStatus = 0;

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailDelete
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectBaseReferenceTableID,
                   @DepartmentNameTypeID,
                   @AuditUserName,
                   @EIDSSObjectID;
            -- End data audit

            UPDATE dbo.trtStringNameTranslation
            SET intRowStatus = @RowStatus,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @DepartmentNameTypeID;

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailDelete
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectStringNameTranslationTableID,
                   @DepartmentNameTypeID,
                   @AuditUserName,
                   @EIDSSObjectID;
        -- End data audit
        END
        ELSE
        BEGIN
            IF
            (
                SELECT COUNT(b.idfsReference)
                FROM dbo.FN_GBL_ReferenceRepair_GET(@LanguageID, 19000164) b
                    INNER JOIN dbo.tlbDepartment d
                        ON d.idfsDepartmentName = b.idfsReference
                WHERE b.strDefault = @DefaultName
                      AND d.intRowStatus = 0
                      AND d.idfOrganization = @OrganizationID
                      AND (
                              (
                                  d.idfDepartment <> @DepartmentID
                                  AND @DepartmentID IS NOT NULL
                                  AND @DepartmentID > 0
                              ) -- Update
                              OR (
                                     @DepartmentID IS NULL
                                     OR @DepartmentID < 0
                                 )
                          ) -- Insert
            ) > 0
            BEGIN
                SELECT @ReturnMessage = 'DOES EXIST';
            END

            IF @ReturnMessage <> 'DOES EXIST'
            BEGIN
                IF @DepartmentID IS NULL
                   OR @DepartmentID < 0
                BEGIN
                    IF (UPPER(@LanguageID) = 'EN-US' AND ISNULL(@DefaultName, N'') = N'')
                    BEGIN
                        SET @DefaultName = @NationalName;
                    END

                    EXECUTE dbo.USSP_GBL_BASE_REFERENCE_SET @DepartmentNameTypeID OUTPUT,
                                                            19000164,
                                                            @LanguageID,
                                                            @DefaultName,
                                                            @NationalName,
                                                            0,
                                                            @Order,
                                                            0,
                                                            @AuditUserName,
                                                            @DataAuditEventID,
                                                            @EIDSSObjectID;

                    EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbDepartment', @DepartmentID OUTPUT;

                    INSERT INTO dbo.tlbDepartment
                    (
                        idfDepartment,
                        idfsDepartmentName,
                        idfOrganization,
                        strReservedAttribute,
                        intRowStatus,
                        rowguid,
                        SourceSystemNameID,
                        SourceSystemKeyValue,
                        AuditCreateUser,
                        AuditCreateDTM
                    )
                    VALUES
                    (@DepartmentID,
                     @DepartmentNameTypeID,
                     @OrganizationID,
                     dbo.FN_GBL_DATACHANGE_INFO(@AuditUserName),
                     0  ,
                     NEWID(),
                     10519001,
                     N'[{"idfDepartment":' + CAST(@DepartmentID AS NVARCHAR(300)) + '}]',
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
                     @DepartmentID,
                     10519001,
                     '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                     + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
                     @AuditUserName,
                     @EIDSSObjectID
                    );
                -- End data audit
                END
                ELSE
                BEGIN
                    SELECT @DepartmentNameTypeID =
                    (
                        SELECT idfsDepartmentName
                        FROM dbo.tlbDepartment
                        WHERE idfDepartment = @DepartmentID
                    );

                    EXECUTE dbo.USSP_GBL_BASE_REFERENCE_SET @DepartmentNameTypeID,
                                                            19000164,
                                                            @LanguageID,
                                                            @DefaultName,
                                                            @NationalName,
                                                            0,
                                                            @Order,
                                                            0,
                                                            @AuditUserName,
                                                            @DataAuditEventID,
                                                            @EIDSSObjectID;

                    -- Data audit
                    INSERT INTO @DepartmentBeforeEdit
                    (
                        DepartmentID,
                        DepartmentNameBaseReferenceID,
                        OrganizationID
                    )
                    SELECT idfDepartment,
                           idfsDepartmentName,
                           idfOrganization
                    FROM dbo.tlbDepartment
                    WHERE idfDepartment = @DepartmentID;
                    -- End data audit

                    UPDATE dbo.tlbDepartment
                    SET idfsDepartmentName = @DepartmentNameTypeID,
                        strReservedAttribute = dbo.FN_GBL_DATACHANGE_INFO(@AuditUserName),
                        AuditUpdateUser = @AuditUserName,
                        AuditUpdateDTM = GETDATE()
                    WHERE idfDepartment = @DepartmentID;

                    -- Data audit
                    INSERT INTO @DepartmentAfterEdit
                    (
                        DepartmentID,
                        DepartmentNameBaseReferenceID,
                        OrganizationID
                    )
                    SELECT idfDepartment,
                           idfsDepartmentName,
                           idfOrganization
                    FROM dbo.tlbDepartment
                    WHERE idfDepartment = @DepartmentID;

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
                           50815910000000,
                           a.DepartmentID,
                           NULL,
                           b.DepartmentNameBaseReferenceID,
                           a.DepartmentNameBaseReferenceID,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @DepartmentAfterEdit AS a
                        FULL JOIN @DepartmentBeforeEdit AS b
                            ON a.DepartmentID = b.DepartmentID
                    WHERE (a.DepartmentNameBaseReferenceID <> b.DepartmentNameBaseReferenceID)
                          OR (
                                 a.DepartmentNameBaseReferenceID IS NOT NULL
                                 AND b.DepartmentNameBaseReferenceID IS NULL
                             )
                          OR (
                                 a.DepartmentNameBaseReferenceID IS NULL
                                 AND b.DepartmentNameBaseReferenceID IS NOT NULL
                             );
                    -- End data audit
                END
            END
        END;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @DepartmentID KeyId,
               'DepartmentID' KeyName;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;
    END CATCH
END
