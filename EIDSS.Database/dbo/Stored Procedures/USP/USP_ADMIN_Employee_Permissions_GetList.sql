
-- ================================================================================================
-- Author:		Mani
-- Create date: 03/12/2021
-- Description:	Retrieve a list of Permissions for the given user.
-- 
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------

-- Mani			   01/12/2021	
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_Employee_Permissions_GetList] @idfuserid BIGINT
	,@EmployeeID BIGINT = NULL
	
AS
BEGIN

	SET NOCOUNT ON;

	-- Returned on login - user's default organization permissions.
	SELECT 
		r1.idfsBaseReference PermissionId
		,r1.strDefault Permission
		,r2.idfsBaseReference PermissionLevelId
		,r2.strDefault PermissionLevel
	FROM dbo.tstUserTable ut
	JOIN dbo.tlbPerson p ON p.idfPerson = ut.idfPerson
	Join dbo.tlbEmployee e on e.idfEmployee= p.idfPerson and e.idfsEmployeeType =10023001
	JOIN dbo.LkupRoleSystemFunctionAccess fa ON fa.idfEmployee =  e.idfEmployee
	JOIN dbo.trtBaseReference r1 ON r1.idfsBaseReference = fa.SystemFunctionID
	JOIN dbo.trtReferenceType r11 ON r11.idfsReferenceType = r1.idfsReferenceType
	JOIN dbo.trtBaseReference r2 ON r2.idfsBaseReference = fa.SystemFunctionOperationID
	WHERE ut.idfUserID = @idfuserid
		AND p.intRowStatus = 0 
		AND e.intRowStatus = 0
		AND fa.intRowStatus = 0 
		AND @EmployeeID IS NULL 

	UNION

	-- Returned when user swtiches to another assigned organization outside of the default one.
	SELECT 
		r1.idfsBaseReference PermissionId
		,r1.strDefault Permission
		,r2.idfsBaseReference PermissionLevelId
		,r2.strDefault PermissionLevel
	FROM dbo.tstUserTable ut
	JOIN dbo.LkupRoleSystemFunctionAccess fa ON fa.idfEmployee = ut.idfPerson 
		and ut.intRowStatus=0
	JOIN dbo.trtBaseReference r1 ON r1.idfsBaseReference = fa.SystemFunctionID
	JOIN dbo.trtReferenceType r11 ON r11.idfsReferenceType = r1.idfsReferenceType
	JOIN dbo.trtBaseReference r2 ON r2.idfsBaseReference = fa.SystemFunctionOperationID
	WHERE ut.idfUserID = @idfuserid
		AND fa.intRowStatus = 0
		AND (fa.idfEmployee = @EmployeeID AND @EmployeeID IS NOT NULL)
	ORDER BY 
		r1.strDefault;

END
