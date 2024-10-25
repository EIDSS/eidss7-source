/*
Table [dbo].[ZZZ_OutbreakStatus] is being dropped.  Deployment will halt if the table contains data.
*/


GO
DROP TABLE [dbo].[ZZZ_OutbreakStatus];


GO
PRINT N'Creating Table [dbo].[gisImportedMap]...';


GO
CREATE TABLE [dbo].[gisImportedMap] (
    [idfImportedMap]       BIGINT           NOT NULL,
    [strMapName]           NVARCHAR (200)   NULL,
    [strMapFullFileName]   NVARCHAR (2048)  NULL,
    [idfsSite]             BIGINT           NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL,
    [intRowStatus]         INT              NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    [geoJson]              NVARCHAR (MAX)   NULL,
    CONSTRAINT [XPKgisImportedMap] PRIMARY KEY CLUSTERED ([idfImportedMap] ASC) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];


GO
PRINT N'Creating Table [dbo].[gisImportedMapGeometry]...';


GO
CREATE TABLE [dbo].[gisImportedMapGeometry] (
    [idfsGISImportedMapGeometry] BIGINT           NOT NULL,
    [idfsGISImportedMap]         BIGINT           NOT NULL,
    [geomShape]                  [sys].[geometry] NULL,
    [rowguid]                    UNIQUEIDENTIFIER NOT NULL,
    [intRowStatus]               INT              NOT NULL,
    [strMaintenanceFlag]         NVARCHAR (20)    NULL,
    [strReservedAttribute]       NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]         BIGINT           NULL,
    [SourceSystemKeyValue]       NVARCHAR (MAX)   NULL,
    [AuditCreateUser]            NVARCHAR (200)   NULL,
    [AuditCreateDTM]             DATETIME         NULL,
    [AuditUpdateUser]            NVARCHAR (200)   NULL,
    [AuditUpdateDTM]             DATETIME         NULL,
    CONSTRAINT [XPKgisImportedMapGeometry] PRIMARY KEY CLUSTERED ([idfsGISImportedMapGeometry] ASC) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];


GO
PRINT N'Creating Table [dbo].[gisImportedMapLayer]...';


GO
CREATE TABLE [dbo].[gisImportedMapLayer] (
    [idfImportedMapLayer]  BIGINT           NOT NULL,
    [idfsImportedMap]      BIGINT           NOT NULL,
    [strGeoJson]           NVARCHAR (MAX)   NULL,
    [rowguid]              UNIQUEIDENTIFIER NOT NULL,
    [intRowStatus]         INT              NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKgisImportedMapGeoJsonLayer] PRIMARY KEY CLUSTERED ([idfImportedMapLayer] ASC) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];


GO
PRINT N'Creating Default Constraint [dbo].[newid__gisImportedMap]...';


GO
ALTER TABLE [dbo].[gisImportedMap]
    ADD CONSTRAINT [newid__gisImportedMap] DEFAULT (newid()) FOR [rowguid];


GO
PRINT N'Creating Default Constraint [dbo].[DF__gisImportedMap__intRo__2819E74A]...';


GO
ALTER TABLE [dbo].[gisImportedMap]
    ADD CONSTRAINT [DF__gisImportedMap__intRo__2819E74A] DEFAULT ((0)) FOR [intRowStatus];


GO
PRINT N'Creating Default Constraint [dbo].[DF_gisImportedMap_CreateDTM]...';


GO
ALTER TABLE [dbo].[gisImportedMap]
    ADD CONSTRAINT [DF_gisImportedMap_CreateDTM] DEFAULT (getdate()) FOR [AuditCreateDTM];


GO
PRINT N'Creating Default Constraint [dbo].[newid__gisImportedMapGeometry]...';


GO
ALTER TABLE [dbo].[gisImportedMapGeometry]
    ADD CONSTRAINT [newid__gisImportedMapGeometry] DEFAULT (newid()) FOR [rowguid];


GO
PRINT N'Creating Default Constraint [dbo].[DF__gisImport__intRo__7F4F0C1C]...';


GO
ALTER TABLE [dbo].[gisImportedMapGeometry]
    ADD CONSTRAINT [DF__gisImport__intRo__7F4F0C1C] DEFAULT ((0)) FOR [intRowStatus];


GO
PRINT N'Creating Default Constraint [dbo].[DF_gisImportedMapGeometry_CreateDTM]...';


GO
ALTER TABLE [dbo].[gisImportedMapGeometry]
    ADD CONSTRAINT [DF_gisImportedMapGeometry_CreateDTM] DEFAULT (getdate()) FOR [AuditCreateDTM];


GO
PRINT N'Creating Default Constraint <unnamed>...';


GO
ALTER TABLE [dbo].[gisImportedMapLayer]
    ADD DEFAULT ((0)) FOR [intRowStatus];


GO
PRINT N'Creating Foreign Key [dbo].[FK_gisImportedMap_trtBaseReference_SourceSystemNameID]...';


GO
ALTER TABLE [dbo].[gisImportedMap] WITH NOCHECK
    ADD CONSTRAINT [FK_gisImportedMap_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_gisImportedMap_tstSite__idfsSite]...';


GO
ALTER TABLE [dbo].[gisImportedMap] WITH NOCHECK
    ADD CONSTRAINT [FK_gisImportedMap_tstSite__idfsSite] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION;


GO
PRINT N'Altering Function [dbo].[fnGetLastCharIndexOfSubstringInNonTrimString]...';


GO
--##SUMMARY Gets the last index of presence of the specified substring in the specified original string
--##SUMMARY with optional right-to-left direction of the text.
--##SUMMARY If an original string doesn't contain specifed substring, the returns -1.

--##REMARKS Author: 
--##REMARKS Create date: 24.02.2014

--##RETURNS int


/*
declare	@s nvarchar(2000) = N'  ascvn .lklokj lk   '

select dbo.fnGetLastCharIndexOfSubstringInNonTrimString(@s, N'lk', 0)
*/	

ALTER function [dbo].[fnGetLastCharIndexOfSubstringInNonTrimString]
(
	@SourceStr nvarchar(4000),	--##PARAM @SourceStr - string value to find the last presence of substring
	@SubStr nvarchar(4000),		--##PARAM @SubStr - string value to find as substring in source string
	@IsRTL bit = 0				--##PARAM @IsRTL - indicator whether the string is right to left or regular
)
returns int
as 
begin

declare @str nvarchar(4000) = ltrim(rtrim(@SourceStr))
declare	@CurPos int = -1
declare	@LastPos int = -1

if	@IsRTL = 1
begin
	set	@LastPos = CHARINDEX(@SubStr, @str, 0)
end
else begin
	declare	@len int = len(@str)


	while @CurPos < @len
	begin
		set @CurPos = CHARINDEX(@SubStr, @str, @CurPos + 1)
		if @CurPos <= 0
			set @CurPos = @len + 1
		else
			set	@LastPos = @CurPos
	end
end

return @LastPos

end
GO
PRINT N'Altering Function [dbo].[fnGetAttributesFromFormattedString]...';


GO
ALTER FUNCTION [dbo].[fnGetAttributesFromFormattedString]
(
	@param1 int,
	@param2 char(5)
)
RETURNS @returntable TABLE
(
	c1 int,
	c2 char(5)
)
AS
BEGIN
	INSERT @returntable
	SELECT @param1, @param2
	RETURN
END
GO
PRINT N'Creating Function [dbo].[FN_GBL_AVR_LocationHierarchy_Flattened]...';


GO

-- =============================================
-- Author:		Steven Verner
-- Create date: 12/1/2021
-- Description:	Returns the complete location hierarchy for the given location on a single row.
-- =============================================
CREATE FUNCTION [dbo].[FN_GBL_AVR_LocationHierarchy_Flattened] 
(
	--@languageId nvarchar(20)
)
RETURNS @ResultsTable TABLE 
(
	 idfsLocation BIGINT
	,AdminLevel1ID BIGINT
	,AdminLevel2ID BIGINT
	,AdminLevel3ID BIGINT
	,AdminLevel4ID BIGINT
	,AdminLevel5ID BIGINT
	,AdminLevel6ID BIGINT
	,AdminLevel7ID BIGINT
	,AdminLevel1Name NVARCHAR(200)
	,AdminLevel2Name NVARCHAR(200)
	,AdminLevel3Name NVARCHAR(200)
	,AdminLevel4Name NVARCHAR(200)
	,AdminLevel5Name NVARCHAR(200)
	,AdminLevel6Name NVARCHAR(200)
	,AdminLevel7Name NVARCHAR(200)
	,Node HIERARCHYID
	,Level INT
	,LevelType NVARCHAR(100)
	,idfsLanguage BIGINT

)
AS
BEGIN
	--DECLARE @lid BIGINT 

	--SELECT @lid = dbo.FN_GBL_LanguageCode_GET(@languageId)

	INSERT INTO @ResultsTable
	SELECT 
		 ld.idfsLocation
		,ld.Level1ID
		,ld.Level2ID
		,ld.Level3ID
		,ld.Level4ID
		,ld.Level5ID
		,ld.Level6ID
		,ld.Level7ID
		,ld.Level1Name
		,ld.Level2Name
		,ld.Level3Name
		,ld.Level4Name
		,ld.Level5Name
		,ld.Level6Name
		,ld.Level7Name
		,ld.Node
		,ld.Level
		,ld.LevelType
		,ld.idfsLanguage
	FROM gisLocationDenormalized ld
	--WHERE ld.idfsLanguage =@lid
	
	RETURN 
END;
GO
PRINT N'Creating View [dbo].[AVR_VW_Location_Farm]...';


GO
CREATE VIEW [AVR_VW_Location_Farm]
    as

    SELECT   
       gls.strPostCode,
       gf.AdminLevel2ID ,
       gls.intRowStatus,
       gf.idfsLanguage as idfsLanguage,
       gf.AdminLevel4ID,
       gf.AdminLevel3ID,
       gls.dblLatitude,
       gls.dblLongitude,
       gf.AdminLevel1ID,
       gls.idfsGeoLocationType,
       gls.blnForeignAddress,
       gls.strForeignAddress,
       gf.idfsLocation,
       gls.idfGeoLocationShared
FROM dbo.tlbGeoLocationShared gls
    LEFT JOIN FN_GBL_AVR_LocationHierarchy_Flattened() gf
        on gf.idfsLocation = gls.idfsLocation  AND gls.intRowStatus = 0
GO
PRINT N'Creating View [dbo].[AVR_VW_Location_Human]...';


GO
CREATE VIEW [dbo].[AVR_VW_Location_Human]
    as

    SELECT   
       gls.strPostCode,
       gf.AdminLevel2ID ,
       gls.intRowStatus,
       gf.idfsLanguage as idfsLanguage,
       gf.AdminLevel4ID,
       gf.AdminLevel3ID,
       gls.dblLatitude,
       gls.dblLongitude,
       gf.AdminLevel1ID,
       gls.idfsGeoLocationType,
       gls.blnForeignAddress,
       gls.strForeignAddress,
       gf.idfsLocation,
       gls.idfGeoLocationShared
FROM dbo.tlbGeoLocationShared gls
    LEFT JOIN FN_GBL_AVR_LocationHierarchy_Flattened() gf
        on gf.idfsLocation = gls.idfsLocation  AND gls.intRowStatus = 0
GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_SET]...';


GO
-- ===============================================================================================================
-- NAME:					USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_SET
-- DESCRIPTION:				Creates or reactivates a relationship between role and dashboard item
-- AUTHOR:					Ricky Moss
--
-- HISTORY OF CHANGES:
-- Name:				Date:		Description of change
-- ---------------------------------------------------------------------------------------------------------------
-- Ricky Moss			12/04/2019	Initial Release
-- Ann Xiong			05/26/2021	Changed RoleID to idfEmployee to fix issue caused by table LkupRoleDashboardObject column name change
-- Ann Xiong			04/25/2023 Implemented Data Audit and added parameter @idfDataAuditEvent	
--
--
-- EXEC USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_SET
-- ===============================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_SET]
(
	@roleID BIGINT,
	@strDashboardObject NVARCHAR(1000),
    @idfDataAuditEvent BIGINT = NULL,
	@user NVARCHAR(50)
)
AS
DECLARE @returnCode			INT				= 0 
DECLARE	@returnMsg			NVARCHAR(MAX)	= 'SUCCESS' 
DECLARE @SupressSelect TABLE (retrunCode INT, returnMessage VARCHAR(200))
DECLARE @tempDashboardObjectID TABLE  (DashboardObjectID BIGINT)
DECLARE @DashboardObject BIGINT

		--Data Audit--
		DECLARE @idfUserId BIGINT = NULL;
		DECLARE @idfSiteId BIGINT = NULL;
		DECLARE @idfsDataAuditEventType bigint = NULL;
		DECLARE @idfsObjectType bigint = 10017058; 					-- User Group --
		DECLARE @idfObject bigint = @roleID;
		DECLARE @idfObjectTable_LkupRoleDashboardObject bigint = 53577790000012;
		--DECLARE @idfDataAuditEvent BIGINT = NULL;

		-- Get and Set UserId and SiteId
		SELECT @idfUserId = userInfo.UserId, @idfSiteId = UserInfo.SiteId FROM dbo.FN_UserSiteInformation(@user) userInfo
		--Data Audit--

BEGIN
	BEGIN TRY
		INSERT INTO @tempDashboardObjectID SELECT VALUE AS DashboardObjectID FROM STRING_SPLIT(@strDashboardObject,',');
		UPDATE LkupRoleDashboardObject SET intRowStatus = 1 WHERE idfEmployee = @roleID AND intRowStatus = 0

      IF @idfDataAuditEvent IS NOT NULL
      BEGIN 
        -- data audit
		DECLARE @DashboardObjectID bigint = NULL;
		DECLARE @DashboardObjectIDsToDelete TABLE
        (
            DashboardObjectID BIGINT NOT NULL
        );

        INSERT INTO @DashboardObjectIDsToDelete
        SELECT DashboardObjectID
	    FROM dbo.LkupRoleDashboardObject
		WHERE idfEmployee = @roleID AND intRowStatus = 0

        WHILE EXISTS (SELECT * FROM @DashboardObjectIDsToDelete)
        BEGIN
            SELECT TOP 1
                @DashboardObjectID = DashboardObjectID
            FROM @DashboardObjectIDsToDelete;
            BEGIN
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail )
					SELECT @idfDataAuditEvent, @idfObjectTable_LkupRoleDashboardObject, @roleID, @DashboardObjectID
            END

            DELETE FROM @DashboardObjectIDsToDelete
            WHERE DashboardObjectID = @DashboardObjectID;
        END
        -- End data audit
	  END

		WHILE(SELECT COUNT(DashboardObjectID) FROM @tempDashboardObjectID) > 0
		BEGIN
			SELECT @DashboardObject = (SELECT TOP 1 (DashboardObjectID) FROM @tempDashboardObjectID)
			IF EXISTS(SELECT DashboardObjectID FROM LkupRoleDashboardObject WHERE DashboardObjectID = @DashboardObject AND idfEmployee = @roleID)
			BEGIN
				--Data Audit--
				DECLARE @intRowStatusOld INT = NULL;
 				SELECT @intRowStatusOld = intRowStatus FROM dbo.LkupRoleDashboardObject WHERE idfEmployee = @roleID AND DashboardObjectID = @DashboardObject;
 				--Data Audit--

				UPDATE LkupRoleDashboardObject SET intRowStatus = 0  WHERE idfEmployee = @roleID AND DashboardObjectID = @DashboardObject

				IF @idfDataAuditEvent IS NOT NULL
				BEGIN 
				--Data Audit--
				insert into dbo.tauDataAuditDetailUpdate(
							idfDataAuditEvent, idfObjectTable, idfColumn, 
							idfObject, idfObjectDetail, 
							strOldValue, strNewValue)
				select		@idfDataAuditEvent,@idfObjectTable_LkupRoleDashboardObject, 51586990000121,
							@roleID,@DashboardObject,
							@intRowStatusOld,0
				 WHERE (@intRowStatusOld <> 0)
				--Data Audit--
				END
			END
			ELSE
			BEGIN
				INSERT INTO LkupRoleDashboardObject (idfEmployee, DashboardObjectID, intRowStatus) VALUES (@roleID, @DashboardObject, 0)

				IF @idfDataAuditEvent IS NOT NULL
				BEGIN 
				--Data Audit--
				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail )
						values ( @idfDataAuditEvent, @idfObjectTable_LkupRoleDashboardObject, @roleID, @DashboardObject)
				--Data Audit--
				END
			END
			DELETE FROM @tempDashboardObjectID WHERE DashboardObjectID = @DashboardObject
		END
		SELECT @returnCode ReturnCode, @returnMsg as ReturnMessage
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK
			END

		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();
		SET @returnCode = ERROR_NUMBER();

		SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage;
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SET]...';


GO
-- ================================================================================================
-- Name: USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SET
--
-- Description:	Creates and/or removes at relationship between a role, system function, and 
-- operation.
--                      
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		12/12/2019 Initial release.
-- Ricky Moss		03/25/2020 Passes in all roles, system functions, and operations at once
-- Ricky Moss		03/26/2020 Add intRowStatus to Merge Query
-- Stephen Long     05/28/2020 Changed 0 for intRowStatus on insert to use intRowStatus supplied 
--                             in the JSON.  A permission may be inserted as denied, so in this 
--                             case an intRowStatus of 1 would be used.
-- Ann Xiong		04/13/2023 Implemented Data Audit
-- Ann Xiong		04/25/2023 Added parameter @idfDataAuditEvent
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SET] (
	@rolesandfunctions NVARCHAR(MAX),
    @idfDataAuditEvent BIGINT = NULL,
	@user NVARCHAR(50)
	)
AS
DECLARE @tempRSFA TABLE (
	RoleID BIGINT,
	SystemFunctionID BIGINT,
	SystemFunctionOperationID BIGINT,
	intRowStatus INT,
	intRowStatusForSystemFunction INT
	)
