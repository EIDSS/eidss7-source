--=================================================================================================
-- Name: USP_ADMIN_ORG_SET
--
-- Description: Creates or updates an organization record.
--
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name             Date      Change
-- ---------------- --------- --------------------------------------------------------------------
-- Ricky Moss		07/12/2019 Restructured to set name and full name of organizations correctly.
-- Stephen Long     04/24/2021 Updated for location hierarchy and removed settlement type ID 
--                             parameter.
-- Stephen Long     06/14/2021 Removed latitude and longitude parameters as not needed in the use
--                             case.  Added departments list and table variable processing.
-- Stephen Long     06/17/2021 Added duplicate abbreviated and full name check as per special 
--                             requirement 1 on use SAUC05.
-- Stephen Long     06/30/2021 Removed english check on default and national name.
-- Stephen Long     08/05/2021 Added audit user name to address set.
-- Stephen Long     08/16/2021 Removal of associating a new organization to a default site ID.
--                             Association of an organization to a site will be done on the 
--                             site screen.
-- Stephen Long     09/01/2021 Changed department stored procedure call from USSP to USP to 
--                             reduce duplication of stored procedures doing the same logic.
-- Mark Wilson		10/06/2021 Added NULL Elevation parm to USP_GBL_ADDRESS_SET.
-- Stephen Long     10/29/2021 Changed from USP_GBL_ADDRESS_SET to USSP_GBL_ADDRESS_SET.
-- Stephen Long     12/13/2022 Added data audit logic for SAUC30 and 31.
-- Ann Xiong		02/17/2023 Found and fix the issue of INSERT INTO @OrganizationBeforeEdit twice.
-- Stephen Long     03/06/2023 Changed data audit call to USSP_GBL_DATA_AUDIT_EVENT_SET.
-- 
-- Testing Code:
--
-- EXEC USP_ADMIN_ORG_SET NULL, 'Test Org 821-12', 'Test Org 821-11', 'Test Organization 821-12', 
--	'Test Organization 821-12', '404-555-4567', NULL, 226,  'TO821-12', 'en', 0,  NULL, 780000000, 
--	37130000000, 3724300000000, NULL, NULL, '2345', NULL, 'Main St', NULL, NULL, 0, NULL, NULL, 1, 
--	10504001, NULL, NULL, NULL
-- EXEC USP_ADMIN_ORG_SET 52448330000054, 'Test Org 71-3', 'Test Org 71-3', 'Test Organization 71-3', 
--	'Test Organization 71-3', '404-555-4567', NULL, 226,  'TO71-1', 'en', 0,  NULL, 780000000, 
--	37130000000, 3724300000000, 1343040000000, NULL, '2345', NULL, 'Main St', NULL, NULL, 0, NULL, 
--	NULL, 1, 10504001, NULL, NULL, NULL
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_ORG_SET]
(
    @LanguageID NVARCHAR(50),
    @OrganizationKey BIGINT = NULL,
    @OrganizationID NVARCHAR(100),
    @OrganizationTypeID BIGINT = NULL,
    @AbbreviatedNameDefaultValue NVARCHAR(200),
    @AbbreviatedNameNationalValue NVARCHAR(200),
    @FullNameDefaultValue NVARCHAR(200),
    @FullNameNationalValue NVARCHAR(200),
    @CurrentCustomizationID BIGINT = NULL,
    @AddressID BIGINT = NULL,
    @LocationID BIGINT,
    @StreetName NVARCHAR(200) = NULL,
    @Apartment NVARCHAR(200) = NULL,
    @Building NVARCHAR(200) = NULL,
    @House NVARCHAR(200) = NULL,
    @PostalCode NVARCHAR(200) = NULL,
    @ForeignAddressIndicator BIT = 0,
    @ForeignAddressString NVARCHAR(200) = NULL,
    @SharedAddressIndicator BIT = 1,
    @ContactPhone NVARCHAR(200) = NULL,
    @AccessoryCode INT,
    @Order INT,
    @OwnershipFormTypeID BIGINT = NULL,
    @LegalFormTypeID BIGINT = NULL,
    @MainFormOfActivityTypeID BIGINT = NULL,
    @AuditUserName NVARCHAR(200),
    @Departments NVARCHAR(MAX) = NULL
)
AS
DECLARE @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @RowID BIGINT = NULL,
        @RowAction CHAR(1) = NULL,
        @RowStatus INT = 0,
        @DepartmentID BIGINT = NULL,
        @DefaultValue NVARCHAR(200) = NULL,
        @NationalValue NVARCHAR(200) = NULL,
        @DepartmentOrder INT = 0,
                                             -- Data audit
        @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectTypeID BIGINT = 10017034,     -- Organization
        @ObjectID BIGINT = @OrganizationKey,
        @ObjectTableID BIGINT = 75650000000; -- tlbOffice
