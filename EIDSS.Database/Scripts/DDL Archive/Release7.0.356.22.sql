

GO
--##SUMMARY This procedure saves changes of specified query
--##SUMMARY (including creation and deletion (in case of incorrect parameters) of the query).

--##REMARKS Author: Mirnaya O.
--##REMARKS Create date: 21.04.2010

--##REMARKS UPDATED BY: Vorobiev E.
--##REMARKS Date: 11.11.2011

--##REMARKS UPDATED BY: Torres E.
--##REMARKS Date: 07/18/2022
--## Added fields idfOffice and idfOffice

--##RETURNS Don't use

/*
--Example of a call of procedure:

declare	@idflQuery					bigint
declare	@idfOffice					bigint
declare	@idfEmployee				bigint
declare	@strFunctionName			nvarchar(200)
declare	@idflDescription			bigint
declare	@DefQueryName				nvarchar(2000)
declare	@QueryName					nvarchar(2000)
declare	@DefQueryDescription		nvarchar(2000)
declare	@QueryDescription			nvarchar(2000)
declare	@blnAddAllKeyFieldValues	bit
declare	@LangID						nvarchar(50)

execute	spAsQuery_Post
		 @idflQuery output
		,@idfOffice output
		,@idfEmployee output
		,@strFunctionName output
		,@idflDescription output
		,@DefQueryName,
		,@QueryName
		,@DefQueryDescription,
		,@QueryDescription
		,@blnAddAllKeyFieldValues
		,@LangID

*/ 


ALTER procedure	[dbo].[spAsQuery_Post]
(
	@idflQuery					bigint output,
	@idfOffice					bigint output,
	@idfEmployee				bigint output,
	@strFunctionName			nvarchar(200) = null output,
	@idflDescription			bigint output,
	@DefQueryName				nvarchar(2000),
	@QueryName					nvarchar(2000),
	@DefQueryDescription		nvarchar(2000),
	@QueryDescription			nvarchar(2000),
	@blnAddAllKeyFieldValues	bit = 0,
	@LangID						nvarchar(50)
)
as

declare	@DefFunctionNamePrefix varchar(50)
declare	@FunctionNameIndex int
declare @NewFunctionName varchar(200)

if	@DefQueryName is null
begin
	-- Delete query
	execute spAsQuery_Delete	@idflQuery
	set	@idflQuery = -1
	set	@idflDescription = -1
	set	@strFunctionName = null
end
else begin
	if	not exists	(
				select	*
				from	tasQuery q
				where	q.idflQuery = @idflQuery
					)
	begin
		-- Generate new IDs for query and its description
		execute	spsysGetNewID	@idflQuery output
		execute	spsysGetNewID	@idflDescription output

		-- Save local BR related to description
		insert into	locBaseReference
		(	idflBaseReference
		)
		values
		(	@idflDescription
		)

		-- Add translation for description
		if @QueryDescription is not null and len(rtrim(ltrim(@QueryDescription))) > 0
		begin
			execute spAsReferencePost @LangID, @idflDescription, @QueryDescription
		end

		-- Save local BR related to query and its English translation
		insert into	locBaseReference
		(	idflBaseReference
		)
		values
		(	@idflQuery
		)

		if @DefQueryName is not null and len(rtrim(ltrim(@DefQueryName))) > 0
		begin
			execute spAsReferencePost 'en', @idflQuery, @DefQueryName
		end

		-- Add translation for query
		if @QueryName is not null and (len(rtrim(ltrim(@QueryName))) > 0) and (@LangID <> N'en')
		begin
			execute spAsReferencePost @LangID, @idflQuery, @QueryName
		end

		-- Generate unique name of the query function
		select top 1	@DefFunctionNamePrefix = 'fn' + s.strSiteID + 'SearchQuery__' + cast(@idflQuery as varchar(30))
		from			tstSite s
		inner join		tstLocalSiteOptions lso
		on				lso.strName = N'SiteID'
						and lso.strValue = cast(s.idfsSite as nvarchar(200))
		where			s.intRowStatus = 0

		set @FunctionNameIndex = 0
		set @NewFunctionName = @DefFunctionNamePrefix

		while	exists
				(	select	*
					from	dbo.sysobjects
					where	xtype in ('IF','FN','TF')
							and category = 0
							and [name] = @NewFunctionName
				)
				or exists
					(	select	*
						from	tasQuery
						where	strFunctionName = @NewFunctionName
					)
		begin
			set @FunctionNameIndex = @FunctionNameIndex + 1
			set @NewFunctionName = @DefFunctionNamePrefix + '__' + cast(@FunctionNameIndex as varchar(100))
		end

		set	@strFunctionName = @NewFunctionName

		-- Create query
		insert into	tasQuery
		(	idflQuery,
			idfOffice,
			idfEmployee,
			strFunctionName,
			idflDescription,
			blnReadOnly,
			blnAddAllKeyFieldValues
		)
		values
		(	@idflQuery,
			@idfOffice,
			@idfEmployee,
			@strFunctionName,
			@idflDescription,
			0,
			IsNull(@blnAddAllKeyFieldValues, 0)
		)
		
	end
	else begin
		if	not exists	(
					select	*
					from	locBaseReference lbr
					where	lbr.idflBaseReference = @idflDescription
						)
		begin
			-- Generate new ID for query description
			execute	spsysGetNewID	@idflDescription output

			-- Save local BR related to description
			insert into	locBaseReference
			(	idflBaseReference
			)
			values
			(	@idflDescription
			)
		end

		-- Add or delete translation for query description
		if @QueryDescription is not null and len(rtrim(ltrim(@QueryDescription))) > 0
		begin
			execute spAsReferencePost @LangID, @idflDescription, @QueryDescription
		end
		else begin
			delete	lsnt
			from	locStringNameTranslation lsnt
			where	lsnt.idflBaseReference = @idflDescription
					and lsnt.idfsLanguage = dbo.fnGetLanguageCode(@LangID)
		end

		-- Save English translation for query
		execute spAsReferencePost 'en', @idflQuery, @DefQueryName

		-- Add or delete translation for query
		if @LangID<>'en' 
		begin
			if @QueryName is not null and len(rtrim(ltrim(@QueryName))) > 0
			begin
				execute spAsReferencePost @LangID, @idflQuery, @QueryName
			end
			else begin
				delete	lsnt
				from	locStringNameTranslation lsnt
				where	lsnt.idflBaseReference = @idflQuery
						and lsnt.idfsLanguage = dbo.fnGetLanguageCode(@LangID)
			end
		end
		-- Update query
		update	q
		set		q.idflDescription			= @idflDescription,
				q.blnAddAllKeyFieldValues	= IsNull(@blnAddAllKeyFieldValues, 0)
		from	tasQuery q
		where	q.idflQuery = @idflQuery

		-- Select query function name
		select	@strFunctionName = q.strFunctionName
		from	tasQuery q
		where	q.idflQuery = @idflQuery

	end
end


return 0
GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_FF_FlexForm_Get]...';


GO
-- ================================================================================================
-- Name: USP_ADMIN_FF_FlexForm_Get
-- Description: Gets list of the Parameters.
--          
-- Revision History:
-- Name				Date			Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albabese	01/06/2020	Initial release for new API.
-- Doug Albanese	07/02/2020	Added field blnGrid to denote the displaying of data in a table format
-- Doug Albanese	09/30/2020	Added filtering for language on the Design Option Tables
-- Doug Albanese	01/06/2021	Added idfsEditMode to clarify if the parameter is required or not.
-- Doug Albanese	02/02/2021	Found a static value for English in this procedure.
-- Doug Albanese	08/01/2021	Added idfsFormTemplate for ease of access
-- Mark Wilson		09/29/2021	Updated to remove E7 FN_FF_DesignLanguageForParameter_GET, 
--								removed unused parameters
-- Doug Albanese	03/17/2022	Added a "commented out" section to replace, when development is not happening during core hours
--	Doug Albanese	08/02/2022	Fix for IGAT #400. Extra parameters showing up that didn't belong to questionnnaire on matrix.
-- Doug Albanese	 01/0/2023	 Changed up a join to see if the displayed labeling will work better for the customer.
-- Doug Albanese	 02/06/2023	 Changed how Parameters, whith no sections, or ordered.
-- Doug Albanese	 02/28/2023	 Update for adding the Parent Section name
-- Doug Albanese	 03/01/2023	 Added the "Decore Element Text"
-- Doug Albnaese	04/13/2023	Added a "Coalesce" to make use of default data from the english side, when none exist for the selected language.
-- Doug Albanese	05/23/2023	Added a new parameter to obtain the Form Template via an observation
--  Doug Albanese	06/07/2023	Added a routine to refresh the design options, in case they are missing for a particular language being used (non-english).
-- Doug Albanese	 06/12/2023	 Removed the old routine to pick up "Decor" items fro mthe ffDecor tables. These were transposed into a new parameter object called "Statements"
/*
DECLARE    @return_value int

 

EXEC    @return_value = [dbo].[USP_ADMIN_FF_FlexForm_Get]
        @LangID = N'en-US',
        @idfsDiagnosis = 7719020000000,
        @idfsFormType = 10034010,
        @idfsFormTemplate = NULL

*/
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_FF_FlexForm_Get] (
	@LangID						NVARCHAR(50) = NULL
	,@idfsDiagnosis				BIGINT = NULL
	,@idfsFormType				BIGINT = NULL
	,@idfsFormTemplate			BIGINT = NULL
	,@idfObservation			BIGINT = NULL
	)