DECLARE @returnCode INT = 0
DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS'
DECLARE @modifiedJSON NVARCHAR(MAX)

		--Data Audit--
		declare @idfUserId BIGINT = NULL;
		declare @idfSiteId BIGINT = NULL;
		declare @idfsDataAuditEventType bigint = NULL;
		declare @idfsObjectType bigint = 10017052;                         -- System Function
		declare @idfObject bigint = NULL;
		declare @idfObjectTable_LkupRoleSystemFunctionAccess bigint = 53577790000006;
		--declare @idfDataAuditEvent bigint= NULL;

		CREATE TABLE #Output  
 		(
			DidfEmployee BIGINT,
			DSystemFunctionID BIGINT,
			DSystemFunctionOperationID BIGINT,
			DAccessPermissionID BIGINT,
			DintRowStatus INT,
     		DAuditCreateUser nvarchar(100),  
     		DAuditCreateDTM datetime,  
     		DAuditUpdateUser nvarchar(100),  
     		DAuditUpdateDTM datetime,  
     		Drowguid uniqueidentifier,  
     		DSourceSystemNameID BIGINT,  
     		DSourceSystemKeyValue nvarchar(max),  
			DintRowStatusForSystemFunction INT,
     		ActionTaken nvarchar(10),  
			IidfEmployee BIGINT,
			ISystemFunctionID BIGINT,
			ISystemFunctionOperationID BIGINT,
			IAccessPermissionID BIGINT,
			IintRowStatus INT,
     		IAuditCreateUser nvarchar(100),  
     		IAuditCreateDTM datetime,  
     		IAuditUpdateUser nvarchar(100),  
     		IAuditUpdateDTM datetime,  
     		Irowguid uniqueidentifier,  
     		ISourceSystemNameID BIGINT,  
     		ISourceSystemKeyValue nvarchar(max),  
			IintRowStatusForSystemFunction INT     
		); 

		CREATE TABLE #Output2  
 		(
			DidfEmployee BIGINT,
			DSystemFunctionID BIGINT,
			DSystemFunctionOperationID BIGINT,
			DAccessPermissionID BIGINT,
			DintRowStatus INT,
     		DAuditCreateUser nvarchar(100),  
     		DAuditCreateDTM datetime,  
     		DAuditUpdateUser nvarchar(100),  
     		DAuditUpdateDTM datetime,  
     		Drowguid uniqueidentifier,  
     		DSourceSystemNameID BIGINT,  
     		DSourceSystemKeyValue nvarchar(max),  
			DintRowStatusForSystemFunction INT,
     		ActionTaken nvarchar(10),  
			IidfEmployee BIGINT,
			ISystemFunctionID BIGINT,
			ISystemFunctionOperationID BIGINT,
			IAccessPermissionID BIGINT,
			IintRowStatus INT,
     		IAuditCreateUser nvarchar(100),  
     		IAuditCreateDTM datetime,  
     		IAuditUpdateUser nvarchar(100),  
     		IAuditUpdateDTM datetime,  
     		Irowguid uniqueidentifier,  
     		ISourceSystemNameID BIGINT,  
     		ISourceSystemKeyValue nvarchar(max),  
			IintRowStatusForSystemFunction INT     
		) 

		CREATE TABLE #OutputI  
 		(
			DidfEmployee BIGINT,
			DSystemFunctionID BIGINT,
			DSystemFunctionOperationID BIGINT,
			DAccessPermissionID BIGINT,
			DintRowStatus INT,
     		DAuditCreateUser nvarchar(100),  
     		DAuditCreateDTM datetime,  
     		DAuditUpdateUser nvarchar(100),  
     		DAuditUpdateDTM datetime,  
     		Drowguid uniqueidentifier,  
     		DSourceSystemNameID BIGINT,  
     		DSourceSystemKeyValue nvarchar(max),  
			DintRowStatusForSystemFunction INT,
     		ActionTaken nvarchar(10),  
			IidfEmployee BIGINT,
			ISystemFunctionID BIGINT,
			ISystemFunctionOperationID BIGINT,
			IAccessPermissionID BIGINT,
			IintRowStatus INT,
     		IAuditCreateUser nvarchar(100),  
     		IAuditCreateDTM datetime,  
     		IAuditUpdateUser nvarchar(100),  
     		IAuditUpdateDTM datetime,  
     		Irowguid uniqueidentifier,  
     		ISourceSystemNameID BIGINT,  
     		ISourceSystemKeyValue nvarchar(max),  
			IintRowStatusForSystemFunction INT     
		) 

		-- Get and Set UserId and SiteId
		select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation(@user) userInfo

		--Data Audit--

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		INSERT INTO @tempRSFA
		SELECT *
		FROM OPENJSON(@rolesandfunctions) WITH (
				RoleID BIGINT '$.RoleId',
				SystemFunctionID BIGINT '$.SystemFunction',
				SystemFunctionOperationID BIGINT '$.Operation',
				intRowStatus BIGINT,
				intRowStatusForSystemFunction BIGINT
				)
		
		MERGE dbo.LkupRoleSystemFunctionAccess rsfa
		USING @tempRSFA t
			ON (
					t.RoleID = rsfa.idfEmployee
					AND t.SystemFunctionID = rsfa.SystemFunctionID
					AND t.SystemFunctionOperationID = rsfa.SystemFunctionOperationID
					--AND (t.intRowStatusForSystemFunction = rsfa.intRowStatusForSystemFunction OR rsfa.intRowStatusForSystemFunction is NULL)
					)
		WHEN MATCHED
			THEN
				UPDATE
				SET rsfa.intRowStatus = t.IntRowStatus, rsfa.intRowStatusForSystemFunction= t.intRowStatusForSystemFunction
		WHEN NOT MATCHED BY TARGET
			THEN
				INSERT (
					idfEmployee,
					SystemFunctionID,
					SystemFunctionOperationID,
					intRowStatus,
					intRowStatusForSystemFunction,
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateUser
					)
				VALUES (
					t.RoleID,
					t.SystemFunctionID,
					t.SystemFunctionOperationID,
					t.intRowStatus,
					t.intRowStatusForSystemFunction,
					10519001,
					'[{"idfEmployee":' + CAST(t.RoleID AS NVARCHAR(100)) + '"SystemFunctionID":' + CAST(t.SystemFunctionID AS NVARCHAR(100)) + '"SystemFunctionOperationID":' + CAST(t.SystemFunctionOperationID AS NVARCHAR(100)) + '}]',
					@user
					)

		OUTPUT DELETED.*, $action AS [Action], INSERTED.* INTO #Output;

		--Data Audit--
		DECLARE @RoleID BIGINT 
		SELECT TOP 1 @RoleID =  RoleID From @tempRSFA;

        IF @idfDataAuditEvent IS NULL
        BEGIN 
			--  tauDataAuditEvent  Event Type- Edit 
			set @idfsDataAuditEventType =10016003;
			-- insert record into tauDataAuditEvent - 
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@RoleID, @idfObjectTable_LkupRoleSystemFunctionAccess, @idfDataAuditEvent OUTPUT
		END

		INSERT INTO #Output2
		SELECT *
		FROM #Output
		Where ActionTaken = 'UPDATE'

		DECLARE @DidfEmployee BIGINT,
			@DSystemFunctionID BIGINT,
			@DSystemFunctionOperationID BIGINT,
			@DintRowStatus INT,
			@DintRowStatusForSystemFunction INT,
			@IidfEmployee BIGINT,
			@ISystemFunctionID BIGINT,
			@ISystemFunctionOperationID BIGINT,
			@IintRowStatus INT,
			@IintRowStatusForSystemFunction INT  

        WHILE EXISTS (SELECT * FROM #Output2)
        BEGIN

            SELECT TOP 1 
                @DidfEmployee = DidfEmployee,
                @DSystemFunctionID = DSystemFunctionID,
                @DSystemFunctionOperationID = DSystemFunctionOperationID,
                @DintRowStatus = DintRowStatus,
                @DintRowStatusForSystemFunction = DintRowStatusForSystemFunction,
                @IidfEmployee = IidfEmployee,
                @ISystemFunctionID = ISystemFunctionID,
                @ISystemFunctionOperationID = ISystemFunctionOperationID,
                @IintRowStatus = IintRowStatus,
                @IintRowStatusForSystemFunction = IintRowStatusForSystemFunction
            FROM #Output2;
            BEGIN
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_LkupRoleSystemFunctionAccess, 51586990000070,
					@DSystemFunctionID,@DSystemFunctionOperationID,
					@DintRowStatus,@IintRowStatus
				--from #Output2
				where (@DintRowStatus <> @IintRowStatus) 
					or(@DintRowStatus is not null and @IintRowStatus is null)
					or(@DintRowStatus is null and @IintRowStatus is not null)

				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_LkupRoleSystemFunctionAccess, 51586990000071,
					@DSystemFunctionID,@DSystemFunctionOperationID,
					@DintRowStatusForSystemFunction,@IintRowStatusForSystemFunction
				--from #Output2
				where (@DintRowStatusForSystemFunction <> @IintRowStatusForSystemFunction) 
					or(@DintRowStatusForSystemFunction is not null and @IintRowStatusForSystemFunction is null)
					or(@DintRowStatusForSystemFunction is null and @IintRowStatusForSystemFunction is not null)

            END

            DELETE FROM #Output2
            WHERE	DidfEmployee = @DidfEmployee AND
					DSystemFunctionID = @DSystemFunctionID AND
					DSystemFunctionOperationID = @DSystemFunctionOperationID;
        END

		INSERT INTO #OutputI
		SELECT *
		FROM #Output
		Where ActionTaken = 'INSERT'

        WHILE EXISTS (SELECT * FROM #OutputI)
        BEGIN

            SELECT TOP 1 
                @DidfEmployee = DidfEmployee,
                @DSystemFunctionID = DSystemFunctionID,
                @DSystemFunctionOperationID = DSystemFunctionOperationID,
                @DintRowStatus = DintRowStatus,
                @DintRowStatusForSystemFunction = DintRowStatusForSystemFunction,
                @IidfEmployee = IidfEmployee,
                @ISystemFunctionID = ISystemFunctionID,
                @ISystemFunctionOperationID = ISystemFunctionOperationID,
                @IintRowStatus = IintRowStatus,
                @IintRowStatusForSystemFunction = IintRowStatusForSystemFunction
            FROM #OutputI;
            BEGIN

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail)
						values ( @idfDataAuditEvent, @idfObjectTable_LkupRoleSystemFunctionAccess, @ISystemFunctionID, @ISystemFunctionOperationID)
            END

            DELETE FROM #OutputI
            WHERE	IidfEmployee = @IidfEmployee AND
					ISystemFunctionID = @ISystemFunctionID AND
					ISystemFunctionOperationID = @ISystemFunctionOperationID;
        END
		--Data Audit--

		IF @@TRANCOUNT > 0
			COMMIT

		SELECT @returnCode 'ReturnCode',@returnMsg 'ReturnMessage'
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK
			END

		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();
		SET @returnCode = ERROR_NUMBER();

		SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage;
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_IE_DownloadTemplate_GETList]...';


GO
--*************************************************************
-- Name 				:USP_ADMIN_IE_DownloadTemplate_GETList
-- Description			:Returns all the resources that can be 
--						 translated when uploading a new language
--						 template by module and section.
--          
-- Author               : Mike Kornegay
--
-- Revision History
--	Name			Date		Change Detail
--	Mike Kornegay	08/24/2021	Original
--  Mike Kornegay	09/01/2021	Update to remove idfsResourceType from trtResourceSetToResource
--  Mike Kornegay	05/02/2023	Fix stored proc to include module and section.
--
-- Testing code:
/*
	EXEC USP_ADMIN_IE_DownloadTemplate_GETList 'en-US'
	EXEC USP_ADMIN_IE_DownloadTemplate_GETList 'ar-JO'
	EXEC USP_ADMIN_IE_DownloadTemplate_GETList 'ru'
	EXEC USP_ADMIN_IE_DownloadTemplate_GETList 'az-Latn-AZ'
*/
--*************************************************************
ALTER PROCEDURE [dbo].[USP_ADMIN_IE_DownloadTemplate_GETList]
(
	@langId NVARCHAR(10)
)
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT 
					RSTR.idfsResourceSet AS SetId,
					RS.strResourceSet AS SectionName,
					RSP.idfsResourceSet AS ModuleId,
					RSP.strResourceSet AS ModuleName,
					RSTR.idfsResource AS ResourceId,
					R.strResourceName AS ResourceDefaultName,
					R.idfsResourceType AS ResourceTypeId,
					RT.strDefault AS ResourceType
					
		FROM		dbo.trtResourceSetToResource RSTR
		INNER JOIN	dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
		INNER JOIN	dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
		INNER JOIN	dbo.trtBaseReference RT ON RT.idfsBaseReference = R.idfsResourceType
		INNER JOIN	dbo.trtResourceSetHierarchy RSH ON RSH.idfsResourceSet = RS.idfsResourceSet
		INNER JOIN	dbo.trtResourceSetHierarchy RSHP ON RSHP.ResourceSetNode = RSH.ResourceSetNode.GetAncestor(RSH.ResourceSetNode.GetLevel() - 1)
		INNER JOIN  dbo.trtResourceSet RSP ON RSP.idfsResourceSet = RSHP.idfsResourceSet
        WHERE         R.intRowStatus = 0
		ORDER BY
				RSP.strResourceSet ASC, RS.strResourceSet ASC, R.strResourceName ASC, RT.strDefault ASC
		;	
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_USERGROUPTOEMPLOYEE_SET]...';


GO

-- ================================================================================================
-- Name: USP_ADMIN_USERGROUPTOEMPLOYEE_SET

-- Description: Assign employee or an existing user group to the  user group.

-- Author: Ricky Moss
--
-- Change Log:
--
-- Name					Date       Change
-- -------------------- ---------- ---------------------------------------------------------------
-- Ricky Moss			12/02/2019 Initial release
-- Ricky Moss			12/12/2019 Data type change of idfEmployeeGroup parameter.
-- Ann Xiong			06/18/2021 Modified to return ReturnCode and ReturnMessage	
-- Ann Xiong			03/21/2021 Modified to delete employees from the tlbEmployeeGroupMember table if those employees exist in the tlbEmployeeGroupMember table but not in @strEmployees		
-- Ann Xiong			04/25/2023 Implemented Data Audit and added parameter @idfDataAuditEvent	
-- 
-- Testing Code:
-- exec USP_ADMIN_USERGROUPTOEMPLOYEE_SET -497, '-452,-508', NULL
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_USERGROUPTOEMPLOYEE_SET] (
	@idfEmployeeGroup BIGINT,
	@strEmployees NVARCHAR(MAX), -- Comma seperated list of employees or user groups to be deleted as BIGINT
	@idfDataAuditEvent BIGINT = NULL,
	@user NVARCHAR(50)
	)
AS
DECLARE @returnCode INT = 0,
	@returnMessage VARCHAR(MAX) = 'SUCCESS';

