-- ================================================================================================
-- Name: USSP_OMM_CONTACT_SET
--
-- Description: Adds or updates outbreak contacts.
--          
-- Author: Doug Albanese
--
-- Revision History:
-- Name                Date		Change Detail
-- ------------------	----------	-----------------------------------------------------------
-- Doug Albanese		08/07/2019	Initial release 
-- Stephen Long        04/12/2022	Cleaned up formatting, and updated Source fields.
-- Doug Albanese		04/30/2022	Corrected case senstive characters for the JSON blob for 
--                                  contact information.
-- Stephen Long         06/06/2022  Corrected casing on Human Master ID to Human Master Id.
-- Stephen Long         06/23/2022  Corrected name of tracing observation ID to match JSON.
-- Stephen Long         06/27/2022  Changed insert from 0 to 1 to match app enumeration.
-- Doug Albanese		08/12/2022	Case Sensitivity changes for "Id" to "ID", so that the JSON 
--                                  data can be picked up
-- Doug Albanese		08/12/2022	Changed OutbreakCaseContactID to CaseContactID, to keep 
--                                  consistent between Vet Case and Human Case
-- Stephen Long         09/20/2022  Made all identifiers use "ID".  Some fields were not saving 
--                                  correctly with the case sensitivity.
-- Stephen Long         10/25/2022  Added logic to add a farm copy when creating a veterinary 
--                                  case contact.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_OMM_CONTACT_SET]
(
    @HumanDiseaseReportId BIGINT = NULL,
    @ContactsParameters NVARCHAR(MAX) = NULL,
    @User NVARCHAR(200) = NULL,
    @OutBreakCaseReportUID BIGINT = NULL,
    @FunctionCall INT = 0
)
AS
BEGIN
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage VARCHAR(200)
    );

    DECLARE @ContactedHumanCasePersonID BIGINT = NULL,
            @ContactTypeID BIGINT = NULL,
            @HumanMasterID BIGINT = NULL,
            @HumanID BIGINT = NULL,
			@FarmMasterID BIGINT = NULL, 
            @DateOfLastContact DATETIME2 = NULL,
            @PlaceOfLastContact NVARCHAR(200) = NULL,
            @Comments NVARCHAR(200) = NULL,
            @ContactRelationshipTypeID BIGINT = NULL,
            @ContactStatusTypeID BIGINT = NULL,
            @RowStatus INT = NULL,
            @RowAction INT = NULL,
            @OutbreakCaseContactUID BIGINT = NULL,
            @TracingObservationID BIGINT = NULL,
            @ReturnMessage NVARCHAR(MAX) = 'Success',
            @ReturnCode BIGINT = 0;
			
    DECLARE @ContactsTemp TABLE
    (
        ContactedHumanCasePersonID BIGINT NULL,
        ContactTypeID BIGINT NULL,
        HumanMasterID BIGINT NULL,
		HumanID BIGINT NULL, 
		FarmMasterID BIGINT NULL, 
        DateOfLastContact DATETIME2 NULL,
        PlaceOfLastContact NVARCHAR(200),
		RowStatus INT NULL,
		RowAction INT NULL,
		Comment NVARCHAR(200),
		ContactTracingObservationID BIGINT NULL,
		ContactRelationshipTypeID BIGINT NULL,
		ContactStatusID BIGINT NULL,
		CaseContactID BIGINT NULL
    );
	
    INSERT INTO @ContactsTemp
    SELECT *
    FROM
        OPENJSON(@ContactsParameters)
        WITH
        (
            ContactedHumanCasePersonID BIGINT,
            ContactTypeID BIGINT,
            HumanMasterID BIGINT,
			HumanID BIGINT, 
			FarmMasterID BIGINT, 
			DateOfLastContact DATETIME2,
            PlaceOfLastContact NVARCHAR(200),
			RowStatus INT,
			RowAction INT,
            Comment NVARCHAR(200),
			ContactTracingObservationID BIGINT,
			ContactRelationshipTypeID BIGINT,
			ContactStatusID BIGINT,
			CaseContactID BIGINT
        );
	
	BEGIN TRY
        WHILE EXISTS (SELECT * FROM @ContactsTemp)
        BEGIN
            SELECT TOP 1
                @ContactedHumanCasePersonID = ContactedHumanCasePersonID,
                @ContactTypeID = ContactTypeID,
                @HumanMasterID = HumanMasterID,
				@HumanID = HumanID, 
				@FarmMasterID = FarmMasterID, 
                @DateOfLastContact = DateOfLastContact,
                @PlaceOfLastContact = PlaceOfLastContact,
                @Comments = Comment,
                @ContactRelationshipTypeID = ContactRelationshipTypeID,
                @ContactStatusTypeID = ContactStatusID,
                @RowStatus = RowStatus,
                @RowAction = RowAction,
                @OutbreakCaseContactUID = CaseContactID,
                @TracingObservationID = ContactTracingObservationID
            FROM @ContactsTemp;

			IF @RowAction = 1 --Insert
			BEGIN
	            IF @FarmMasterID IS NULL
				BEGIN
				    INSERT INTO @SuppressSelect
                    EXECUTE dbo.USP_HUM_COPYHUMANACTUALTOHUMAN @HumanMasterID,
                                                               @HumanID OUTPUT,
                                                               @ReturnCode OUTPUT,
                                                               @ReturnMessage OUTPUT;
				END
				ELSE
				BEGIN
				    DECLARE @FarmID BIGINT;
				    INSERT INTO @SuppressSelect
                    EXECUTE dbo.USSP_VET_FARM_COPY @User,
                                                   @FarmMasterID,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   @HumanMasterID,
                                                   @FarmID OUTPUT,
                                                   @HumanID OUTPUT;
				END
			END;
				
            IF @HumanDiseaseReportId IS NOT NULL
            BEGIN
                IF NOT EXISTS
                (
                    SELECT idfContactedCasePerson
                    FROM dbo.tlbContactedCasePerson
                    WHERE idfContactedCasePerson = @ContactedHumanCasePersonID
                          AND intRowStatus = 0
                )
					BEGIN
						IF @FunctionCall = 0
							BEGIN
								EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbContactedCasePerson', @ContactedHumanCasePersonID OUTPUT;
							END
						ELSE
							BEGIN
								INSERT INTO @SuppressSelect
								EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbContactedCasePerson', @ContactedHumanCasePersonID OUTPUT;
							END
							
						INSERT INTO dbo.tlbContactedCasePerson
						(
							idfContactedCasePerson,
							idfsPersonContactType,
							idfHuman,
							idfHumanCase,
							datDateOfLastContact,
							strPlaceInfo,
							intRowStatus,
							strComments,
							SourceSystemKeyValue,
							SourceSystemNameID,
							AuditCreateUser,
							AuditCreateDTM
						)
						VALUES
						(
							@ContactedHumanCasePersonID,
							@ContactTypeID,
							@HumanID,
							@HumanDiseaseReportID,
							@DateOfLastContact,
							@PlaceOfLastContact,
							@RowStatus,
							@Comments,
							'[{"idfContactedCasePerson":' + CAST(@ContactedHumanCasePersonID AS NVARCHAR(300)) + '}]',
							10519001,
							@User,
							GETDATE()
						)
					END
                ELSE
					BEGIN
						IF @RowAction = 3 -- Delete
						BEGIN
							SET @RowStatus = 1
						END
						ELSE
						BEGIN
							SET @RowStatus = 0
						END

						UPDATE dbo.tlbContactedCasePerson
						SET idfsPersonContactType = @ContactTypeID,
							idfHuman = @HumanID,
							idfHumanCase = @HumanDiseaseReportID,
							datDateOfLastContact = @DateOfLastContact,
							strPlaceInfo = @PlaceOfLastContact,
							intRowStatus = @RowStatus,
							rowguid = NEWID(),
							strComments = @Comments,
							strMaintenanceFlag = '',
							strReservedAttribute = '',
							AuditUpdateUser = @User,
							AuditCreateDTM = GETDATE()
						WHERE idfContactedCasePerson = @ContactedHumanCasePersonID
							  AND intRowStatus = 0;
					END
            END
			
            IF NOT EXISTS
            (
                SELECT OutbreakCaseContactUID
                FROM dbo.OutbreakCaseContact
                WHERE OutbreakCaseContactUID = @OutbreakCaseContactUID
                      AND intRowStatus = 0
            )
            BEGIN
                IF @FunctionCall = 0
					BEGIN
						EXEC dbo.USP_GBL_NEXTKEYID_GET 'OutbreakCaseContact',
													   @OutbreakCaseContactUID OUTPUT;
					END
                ELSE
					BEGIN
						INSERT INTO @SuppressSelect
						EXEC dbo.USP_GBL_NEXTKEYID_GET 'OutbreakCaseContact',
													   @OutbreakCaseContactUID OUTPUT;
					END

					INSERT INTO OutbreakCaseContact
					(
						OutbreakCaseContactUID,
						OutbreakCaseReportUID,
						ContactTypeID,
						ContactedHumanCasePersonID,
						idfHuman,
						ContactRelationshipTypeID,
						DateOfLastContact,
						PlaceOfLastContact,
						CommentText,
						ContactStatusID,
						ContactTracingObservationID,
						intRowStatus,
						SourceSystemNameID,
						SourceSystemKeyValue,
						AuditCreateUser,
						AuditCreateDTM
					)
					VALUES
					(
						@OutbreakCaseContactUID,
						@OutBreakCaseReportUID,
						@ContactTypeID,
						@ContactedHumanCasePersonID,
						@HumanID,
						@ContactRelationshipTypeID,
						@DateOfLastContact,
						@PlaceOfLastContact,
						@Comments,
						@ContactStatusTypeID,
						@TracingObservationID,
						@RowStatus,
						10519001,
						'[{"OutbreakCaseContactUID":' + CAST(@OutbreakCaseContactUID AS NVARCHAR(300)) + '}]',
						@User,
						GETDATE()
					);
				END
            ELSE
				BEGIN
					IF @RowAction = 3 -- Delete
					BEGIN
						SET @RowStatus = 1;
					END
					ELSE
					BEGIN
						SET @RowStatus = 0;
					END

					UPDATE dbo.OutbreakCaseContact
					SET ContactTypeID = @ContactTypeID,
						ContactRelationshipTypeID = @ContactRelationshipTypeID,
						DateOfLastContact = @DateOfLastContact,
						PlaceOfLastContact = @PlaceOfLastContact,
						CommentText = @Comments,
						ContactStatusID = @ContactStatusTypeID,
						ContactTracingObservationID = @TracingObservationID,
						intRowStatus = @RowStatus,
						AuditUpdateUser = @User,
						AuditUpdateDTM = GETDATE()
					WHERE OutbreakCaseContactUID = @OutbreakCaseContactUID;
				END
			
            SET ROWCOUNT 1;
            DELETE FROM @ContactsTemp;
            SET ROWCOUNT 0;
        END
    END TRY
    BEGIN CATCH
        THROW
    END CATCH;
END