AS
BEGIN
	DECLARE @idfsCountry AS BIGINT,
			@idfsLanguage BIGINT = dbo.FN_GBL_LanguageCode_GET(@LangID)
	DECLARE @tmpTemplate AS TABLE (
		idfsFormTemplate BIGINT
		,IsUNITemplate BIT
		)
	DECLARE @returnCode INT = 0;
	DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';

	BEGIN TRY
		IF @idfObservation IS NOT NULL
		 BEGIN
			SELECT
			   @idfsFormTemplate = idfsFormTemplate
			FROM
			   tlbObservation
			WHERE
			   idfObservation = @idfObservation
		 END

		IF @idfsFormTemplate IS NULL
			BEGIN
				--Obtain idfsFormTemplate, via given parameters of idfsDiagnosis and idfsFormType
				---------------------------------------------------------------------------------
				SET @idfsCountry = dbo.FN_GBL_CurrentCountry_GET()

				INSERT INTO @tmpTemplate
				EXECUTE dbo.USP_ADMIN_FF_ActualTemplate_GET 
					@idfsCountry,
					@idfsDiagnosis,
					@idfsFormType

				SELECT TOP 1 @idfsFormTemplate = idfsFormTemplate
				FROM @tmpTemplate

				IF @idfsFormTemplate = - 1
					SET @idfsFormTemplate = NULL

				---------------------------------------------------------------------------------
			END

		 --On occasion, Parameters and Sections do not have any Design Options associated with them. The following SP will create them so that ordering information will be available.
		 --If ordering information is all null, or zeros...then they will be reassigned new numbers, and kept in the same order as they were before.
		 EXEC USSP_ADMIN_FF_DesignOptionsRefresh_SET @LangId= @langid, @idfsFormTemplate = @idfsFormTemplate, @User = 'System'

		SELECT 
			s.idfsParentSection
			,COALESCE(p.idfsSection,0) AS idfsSection
			,p.idfsParameter
			,PS.name AS ParentSectionName
			,RF.Name AS SectionName
			,PN.Name AS ParameterName
			,PTR.Name AS parameterType
			,p.idfsParameterType
			,pt.idfsReferenceType
			,p.idfsEditor
			,COALESCE(sdo.intOrder,2147483646) AS SectionOrder
			,COALESCE(PDO.intOrder, PDO_C.intOrder) AS ParameterOrder
			,s.blnGrid
			,s.blnFixedRowSet
			,PFT.idfsEditMode
			,pft.idfsFormTemplate
			,NULL AS DecoreElementText
		FROM dbo.ffParameter p
		LEFT JOIN dbo.ffParameterForTemplate PFT ON PFT.idfsParameter = p.idfsParameter AND PFT.intRowStatus = 0
		LEFT JOIN dbo.ffSection s ON s.idfsSection = p.idfsSection
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000101) PS ON S.idfsParentSection = PS.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000101) RF ON S.idfsSection = RF.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000071) PTR ON PTR.idfsReference = P.idfsParameterType
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000070) PN ON PN.idfsReference = P.idfsParameterCaption
		LEFT JOIN dbo.ffParameterDesignOption PDO ON PFT.idfsParameter = PDO.idfsParameter
			AND PDO.idfsFormTemplate = PFT.idfsFormTemplate
			AND PDO.idfsLanguage = @idfsLanguage
			AND PDO.intRowStatus = 0
		LEFT JOIN dbo.ffSectionDesignOption sdo ON sdo.idfsSection = s.idfsSection 
			AND sdo.idfsFormTemplate = @idfsFormTemplate 
			AND sdo.idfsLanguage = @idfsLanguage
			AND sdo.intRowStatus = 0
		LEFT JOIN dbo.ffParameterType PT
			ON pt.idfsParameterType = p.idfsParameterType
		--LEFT JOIN ffDecorElement DE
		--	ON DE.idfsFormTemplate = @idfsFormTemplate AND DE.idfsSection = s.idfsParentSection AND DE.intRowStatus = 0
	 --   LEFT JOIN ffDecorElementText DET
		--	ON DET.idfDecorElement = DE.idfDecorElement
		--LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000131) DT ON DT.idfsReference = DET.idfsBaseReference
		--------------------------------------------------------------------------------------------------------------------
		--Special join for coalescing design options that may not exist                                                   --
		--------------------------------------------------------------------------------------------------------------------
		LEFT JOIN dbo.ffParameterDesignOption PDO_C ON PFT.idfsParameter = PDO_C.idfsParameter
			AND PDO_C.idfsFormTemplate = PFT.idfsFormTemplate
			AND PDO_C.idfsLanguage = dbo.FN_GBL_LanguageCode_GET('en-us') --Default language, DO NOT REMOVE
			AND PDO_C.intRowStatus = 0
		--------------------------------------------------------------------------------------------------------------------

		WHERE PFT.idfsFormTemplate = @idfsFormTemplate
		ORDER BY  SectionOrder
			,ParameterOrder

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT = 1
			ROLLBACK;

		SET @returnCode = ERROR_NUMBER();
		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();;

		THROW;
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_GBL_ReportForm_GetList]...';


GO
-- ================================================================================================
-- Name: USP_GBL_ReportForm_GetList
--
-- Description: Get list of weekly reports that fit search criteria entered.
--          
-- Author: Manickandan Govindarajan

