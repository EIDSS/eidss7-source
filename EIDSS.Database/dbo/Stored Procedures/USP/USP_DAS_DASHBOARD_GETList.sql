/****** Object:  StoredProcedure [dbo].[USP_DAS_DASHBOARD_GETList]    Script Date: 12/17/2019 12:00:25 PM ******/

-- ================================================================================================
-- Name: USP_DAS_DASHBOARD_GETList
--
-- Description: Returns a list of dashboard item based on the user currently logged in and 
-- dashboard item.
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name            Date      Change Detail
-- -------------- ---------- ---------------------------------------------------------------------
-- Ricky Moss     11/21/2018 Initial Release
-- Ricky Moss     11/30/2018 Removed the id variables
-- Stephen Long   12/17/2019 Cleaned up log, replaced hard-coded language parameter to the 
--                           reference repair call.
-- Stephen Long   01/26/2020 Added return code and return message.
-- Leo Tracchia	  02/22/2022 Minor change for generating dashboard links 
--
-- Testing Code:
-- exec USP_DAS_DASHBOARD_GETList 'en', 55541620000032, 'Icon'
-- exec USP_DAS_DASHBOARD_GETList 'en', 55541620000032, 'Grid'
-- exec USP_DAS_DASHBOARD_GETList 'en', 55541620000032, 'Navi'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_DAS_DASHBOARD_GETList] (
	@LanguageID NVARCHAR(50),
	@PersonID BIGINT,
	@DashboardItemType NVARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;

	BEGIN TRY
		SELECT distinct br.idfsBaseReference as 'BaseReferenceId',
			strBaseReferenceCode as 'BaseReferenceCode',
			snt.strDefault as 'Default',
			snt.[name] as 'Name',
			ao.PageLink as 'PageLink'
		FROM dbo.trtBaseReference br
		JOIN dbo.lkupEIDSSAppObject ao
			ON br.idfsBaseReference = ao.AppObjectNameID
		JOIN dbo.LkupRoleDashboardObject do
			ON ao.AppObjectNameID = do.DashboardObjectID
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000506) snt
			ON br.idfsBaseReference = snt.idfsReference
		LEFT JOIN dbo.tlbEmployeeGroupMember egm
			ON do.idfEmployee = egm.idfEmployeeGroup
		WHERE egm.idfEmployee = @PersonID
			AND egm.idfEmployeeGroup < 0
			AND ao.intRowStatus = 0
			AND do.intRowStatus = 0
			AND egm.intRowStatus = 0
			AND ao.PageLink <> '#'
			AND strBaseReferenceCode LIKE '%dashB' + @DashboardItemType + '%'
		
		--order by snt.[name]

		--SELECT @ReturnCode,
		--	@ReturnMessage;
	END TRY

	BEGIN CATCH
		--SET @ReturnCode = ERROR_NUMBER();
		--SET @ReturnMessage = ERROR_MESSAGE();

		--SELECT @ReturnCode,
		--	@ReturnMessage;

		THROW;
	END CATCH;
END;
