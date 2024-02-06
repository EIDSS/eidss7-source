
--================================================================================================
-- Author:		Mani Govindarajan
-- Create date: 05.07.2019
-- Description:	Retrieve a list of Roles and Permissions for the given user by role and by employee by Organization
-- 
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Mani

-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ASPNetUser_GetRolesAndPermissionsByOrg]
	@idfuserid BIGINT
	,@OrgId BIGINT
	,@EmployeeID BIGINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

		DECLARE @aspNetUserId NVARCHAR(128);
		DECLARE @userId bigint;

		
		SELECT @aspNetUserId = u.Id
		FROM dbo.AspNetUsers u
		WHERE u.idfUserID = @idfuserid

		select @userId = ei.idfUserId from EmployeeToInstitution ei
		where ei.aspNetUserId = @aspNetUserId and ei.idfInstitution = @OrgId

		SELECT 
			fa.idfEmployee
			,r1.idfsBaseReference PermissionId
			,'Employee' AS  [Role]
			,r1.strDefault Permission
			,r2.idfsBaseReference PermissionLevelId
			,r2.strDefault PermissionLevel
		FROM dbo.tstUserTable ut
		JOIN dbo.tlbPerson p ON p.idfPerson = ut.idfPerson
		Join dbo.tlbEmployee e on e.idfEmployee= p.idfPerson
		JOIN dbo.LkupRoleSystemFunctionAccess fa ON fa.idfEmployee =  e.idfEmployee
		JOIN dbo.trtBaseReference r1 ON r1.idfsBaseReference = fa.SystemFunctionID
		JOIN dbo.trtReferenceType r11 ON r11.idfsReferenceType = r1.idfsReferenceType
		JOIN dbo.trtBaseReference r2 ON r2.idfsBaseReference = fa.SystemFunctionOperationID
		WHERE ut.idfUserID = @userId
			AND p.intRowStatus = 0 
			AND e.intRowStatus = 0
			AND fa.intRowStatus = 0 

		--UNION

		---- Returned when user swtiches to another assigned organization outside of the default one.
		--SELECT 
		--	fa.idfEmployee,
		--	r1.idfsBaseReference PermissionId
		--	,'Employee' AS [Role]
		--	,r1.strDefault Permission
		--	,r2.idfsBaseReference PermissionLevelId
		--	,r2.strDefault PermissionLevel
		--FROM dbo.tstUserTable ut
		--JOIN dbo.LkupRoleSystemFunctionAccess fa ON fa.idfEmployee = ut.idfPerson 
		--	and ut.intRowStatus=0
		--JOIN dbo.trtBaseReference r1 ON r1.idfsBaseReference = fa.SystemFunctionID
		--JOIN dbo.trtReferenceType r11 ON r11.idfsReferenceType = r1.idfsReferenceType
		--JOIN dbo.trtBaseReference r2 ON r2.idfsBaseReference = fa.SystemFunctionOperationID
		--JOIN dbo.EmployeeToInstitution ei on ei.aspNetUserId= @aspNetUserId 
		--where  ei.idfInstitution = @OrgId and ei.aspNetUserId= @OrgId
		--	AND fa.intRowStatus = 0
		--	AND (fa.idfEmployee = @EmployeeID AND @EmployeeID IS NOT NULL)
		--ORDER BY 
		--	r1.strDefault;

END