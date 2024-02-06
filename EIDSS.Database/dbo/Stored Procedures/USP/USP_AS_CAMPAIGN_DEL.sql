-- ================================================================================================
-- Name: USP_AS_CAMPAIGN_DEL
--
-- Description: Deletes an active surveillance campaign record for the human/vet module.
--          
-- Revision History:
-- Name               Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Stephen Long       07/06/2019 Initial release.
-- Mark Wilson		  08/12/2021 modified to delete from tlbCampaignToDiagnosis
-- Manickandan Govindarajan 11/17/2022 Implemented Data Audit
-- Testing code:
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_AS_CAMPAIGN_DEL] (
@LanguageID NVARCHAR(50),
	@CampaignID AS BIGINT,
	@UserName as varchar(255)
	)
AS
BEGIN
	SET NOCOUNT ON;

	--Data Audit
	
	declare @auditdDelete as TABLE
    (
      idfObject bigint,
	  idfTable bigint
    )
	declare @idfsDataAuditEventType bigint =10016002;
	declare @idfsObjectType bigint;
	declare @idfObject bigint =@CampaignID;
	declare @idfObjectTable_tlbCampaign bigint =706900000000;
	declare @idfDataAuditEvent bigint;
	declare @campaignCategoryId bigint;
	declare @idfUserID bigint;
	declare @idfSiteId bigint;
	declare @idfObjectTable_tlbCampaignToDiagnosis bigint =707000000000;


	--Data Audit

	BEGIN TRY
		DECLARE @ReturnMessage VARCHAR(MAX) = 'Success',
			@ReturnCode INT = 0,
			@MonitoringSessionCount AS INT = 0;

		--Data Audit

		select @campaignCategoryId= CampaignCategoryID from tlbCampaign where idfCampaign = @CampaignID;
		if @campaignCategoryId = 10501001
			set @idfsObjectType=10017061;
		ELSE IF @campaignCategoryId = 10501002
			set @idfsObjectType=10017073;
		
		--Data Audit

		SELECT @MonitoringSessionCount = COUNT(*)
		FROM dbo.tlbMonitoringSession
		WHERE idfCampaign = @CampaignID
			AND intRowStatus = 0;

		IF @MonitoringSessionCount = 0
		BEGIN
			
			--Data Audit
			  select @idfUserID= a.userid, @idfSiteId= a.siteid from dbo.FN_UserSiteInformation('Administrator') a;
			-- insert record into tauDataAuditEvent
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserID,@idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbCampaign, @idfDataAuditEvent OUTPUT
				-- insert into delete 

			INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, @idfObjectTable_tlbCampaignToDiagnosis, idfCampaignToDiagnosis
				 from dbo.tlbCampaignToDiagnosis WHERE idfCampaign = @CampaignID;
			--Data Audit

			-- Delete child records for species and sample types.
			UPDATE dbo.tlbCampaignToDiagnosis
			SET intRowStatus = 1, AuditUpdateUser= @UserName, AuditUpdateDTM = GETDATE()
			WHERE idfCampaign = @CampaignID;

			UPDATE dbo.tlbCampaign
			SET intRowStatus = 1,AuditUpdateUser= @UserName, AuditUpdateDTM = GETDATE()
			WHERE idfCampaign = @CampaignID;

			--Data Audit
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				values (@idfDataAuditEvent, @idfObjectTable_tlbCampaign,@idfObject)
			--Data Audit

		END;
		ELSE
		BEGIN
			SET @ReturnCode = 1;
			SET @ReturnMessage = 'Unable to delete this record as it contains dependent child objects.';
		END;

		IF @@TRANCOUNT > 0
			AND @returnCode = 0
			COMMIT;

		SELECT @ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage;
	END TRY

	BEGIN CATCH
		IF @@Trancount > 0
			ROLLBACK TRANSACTION;

		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage;

		THROW;
	END CATCH
END
