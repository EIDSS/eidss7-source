



-- ============================================================================
-- Name: USP_GBL_EMPLOYEE_GROUP_GETList
-- Description:	Get employee group list for verifying user permissions.
--                      
-- Author: Stephen Long
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Stephen Long     04/30/2018 Initial release.
-- Stephen Long     10/03/2019 Stored procedure clean up.
-- Stephen Long		03/10/2020 Resolved duplicate role appearances
-- Mark Wilson		01/30/2021 Updated to filter intRowStatus = 1
-- Mark Wilson		05/17/2022 Updated to find idfsSite for CDR
-- Mani Govindarajan 02/4/2023 Commented get user group from CDR.
-- Mani Govindarajan 03/02/2023 Added intRowStatus Condition on groupName
-- exec USP_GBL_EMPLOYEE_GROUP_GETList 'en'
-- ============================================================================
CREATE PROCEDURE [dbo].[USP_GBL_EMPLOYEE_GROUP_GETList] (
@LangID NVARCHAR(50),
@idfsSite BIGINT
)
AS
BEGIN
	DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode BIGINT = 0;
	--DECLARE @SupressSelect TABLE (
	--	retrunCode INT,
	--	returnMessage VARCHAR(200)
	--	)

	BEGIN TRY

---------------------------------------------------------------------------------
		--DECLARE @CDRSite BIGINT -- idfsSite for CDR
		--SELECT 
		--	@CDRSite = S.idfsSite
		--FROM dbo.tstSite S
		--INNER JOIN dbo.trtBaseReference SR ON SR.idfsBaseReference = S.idfsSiteType
		--WHERE S.intRowStatus = 0 
		--AND SR.strDefault = 'CDR'
		--		order by s.idfsSite desc

---------------------------------------------------------------------------------

		SELECT eg.idfEmployeeGroup,
			eg.idfsEmployeeGroupName,
			ISNULL(groupName.name, eg.strName) AS strName,
			eg.strDescription
		FROM dbo.tlbEmployeeGroup eg

		LEFT JOIN FN_GBL_ReferenceRepair_GET(@LangID, 19000022) groupName
			ON groupName.idfsReference = eg.idfsEmployeeGroupName
		WHERE 
			eg.idfEmployeeGroup <> - 1
			AND eg.intRowStatus = 0
			and groupName.intRowStatus=0
			AND		((eg.idfsSite =  @idfsSite OR @idfsSite IS NULL)
			AND eg.idfEmployeeGroup != -506 and eg.idfsEmployeeGroupName != -506
			--OR (eg.idfsSite = @CDRSite)
			)

	    ORDER BY strName;

	--	SELECT @returnCode,
		--	@returnMsg;
	END TRY

	BEGIN CATCH
		--BEGIN
			--SET @returnCode = ERROR_NUMBER();
			--SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();

			--SELECT @returnCode,
				--@returnMsg;
		--END
	END CATCH;
END
