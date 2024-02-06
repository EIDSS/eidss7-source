/*******************************************************
NAME						: [USP_CONF_HumanAggregateCaseMatrixVersion_DELETE]		


Description					: Deletes[o Entries For Human Aggregate Case Matrix Version

Author						: Lamont Mitchell

Revision History
		
			Name							Date								Change Detail
			Lamont Mitchell					01/24/19							Initial Created
--			Ann Xiong						02/21/2023							Implemented Data Audit
*******************************************************/
CREATE PROCEDURE [dbo].[USP_CONF_HumanAggregateCaseMatrixVersion_DELETE]
	
@idfVersion								BIGINT = NULL
AS BEGIN
	DECLARE @returnMsg					VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode					BIGINT = 0;
	SET NOCOUNT ON;

	--Data Audit--
	declare @idfUserId BIGINT = NULL;
	declare @idfSiteId BIGINT = NULL;
	declare @idfsDataAuditEventType bigint = NULL;
	declare @idfsObjectType bigint = 10017003;                         -- Matrix for Aggregate Reports
	declare @idfObject bigint = @idfVersion;
	declare @idfDataAuditEvent bigint= NULL;
	declare @idfObjectTable_tlbAggrMatrixVersionHeader bigint = 707330000000;

	-- Get and Set UserId and SiteId
	select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation('Administrator') userInfo

	--End data audit

	BEGIN TRY
			IF EXISTS(SELECT * from [tlbAggrMatrixVersionHeader] WHERE idfVersion =  @idfVersion )
			 BEGIN
				DELETE FROM [tlbAggrMatrixVersionHeader] WHERE idfVersion =  @idfVersion 

			--Data Audit

			-- tauDataAuditEvent Event Type - Delete
			set @idfsDataAuditEventType =10016002;

			-- insert record into tauDataAuditEvent
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserID,@idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbAggrMatrixVersionHeader, @idfDataAuditEvent OUTPUT

			INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, @idfObjectTable_tlbAggrMatrixVersionHeader, @idfObject
            -- End data audit

				SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'
			 END
			ELSE
			BEGIN
				SET @returnMsg = 'Record does not exists'
				SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'
			END
		END TRY
		BEGIN CATCH
				THROW;
		END CATCH
END
