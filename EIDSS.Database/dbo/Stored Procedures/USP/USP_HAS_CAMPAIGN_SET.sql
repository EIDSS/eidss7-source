

-- ================================================================================================
-- Name: USP_HAS_CAMPAIGN_SET
--
-- Description: Insert/update active surveillance campaign record for the human module.
--          
-- Revision History:
-- Name						Date       Change Detail
-- ------------------		---------- -----------------------------------------------------------------
-- Stephen Long				07/06/2019 Initial release.
-- Stephen Long				09/30/2020 Added site ID to insert and update.
-- Manickandan Govindarajan 11/25/2020 Updated correct parameter for USP_GBL_NextNumber_GET to get the correct SCH Prefix
-- Mark Wilson				08/19/2021 Updated to handle multiple diagnosis per Campaign
-- Lamont Mitchell			08/25/2001 Removed Output declaration from @idfCampaign
-- Mark Wilson				08/27/2021 added code to clear tlbCampaignToDiagnosis
-- Mark Wilson				10/13/2021 reviewed for location udpates. minor edits
-- Testing code:
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HAS_CAMPAIGN_SET] (
	@LanguageID NVARCHAR(50),
	@idfCampaign BIGINT NULL,
	@CampaignTypeID BIGINT,
	@CampaignStatusTypeID BIGINT,
	@CampaignDateStart DATETIME,
	@CampaignDateEnd DATETIME,
	@strCampaignID NVARCHAR(50),
	@CampaignName NVARCHAR(200),
	@CampaignAdministrator NVARCHAR(200),
	@Conclusion NVARCHAR(MAX),
	@SiteID BIGINT,
	@CampaignCategoryTypeID BIGINT,
	@AuditUserName NVARCHAR(200), 
	@CampaignToDiagnosisCombo NVARCHAR(MAX),  -- idfCampaignToDiagnosis, idfsDiagnosis, intOrder,  intPlannedNumber, idfsSpeciesType, idfsSampleType, Comments, AuditUser
	@MonitoringSessions NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @ReturnCode INT = 0
	DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS'
	DECLARE @SuppressSelect TABLE 
	(
		ReturnCode INT,
		ReturnMessage VARCHAR(200)
	)
	DECLARE 
		@idfCampaignToDiagnosis BIGINT = NULL,
		@idfsDiagnosis BIGINT = NULL,
		@intOrder INT = NULL,
		@intPlannedNumber INT = NULL,
		@idfsSpeciesType BIGINT = NULL,
		@idfsSampleType BIGINT = NULL,
		@Comments NVARCHAR(500) = NULL,
		@RowID BIGINT = NULL,

		@idfMonitoringSession BIGINT = NULL

	DECLARE @tlbCampaignToDiagnosis TABLE 
	(
		idfCampaignToDiagnosis BIGINT NOT NULL,
		idfsDiagnosis BIGINT NULL,
		intOrder INT NOT NULL,
		intPlannedNumber INT NULL,
		idfsSpeciesType BIGINT NULL,
		idfsSampleType BIGINT NULL,
		Comments NVARCHAR(MAX) NULL		
	);

	DECLARE @tlbMonitoringSession TABLE 
	(
		idfMonitoringSession BIGINT NOT NULL
	);

	BEGIN TRY
		BEGIN TRANSACTION

		INSERT INTO @tlbCampaignToDiagnosis
		(
		    idfCampaignToDiagnosis,
		    idfsDiagnosis,
		    intOrder,
		    intPlannedNumber,
--		    idfsSpeciesType, -- no Sample Type for human
		    idfsSampleType,  
		    Comments
		)
		SELECT *
		FROM OPENJSON(@CampaignToDiagnosisCombo) WITH 
		(
			idfCampaignToDiagnosis BIGINT,
			idfsDiagnosis BIGINT,
			intOrder INT,
			intPlannedNumber INT,
--			idfsSpeciesType BIGINT,
			idfsSampleType BIGINT,
			Comments NVARCHAR(MAX)
		);

		INSERT INTO @tlbMonitoringSession
		SELECT * 
		FROM OPENJSON(@MonitoringSessions) WITH (
				idfMonitoringSession BIGINT
		);

		IF NOT EXISTS (
				SELECT *
				FROM dbo.tlbCampaign
				WHERE idfCampaign = @idfCampaign
					AND intRowStatus = 0
				)
		BEGIN
			INSERT INTO @SuppressSelect
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 
				'tlbCampaign',
				@idfCampaign OUTPUT;

			INSERT INTO @SuppressSelect
			EXECUTE dbo.USP_GBL_NextNumber_GET 
				'Human Active Surveillance Campaign',
				@strCampaignID OUTPUT,
				NULL;

			INSERT INTO dbo.tlbCampaign (
				idfCampaign,
				idfsCampaignType,
				idfsCampaignStatus,
				datCampaignDateStart,
				datCampaignDateEnd,
				strCampaignID,
				strCampaignName,
				strCampaignAdministrator,
				strConclusion,
				intRowStatus,
				rowguid,
				CampaignCategoryID, 
				idfsSite,
				SourceSystemNameID,
				SourceSystemKeyValue,
				AuditCreateUser,
				AuditCreateDTM,
				AuditUpdateUser,
				AuditUpdateDTM
				)
			VALUES (
				@idfCampaign,
				@CampaignTypeID,
				@CampaignStatusTypeID,
				@CampaignDateStart,
				@CampaignDateEnd,
				@strCampaignID,
				@CampaignName,
				@CampaignAdministrator,
				@Conclusion,
				0,
				NEWID(),
				@CampaignCategoryTypeID,
				@SiteID,
				10519001,
				'[{"idfCampaign":' + CAST(@idfCampaign AS NVARCHAR(300)) + '}]',
				@AuditUserName,
				GETDATE(),
				@AuditUserName,
				GETDATE()
				);
		END
		ELSE
		BEGIN
			UPDATE dbo.tlbCampaign
			SET idfsCampaignType = @CampaignTypeID,
				idfsCampaignStatus = @CampaignStatusTypeID,
				datCampaignDateStart = @CampaignDateStart,
				datCampaignDateEnd = @CampaignDateEnd,
				strCampaignID = @strCampaignID,
				strCampaignName = @CampaignName,
				strCampaignAdministrator = @CampaignAdministrator,
				strConclusion = @Conclusion,
				CampaignCategoryID = @CampaignCategoryTypeID, 
				idfsSite = @SiteID,
				intRowStatus = 0, -- no reason to update a deleted record
				SourceSystemNameID = ISNULL(SourceSystemNameID, 10519001),
				SourceSystemKeyValue = ISNULL(SourceSystemKeyValue, '[{"idfCampaign":' + CAST(@idfCampaign AS NVARCHAR(300)) + '}]'),
				AuditUpdateUser = @AuditUserName,
				AuditUpdateDTM = GETDATE()
			WHERE idfCampaign = @idfCampaign;
		END

/* this needs some 'splaining

		UPDATE dbo.tlbCampaignToDiagnosis
		SET intRowStatus = 1
		WHERE idfCampaign = @idfCampaign

*/

		WHILE EXISTS (
				SELECT *
				FROM @tlbCampaignToDiagnosis
				)
		BEGIN
			SELECT 
				TOP 1 @RowID = idfCampaignToDiagnosis,
				@idfsDiagnosis = idfsDiagnosis,
				@intOrder = intOrder,
				@intPlannedNumber = intPlannedNumber,
				@idfsSpeciesType = NULL, -- SpeciesType is null for human
				@idfsSampleType = idfsSampleType,
				@Comments = Comments

			FROM @tlbCampaignToDiagnosis;

			INSERT INTO @SuppressSelect
			EXECUTE dbo.USSP_HAS_CampaignToDiagnosis_SET 
				@RowID,
				@idfCampaign,
				@idfsDiagnosis,
				@intOrder,
				@intPlannedNumber,
				@idfsSpeciesType,
				@idfsSampleType,
				@Comments,
				@AuditUserName

			DELETE
			FROM @tlbCampaignToDiagnosis
			WHERE idfCampaignToDiagnosis = @RowID;

		END;

		WHILE EXISTS (
				SELECT *
				FROM @tlbMonitoringSession
				)
		BEGIN
			SELECT TOP 1 @idfMonitoringSession = idfMonitoringSession
			FROM @tlbMonitoringSession;

			UPDATE dbo.tlbMonitoringSession 
			SET idfCampaign = @idfCampaign,
				AuditUpdateDTM = GETDATE(),
				AuditCreateUser = @AuditUserName

			WHERE idfMonitoringSession = @idfMonitoringSession;

			DELETE
			FROM @tlbMonitoringSession
			WHERE idfMonitoringSession = @idfMonitoringSession;
		END;


		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

		SELECT 
			@ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage,
			@idfCampaign idfCampaign,
			@strCampaignID strCampaignID;

	END TRY

	BEGIN CATCH
		IF @@Trancount > 0
			ROLLBACK TRANSACTION;

		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT
			@ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage,
			@idfCampaign idfCampaign,
			@strCampaignID strCampaignID;

		THROW;
	END CATCH
END
