


DECLARE @idfsSite BIGINT = NULL


DECLARE @tlbEmployee TABLE
(
	idfEmployee BIGINT

)

INSERT INTO @tlbEmployee
SELECT 
	idfEmployee
FROM dbo.tlbEmployee
WHERE idfEmployee IN(SELECT idfEmployeeGroup FROM dbo.tlbEmployeeGroup WHERE idfsEmployeeGroupName BETWEEN -529 AND -501 AND idfEmployee NOT BETWEEN -529 AND -501)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE [dbo].[LkupRoleSystemFunctionAccess] DISABLE TRIGGER [TR_LkupRoleSystemFunctionAccess_I_Delete]

DELETE FROM dbo.LkupRoleSystemFunctionAccess 
WHERE idfEmployee IN (SELECT * FROM @tlbEmployee)

ALTER TABLE [dbo].[LkupRoleSystemFunctionAccess] ENABLE TRIGGER [TR_LkupRoleSystemFunctionAccess_I_Delete]
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete dashboardicons/grid for GG custom roles
ALTER TABLE dbo.LkupRoleDashboardObject DISABLE TRIGGER [TR_LkupRoleDashboardObject_I_Delete]

DELETE from dbo.LkupRoleDashboardObject 
WHERE idfEmployee IN (SELECT * FROM @tlbEmployee)

ALTER TABLE dbo.LkupRoleDashboardObject ENABLE TRIGGER [TR_LkupRoleDashboardObject_I_Delete]

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE dbo.tlbEmployeeGroupMember DISABLE TRIGGER [TR_tlbEmployeeGroupMember_I_Delete]

DELETE FROM dbo.tlbEmployeeGroupMember 
WHERE idfEmployeeGroup IN (SELECT * FROM @tlbEmployee)

DELETE FROM dbo.tlbEmployeeGroupMember 
WHERE idfEmployee IN (SELECT * FROM @tlbEmployee)

ALTER TABLE dbo.tlbEmployeeGroupMember ENABLE TRIGGER [TR_tlbEmployeeGroupMember_I_Delete]

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE dbo.tlbEmployeeGroup DISABLE TRIGGER [TR_tlbEmployeeGroup_I_Delete]

DELETE FROM dbo.tlbEmployeeGroup 
WHERE idfEmployeeGroup IN (SELECT * FROM @tlbEmployee)

ALTER TABLE dbo.tlbEmployeeGroup ENABLE TRIGGER [TR_tlbEmployeeGroup_I_Delete]
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE dbo.tlbEmployee DISABLE TRIGGER [TR_tlbEmployee_I_Delete]

DELETE FROM dbo.tlbEmployee 
WHERE idfEmployee IN (SELECT * FROM @tlbEmployee)

ALTER TABLE dbo.tlbEmployee ENABLE TRIGGER [TR_tlbEmployee_I_Delete]

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------



