
--*************************************************************
-- Name: [USP_OMM_Vet_Contact_Set]
-- Description: Insert/Update for Outbreak Case
--          
-- Author: Doug Albanese
-- Revision History
--		Name       Date       Change Detail
--    Doug Albanese	6-5-2019
--*************************************************************
CREATE PROCEDURE [dbo].[USP_OMM_Vet_Contact_Set]
(    
	@LangID										NVARCHAR(50), 
	@OutbreakCaseContactUID						BIGINT = -1,
	@idfHuman									BIGINT = NULL,
	@OutBreakCaseReportUID						BIGINT,
	@ContactTypeId								BIGINT = NULL,
	@ContactRelationshipTypeID					BIGINT = NULL,
	@DateOfLastContact							DATETIME = NULL,
	@PlaceOfLastContact							NVARCHAR(200) = NULL,
	@CommentText								NVARCHAR(500) = NULL,
	@ContactStatusID							BIGINT = NULL,
	@intRowStatus								INT = 0,
	@AuditUser									VARCHAR(100) ='',
	@FunctionCall								INT = 0
)
AS

BEGIN    

	DECLARE	@returnCode						INT = 0;
	DECLARE @returnMsg						NVARCHAR(MAX) = 'SUCCESS';
	DECLARE @contactLocation				BIGINT = NULL

	Declare @SupressSelect table
	( retrunCode int,
		returnMsg varchar(200)
	)

	BEGIN TRY
			IF @OutbreakCaseContactUID < 0
				BEGIN
					INSERT INTO @SupressSelect
					EXEC	dbo.USP_GBL_NEXTKEYID_GET 'OutbreakCaseContact', @OutbreakCaseContactUID OUTPUT;
					
					INSERT INTO OutbreakCaseContact
						(
							OutbreakCaseContactUID,
							OutbreakCaseReportUID,
							ContactTypeId,
							ContactedHumanCasePersonID,
							idfHuman,
							ContactRelationshipTypeID,
							DateOfLastContact,
							PlaceOfLastContact,
							CommentText,
							ContactStatusId,
							ContactTracingObservationID,
							intRowStatus,
							AuditCreateUser,
							AuditCreateDTM
						)
					VALUES
						(
							@OutbreakCaseContactUID, --OutbreakCaseContactUID
							@OutBreakCaseReportUID, --OutbreakCaseReportUID
							@ContactTypeId, --ContactTypeId
							NULL, --ContactedHumanCasePersonID
							@idfHuman, --idfHuman
							@ContactRelationshipTypeID, --ContactRelationshipTypeID
							@DateOfLastContact, --DateOfLastContact
							@PlaceOfLastContact, --PlaceOfLastContact
							@CommentText, --CommentText
							@ContactStatusID, --ContactStatusId
							NULL, --ContactTracingObservationID
							@intRowStatus, --intRowStatus
							@AuditUser, --AuditCreateUser
							GETDATE() --AuditCreateDTM
						)

				END
			ELSE
				BEGIN
					UPDATE		OutbreakCaseContact
					SET 
								OutbreakCaseReportUID = @OutBreakCaseReportUID,
								ContactTypeId = @ContactTypeId,
								--ContactedHumanCasePersonID,
								idfHuman = @idfHuman,
								ContactRelationshipTypeID = @ContactRelationshipTypeID,
								DateOfLastContact = @DateOfLastContact,
								PlaceOfLastContact = @PlaceOfLastContact,
								CommentText = @CommentText,
								ContactStatusId = @ContactStatusID,
								--ContactTracingObservationID,
								intRowStatus = @intRowStatus,
								AuditUpdateUser = @AuditUser,
								AuditUpdateDTM = GETDATE()
					WHERE
								OutbreakCaseContactUID=@OutbreakCaseContactUID
				END
				
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT = 1 
			--ROLLBACK;
		throw;
	END CATCH

	if (@FunctionCall= 0)
		BEGIN
			SELECT	@returnCode as returnCode, @returnMsg as returnMsg
		END
	
END