DECLARE @tempEmployeeList TABLE (idfEmployee  BIGINT NOT NULL);
DECLARE @idfEmployee BIGINT;
DECLARE @tempEmployeeListToDelete TABLE (idfEmployee  BIGINT NOT NULL);
DECLARE @tempEmployeeListOld TABLE (idfEmployee  BIGINT NOT NULL);

		--Data Audit--
		DECLARE @idfUserId BIGINT = NULL;
		DECLARE @idfSiteId BIGINT = NULL;
		DECLARE @idfsDataAuditEventType bigint = NULL;
		DECLARE @idfsObjectType bigint = 10017058; 					-- User Group --
		DECLARE @idfObject bigint = @idfEmployeeGroup;
		DECLARE @idfObjectTable_tlbEmployeeGroupMember bigint = 75540000000;
		--DECLARE @idfDataAuditEvent BIGINT = NULL;

		-- Get and Set UserId and SiteId
		SELECT @idfUserId = userInfo.UserId, @idfSiteId = UserInfo.SiteId FROM dbo.FN_UserSiteInformation(@user) userInfo
		--Data Audit--

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			IF COALESCE(@strEmployees, '') = ''
				Set @strEmployees = null

			INSERT @tempEmployeeList
			SELECT VALUE AS idfEmployee
			FROM STRING_SPLIT(@strEmployees, ',');

			INSERT @tempEmployeeListOld
			SELECT idfEmployee
			FROM dbo.tlbEmployeeGroupMember
			WHERE idfEmployeeGroup = @idfEmployeeGroup AND intRowStatus = 0;

			INSERT @tempEmployeeListToDelete
			SELECT idfEmployee
			FROM @tempEmployeeListOld
			WHERE idfEmployee NOT IN ( SELECT idfEmployee FROM @tempEmployeeList);

			-- Delete employees from the tlbEmployeeGroupMember table if those employees exist in the tlbEmployeeGroupMember table but not in @strEmployees		
			WHILE (SELECT COUNT(*) FROM @tempEmployeeListToDelete) > 0
			BEGIN
				SET @idfEmployee = (SELECT TOP 1 idfEmployee FROM @tempEmployeeListToDelete)
					BEGIN
						UPDATE dbo.tlbEmployeeGroupMember
						SET intRowStatus = 1
						WHERE idfEmployeeGroup = @idfEmployeeGroup
						AND idfEmployee = @idfEmployee

        				IF @idfDataAuditEvent IS NOT NULL
        				BEGIN 
						--Data Audit--
						INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail )
							SELECT @idfDataAuditEvent, @idfObjectTable_tlbEmployeeGroupMember, @idfEmployeeGroup, @idfEmployee
						--Data Audit--
						END
					END
				DELETE FROM @tempEmployeeListToDelete WHERE idfEmployee = @idfEmployee
			END

			WHILE (SELECT COUNT(*) FROM @tempEmployeeList) > 0
			BEGIN
				SET @idfEmployee = (SELECT TOP 1 idfEmployee FROM @tempEmployeeList)

				-- Validate if employee is not already part of the current user group
				IF NOT EXISTS (
								SELECT * FROM dbo.tlbEmployeeGroupMember 
								WHERE idfEmployeeGroup = @idfEmployeeGroup
								AND idfEmployee = @idfEmployee
							)
					BEGIN
						-- If employee is not already a part of user group, insert a new record 
						INSERT INTO dbo.tlbEmployeeGroupMember
						(
							idfEmployeeGroup,
							idfEmployee,
							intRowStatus,
							rowguid
						)
						VALUES (
							@idfEmployeeGroup,
							@idfEmployee,
							0,
							NEWID()
							);

        				IF @idfDataAuditEvent IS NOT NULL
        				BEGIN 
						--Data Audit--
						INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail )
									values ( @idfDataAuditEvent, @idfObjectTable_tlbEmployeeGroupMember, @idfEmployeeGroup, @idfEmployee)
						--Data Audit--
						END
					END
				ELSE IF EXISTS (
								SELECT * FROM dbo.tlbEmployeeGroupMember 
								WHERE idfEmployeeGroup = @idfEmployeeGroup
								AND idfEmployee = @idfEmployee
							)
					-- If employee is already part of the user group, make membership 'active'
					BEGIN
						--Data Audit--
						DECLARE @intRowStatusOld INT = NULL;
 						SELECT @intRowStatusOld = intRowStatus FROM dbo.tlbEmployeeGroupMember WHERE idfEmployeeGroup = @idfEmployeeGroup AND idfEmployee = @idfEmployee;
 						--Data Audit--

						UPDATE dbo.tlbEmployeeGroupMember
						SET intRowStatus = 0
						WHERE idfEmployeeGroup = @idfEmployeeGroup
						AND idfEmployee = @idfEmployee

        				IF @idfDataAuditEvent IS NOT NULL
        				BEGIN 
						--Data Audit--
						insert into dbo.tauDataAuditDetailUpdate(
									idfDataAuditEvent, idfObjectTable, idfColumn, 
									idfObject, idfObjectDetail, 
									strOldValue, strNewValue)
						select		@idfDataAuditEvent,@idfObjectTable_tlbEmployeeGroupMember, 51586990000121,
									@idfEmployeeGroup,@idfEmployee,
									@intRowStatusOld,0
						WHERE		(@intRowStatusOld <> 0)
						--Data Audit--
						END
					END

				-- Delete record processed from the temporary table
				DELETE FROM @tempEmployeeList WHERE idfEmployee = @idfEmployee
			END

			IF @@TRANCOUNT > 0 
			  COMMIT

			SELECT @returnCode AS 'ReturnCode',	@returnMessage AS 'ReturnMessage';

	END TRY

	BEGIN CATCH

		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK
			END

		SET @returnMessage = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();
		SET @returnCode = ERROR_NUMBER();

		SELECT @returnCode AS ReturnCode, @returnMessage AS ReturnMessage;
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_ASPNetUser_GetRolesAndPermissions]...';


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
ALTER PROCEDURE [dbo].[USP_ASPNetUser_GetRolesAndPermissions]
    @idfuserid BIGINT,
    @EmployeeID BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SiteID BIGINT = (
                                 SELECT idfsSite FROM dbo.tlbEmployee WHERE idfEmployee = @EmployeeID
                             );
    DECLARE @Results TABLE
    (
        idfEmployee BIGINT NOT NULL,
        PermissionId BIGINT NOT NULL,
        [Role] NVARCHAR(MAX) NOT NULL,
        Permission NVARCHAR(3000) NOT NULL,
        PermissionLevelId BIGINT NOT NULL,
        PermissionLevel NVARCHAR(2000) NOT NULL
    );
    DECLARE @UserSitePermissions TABLE
    (
        SiteID BIGINT NOT NULL,
        PermissionTypeID BIGINT NOT NULL,
        Permission INT NOT NULL
    );
    DECLARE @UserGroupSitePermissions TABLE
    (
        SiteID BIGINT NOT NULL,
        PermissionTypeID BIGINT NOT NULL,
        Permission INT NOT NULL
    );

    INSERT INTO @UserGroupSitePermissions
    SELECT oa.idfsOnSite,
           oa.idfsObjectOperation,
           CASE
               WHEN oa.intPermission = 2 THEN
                   3
               ELSE
                   2
           END
    FROM dbo.tstObjectAccess oa
        INNER JOIN dbo.tlbEmployeeGroupMember egm
            ON egm.idfEmployee = @EmployeeID
               AND egm.intRowStatus = 0
    WHERE oa.intRowStatus = 0
          AND oa.idfsObjectType = 10060011 -- Site
          AND oa.idfActor = egm.idfEmployeeGroup;

    INSERT INTO @UserSitePermissions
    SELECT oa.idfsOnSite,
           oa.idfsObjectOperation,
           CASE
               WHEN oa.intPermission = 2 THEN
                   5
               ELSE
                   4
           END
    FROM dbo.tstObjectAccess oa
    WHERE oa.intRowStatus = 0
          AND oa.idfsObjectType = 10060011 -- Site
          AND oa.idfActor = @EmployeeID;

    -- Returned on login - user's default organization permissions.
    INSERT INTO @Results
    SELECT fa.idfEmployee,
           r1.idfsBaseReference PermissionId,
           'Employee' AS [Role],
           r1.strDefault Permission,
           r2.idfsBaseReference PermissionLevelId,
           r2.strDefault PermissionLevel
    FROM dbo.tstUserTable ut
        JOIN dbo.tlbPerson p
            ON p.idfPerson = ut.idfPerson
        Join dbo.tlbEmployee e
            on e.idfEmployee = p.idfPerson
        JOIN dbo.LkupRoleSystemFunctionAccess fa
            ON fa.idfEmployee = e.idfEmployee
        JOIN dbo.trtBaseReference r1
            ON r1.idfsBaseReference = fa.SystemFunctionID
        JOIN dbo.trtReferenceType r11
            ON r11.idfsReferenceType = r1.idfsReferenceType
        JOIN dbo.trtBaseReference r2
            ON r2.idfsBaseReference = fa.SystemFunctionOperationID
    WHERE ut.idfUserID = @idfuserid
          AND p.intRowStatus = 0
          AND e.intRowStatus = 0
          AND fa.intRowStatus = 0
          AND @EmployeeID IS NULL
    UNION

    -- Returned when user switches to another assigned organization outside of the default one.
    SELECT fa.idfEmployee,
           r1.idfsBaseReference PermissionId,
           'Employee' AS [Role],
           r1.strDefault Permission,
           r2.idfsBaseReference PermissionLevelId,
           r2.strDefault PermissionLevel
    FROM dbo.tstUserTable ut
        JOIN dbo.LkupRoleSystemFunctionAccess fa
            ON fa.idfEmployee = ut.idfPerson
               and ut.intRowStatus = 0
        JOIN dbo.trtBaseReference r1
            ON r1.idfsBaseReference = fa.SystemFunctionID
        JOIN dbo.trtReferenceType r11
            ON r11.idfsReferenceType = r1.idfsReferenceType
        JOIN dbo.trtBaseReference r2
            ON r2.idfsBaseReference = fa.SystemFunctionOperationID
    WHERE ut.idfUserID = @idfuserid
          AND fa.intRowStatus = 0
          AND (
                  fa.idfEmployee = @EmployeeID
                  AND @EmployeeID IS NOT NULL
              )
    ORDER BY r1.strDefault;

    -- =======================================================================================
    -- SITE FILTRATION RULES
    --
    -- Apply site filtration rules from use case SAUC29.
    -- =======================================================================================
    -- 
    -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
    -- as all records have been pulled above with or without site filtration rules applied.
    --
    DELETE FROM @Results
    WHERE EXISTS
    (
        SELECT e.idfEmployee
        FROM dbo.tlbEmployee e
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = @SiteID
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroup eg
                ON eg.idfsSite = @SiteID
                   AND eg.intRowStatus = 0
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = eg.idfEmployeeGroup
                   AND br.intRowStatus = 0
                   AND br.blnSystem = 1
        WHERE e.intRowStatus = 0
              AND oa.idfsObjectOperation = 10059003 -- Read permission
              AND oa.intPermission = 1 -- Deny permission
              AND oa.idfsObjectType = 10060011 -- Site
              AND oa.idfActor = eg.idfEmployeeGroup
    );

    --
    -- Apply level 1 site filtration rules for an employee's associated user group(s).  
    -- Allows and denies will supersede level 0.
    --
    INSERT INTO @Results
    SELECT @EmployeeID,
           r1.idfsBaseReference PermissionId,
           'Employee' AS [Role],
           r1.strDefault Permission,
           r2.idfsBaseReference PermissionLevelId,
           r2.strDefault PermissionLevel
    FROM dbo.LkupRoleSystemFunctionAccess fa
        JOIN dbo.trtBaseReference r1
            ON r1.idfsBaseReference = fa.SystemFunctionID
        JOIN dbo.trtReferenceType r11
            ON r11.idfsReferenceType = r1.idfsReferenceType
        JOIN dbo.trtBaseReference r2
            ON r2.idfsBaseReference = fa.SystemFunctionOperationID
    WHERE fa.intRowStatus = 0
          AND @EmployeeID IS NOT NULL
          AND EXISTS
    (
        SELECT *
        FROM @UserGroupSitePermissions
        WHERE SiteID = @SiteID
              AND Permission = 1 -- Allow permission
    );

    DELETE res
    FROM @Results res
        INNER JOIN @UserGroupSitePermissions ugsp
            ON ugsp.SiteID = @SiteID
    WHERE ugsp.Permission = 3
          AND res.PermissionLevelId = ugsp.PermissionTypeID; -- Deny permission

    --
    -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
    -- will supersede level 1.
    --
    INSERT INTO @Results
    SELECT @EmployeeID,
           r1.idfsBaseReference PermissionId,
           'Employee' AS [Role],
           r1.strDefault Permission,
           r2.idfsBaseReference PermissionLevelId,
           r2.strDefault PermissionLevel
    FROM dbo.LkupRoleSystemFunctionAccess fa
        JOIN dbo.trtBaseReference r1
            ON r1.idfsBaseReference = fa.SystemFunctionID
        JOIN dbo.trtReferenceType r11
            ON r11.idfsReferenceType = r1.idfsReferenceType
        JOIN dbo.trtBaseReference r2
            ON r2.idfsBaseReference = fa.SystemFunctionOperationID
    WHERE fa.intRowStatus = 0
          AND @EmployeeID IS NOT NULL
          AND EXISTS
    (
        SELECT *
        FROM @UserSitePermissions
        WHERE SiteID = @SiteID
              AND Permission = 1 -- Allow permission
    );

    DELETE res
    FROM @Results res
        INNER JOIN @UserSitePermissions usp
            ON usp.SiteID = @SiteID
    WHERE usp.Permission = 4
          AND res.PermissionLevelId = usp.PermissionTypeID; -- Deny permission

    SELECT idfEmployee,
           PermissionId,
           [Role],
           Permission,
           PermissionLevelId,
           PermissionLevel
    FROM @Results
    GROUP BY idfEmployee,
             PermissionId,
             [Role],
             Permission,
             PermissionLevelId,
             PermissionLevel;
END
GO
PRINT N'Altering Procedure [dbo].[USP_OMM_HUMAN_DISEASE_SET]...';


