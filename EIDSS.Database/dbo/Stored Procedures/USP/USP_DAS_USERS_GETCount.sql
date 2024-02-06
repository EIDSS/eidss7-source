/****** Object:  StoredProcedure [dbo].[USP_DAS_USERS_GETCount]    Script Date: 12/11/2018 4:26:40 PM ******/
-- ================================================================================================
-- Name: USP_DAS_USERS_GETCOUNT
--
-- Description: Returns a count of users in the system
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss       05/07/2018 Initial Release
-- Stephen Long     01/26/2020 Added site list parameter for site filtration, and corrected table
--                             query was selecting from (tlbPerson to tstUserTable).
--
-- Testing Code:
-- exec USP_DAS_USERS_GETCount
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_DAS_USERS_GETCount] (@SiteList VARCHAR(MAX) = NULL)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;

	BEGIN TRY
		SELECT COUNT(u.idfUserID) AS RecordCount
		FROM dbo.tstUserTable u
		WHERE u.intRowStatus = 0
			AND (
				(
					u.idfsSite IN (
						SELECT CAST([Value] AS BIGINT)
						FROM dbo.FN_GBL_SYS_SplitList(@SiteList, NULL, ',')
						)
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
