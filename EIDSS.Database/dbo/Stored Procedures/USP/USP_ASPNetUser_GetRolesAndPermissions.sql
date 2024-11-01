SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--================================================================================================
-- Author:		Steven L. Verner
-- Create date: 05.07.2019
-- Description:	Retrieve a list of Roles and Permissions for the given user by role and by employee
-- 
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Stephen Long    10/03/2019 Added check for row status; only return active employee group 
--                            memberships.
-- Stephen Long    05/23/2020 Added intRowStatus check on system function table.
-- Stephen Long    12/10/2020 Added employee ID parameter as optional parameter, and union for 
--                            users that are employees of multiple organizations.
-- Mani			   01/05/2021	Changed the join to use LkupRoleSystemFunctionAccess fa ON fa.RoleID = r.idfsEmployeeGroupName
-- Mani			   03/12/2021	Added employee level pemission
-- Stephen Long    01/13/2023 Updated for site filtration queries/permissions.
-- Mike Kornegay   02/07/2023 Changed Permission field in @Results to NVARCHAR(2000) because some environments fail at 200.
-- Steven Verner   05/01/2023 Somehow the permission field got set back to NVARCHAR(200).  Fixed again!
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ASPNetUser_GetRolesAndPermissions]
    @idfuserid BIGINT,
    @EmployeeID BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @idfPerson BIGINT

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


	select	@idfPerson as idfEmployee,
			sf.idfsBaseReference as [PermissionId],
			'Employee' AS [Role],
			sf.strDefault as [Permission],
			o.idfsBaseReference as [PermissionLevelId],
			o.strDefault as [PermissionLevel]
	from	dbo.trtBaseReference sf
	inner join dbo.LkupSystemFunctionToOperation sf_to_o
	on sf_to_o.SystemFunctionID = sf.idfsBaseReference
		and sf_to_o.intRowStatus = 0
	inner join dbo.trtBaseReference o
	on o.idfsBaseReference = sf_to_o.SystemFunctionOperationID
	OUTER APPLY
		(	select	top 1 lrsfa.SystemFunctionID
			from dbo.LkupRoleSystemFunctionAccess lrsfa
			where lrsfa.SystemFunctionID = sf.idfsBaseReference
					and lrsfa.SystemFunctionOperationID = sf_to_o.SystemFunctionOperationID
					and lrsfa.intRowStatus = 0
					and lrsfa.idfEmployee = @idfPerson
		) individual_perm
	OUTER APPLY
		(	select	top 1 lrsfa.SystemFunctionID
			from dbo.LkupRoleSystemFunctionAccess lrsfa
			inner join dbo.tlbEmployeeGroupMember egm
			on egm.idfEmployeeGroup = lrsfa.idfEmployee
				and egm.idfEmployee = @idfPerson
				and egm.intRowStatus = 0
			inner join	dbo.tlbEmployeeGroup eg
			on eg.idfEmployeeGroup = egm.idfEmployeeGroup
				and eg.intRowStatus = 0
			where lrsfa.SystemFunctionID = sf.idfsBaseReference
					and lrsfa.SystemFunctionOperationID = sf_to_o.SystemFunctionOperationID
					and lrsfa.intRowStatus = 0
					and individual_perm.SystemFunctionID is null
		) group_perm
	where sf.idfsReferenceType = 19000094 /*System Function*/
			and sf.intRowStatus = 0
			and (individual_perm.SystemFunctionID is not null or group_perm.SystemFunctionID is not null)

END
