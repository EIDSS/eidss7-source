
-- ===============================================================================================================
-- NAME:					USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_GETLIST
-- DESCRIPTION:				Returns a list of icons and dashboards for a user group
-- AUTHOR:					Ricky Moss
--
-- HISTORY OF CHANGES:
-- Name:				Date:		Description of change
-- ---------------------------------------------------------------------------------------------------------------
-- Ricky Moss			12/04/2019	Initial Release
-- Mani					12/23/2020  Added intRowStatus =0 for get getting the active records
-- Ann Xiong			05/18/2021	Changed do.RoleID to do.idfEmployee to fix issue caused by table LkupRoleDashboardObject column name change
--
-- EXEC USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_GETLIST -501,'grid','en',null
-- EXEC USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_GETLIST -508,'icon','en',null
-- EXEC USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_GETLIST null,'grid','en',null
-- EXEC USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_GETLIST null,'icon','en',null
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_GETLIST]
(
	@roleId BIGINT,
	@dashboardItemType NVARCHAR(50),
	@langId NVARCHAR(50),
	@user NVARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		IF @dashboardItemType = 'icon' AND @roleId IS NULL
			SELECT DISTINCT(br.idfsBaseReference), strBaseReferenceCode, snt.strDefault, snt.name as strName, PageLink 
			FROM	FN_GBL_Reference_GETList(@langId, 19000506) snt
					JOIN trtBaseReference br ON br.idfsBaseReference = snt.idfsReference
					JOIN lkupEIDSSAppObject ao 
						ON br.idfsBaseReference = ao.AppObjectNameID
					LEFT join LkupRoleDashboardObject do 
						on ao.AppObjectNameID = do.DashboardObjectID
			where	strBaseReferenceCode like '%dashB'+ @dashboardItemType + '%'
		ELSE IF @dashboardItemType = 'icon' AND @roleId IS NOT NULL
			SELECT DISTINCT(br.idfsBaseReference), strBaseReferenceCode, snt.strDefault, snt.name as strName, PageLink 
			FROM	FN_GBL_Reference_GETList(@langId, 19000506) snt
					JOIN trtBaseReference br ON br.idfsBaseReference = snt.idfsReference
					JOIN lkupEIDSSAppObject ao 
						ON br.idfsBaseReference = ao.AppObjectNameID
					LEFT join LkupRoleDashboardObject do 
						on ao.AppObjectNameID = do.DashboardObjectID
			where	strBaseReferenceCode like '%dashB'+ @dashboardItemType + '%' AND do.idfEmployee = @roleId and do.intRowStatus=0
		ELSE IF @dashboardItemType = 'grid' AND @roleId IS NULL
			select DISTINCT(br.idfsBaseReference), strBaseReferenceCode, snt.strDefault, snt.name as strName, PageLink 
			from	FN_GBL_Reference_GETList(@langId, 19000506) snt
					join trtBaseReference br on br.idfsBaseReference = snt.idfsReference
					join lkupEIDSSAppObject ao 
						on br.idfsBaseReference = ao.AppObjectNameID
					LEFT join LkupRoleDashboardObject do 
						on ao.AppObjectNameID = do.DashboardObjectID
			where	strBaseReferenceCode like '%dashB' + @dashboardItemType + '%'
		ELSE 
			select DISTINCT(br.idfsBaseReference), strBaseReferenceCode, snt.strDefault, snt.name as strName, PageLink 
			from	FN_GBL_Reference_GETList(@langId, 19000506) snt
					join trtBaseReference br on br.idfsBaseReference = snt.idfsReference
					join lkupEIDSSAppObject ao 
						on br.idfsBaseReference = ao.AppObjectNameID
					LEFT join LkupRoleDashboardObject do 
						on ao.AppObjectNameID = do.DashboardObjectID
			where	strBaseReferenceCode like '%dashB' + @dashboardItemType + '%' AND do.idfEmployee = @roleId and do.intRowStatus=0
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
