-- -- ============================================================================
-- Name: [USSP_GBL_SITE_CUSTOMUSERGROUUP_SET]
-- Description: Insert Site Custom User Roles from CDR Site
--                      
-- Author: Mani -  02/5/2023 Copied from Mark's Script
-- History

 --Manickandan Govindarajan  02/16/2023 Added insert statments for inserting dashboard icon and grid records into LkupRoleDashboardObject for e7 custom roles

-- ============================================================================


CREATE PROCEDURE [dbo].[USSP_GBL_SITE_CUSTOMUSERGROUP_SET] (
	@SiteId bigint
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @tlbEmployeeGroup TABLE
(
	idfsEmployeeGroupName BIGINT,
	idfsSite BIGINT,
	strName NVARCHAR(200),
	strDescription NVARCHAR(200)

)
INSERT INTO @tlbEmployeeGroup
(
	idfsEmployeeGroupName,
	idfsSite,
	strName,
	strDescription
	
)

SELECT 
	T.idfsEmployeeGroupName,
	@siteId,
	T.strName,
	T.strDescription
	

FROM dbo.tlbEmployeeGroup T
INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup
CROSS APPLY dbo.tstSite Sites
WHERE T.idfEmployeeGroup IN (-501, -506, -513, -514, -515, -516, -517, -518, -519, -520, -521, -522, -523, -524, -525, -526, -527, -528, -529)
AND Sites.idfsSite =  dbo.FN_GBL_SITEID_GET()

DECLARE @idfEmployeeGroup BIGINT;
DECLARE @idfEmployee BIGINT;
DECLARE @idfsEmployeeGroupName BIGINT;
DECLARE @idfsSite BIGINT;
DECLARE @strName NVARCHAR(200);
DECLARE @strDescription NVARCHAR(200);

DECLARE tlbEmployeeGroup_cursor CURSOR FOR
SELECT
	idfsEmployeeGroupName,
	@siteId,
	strName,
	strDescription
FROM @tlbEmployeeGroup

OPEN tlbEmployeeGroup_cursor;

FETCH NEXT FROM tlbEmployeeGroup_cursor INTO @idfsEmployeeGroupName, @idfsSite, @strName, @strDescription;
WHILE @@FETCH_STATUS = 0
BEGIN

	
		
		
		EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbEmployee',
		@idfsKey = @idfEmployee OUTPUT

		INSERT INTO dbo.tlbEmployee
		(
			idfEmployee,
			idfsEmployeeType,
			idfsSite,
			intRowStatus,
			rowguid,
			SourceSystemNameID,
			SourceSystemKeyValue,
			AuditCreateUser,
			AuditCreateDTM,
			idfsEmployeeCategory
		)

		SELECT

			@idfEmployee,
			10023001,
			@idfsSite,
			0,
			NEWID(),
			10519001,
			'[{"idfEmployee":' + CAST(@idfEmployee AS NVARCHAR(24)) + '}]',
			'System',
			GETDATE(),
			10526002


		INSERT INTO dbo.tlbEmployeeGroup
		(
			idfEmployeeGroup,
			idfsEmployeeGroupName,
			idfsSite,
			strName,
			strDescription,
			rowguid,
			intRowStatus,
			SourceSystemNameID,
			SourceSystemKeyValue,
			AuditCreateUser,
			AuditCreateDTM
		)
		SELECT
			@idfEmployee,
			@idfsEmployeeGroupName,
			@idfsSite,
			@strName,
			@strDescription,
			NEWID(),
			0,
			10519001,
			'[{"idfEmployeeGroup":' + CAST(@idfEmployeeGroup AS NVARCHAR(24)) + '}]',
			'System',
			GETDATE()


	IF NOT EXISTS (SELECT * FROM dbo.LkupRoleSystemFunctionAccess WHERE idfEmployee = @idfEmployee)
	BEGIN
		INSERT INTO dbo.LkupRoleSystemFunctionAccess
		(
			idfEmployee,
			SystemFunctionID,
			SystemFunctionOperationID,
			AccessPermissionID,
			intRowStatus,
			AuditCreateUser,
			AuditCreateDTM,
			rowguid,
			SourceSystemNameID,
			SourceSystemKeyValue,
			intRowStatusForSystemFunction
		)

		SELECT
			@idfEmployee,
			SystemFunctionID,
			SystemFunctionOperationID,
			AccessPermissionID,
			r.intRowStatus,
			'System',
			GETDATE(),
			NEWID(),
			10519001,
			'{"idfEmployee":-' + CAST(@idfEmployee AS NVARCHAR(24)) + ',"SystemFunctionID":' + CAST(SystemFunctionID AS NVARCHAR(24)) + '}',
			intRowStatusForSystemFunction
		FROM dbo.LkupRoleSystemFunctionAccess r
			inner join tlbEmployeeGroup eg on eg.idfEmployeeGroup = r.idfEmployee
		WHERE idfEmployee = @idfsEmployeeGroupName  and eg.idfsSite =  dbo.FN_GBL_SITEID_GET()

	END

    /*--dashboard objects**/

	IF NOT EXISTS (SELECT * FROM dbo.LkupRoleDashboardObject WHERE idfEmployee = @idfEmployee)
	BEGIN
		INSERT INTO dbo.LkupRoleDashboardObject
		(
		    idfEmployee,
		    DashboardObjectID,
		    DisplayName,
		    DisplayOrder,
		    intRowStatus,
		    AuditCreateUser,
		    AuditCreateDTM,
		    AuditUpdateUser,
		    AuditUpdateDTM,
		    rowguid,
		    SourceSystemNameID,
		    SourceSystemKeyValue
		)

		SELECT
			@idfEmployee,
			DashboardObjectID,
		    DisplayName,
		    DisplayOrder,
		    r.intRowStatus,
		    'System',
		    GETDATE(),
		    r.AuditUpdateUser,
		    GETDATE(),
		    NEWID(),
			10519001,
			'{"idfEmployee":-' + CAST(@idfEmployee AS NVARCHAR(24)) + ',"DashboardObjectID":' + CAST(DashboardObjectID AS NVARCHAR(24)) + '}'
				FROM dbo.LkupRoleDashboardObject r
			inner join tlbEmployeeGroup eg on eg.idfEmployeeGroup = r.idfEmployee
		WHERE idfEmployee = @idfsEmployeeGroupName  and eg.idfsSite =  dbo.FN_GBL_SITEID_GET()

	END

	FETCH NEXT FROM tlbEmployeeGroup_cursor INTO @idfsEmployeeGroupName, @SiteId, @strName, @strDescription;

END


CLOSE tlbEmployeeGroup_cursor;
DEALLOCATE tlbEmployeeGroup_cursor;

END



