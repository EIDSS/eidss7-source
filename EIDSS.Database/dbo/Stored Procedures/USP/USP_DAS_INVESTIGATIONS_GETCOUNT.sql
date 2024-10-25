-- ================================================================================================
-- Name: USP_DAS_INVESTIGATIONS_GETCOUNT
--
-- Description: Returns a count of veterinary disease reports
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name					Date       Change Detail
-- -------------------- ---------- ---------------------------------------------------------------
-- Ricky Moss			05/07/2018 Initial Release
-- Stephen Long         01/24/2020 Added site list parameter for site filtration.  Removed unused
--                                 left joins, and added active record status check.
--
-- Testing Code:
-- exec USP_DAS_INVESTIGATIONS_GETCOUNT
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_DAS_INVESTIGATIONS_GETCOUNT] @SiteList VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;

	BEGIN TRY
		SELECT COUNT(vc.idfVetCase) AS RecordCount
		FROM dbo.tlbVetCase vc
		INNER JOIN dbo.tlbFarm AS f
			ON f.idfFarm = vc.idfFarm
		WHERE vc.intRowStatus = 0
			AND vc.idfsCaseProgressStatus = 10109001 --In Process
			AND (
				vc.idfsSite IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteList, NULL, ',')
					)
				OR (@SiteList IS NULL)
				);

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
END
