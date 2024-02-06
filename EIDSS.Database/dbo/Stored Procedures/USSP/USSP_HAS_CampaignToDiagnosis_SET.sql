


-- ================================================================================================
-- Name: USSP_HAS_CampaignToDiagnosis_SET 
--
-- Description:	Inserts or updates campaign to sample type for the human module active surveillance 
-- campaign set up and edit use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     07/06/2019 Initial release.
-- Mark Wilson		08/19/2021 Updated to use tlbCampaignToDiagnosis and renamed to USSP_HAS_CampaignToDiagnosis_SET
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_HAS_CampaignToDiagnosis_SET] (
	@idfCampaignToDiagnosis BIGINT = NULL,
	@idfCampaign BIGINT,
	@idfsDiagnosis BIGINT,
	@intOrder INT,
	@intPlannedNumber INT = NULL,
	@idfsSpeciesType BIGINT = NULL,
	@idfsSampleType BIGINT = NULL,
	@Comments NVARCHAR(MAX) = NULL,
	@AuditUserName NVARCHAR(200)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM dbo.tlbCampaignToDiagnosis WHERE idfCampaignToDiagnosis = @idfCampaignToDiagnosis)
		BEGIN
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 
				'tlbCampaignToDiagnosis',
				@idfCampaignToDiagnosis OUTPUT;

			INSERT INTO dbo.tlbCampaignToDiagnosis
			(
			    idfCampaignToDiagnosis,
			    idfCampaign,
			    idfsDiagnosis,
			    intOrder,
			    intRowStatus,
			    rowguid,
			    intPlannedNumber,
			    idfsSpeciesType,
			    idfsSampleType,
			    SourceSystemNameID,
			    SourceSystemKeyValue,
			    AuditCreateUser,
			    AuditCreateDTM,
			    AuditUpdateUser,
			    AuditUpdateDTM,
			    Comments
			)
			VALUES (
				@idfCampaignToDiagnosis,
				@idfCampaign,
				@idfsDiagnosis,
				@intOrder,
				0,
				NEWID(),
				@intPlannedNumber,
				@idfsSpeciesType,
				@idfsSampleType,
				10519001,
				'[{"idfCampaignToDiagnosis":' + CAST(@idfCampaignToDiagnosis AS NVARCHAR(300)) + '}]',
				@AuditUserName,
				GETDATE(),
				@AuditUserName,
				GETDATE(),
				@Comments
				);
		END;
		ELSE
		BEGIN
			UPDATE dbo.tlbCampaignToDiagnosis
			SET idfCampaign = @idfCampaign,
				idfsDiagnosis = @idfsDiagnosis,
				intOrder = @intOrder,
				intPlannedNumber = @intPlannedNumber, 
				idfsSpeciesType = @idfsSpeciesType,
				idfsSampleType = @idfsSampleType,
				SourceSystemNameID = ISNULL(SourceSystemNameID, 10519001),
				SourceSystemKeyValue = '[{"idfCampaignToDiagnosis":' + CAST(@idfCampaignToDiagnosis AS NVARCHAR(300)) + '}]',
				AuditUpdateUser = @AuditUserName,
				AuditUpdateDTM = GETDATE(),
				Comments = @Comments,
				intRowStatus=0
			WHERE idfCampaignToDiagnosis = @idfCampaignToDiagnosis;
		END;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
