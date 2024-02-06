

--=================================================================================================
-- Author:					Srini Goli
--
-- Description:				To get the Reports list
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------

-- 
-- Test Code:
-- EXEC report.USP_REP_Reports_GetList 
-- SELECT * FROM [dbo].[tlbReportAudit]
--=================================================================================================
CREATE PROCEDURE [Report].[USP_REP_Reports_GetList] 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode BIGINT = 0;
	DECLARE @ReportNames table
	(
		strReportName nvarchar(250) not null
	)


	BEGIN TRY
	    
	    INSERT INTO @ReportNames(strReportName)
	    SELECT 'ALL' AS [ReportName]
	    
	    INSERT INTO @ReportNames(strReportName)
	    SELECT [ReportName]
        FROM [dbo].[tlbReportAudit]
		GROUP BY [ReportName]
		ORDER BY [ReportName] ASC
		
		SELECT strReportName AS [ReportName]
		FROM @ReportNames
		
		--SELECT @returnCode,
		--	@returnMsg;
	END TRY

	BEGIN CATCH
		BEGIN
			SET @returnCode = ERROR_NUMBER();
			SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();

			SELECT @returnCode,
				@returnMsg;
		END
	END CATCH;
END


