-- ================================================================================================
-- Name: USP_DAS_APPROVALS_GETList
--
-- Description: Returns a list of accessioned samples and test that need to destroyed or deleted 
-- or tests that need to be validated
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name                  Date       Change Detail
-- --------------------- ---------- --------------------------------------------------------------
-- Ricky Moss            11/27/2018 Initial release
-- Ricky Moss            11/30/2018	Remove reference type id variables
-- Ricyk Moss            12/30/2018	Rename fields to fit standards and consistency
-- Stephen Long          02/25/2019 Modified selects to be in sync with the use case.
-- Stephen Long          01/24/2020 Converted site ID to site list for site filtration.
-- Leo Tracchia			 02/18/2022 Removed return code and return message		
-- Testing Code:
-- exec USP_DAS_APPROVALS_GETList 'en', 1100
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_DAS_APPROVALS_GETList] (
	@LanguageID NVARCHAR(50),
	@SiteList VARCHAR(MAX) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;

	BEGIN TRY
		SELECT 'Samples to be destroyed' AS Approval,
			COUNT(m.idfsSampleStatus) AS NumberOfRecords,
			'~/Laboratory/Laboratory.aspx?Tab=Approvals&ActionRequested=38' AS [Action]
		FROM dbo.tlbMaterial m
		WHERE m.idfsSampleStatus = 10015003 --Marked for Destruction
			AND m.intRowStatus = 0
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
		
		UNION
		
		SELECT 'Records to be deleted' AS Approval,
			(
				(
					SELECT COUNT(m.idfMaterial)
					FROM dbo.tlbMaterial m
					WHERE m.idfsSampleStatus = 10015002 --Marked for Deletion
						AND m.intRowStatus = 0
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
					) + (
					SELECT COUNT(t.idfTesting)
					FROM dbo.tlbTesting t
					INNER JOIN dbo.tlbMaterial AS m
						ON m.idfMaterial = t.idfMaterial
					WHERE t.idfsTestStatus = 19000502 --Marked for Deletion
						AND t.intRowStatus = 0
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
					)
				) AS NumberOfRecords,
			'~/Laboratory/Laboratory.aspx?Tab=Approvals&ActionRequested=39' AS [Action]
		
		UNION
		
		SELECT 'Test Results to be validated' AS Approval,
			(
				SELECT COUNT(t.idfTesting)
				FROM dbo.tlbTesting t
				INNER JOIN dbo.tlbMaterial AS m
					ON m.idfMaterial = t.idfMaterial
				WHERE t.idfsTestStatus = 10001004 --Preliminary
					AND t.intRowStatus = 0
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
				) AS NumberOfRecords,
			'~/Laboratory/Laboratory.aspx?Tab=Approvals&ActionRequested=40' AS [Action];

		--SELECT @ReturnCode,
		--	@ReturnMessage;
	END TRY

	BEGIN CATCH
		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		--SELECT @ReturnCode,
		--	@ReturnMessage;

		THROW;
	END CATCH;
END
