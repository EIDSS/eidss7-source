-- ================================================================================================
-- Name: USP_DAS_UNACCESSIONED_SAMPLE_GETCount
--
-- Description:	Gets unaccessioned sample count for the dashboard module use case SYSUC06.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/25/2019 Initial release.
-- Stephen Long     01/26/2020 Changed site ID to site list for site filtration.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_DAS_UNACCESSIONED_SAMPLE_GETCount] (
	@LanguageID NVARCHAR(50),
	@OrganizationID BIGINT = NULL,
	@SiteList VARCHAR(MAX) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;

	BEGIN TRY
		SELECT COUNT(m.idfMaterial) AS RecordCount 
		FROM dbo.tlbMaterial m
		WHERE (m.blnAccessioned = 0)
			AND (
				(m.idfSendToOffice = @OrganizationID)
				OR (@OrganizationID IS NULL)
				)
			AND (
				(
					m.idfsSite IN (
						SELECT CAST([Value] AS BIGINT)
						FROM dbo.FN_GBL_SYS_SplitList(@SiteList, NULL, ',')
						)
					OR m.idfsCurrentSite IN (
						SELECT CAST([Value] AS BIGINT)
						FROM dbo.FN_GBL_SYS_SplitList(@SiteList, NULL, ',')
						)
					)
				OR (@SiteList IS NULL)
				)
			AND (m.idfsSampleType <> 10320001) --Unknown
			AND (m.idfsSampleStatus IS NULL)
			AND (m.intRowStatus = 0);

		SELECT @ReturnCode,
			@ReturnMessage;
	END TRY

	BEGIN CATCH
		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode,
			@ReturnMessage;

		THROW;
	END CATCH;
END;
