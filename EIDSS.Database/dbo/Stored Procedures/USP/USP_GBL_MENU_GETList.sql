
-- ================================================================================================
-- Name: USP_GBL_MENU_GETList
-- Description: Selects items for the EIDSS header menu.     
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Mandar Kulkarni 09/06/2018 Initial release
-- Mandar Kulkarni 08/11/2020 Changed the order sequence to intOrder intread of EIDSSMenuID
-- Stephen Long    12/10/2020 Added emloyee ID parameter for users that are employed by 
--                            multiple organizations.
-- Mani			   03/02/2021 Added controller, straction fields from LkupEIDSSAppObject table
-- Mani			   09/7/2021 changed the condition in tlbEmployeeGroup with idfEmployeeGroup field
-- Testing Code:
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_MENU_GETList] (
	@idfUserId BIGINT
	,@LangID NVARCHAR(50) = 'EN'
	,@EmployeeID BIGINT = NULL
	)
AS
DECLARE @idfPerson BIGINT
DECLARE @returnMsg VARCHAR(MAX) = 'Success'
DECLARE @returnCode BIGINT = 0
DECLARE @RoleId BIGINT
DECLARE @idfsLangId BIGINT

BEGIN
	-- Set language ID
	SET @idfsLangId = (
			SELECT dbo.FN_GBL_LanguageCode_GET(@LangID)
			)

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

		-- If active site or person is not found
		IF @idfPerson IS NULL
		BEGIN
			SET @returnCode = 10
			SET @returnMsg = 'Either the Site or the User is not active'
		END
		ELSE
			-- Get the all the menu options for every role that the user is assigned to.
		BEGIN
			SELECT a.idfsBaseReference
				,ISNULL(b.strTextString, a.strDefault) AS MenuName
				,a.idfsReferenceType
				,f.EIDSSMenuID AS EIDSSMenuId
				,ISNULL(f.EIDSSParentMenuID, f.EIDSSMenuID) AS EIDSSParentMenuId
				,g.PageName
				,g.PageTitleID
				,g.PageLink
				,g.ExceptionControlList
				,g.DisplayOrder
				,ISNULL(g.IsOpenInNewWindow, 0) AS IsOpenInNewWindow
				,g.AppModuleGroupList,
				g.Controller,
				g.strAction,
				g.Area,
				g.SubArea
			FROM dbo.trtBaseReference a
			INNER JOIN dbo.LkupEIDSSMenu f ON f.EIDSSMenuID = a.idfsBaseReference
				AND f.intRowStatus = 0
			INNER JOIN dbo.LkupEIDSSAppObject g ON f.EIDSSMenuID = g.AppObjectNameID
				AND g.intRowStatus = 0
			LEFT OUTER JOIN dbo.trtStringNameTranslation b ON b.idfsBaseReference = a.idfsBaseReference
				AND b.intRowStatus = 0
				AND b.idfsLanguage = @idfsLangId
			WHERE a.intRowStatus = 0
				AND a.idfsReferenceType = 19000506
				AND a.idfsBaseReference IN (
					SELECT c.EIDSSMenuID
					FROM dbo.LkupRoleMenuAccess C
					WHERE c.intRowStatus = 0
						AND c.idfEmployee IN (
							SELECT d.idfEmployeeGroup
							FROM dbo.tlbEmployeeGroup d
							INNER JOIN dbo.tlbEmployeeGroupMember e ON e.idfEmployeeGroup = d.idfEmployeeGroup
								AND e.intRowStatus = 0
							WHERE e.idfEmployee = @idfPerson
								AND d.intRowStatus = 0
							)
					)
			--AND (Pagelink <> '#' OR EIDSSMenuId = EIDSSParentMenuId)
			--		Mandar Kulkarni	08/11/2020	Changed the order sequence to intOrder intread of EIDSSMenuID
			ORDER BY EIDSSParentMenuId
				,intOrder;
		END

	END TRY

	BEGIN CATCH
		--SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();
		--SET @returnCode = ERROR_NUMBER();

		--SELECT @returnCode
		--	,@returnMsg;
	END CATCH
END