-- Revision History:
-- Name                     Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Manickandan Govindarajan 03/06/2022 Updated USING Locatin Hieracy Denormalized table
-- Michael Brown	        03/05/2022 Added SentByPersonName, and EnteredByPersonName to select 
--                                     statement at end of proc.
-- Mark Wilson		        04/06/2022 Updated to use new location function.
-- Stephen Long             06/09/2023 Fix to only use location hierarchy function.
--
-- Testing code:
--
/*

EXECUTE [dbo].[USP_GBL_ReportForm_GetList] 
	@LanguageID = 'en-US',
	@pageNo = 1,
	@PageSize = 10,
	@SortColumn = 'EIDSSReportID',
	@SortOrder = 'asc',
	@SiteID = 5,
	@ReportFormTypeID = NULL,
	@EIDSSReportID = NULL,
	@AdministrativeUnitTypeID = NULL, 
	@TimeIntervalTypeID = NULL,
	@StartDate = NULL,
	@EndDate = NULL,
	@AdministrativeLevelID = 3330000000,
	@OrganizationID = NULL,
	@SiteList = NULL,
	@SelectAllIndicator = 0,
	@ApplySiteFiltrationIndicator = 0
*/
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_GBL_ReportForm_GetList]
(
    @LanguageID AS NVARCHAR(50),
    @pageNo INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'EIDSSReportID',
    @SortOrder NVARCHAR(4) = 'ASC',
    @SiteID BIGINT,
    @ReportFormTypeID AS BIGINT = NULL,
    @EIDSSReportID AS NVARCHAR(400) = NULL,
    @AdministrativeUnitTypeID AS BIGINT = NULL,
    @TimeIntervalTypeID AS BIGINT = NULL,
    @StartDate AS DATETIME = NULL,
    @EndDate AS DATETIME = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @OrganizationID BIGINT = NULL,
    @SiteList VARCHAR(MAX) = NULL,
    @SelectAllIndicator BIT = 0,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplySiteFiltrationIndicator BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FiltrationSiteAdministrativeLevelID AS BIGINT,
            @LanguageCode AS BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID),
            @firstRec INT = (@pageNo - 1) * @pagesize,
            @lastRec INT = (@pageNo * @pageSize + 1);
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL
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

    BEGIN TRY
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
                ON egm.idfEmployee = @UserEmployeeID
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
              AND oa.idfActor = @UserEmployeeID;

        IF @SelectAllIndicator = 1
        BEGIN
            SET @PageSize = 100000;
            SET @PageNo = 1;
        END;

        -- ========================================================================================
        -- NO SITE FILTRATION RULES APPLIED
        --
        -- For first and second level sites, do not apply any site filtration rules.
        -- ========================================================================================
        IF @ApplySiteFiltrationIndicator = 0
        BEGIN
            INSERT INTO @Results
            SELECT ac.idfReportForm,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbReportForm ac
                INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = ac.idfsAdministrativeUnit
                       AND lh.idfsLanguage = @LanguageCode
                LEFT JOIN dbo.trtStringNameTranslation per
                    ON per.idfsBaseReference = CASE
                                                   WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091002 /* Day */
                                                   WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 6 THEN
                                                       10091004 /* Week - use datediff with day because datediff with week will return incorrect result if first day of the week in country differs from Sunday */
                                                   WHEN DATEDIFF(MONTH, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091001 /* Month */
                                                   WHEN DATEDIFF(QUARTER, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091003 /* Quarter */
                                                   WHEN DATEDIFF(YEAR, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091005 /* Year */
                                               END
                       AND per.idfsLanguage = @LanguageCode
            WHERE ac.intRowStatus = 0
                  AND (
                          ac.idfsReportFormType = @ReportFormTypeID
                          OR @ReportFormTypeID IS NULL
                      )
                  AND (
                          ac.idfSentByOffice = @OrganizationID
                          OR @OrganizationID IS NULL
                      )
                  AND (
                          (
                              lh.AdminLevel1ID = @AdministrativeLevelID
                              OR lh.AdminLevel2ID = @AdministrativeLevelID
                              OR lh.AdminLevel3ID = @AdministrativeLevelID
                              OR lh.AdminLevel4ID = @AdministrativeLevelID
                              OR lh.AdminLevel5ID = @AdministrativeLevelID
                              OR lh.AdminLevel6ID = @AdministrativeLevelID
                              OR lh.AdminLevel7ID = @AdministrativeLevelID
                          )
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          per.idfsBaseReference = @TimeIntervalTypeID
                          OR @TimeIntervalTypeID IS NULL
                      )
                  AND (
                          ac.datStartDate >= @StartDate
                          OR @StartDate IS NULL
                      )
                  AND (
                          ac.datFinishDate <= @EndDate
                          OR @EndDate IS NULL
                      )
                  AND (
                          ac.strReportFormID LIKE '%' + @EIDSSReportID + '%'
                          OR @EIDSSReportID IS NULL
                      );
        END
        ELSE
        BEGIN
            DECLARE @FilteredResults TABLE
            (
                ID BIGINT NOT NULL,
                ReadPermissionIndicator BIT NOT NULL,
                AccessToPersonalDataPermissionIndicator BIT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
                WritePermissionIndicator BIT NOT NULL,
                DeletePermissionIndicator BIT NOT NULL, INDEX IDX_ID (ID
                                                                     ));
            -- =======================================================================================
            -- DEFAULT SITE FILTRATION RULES
            --
            -- Apply non-configurable site filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0;
            DECLARE @AdministrativeLevelTypeID INT;
            DECLARE @DefaultAccessRules AS TABLE
            (
                AccessRuleID BIGINT NOT NULL,
                ReadPermissionIndicator BIT NOT NULL,
                AccessToPersonalDataPermissionIndicator BIT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
                WritePermissionIndicator BIT NOT NULL,
                DeletePermissionIndicator BIT NOT NULL,
                AdministrativeLevelTypeID INT NULL
            );

            INSERT INTO @DefaultAccessRules
            SELECT AccessRuleID,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator,
                   a.AdministrativeLevelTypeID
            FROM dbo.AccessRule a
            WHERE DefaultRuleIndicator = 1;

            --
            -- Weekly report data shall be available to all sites' organizations 
            -- connected to the particular report.
            --
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 16;

            IF @RuleActiveStatus = 0
            BEGIN
                -- Entered by and notification received by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT a.idfReportForm,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbReportForm a
                WHERE a.intRowStatus = 0
                      AND (
                              a.idfEnteredByOffice = @OrganizationID
                              OR a.idfSentByOffice = @OrganizationID
                          );
            END;

            --
            -- Weekly report data shall be available to all sites of the same 
            -- administrative level specified in the rule.
            --
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 16;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 16;

                SELECT @FiltrationSiteAdministrativeLevelID = CASE
                                                                  WHEN @AdministrativeLevelTypeID = 1 THEN
                                                                      g.Level1ID
                                                                  WHEN @AdministrativeLevelTypeID = 2 THEN
                                                                      g.Level2ID
                                                                  WHEN @AdministrativeLevelTypeID = 3 THEN
                                                                      g.Level3ID
                                                                  WHEN @AdministrativeLevelTypeID = 4 THEN
                                                                      g.Level4ID
                                                                  WHEN @AdministrativeLevelTypeID = 5 THEN
                                                                      g.Level5ID
                                                                  WHEN @AdministrativeLevelTypeID = 6 THEN
                                                                      g.Level6ID
                                                                  WHEN @AdministrativeLevelTypeID = 7 THEN
                                                                      g.Level7ID
                                                              END
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                WHERE o.intRowStatus = 0
                      AND o.idfOffice = @UserOrganizationID;

                -- Administrative level specified in the rule of the report administrative unit.
                INSERT INTO @FilteredResults
                SELECT ac.idfReportForm,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbReportForm ac
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = ac.idfsAdministrativeUnit
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 16
                WHERE ac.intRowStatus = 0
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )
                      AND ac.idfReportForm NOT IN (
                                                      SELECT ID FROM @FilteredResults
                                                  );

                -- Administrative level of the settlement of the report administrative unit.
                INSERT INTO @FilteredResults
                SELECT ac.idfReportForm,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbReportForm ac
                    INNER JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000004) settlement
                        ON settlement.idfsReference = ac.idfsAdministrativeUnit
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 16
                WHERE ac.intRowStatus = 0
                      AND (ac.idfReportForm NOT IN (
                                                       SELECT ID FROM @FilteredResults
                                                   )
                          );
            END;

            -- =======================================================================================
            -- CONFIGURABLE SITE FILTRATION RULES
            -- 
            -- Apply configurable site filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the non-configurable rules.
            -- =======================================================================================
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ag.idfReportForm,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbReportForm ag
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ag.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @SiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ag.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ag.idfReportForm,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbReportForm ag
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ag.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @SiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ag.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            INSERT INTO @FilteredResults
            SELECT ag.idfReportForm,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbReportForm ag
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @SiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ag.intRowStatus = 0
                  AND sgs.idfsSite = ag.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ag.idfReportForm,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbReportForm ag
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @SiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ag.intRowStatus = 0
                  AND a.GrantingActorSiteID = ag.idfsSite;
        END;

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
            SELECT rf.idfReportForm
            FROM dbo.tlbReportForm rf
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = rf.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE rf.intRowStatus = 0
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
        (
            ID,
            ReadPermissionIndicator,
            AccessToPersonalDataPermissionIndicator,
            AccessToGenderAndAgeDataPermissionIndicator,
            WritePermissionIndicator,
            DeletePermissionIndicator
        )
        SELECT rf.idfReportForm,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbReportForm rf
        WHERE rf.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = rf.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbReportForm rf
                ON rf.idfReportForm = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = rf.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        (
            ID,
            ReadPermissionIndicator,
            AccessToPersonalDataPermissionIndicator,
            AccessToGenderAndAgeDataPermissionIndicator,
            WritePermissionIndicator,
            DeletePermissionIndicator
        )
        SELECT rf.idfReportForm,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbReportForm rf
        WHERE rf.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = rf.idfsSite
        );

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT rf.idfReportForm
                        FROM dbo.tlbReportForm rf
                            INNER JOIN @UserSitePermissions usp
                                ON usp.SiteID = rf.idfsSite
                        WHERE usp.Permission = 4 -- Deny permission
                              AND usp.PermissionTypeID = 10059003 -- Read permission
                    );

        WITH CTEResults
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @sortColumn = 'EIDSSReportID'
                                                        AND @SortOrder = 'asc' THEN
                                                       ac.idfReportForm
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'EIDSSReportID'
                                                        AND @SortOrder = 'desc' THEN
                                                       ac.idfReportForm
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'StartDate'
                                                        AND @SortOrder = 'asc' THEN
                                                       ac.datStartDate
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'StartDate'
                                                        AND @SortOrder = 'desc' THEN
                                                       ac.datStartDate
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'EndDate'
                                                        AND @SortOrder = 'asc' THEN
                                                       ac.datFinishDate
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'EndDate'
                                                        AND @SortOrder = 'desc' THEN
                                                       ac.datFinishDate
                                               END DESC
                                     ) AS ROWNUM,
                   COUNT(*) OVER () AS TotalRowCount,
                   ac.idfReportForm AS ReportFormID,
                   ac.idfsReportFormType AS ReportFormTypeID,
                   ac.idfsAdministrativeUnit AS AdministrativeUnitID,
                   ac.idfSentByOffice AS SentByOrganizationID,
                   SentByOffice.AbbreviatedName AS SentByOrganizationName,
                   ac.idfSentByPerson AS SentByPersonID,
                   ac.idfEnteredByOffice AS EnteredByOrganizationID,
                   EnteredByOffice.AbbreviatedName AS EnteredByOrganizationName,
                   ac.idfEnteredByPerson AS EnteredByPersonID,
                   dbo.FN_GBL_ConcatFullName(
                                                EnteredByPerson.strFamilyName,
                                                EnteredByPerson.strFirstName,
                                                EnteredByPerson.strSecondName
                                            ) AS SentByPersonName,
                   EnteredByPerson.strFamilyName + ', ' + EnteredByPerson.strFirstName AS EnteredByPersonName,
                   dbo.FN_GBL_FormatDate(ac.datSentByDate, 'mm/dd/yyyy') AS SentByDate,
                   ac.datSentByDate AS DisplaySentByDate,
                   dbo.FN_GBL_FormatDate(ac.datEnteredByDate, 'mm/dd/yyyy') AS EnteredByDate,
                   ac.datEnteredByDate AS DisplayEnteredByDate,
                   dbo.FN_GBL_FormatDate(ac.datStartDate, 'mm/dd/yyyy') AS StartDate,
                   ac.datStartDate AS DisplayStartDate,
                   dbo.FN_GBL_FormatDate(ac.datFinishDate, 'mm/dd/yyyy') AS FinishDate,
                   ac.datFinishDate AS DisplayFinishDate,
                   ac.strReportFormID AS EIDSSReportID,
                   lh.LevelType AS AdministrativeUnitTypeName,
                   ac.idfsDiagnosis,
                   br.strDefault AS diseaseDefaultName,
                   ISNULL(diagnosis.strTextString, br.strDefault) AS diseaseName,
                   diagnosis.strTextString AS Diagnosis,
                   ac.Total,
                   ac.Notified,
                   ac.Comments,
                   lh.Level1ID AS AdminLevel0,
                   lh.Level1Name AS AdminLevel0Name,
                   lh.Level2ID AS AdminLevel1,
                   lh.Level2Name AS AdminLevel1Name,
                   lh.Level3ID AS AdminLevel2,
                   lh.Level3Name AS AdminLevel2Name,
                   lh.Level4ID AS idfsSettlement,
                   lh.Level4Name AS SettlementName,
                   per.idfsBaseReference AS PeriodTypeID,
                   per.strTextString AS PeriodTypeName,
                   '0' AS RowSelectionIndicator
            FROM dbo.tlbReportForm ac
                LEFT JOIN dbo.FN_GBL_Institution_Min(@LanguageID) EnteredByOffice
                    ON ac.idfEnteredByOffice = EnteredByOffice.idfOffice
                LEFT JOIN dbo.tlbPerson EnteredByPerson
                    ON ac.idfEnteredByPerson = EnteredByPerson.idfPerson
                LEFT JOIN dbo.FN_GBL_Institution_Min(@LanguageID) SentByOffice
                    ON ac.idfSentByOffice = SentByOffice.idfOffice
                INNER JOIN dbo.gisLocationDenormalized lh
                    ON lh.idfsLocation = ac.idfsAdministrativeUnit
                       AND lh.idfsLanguage = @LanguageCode
                LEFT JOIN dbo.trtStringNameTranslation per
                    ON per.idfsBaseReference = CASE
                                                   WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091002 /* Day */
                                                   WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 6 THEN
                                                       10091004 /* Week - use datediff with day because datediff with week will return incorrect result if first day of the week in country differs from Sunday */
                                                   WHEN DATEDIFF(MONTH, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091001 /* Month */
                                                   WHEN DATEDIFF(QUARTER, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091003 /* Quarter */
                                                   WHEN DATEDIFF(YEAR, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091005 /* Year */
                                               END
                       AND per.idfsLanguage = @LanguageCode
                JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = ac.idfsDiagnosis
                LEFT JOIN dbo.trtStringNameTranslation diagnosis
                    ON diagnosis.idfsBaseReference = ac.idfsDiagnosis
                       AND diagnosis.idfsLanguage = @LanguageCode
            WHERE ac.intRowStatus = 0
                  AND (
                          ac.idfsReportFormType = @ReportFormTypeID
                          OR @ReportFormTypeID IS NULL
                      )
                  AND (
                          ac.idfSentByOffice = @OrganizationID
                          OR @OrganizationID IS NULL
                      )
                  AND (
                          per.idfsBaseReference = @TimeIntervalTypeID
                          OR @TimeIntervalTypeID IS NULL
                      )
                  AND (
                          ac.datStartDate >= @StartDate
                          OR @StartDate IS NULL
                      )
                  AND (
                          ac.datFinishDate <= @EndDate
                          OR @EndDate IS NULL
                      )
                  AND (
                          (
                              lh.Level1ID = @AdministrativeLevelID
                              OR lh.Level2ID = @AdministrativeLevelID
                              OR lh.Level3ID = @AdministrativeLevelID
                              OR lh.Level4ID = @AdministrativeLevelID
                              OR lh.Level5ID = @AdministrativeLevelID
                              OR lh.Level6ID = @AdministrativeLevelID
                              OR lh.Level7ID = @AdministrativeLevelID
                          )
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          ac.strReportFormID LIKE '%' + @EIDSSReportID + '%'
                          OR @EIDSSReportID IS NULL
                      )
           )
        SELECT TotalRowCount,
               ReportFormId,
               ReportFormTypeID,
               AdministrativeUnitID,
               SentByOrganizationID,
               SentByOrganizationName,
               SentByPersonID,
               SentByPersonName,
               EnteredByOrganizationID,
               EnteredByOrganizationName,
               EnteredByPersonID,
               EnteredByPersonName,
               SentByDate,
               DisplaySentByDate,
               EnteredByDate,
               DisplayEnteredByDate,
               StartDate,
               DisplayStartDate,
               FinishDate,
               DisplayFinishDate,
               EIDSSReportID,
               NULL AS AdministrativeUnitTypeID,
               AdministrativeUnitTypeName,
               idfsDiagnosis,
               diseaseDefaultName,
               diseaseName,
               Diagnosis Total,
               Notified,
               Comments,
               AdminLevel0,
               AdminLevel0Name,
               AdminLevel1,
               AdminLevel1Name,
               AdminLevel2,
               AdminLevel2Name,
               idfsSettlement,
               SettlementName,
               TotalPages = (TotalRowCount / @pageSize) + IIF(TotalRowCount % @pageSize > 0, 1, 0),
               CurrentPage = @pageNo
        FROM CTEResults
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
GO
PRINT N'Altering Procedure [dbo].[USP_VAS_MONITORING_SESSION_GETDetail]...';


GO
-- ================================================================================================
-- Name: USP_VAS_MONITORING_SESSION_GETDetail
--
-- Description:	Get active surveillance monitoring session detail (one record) for the veterinary 
-- surveillance session edit/enter and other use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     05/02/2019 Initial release.
-- Stephen Long     04/27/2020 Corrected legacy session ID.
-- Stephen Long     08/22/2020 Corrected joins for person entered by site.
-- Mike Kornegay    12/16/2021 Added tlbMonitoringSessionToDiagnosis to all joins involving idfsDiagnosis and changed
--                             location hieararchy to use FN_GBL_LocationHierarchy_Flattened 
-- Mike Kornegay	01/19/2022 Added join to tlbVetCase and added idfCaseType
-- Mike Kornegay	01/26/2022 Added the disease identifiers and names fields to the query and added
--							   the strCampaign field as CampaignID and idfCampaign as CampaignKey.
-- Mike Kornegay	02/01/2022 Removed join to tlbVetCase and added join to MonitoringSessionToSampletypes to
--							   get if the report is Avian or Livestock
-- Mike Kornegay    02/15/2022 Changed SpeciesTypeID to ReportTypeID
-- Mike Kornegay	03/08/2022 Added LocationID
-- Mike Kornegay	06/13/2022 Changed ReportTypeID and ReportTypeName to point to the new SessionCategoryID - this
--							   field now stores the report type of the vet surveillance session so we do not depend 
--							   on the diagnosis list to determine type.
-- Mike Kornegay	10/20/2022 Changed ReportTypeID to point to the new idfsMonitoringSessionSpeciesType.
-- Srini Goli		11/13/2022 Updated Region, Rayon and Settlement Names
-- Stephen Long     06/07/2023 Fix for 4597 and 4598.
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_VAS_MONITORING_SESSION_GETDetail]
(
    @LanguageID NVARCHAR(50),
    @MonitoringSessionID BIGINT,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplyFiltrationIndicator BIT = 0
)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        DECLARE @SiteID BIGINT = (
                                     SELECT idfsSite
                                     FROM dbo.tlbMonitoringSession
                                     WHERE idfMonitoringSession = @MonitoringSessionID
                                 );
        DECLARE @Results TABLE
        (
            ID BIGINT NOT NULL,
            ReadPermissionIndicator INT NOT NULL,
            AccessToPersonalDataPermissionIndicator INT NOT NULL,
            AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
            WritePermissionIndicator INT NOT NULL,
            DeletePermissionIndicator INT NOT NULL
        );
        DECLARE @FinalResults TABLE
        (
            ID BIGINT NOT NULL,
            ReadPermissionIndicator INT NOT NULL,
            AccessToPersonalDataPermissionIndicator INT NOT NULL,
            AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
            WritePermissionIndicator INT NOT NULL,
            DeletePermissionIndicator INT NOT NULL
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

        IF @UserSiteID = @SiteID
           OR @ApplyFiltrationIndicator = 0
        BEGIN
            INSERT INTO @Results
            SELECT @MonitoringSessionID,
                   1,
                   1,
                   1,
                   1,
                   1;
        END
        ELSE
        BEGIN
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
                    ON egm.idfEmployee = @UserEmployeeID
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
                  AND oa.idfActor = @UserEmployeeID;

            DECLARE @FilteredResults TABLE
            (
                ID BIGINT NOT NULL,
                ReadPermissionIndicator BIT NOT NULL,
                AccessToPersonalDataPermissionIndicator BIT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
                WritePermissionIndicator BIT NOT NULL,
                DeletePermissionIndicator BIT NOT NULL, INDEX IDX_ID (ID
                                                                     ));

            -- =======================================================================================
            -- DEFAULT CONFIGURABLE FILTRATION RULES
            --
            -- Apply non-configurable filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0,
                    @AdministrativeLevelTypeID INT,
                    @FiltrationSiteAdministrativeLevelID AS BIGINT,
                    @LanguageCode AS BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID);            
            DECLARE @DefaultAccessRules AS TABLE
            (
                AccessRuleID BIGINT NOT NULL,
                ActiveIndicator INT NOT NULL,
                ReadPermissionIndicator BIT NOT NULL,
                AccessToPersonalDataPermissionIndicator BIT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
                WritePermissionIndicator BIT NOT NULL,
                DeletePermissionIndicator BIT NOT NULL,
                AdministrativeLevelTypeID INT NULL
            );

            INSERT INTO @DefaultAccessRules
            SELECT AccessRuleID,
                   a.intRowStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator,
                   a.AdministrativeLevelTypeID
            FROM dbo.AccessRule a
            WHERE DefaultRuleIndicator = 1;

            --
            -- Session data shall be available to all sites of the same administrative level.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537015;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537015;

                SELECT @FiltrationSiteAdministrativeLevelID = CASE
                                                                  WHEN @AdministrativeLevelTypeID = 1 THEN
                                                                      g.Level1ID
                                                                  WHEN @AdministrativeLevelTypeID = 2 THEN
                                                                      g.Level2ID
                                                                  WHEN @AdministrativeLevelTypeID = 3 THEN
                                                                      g.Level3ID
                                                                  WHEN @AdministrativeLevelTypeID = 4 THEN
                                                                      g.Level4ID
                                                                  WHEN @AdministrativeLevelTypeID = 5 THEN
                                                                      g.Level5ID
                                                                  WHEN @AdministrativeLevelTypeID = 6 THEN
                                                                      g.Level6ID
                                                                  WHEN @AdministrativeLevelTypeID = 7 THEN
                                                                      g.Level7ID
                                                              END
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                WHERE o.intRowStatus = 0
                      AND o.idfOffice = @UserOrganizationID;

                -- Administrative level specified in the rule of the site where the session was created.
                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tstSite s
                        ON ms.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537015
                WHERE ms.idfMonitoringSession = @MonitoringSessionID
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          );

                -- Administrative level specified in the rule of the farm address.
                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tlbFarm f
                        ON f.idfMonitoringSession = ms.idfMonitoringSession
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = f.idfFarmAddress
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537015
                WHERE ms.idfMonitoringSession = @MonitoringSessionID
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          );
            END;

            --
            -- Session data is always distributed across the sites where the disease reports are 
            -- linked to the session.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537016;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tlbVetCase v
                        ON v.idfParentMonitoringSession = ms.idfMonitoringSession
                           AND v.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537016
                WHERE ms.idfMonitoringSession = @MonitoringSessionID
                      AND v.idfsSite = @UserSiteID;
            END;

            --
            -- Session data shall be available to all sites' organizations connected to the particular 
            -- session where samples were transferred out.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537017;

            IF @RuleActiveStatus = 0
            BEGIN
                -- Samples transferred collected by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tlbMaterial m
                        ON ms.idfMonitoringSession = m.idfMonitoringSession
                           AND m.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial toutm
                        ON m.idfMaterial = toutm.idfMaterial
                           AND toutm.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT tout
                        ON toutm.idfTransferOut = tout.idfTransferOut
                           AND tout.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537017
                WHERE ms.idfMonitoringSession = @MonitoringSessionID
                      AND tout.idfSendToOffice = @UserOrganizationID;

                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tlbMaterial m
                        ON ms.idfMonitoringSession = m.idfMonitoringSession
                           AND m.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial toutm
                        ON m.idfMaterial = toutm.idfMaterial
                           AND toutm.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537017
                WHERE ms.idfMonitoringSession = @MonitoringSessionID
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          );
            END;

            -- =======================================================================================
            -- CONFIGURABLE FILTRATION RULES
            -- 
            -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the default rules.
            -- =======================================================================================
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ms.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.idfMonitoringSession = @MonitoringSessionID
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ms.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.idfMonitoringSession = @MonitoringSessionID
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ms.idfsSite
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.idfMonitoringSession = @MonitoringSessionID
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ms.idfsSite
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.idfMonitoringSession = @MonitoringSessionID
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.idfMonitoringSession = @MonitoringSessionID
                  AND sgs.idfsSite = ms.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.idfMonitoringSession = @MonitoringSessionID
                  AND a.GrantingActorSiteID = ms.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.idfMonitoringSession = @MonitoringSessionID
                  AND a.GrantingActorSiteID = ms.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.idfMonitoringSession = @MonitoringSessionID
                  AND a.GrantingActorSiteID = ms.idfsSite;

            -- Copy filtered results to results and use search criteria
            INSERT INTO @Results
            SELECT ID,
                   ReadPermissionIndicator,
                   AccessToPersonalDataPermissionIndicator,
                   AccessToGenderAndAgeDataPermissionIndicator,
                   WritePermissionIndicator,
                   DeletePermissionIndicator
            FROM @FilteredResults
            GROUP BY ID,
                     ReadPermissionIndicator,
                     AccessToPersonalDataPermissionIndicator,
                     AccessToGenderAndAgeDataPermissionIndicator,
                     WritePermissionIndicator,
                     DeletePermissionIndicator;
        END

        -- =======================================================================================
        -- DISEASE FILTRATION RULES
        --
        -- Apply disease filtration rules from use case SAUC62.
        -- =======================================================================================
        -- 
        -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without filtration rules applied.
        --
        DELETE FROM @Results
        WHERE ID IN (
                        SELECT ms.idfMonitoringSession
                        FROM dbo.tlbMonitoringSession ms
                            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = msd.idfsDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE ms.idfMonitoringSession = @MonitoringSessionID
                              AND oa.intPermission = 1 -- Deny permission
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND oa.idfActor = -506 -- Default role
                    );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT ms.idfMonitoringSession,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbMonitoringSession ms
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = msd.idfsDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND ms.idfMonitoringSession = @MonitoringSessionID
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup
        GROUP BY ms.idfMonitoringSession;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = res.ID
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = msd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1 -- Deny permission
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT ms.idfMonitoringSession,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbMonitoringSession ms
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = msd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND ms.idfMonitoringSession = @MonitoringSessionID
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID
        GROUP BY ms.idfMonitoringSession;

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT ms.idfMonitoringSession
                        FROM dbo.tlbMonitoringSession ms
                            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = msd.idfsDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE ms.intRowStatus = 0
                              AND oa.intPermission = 1 -- Deny permission
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND oa.idfActor = @UserEmployeeID
                    );

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without filtration rules applied.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT ms.idfMonitoringSession
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = ms.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE ms.idfMonitoringSession = @MonitoringSessionID
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
        SELECT ms.idfMonitoringSession,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbMonitoringSession ms
        WHERE ms.idfMonitoringSession = @MonitoringSessionID
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = ms.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = ms.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT ms.idfMonitoringSession,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbMonitoringSession ms
        WHERE ms.idfMonitoringSession = @MonitoringSessionID
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = ms.idfsSite
        );

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT ms.idfMonitoringSession
                        FROM dbo.tlbMonitoringSession ms
                            INNER JOIN @UserSitePermissions usp
                                ON usp.SiteID = ms.idfsSite
                        WHERE usp.Permission = 4 -- Deny permission
                              AND usp.PermissionTypeID = 10059003 -- Read permission
                    );

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        INSERT INTO @FinalResults
        SELECT ID,
               MAX(res.ReadPermissionIndicator),
               MAX(res.AccessToPersonalDataPermissionIndicator),
               MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
               MAX(res.WritePermissionIndicator),
               MAX(res.DeletePermissionIndicator)
        FROM @Results res
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
        GROUP BY ID

        SELECT ms.idfMonitoringSession AS VeterinaryMonitoringSessionID,
               ms.strMonitoringSessionID AS EIDSSSessionID,
               ms.idfsMonitoringSessionStatus AS SessionStatusTypeID,
               MonitoringSessionStatus.name AS SessionStatusTypeName,
               ms.idfsMonitoringSessionSpeciesType AS ReportTypeID,
               ISNULL(reportType.name, reportType.strDefault) as ReportTypeName,
               ms.datEnteredDate AS EnteredDate,
               ms.datStartDate AS StartDate,
               ms.datEndDate AS EndDate,
               diseaseIDs.diseaseIDs AS DiseaseIdentifiers,
               diseaseNames.diseaseNames AS DiseaseNames,
               ms.idfsCountry AS CountryID,
               ms.idfsRegion AS RegionID,
               LH.AdminLevel2Name AS RegionName,
               ms.idfsRayon AS RayonID,
               LH.AdminLevel3Name AS RayonName,
               ms.idfsSettlement AS SettlementID,
               LH.AdminLevel4Name AS SettlementName,
               LH.idfsLocation AS LocationID,
               ms.idfPersonEnteredBy AS EnteredByPersonID,
               ISNULL(p.strFamilyName, N'') + ISNULL(', ' + p.strFirstName, '') + ISNULL(' ' + p.strSecondName, '') AS EnteredByPersonName,
               ms.idfsSite AS SiteID,
               siteName.strSiteName AS SiteName,
               ms.LegacySessionID AS LegacyID,
               c.idfCampaign AS CampaignKey,
               c.strCampaignID AS CampaignID,
               c.strCampaignName AS CampaignName,
               c.idfsCampaignType AS CampaignTypeID,
               campaignType.name AS CampaignTypeName,
                                  CASE
                       WHEN res.ReadPermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.ReadPermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.ReadPermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.ReadPermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.ReadPermissionIndicator)
                   END AS ReadPermissionindicator,
                   CASE
                       WHEN res.AccessToPersonalDataPermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToPersonalDataPermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.AccessToPersonalDataPermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToPersonalDataPermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.AccessToPersonalDataPermissionIndicator)
                   END AS AccessToPersonalDataPermissionIndicator,
                   CASE
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.AccessToGenderAndAgeDataPermissionIndicator)
                   END AS AccessToGenderAndAgeDataPermissionIndicator,
                   CASE
                       WHEN res.WritePermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.WritePermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.WritePermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.WritePermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.WritePermissionIndicator)
                   END AS WritePermissionIndicator,
                   CASE
                       WHEN res.DeletePermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.DeletePermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.DeletePermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.DeletePermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.DeletePermissionIndicator)
                   END AS DeletePermissionIndicator
        FROM @FinalResults res
            INNER JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = res.ID
            INNER JOIN dbo.tstSite SiteName
                ON siteName.idfsSite = ms.idfsSite
                   AND siteName.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
            LEFT JOIN dbo.tlbCampaign c
                ON c.idfCampaign = ms.idfCampaign
                   AND c.intRowStatus = 0
            LEFT JOIN dbo.MonitoringSessionToSampleType mss
                ON ms.idfMonitoringSession = mss.idfMonitoringSession
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000116) campaignType
                ON c.idfsCampaignType = campaignType.idfsReference
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000117) monitoringSessionStatus
                ON monitoringSessionStatus.idfsReference = ms.idfsMonitoringSessionStatus
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000538) reportType
                ON reportType.idfsReference = ms.SessionCategoryID
            LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                ON LH.idfsLocation = ms.idfsLocation
            LEFT JOIN dbo.tlbPerson p
                ON p.idfPerson = ms.idfPersonEnteredBy
                   AND p.intRowStatus = 0
            LEFT JOIN dbo.tstUserTable u
                ON u.idfPerson = ms.idfPersonEnteredBy
                   AND u.intRowStatus = 0
            CROSS APPLY
        (
            SELECT dbo.FN_GBL_SESSION_DISEASEIDS_GET(ms.idfMonitoringSession) diseaseIDs
        ) diseaseIDs
            CROSS APPLY
        (
            SELECT dbo.FN_GBL_SESSION_DISEASE_NAMES_GET(ms.idfMonitoringSession, @LanguageID) diseaseNames
        ) diseaseNames;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_VAS_MONITORING_SESSION_GETList]...';


