-- ================================================================================================
-- Name: USP_OMM_Contact_Set
-- Description: Inserts or updates an outbreak contact.
--          
-- Author: Doug Albanese
-- Revision History:
-- Name             Date		Change Detail
-- ----------------	----------	----------------------------------------------------------
-- Doug Albanese    05/29/2020	Correction to create copy of contact after it has been 
--								updated.
-- Stephen Long     05/02/2022	Updated parameters to use admin levels.
-- Stephen Long     06/05/2022	Added logic to handle convert to case status.
-- Stephen Long     06/23/2022	Added contact tracing observation identifier to the update.
-- Stephen Long     06/27/2022	Set classification type to Suspect on contact conversion.
-- Doug Albanese	08/15/2022	Changed OutbreakCaseContactId to CaseContactID
-- Doug Albanese	08/24/2022	Converted HumanId to HumanID, HumanMasterId to HumanMasterID, for 
--                              the json blob conversion to a table.
-- Doug Albanese	08/24/2022	Change the Case Status to "Convert To Case", when creating a new 
--                              case.
-- Stephen Long     09/20/2022  Made all identifiers use "ID".  Some fields were not saving 
--                              correctly with the case sensitivity.
-- Stephen Long     10/25/2022  Added farm master ID and case contact ID fields.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_Contact_Set]
(
    @Contacts NVARCHAR(MAX),
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ReturnCode INT = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
                @AddressID BIGINT = NULL,
                @ForeignAddressIndicator BIT = 0,
                @OutbreakID BIGINT = NULL,
                @HumanMasterID BIGINT = NULL,
                @HumanID BIGINT = NULL,
                @FarmMasterID BIGINT = NULL, 
                @CaseContactID BIGINT,
                @OutbreakCaseReportUID BIGINT = NULL,
                @ContactRelationshipTypeID BIGINT = NULL,
                @DateOfLastContact DATETIME = NULL,
                @LocationID BIGINT = NULL,
                @Street NVARCHAR(200) = NULL,
                @PostalCode NVARCHAR(200) = NULL,
                @Building NVARCHAR(200) = NULL,
                @House NVARCHAR(200) = NULL,
                @Apartment NVARCHAR(200) = NULL,
                @ForeignAddressString NVARCHAR(200) = NULL,
                @ContactPhone NVARCHAR(200) = NULL,
                @PlaceOfLastContact NVARCHAR(200) = NULL,
                @Comment NVARCHAR(500) = NULL,
                @ContactStatusID BIGINT = NULL,
                @RowStatus INT = 0,
                @ContactTracingObservationID BIGINT = NULL;

        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT NULL,
            ReturnMessage NVARCHAR(MAX) NULL
        );
        DECLARE @ContactsTemp TABLE
        (
            CaseContactID BIGINT NOT NULL,
            OutbreakCaseReportUID BIGINT NULL,
            ContactRelationshipTypeID BIGINT NULL,
            OutbreakID BIGINT NULL,
            HumanMasterID BIGINT NULL,
            HumanID BIGINT NULL,
            FarmMasterID BIGINT NULL, 
            DateOfLastContact DATETIME NULL,
            AddressID BIGINT NULL,
            LocationID BIGINT NULL,
            Street NVARCHAR(200) NULL,
            PostalCode NVARCHAR(200) NULL,
            Building NVARCHAR(200) NULL,
            House NVARCHAR(200) NULL,
            Apartment NVARCHAR(200) NULL,
            ForeignAddressString NVARCHAR(200) NULL,
            ContactPhone NVARCHAR(200) NULL,
            PlaceOfLastContact NVARCHAR(200) NULL,
            Comment NVARCHAR(500) NULL,
            ContactStatusID BIGINT NULL,
            ContactTracingObservationID BIGINT NULL,
            RowStatus INT NOT NULL
        );

        BEGIN TRANSACTION;

        INSERT INTO @ContactsTemp
        SELECT *
        FROM
            OPENJSON(@Contacts)
            WITH
            (
                CaseContactID BIGINT,
                OutbreakCaseReportUID BIGINT,
                ContactRelationshipTypeID BIGINT,
                OutbreakID BIGINT,
                HumanMasterID BIGINT,
                HumanID BIGINT,
                FarmMasterID BIGINT, 
                DateOfLastContact DATETIME2,
                AddressID BIGINT,
                LocationID BIGINT,
                Street NVARCHAR(200),
                PostalCode NVARCHAR(200),
                Building NVARCHAR(200),
                House NVARCHAR(200),
                Apartment NVARCHAR(200),
                ForeignAddressString NVARCHAR(200),
                ContactPhone NVARCHAR(200),
                PlaceOfLastContact NVARCHAR(200),
                Comment NVARCHAR(500),
                ContactStatusID BIGINT,
                ContactTracingObservationID BIGINT,
                RowStatus INT
            );

        WHILE EXISTS (SELECT * FROM @ContactsTemp)
        BEGIN
            SELECT TOP 1
                @CaseContactID = CaseContactID,
                @OutbreakCaseReportUID = OutbreakCaseReportUID,
                @ContactRelationshipTypeID = ContactRelationshipTypeID,
                @OutbreakID = OutbreakID,
                @HumanMasterID = HumanMasterID,
                @HumanID = HumanID,
                @FarmMasterID = FarmMasterID, 
                @DateOfLastContact = DateOfLastContact,
                @AddressID = AddressID,
                @LocationID = LocationID,
                @Street = Street,
                @PostalCode = PostalCode,
                @Building = Building,
                @House = House,
                @Apartment = Apartment,
                @ForeignAddressString = ForeignAddressString,
                @ContactPhone = ContactPhone,
                @PlaceOfLastContact = PlaceOfLastContact,
                @Comment = Comment,
                @ContactStatusID = ContactStatusID,
                @ContactTracingObservationID = ContactTracingObservationID,
                @RowStatus = RowStatus
            FROM @ContactsTemp;

            IF @ForeignAddressString IS NOT NULL
            BEGIN
                SET @ForeignAddressIndicator = 1;
            END

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_ADDRESS_SET @AddressID OUTPUT,
                                             NULL,
                                             NULL,
                                             NULL,
                                             @LocationID,
                                             @Apartment,
                                             @Building,
                                             @Street,
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
                                             0, --@blnGeoLocationShared
                                             @AuditUserName,
                                             @ReturnCode OUTPUT,
                                             @ReturnMessage OUTPUT;

            UPDATE dbo.OutbreakCaseContact
            SET ContactRelationshipTypeID = @ContactRelationshipTypeID,
                DateOfLastContact = @DateOfLastContact,
                PlaceOfLastContact = @PlaceOfLastContact,
                idfHuman = @HumanID,
                CommentText = @Comment,
                ContactStatusID = @ContactStatusID,
                ContactTracingObservationID = @ContactTracingObservationID, 
                intRowStatus = @RowStatus,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE OutbreakCaseContactUID = @CaseContactID;

            UPDATE dbo.tlbHuman
            SET idfCurrentResidenceAddress = @AddressID,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfHuman = @HumanID;

            UPDATE dbo.HumanAddlInfo
            SET ContactPhoneNbr = @ContactPhone,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE HumanAdditionalInfo = @HumanID;

            -- Convert to case, then create a human or veterinary case.
            IF @ContactStatusID = 10517002
            BEGIN
                --INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_OMM_CONVERT_CONTACT_Set @OutbreakID,
                                                         @CaseContactID, 
                                                         @HumanMasterID,
                                                         @HumanID, 
                                                         @FarmMasterID, 
                                                         @AddressID,
                                                         @LocationID,
                                                         @Street,
                                                         @Apartment,
                                                         @Building,
                                                         @House,
                                                         @PostalCode,
                                                         NULL,
                                                         NULL,
                                                         NULL,
                                                         10109001, -- In Process
														 --10517002, --Convert To Case
                                                         380000000, -- Suspect
                                                         @AuditUserName;
            END

            SET ROWCOUNT 1;
            DELETE FROM @ContactsTemp;
            SET ROWCOUNT 0;
        END;

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
