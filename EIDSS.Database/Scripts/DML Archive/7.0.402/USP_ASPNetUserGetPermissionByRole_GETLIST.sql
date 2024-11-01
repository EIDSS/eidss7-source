SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- ================================================================================================
-- Name: USP_ASPNetUserGetPermissionByRole_GETLIST
--
-- Description: Returns a list of permissions given as list of roles, if no roles are provided, 
--				then the SP will return the list of available system functions.
-- Author: Ricky Moss
--
-- Revision Log:
-- Name					Date       Description of Change
-- -------------------- ---------- ---------------------------------------------------------------
-- Ricky Moss			11/27/2019 Initial Release
-- Ricky Moss			12/11/2019 Updated Relationship between idfEmployeeGroup and 
--                                 LkupRoleSystemFunctionAccessTable
-- Ricky Moss			02/07/2019 Removed Role fields
-- Stephen Long         05/18/2020 Added access to gender and age data.
-- Stephen Long         05/23/2020 Corrected access permissions to use intRowStatus to indicate 
--                                 deny permission.  Recommend for future to use the access 
--                                 permission types defined in base reference: 
--                                 10515001 (allow) and 10515002 (deny).  Permissions were not 
--                                 returning correctly when updating from the user group page.
-- Stephen Long         05/30/2020 Added intRowStatus check to the PIVOT portions.
-- Mani					01/06/2020 Added sfa.intRowstatus=0
-- Ann Xiong			05/18/2021 Changed do.RoleID to do.idfEmployee to fix issue caused by table LkupRoleSystemFunctionAccess column name change
-- Mark Wilson			04/27/2022 added sorting by intOrder
--
-- exec USP_ASPNetUserGetPermissionByRole_GETLIST '-501,-508,389445040000888', @LangId
-- exec USP_ASPNetUserGetPermissionByRole_GETLIST -501, 'en-US'
-- ================================================================================================
CREATE or ALTER PROCEDURE [dbo].[USP_ASPNetUserGetPermissionByRole_GETLIST] 
	(
	@strEmployees NVARCHAR(MAX), -- Comma seperated list of employees or user groups to be deleted as BIGINT
	@LangId NVARCHAR(50) = 'en'
	)
AS
DECLARE @employeeRoleID TABLE (employeeRoleID  BIGINT NOT NULL, blnGroup bit not null default(0));


BEGIN
	BEGIN TRY

		IF @strEmployees IS NOT NULL -- When Role and/or EmployeeID is passed, return system function assigned to each
		begin
				INSERT	@employeeRoleID (employeeRoleID, blnGroup)
				SELECT	case when split.[value] is not null and ISNUMERIC(split.[value]) = 1 then cast(split.[value] as bigint) else -100000000 end,
						case when eg.idfEmployeeGroup is not null then 1 else 0 end
				FROM	STRING_SPLIT(@strEmployees, ',') split
				left join	dbo.tlbEmployeeGroup eg
				on			cast(eg.idfEmployeeGroup as nvarchar) = split.[value] collate Cyrillic_General_CI_AS
							and eg.intRowStatus = 0
				where	split.[value] is not null and ISNUMERIC(split.[value]) = 1

		select    [RoleID]
				, [SystemFunctionId]
				, [Permission]
				, [10059003] as ReadPermission
				, [10059004] as WritePermission
				, [10059001] as CreatePermission
				, [10059005] as ExecutePermission
				, [10059002] as DeletePermission
				, [10059006] as AccessToPersonalDataPermission
				, [10059007] as AccessToGenderAndAgeDataPermission

			from
			(
				select	er.employeeRoleID as [RoleID],
						sf.idfsReference as [SystemFunctionId],
						sf.[name] as [Permission],
						sf_to_o.SystemFunctionOperationID,
						sf.intOrder,
						isnull(individual_perm.intPermission, group_perm.intPermission) as intPermission
		from	dbo.FN_GBL_Reference_GETList(@LangId, 19000094) sf
		inner join	dbo.LkupSystemFunctionToOperation sf_to_o
				on	sf_to_o.SystemFunctionID = sf.idfsReference
					and sf_to_o.intRowStatus = 0
		cross join	@employeeRoleID er
		OUTER APPLY
			(	select	top 1 cast(0 as int) as intPermission
				from dbo.LkupRoleSystemFunctionAccess lrsfa
				where lrsfa.SystemFunctionID = sf.idfsReference
						and lrsfa.SystemFunctionOperationID = sf_to_o.SystemFunctionOperationID
						and lrsfa.intRowStatus = 0
						and lrsfa.idfEmployee = er.employeeRoleID
			) individual_perm
		OUTER APPLY
			(	select	top 1 cast(0 as int) as intPermission
				from dbo.LkupRoleSystemFunctionAccess lrsfa
				inner join dbo.tlbEmployeeGroupMember egm
				on egm.idfEmployeeGroup = lrsfa.idfEmployee
					and egm.idfEmployee = er.employeeRoleID
					and egm.intRowStatus = 0
				inner join	dbo.tlbEmployeeGroup eg
				on eg.idfEmployeeGroup = egm.idfEmployeeGroup
					and eg.intRowStatus = 0
				where lrsfa.SystemFunctionID = sf.idfsReference
						and lrsfa.SystemFunctionOperationID = sf_to_o.SystemFunctionOperationID
						and lrsfa.intRowStatus = 0
						and er.blnGroup = 0
						and individual_perm.intPermission is null
			) group_perm
			) p
			pivot
			(	max(p.intPermission)
				for p.SystemFunctionOperationID in 
					(
						[10059001], [10059002], [10059003], [10059004], [10059005], [10059006], [10059007]
					)
			) as pvt
			order by [intOrder], [Permission]

		end
		else  -- Return all system functions
			SELECT 
				cast(0 as bigint) [RoleID],
				sf.idfsReference as [SystemFunctionId],
				sf.[name] [Permission],
				cast(0 as int) AS ReadPermission,
				cast(0 as int) AS WritePermission,
				cast(0 as int) AS CreatePermission,
				cast(0 as int) AS ExecutePermission,
				cast(0 as int) AS DeletePermission,
				cast(0 as int) AS AccessToPersonalDataPermission,
				cast(0 as int) AS AccessToGenderAndAgeDataPermission
			FROM dbo.FN_GBL_Reference_GETList(@LangId, 19000094) sf
			order by sf.intOrder

	END TRY

	BEGIN CATCH
		THROW
	END CATCH
END