GO
-- ================================================================================================
-- Name: USP_VAS_MONITORING_SESSION_GETList
--
-- Description: Gets a list of veterinary active surveillance sessions for the veterinary module 
-- based on search criteria provided.
--
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Mandar Kulkarni            Initial release.
-- Stephen Long    06/06/2018 Added campaign ID parameter and additional where clause check.
-- Stephen Long    11/18/2018 Renamed with correct module name, and updated parameter names and 
--                            result name field names.
-- Stephen Long    12/31/2018 Added pagination logic.
-- Stephen Long    05/01/2019 Removed additional field parameters to sync with use case, and 
--                            added campaign and monitoring session ID parameters.
-- Stephen Long    06/25/2019 Corrected session category type.
-- Stephen Long    07/06/2019 Added EIDSSCampaignID to the select.
-- Stephen Long    08/28/2019 Corrected date entered from and to when null dates are passed in on 
--                            one of the dates and the other has data.
-- Stephen Long    09/13/2019 Added settlement ID parameter and where clause.
-- Stephen Long    12/18/2019 Added legacy session ID parameter and where clause.
-- Stephen Long    01/22/2020 Added site list parameter for site filtration.
-- Stephen Long    02/02/2020 Added non-configurable filtration rules.
-- Stephen Long    02/20/2020 Added additional non-configurable rules.
-- Stephen Long    03/25/2020 Added if/else for first-level and second-level site types to bypass 
--                            non-configurable rules.
-- Stephen Long    04/17/2020 Changed join from FN_GBL_INSTITUTION to tstSite as not all sites have 
--                            organizations.
-- Stephen Long    05/18/2020 Added disease filtration rules from use case SAUC62.
-- Stephen Long    06/22/2020 Added where criteria to the query when no site filtration is 
--                            required.
-- Stephen Long    07/07/2020 Added trim to EIDSS identifier like criteria.
-- Stephen Long    09/23/2020 Added descending to the order by clause.
-- Stephen Long    11/18/2020 Renamed organization ID and name to site ID and name.
-- Stephen Long    11/25/2020 Added configurable site filtration rules.
-- Stephen Long    12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long    12/24/2020 Modified join on disease filtration default role rule.
-- Stephen Long    12/29/2020 Changed function call on reference data for inactive records.
-- Stephen Long    01/28/2021 Added order by clause to handle user selected sorting across 
--                            pagination sets.
-- Stephen Long    04/02/2021 Added updated pagination and location hierarchy.
-- Mike Kornegay   12/16/2021 Added tlbMonitoringSessionToDiagnosis to all joins involving 
--                            idfsDiagnosis and changed
--                            location hieararchy to use FN_GBL_LocationHierarchy_Flattened
-- Stephen Long    01/26/2022 Added the disease identifiers and names fields to the query.
-- Mike Kornegay   01/31/2022 Removed the left join on tlbMonitoringSessionToDiagnosis because it 
--                            was replaced
--							  by the new disease functions.
-- Mike Kornegay   03/10/2022 Added SessionStatusTypeID and ReportTypeID to return fields.
-- Mike Kornegay   03/20/2022 Corrected date comparisons to use binary compare instead of between.
-- Mike Kornegay   03/25/2022 Further changes to date comparisons to prevent sql overflow.
-- Stephen Long    03/29/2022 Fix to site filtration to pull back a user's own site records.
-- Mike Kornegay   05/16/2022 Correct returned location levels to be country, region, rayon, 
--                            settlement
-- Mike Kornegay   05/19/2022 Correct location search to use node descendants instead of particular 
--                            idfsLocation
-- Stephen Long    06/03/2022 Updated to point default access rules to base reference.
-- Mike Kornegay   06/13/2022 Changed ReportTypeID and ReportTypeName to point to the new SessionCategoryID - this
--							   field now stores the report type of the vet surveillance session so we do not depend 
--							   on the diagnosis list to determine type.
-- Mike Kornegay   07/27/2022 Changed CTE for paging and sorting.
-- Stephen Long    08/13/2022 Added session category type ID parameter and where criteria.
-- Stephen Long    09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Mike Kornegay   09/24/2022 Testing stored proc change.
-- Stephen Long    01/09/2023 Updated for site filtration queries.
-- Stephen Long    06/07/2023 Fix to use location de-normalized table.
--
-- Testing Code:
--EXEC	@return_value = [dbo].[USP_VAS_MONITORING_SESSION_GETList]
--		@LanguageID = N'en-US',
--		@SessionID = NULL,
--		@LegacySessionID = NULL,
--		@CampaignID = NULL,
--		@CampaignKey = NULL,
--		@SessionStatusTypeID = NULL,
--		@DateEnteredFrom = NULL,
--		@DateEnteredTo = NULL,
--		@AdministrativeLevelID = 349690000000,
--		@DiseaseID = NULL,
--		@UserSiteID = 1100,
--		@UserOrganizationID = 709150000000,
--		@UserEmployeeID = 155568340001298,
--		@ApplySiteFiltrationIndicator = 0,
--		@SortColumn = N'SessionID',
--		@SortOrder = N'desc',
--		@PageNumber = 1,
--		@PageSize = 10
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_VAS_MONITORING_SESSION_GETList]
(
    @LanguageID NVARCHAR(50),
    @SessionID NVARCHAR(200) = NULL,
    @LegacySessionID NVARCHAR(50) = NULL,
    @CampaignID NVARCHAR(200) = NULL,
    @CampaignKey BIGINT = NULL,
    @SessionStatusTypeID BIGINT = NULL,
    @DateEnteredFrom DATETIME = NULL,
    @DateEnteredTo DATETIME = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @DiseaseID BIGINT = NULL,
    @SessionCategoryTypeID BIGINT = NULL,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplySiteFiltrationIndicator BIT = 0,
    @SortColumn NVARCHAR(30) = 'SessionID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @PageNumber INT = 1,
    @PageSize INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FirstRec INT = (@PageNumber - 1) * @PageSize, 
            @LastRec INT = (@PageNumber * @PageSize + 1),
            @FiltrationSiteAdministrativeLevelID AS BIGINT,
            @LanguageCode AS BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID);
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL INDEX IDX_1 CLUSTERED,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
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

    BEGIN TRY
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
                ON egm.idfEmployee = @UserEmployeeID
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
              AND oa.idfActor = @UserEmployeeID;

        IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
        END

        -- ========================================================================================
        -- NO CONFIGURABLE FILTRATION RULES APPLIED
        --
        -- For first and second level sites, do not apply any configurable filtration rules.
        -- ========================================================================================
        IF @ApplySiteFiltrationIndicator = 0
        BEGIN
            INSERT INTO @Results
            SELECT ms.idfMonitoringSession,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbMonitoringSession ms
                LEFT JOIN dbo.tlbCampaign c
                    ON c.idfCampaign = ms.idfCampaign
                       AND c.intRowStatus = 0
                LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                    ON msd.idfMonitoringSession = ms.idfMonitoringSession
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = ms.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
            WHERE ms.intRowStatus = 0
                  AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
                  AND (
                          ms.idfCampaign = @CampaignKey
                          OR @CampaignKey IS NULL
                      )
                  AND (
                          ms.idfsMonitoringSessionStatus = @SessionStatusTypeID
                          OR @SessionStatusTypeID IS NULL
                      )
                  AND (
                          msd.idfsDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          (CAST(ms.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          g.Level1ID = @AdministrativeLevelID
                          OR g.Level2ID = @AdministrativeLevelID
                          OR g.Level3ID = @AdministrativeLevelID
                          OR g.Level4ID = @AdministrativeLevelID
                          OR g.Level5ID = @AdministrativeLevelID
                          OR g.Level6ID = @AdministrativeLevelID
                          OR g.Level7ID = @AdministrativeLevelID
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
                          OR @SessionID IS NULL
                      )
                  AND (
                          c.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'
                          OR @CampaignID IS NULL
                      )
                  AND (
                          LegacySessionID LIKE '%' + TRIM(@LegacySessionID) + '%'
                          OR @LegacySessionID IS NULL
                      )
                  AND (
                          ms.SessionCategoryID = @SessionCategoryTypeID
                          OR @SessionCategoryTypeID IS NULL
                      )
            GROUP BY ms.idfMonitoringSession;
        END
        ELSE
        BEGIN
            INSERT INTO @Results
            SELECT ms.idfMonitoringSession,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbMonitoringSession ms
                LEFT JOIN dbo.tlbCampaign c
                    ON c.idfCampaign = ms.idfCampaign
                       AND c.intRowStatus = 0
                LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                    ON msd.idfMonitoringSession = ms.idfMonitoringSession
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = ms.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
            WHERE ms.intRowStatus = 0
                  AND ms.idfsSite = @UserSiteID
                  AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session
                  AND (
                          ms.idfCampaign = @CampaignKey
                          OR @CampaignKey IS NULL
                      )
                  AND (
                          ms.idfsMonitoringSessionStatus = @SessionStatusTypeID
                          OR @SessionStatusTypeID IS NULL
                      )
                  AND (
                          msd.idfsDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          (CAST(ms.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          g.Level1ID = @AdministrativeLevelID
                          OR g.Level2ID = @AdministrativeLevelID
                          OR g.Level3ID = @AdministrativeLevelID
                          OR g.Level4ID = @AdministrativeLevelID
                          OR g.Level5ID = @AdministrativeLevelID
                          OR g.Level6ID = @AdministrativeLevelID
                          OR g.Level7ID = @AdministrativeLevelID
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
                          OR @SessionID IS NULL
                      )
                  AND (
                          c.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'
                          OR @CampaignID IS NULL
                      )
                  AND (
                          LegacySessionID LIKE '%' + TRIM(@LegacySessionID) + '%'
                          OR @LegacySessionID IS NULL
                      )
                  AND (
                          ms.SessionCategoryID = @SessionCategoryTypeID
                          OR @SessionCategoryTypeID IS NULL
                      )
            GROUP BY ms.idfMonitoringSession;

            DECLARE @FilteredResults TABLE
            (
                ID BIGINT NOT NULL,
                ReadPermissionIndicator BIT NOT NULL,
                AccessToPersonalDataPermissionIndicator BIT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
                WritePermissionIndicator BIT NOT NULL,
                DeletePermissionIndicator BIT NOT NULL, INDEX IDX_ID (ID
                                                                     ));

            -- =======================================================================================
            -- DEFAULT CONFIGURABLE FILTRATION RULES
            --
            -- Apply non-configurable filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0;
            DECLARE @AdministrativeLevelTypeID INT;
            DECLARE @DefaultAccessRules AS TABLE
            (
                AccessRuleID BIGINT NOT NULL,
                ActiveIndicator INT NOT NULL,
                ReadPermissionIndicator BIT NOT NULL,
                AccessToPersonalDataPermissionIndicator BIT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
                WritePermissionIndicator BIT NOT NULL,
                DeletePermissionIndicator BIT NOT NULL,
                AdministrativeLevelTypeID INT NULL
            );

            INSERT INTO @DefaultAccessRules
            SELECT AccessRuleID,
                   a.intRowStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator,
                   a.AdministrativeLevelTypeID
            FROM dbo.AccessRule a
            WHERE DefaultRuleIndicator = 1;

            --
            -- Session data shall be available to all sites of the same administrative level.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537015;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537015;

                SELECT @FiltrationSiteAdministrativeLevelID = CASE
                                                                  WHEN @AdministrativeLevelTypeID = 1 THEN
                                                                      g.Level1ID
                                                                  WHEN @AdministrativeLevelTypeID = 2 THEN
                                                                      g.Level2ID
                                                                  WHEN @AdministrativeLevelTypeID = 3 THEN
                                                                      g.Level3ID
                                                                  WHEN @AdministrativeLevelTypeID = 4 THEN
                                                                      g.Level4ID
                                                                  WHEN @AdministrativeLevelTypeID = 5 THEN
                                                                      g.Level5ID
                                                                  WHEN @AdministrativeLevelTypeID = 6 THEN
                                                                      g.Level6ID
                                                                  WHEN @AdministrativeLevelTypeID = 7 THEN
                                                                      g.Level7ID
                                                              END
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                WHERE o.intRowStatus = 0
                      AND o.idfOffice = @UserOrganizationID;

                -- Administrative level specified in the rule of the site where the session was created.
                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tstSite s
                        ON ms.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537015
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          );

                -- Administrative level specified in the rule of the farm address.
                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tlbFarm f
                        ON f.idfMonitoringSession = ms.idfMonitoringSession
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = f.idfFarmAddress
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537015
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          );
            END;

            --
            -- Session data is always distributed across the sites where the disease reports are 
            -- linked to the session.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537016;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tlbVetCase v
                        ON v.idfParentMonitoringSession = ms.idfMonitoringSession
                           AND v.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537016
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
                      AND v.idfsSite = @UserSiteID;
            END;

            --
            -- Session data shall be available to all sites' organizations connected to the particular 
            -- session where samples were transferred out.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537017;

            IF @RuleActiveStatus = 0
            BEGIN
                -- Samples transferred collected by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tlbMaterial m
                        ON ms.idfMonitoringSession = m.idfMonitoringSession
                           AND m.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial toutm
                        ON m.idfMaterial = toutm.idfMaterial
                           AND toutm.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT tout
                        ON toutm.idfTransferOut = tout.idfTransferOut
                           AND tout.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537017
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
                      AND tout.idfSendToOffice = @UserOrganizationID;

                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tlbMaterial m
                        ON ms.idfMonitoringSession = m.idfMonitoringSession
                           AND m.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial toutm
                        ON m.idfMaterial = toutm.idfMaterial
                           AND toutm.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537017
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          );
            END;

            -- =======================================================================================
            -- CONFIGURABLE FILTRATION RULES
            -- 
            -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the default rules.
            -- =======================================================================================
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ms.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ms.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ms.idfsSite
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ms.idfsSite
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.intRowStatus = 0
                  AND sgs.idfsSite = ms.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.intRowStatus = 0
                  AND a.GrantingActorSiteID = ms.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.intRowStatus = 0
                  AND a.GrantingActorSiteID = ms.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.intRowStatus = 0
                  AND a.GrantingActorSiteID = ms.idfsSite;

            -- Copy filtered results to results and use search criteria
            INSERT INTO @Results
            SELECT ID,
                   ReadPermissionIndicator,
                   AccessToPersonalDataPermissionIndicator,
                   AccessToGenderAndAgeDataPermissionIndicator,
                   WritePermissionIndicator,
                   DeletePermissionIndicator
            FROM @FilteredResults
                INNER JOIN dbo.tlbMonitoringSession ms
                    ON ms.idfMonitoringSession = ID
                LEFT JOIN dbo.tlbCampaign c
                    ON c.idfCampaign = ms.idfCampaign
                       AND c.intRowStatus = 0
                LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                    ON msd.idfMonitoringSession = ms.idfMonitoringSession
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = ms.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
            WHERE ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
                  AND (
                          ms.idfCampaign = @CampaignKey
                          OR @CampaignKey IS NULL
                      )
                  AND (
                          ms.idfsMonitoringSessionStatus = @SessionStatusTypeID
                          OR @SessionStatusTypeID IS NULL
                      )
                  AND (
                          msd.idfsDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          g.Level1ID = @AdministrativeLevelID
                          OR g.Level2ID = @AdministrativeLevelID
                          OR g.Level3ID = @AdministrativeLevelID
                          OR g.Level4ID = @AdministrativeLevelID
                          OR g.Level5ID = @AdministrativeLevelID
                          OR g.Level6ID = @AdministrativeLevelID
                          OR g.Level7ID = @AdministrativeLevelID
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          (CAST(ms.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
                          OR @SessionID IS NULL
                      )
                  AND (
                          c.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'
                          OR @CampaignID IS NULL
                      )
                  AND (
                          LegacySessionID LIKE '%' + TRIM(@LegacySessionID) + '%'
                          OR @LegacySessionID IS NULL
                      )
                  AND (
                          ms.SessionCategoryID = @SessionCategoryTypeID
                          OR @SessionCategoryTypeID IS NULL
                      )
            GROUP BY ID,
                     ReadPermissionIndicator,
                     AccessToPersonalDataPermissionIndicator,
                     AccessToGenderAndAgeDataPermissionIndicator,
                     WritePermissionIndicator,
                     DeletePermissionIndicator;
        END;

        -- =======================================================================================
        -- DISEASE FILTRATION RULES
        --
        -- Apply disease filtration rules from use case SAUC62.
        -- =======================================================================================
        -- 
        -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without filtration rules applied.
        --
        DELETE FROM @Results
        WHERE ID IN (
                        SELECT ms.idfMonitoringSession
                        FROM dbo.tlbMonitoringSession ms
                            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = msd.idfsDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE ms.intRowStatus = 0
                              AND oa.intPermission = 1 -- Deny permission
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND oa.idfActor = -506 -- Default role
                    );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT ms.idfMonitoringSession,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbMonitoringSession ms
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = msd.idfsDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND ms.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup
        GROUP BY ms.idfMonitoringSession;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = res.ID
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = msd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1 -- Deny permission
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT ms.idfMonitoringSession,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbMonitoringSession ms
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = msd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND ms.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID
        GROUP BY ms.idfMonitoringSession;

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT ms.idfMonitoringSession
                        FROM dbo.tlbMonitoringSession ms
                            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = msd.idfsDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE ms.intRowStatus = 0
                              AND oa.intPermission = 1 -- Deny permission
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND oa.idfActor = @UserEmployeeID
                    );

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without filtration rules applied.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT ms.idfMonitoringSession
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = ms.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE ms.intRowStatus = 0
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
        SELECT ms.idfMonitoringSession,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbMonitoringSession ms
        WHERE ms.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = ms.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = ms.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT ms.idfMonitoringSession,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbMonitoringSession ms
        WHERE ms.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = ms.idfsSite
        );

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT ms.idfMonitoringSession
                        FROM dbo.tlbMonitoringSession ms
                            INNER JOIN @UserSitePermissions usp
                                ON usp.SiteID = ms.idfsSite
                        WHERE usp.Permission = 4 -- Deny permission
                              AND usp.PermissionTypeID = 10059003 -- Read permission
                    );

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        INSERT INTO @FinalResults
        SELECT ID,
               MAX(res.ReadPermissionIndicator),
               MAX(res.AccessToPersonalDataPermissionIndicator),
               MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
               MAX(res.WritePermissionIndicator),
               MAX(res.DeletePermissionIndicator)
        FROM @Results res
            INNER JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = res.ID
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
            LEFT JOIN dbo.tlbCampaign c
                ON c.idfCampaign = ms.idfCampaign
                   AND c.intRowStatus = 0
            LEFT JOIN dbo.gisLocationDenormalized g
                ON g.idfsLocation = ms.idfsLocation
                   AND g.idfsLanguage = @LanguageCode
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
              AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
              AND (
                      ms.idfCampaign = @CampaignKey
                      OR @CampaignKey IS NULL
                  )
              AND (
                      ms.idfsMonitoringSessionStatus = @SessionStatusTypeID
                      OR @SessionStatusTypeID IS NULL
                  )
              AND (
                      msd.idfsDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      g.Level1ID = @AdministrativeLevelID
                      OR g.Level2ID = @AdministrativeLevelID
                      OR g.Level3ID = @AdministrativeLevelID
                      OR g.Level4ID = @AdministrativeLevelID
                      OR g.Level5ID = @AdministrativeLevelID
                      OR g.Level6ID = @AdministrativeLevelID
                      OR g.Level7ID = @AdministrativeLevelID
                      OR @AdministrativeLevelID IS NULL
                  )
              AND (
                      (CAST(ms.datEnteredDate AS DATE)
              BETWEEN @DateEnteredFrom AND @DateEnteredTo
                      )
                      OR (
                             @DateEnteredFrom IS NULL
                             OR @DateEnteredTo IS NULL
                         )
                  )
              AND (
                      ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
                      OR @SessionID IS NULL
                  )
              AND (
                      c.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'
                      OR @CampaignID IS NULL
                  )
              AND (
                      LegacySessionID LIKE '%' + TRIM(@LegacySessionID) + '%'
                      OR @LegacySessionID IS NULL
                  )
              AND (
                      ms.SessionCategoryID = @SessionCategoryTypeID
                      OR @SessionCategoryTypeID IS NULL
                  )
        GROUP BY ID;

        WITH paging
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'SessionID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ms.strMonitoringSessionID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'SessionID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ms.strMonitoringSessionID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'SessionStatusTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       sessionStatus.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'SessionStatusTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       sessionStatus.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'EnteredDate'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ms.datEnteredDate
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EnteredDate'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ms.datEnteredDate
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel1Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.Level2Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel1Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.Level2Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel2Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.Level3Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel2Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.Level3Name
                                               END DESC
                                     ) AS ROWNUM,
                   COUNT(*) OVER () AS RecordCount,
                   res.ID AS SessionKey,
                   ms.strMonitoringSessionID AS SessionID,
                   ms.idfCampaign AS CampaignKey,
                   c.strCampaignID AS CampaignID,
                   sessionStatus.idfsReference AS SessionStatusTypeID,
                   ms.SessionCategoryID AS ReportTypeID,
                   ISNULL(reportType.name, reportType.strDefault) AS ReportTypeName,
                   sessionStatus.name AS SessionStatusTypeName,
                   ms.datStartDate AS StartDate,
                   ms.datEndDate AS EndDate,
                   diseaseIDs.diseaseIDs AS DiseaseIdentifiers,
                   diseaseNames.diseaseNames AS DiseaseNames,
                   '' AS DiseaseName,
                   lh.Level1Name AS AdministrativeLevel0Name,
                   lh.Level2Name AS AdministrativeLevel1Name,
                   lh.Level3Name AS AdministrativeLevel2Name,
                   lh.Level4Name AS SettlementName,
                   ms.datEnteredDate AS EnteredDate,
                   ISNULL(p.strFirstName, '') + ' ' + ISNULL(p.strFamilyName, '') AS EnteredByPersonName,
                   ms.idfsSite AS SiteKey,
                   s.strSiteName AS SiteName,
                   CASE
                       WHEN res.ReadPermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.ReadPermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.ReadPermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.ReadPermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.ReadPermissionIndicator)
                   END AS ReadPermissionindicator,
                   CASE
                       WHEN res.AccessToPersonalDataPermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToPersonalDataPermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.AccessToPersonalDataPermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToPersonalDataPermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.AccessToPersonalDataPermissionIndicator)
                   END AS AccessToPersonalDataPermissionIndicator,
                   CASE
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.AccessToGenderAndAgeDataPermissionIndicator)
                   END AS AccessToGenderAndAgeDataPermissionIndicator,
                   CASE
                       WHEN res.WritePermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.WritePermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.WritePermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.WritePermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.WritePermissionIndicator)
                   END AS WritePermissionIndicator,
                   CASE
                       WHEN res.DeletePermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.DeletePermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.DeletePermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.DeletePermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.DeletePermissionIndicator)
                   END AS DeletePermissionIndicator,
                   (
                       SELECT COUNT(*)
                       FROM dbo.tlbMonitoringSession
                       WHERE intRowStatus = 0
                             AND SessionCategoryID = 10502002 -- Veterinary Avian Active Surveillance Session
                             OR SessionCategoryID = 10502009 -- Veterinary Livestock Active Surveillance Session
                   ) AS TotalCount
            FROM @FinalResults res
                INNER JOIN dbo.tlbMonitoringSession ms
                    ON ms.idfMonitoringSession = res.ID
                LEFT JOIN dbo.MonitoringSessionToSampleType mss
                    ON ms.idfMonitoringSession = mss.idfMonitoringSession
                CROSS APPLY
            (
                SELECT dbo.FN_GBL_SESSION_DISEASEIDS_GET(ms.idfMonitoringSession) diseaseIDs
            ) diseaseIDs
                CROSS APPLY
            (
                SELECT dbo.FN_GBL_SESSION_DISEASE_NAMES_GET(ms.idfMonitoringSession, @LanguageID) diseaseNames
            ) diseaseNames
                LEFT JOIN dbo.tstSite s
                    ON s.idfsSite = ms.idfsSite
                LEFT JOIN dbo.tlbCampaign c
                    ON c.idfCampaign = ms.idfCampaign
                       AND c.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000117) sessionStatus
                    ON sessionStatus.idfsReference = ms.idfsMonitoringSessionStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000502) reportType
                    ON reportType.idfsReference = ms.SessionCategoryID
                INNER JOIN dbo.gisLocationDenormalized lh
                    ON lh.idfsLocation = ms.idfsLocation
                       AND lh.idfsLanguage = @LanguageCode
                LEFT JOIN dbo.tlbPerson p
                    ON p.idfPerson = ms.idfPersonEnteredBy
            WHERE ms.intRowStatus = 0
           )
        SELECT SessionKey,
               SessionID,
               CampaignKey,
               CampaignID,
               SessionStatusTypeID,
               ReportTypeID,
               ReportTypeName,
               SessionStatusTypeName,
               StartDate,
               EndDate,
               DiseaseIdentifiers,
               DiseaseNames,
               DiseaseName,
               AdministrativeLevel0Name,
               AdministrativeLevel1Name,
               AdministrativeLevel2Name,
               SettlementName,
               EnteredDate,
               EnteredByPersonName,
               SiteKey,
               SiteName,
               ReadPermissionIndicator,
               AccessToPersonalDataPermissionIndicator,
               AccessToGenderAndAgeDataPermissionIndicator,
               WritePermissionIndicator,
               DeletePermissionIndicator,
               RecordCount,
               TotalCount,
               CurrentPage = @PageNumber,
               TotalPages = (RecordCount / @PageSize) + IIF(RecordCount % @PageSize > 0, 1, 0)
        FROM paging
        WHERE RowNum > @FirstRec
              AND RowNum < @LastRec;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
GO