DECLARE @DepartmentsTemp TABLE
(
    DepartmentID BIGINT NOT NULL,
    DepartmentNameDefaultValue NVARCHAR(200) NULL,
    DepartmentNameNationalValue NVARCHAR(200) NULL,
    OrderNumber INT NOT NULL,
    RowStatus INT NOT NULL,
    RowAction CHAR(1)
);
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage VARCHAR(200)
);
DECLARE @SuppressDepartmentSelect TABLE
(
    ReturnCode INT,
    ReturnMessage VARCHAR(200),
    KeyId BIGINT NULL,
    KeyName VARCHAR(MAX)
);
DECLARE @OrganizationAfterEdit TABLE
(
    OrganizationID BIGINT,
    OrganizationFullNameID BIGINT,
    OrganizjationAbbreviationNameID BIGINT,
    CustomizationPackageID BIGINT,
    LocationID BIGINT,
    ContactPhone NVARCHAR(200),
    AccessoryCode INT,
    EIDSSOrganizationID NVARCHAR(100),
    OrganizationTypeID BIGINT,
    OwnershipFormID BIGINT,
    LegalFormID BIGINT,
    MainFormOfActivityID BIGINT
);
DECLARE @OrganizationBeforeEdit TABLE
(
    OrganizationID BIGINT,
    OrganizationFullNameID BIGINT,
    OrganizjationAbbreviationNameID BIGINT,
    CustomizationPackageID BIGINT,
    LocationID BIGINT,
    ContactPhone NVARCHAR(200),
    AccessoryCode INT,
    EIDSSOrganizationID NVARCHAR(100),
    OrganizationTypeID BIGINT,
    OwnershipFormID BIGINT,
    LegalFormID BIGINT,
    MainFormOfActivityID BIGINT
);
BEGIN
    BEGIN TRY
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        IF (
               ISNULL(@OrganizationID, N'') <> N''
               AND EXISTS
        (
            SELECT idfOffice
            FROM dbo.tlbOffice
            WHERE strOrganizationID = @OrganizationID
                  AND intRowStatus = 0
        )
               AND @OrganizationKey IS NULL
           )
           OR (
                  ISNULL(@OrganizationID, N'') <> N''
                  AND EXISTS
        (
            SELECT idfOffice
            FROM dbo.tlbOffice
            WHERE strOrganizationID = @OrganizationID
                  AND idfOffice <> @OrganizationKey
                  AND intRowStatus = 0
        )
                  AND @OrganizationKey IS NOT NULL
              )
        BEGIN
            SELECT @ReturnMessage = 'ID DOES EXIST';

            SELECT @ReturnCode = 1;

            SELECT @OrganizationKey = NULL;
        END

        IF @ReturnCode = 0
           AND (
                   ISNULL(@AbbreviatedNameDefaultValue, N'') <> N''
                   AND
                   (
                       SELECT COUNT(*)
                       FROM dbo.trtBaseReference
                       WHERE strDefault = @AbbreviatedNameDefaultValue
                             AND idfsReferenceType = 19000045
                             AND intRowStatus = 0
                             AND @OrganizationKey IS NULL
                             AND @OrganizationID IS NULL
                   ) > 0 -- use 0 in this scenario as the record is brand new
                   OR
                   (
                       SELECT COUNT(*)
                       FROM dbo.trtBaseReference
                       WHERE strDefault = @AbbreviatedNameDefaultValue
                             AND idfsReferenceType = 19000045
                             AND intRowStatus = 0
                             AND @OrganizationKey IS NOT NULL
                             AND @OrganizationID IS NULL
                   ) > 1 -- use 1 in this scenario to not count a duplicate against itself
               )
           AND (
                   ISNULL(@FullNameDefaultValue, N'') <> N''
                   AND
                   (
                       SELECT COUNT(*)
                       FROM dbo.trtBaseReference
                       WHERE strDefault = @FullNameDefaultValue
                             AND idfsReferenceType = 19000046
                             AND intRowStatus = 0
                             AND @OrganizationKey IS NULL
                             AND @OrganizationID IS NULL
                   ) > 0 -- use 0 in this scenario as the record is brand new
                   OR
                   (
                       SELECT COUNT(*)
                       FROM dbo.trtBaseReference
                       WHERE strDefault = @FullNameDefaultValue
                             AND idfsReferenceType = 19000046
                             AND intRowStatus = 0
                             AND @OrganizationKey IS NOT NULL
                             AND @OrganizationID IS NULL
                   ) > 1 -- use 1 in this scenario to not count a duplicate against itself
               )
        BEGIN
            SELECT @ReturnMessage = 'NAME DOES EXIST';

            SELECT @ReturnCode = 2;

            SELECT @OrganizationKey = NULL;
        END

        IF @ReturnCode = 0
        BEGIN
            SET NOCOUNT ON;

            BEGIN TRANSACTION;

            IF @OrganizationKey IS NULL
            BEGIN
                -- Data audit
                SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                          @AuditSiteID,
                                                          @DataAuditEventTypeID,
                                                          @ObjectTypeID,
                                                          @OrganizationKey,
                                                          @ObjectTableID,
                                                          @OrganizationID,
                                                          @DataAuditEventID OUTPUT;
            -- End data audit
            END
            ELSE
            BEGIN
                -- Data audit
                SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                          @AuditSiteID,
                                                          @DataAuditEventTypeID,
                                                          @ObjectTypeID,
                                                          @OrganizationKey,
                                                          @ObjectTableID,
                                                          @OrganizationID,
                                                          @DataAuditEventID OUTPUT;
            END

            INSERT INTO @DepartmentsTemp
            SELECT *
            FROM
                OPENJSON(@Departments)
                WITH
                (
                    DepartmentID BIGINT,
                    DepartmentNameDefaultValue NVARCHAR(200),
                    DepartmentNameNationalValue NVARCHAR(200),
                    OrderNumber INT,
                    RowStatus INT,
                    RowAction CHAR(1)
                );

            DECLARE @OrganizationFullNameID BIGINT,
                    @OrganizationAbbreviatedNameID BIGINT;

            SELECT @OrganizationFullNameID = idfsOfficeName,
                   @OrganizationAbbreviatedNameID = idfsOfficeAbbreviation
            FROM dbo.tlbOffice
            WHERE idfOffice = @OrganizationKey;

            IF NOT EXISTS
            (
                SELECT idfsOfficeName
                FROM dbo.tlbOffice
                WHERE idfOffice = @OrganizationKey
            )
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_GBL_BASE_REFERENCE_SET @OrganizationFullNameID OUTPUT,
                                                        19000046,
                                                        @LanguageID,
                                                        @FullNameDefaultValue,
                                                        @FullNameNationalValue,
                                                        0,
                                                        @Order,
                                                        0,
                                                        @AuditUserName,
                                                        @DataAuditEventID,
                                                        @OrganizationID;
            END
            ELSE
            BEGIN
                SELECT @OrganizationFullNameID =
                (
                    SELECT idfsOfficeName
                    FROM dbo.tlbOffice
                    WHERE idfOffice = @OrganizationKey
                );

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_GBL_BASE_REFERENCE_SET @OrganizationFullNameID OUTPUT,
                                                        19000046,
                                                        @LanguageID,
                                                        @FullNameDefaultValue,
                                                        @FullNameNationalValue,
                                                        0,
                                                        @Order,
                                                        0,
                                                        @AuditUserName,
                                                        @DataAuditEventID,
                                                        @OrganizationID;
            END

            IF NOT EXISTS
            (
                SELECT idfsOfficeAbbreviation
                FROM dbo.tlbOffice
                WHERE idfOffice = @OrganizationKey
            )
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_GBL_BASE_REFERENCE_SET @OrganizationAbbreviatedNameID OUTPUT,
                                                        19000045,
                                                        @LanguageID,
                                                        @AbbreviatedNameDefaultValue,
                                                        @AbbreviatedNameNationalValue,
                                                        0,
                                                        @Order,
                                                        0,
                                                        @AuditUserName,
                                                        @DataAuditEventID,
                                                        @OrganizationID;
            END
            ELSE
            BEGIN
                SELECT @OrganizationAbbreviatedNameID =
                (
                    SELECT idfsOfficeAbbreviation
                    FROM dbo.tlbOffice
                    WHERE idfOffice = @OrganizationKey
                );

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_GBL_BASE_REFERENCE_SET @OrganizationAbbreviatedNameID OUTPUT,
                                                        19000045,
                                                        @LanguageID,
                                                        @AbbreviatedNameDefaultValue,
                                                        @AbbreviatedNameNationalValue,
                                                        0,
                                                        @Order,
                                                        0,
                                                        @AuditUserName,
                                                        @DataAuditEventID,
                                                        @OrganizationID;
            END

            IF @CurrentCustomizationID IS NULL
            BEGIN
                SET @CurrentCustomizationID = dbo.FN_GBL_CustomizationPackage_GET();
            END

            -- Set the address including potentially the street and postal code tables. 
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_ADDRESS_SET_WITH_AUDITING @AddressID OUTPUT,
                                                           @DataAuditEventID,
                                                           NULL,
                                                           NULL,
                                                           NULL,
                                                           @LocationID,
                                                           @Apartment,
                                                           @Building,
                                                           @StreetName,
                                                           @House,
                                                           @PostalCode,
                                                           NULL,
                                                           NULL,
                                                           NULL,
                                                           NULL,
                                                           NULL,
                                                           NULL,
                                                           NULL,
                                                           @ForeignAddressIndicator,
                                                           @ForeignAddressString,
                                                           @SharedAddressIndicator,
                                                           @AuditUserName;

            IF @OrganizationKey IS NULL
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbOffice', @OrganizationKey OUTPUT;

                INSERT INTO dbo.tlbOffice
                (
                    idfOffice,
                    idfsOfficeName,
                    idfsOfficeAbbreviation,
                    idfCustomizationPackage,
                    idfLocation,
                    idfsSite,
                    strContactPhone,
                    intHACode,
                    strOrganizationID,
                    OrganizationTypeID,
                    OwnershipFormID,
                    MainFormOfActivityID,
                    LegalFormID,
                    AuditCreateUser
                )
                VALUES
                (   @OrganizationKey,
                    @OrganizationFullNameID,
                    @OrganizationAbbreviatedNameID,
                    @CurrentCustomizationID,
                    @AddressID,
                    NULL, -- Site ID will be updated on the site screen/site set stored procedure.
                    @ContactPhone,
                    @AccessoryCode,
                    @OrganizationID,
                    @OrganizationTypeID,
                    @OwnershipFormTypeID,
                    @MainFormOfActivityTypeID,
                    @LegalFormTypeID,
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
                 @ObjectTableID,
                 @OrganizationKey,
                 10519001,
                 '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                 + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 @OrganizationID
                );
            -- End data audit
            END
            ELSE
            BEGIN
                -- Data audit
                INSERT INTO @OrganizationBeforeEdit
                (
                    OrganizationID,
                    OrganizationFullNameID,
                    OrganizjationAbbreviationNameID,
                    CustomizationPackageID,
                    LocationID,
                    ContactPhone,
                    AccessoryCode,
                    EIDSSOrganizationID,
                    OrganizationTypeID,
                    OwnershipFormID,
                    LegalFormID,
                    MainFormOfActivityID
                )
                SELECT idfOffice,
                       idfsOfficeName,
                       idfsOfficeAbbreviation,
                       idfCustomizationPackage,
                       idfLocation,
                       strContactPhone,
                       intHACode,
                       strOrganizationID,
                       OrganizationTypeID,
                       OwnershipFormID,
                       LegalFormID,
                       MainFormOfActivityID
                FROM dbo.tlbOffice
                WHERE idfOffice = @OrganizationKey;
                -- End data audit

                UPDATE dbo.tlbOffice
                SET strContactPhone = @ContactPhone,
                    idfLocation = @AddressID,
                    intHACode = @AccessoryCode,
                    strOrganizationID = @OrganizationID,
                    OrganizationTypeID = @OrganizationTypeID,
                    OwnershipFormID = @OwnershipFormTypeID,
                    LegalFormID = @LegalFormTypeID,
                    MainFormOfActivityID = @MainFormofActivityTypeID,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfOffice = @OrganizationKey;

                -- Data audit
                INSERT INTO @OrganizationAfterEdit
                (
                    OrganizationID,
                    OrganizationFullNameID,
                    OrganizjationAbbreviationNameID,
                    CustomizationPackageID,
                    LocationID,
                    ContactPhone,
                    AccessoryCode,
                    EIDSSOrganizationID,
                    OrganizationTypeID,
                    OwnershipFormID,
                    LegalFormID,
                    MainFormOfActivityID
                )
                SELECT idfOffice,
                       idfsOfficeName,
                       idfsOfficeAbbreviation,
                       idfCustomizationPackage,
                       idfLocation,
                       strContactPhone,
                       intHACode,
                       strOrganizationID,
                       OrganizationTypeID,
                       OwnershipFormID,
                       LegalFormID,
                       MainFormOfActivityID
                FROM dbo.tlbOffice
                WHERE idfOffice = @OrganizationKey;

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
                       80120000000,
                       a.OrganizationID,
                       NULL,
                       b.OrganizationFullNameID,
                       a.OrganizationFullNameID,
                       @AuditUserName,
                       @OrganizationID
                FROM @OrganizationAfterEdit AS a
                    FULL JOIN @OrganizationBeforeEdit AS b
                        ON a.OrganizationID = b.OrganizationID
                WHERE (a.OrganizationFullNameID <> b.OrganizationFullNameID)
                      OR (
                             a.OrganizationFullNameID IS NOT NULL
                             AND b.OrganizationFullNameID IS NULL
                         )
                      OR (
                             a.OrganizationFullNameID IS NULL
                             AND b.OrganizationFullNameID IS NOT NULL
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
                       80110000000,
                       a.OrganizationID,
                       NULL,
                       b.OrganizjationAbbreviationNameID,
                       a.OrganizjationAbbreviationNameID,
                       @AuditUserName,
                       @OrganizationID
                FROM @OrganizationAfterEdit AS a
                    FULL JOIN @OrganizationBeforeEdit AS b
                        ON a.OrganizationID = b.OrganizationID
                WHERE (a.OrganizjationAbbreviationNameID <> b.OrganizjationAbbreviationNameID)
                      OR (
                             a.OrganizjationAbbreviationNameID IS NOT NULL
                             AND b.OrganizjationAbbreviationNameID IS NULL
                         )
                      OR (
                             a.OrganizjationAbbreviationNameID IS NULL
                             AND b.OrganizjationAbbreviationNameID IS NOT NULL
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
                       51577490000000,
                       a.OrganizationID,
                       NULL,
                       b.CustomizationPackageID,
                       a.CustomizationPackageID,
                       @AuditUserName,
                       @OrganizationID
                FROM @OrganizationAfterEdit AS a
                    FULL JOIN @OrganizationBeforeEdit AS b
                        ON a.OrganizationID = b.OrganizationID
                WHERE (a.CustomizationPackageID <> b.CustomizationPackageID)
                      OR (
                             a.CustomizationPackageID IS NOT NULL
                             AND b.CustomizationPackageID IS NULL
                         )
                      OR (
                             a.CustomizationPackageID IS NULL
                             AND b.CustomizationPackageID IS NOT NULL
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
                       4577920000000,
                       a.OrganizationID,
                       NULL,
                       b.LocationID,
                       a.LocationID,
                       @AuditUserName,
                       @OrganizationID
                FROM @OrganizationAfterEdit AS a
                    FULL JOIN @OrganizationBeforeEdit AS b
                        ON a.OrganizationID = b.OrganizationID
                WHERE (a.LocationID <> b.LocationID)
                      OR (
                             a.LocationID IS NOT NULL
                             AND b.LocationID IS NULL
                         )
                      OR (
                             a.LocationID IS NULL
                             AND b.LocationID IS NOT NULL
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
                       80150000000,
                       a.OrganizationID,
                       NULL,
                       b.ContactPhone,
                       a.ContactPhone,
                       @AuditUserName,
                       @OrganizationID
                FROM @OrganizationAfterEdit AS a
                    FULL JOIN @OrganizationBeforeEdit AS b
                        ON a.OrganizationID = b.OrganizationID
                WHERE (a.ContactPhone <> b.ContactPhone)
                      OR (
                             a.ContactPhone IS NOT NULL
                             AND b.ContactPhone IS NULL
                         )
                      OR (
                             a.ContactPhone IS NULL
                             AND b.ContactPhone IS NOT NULL
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
                       50815930000000,
                       a.OrganizationID,
                       NULL,
                       b.AccessoryCode,
                       a.AccessoryCode,
                       @AuditUserName,
                       @OrganizationID
                FROM @OrganizationAfterEdit AS a
                    FULL JOIN @OrganizationBeforeEdit AS b
                        ON a.OrganizationID = b.OrganizationID
                WHERE (a.AccessoryCode <> b.AccessoryCode)
                      OR (
                             a.AccessoryCode IS NOT NULL
                             AND b.AccessoryCode IS NULL
                         )
                      OR (
                             a.AccessoryCode IS NULL
                             AND b.AccessoryCode IS NOT NULL
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
                       51523430000000,
                       a.OrganizationID,
                       NULL,
                       b.EIDSSOrganizationID,
                       a.EIDSSOrganizationID,
                       @AuditUserName,
                       @OrganizationID
                FROM @OrganizationAfterEdit AS a
                    FULL JOIN @OrganizationBeforeEdit AS b
                        ON a.OrganizationID = b.OrganizationID
                WHERE (a.EIDSSOrganizationID <> b.EIDSSOrganizationID)
                      OR (
                             a.EIDSSOrganizationID IS NOT NULL
                             AND b.EIDSSOrganizationID IS NULL
                         )
                      OR (
                             a.EIDSSOrganizationID IS NULL
                             AND b.EIDSSOrganizationID IS NOT NULL
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
                       51586990000045,
                       a.OrganizationID,
                       NULL,
                       b.OrganizationTypeID,
                       a.OrganizationTypeID,
                       @AuditUserName,
                       @OrganizationID
                FROM @OrganizationAfterEdit AS a
                    FULL JOIN @OrganizationBeforeEdit AS b
                        ON a.OrganizationID = b.OrganizationID
                WHERE (a.OrganizationTypeID <> b.OrganizationTypeID)
                      OR (
                             a.OrganizationTypeID IS NOT NULL
                             AND b.OrganizationTypeID IS NULL
                         )
                      OR (
                             a.OrganizationTypeID IS NULL
                             AND b.OrganizationTypeID IS NOT NULL
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
                       51586990000046,
                       a.OrganizationID,
                       NULL,
                       b.OwnershipFormID,
                       a.OwnershipFormID,
                       @AuditUserName,
                       @OrganizationID
                FROM @OrganizationAfterEdit AS a
                    FULL JOIN @OrganizationBeforeEdit AS b
                        ON a.OrganizationID = b.OrganizationID
                WHERE (a.OwnershipFormID <> b.OwnershipFormID)
                      OR (
                             a.OwnershipFormID IS NOT NULL
                             AND b.OwnershipFormID IS NULL
                         )
                      OR (
                             a.OwnershipFormID IS NULL
                             AND b.OwnershipFormID IS NOT NULL
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
                       51586990000047,
                       a.OrganizationID,
                       NULL,
                       b.LegalFormID,
                       a.LegalFormID,
                       @AuditUserName,
                       @OrganizationID
                FROM @OrganizationAfterEdit AS a
                    FULL JOIN @OrganizationBeforeEdit AS b
                        ON a.OrganizationID = b.OrganizationID
                WHERE (a.LegalFormID <> b.LegalFormID)
                      OR (
                             a.LegalFormID IS NOT NULL
                             AND b.LegalFormID IS NULL
                         )
                      OR (
                             a.LegalFormID IS NULL
                             AND b.LegalFormID IS NOT NULL
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
                       51586990000048,
                       a.OrganizationID,
                       NULL,
                       b.MainFormOfActivityID,
                       a.MainFormOfActivityID,
                       @AuditUserName,
                       @OrganizationID
                FROM @OrganizationAfterEdit AS a
                    FULL JOIN @OrganizationBeforeEdit AS b
                        ON a.OrganizationID = b.OrganizationID
                WHERE (a.MainFormOfActivityID <> b.MainFormOfActivityID)
                      OR (
                             a.MainFormOfActivityID IS NOT NULL
                             AND b.MainFormOfActivityID IS NULL
                         )
                      OR (
                             a.MainFormOfActivityID IS NULL
                             AND b.MainFormOfActivityID IS NOT NULL
                         );
            -- End data audit
            END

            WHILE EXISTS (SELECT * FROM @DepartmentsTemp)
            BEGIN
                SELECT TOP 1
                    @RowID = DepartmentID,
                    @DepartmentID = DepartmentID,
                    @DefaultValue = DepartmentNameDefaultValue,
                    @NationalValue = DepartmentNameNationalValue,
                    @DepartmentOrder = OrderNumber,
                    @RowStatus = RowStatus
                FROM @DepartmentsTemp
                ORDER BY RowStatus DESC,
                         DepartmentID;

                INSERT INTO @SuppressDepartmentSelect
                EXECUTE dbo.USP_ADMIN_DEPARTMENTS_SET @LanguageID,
                                                      @DepartmentID,
                                                      @DefaultValue,
                                                      @NationalValue,
                                                      @OrganizationKey,
                                                      NULL,
                                                      @DepartmentOrder,
                                                      @AuditUserName,
                                                      @DataAuditEventID,
                                                      @OrganizationID,
                                                      @RowStatus;

                SET @ReturnMessage =
                (
                    SELECT MAX(ReturnMessage) FROM @SuppressDepartmentSelect
                );

                IF @ReturnMessage = 'DOES EXIST'
                BEGIN
                    SET @ReturnMessage = 'DEPARTMENT DEFAULT VALUE DOES EXISTS,' + @DefaultValue;
                    SET @ReturnCode = 3;

                    DELETE FROM @DepartmentsTemp;
                END
                ELSE
                BEGIN
                    DELETE FROM @DepartmentsTemp
                    WHERE DepartmentID = @RowID;
                END
            END;

            IF @@TRANCOUNT > 0
                COMMIT;
        END

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @OrganizationKey KeyId,
               'OrganizationKey' KeyName,
               @AddressID AdditionalKeyId,
               'AddressID' AdditionalKeyName;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;
    END CATCH
END
