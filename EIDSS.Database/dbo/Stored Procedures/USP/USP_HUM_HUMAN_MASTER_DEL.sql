

-- ================================================================================================
-- Name: USP_HUM_HUMAN_MASTER_DEL
--
-- Description: Delete a human master (actual) record.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Ann Xiong    2/15/2019 Initial release for new API.
-- Ann Xiong    2/10/2022 Updated 'ReturnMsg' to 'ReturnMessage'
-- Ann Xiong    2/14/2022 Removed @LanguageID and updated 'ReturnMsg' to 'ReturnMessage'
-- Ann Xiong    4/19/2022 Updated SELECT @ReturnCode 'ReturnCode', @ReturnMsg 'ReturnMessage' to SELECT @ReturnCode ReturnCode, @ReturnMsg ReturnMessage
-- Ann Xiong	3/15/2023 Implemented Data Audit and added parameters @idfDataAuditEvent and @AuditUserName
--
--
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HUM_HUMAN_MASTER_DEL] 
(
	@HumanMasterID		BIGINT,
    @idfDataAuditEvent BIGINT = NULL,
    @AuditUserName NVARCHAR(100)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnCode INT = 0 
	DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS'

	--Data Audit--
	DECLARE @idfUserId BIGINT = NULL;
	DECLARE @idfSiteId BIGINT = NULL;
	DECLARE @idfsDataAuditEventType bigint = 10016002;               	-- Delete audit event type
	DECLARE @idfsObjectType bigint = 10017082; 							-- Person Deduplication --
	DECLARE @idfObject bigint = @HumanMasterID;
	DECLARE @idfObjectTable_tlbHumanActual bigint = 4573200000000;
	--DECLARE @idfDataAuditEvent bigint = NULL;	

	-- Get and Set UserId and SiteId
	SELECT @idfUserId = userInfo.UserId, @idfSiteId = UserInfo.SiteId FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo
	--Data Audit--

	BEGIN TRY
		BEGIN TRANSACTION
			UPDATE 	dbo.tlbHumanActual
			SET 	intRowStatus = 1						
			WHERE	idfHumanActual = @HumanMasterID
					AND intRowStatus = 0

            -- Data audit
        	IF @idfDataAuditEvent IS NULL
        	BEGIN 
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @HumanMasterID, @idfObjectTable_tlbHumanActual, @idfDataAuditEvent OUTPUT
			END

			INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
					SELECT @idfDataAuditEvent, @idfObjectTable_tlbHumanActual, @idfObject
            -- End data audit
			
			IF @@TRANCOUNT > 0 
				COMMIT TRANSACTION;
			
			SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SET @ReturnCode = ERROR_NUMBER()
		SET @ReturnMessage = 'ErrorNumber: ' + convert(varchar, ERROR_NUMBER() ) 
							+ ' ErrorSeverity: ' + convert(varchar, ERROR_SEVERITY() )
			   				+ ' ErrorState: ' + convert(varchar,ERROR_STATE())
			   				+ ' ErrorProcedure: ' + isnull(ERROR_PROCEDURE() ,'')
			   				+ ' ErrorLine: ' +  convert(varchar,isnull(ERROR_LINE() ,''))
			   				+ ' ErrorMessage: '+ ERROR_MESSAGE()

		SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage

	END CATCH
END