GO
--*************************************************************
-- Name 				:	USP_OMM_HUMAN_DISEASE_SET
-- Description			:	Insert OR UPDATE human disease record
--          
-- Author               :	Doug Albanese
-- Revision History
--	Name			Date		Change Detail
--	Doug Albanese	2/2019		Created a shell of the Human Disease Report for Outbreak use only
--	Doug Albanese	5/21/2020	Removed the Case Monitoring SP call and moved it up to the parent SP (USP_OMM_Case_Set)
--	Doug Albanese	10/12/2020	Corrected Audit information
--	Doug Albanese	04/19/2022	Refreshed this SP from the one used for "Human Disease Report". This is a temporarly solution, until it is rewritten to use Location Hierarchy
--	Doug Albanese	04/26/2022	Removed all supression, since the "INSERTS" of this SP are 3 levels deep and only used by USP_OMM_Case_Set
--	Doug Albanese	05/06/2022	Added indicator for Tests conducted
--  Doug Albanese	03/10/2023	Added Data Auditing
--  Doug Albanese	04/28/2023	Removed suppression on USSP_GBL_DATA_AUDIT_EVENT_SET
--
--*************************************************************
ALTER PROCEDURE [dbo].[USP_OMM_HUMAN_DISEASE_SET]
(
	@idfHumanCase							BIGINT = -1 OUTPUT, -- tlbHumanCase.idfHumanCase Primary Key`
	@idfHuman								BIGINT = NULL, -- tlbHumanCase.idfHuman
	@strHumanCaseId							NVARCHAR(200) = '(new)',
	@OutbreakCaseReportUID					BIGINT = NULL,
	@idfHumanActual							BIGINT, -- tlbHumanActual.idfHumanActual
	@idfsFinalDiagnosis						BIGINT, -- tlbhumancase.idfsTentativeDiagnosis/idfsFinalDiagnosis
	@datDateOfDiagnosis						DATETIME = NULL, --tlbHumanCase.datTentativeDiagnosisDate/datFinalDiagnosisDate
	@datNotificationDate					DATETIME = NULL, --tlbHumanCase.DatNotIFicationDate
	@idfsFinalState							BIGINT = NULL, --tlbHumanCase.idfsFinalState

	@idfSentByOffice						BIGINT = NULL, -- tlbHumanCase.idfSentByOffice
	@strSentByFirstName						NVARCHAR(200)= NULL,--tlbHumanCase.strSentByFirstName
	@strSentByPatronymicName				NVARCHAR(200)= NULL, --tlbHumancase.strSentByPatronymicName
	@strSentByLastName						NVARCHAR(200)= NULL, --tlbHumanCase.strSentByLastName
	@idfSentByPerson						BIGINT = NULL, --tlbHumcanCase.idfSentByPerson

	@idfReceivedByOffice					BIGINT = NULL,-- tlbHumanCase.idfReceivedByOffice
	@strReceivedByFirstName					NVARCHAR(200)= NULL, --tlbHumanCase.strReceivedByFirstName
	@strReceivedByPatronymicName			NVARCHAR(200)= NULL, --tlbHumanCase.strReceivedByPatronymicName
	@strReceivedByLastName					NVARCHAR(200)= NULL, --tlbHuanCase.strReceivedByLastName
	@idfReceivedByPerson					BIGINT = NULL, -- tlbHumanCase.idfReceivedByPerson

	@idfsHospitalizationStatus				BIGINT = NULL,  -- tlbHumanCase.idfsHospitalizationStatus
	@idfHospital							BIGINT = NULL, -- tlbHumanCase.idfHospital
	@strCurrentLocation						NVARCHAR(200)= NULL, -- tlbHumanCase.strCurrentLocation
	@datOnSetDate							DATETIME = NULL,	-- tlbHumanCase.datOnSetDate
	@idfsInitialCaseStatus					BIGINT = NULL, -- tlbHumanCase.idfsInitialCaseStatus
	@idfsYNPreviouslySoughtCare				BIGINT = NULL,	--idfsYNPreviouslySoughtCare
	@datFirstSoughtCareDate					DATETIME = NULL, --tlbHumanCase.datFirstSoughtCareDate
	@idfSoughtCareFacility					BIGINT = NULL, --tlbHumanCase.idfSoughtCareFacility
	@idfsNonNotIFiableDiagnosis				BIGINT = NULL,	--tlbHumanCase.idfsNonNotIFiableDiagnosis
	@idfsYNHospitalization					BIGINT = NULL, -- tlbHumanCase.idfsYNHospitalization
	@datHospitalizationDate					DATETIME = NULL,  --tlbHumanCase.datHospitalizationDate 
	@datDischargeDate						DATETIME = NULL,	-- tlbHumanCase.datDischargeDate
	@strHospitalName						NVARCHAR(200)= NULL, --tlbHumanCase.strHospitalizationPlace  
	@idfsYNAntimicrobialTherapy				BIGINT = NULL, --  tlbHumanCase.idfsYNAntimicrobialTherapy 
	@strAntibioticName						NVARCHAR(200)= NULL, -- tlbHumanCase.strAntimicrobialTherapyName
	@strDosage								NVARCHAR(200)= NULL, --tlbHumanCase.strDosage
	@datFirstAdministeredDate				DATETIME = NULL, -- tlbHumanCase.datFirstAdministeredDate
	@strClinicalNotes						NVARCHAR(500) = NULL, -- tlbHumanCase.strClinicalNotes , or strSummaryNotes
	@strNote								NVARCHAR(500) = NULL, -- tlbHumanCase.strNote
	@idfsYNSpecIFicVaccinationAdministered	BIGINT = NULL, --  tlbHumanCase.idfsYNSpecIFicVaccinationAdministered
	@idfInvestigatedByOffice				BIGINT = NULL, -- tlbHumanCase.idfInvestigatedByOffice 
	@idfInvestigatedByPerson				BIGINT = NULL,
	@StartDateofInvestigation				DATETIME = NULL, -- tlbHumanCase.datInvestigationStartDate
	@idfsYNRelatedToOutbreak				BIGINT = NULL, -- tlbHumanCase.idfsYNRelatedToOutbreak
	@idfOutbreak							BIGINT = NULL, --idfOutbreak  
	@idfsYNExposureLocationKnown			BIGINT = NULL, --tlbHumanCase.idfsYNExposureLocationKnown
	@idfPointGeoLocation					BIGINT = NULL, --tlbHumanCase.idfPointGeoLocation
	@datExposureDate						DATETIME = NULL, -- tlbHumanCase.datExposureDate 
	@strLocationDescription					NVARCHAR(MAX) = NULL, --tlbGeolocation.Description

	@CaseGeoLocationID						BIGINT = NULL,
	@CaseidfsLocation						BIGINT = NULL,
	@CasestrStreetName						NVARCHAR(200) = NULL,
	@CasestrApartment						NVARCHAR(200) = NULL,
	@CasestrBuilding						NVARCHAR(200) = NULL,
	@CasestrHouse							NVARCHAR(200) = NULL,
	@CaseidfsPostalCode						NVARCHAR(200) = NULL,
	@CasestrLatitude						FLOAT = NULL,
	@CasestrLongitude						FLOAT = NULL,
	@CasestrElevation						FLOAT = NULL,

	@idfsLocationGroundType					BIGINT = NULL, --tlbGeolocation.GroundType
	@intLocationDistance					FLOAT = NULL, --tlbGeolocation.Distance
	@idfsFinalCaseStatus					BIGINT = NULL, --tlbHuanCase.idfsFinalCaseStatus 
	@idfsOutcome							BIGINT = NULL, -- --tlbHumanCase.idfsOutcome 
	@datDateofDeath							DATETIME = NULL, -- tlbHumanCase.datDateOfDeath 
	@idfsCaseProgressStatus					BIGINT = 10109001,	--	tlbHumanCase.reportStatus, default = In-process
	@idfPersonEnteredBy						BIGINT = NULL,
	@idfsYNSpecimenCollected				BIGINT = NULL,
	@DiseaseReportTypeID					BIGINT = NULL, 
	@blnClinicalDiagBasis          			BIT = NULL,
	@blnLabDiagBasis						BIT = NULL,
	@blnEpiDiagBasis						BIT = NULL,
	@DateofClassification					DATETIME = NULL,
	@strSummaryNotes						NVARCHAR(MAX) = NULL,
	@idfEpiObservation						BIGINT = NULL,
	@idfCSObservation						BIGINT = NULL,
	@SamplesParameters						NVARCHAR(MAX) = NULL,
	@TestsParameters						NVARCHAR(MAX) = NULL,
	@idfsYNTestsConducted					BIGINT = NULL,
	@AntiviralTherapiesParameters			NVARCHAR(MAX) = NULL,
	@VaccinationsParameters					NVARCHAR(MAX) = NULL,
	@CaseMonitoringsParameters				NVARCHAR(MAX) = NULL,
	@ContactsParameters						NVARCHAR(MAX) = NULL,
	@strStreetName							NVARCHAR(200)= NULL,
	@strHouse								NVARCHAR(200)= NULL,
	@strBuilding							NVARCHAR(200)= NULL,
	@strApartment							NVARCHAR(200)= NULL,
	@strPostalCode							NVARCHAR(200) = NULL,
	@User									NVARCHAR(100) = NULL
)
AS

DECLARE @returnCode					INT = 0 
DECLARE	@ReturnMessage				NVARCHAR(max) = 'SUCCESS' 

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			-- Data audit Declarations (Start)
			DECLARE @AuditUserID BIGINT = NULL
			DECLARE @AuditSiteID BIGINT = NULL
			DECLARE @DataAuditEventID BIGINT = NULL
			DECLARE @DataAuditEventTypeID BIGINT = NULL
			DECLARE @ObjectTypeID BIGINT = 10017080
			DECLARE @ObjectID BIGINT = @idfOutbreak
			DECLARE @ObjectTableID BIGINT = 75610000000
			-- Data audit Declarations (End)

			-- Data audit UserInfo (Start)
			-- Get and set user and site identifiers
			SELECT @AuditUserID = userInfo.UserId,
			   @AuditSiteID = userInfo.SiteId
			FROM dbo.FN_UserSiteInformation(@User) userInfo;
			-- Data audit UserInfo (End)

			--Data Audit Before Edit Table (Start)
			DECLARE @HumanCaseBeforeEdit TABLE (
				blnClinicalDiagBasis					BIT,
				blnEpiDiagBasis							BIT,
				blnLabDiagBasis							BIT,
				datCompletionPaperFormDate				DateTime,
				datDischargeDate						DateTime,
				datExposureDate							DateTime,
				datFacilityLastVisit					DateTime,
				datFinalDiagnosisDate					DateTime,
				datHospitalizationDate					DateTime,
				datInvestigationStartDate				DateTime,
				datModificationDate						DateTime,
				datTentativeDiagnosisDate				DateTime,
				idfHumanCase							BIGINT,
				idfInvestigatedByOffice					BIGINT,
				idfPointGeoLocation						BIGINT,
				idfReceivedByOffice						BIGINT,
				idfsFinalDiagnosis						BIGINT,
				idfsFinalState							BIGINT,
				idfsHospitalizationStatus				BIGINT,
				idfsHumanAgeType						BIGINT,
				idfsInitialCaseStatus					BIGINT,
				idfsOutcome								BIGINT,
				idfsTentativeDiagnosis					BIGINT,
				idfsYNAntimicrobialTherapy				BIGINT,
				idfsYNHospitalization					BIGINT,
				idfsYNRelatedToOutbreak					BIGINT,
				idfsYNSpecimenCollected					BIGINT,
				intPatientAge							INT,
				strClinicalDiagnosis					NVARCHAR(2000),
				strCurrentLocation						NVARCHAR(2000),
				strEpidemiologistsName					NVARCHAR(2000),
				strHospitalizationPlace					NVARCHAR(2000),
				strLocalIdentifier						NVARCHAR(2000),
				strNotCollectedReason					NVARCHAR(2000),
				strNote									NVARCHAR(2000),
				strReceivedByFirstName					NVARCHAR(2000),
				strReceivedByLastName					NVARCHAR(2000),
				strReceivedByPatronymicName				NVARCHAR(2000),
				strSentByFirstName						NVARCHAR(2000),
				strSentByLastName						NVARCHAR(2000),
				strSentByPatronymicName					NVARCHAR(2000),
				strSoughtCareFacility					NVARCHAR(2000),
				idfsFinalCaseStatus						BIGINT,
				idfSentByOffice							BIGINT,
				idfEpiObservation						BIGINT,
				idfCSObservation						BIGINT,
				idfDeduplicationResultCase				BIGINT,
				datNotificationDate						DateTime,
				datFirstSoughtCareDate					DateTime,
				datOnSetDate							DateTime,
				strClinicalNotes						NVARCHAR(2000),
				strSummaryNotes							NVARCHAR(2000),
				idfHuman								BIGINT,
				idfPersonEnteredBy						BIGINT,
				idfSentByPerson							BIGINT,
				idfReceivedByPerson						BIGINT,
				idfInvestigatedByPerson					BIGINT,
				idfsYNTestsConducted					BIGINT,
				idfSoughtCareFacility					BIGINT,
				idfsNonNotifiableDiagnosis				BIGINT,
				idfsNotCollectedReason					BIGINT,
				idfOutbreak								BIGINT,
				datEnteredDate							DateTime,
				strCaseID								NVARCHAR(200),
				idfsCaseProgressStatus					BIGINT,
				strSampleNotes							NVARCHAR(2000),
				uidOfflineCaseID						UNIQUEIDENTIFIER,
				datFinalCaseClassificationDate			DateTime,
				idfHospital								BIGINT
			)
			--Data Audit Before Edit Table (End)

			--Data Audit After Edit Table (Start)
			DECLARE @HumanCaseAfterEdit TABLE (
				blnClinicalDiagBasis					BIT,
				blnEpiDiagBasis							BIT,
				blnLabDiagBasis							BIT,
				datCompletionPaperFormDate				DateTime,
				datDischargeDate						DateTime,
				datExposureDate							DateTime,
				datFacilityLastVisit					DateTime,
				datFinalDiagnosisDate					DateTime,
				datHospitalizationDate					DateTime,
				datInvestigationStartDate				DateTime,
				datModificationDate						DateTime,
				datTentativeDiagnosisDate				DateTime,
				idfHumanCase							BIGINT,
				idfInvestigatedByOffice					BIGINT,
				idfPointGeoLocation						BIGINT,
				idfReceivedByOffice						BIGINT,
				idfsFinalDiagnosis						BIGINT,
				idfsFinalState							BIGINT,
				idfsHospitalizationStatus				BIGINT,
				idfsHumanAgeType						BIGINT,
				idfsInitialCaseStatus					BIGINT,
				idfsOutcome								BIGINT,
				idfsTentativeDiagnosis					BIGINT,
				idfsYNAntimicrobialTherapy				BIGINT,
				idfsYNHospitalization					BIGINT,
				idfsYNRelatedToOutbreak					BIGINT,
				idfsYNSpecimenCollected					BIGINT,
				intPatientAge							INT,
				strClinicalDiagnosis					NVARCHAR(2000),
				strCurrentLocation						NVARCHAR(2000),
				strEpidemiologistsName					NVARCHAR(2000),
				strHospitalizationPlace					NVARCHAR(2000),
				strLocalIdentifier						NVARCHAR(2000),
				strNotCollectedReason					NVARCHAR(2000),
				strNote									NVARCHAR(2000),
				strReceivedByFirstName					NVARCHAR(2000),
				strReceivedByLastName					NVARCHAR(2000),
				strReceivedByPatronymicName				NVARCHAR(2000),
				strSentByFirstName						NVARCHAR(2000),
				strSentByLastName						NVARCHAR(2000),
				strSentByPatronymicName					NVARCHAR(2000),
				strSoughtCareFacility					NVARCHAR(2000),
				idfsFinalCaseStatus						BIGINT,
				idfSentByOffice							BIGINT,
				idfEpiObservation						BIGINT,
				idfCSObservation						BIGINT,
				idfDeduplicationResultCase				BIGINT,
				datNotificationDate						DateTime,
				datFirstSoughtCareDate					DateTime,
				datOnSetDate							DateTime,
				strClinicalNotes						NVARCHAR(2000),
				strSummaryNotes							NVARCHAR(2000),
				idfHuman								BIGINT,
				idfPersonEnteredBy						BIGINT,
				idfSentByPerson							BIGINT,
				idfReceivedByPerson						BIGINT,
				idfInvestigatedByPerson					BIGINT,
				idfsYNTestsConducted					BIGINT,
				idfSoughtCareFacility					BIGINT,
				idfsNonNotifiableDiagnosis				BIGINT,
				idfsNotCollectedReason					BIGINT,
				idfOutbreak								BIGINT,
				datEnteredDate							DateTime,
				strCaseID								NVARCHAR(200),
				idfsCaseProgressStatus					BIGINT,
				strSampleNotes							NVARCHAR(2000),
				uidOfflineCaseID						UNIQUEIDENTIFIER,
				datFinalCaseClassificationDate			DateTime,
				idfHospital								BIGINT
			)
			--Data Audit After Edit Table (End)

			Declare @SupressSelect table
			( retrunCode int,
			  returnMessage varchar(200)
			)

			Declare @SupressSelectHumanCase table
			( retrunCode int,
			  returnMessage varchar(200),
			  idfHumanCase BigInt
			)
			DECLARE @COPYHUMANACTUALTOHUMAN_ReturnCode int = 0
			
			--INSERT INTO @SupressSelect
			EXEC USP_OMM_COPYHUMANACTUALTOHUMAN @idfHumanActual, @idfHuman OUTPUT--, @returnCode OUTPUT, @returnMsg OUTPUT

			--INSERT INTO @SupressSelect
			EXECUTE dbo.USSP_GBL_ADDRESS_SET 
				@GeolocationID = @CaseGeoLocationID OUTPUT,
				@ResidentTypeID = NULL,
				@GroundTypeID = NULL,
				@GeolocationTypeID = NULL,
				@LocationID = @CaseidfsLocation,
				@Apartment = @CasestrApartment,
				@Building = @CasestrBuilding,
				@StreetName = @CasestrStreetName,
				@House = @CasestrHouse,
				@PostalCodeString = @CaseidfsPostalCode,
				@DescriptionString = NULL,
				@Distance = NULL,
				@Latitude = @CasestrLatitude,
				@Longitude = @CasestrLongitude,
				@Elevation = @CasestrElevation,
				@Accuracy = NULL,
				@Alignment = NULL,
				@ForeignAddressIndicator = null,
				@ForeignAddressString = null,
				@GeolocationSharedIndicator = 0,
				@AuditUserName = @User,
				@ReturnCode = @ReturnCode OUTPUT,
				@ReturnMessage = @ReturnMessage OUTPUT;

			IF NOT EXISTS (SELECT idfHumanCase FROM dbo.tlbHumanCase WHERE idfHumanCase = @idfHumanCase)
				BEGIN
					-- Get next key value
					--INSERT INTO @SupressSelect
					EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbHumanCase', @idfHumanCase OUTPUT

					-- Create a stringId for Human Case
					IF LEFT(ISNULL(@strHumanCaseID, '(new'),4) = '(new'
						BEGIN
							--INSERT INTO @SupressSelect
							EXEC dbo.USP_GBL_NextNumber_GET 'Human Disease Report', @strHumanCaseID OUTPUT , NULL --N'AS Session'
						END
					 
					  -- Data audit (Create)
					 SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

					  --INSERT INTO @SupressSelect            
					  EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,                                                      
						 @AuditSiteID,                                                      
						 @DataAuditEventTypeID,                                                      
						 @ObjectTypeID,                                                      
						 @idfHumanCase,                                                      
						 @ObjectTableID,                                                      
						 @strHumanCaseID,                                                       
						 @DataAuditEventID OUTPUT;
					 -- Data audit (Create)

					INSERT 
					INTO	tlbHumanCase
							(
							 idfHumanCase,		
							 idfHuman,
							 strCaseId,				
							 idfsFinalDiagnosis,
							 datFinalDiagnosisDate,
							 datNotIFicationDate,			
							 idfsFinalState,
							 idfSentByOffice,	
							 strSentByFirstName,	
							 strSentByPatronymicName,	
							 strSentByLastName,	
							 idfSentByPerson,
							 idfReceivedByOffice,	
							 strReceivedByFirstName,	
							 strReceivedByPatronymicName,	
							 strReceivedByLastName,	
							 idfReceivedByPerson,
							 idfsHospitalizationStatus,		
							 idfHospital,				
							 strCurrentLocation,				
							 datOnSetDate,			
							 idfsInitialCaseStatus ,	
							 idfsYNPreviouslySoughtCare,	
							 datFirstSoughtCareDate,		
							 idfSoughtCareFacility,			
							 idfsNonNotIFiableDiagnosis,	
							 idfsYNHospitalization,			
							 datHospitalizationDate,		
							 datDischargeDate,			
							 strHospitalizationPlace ,				
							 idfsYNAntimicrobialTherapy,	
							 strClinicalNotes,	
							 strNote,		
							 idfsYNSpecIFicVaccinationAdministered,
							 idfInvestigatedByOffice,	
							 idfInvestigatedByPerson,
							 datInvestigationStartDate,
							 idfsYNRelatedToOutbreak,	
							 idfOutbreak,					
							 idfsYNExposureLocationKnown,
							 datExposureDate,				
							 idfsFinalCaseStatus,	
							 idfsOutcome,					
							 intRowStatus,
							 idfsCaseProgressStatus,
							 datModificationDate,
							 datEnteredDate,
							 idfPersonEnteredBy,
							 idfsYNSpecimenCollected,
							 DiseaseReportTypeID,
							 blnClinicalDiagBasis,
							 blnLabDiagBasis,
							 blnEpiDiagBasis,
							 datFinalCaseClassificationDate,	
							 strsummarynotes,
							 idfEpiObservation,	
							 idfCSObservation,
							 idfsYNTestsConducted,
							 AuditCreateUser,
							 AuditCreateDTM		
							)
					VALUES (
							 @idfHumanCase,
							 @idfHuman,		
							 @strHumanCaseId,				
							 @idfsFinalDiagnosis,					
							 @datDateOfDiagnosis,
							 @datNotificationDate,			
							 @idfsFinalState,
							 @idfSentByOffice,	
							 @strSentByFirstName,	
							 @strSentByPatronymicName,	
							 @strSentByLastName,	
							 @idfSentByPerson,	
							 @idfReceivedByOffice,	
							 @strReceivedByFirstName,	
							 @strReceivedByPatronymicName,	
							 @strReceivedByLastName,	
							 @idfReceivedByPerson,
							 @idfsHospitalizationStatus,		
							 @idfHospital,				
							 @strCurrentLocation,				
							 @datOnSetDate,			
							 @idfsInitialCaseStatus,	
							 @idfsYNPreviouslySoughtCare,	
							 @datFirstSoughtCareDate,		
							 @idfSoughtCareFacility,			
							 @idfsNonNotIFiableDiagnosis,	
							 @idfsYNHospitalization,			
							 @datHospitalizationDate,		
							 @datDischargeDate,			
							 @strHospitalName,	
							 @idfsYNAntimicrobialTherapy,			
							 @strClinicalNotes,		
							 @strNote,
							 @idfsYNSpecIFicVaccinationAdministered,
							 @idfInvestigatedByOffice,	
							 @idfInvestigatedByPerson,
							 @StartDateofInvestigation,
							 @idfsYNRelatedToOutbreak,	
							 @idfOutbreak,					
							 @idfsYNExposureLocationKnown,
							 @datExposureDate,				
							 @idfsFinalCaseStatus,
							 @idfsOutcome,					
							 0,
							 @idfsCaseProgressStatus,
							 getdate(),			
							 getDate(),				
							 @idfPersonEnteredBy,
							 @idfsYNSpecimenCollected,
							 @DiseaseReportTypeID,
							 @blnClinicalDiagBasis,
							 @blnLabDiagBasis,
							 @blnEpiDiagBasis,
							 @DateofClassification,
							 @strSummaryNotes,
							 @idfEpiObservation,
							 @idfCSObservation,
							 @idfsYNTestsConducted,
							 @User,
							 GETDATE()
							)
				END
			ELSE
				BEGIN
					  -- Data audit Edit (Start)
					 SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type
					 SELECT @strHumanCaseId = strCaseID FROM tlbHumanCase where idfHumanCase = @idfHumanCase

					  --INSERT INTO @SupressSelect            
					  EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,                                                      
						 @AuditSiteID,                                                      
						 @DataAuditEventTypeID,                                                      
						 @ObjectTypeID,                                                      
						 @idfHumanCase,                                                      
						 @ObjectTableID,                                                      
						 @strHumanCaseId,                                                       
						 @DataAuditEventID OUTPUT;
					 -- Data audit Edit (End)

				    --Date Audit Collect Record Details Before Update (Start)
					 INSERT INTO @HumanCaseBeforeEdit (
						   blnClinicalDiagBasis,
						   blnEpiDiagBasis,
						   blnLabDiagBasis,
						   datCompletionPaperFormDate,
						   datDischargeDate,
						   datExposureDate,
						   datFacilityLastVisit,
						   datFinalDiagnosisDate,
						   datHospitalizationDate,
						   datInvestigationStartDate,
						   datModificationDate,
						   datTentativeDiagnosisDate,
						   idfHumanCase,
						   idfInvestigatedByOffice,
						   idfPointGeoLocation,
						   idfReceivedByOffice,
						   idfsFinalDiagnosis,
						   idfsFinalState,
						   idfsHospitalizationStatus,
						   idfsHumanAgeType,
						   idfsInitialCaseStatus,
						   idfsOutcome,
						   idfsTentativeDiagnosis,
						   idfsYNAntimicrobialTherapy,
						   idfsYNHospitalization,
						   idfsYNRelatedToOutbreak,
						   idfsYNSpecimenCollected,
						   intPatientAge,
						   strClinicalDiagnosis,
						   strCurrentLocation,
						   strEpidemiologistsName,
						   strHospitalizationPlace,
						   strLocalIdentifier,
						   strNotCollectedReason,
						   strNote,
						   strReceivedByFirstName,
						   strReceivedByLastName,
						   strReceivedByPatronymicName,
						   strSentByFirstName,
						   strSentByLastName,
						   strSentByPatronymicName,
						   strSoughtCareFacility,
						   idfsFinalCaseStatus,
						   idfSentByOffice,
						   idfEpiObservation,
						   idfCSObservation,
						   idfDeduplicationResultCase,
						   datNotificationDate,
						   datFirstSoughtCareDate,
						   datOnSetDate,
						   strClinicalNotes,
						   strSummaryNotes,
						   idfHuman,
						   idfPersonEnteredBy,
						   idfSentByPerson,
						   idfReceivedByPerson,
						   idfInvestigatedByPerson,
						   idfsYNTestsConducted,
						   idfSoughtCareFacility,
						   idfsNonNotifiableDiagnosis,
						   idfsNotCollectedReason,
						   idfOutbreak,
						   datEnteredDate,
						   strCaseID,
						   idfsCaseProgressStatus,
						   strSampleNotes,
						   uidOfflineCaseID,
						   datFinalCaseClassificationDate,
						   idfHospital
					 )
					 SELECT 
						   blnClinicalDiagBasis,
						   blnEpiDiagBasis,
						   blnLabDiagBasis,
						   datCompletionPaperFormDate,
						   datDischargeDate,
						   datExposureDate,
						   datFacilityLastVisit,
						   datFinalDiagnosisDate,
						   datHospitalizationDate,
						   datInvestigationStartDate,
						   datModificationDate,
						   datTentativeDiagnosisDate,
						   idfHumanCase,
						   idfInvestigatedByOffice,
						   idfPointGeoLocation,
						   idfReceivedByOffice,
						   idfsFinalDiagnosis,
						   idfsFinalState,
						   idfsHospitalizationStatus,
						   idfsHumanAgeType,
						   idfsInitialCaseStatus,
						   idfsOutcome,
						   idfsTentativeDiagnosis,
						   idfsYNAntimicrobialTherapy,
						   idfsYNHospitalization,
						   idfsYNRelatedToOutbreak,
						   idfsYNSpecimenCollected,
						   intPatientAge,
						   strClinicalDiagnosis,
						   strCurrentLocation,
						   strEpidemiologistsName,
						   strHospitalizationPlace,
						   strLocalIdentifier,
						   strNotCollectedReason,
						   strNote,
						   strReceivedByFirstName,
						   strReceivedByLastName,
						   strReceivedByPatronymicName,
						   strSentByFirstName,
						   strSentByLastName,
						   strSentByPatronymicName,
						   strSoughtCareFacility,
						   idfsFinalCaseStatus,
						   idfSentByOffice,
						   idfEpiObservation,
						   idfCSObservation,
						   idfDeduplicationResultCase,
						   datNotificationDate,
						   datFirstSoughtCareDate,
						   datOnSetDate,
						   strClinicalNotes,
						   strSummaryNotes,
						   idfHuman,
						   idfPersonEnteredBy,
						   idfSentByPerson,
						   idfReceivedByPerson,
						   idfInvestigatedByPerson,
						   idfsYNTestsConducted,
						   idfSoughtCareFacility,
						   idfsNonNotifiableDiagnosis,
						   idfsNotCollectedReason,
						   idfOutbreak,
						   datEnteredDate,
						   strCaseID,
						   idfsCaseProgressStatus,
						   strSampleNotes,
						   uidOfflineCaseID,
						   datFinalCaseClassificationDate,
						   idfHospital
					 FROM
						   tlbHumanCase
					 WHERE
						   idfHumanCase = @idfHumanCase
					 --Date Audit Collect Record Details Before Update (End)

					UPDATE dbo.tlbHumanCase
					SET							
							--strCaseId =  @strHumanCaseId,
							idfsTentativeDiagnosis =  @idfsFinalDiagnosis,
							idfsFinalDiagnosis =  @idfsFinalDiagnosis,
							--datTentativeDiagnosisDate =  @datDateOfDiagnosis,
							datFinalDiagnosisDate =  @datDateOfDiagnosis,
							datNotIFicationDate =  @datNotificationDate,
							idfsFinalState=  @idfsFinalState,

							idfSentByOffice =  @idfSentByOffice,
							strSentByFirstName =  @strSentByFirstName,
							strSentByPatronymicName =  @strSentByPatronymicName,
							strSentByLastName =  @strSentByLastName,
							idfSentByPerson = @idfSentByPerson,

							idfReceivedByOffice =  @idfReceivedByOffice,
							strReceivedByFirstName =  @strReceivedByFirstName,
							strReceivedByPatronymicName =  @strReceivedByPatronymicName,
							strReceivedByLastName =  @strReceivedByLastName,
							idfReceivedByPerson = @idfReceivedByPerson,

							idfsHospitalizationStatus =  @idfsHospitalizationStatus,
							idfHospital =  @idfHospital,
							strCurrentLocation =  @strCurrentLocation,
							datOnSetDate =  @datOnSetDate,
							idfsInitialCaseStatus  =  @idfsInitialCaseStatus,	
							idfsYNPreviouslySoughtCare = @idfsYNPreviouslySoughtCare,
							datFirstSoughtCareDate =  @datFirstSoughtCareDate,
							idfSoughtCareFacility =  @idfSoughtCareFacility	,
							idfsNonNotIFiableDiagnosis =  @idfsNonNotIFiableDiagnosis,
							idfsYNHospitalization =  @idfsYNHospitalization,
							datHospitalizationDate  =  @datHospitalizationDate,
							datDischargeDate =  @datDischargeDate,
							strHospitalizationPlace  =  @strHospitalName,
							idfsYNAntimicrobialTherapy =  @idfsYNAntimicrobialTherapy,
							strClinicalNotes = @strClinicalNotes,
							strNote = @strNote,
							idfsYNSpecIFicVaccinationAdministered = @idfsYNSpecIFicVaccinationAdministered,
							idfInvestigatedByOffice =  @idfInvestigatedByOffice,
							idfInvestigatedByPerson = @idfInvestigatedByPerson,
							datInvestigationStartDate = @StartDateofInvestigation, 
							idfsYNRelatedToOutbreak = @idfsYNRelatedToOutbreak,
							idfOutbreak =  @idfOutbreak,
							idfsYNExposureLocationKnown = @idfsYNExposureLocationKnown,
							datExposureDate =  @datExposureDate,
							idfsFinalCaseStatus  =  @idfsFinalCaseStatus,
							idfsOutcome =  @idfsOutcome,
							idfsCaseProgressStatus = @idfsCaseProgressStatus,
							datModificationDate = getdate(),
							idfsYNSpecimenCollected = @idfsYNSpecimenCollected,
							idfsYNTestsConducted = @idfsYNTestsConducted,
							DiseaseReportTypeID = @DiseaseReportTypeID,
							blnClinicalDiagBasis = @blnClinicalDiagBasis,
							blnLabDiagBasis = @blnLabDiagBasis,
							blnEpiDiagBasis	= @blnEpiDiagBasis,
							datFinalCaseClassificationDate = @DateofClassification,
							strsummarynotes = @strSummaryNotes,
							idfEpiObservation = @idfEpiObservation,
							idfCSObservation = @idfCSObservation,
							idfHuman = @idfHuman,
							AuditUpdateUser = @User,
							AuditUpdateDTM = GETDATE()

					WHERE	idfHumanCase = @idfHumanCase

					--Date Audit Collect Record Details After Update (Start)
					 INSERT INTO @HumanCaseAfterEdit (
						 blnClinicalDiagBasis,
						 blnEpiDiagBasis,
						 blnLabDiagBasis,
						 datCompletionPaperFormDate,
						 datDischargeDate,
						 datExposureDate,
						 datFacilityLastVisit,
						 datFinalDiagnosisDate,
						 datHospitalizationDate,
						 datInvestigationStartDate,
						 datModificationDate,
						 datTentativeDiagnosisDate,
						 idfHumanCase,
						 idfInvestigatedByOffice,
						 idfPointGeoLocation,
						 idfReceivedByOffice,
						 idfsFinalDiagnosis,
						 idfsFinalState,
						 idfsHospitalizationStatus,
						 idfsHumanAgeType,
						 idfsInitialCaseStatus,
						 idfsOutcome,
						 idfsTentativeDiagnosis,
						 idfsYNAntimicrobialTherapy,
						 idfsYNHospitalization,
						 idfsYNRelatedToOutbreak,
						 idfsYNSpecimenCollected,
						 intPatientAge,
						 strClinicalDiagnosis,
						 strCurrentLocation,
						 strEpidemiologistsName,
						 strHospitalizationPlace,
						 strLocalIdentifier,
						 strNotCollectedReason,
						 strNote,
						 strReceivedByFirstName,
						 strReceivedByLastName,
						 strReceivedByPatronymicName,
						 strSentByFirstName,
						 strSentByLastName,
						 strSentByPatronymicName,
						 strSoughtCareFacility,
						 idfsFinalCaseStatus,
						 idfSentByOffice,
						 idfEpiObservation,
						 idfCSObservation,
						 idfDeduplicationResultCase,
						 datNotificationDate,
						 datFirstSoughtCareDate,
						 datOnSetDate,
						 strClinicalNotes,
						 strSummaryNotes,
						 idfHuman,
						 idfPersonEnteredBy,
						 idfSentByPerson,
						 idfReceivedByPerson,
						 idfInvestigatedByPerson,
						 idfsYNTestsConducted,
						 idfSoughtCareFacility,
						 idfsNonNotifiableDiagnosis,
						 idfsNotCollectedReason,
						 idfOutbreak,
						 datEnteredDate,
						 strCaseID,
						 idfsCaseProgressStatus,
						 strSampleNotes,
						 uidOfflineCaseID,
						 datFinalCaseClassificationDate,
						 idfHospital
					 )
					 SELECT 
						 blnClinicalDiagBasis,
						 blnEpiDiagBasis,
						 blnLabDiagBasis,
						 datCompletionPaperFormDate,
						 datDischargeDate,
						 datExposureDate,
						 datFacilityLastVisit,
						 datFinalDiagnosisDate,
						 datHospitalizationDate,
						 datInvestigationStartDate,
						 datModificationDate,
						 datTentativeDiagnosisDate,
						 idfHumanCase,
						 idfInvestigatedByOffice,
						 idfPointGeoLocation,
						 idfReceivedByOffice,
						 idfsFinalDiagnosis,
						 idfsFinalState,
						 idfsHospitalizationStatus,
						 idfsHumanAgeType,
						 idfsInitialCaseStatus,
						 idfsOutcome,
						 idfsTentativeDiagnosis,
						 idfsYNAntimicrobialTherapy,
						 idfsYNHospitalization,
						 idfsYNRelatedToOutbreak,
						 idfsYNSpecimenCollected,
						 intPatientAge,
						 strClinicalDiagnosis,
						 strCurrentLocation,
						 strEpidemiologistsName,
						 strHospitalizationPlace,
						 strLocalIdentifier,
						 strNotCollectedReason,
						 strNote,
						 strReceivedByFirstName,
						 strReceivedByLastName,
						 strReceivedByPatronymicName,
						 strSentByFirstName,
						 strSentByLastName,
						 strSentByPatronymicName,
						 strSoughtCareFacility,
						 idfsFinalCaseStatus,
						 idfSentByOffice,
						 idfEpiObservation,
						 idfCSObservation,
						 idfDeduplicationResultCase,
						 datNotificationDate,
						 datFirstSoughtCareDate,
						 datOnSetDate,
						 strClinicalNotes,
						 strSummaryNotes,
						 idfHuman,
						 idfPersonEnteredBy,
						 idfSentByPerson,
						 idfReceivedByPerson,
						 idfInvestigatedByPerson,
						 idfsYNTestsConducted,
						 idfSoughtCareFacility,
						 idfsNonNotifiableDiagnosis,
						 idfsNotCollectedReason,
						 idfOutbreak,
						 datEnteredDate,
						 strCaseID,
						 idfsCaseProgressStatus,
						 strSampleNotes,
						 uidOfflineCaseID,
						 datFinalCaseClassificationDate,
						 idfHospital
					 FROM
						 tlbHumanCase
					 WHERE
						 idfHumanCase = @idfHumanCase
					 --Date Audit Collect Record Details After Update (End)

					 --Date Audit Create Entry For Any Changes Made (Start)
					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79490000000, --blnClinicalDiagBasis
							a.idfHumanCase,
							NULL,
							b.blnClinicalDiagBasis,
							a.blnClinicalDiagBasis,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.blnClinicalDiagBasis <> b.blnClinicalDiagBasis)
						   OR (
								  a.blnClinicalDiagBasis IS NOT NULL
								  AND b.blnClinicalDiagBasis IS NULL
							  )
						   OR (
								  a.blnClinicalDiagBasis IS NULL
								  AND b.blnClinicalDiagBasis IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79500000000, --blnEpiDiagBasis
							a.idfHumanCase,
							NULL,
							b.blnEpiDiagBasis,
							a.blnEpiDiagBasis,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.blnEpiDiagBasis <> b.blnEpiDiagBasis)
						   OR (
								  a.blnEpiDiagBasis IS NOT NULL
								  AND b.blnEpiDiagBasis IS NULL
							  )
						   OR (
								  a.blnEpiDiagBasis IS NULL
								  AND b.blnEpiDiagBasis IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79510000000, --blnLabDiagBasis
							a.idfHumanCase,
							NULL,
							b.blnLabDiagBasis,
							a.blnLabDiagBasis,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.blnLabDiagBasis <> b.blnLabDiagBasis)
						   OR (
								  a.blnLabDiagBasis IS NOT NULL
								  AND b.blnLabDiagBasis IS NULL
							  )
						   OR (
								  a.blnLabDiagBasis IS NULL
								  AND b.blnLabDiagBasis IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79520000000, --datCompletionPaperFormDate
							a.idfHumanCase,
							NULL,
							b.datCompletionPaperFormDate,
							a.datCompletionPaperFormDate,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.datCompletionPaperFormDate <> b.datCompletionPaperFormDate)
						   OR (
								  a.datCompletionPaperFormDate IS NOT NULL
								  AND b.datCompletionPaperFormDate IS NULL
							  )
						   OR (
								  a.datCompletionPaperFormDate IS NULL
								  AND b.datCompletionPaperFormDate IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79530000000, --datDischargeDate
							a.idfHumanCase,
							NULL,
							b.datDischargeDate,
							a.datDischargeDate,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.datDischargeDate <> b.datDischargeDate)
						   OR (
								  a.datDischargeDate IS NOT NULL
								  AND b.datDischargeDate IS NULL
							  )
						   OR (
								  a.datDischargeDate IS NULL
								  AND b.datDischargeDate IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79540000000, --datExposureDate
							a.idfHumanCase,
							NULL,
							b.datExposureDate,
							a.datExposureDate,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.datExposureDate <> b.datExposureDate)
						   OR (
								  a.datExposureDate IS NOT NULL
								  AND b.datExposureDate IS NULL
							  )
						   OR (
								  a.datExposureDate IS NULL
								  AND b.datExposureDate IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79550000000, --datFacilityLastVisit
							a.idfHumanCase,
							NULL,
							b.datFacilityLastVisit,
							a.datFacilityLastVisit,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.datFacilityLastVisit <> b.datFacilityLastVisit)
						   OR (
								  a.datFacilityLastVisit IS NOT NULL
								  AND b.datFacilityLastVisit IS NULL
							  )
						   OR (
								  a.datFacilityLastVisit IS NULL
								  AND b.datFacilityLastVisit IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79560000000, --datFinalDiagnosisDate
							a.idfHumanCase,
							NULL,
							b.datFinalDiagnosisDate,
							a.datFinalDiagnosisDate,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.datFinalDiagnosisDate <> b.datFinalDiagnosisDate)
						   OR (
								  a.datFinalDiagnosisDate IS NOT NULL
								  AND b.datFinalDiagnosisDate IS NULL
							  )
						   OR (
								  a.datFinalDiagnosisDate IS NULL
								  AND b.datFinalDiagnosisDate IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79570000000, --datHospitalizationDate
							a.idfHumanCase,
							NULL,
							b.datHospitalizationDate,
							a.datHospitalizationDate,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.datHospitalizationDate <> b.datHospitalizationDate)
						   OR (
								  a.datHospitalizationDate IS NOT NULL
								  AND b.datHospitalizationDate IS NULL
							  )
						   OR (
								  a.datHospitalizationDate IS NULL
								  AND b.datHospitalizationDate IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79580000000, --datInvestigationStartDate
							a.idfHumanCase,
							NULL,
							b.datInvestigationStartDate,
							a.datInvestigationStartDate,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.datInvestigationStartDate <> b.datInvestigationStartDate)
						   OR (
								  a.datInvestigationStartDate IS NOT NULL
								  AND b.datInvestigationStartDate IS NULL
							  )
						   OR (
								  a.datInvestigationStartDate IS NULL
								  AND b.datInvestigationStartDate IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79590000000, --datModificationDate
							a.idfHumanCase,
							NULL,
							b.datModificationDate,
							a.datModificationDate,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.datModificationDate <> b.datModificationDate)
						   OR (
								  a.datModificationDate IS NOT NULL
								  AND b.datModificationDate IS NULL
							  )
						   OR (
								  a.datModificationDate IS NULL
								  AND b.datModificationDate IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79600000000, --datTentativeDiagnosisDate
							a.idfHumanCase,
							NULL,
							b.datTentativeDiagnosisDate,
							a.datTentativeDiagnosisDate,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.datTentativeDiagnosisDate <> b.datTentativeDiagnosisDate)
						   OR (
								  a.datTentativeDiagnosisDate IS NOT NULL
								  AND b.datTentativeDiagnosisDate IS NULL
							  )
						   OR (
								  a.datTentativeDiagnosisDate IS NULL
								  AND b.datTentativeDiagnosisDate IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79610000000, --idfHumanCase
							a.idfHumanCase,
							NULL,
							b.idfHumanCase,
							a.idfHumanCase,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfHumanCase <> b.idfHumanCase)
						   OR (
								  a.idfHumanCase IS NOT NULL
								  AND b.idfHumanCase IS NULL
							  )
						   OR (
								  a.idfHumanCase IS NULL
								  AND b.idfHumanCase IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79620000000, --idfInvestigatedByOffice
							a.idfHumanCase,
							NULL,
							b.idfInvestigatedByOffice,
							a.idfInvestigatedByOffice,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfInvestigatedByOffice <> b.idfInvestigatedByOffice)
						   OR (
								  a.idfInvestigatedByOffice IS NOT NULL
								  AND b.idfInvestigatedByOffice IS NULL
							  )
						   OR (
								  a.idfInvestigatedByOffice IS NULL
								  AND b.idfInvestigatedByOffice IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79630000000, --idfPointGeoLocation
							a.idfHumanCase,
							NULL,
							b.idfPointGeoLocation,
							a.idfPointGeoLocation,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfPointGeoLocation <> b.idfPointGeoLocation)
						   OR (
								  a.idfPointGeoLocation IS NOT NULL
								  AND b.idfPointGeoLocation IS NULL
							  )
						   OR (
								  a.idfPointGeoLocation IS NULL
								  AND b.idfPointGeoLocation IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79640000000, --idfReceivedByOffice
							a.idfHumanCase,
							NULL,
							b.idfReceivedByOffice,
							a.idfReceivedByOffice,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfReceivedByOffice <> b.idfReceivedByOffice)
						   OR (
								  a.idfReceivedByOffice IS NOT NULL
								  AND b.idfReceivedByOffice IS NULL
							  )
						   OR (
								  a.idfReceivedByOffice IS NULL
								  AND b.idfReceivedByOffice IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79660000000, --idfsFinalDiagnosis
							a.idfHumanCase,
							NULL,
							b.idfsFinalDiagnosis,
							a.idfsFinalDiagnosis,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsFinalDiagnosis <> b.idfsFinalDiagnosis)
						   OR (
								  a.idfsFinalDiagnosis IS NOT NULL
								  AND b.idfsFinalDiagnosis IS NULL
							  )
						   OR (
								  a.idfsFinalDiagnosis IS NULL
								  AND b.idfsFinalDiagnosis IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79670000000, --idfsFinalState
							a.idfHumanCase,
							NULL,
							b.idfsFinalState,
							a.idfsFinalState,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsFinalState <> b.idfsFinalState)
						   OR (
								  a.idfsFinalState IS NOT NULL
								  AND b.idfsFinalState IS NULL
							  )
						   OR (
								  a.idfsFinalState IS NULL
								  AND b.idfsFinalState IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79680000000, --idfsHospitalizationStatus
							a.idfHumanCase,
							NULL,
							b.idfsHospitalizationStatus,
							a.idfsHospitalizationStatus,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsHospitalizationStatus <> b.idfsHospitalizationStatus)
						   OR (
								  a.idfsHospitalizationStatus IS NOT NULL
								  AND b.idfsHospitalizationStatus IS NULL
							  )
						   OR (
								  a.idfsHospitalizationStatus IS NULL
								  AND b.idfsHospitalizationStatus IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79690000000, --idfsHumanAgeType
							a.idfHumanCase,
							NULL,
							b.idfsHumanAgeType,
							a.idfsHumanAgeType,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsHumanAgeType <> b.idfsHumanAgeType)
						   OR (
								  a.idfsHumanAgeType IS NOT NULL
								  AND b.idfsHumanAgeType IS NULL
							  )
						   OR (
								  a.idfsHumanAgeType IS NULL
								  AND b.idfsHumanAgeType IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79700000000, --idfsInitialCaseStatus
							a.idfHumanCase,
							NULL,
							b.idfsInitialCaseStatus,
							a.idfsInitialCaseStatus,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsInitialCaseStatus <> b.idfsInitialCaseStatus)
						   OR (
								  a.idfsInitialCaseStatus IS NOT NULL
								  AND b.idfsInitialCaseStatus IS NULL
							  )
						   OR (
								  a.idfsInitialCaseStatus IS NULL
								  AND b.idfsInitialCaseStatus IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79710000000, --idfsOutcome
							a.idfHumanCase,
							NULL,
							b.idfsOutcome,
							a.idfsOutcome,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsOutcome <> b.idfsOutcome)
						   OR (
								  a.idfsOutcome IS NOT NULL
								  AND b.idfsOutcome IS NULL
							  )
						   OR (
								  a.idfsOutcome IS NULL
								  AND b.idfsOutcome IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79720000000, --idfsTentativeDiagnosis
							a.idfHumanCase,
							NULL,
							b.idfsTentativeDiagnosis,
							a.idfsTentativeDiagnosis,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsTentativeDiagnosis <> b.idfsTentativeDiagnosis)
						   OR (
								  a.idfsTentativeDiagnosis IS NOT NULL
								  AND b.idfsTentativeDiagnosis IS NULL
							  )
						   OR (
								  a.idfsTentativeDiagnosis IS NULL
								  AND b.idfsTentativeDiagnosis IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79730000000, --idfsYNAntimicrobialTherapy
							a.idfHumanCase,
							NULL,
							b.idfsYNAntimicrobialTherapy,
							a.idfsYNAntimicrobialTherapy,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsYNAntimicrobialTherapy <> b.idfsYNAntimicrobialTherapy)
						   OR (
								  a.idfsYNAntimicrobialTherapy IS NOT NULL
								  AND b.idfsYNAntimicrobialTherapy IS NULL
							  )
						   OR (
								  a.idfsYNAntimicrobialTherapy IS NULL
								  AND b.idfsYNAntimicrobialTherapy IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79740000000, --idfsYNHospitalization
							a.idfHumanCase,
							NULL,
							b.idfsYNHospitalization,
							a.idfsYNHospitalization,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsYNHospitalization <> b.idfsYNHospitalization)
						   OR (
								  a.idfsYNHospitalization IS NOT NULL
								  AND b.idfsYNHospitalization IS NULL
							  )
						   OR (
								  a.idfsYNHospitalization IS NULL
								  AND b.idfsYNHospitalization IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79750000000, --idfsYNRelatedToOutbreak
							a.idfHumanCase,
							NULL,
							b.idfsYNRelatedToOutbreak,
							a.idfsYNRelatedToOutbreak,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsYNRelatedToOutbreak <> b.idfsYNRelatedToOutbreak)
						   OR (
								  a.idfsYNRelatedToOutbreak IS NOT NULL
								  AND b.idfsYNRelatedToOutbreak IS NULL
							  )
						   OR (
								  a.idfsYNRelatedToOutbreak IS NULL
								  AND b.idfsYNRelatedToOutbreak IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79760000000, --idfsYNSpecimenCollected
							a.idfHumanCase,
							NULL,
							b.idfsYNSpecimenCollected,
							a.idfsYNSpecimenCollected,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsYNSpecimenCollected <> b.idfsYNSpecimenCollected)
						   OR (
								  a.idfsYNSpecimenCollected IS NOT NULL
								  AND b.idfsYNSpecimenCollected IS NULL
							  )
						   OR (
								  a.idfsYNSpecimenCollected IS NULL
								  AND b.idfsYNSpecimenCollected IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79770000000, --intPatientAge
							a.idfHumanCase,
							NULL,
							b.intPatientAge,
							a.intPatientAge,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.intPatientAge <> b.intPatientAge)
						   OR (
								  a.intPatientAge IS NOT NULL
								  AND b.intPatientAge IS NULL
							  )
						   OR (
								  a.intPatientAge IS NULL
								  AND b.intPatientAge IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79780000000, --strClinicalDiagnosis
							a.idfHumanCase,
							NULL,
							b.strClinicalDiagnosis,
							a.strClinicalDiagnosis,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strClinicalDiagnosis <> b.strClinicalDiagnosis)
						   OR (
								  a.strClinicalDiagnosis IS NOT NULL
								  AND b.strClinicalDiagnosis IS NULL
							  )
						   OR (
								  a.strClinicalDiagnosis IS NULL
								  AND b.strClinicalDiagnosis IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79790000000, --strCurrentLocation
							a.idfHumanCase,
							NULL,
							b.strCurrentLocation,
							a.strCurrentLocation,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strCurrentLocation <> b.strCurrentLocation)
						   OR (
								  a.strCurrentLocation IS NOT NULL
								  AND b.strCurrentLocation IS NULL
							  )
						   OR (
								  a.strCurrentLocation IS NULL
								  AND b.strCurrentLocation IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79800000000, --strEpidemiologistsName
							a.idfHumanCase,
							NULL,
							b.strEpidemiologistsName,
							a.strEpidemiologistsName,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strEpidemiologistsName <> b.strEpidemiologistsName)
						   OR (
								  a.strEpidemiologistsName IS NOT NULL
								  AND b.strEpidemiologistsName IS NULL
							  )
						   OR (
								  a.strEpidemiologistsName IS NULL
								  AND b.strEpidemiologistsName IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79810000000, --strHospitalizationPlace
							a.idfHumanCase,
							NULL,
							b.strHospitalizationPlace,
							a.strHospitalizationPlace,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strHospitalizationPlace <> b.strHospitalizationPlace)
						   OR (
								  a.strHospitalizationPlace IS NOT NULL
								  AND b.strHospitalizationPlace IS NULL
							  )
						   OR (
								  a.strHospitalizationPlace IS NULL
								  AND b.strHospitalizationPlace IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79820000000, --strLocalIdentifier
							a.idfHumanCase,
							NULL,
							b.strLocalIdentifier,
							a.strLocalIdentifier,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strLocalIdentifier <> b.strLocalIdentifier)
						   OR (
								  a.strLocalIdentifier IS NOT NULL
								  AND b.strLocalIdentifier IS NULL
							  )
						   OR (
								  a.strLocalIdentifier IS NULL
								  AND b.strLocalIdentifier IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79830000000, --strNotCollectedReason
							a.idfHumanCase,
							NULL,
							b.strNotCollectedReason,
							a.strNotCollectedReason,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strNotCollectedReason <> b.strNotCollectedReason)
						   OR (
								  a.strNotCollectedReason IS NOT NULL
								  AND b.strNotCollectedReason IS NULL
							  )
						   OR (
								  a.strNotCollectedReason IS NULL
								  AND b.strNotCollectedReason IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79840000000, --strNote
							a.idfHumanCase,
							NULL,
							b.strNote,
							a.strNote,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strNote <> b.strNote)
						   OR (
								  a.strNote IS NOT NULL
								  AND b.strNote IS NULL
							  )
						   OR (
								  a.strNote IS NULL
								  AND b.strNote IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79850000000, --strReceivedByFirstName
							a.idfHumanCase,
							NULL,
							b.strReceivedByFirstName,
							a.strReceivedByFirstName,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strReceivedByFirstName <> b.strReceivedByFirstName)
						   OR (
								  a.strReceivedByFirstName IS NOT NULL
								  AND b.strReceivedByFirstName IS NULL
							  )
						   OR (
								  a.strReceivedByFirstName IS NULL
								  AND b.strReceivedByFirstName IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79860000000, --strReceivedByLastName
							a.idfHumanCase,
							NULL,
							b.strReceivedByLastName,
							a.strReceivedByLastName,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strReceivedByLastName <> b.strReceivedByLastName)
						   OR (
								  a.strReceivedByLastName IS NOT NULL
								  AND b.strReceivedByLastName IS NULL
							  )
						   OR (
								  a.strReceivedByLastName IS NULL
								  AND b.strReceivedByLastName IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79870000000, --strReceivedByPatronymicName
							a.idfHumanCase,
							NULL,
							b.strReceivedByPatronymicName,
							a.strReceivedByPatronymicName,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strReceivedByPatronymicName <> b.strReceivedByPatronymicName)
						   OR (
								  a.strReceivedByPatronymicName IS NOT NULL
								  AND b.strReceivedByPatronymicName IS NULL
							  )
						   OR (
								  a.strReceivedByPatronymicName IS NULL
								  AND b.strReceivedByPatronymicName IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79880000000, --strSentByFirstName
							a.idfHumanCase,
							NULL,
							b.strSentByFirstName,
							a.strSentByFirstName,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strSentByFirstName <> b.strSentByFirstName)
						   OR (
								  a.strSentByFirstName IS NOT NULL
								  AND b.strSentByFirstName IS NULL
							  )
						   OR (
								  a.strSentByFirstName IS NULL
								  AND b.strSentByFirstName IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79890000000, --strSentByLastName
							a.idfHumanCase,
							NULL,
							b.strSentByLastName,
							a.strSentByLastName,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strSentByLastName <> b.strSentByLastName)
						   OR (
								  a.strSentByLastName IS NOT NULL
								  AND b.strSentByLastName IS NULL
							  )
						   OR (
								  a.strSentByLastName IS NULL
								  AND b.strSentByLastName IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79900000000, --strSentByPatronymicName
							a.idfHumanCase,
							NULL,
							b.strSentByPatronymicName,
							a.strSentByPatronymicName,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strSentByPatronymicName <> b.strSentByPatronymicName)
						   OR (
								  a.strSentByPatronymicName IS NOT NULL
								  AND b.strSentByPatronymicName IS NULL
							  )
						   OR (
								  a.strSentByPatronymicName IS NULL
								  AND b.strSentByPatronymicName IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							79910000000, --strSoughtCareFacility
							a.idfHumanCase,
							NULL,
							b.strSoughtCareFacility,
							a.strSoughtCareFacility,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strSoughtCareFacility <> b.strSoughtCareFacility)
						   OR (
								  a.strSoughtCareFacility IS NOT NULL
								  AND b.strSoughtCareFacility IS NULL
							  )
						   OR (
								  a.strSoughtCareFacility IS NULL
								  AND b.strSoughtCareFacility IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							855690000000, --idfsFinalCaseStatus
							a.idfHumanCase,
							NULL,
							b.idfsFinalCaseStatus,
							a.idfsFinalCaseStatus,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsFinalCaseStatus <> b.idfsFinalCaseStatus)
						   OR (
								  a.idfsFinalCaseStatus IS NOT NULL
								  AND b.idfsFinalCaseStatus IS NULL
							  )
						   OR (
								  a.idfsFinalCaseStatus IS NULL
								  AND b.idfsFinalCaseStatus IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							855700000000, --idfSentByOffice
							a.idfHumanCase,
							NULL,
							b.idfSentByOffice,
							a.idfSentByOffice,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfSentByOffice <> b.idfSentByOffice)
						   OR (
								  a.idfSentByOffice IS NOT NULL
								  AND b.idfSentByOffice IS NULL
							  )
						   OR (
								  a.idfSentByOffice IS NULL
								  AND b.idfSentByOffice IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							855710000000, --idfEpiObservation
							a.idfHumanCase,
							NULL,
							b.idfEpiObservation,
							a.idfEpiObservation,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfEpiObservation <> b.idfEpiObservation)
						   OR (
								  a.idfEpiObservation IS NOT NULL
								  AND b.idfEpiObservation IS NULL
							  )
						   OR (
								  a.idfEpiObservation IS NULL
								  AND b.idfEpiObservation IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							855720000000, --idfCSObservation
							a.idfHumanCase,
							NULL,
							b.idfCSObservation,
							a.idfCSObservation,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfCSObservation <> b.idfCSObservation)
						   OR (
								  a.idfCSObservation IS NOT NULL
								  AND b.idfCSObservation IS NULL
							  )
						   OR (
								  a.idfCSObservation IS NULL
								  AND b.idfCSObservation IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							855730000000, --idfDeduplicationResultCase
							a.idfHumanCase,
							NULL,
							b.idfDeduplicationResultCase,
							a.idfDeduplicationResultCase,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfDeduplicationResultCase <> b.idfDeduplicationResultCase)
						   OR (
								  a.idfDeduplicationResultCase IS NOT NULL
								  AND b.idfDeduplicationResultCase IS NULL
							  )
						   OR (
								  a.idfDeduplicationResultCase IS NULL
								  AND b.idfDeduplicationResultCase IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							855740000000, --datNotificationDate
							a.idfHumanCase,
							NULL,
							b.datNotificationDate,
							a.datNotificationDate,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.datNotificationDate <> b.datNotificationDate)
						   OR (
								  a.datNotificationDate IS NOT NULL
								  AND b.datNotificationDate IS NULL
							  )
						   OR (
								  a.datNotificationDate IS NULL
								  AND b.datNotificationDate IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							855750000000, --datFirstSoughtCareDate
							a.idfHumanCase,
							NULL,
							b.datFirstSoughtCareDate,
							a.datFirstSoughtCareDate,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.datFirstSoughtCareDate <> b.datFirstSoughtCareDate)
						   OR (
								  a.datFirstSoughtCareDate IS NOT NULL
								  AND b.datFirstSoughtCareDate IS NULL
							  )
						   OR (
								  a.datFirstSoughtCareDate IS NULL
								  AND b.datFirstSoughtCareDate IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							855760000000, --datOnSetDate
							a.idfHumanCase,
							NULL,
							b.datOnSetDate,
							a.datOnSetDate,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.datOnSetDate <> b.datOnSetDate)
						   OR (
								  a.datOnSetDate IS NOT NULL
								  AND b.datOnSetDate IS NULL
							  )
						   OR (
								  a.datOnSetDate IS NULL
								  AND b.datOnSetDate IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							855770000000, --strClinicalNotes
							a.idfHumanCase,
							NULL,
							b.strClinicalNotes,
							a.strClinicalNotes,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strClinicalNotes <> b.strClinicalNotes)
						   OR (
								  a.strClinicalNotes IS NOT NULL
								  AND b.strClinicalNotes IS NULL
							  )
						   OR (
								  a.strClinicalNotes IS NULL
								  AND b.strClinicalNotes IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							855780000000, --strSummaryNotes
							a.idfHumanCase,
							NULL,
							b.strSummaryNotes,
							a.strSummaryNotes,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strSummaryNotes <> b.strSummaryNotes)
						   OR (
								  a.strSummaryNotes IS NOT NULL
								  AND b.strSummaryNotes IS NULL
							  )
						   OR (
								  a.strSummaryNotes IS NULL
								  AND b.strSummaryNotes IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							4577900000000, --idfHuman
							a.idfHumanCase,
							NULL,
							b.idfHuman,
							a.idfHuman,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfHuman <> b.idfHuman)
						   OR (
								  a.idfHuman IS NOT NULL
								  AND b.idfHuman IS NULL
							  )
						   OR (
								  a.idfHuman IS NULL
								  AND b.idfHuman IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							4577910000000, --idfPersonEnteredBy
							a.idfHumanCase,
							NULL,
							b.idfPersonEnteredBy,
							a.idfPersonEnteredBy,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfPersonEnteredBy <> b.idfPersonEnteredBy)
						   OR (
								  a.idfPersonEnteredBy IS NOT NULL
								  AND b.idfPersonEnteredBy IS NULL
							  )
						   OR (
								  a.idfPersonEnteredBy IS NULL
								  AND b.idfPersonEnteredBy IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							4578390000000, --idfSentByPerson
							a.idfHumanCase,
							NULL,
							b.idfSentByPerson,
							a.idfSentByPerson,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfSentByPerson <> b.idfSentByPerson)
						   OR (
								  a.idfSentByPerson IS NOT NULL
								  AND b.idfSentByPerson IS NULL
							  )
						   OR (
								  a.idfSentByPerson IS NULL
								  AND b.idfSentByPerson IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							4578400000000, --idfReceivedByPerson
							a.idfHumanCase,
							NULL,
							b.idfReceivedByPerson,
							a.idfReceivedByPerson,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfReceivedByPerson <> b.idfReceivedByPerson)
						   OR (
								  a.idfReceivedByPerson IS NOT NULL
								  AND b.idfReceivedByPerson IS NULL
							  )
						   OR (
								  a.idfReceivedByPerson IS NULL
								  AND b.idfReceivedByPerson IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							4578410000000, --idfInvestigatedByPerson
							a.idfHumanCase,
							NULL,
							b.idfInvestigatedByPerson,
							a.idfInvestigatedByPerson,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfInvestigatedByPerson <> b.idfInvestigatedByPerson)
						   OR (
								  a.idfInvestigatedByPerson IS NOT NULL
								  AND b.idfInvestigatedByPerson IS NULL
							  )
						   OR (
								  a.idfInvestigatedByPerson IS NULL
								  AND b.idfInvestigatedByPerson IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							4578420000000, --idfsYNTestsConducted
							a.idfHumanCase,
							NULL,
							b.idfsYNTestsConducted,
							a.idfsYNTestsConducted,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsYNTestsConducted <> b.idfsYNTestsConducted)
						   OR (
								  a.idfsYNTestsConducted IS NOT NULL
								  AND b.idfsYNTestsConducted IS NULL
							  )
						   OR (
								  a.idfsYNTestsConducted IS NULL
								  AND b.idfsYNTestsConducted IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							12014650000000, --idfSoughtCareFacility
							a.idfHumanCase,
							NULL,
							b.idfSoughtCareFacility,
							a.idfSoughtCareFacility,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfSoughtCareFacility <> b.idfSoughtCareFacility)
						   OR (
								  a.idfSoughtCareFacility IS NOT NULL
								  AND b.idfSoughtCareFacility IS NULL
							  )
						   OR (
								  a.idfSoughtCareFacility IS NULL
								  AND b.idfSoughtCareFacility IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							12014660000000, --idfsNonNotifiableDiagnosis
							a.idfHumanCase,
							NULL,
							b.idfsNonNotifiableDiagnosis,
							a.idfsNonNotifiableDiagnosis,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsNonNotifiableDiagnosis <> b.idfsNonNotifiableDiagnosis)
						   OR (
								  a.idfsNonNotifiableDiagnosis IS NOT NULL
								  AND b.idfsNonNotifiableDiagnosis IS NULL
							  )
						   OR (
								  a.idfsNonNotifiableDiagnosis IS NULL
								  AND b.idfsNonNotifiableDiagnosis IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							12014670000000, --idfsNotCollectedReason
							a.idfHumanCase,
							NULL,
							b.idfsNotCollectedReason,
							a.idfsNotCollectedReason,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsNotCollectedReason <> b.idfsNotCollectedReason)
						   OR (
								  a.idfsNotCollectedReason IS NOT NULL
								  AND b.idfsNotCollectedReason IS NULL
							  )
						   OR (
								  a.idfsNotCollectedReason IS NULL
								  AND b.idfsNotCollectedReason IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							12665410000000, --idfHumanCase
							a.idfHumanCase,
							NULL,
							b.idfHumanCase,
							a.idfHumanCase,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfHumanCase <> b.idfHumanCase)
						   OR (
								  a.idfHumanCase IS NOT NULL
								  AND b.idfHumanCase IS NULL
							  )
						   OR (
								  a.idfHumanCase IS NULL
								  AND b.idfHumanCase IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							12665420000000, --datEnteredDate
							a.idfHumanCase,
							NULL,
							b.datEnteredDate,
							a.datEnteredDate,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.datEnteredDate <> b.datEnteredDate)
						   OR (
								  a.datEnteredDate IS NOT NULL
								  AND b.datEnteredDate IS NULL
							  )
						   OR (
								  a.datEnteredDate IS NULL
								  AND b.datEnteredDate IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							12665430000000, --strCaseID
							a.idfHumanCase,
							NULL,
							b.strCaseID,
							a.strCaseID,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strCaseID <> b.strCaseID)
						   OR (
								  a.strCaseID IS NOT NULL
								  AND b.strCaseID IS NULL
							  )
						   OR (
								  a.strCaseID IS NULL
								  AND b.strCaseID IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							12665440000000, --idfsCaseProgressStatus
							a.idfHumanCase,
							NULL,
							b.idfsCaseProgressStatus,
							a.idfsCaseProgressStatus,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfsCaseProgressStatus <> b.idfsCaseProgressStatus)
						   OR (
								  a.idfsCaseProgressStatus IS NOT NULL
								  AND b.idfsCaseProgressStatus IS NULL
							  )
						   OR (
								  a.idfsCaseProgressStatus IS NULL
								  AND b.idfsCaseProgressStatus IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							12665450000000, --strSampleNotes
							a.idfHumanCase,
							NULL,
							b.strSampleNotes,
							a.strSampleNotes,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.strSampleNotes <> b.strSampleNotes)
						   OR (
								  a.strSampleNotes IS NOT NULL
								  AND b.strSampleNotes IS NULL
							  )
						   OR (
								  a.strSampleNotes IS NULL
								  AND b.strSampleNotes IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							12665460000000, --uidOfflineCaseID
							a.idfHumanCase,
							NULL,
							b.uidOfflineCaseID,
							a.uidOfflineCaseID,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.uidOfflineCaseID <> b.uidOfflineCaseID)
						   OR (
								  a.uidOfflineCaseID IS NOT NULL
								  AND b.uidOfflineCaseID IS NULL
							  )
						   OR (
								  a.uidOfflineCaseID IS NULL
								  AND b.uidOfflineCaseID IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							51389570000000, --datFinalCaseClassificationDate
							a.idfHumanCase,
							NULL,
							b.datFinalCaseClassificationDate,
							a.datFinalCaseClassificationDate,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.datFinalCaseClassificationDate <> b.datFinalCaseClassificationDate)
						   OR (
								  a.datFinalCaseClassificationDate IS NOT NULL
								  AND b.datFinalCaseClassificationDate IS NULL
							  )
						   OR (
								  a.datFinalCaseClassificationDate IS NULL
								  AND b.datFinalCaseClassificationDate IS NOT NULL
							  );



					 INSERT INTO dbo.tauDataAuditDetailUpdate
					 (
						 idfDataAuditEvent,
						 idfObjectTable,
						 idfColumn,
						 idfObject,
						 idfObjectDetail,
						 strOldValue,
						 strNewValue,
						 AuditCreateUser,
						 strObject
					 )
					 SELECT @DataAuditEventID,
							@ObjectTableID,
							51523420000000, --idfHospital
							a.idfHumanCase,
							NULL,
							b.idfHospital,
							a.idfHospital,
							@User,
							@idfHumanCase
					 FROM @HumanCaseAfterEdit AS a
						 FULL JOIN @HumanCaseBeforeEdit AS b
							 ON a.idfHumanCase = b.idfHumanCase
					 WHERE (a.idfHospital <> b.idfHospital)
						   OR (
								  a.idfHospital IS NOT NULL
								  AND b.idfHospital IS NULL
							  )
						   OR (
								  a.idfHospital IS NULL
								  AND b.idfHospital IS NOT NULL
							  );

					 --Date Audit Create Entry For Any Changes Made (End)

				END
				
				UPDATE	
						tlbHuman
				SET		
						idfCurrentResidenceAddress = @CaseGeoLocationID
				WHERE
						idfHuman = @idfHuman

				--Temp solution for correct DateTime2 json dates, when they are coming in at Min value
				SET @SamplesParameters = REPLACE ( @SamplesParameters , '"0001-01-01T00:00:00"' , 'null')  
				SET @TestsParameters = REPLACE ( @TestsParameters , '"0001-01-01T00:00:00"' , 'null')  
				SET @AntiviralTherapiesParameters = REPLACE ( @AntiviralTherapiesParameters , '"0001-01-01T00:00:00"' , 'null')  
				SET @VaccinationsParameters = REPLACE ( @VaccinationsParameters , '"0001-01-01T00:00:00"' , 'null')  

				----set AntiviralTherapies for this idfHumanCase
				If @AntiviralTherapiesParameters IS NOT NULL
					BEGIN
						DECLARE @OutbreakAntimicrobialTemp TABLE(
							antibioticID BIGINT NULL,
							idfHumanCase BIGINT NULL,
							idfAntimicrobialTherapy BIGINT NULL,
							strAntimicrobialTherapyName NVARCHAR(200) NULL,
							strDosage NVARCHAR(200) NULL,
							datFirstAdministeredDate DATETIME2 NULL,
							rowAction CHAR(1) NULL
						)

						INSERT INTO @OutbreakAntimicrobialTemp
							SELECT * FROM OPENJSON(@AntiviralTherapiesParameters)
							WITH(
								antibioticID BIGINT,
								idfHumanCase BIGINT,
								idfAntimicrobialTherapy BIGINT,
								strAntimicrobialTherapyName NVARCHAR(200),
								strDosage NVARCHAR(200),
								datFirstAdministeredDate DATETIME2,
								rowAction CHAR(1)
							)

						DECLARE @Antimicrobials NVARCHAR(MAX) = NULL

						SET @Antimicrobials = 
							(
							SELECT
								idfAntimicrobialTherapy,
								@idfHumanCase AS idfHumanCase,
								datFirstAdministeredDate,
								strAntimicrobialTherapyName,
								strDosage,
								rowAction
							FROM 
								@OutbreakAntimicrobialTemp
							FOR JSON PATH
						)

						--INSERT INTO @SupressSelect
						EXEC USSP_HUMAN_DISEASE_ANTIVIRALTHERAPIES_SET @idfHumanCase,@Antimicrobials, @outbreakCall = 1, @User = @User;
					END

				If @VaccinationsParameters IS NOT NULL
					BEGIN
						DECLARE @VaccinationsParametersTemp TABLE(
							vaccinationID BIGINT NULL,
							humanDiseaseReportVaccinationUID BIGINT NULL,
							idfHumanCase BIGINT NULL,
							vaccinationName NVARCHAR(200) NULL,
							vaccinationDate DATETIME2 NULL,
							rowAction CHAR(1) NULL,
							intRowStatus INT NULL
						)


						INSERT INTO @VaccinationsParametersTemp
							SELECT * FROM OPENJSON(@VaccinationsParameters)
							WITH(
								vaccinationID BIGINT,
								humanDiseaseReportVaccinationUID BIGINT,
								idfHumanCase BIGINT,
								vaccinationName NVARCHAR(200),
								vaccinationDate DATETIME2,
								rowAction NVARCHAR(1),
								intRowStatus INT
							)
						
						DECLARE @Vaccinations NVARCHAR(MAX) = NULL
						SET @Vaccinations = 
							(
							SELECT
								vaccinationID,
								humanDiseaseReportVaccinationUID,
								@idfHumanCase AS idfHumanCase,
								vaccinationName,
								vaccinationDate,
								rowAction,
								intRowStatus
							FROM 
								@VaccinationsParametersTemp
							FOR JSON PATH
						)

						--INSERT INTO @SupressSelect
						EXEC USSP_HUMAN_DISEASE_VACCINATIONS_SET @idfHumanCase,@Vaccinations,@outbreakCall=1, @User = @User;
					END
				
				
				--set Samples for this idfHumanCase	
				If @SamplesParameters IS NOT NULL
					BEGIN
						--INSERT INTO @SupressSelect
						EXEC USSP_OMM_HUMAN_SAMPLES_SET @idfHumanActual, @idfHumanCase= @idfHumanCase, @SamplesParameters = @SamplesParameters, @User = @User, @TestsParameters = @TestsParameters, @idfsFinalDiagnosis = @idfsFinalDiagnosis;
					END
		
				-- update tlbHuman IF datDateofDeath is provided.
				IF @datDateofDeath IS NOT NULL
					BEGIN
						UPDATE dbo.tlbHuman
						SET		datDateofDeath = @datDateofDeath
						WHERE idfHuman = @idfHuman
					END
		
		IF @@TRANCOUNT > 0 
			COMMIT
			
	END TRY
	BEGIN CATCH
			IF @@Trancount = 1 
				ROLLBACK;

				THROW;
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_REF_DIAGNOSISREFERENCE_DEL]...';


GO
--=================================================================================================
-- Name: USP_REF_DIAGNOSISREFERENCE_DEL
--
-- Description: Removes disease reference from active list of diseases
--							
-- Author:		Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		09/26/2018 Initial Release
-- Ricky Moss		12/12/2018 Removed return codes
-- Ricky Moss		02/09/2019 Added removal of tests, sample type and penside tests from disease
-- Ricky Moss		03/31/2019 Remove delete Anyway parameter
-- Leo Tracchia		11/25/2020 Added @forceDelete parameter as optional
-- Doug Albanese	08/03/2021 Added the deletion routine to deactivate the record tied to the 
--                             base reference
-- Stephen Long     10/31/2022 Added site alert logic.
-- Leo Tracchia		02/20/2023 Added data audit logic for deletes
-- Leo Tracchia     05/01/2023 Fixed bug for data audit logs on deletes
--
-- Test Code:
-- exec USP_REF_DIAGNOSISREFERENCE_DEL 6618200000000, 0
--=================================================================================================
ALTER PROCEDURE [dbo].[USP_REF_DIAGNOSISREFERENCE_DEL]
(
    @IdfsDiagnosis BIGINT,
    @ForceDelete bit = 0,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    BEGIN TRY
        DECLARE @ReturnCode INT = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );

        IF (
               (
                   NOT EXISTS
        (
            SELECT idfAggrDiagnosticActionMTX
            FROM dbo.tlbAggrDiagnosticActionMTX
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfAggrHumanCaseMTX
            FROM dbo.tlbAggrHumanCaseMTX
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfAggrDiagnosticActionMTX
            FROM dbo.tlbAggrDiagnosticActionMTX
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfAggrProphylacticActionMTX
            FROM dbo.tlbAggrProphylacticActionMTX
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfAggrVetCaseMTX
            FROM dbo.tlbAggrVetCaseMTX
            WHERE idfsSpeciesType = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfCampaign
            FROM dbo.tlbCampaignToDiagnosis
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfCampaignToDiagnosis
            FROM dbo.tlbCampaignToDiagnosis
            WHERE idfsSpeciesType = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfMonitoringSession
            FROM dbo.tlbMonitoringSessionToDiagnosis
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfMonitoringSessionToDiagnosis
            FROM dbo.tlbMonitoringSessionToDiagnosis
            WHERE idfsSpeciesType = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfMonitoringSessionSummary
            FROM dbo.tlbMonitoringSessionSummaryDiagnosis
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfPensideTest
            FROM dbo.tlbPensideTest
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfTesting
            FROM dbo.tlbTesting
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfTestValidation
            FROM dbo.tlbTestValidation
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfVaccination
            FROM dbo.tlbVaccination
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfsVSSessionSummaryDiagnosis
            FROM dbo.tlbVectorSurveillanceSessionSummaryDiagnosis
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfDiagnosisAgeGroupToDiagnosis
            FROM dbo.trtDiagnosisAgeGroupToDiagnosis
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfDiagnosisToGroupForReportType
            FROM dbo.trtDiagnosisToGroupForReportType
            WHERE idfsDiagnosis = @IdfsDiagnosis
        )
                   AND NOT EXISTS
        (
            SELECT idfFFObjectToDiagnosisForCustomReport
            FROM dbo.trtFFObjectToDiagnosisForCustomReport
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
               )
               or @ForceDelete = 1
           )
        BEGIN
			
			--Begin: Data Audit--	

				DECLARE @idfUserId BIGINT = @UserId;
				DECLARE @idfSiteId BIGINT = @SiteId;
				DECLARE @idfsDataAuditEventType bigint = NULL;
				DECLARE @idfsObjectType bigint = 10017018; 
				DECLARE @idfObject bigint = @IdfsDiagnosis;
				DECLARE @idfObjectTable_trtDiagnosis bigint = 75840000000;		
				DECLARE @idfObjectTable_trtBaseReference bigint = 75820000000;
				DECLARE @idfObjectTable_trtStringNameTranslation bigint = 75990000000;
				DECLARE @idfDataAuditEvent bigint = NULL;	

				-- tauDataAuditEvent Event Type - Delete 
				set @idfsDataAuditEventType = 10016002;
			
				-- insert record into tauDataAuditEvent - 
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfObject, @idfObjectTable_trtDiagnosis, @idfDataAuditEvent OUTPUT

			--End: Data Audit--	

            UPDATE dbo.trtDiagnosis
            SET intRowStatus = 1
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0

			--Begin: Data Audit, trtDiagnosis--				

				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject)
				VALUES (@idfDataAuditEvent, @idfObjectTable_trtDiagnosis, @idfObject)

			--End: Data Audit, trtDiagnosis--
				  
            UPDATE dbo.trtBaseReference
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @IdfsDiagnosis
                  AND intRowStatus = 0

			--Begin: Data Audit, trtBaseReference--				

				-- insert record into tauDataAuditEvent - 
				--INSERT INTO @SuppressSelect
				--EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfObject, @idfObjectTable_trtBaseReference, @idfDataAuditEvent OUTPUT

				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject)
				VALUES (@idfDataAuditEvent, @idfObjectTable_trtBaseReference, @idfObject)

			--End: Data Audit, trtBaseReference--

            UPDATE dbo.trtStringNameTranslation
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @IdfsDiagnosis

			--Begin: Data Audit, trtStringNameTranslation--				

				-- insert record into tauDataAuditEvent - 
				--INSERT INTO @SuppressSelect
				--EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfObject, @idfObjectTable_trtStringNameTranslation, @idfDataAuditEvent OUTPUT

				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject)
				VALUES (@idfDataAuditEvent, @idfObjectTable_trtStringNameTranslation, @idfObject)

			--End: Data Audit, trtStringNameTranslation--

            UPDATE dbo.trtBaseReference
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @IdfsDiagnosis		

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @IdfsDiagnosis,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;
        END
        ELSE
        BEGIN
            SELECT @ReturnCode = -1;
            SELECT @ReturnMessage = 'IN USE';
        END

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO
PRINT N'Creating Procedure [dbo].[USP_GBL_NEXTKEYID_GET_PRE_GET]...';


GO
-- ============================================================================
-- Name: USP_GBL_NEXTKEYID_GET
-- Description:	Gets a new ID (primary key) value for a given table
--                   
-- Author: Mandar Kulkarni
-- Date 11/08/2017
--
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Steven Verner	03/26/2021	Removed @returnCode and @returnMessage variables and instead
--								throw exception, which floats up to calling SP and handled
--								(I primarily made this change to allow EF Power Tools to generate POCOs for SET operations)
/*
----testing code:
DECLARE	@return_value int,
		@idfsKey bigint
EXEC	@return_value = [dbo].[USP_GBL_NEXTKEYID_GET]
		@tableName = N'lkupconfigparm',
		@idfsKey = @idfsKey OUTPUT
*/
--=====================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_NEXTKEYID_GET_PRE_GET] 
(
 @tableName VARCHAR(100),
 @idfsKey	BIGINT = 0 OUTPUT
)
AS
DECLARE @sqlString		NVARCHAR(max) 
DECLARE @increamentBy	INT = 1;

------==================================================
------for local debug 
----DECLARE  @tableName VARCHAR(100), @idfsKey	BIGINT 
--------SET @tableName='trtBaseReference'
----SET @tableName='lkupconfigparm'
------==================================================
BEGIN
	BEGIN TRY  
		----prepare next ID based on returned highest id
		EXEC [dbo].[USP_GBL_NEXTKEYID_PRE_GET] @tableName, @idfsKey OUTPUT
		----PRINT '@idfsKey returned: '+ CONVERT(VARCHAR(20),@idfsKey) 

		SET @idfsKey=@idfsKey+@increamentBy
		----PRINT '@idfsKey for next: '+ CONVERT(VARCHAR(20),@idfsKey) 

		-- Check if table name exists in the Primary Keys table
		IF EXISTS (SELECT * FROM dbo.LKUPNextKey WHERE tableName = @tableName)
		-- If table row exists, update info
		BEGIN
			-- update the last key value in the table for the next time.
			UPDATE	dbo.LKUPNextKey
			SET		LastUsedKey = @idfsKey,
					AuditUpdateDTM=GETDATE()
			WHERE	tableName = @tableName

		END ELSE 
		-- If table row does not exists, insert  a new row. 
		BEGIN
			INSERT
			INTO dbo.LKUPNextKey
			(
			TableName,
			LastUsedKey,
			intRowStatus
			)
			VALUES
			(
			@tableName,
			@idfsKey,
			0
			)
		END
	END TRY  
	BEGIN CATCH 
		THROW
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_EMPLOYEEGROUP_SET]...';


GO
-- ===============================================================================================================
-- Name: USP_ADMIN_EMPLOYEEGROUP_SET
-- Description: Add or reactivates a relationship between an employee and employee group
-- Author: Ricky Moss
--
-- History of changes
--
-- Name					Date			Change
-- ---------------------------------------------------------------------------------------------------------------
-- Ricky Moss			12/02/2019		Initial Release
-- Ricky Moss			03/25/2019		Added EmployeeGroupName when checking for duplicate and refactored the 
--                                      query checking for duplicates
-- Stephen Long         05/19/2020 Updated existing default and name queries to use top 1 as the name was 
--                                 returning duplicates causing a subquery error.
-- Ann Xiong            01/27/2021 Modified to pass 10023001 (Employee Group) instead of 10023002 (Person) 
--                                 as idfsEmployeeType when insert new Employee Group to tlbEmployee.
-- Mandar				07/09/2021 Fixed an issue when creating a new user group.
-- Ann Xiong            10/28/2021 Modified to return ReturnMessage instead of RetunMessage.
-- Stephen Long         03/14/2022 Removed insert suppress select on base reference set; causing nested insert 
--                                 exec on USP_ADMIN_SITE_SET call.
-- Ann Xiong			02/23/2023 Fixed the issue "Subquery returned more than 1 value".
-- Ann Xiong			02/28/2023 Implemented Data Audit
-- Ann Xiong			03/01/2023 Fixed the issue of National Name not saved
-- Ann Xiong			04/25/2023	Added parameters @strEmployees, @rolesandfunctions, @strDashboardObject
--
-- EXEC USP_ADMIN_EMPLOYEEGROUP_SET -500, 1, 'Test 1204-7', 'Test 1204-7', 'Test Role on December 4',  'en', NULL
-- EXEC USP_ADMIN_EMPLOYEEGROUP_SET NULL, 1, 'Test 1205', 'Test 1205', 'Test Role on December 5',  'en', NULL
-- EXEC USP_ADMIN_EMPLOYEEGROUP_SET NULL, 1, 'Test 1212-1', 'Test 1212-1', 'Test Role on December 12',  'en', NULL
-- ===============================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_EMPLOYEEGROUP_SET] (
	@idfEmployeeGroup BIGINT,
	@idfsSite BIGINT,
	@strDefault NVARCHAR(200),
	@strName NVARCHAR(200),
	@strDescription NVARCHAR(200),
	@langId NVARCHAR(50),
	@strEmployees NVARCHAR(MAX) = NULL, -- Comma seperated list of employees or user groups to be deleted as BIGINT
	@rolesandfunctions NVARCHAR(MAX) = NULL,
	@strDashboardObject NVARCHAR(1000) = NULL,
	@user NVARCHAR(200)
	)
AS
DECLARE @returnCode INT = 0
DECLARE @returnMsg NVARCHAR(50) = 'SUCCESS'
DECLARE @idfsEmployeeGroupName BIGINT
DECLARE @idfEmployee BIGINT
DECLARE @SupressSelect TABLE (
	ReturnCode INT,
	ReturnMessage VARCHAR(200)
	)
DECLARE @existingDefault BIGINT
DECLARE @existingName BIGINT

		--Data Audit--
		declare @idfUserId BIGINT = NULL;
		declare @idfSiteId BIGINT = NULL;
		declare @idfsDataAuditEventType bigint = NULL;
		declare @idfsObjectType bigint = 10017058;                         -- User Group
		declare @idfObject bigint = @idfEmployeeGroup;
		declare @idfDataAuditEvent bigint= NULL;
		declare @idfObjectTable_tlbEmployee bigint = 75520000000;
		declare @idfObjectTable_tlbEmployeeGroup bigint = 75530000000;
		declare @idfObjectTable_trtBaseReference BIGINT = 75820000000;

		DECLARE @tlbEmployeeGroup_BeforeEdit TABLE
		(
			EmployeeGroupID BIGINT,
			strName varchar(200),
			strDescription varchar(200)
		);
		DECLARE @tlbEmployeeGroup_AfterEdit TABLE
		(
			EmployeeGroupID BIGINT,
			strName varchar(200),
			strDescription varchar(200)
		);
		DECLARE @trtBaseReference_BeforeEdit TABLE
		(
    		BaseReferenceID BIGINT,
    		DefaultValue NVARCHAR(2000)
		);
		DECLARE @trtBaseReference_AfterEdit TABLE
		(
    		BaseReferenceID BIGINT,
    		DefaultValue NVARCHAR(2000)
		);

		-- Get and Set UserId and SiteId
		select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation(@user) userInfo

		--Data Audit--

BEGIN
	BEGIN TRY
		SELECT @existingDefault = (
				SELECT TOP 1 idfsReference
				FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000022)
				WHERE strDefault = @strDefault
				)

		SELECT @existingName = (
				SELECT TOP 1 idfsReference
				FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000022)
				WHERE [name] = @strName
				)

		IF (
				@existingDefault IS NOT NULL
				OR @existingName IS NOT NULL
				)
			SELECT @idfsEmployeeGroupName = (
					SELECT TOP 1 idfsEmployeeGroupName
					FROM dbo.tlbEmployeeGroup
					WHERE idfsEmployeeGroupName IN (
							@existingDefault,
							@existingName
							)
					)

		IF (
				@existingDefault IS NOT NULL
				AND @existingDefault <> @idfsEmployeeGroupName
				AND @idfsEmployeeGroupName IS NOT NULL
				)
			OR (
				@existingDefault IS NOT NULL
				AND @idfsEmployeeGroupName IS NULL
				)
			OR (
				@existingName IS NOT NULL
				AND @existingName <> @idfsEmployeeGroupName
				AND @idfsEmployeeGroupName IS NOT NULL
				)
			OR (
				@existingName IS NOT NULL
				AND @idfEmployeeGroup IS NULL
				)
		BEGIN
			SELECT @idfEmployeeGroup = (
					SELECT TOP 1 idfEmployeeGroup
					FROM dbo.tlbEmployeeGroup
					WHERE strName = @strName
					)

			SELECT @returnMsg = 'DOES EXIST'
		END
		ELSE IF @idfEmployeeGroup IS NOT NULL
		BEGIN
			SELECT @idfsEmployeeGroupName = (
					SELECT idfsEmployeeGroupName
					FROM dbo.tlbEmployeeGroup
					WHERE idfEmployeeGroup = @idfEmployeeGroup
					)

            -- Data audit
            INSERT INTO @trtBaseReference_BeforeEdit
            (
                BaseReferenceID,
                DefaultValue
            )
            SELECT idfsBaseReference,
                   strDefault
            FROM dbo.trtBaseReference
            WHERE idfsBaseReference = @idfsEmployeeGroupName
            -- End data audit

			UPDATE dbo.trtBaseReference
			SET strDefault = @strDefault
			WHERE idfsBaseReference = @idfsEmployeeGroupName

            -- Data audit
            INSERT INTO @trtBaseReference_AfterEdit
            (
                BaseReferenceID,
                DefaultValue
            )
            SELECT idfsBaseReference,
                   strDefault
            FROM dbo.trtBaseReference
            WHERE idfsBaseReference = @idfsEmployeeGroupName

			--  tauDataAuditEvent  Event Type- Edit 
			set @idfsDataAuditEventType =10016003;
			-- insert record into tauDataAuditEvent - 
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfEmployeeGroup, @idfObjectTable_tlbEmployeeGroup, @idfDataAuditEvent OUTPUT

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @idfDataAuditEvent,
                   @idfObjectTable_trtBaseReference,
                   81120000000,
                   a.BaseReferenceID,
                   NULL,
                   b.DefaultValue,
                   a.DefaultValue
            FROM @trtBaseReference_AfterEdit AS a
                FULL JOIN @trtBaseReference_BeforeEdit AS b
                    ON a.BaseReferenceID = b.BaseReferenceID
            WHERE (a.DefaultValue <> b.DefaultValue)
                  OR (
                         a.DefaultValue IS NOT NULL
                         AND b.DefaultValue IS NULL
                     )
                  OR (
                         a.DefaultValue IS NULL
                         AND b.DefaultValue IS NOT NULL
                     );
            -- Data audit

			-- Data audit
            INSERT INTO @tlbEmployeeGroup_BeforeEdit
            (
                        EmployeeGroupID,
                           strName,
                           strDescription
            )
            SELECT	idfEmployeeGroup,
                           strName,
                           strDescription
           FROM dbo.tlbEmployeeGroup
		   WHERE idfEmployeeGroup = @idfEmployeeGroup
           -- End data audit

			UPDATE dbo.tlbEmployeeGroup
			SET strName = @strName,
				strDescription = @strDescription
			WHERE idfEmployeeGroup = @idfEmployeeGroup

			-- Data audit
            INSERT INTO @tlbEmployeeGroup_AfterEdit
            (
                        EmployeeGroupID,
                           strName,
                           strDescription
            )
            SELECT	idfEmployeeGroup,
                           strName,
                           strDescription
           FROM dbo.tlbEmployeeGroup
		   WHERE idfEmployeeGroup = @idfEmployeeGroup

		   insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbEmployeeGroup, 78710000000,
					a.EmployeeGroupID,null,
					a.strName,b.strName
			from @tlbEmployeeGroup_BeforeEdit a  inner join @tlbEmployeeGroup_AfterEdit b on a.EmployeeGroupID = b.EmployeeGroupID
			where (a.strName <> b.strName) 
					or(a.strName is not null and b.strName is null)
					or(a.strName is null and b.strName is not null)

			insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbEmployeeGroup, 78700000000,
					a.EmployeeGroupID,null,
					a.strDescription,b.strDescription
			from @tlbEmployeeGroup_BeforeEdit a  inner join @tlbEmployeeGroup_AfterEdit b on a.EmployeeGroupID = b.EmployeeGroupID
			where (a.strDescription <> b.strDescription) 
					or(a.strDescription is not null and b.strDescription is null)
					or(a.strDescription is null and b.strDescription is not null)

			--Data Audit--
		END
		ELSE
		BEGIN
			SET @idfEmployeeGroup = (
					SELECT MIN(idfEmployee) - 1
					FROM dbo.tlbEmployee
					)

			--Data Audit--
			-- tauDataAuditEvent Event Type - Create 
			set @idfsDataAuditEventType =10016001;
			-- insert record into tauDataAuditEvent - 
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfEmployeeGroup, @idfObjectTable_tlbEmployeeGroup, @idfDataAuditEvent OUTPUT
			--Data Audit--
			
			--INSERT INTO @SupressSelect
			--EXEC dbo.USP_GBL_BaseReference_SET
			--	@ReferenceID=@idfsEmployeeGroupName OUTPUT, 
			--	@ReferenceType=19000022, 
			--	@LangID=@LangID, 
			--	@DefaultName=@strDefault, 
			--	@NationalName=@strName, 
			--	@HACode=226, 
			--	@Order=0, 
			--	@System=0;

            EXECUTE dbo.USSP_GBL_BASE_REFERENCE_SET @idfsEmployeeGroupName OUTPUT,
                                                        19000022,
                                                        @LangID,
                                                        @strDefault,
                                                        @strName,
                                                        226,
                                                        0,
                                                        0,
                                                        @User,
                                                        @idfDataAuditEvent,
                                                        NULL;

			INSERT INTO dbo.tlbEmployee (
				idfEmployee,
				idfsEmployeeType,
				idfsSite,
				intRowStatus
				)
			VALUES (
				@idfEmployeeGroup,
				10023001,
				@idfsSite,
				0
				)

			--Data Audit--
			INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tlbEmployee, @idfEmployeeGroup)
			--Data Audit--

			INSERT INTO dbo.tlbEmployeeGroup (
				idfEmployeeGroup,
				idfsEmployeeGroupName,
				idfsSite,
				strName,
				strDescription,
				intRowStatus
				)
			VALUES (
				@idfEmployeeGroup,
				@idfsEmployeeGroupName,
				@idfsSite,
				@strName,
				@strDescription,
				0
				)

			--Data Audit--
			INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tlbEmployeeGroup, @idfEmployeeGroup)
			--Data Audit--

			DECLARE @tempRSFA TABLE (
				RoleId BIGINT,
				SystemFunction BIGINT,
				Operation BIGINT,
				intRowStatus INT,
				intRowStatusForSystemFunction INT
				)

			INSERT INTO @tempRSFA
			SELECT *
			FROM OPENJSON(@rolesandfunctions) WITH (
				RoleId BIGINT,
				SystemFunction BIGINT,
				Operation BIGINT,
				intRowStatus INT,
				intRowStatusForSystemFunction INT
				)

            UPDATE @tempRSFA
            SET RoleId = @idfEmployeeGroup;

			SET @rolesandfunctions =
			(
				SELECT 
					RoleId,
					SystemFunction,
					Operation,
					intRowStatus,
					intRowStatusForSystemFunction
				FROM @tempRSFA
				FOR JSON PATH);
		END

		-- Call USP_ADMIN_USERGROUPTOEMPLOYEE_SET
		IF @strEmployees IS NOT NULL AND @strEmployees <> ''
		BEGIN
		INSERT INTO @SupressSelect
		EXEC dbo.USP_ADMIN_USERGROUPTOEMPLOYEE_SET
			@idfEmployeeGroup = @idfEmployeeGroup,
			@strEmployees = @strEmployees,
			@idfDataAuditEvent = @idfDataAuditEvent,
			@user = @user
		END

		--Call  USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_SET
		IF @strDashboardObject IS NOT NULL
		BEGIN
		INSERT INTO @SupressSelect
		EXEC dbo.USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_SET
			@roleID = @idfEmployeeGroup,
			@strDashboardObject = @strDashboardObject,
			@idfDataAuditEvent = @idfDataAuditEvent,
			@user = @user
		END

		--Call USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SET
		IF @rolesandfunctions IS NOT NULL
		BEGIN
		INSERT INTO @SupressSelect
			EXEC dbo.USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SET
				@rolesandfunctions = @rolesandfunctions,
				@idfDataAuditEvent = @idfDataAuditEvent,
				@user = @user
		END

		SELECT @returnCode 'ReturnCode',
			@returnMsg 'ReturnMessage',
			@idfEmployeeGroup 'idfEmployeeGroup',
			@idfsEmployeeGroupName 'idfsEmployeeGroupName'
	END TRY

	BEGIN CATCH
		THROW
	END CATCH
END
GO
PRINT N'Refreshing Procedure [dbo].[spAsQueryFunction_Post]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[spAsQueryFunction_Post]';


GO
PRINT N'Refreshing Procedure [dbo].[USP_OMM_Case_Set]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[USP_OMM_Case_Set]';


GO
PRINT N'Refreshing Procedure [dbo].[USSP_OMM_CONVERT_CONTACT_Set]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[USSP_OMM_CONVERT_CONTACT_Set]';


GO
PRINT N'Refreshing Procedure [dbo].[USP_OMM_Contact_Set]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[USP_OMM_Contact_Set]';


GO
PRINT N'Refreshing Procedure [dbo].[USP_ADMIN_EMPLOYEEGROUP_SET_TEMP]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[USP_ADMIN_EMPLOYEEGROUP_SET_TEMP]';


GO
PRINT N'Checking existing data against newly created constraints';


GO
ALTER TABLE [dbo].[gisImportedMap] WITH CHECK CHECK CONSTRAINT [FK_gisImportedMap_trtBaseReference_SourceSystemNameID];

ALTER TABLE [dbo].[gisImportedMap] WITH CHECK CHECK CONSTRAINT [FK_gisImportedMap_tstSite__idfsSite];


GO
PRINT N'Update complete.';


GO
