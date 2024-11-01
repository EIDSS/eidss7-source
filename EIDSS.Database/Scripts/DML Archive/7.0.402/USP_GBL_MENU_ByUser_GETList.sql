
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--================================================================================================
-- Name: USP_GBL_MENU_ByUser_GETList
-- Description: Selects items for the EIDSS header menu.     
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Mandar Kulkarni 09/07/2021 Initial release
-- Mani  09/07/2021 updated input parameter
-- Mani 09/16/2021 Update  with CTE 
-- Mani 11/11/2021  Added Read System Operation Condition for LkupRoleSystemFunctionAccess table -10059003

-- Testing Code:
/*

 EXEC USP_GBL_MENU_ByUser_GETList 161287150000873, 'en-US', 420664190000873

*/
-- ================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_GBL_MENU_ByUser_GETList] 
(
	@idfUserId BIGINT
	,@LangID NVARCHAR(50) = 'en-US'
	,@EmployeeID BIGINT = NULL
)

AS
DECLARE @returnMsg VARCHAR(MAX) = 'Success'
DECLARE @returnCode BIGINT = 0
DECLARE @RoleId BIGINT
DECLARE @idfsLangId BIGINT
DECLARE @idfPerson BIGINT


BEGIN


	BEGIN TRY

		-- Get the person ID for the logged in user.
		IF @EmployeeID IS NULL
		BEGIN
			SET @idfPerson = (
					SELECT a.idfPerson
					FROM dbo.tstUserTable a
					INNER JOIN dbo.tstSite b ON a.idfsSite = b.idfsSite
					WHERE a.idfUserId = @idfUserId
						AND a.intRowStatus = 0 -- Check if user is active
						AND b.intRowStatus = 0 -- Check if site is active
					)
		END
		ELSE
		BEGIN
			SET @idfPerson = @EmployeeID
		END;

		BEGIN

			select	@idfPerson as idfEmployee,
					lkEmenu.EIDSSMenuID as EIDSSMenuId,
					ISNULL(menuName.strTextString,menuName.[name]) AS MenuName,
					ISNULL(lkEmenu.EIDSSParentMenuID, lkEmenu.EIDSSMenuID) AS EIDSSParentMenuId,
					PM.strDefault AS strParentMenuName,
					lkEAO.Controller,
					lkEAO.strAction,
					lkEAO.Area,
					lkEAO.SubArea,
					menuName.intOrder
			from	LkupEIDSSMenu lkEmenu
			INNER JOIN dbo.LkupEIDSSAppObject lkEAO 
			ON lkEmenu.EIDSSMenuID = lkEAO.AppObjectNameID AND lkEAO.intRowStatus = 0
			INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID,19000506) menuName 
			ON lkEmenu.EIDSSMenuID = menuName.idfsReference
			INNER JOIN dbo.trtBaseReference PM ON PM.idfsBaseReference = ISNULL(lkEmenu.EIDSSParentMenuID, lkEmenu.EIDSSMenuID)
			OUTER APPLY
				(	select	top 1 letsf.SystemFunctionID
					from dbo.LkupEIDSSMenuToSystemFunction letsf
					INNER JOIN  dbo.LkupRoleSystemFunctionAccess lrsfa
					ON lrsfa.SystemFunctionID = letsf.SystemFunctionID AND lrsfa.intRowStatus = 0 and (lrsfa.SystemFunctionOperationID=10059003 or lrsfa.SystemFunctionOperationID=10059005)
							and lrsfa.idfEmployee = @idfPerson
					where letsf.EIDSSMenuID = lkEmenu.EIDSSMenuID
							and letsf.intRowStatus = 0
				) individual_perm
			OUTER APPLY
				(	select	top 1 letsf.SystemFunctionID
					from dbo.LkupEIDSSMenuToSystemFunction letsf
					INNER JOIN  dbo.LkupRoleSystemFunctionAccess lrsfa
					ON lrsfa.SystemFunctionID = letsf.SystemFunctionID AND lrsfa.intRowStatus = 0 and (lrsfa.SystemFunctionOperationID=10059003 or lrsfa.SystemFunctionOperationID=10059005)
					inner join dbo.tlbEmployeeGroupMember egm
					on egm.idfEmployeeGroup = lrsfa.idfEmployee
						and egm.idfEmployee = @idfPerson
						and egm.intRowStatus = 0
					inner join	dbo.tlbEmployeeGroup eg
					on eg.idfEmployeeGroup = egm.idfEmployeeGroup
						and eg.intRowStatus = 0
					where letsf.EIDSSMenuID = lkEmenu.EIDSSMenuID
							and letsf.intRowStatus = 0
							and individual_perm.SystemFunctionID is null
				) group_perm
			where lkEmenu.intRowStatus = 0
					and (individual_perm.SystemFunctionID is not null or group_perm.SystemFunctionID is not null)
			ORDER BY ISNULL(lkEmenu.EIDSSParentMenuID, lkEmenu.EIDSSMenuID), menuName.intOrder
				


	END


		

	END TRY

	BEGIN CATCH
		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();
		SET @returnCode = ERROR_NUMBER();

	END CATCH
END
