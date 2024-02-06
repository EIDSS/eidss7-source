
GO
PRINT N'Altering Function [dbo].[fnGetLanguageCode]...';


GO

-- select * from fnGetLanguageCode('en','rftCountry')

ALTER          function [dbo].[fnGetLanguageCode](@LangID  nvarchar(50))
returns bigint
as
BEGIN
DECLARE @LanguageCode bigint
SET @LanguageCode = CASE @LangID WHEN N'az-L'	THEN 10049001
		WHEN N'ru'			THEN 10049006
		WHEN N'ka'			THEN 10049004
		WHEN N'kk'			THEN 10049005
		WHEN N'uz-C'		THEN 10049007
		WHEN N'uz-L'		THEN 10049008
		WHEN N'uk'			THEN 10049009
		WHEN N'CISID-AZ'	THEN 10049002
		WHEN N'hy'			THEN 10049010
		WHEN N'ar-IQ'		THEN 10049015
		WHEN N'ar'			THEN 10049011
		WHEN N'vi'			THEN 10049012
		WHEN N'lo'			THEN 10049013
		WHEN N'th'			THEN 10049014
		ELSE 10049003 END
return @LanguageCode
END
GO

GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_FF_TemplateDesign_GET]...';


GO
-- ================================================================================================
-- Name: USP_ADMIN_FF_TemplateDesign_GET
-- Description: Returns list of Sections/Parameters
--          
--	Revision History:
--	Name            Date		Change
--	--------------- ----------	--------------------------------------------------------------------
--	Doug Albanese	02/26/2020	Initial release for new API.
--	Doug Albanese	04/06/2020	Addition of automatic intOrder assignment for NULL or zero values
--	Doug Albanese	04/07/2020	return column name change to seperate section from parameters for intOrder
--	Doug Albanese	04/27/2020	Clean up for new templates created where nulls are only the response
--	Doug Albanese	05/11/2020	Correct for duplicate rows being returned
--	Doug Albanese	10/28/2020	Corrected the result to handle missing section data.
--	Doug Albanese	01/06/2021	Added idfsEditMode to handle the status of a parameter's required validation
--	Doug Albanese	01/21/2021	Correction to force the ordering of sections and parameters for a flex form, plus used the new translation function
--	Doug Albanese	01/22/2021	Design Option join didn't include the base reference language id.
--	Doug Albanese	05/21/2021	Refactored to produce "Sectionless" parameters
--	Doug Albanese	05/25/2021	Corrected an intRowStatus problem for parameters getting picked up, when they were deleted.
--	Doug Albanese	07/04/2021  Correction to force template design to come through for the Flex Form Designer
--	Doug Albanese	07/06/2021	Added Observations to the output to determine if a template is locked for specific funtionality
--	Doug Albanese	07/08/2021	Removed idfsSection and idfsParameter from ordering
--	Doug Albanese	10/28/2021	Removed the old concept of reordering parameters/sections, when they have 0 for intOrder
--	Doug Albanese	03/15/2022	Added a USSP to resolve any design option problems. Also added auditing information for the user requesting this call
--	Doug Albanese	03/16/2022	Changed out USSP_ADMIN_FF_DesignOptionsRefresh with USSP_ADMIN_FF_DesignOptionsRefresh_SET
--	Doug Albanese	05/09/2022	Cleaning up duplicates
--	Doug Albanese	05/23/2022	Missing Section Options requires a LEFT JOIN to continue without error
--	Doug Albanese	06/07/2022	Filtered output to only display items that have parameters. Nulls were showing up previously
--  Doug Albanese	03/03/2023	Added Editor Type to the return
--  Doug Albanese	04/04/2023	Refactored to correctly pick up objects pertaining to a specific template.
--  Doug Albanese	04/10/2023	Section data doesn't always exists, so a LEFT Join used on section related tables.
--	Doug Albanese	04/14/2023	Changed size of "Name" fields from 200 to 2000
--  Doug Albanese   04/18/2023	Swapped out fnGetLanguageCode for dbo.FN_GBL_LanguageCode_GET(@LangID);	
--  Doug Albanese	06/07/2023	Added 'System' for the auto refresh of any design options that may be missing
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_FF_TemplateDesign_GET] (
	@langid				NVARCHAR(50),
	@idfsFormTemplate	BIGINT = NULL,
	@User				NVARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE		@langid_int				BIGINT
				,@returnCode			BIGINT
				,@returnMsg				NVARCHAR(MAX)

	BEGIN TRY
		BEGIN TRANSACTION

		SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangID);	

		--On occasion, Parameters and Sections do not have any Design Options associated with them. The following SP will create them so that ordering information will be available.
		--If ordering information is all null, or zeros...then they will be reassigned new numbers, and kept in the same order as they were before.
		EXEC USSP_ADMIN_FF_DesignOptionsRefresh_SET @LangId= @langid, @idfsFormTemplate = @idfsFormTemplate, @User = 'System'

		DECLARE @TemplateDesign TABLE (
			idfsSection					BIGINT,
			idfsParentSection			BIGINT,
			idfsParameter				BIGINT,
			idfsEditor					BIGINT,
			idfsParameterType			BIGINT,
			idfsParameterCaption		BIGINT,
			intSectionOrder				INT,
			intParameterOrder			INT,
			ParameterName				NVARCHAR(2000),
			SectionName					NVARCHAR(2000),
			idfsEditMode				BIGINT,
			Observations				INT
		)
		
		DECLARE @iObservations		INT

		SELECT
			@iObservations = COUNT(idfObservation)
		FROM
			tlbObservation O
		INNER JOIN ffFormTemplate FT
			ON FT.idfsFormTemplate = O.idfsFormTemplate
			AND FT.intRowStatus = 0
		WHERE
			O.idfsFormTemplate = @idfsFormTemplate

		INSERT INTO @TemplateDesign (idfsSection,idfsParentSection,idfsParameter,idfsEditor,idfsParameterType,idfsParameterCaption,intSectionOrder,intParameterOrder,ParameterName,SectionName,idfsEditMode,Observations)
		 SELECT 
			   COALESCE(s.idfsSection, -1) AS idfsSection
			   ,s.idfsParentSection
			   ,p.idfsParameter
			   ,p.idfsEditor
			   ,p.idfsParameterType
			   ,p.idfsParameterCaption
			   ,sdo.intOrder AS intSectionOrder
			   ,pdo.intOrder AS intParameterOrder
			   ,pn.name AS ParameterName
			   ,sn.name AS SectionName
			   ,pft.idfsEditMode
			   ,@iObservations AS Observations
		 FROM
			   ffFormTemplate ft
		 INNER JOIN ffParameterForTemplate pft ON pft.idfsFormTemplate = ft.idfsFormTemplate and pft.intRowStatus = 0
		 INNER JOIN ffParameter p ON p.idfsParameter = pft.idfsParameter and p.intRowStatus = 0
		 INNER JOIN ffSection s ON s.idfsSection = p.idfsSection and s.intRowStatus = 0
		 LEFT JOIN ffSectionForTemplate sft ON sft.idfsSection = s.idfsSection and sft.idfsFormTemplate = @idfsFormTemplate and sft.intRowStatus = 0
		 INNER JOIN ffParameterDesignOption pdo ON pdo.idfsParameter = p.idfsParameter and pdo.idfsFormTemplate = @idfsFormTemplate and pdo.idfsLanguage = @langid_int and pdo.intRowStatus = 0
		 LEFT JOIN ffSectionDesignOption sdo ON sdo.idfsSection = s.idfsSection and sdo.idfsFormTemplate = @idfsFormTemplate and sdo.idfsLanguage = @langid_int and sdo.intRowStatus = 0
		 INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000066) pn
						   ON pn.idfsReference = p.idfsParameter
		 INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000101) sn
						   ON sn.idfsReference = s.idfsSection
		 WHERE 
			   ft.idfsFormTemplate = @idfsFormTemplate 

		 INSERT INTO @TemplateDesign (idfsSection,idfsParentSection,idfsParameter,idfsEditor,idfsParameterType,idfsParameterCaption,intSectionOrder,intParameterOrder,ParameterName,SectionName,idfsEditMode, Observations)
		 SELECT 
			   -1 AS idfsSection --????
			   ,NULL As idfsParentSection
			   ,p.idfsParameter
			   ,p.idfsEditor
			   ,p.idfsParameterType
			   ,p.idfsParameterCaption
			   ,0 AS intSectionOrder
			   ,pdo.intOrder AS intParameterOrder
			   ,pn.name AS ParameterName
			   ,'' AS SectionName
			   ,pft.idfsEditMode
			   ,@iObservations
		 FROM
			   ffFormTemplate ft
		 INNER JOIN ffParameterForTemplate pft 
			   ON pft.idfsFormTemplate = ft.idfsFormTemplate and pft.intRowStatus = 0
		 INNER JOIN ffParameter p ON p.idfsParameter = pft.idfsParameter and p.intRowStatus = 0
		 INNER JOIN ffParameterDesignOption pdo ON pdo.idfsParameter = p.idfsParameter and pdo.idfsFormTemplate = @idfsFormTemplate and pdo.idfsLanguage = @langid_int and pdo.intRowStatus = 0
		 INNER JOIN dbo.FN_GBL_ReferenceRepair(@langid, 19000066) pn
						   ON pn.idfsReference = p.idfsParameter
		 WHERE 
			   ft.idfsFormTemplate = @idfsFormTemplate and 
			   p.idfsSection IS NULL
		
		SELECT
			idfsParentSection,
			idfsSection,
			SectionName,
			intSectionOrder,
			idfsParameter,
			ParameterName,
			intParameterOrder,
			idfsEditor,
			idfsParameterType,
			idfsParameterCaption,
			idfsEditMode,
			Observations
		FROM
			@TemplateDesign
		WHERE
			idfsParameter IS NOT NULL
		ORDER BY
			intSectionOrder,
			intParameterOrder

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_GBL_BASE_REFERENCE_GETList]...';


GO
--*************************************************************************************************
-- Name: USP_GBL_BASE_REFERENCE_GETList
--
-- Description: List filered values from tlbBaseReference table.
--          
-- Revision History:
-- Name							Date		Change Detail
-- ---------------				----------	--------------------------------------------------------------------
-- Stephen Long					06/29/2019	Initial release.
-- Manickandan Govindarajan		11/24/2020	The IF query is getting the intHACode from basereference table but the
--											IntHACode is 0 for multiple records ex: 19000040 refrencetype
--											Updated the code to get intHACode from trtHACodeList table. It will help to filter in the app
--
-- Mark Wilson					12/16/2020  Updated to accept null HACode (when HACode is unnecessary)
-- Steven Verner				10/21/2022	Removed duplicate base reference types where there currently is an editor for those types
--											Like Age Group, Case Classification,etc.
--											This change fixes bugs 3865,4757,4756,4755,4750...
-- Doug Albanese				9/15/2023	Adding "Editor Settings" to the result of data.

--
-- @intHACode Code List
-- 0	None
-- 2	Human
-- 4	Exophyte
-- 8	Plant
-- 16	Soil
-- 32	Livestock
-- 64	Avian
-- 128	Vector
-- 256	Syndromic
-- 510	All	
--
-- Testing code:
/*
	Exec USP_GBL_BASE_REFERENCE_GETList 'EN', 'Nationality List', 0
	Exec USP_GBL_BASE_REFERENCE_GETList 'EN', 'Case Status', 64
	Exec USP_GBL_BASE_REFERENCE_GETList 'EN', 'Diagnosis', 2
	EXEC USP_GBL_BASE_REFERENCE_GETList 'en','Personal ID Type', 0
	EXEC USP_GBL_BASE_REFERENCE_GETList 'en','Patient Location Type', 2
	EXEC USP_GBL_BASE_REFERENCE_GETList 'en','Organization Type', 482
	EXEC USP_GBL_BASE_REFERENCE_GETList 'en','Human Age Type', 2

*/
-- ************************************************************************************************
ALTER PROCEDURE [dbo].[USP_GBL_BASE_REFERENCE_GETList] 
(
	@LangID	NVARCHAR(50),
	@ReferenceTypeName VARCHAR(400) = NULL,
	@intHACode	BIGINT = NULL 
)
AS
	DECLARE @HACodeMax BIGINT = 510;
	DECLARE @ReturnMsg VARCHAR(MAX) = 'Success';
	DECLARE @ReturnCode BIGINT = 0;
	DECLARE @HAList TABLE(
		intHACode INT

	)

	DECLARE @trtBaseReference TABLE (
	    idfsBaseReference	  BIGINT,
		idfsReferenceType	  BIGINT,
		strBaseReferenceCode  NVARCHAR(200),
		strDefault			  NVARCHAR(200),
		[name]				  NVARCHAR(200),
		intHACode			  INT,
		intOrder			  INT,
		intRowStatus		  INT,
		blnSystem			  BIT,
		intDefaultHACode	  BIGINT,
		strHACode			  NVARCHAR(200),
		EditorSettings		  BIGINT
	)

	IF @intHACode IS NOT NULL
	INSERT INTO @HAList
	(
	    intHACode
	)
	SELECT intHACode FROM dbo.FN_GBL_SplitHACode(@intHACode, @HACodeMax)

	BEGIN TRY
		INSERT INTO @trtBaseReference
		SELECT 
			br.idfsBaseReference,
			br.idfsReferenceType,
			br.strBaseReferenceCode,
			strDefault = CASE WHEN @ReferenceTypeName = 'Disease' THEN
				(SELECT TOP 1 ISNULL(sg.strTextString, brg.strDefault)FROM trtDiagnosisToDiagnosisGroup dg
				INNER Join dbo.trtBaseReference brg ON dg.idfsDiagnosisGroup = brg.idfsBaseReference
				LEFT JOIN dbo.trtStringNameTranslation AS sg ON brg.idfsBaseReference = sg.idfsBaseReference AND sg.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LangID)
				WHERE dg.idfsDiagnosis = br.idfsBaseReference AND brg.strDefault IS NOT NULL)
			ELSE br.strDefault END,
			ISNULL(s.strTextString, br.strDefault) AS [name],
			br.intHACode,
			br.intOrder,
			br.intRowStatus,
			br.blnSystem,
			rt.intDefaultHACode,
			CASE WHEN ISNULL(@intHACode,0) = 0 THEN NULL ELSE dbo.FN_GBL_SPLITHACODEASSTRING(br.intHACode, 510) END AS strHACode,
			EditorSettings
		FROM dbo.trtBaseReference br
		INNER JOIN dbo.trtReferenceType AS rt ON rt.idfsReferenceType = br.idfsReferenceType
		LEFT JOIN dbo.trtStringNameTranslation AS s ON br.idfsBaseReference = s.idfsBaseReference AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LangID)
		LEFT JOIN dbo.trtHACodeList HA ON HA.intHACode = br.intHACode
		LEFT JOIN dbo.trtBaseReference HAR ON HAR.idfsBaseReference = HA.idfsCodeName
		
		WHERE 
			br.idfsBaseReference NOT IN (19000146,19000011,19000019,19000537,19000529,19000530,19000531,19000532,19000533,19000534,19000535,19000125,19000123,19000122,
												 19000143,19000050,19000126,19000121,19000075,19000124,19000012,19000164,19000019,19000503,19000530,19000510,19000506,19000505,
												 19000509,19000511,19000508,19000507,19000022,19000131,19000070,19000066,19000071,19000069,19000029,19000032,19000101,19000525,
												 19000033,19000532,19000534,19000533,19000152,19000056,19000060,19000109,19000062,19000045,19000046,19000516,19000074,19000147,
												 19000130,19000535,19000531,19000087,19000079,19000529,19000119,19000524,19000084,19000519,19000166,19000086,19000090,19000141,
												 19000140)
			AND	
			br.intRowStatus = 0	
			AND
		((EXISTS 
				(SELECT intHACode FROM dbo.FN_GBL_SplitHACode(@intHACode, @HACodeMax) 
				INTERSECT 
				SELECT intHACode FROM dbo.FN_GBL_SplitHACode(br.intHACode, @HACodeMax)) 
				OR @intHACode IS NULL OR @intHACode = 0 OR br.intHACode = @intHACode))
		AND rt.strReferenceTypeName = IIF(@ReferenceTypeName IS NOT NULL, @ReferenceTypeName, rt.strReferenceTypeName )
		
		ORDER BY 
			br.intOrder,
			[name]

		 UPDATE @trtBaseReference
		 SET EditorSettings = RT.EditorSettings
		 FROM trtReferenceType RT
		 WHERE RT.idfsReferenceType = idfsBaseReference

		 SELECT
			idfsBaseReference,
			idfsReferenceType,
			strBaseReferenceCode,
			strDefault,
			[name],
			intHACode,
			intOrder,
			intRowStatus,
			blnSystem,
			intDefaultHACode,
			strHACode,
			EditorSettings
		 FROM
			@trtBaseReference
	END TRY  

	BEGIN CATCH 

		THROW;

	END CATCH;
GO
PRINT N'Altering Procedure [dbo].[USP_HAS_MONITORING_SESSION_DEL]...';


GO
-- ================================================================================================
-- Name: USP_HAS_MONITORING_SESSION_DEL
--
-- Description:	Sets an active surveillance monitoring session record to "inactive" for the human 
-- module.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     07/06/2019 Initial release.
-- Mark Wilson		08/18/2021 added all children tables and removed LanguageID
-- Stephen Long     06/06/2023 Added check for child dependent objects.
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_HAS_MONITORING_SESSION_DEL] (@MonitoringSessionID BIGINT)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ReturnMessage VARCHAR(MAX) = 'Success',
                @ReturnCode BIGINT = 0,
                @SampleCount AS INT = 0,
                @LabTestCount AS INT = 0,
                @TestInterpretationCount AS INT = 0,
                @DiseaseReportCount AS INT = 0,
                @AggregateCount AS INT = 0;

        BEGIN TRANSACTION;

        DECLARE @tlbMonitoringSessionSummary TABLE (idfMonitorintSessionSummary BIGINT)

        SELECT @AggregateCount = COUNT(*)
        FROM dbo.tlbMonitoringSessionSummary mss
        WHERE mss.idfMonitoringSession = @MonitoringSessionID
              AND mss.intRowStatus = 0;

        SELECT @DiseaseReportCount = COUNT(*)
        FROM dbo.tlbHumanCase h
        WHERE h.idfParentMonitoringSession = @MonitoringSessionID
              AND h.intRowStatus = 0;

        SELECT @TestInterpretationCount = COUNT(*)
        FROM dbo.tlbTestValidation tv
            INNER JOIN dbo.tlbTesting t
                ON t.idfTesting = tv.idfTesting
                   AND t.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
        WHERE m.idfMonitoringSession = @MonitoringSessionID
              AND tv.intRowStatus = 0;

        SELECT @LabTestCount = COUNT(*)
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
        WHERE m.idfMonitoringSession = @MonitoringSessionID
              AND t.intRowStatus = 0;

        SELECT @SampleCount = COUNT(*)
        FROM dbo.tlbMaterial
        WHERE idfMonitoringSession = @MonitoringSessionID
              AND intRowStatus = 0;

        IF @SampleCount = 0
           AND @LabTestCount = 0
           AND @TestInterpretationCount = 0
           AND @AggregateCount = 0
           AND @DiseaseReportCount = 0
        BEGIN
            INSERT into @tlbMonitoringSessionSummary
            SELECT idfMonitoringSessionSummary
            FROM dbo.tlbMonitoringSessionSummary
            WHERE idfMonitoringSession = @MonitoringSessionID

            UPDATE dbo.tlbMonitoringSession
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSession = @MonitoringSessionID;

            UPDATE dbo.tlbMonitoringSessionToDiagnosis
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSession = @MonitoringSessionID

            UPDATE dbo.tlbMonitoringSessionAction
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSession = @MonitoringSessionID

            UPDATE dbo.tlbMonitoringSessionSummary
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSession = @MonitoringSessionID

            UPDATE dbo.tlbMonitoringSessionSummaryDiagnosis
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSessionSummary IN (
                                                     SELECT * FROM @tlbMonitoringSessionSummary
                                                 )

            UPDATE dbo.tlbMonitoringSessionSummarySample
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSessionSummary IN (
                                                     SELECT * FROM @tlbMonitoringSessionSummary
                                                 )

            UPDATE dbo.tlbMonitoringSessionToMaterial
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSession = @MonitoringSessionID
        END
        ELSE
        BEGIN
            SET @ReturnCode = 1;
            SET @ReturnMessage = 'Unable to delete this record as it contains dependent child objects.';
        END;

        IF @@TRANCOUNT > 0
            COMMIT;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;
    END TRY
    BEGIN CATCH
        IF @@Trancount > 0
            ROLLBACK TRANSACTION;

        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;

        THROW;
    END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_HAS_MONITORING_SESSION_GETDetail]...';


GO
-- ================================================================================================
-- Name: USP_HAS_MONITORING_SESSION_GETDetail
--
-- Description:	Get active surveillance monitoring session detail (one record) for the human 
-- surveillance session edit/enter and other use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     07/06/2019 Initial release.
-- Mark Wilson		08/18/2021 joined tlbMonitoringSessionToDiagnosis to get disease
-- Mark Wilson	    08/18/2021 updated location info
-- Doug Albanese	12/01/2021 Refactoring to have correct alias for location data
-- Doug Albanese	12/03/2021 Integrated the new FN_GBL_LocationHierarchy_Flattened for use with 
--                             the Location Hierarchy
-- Doug Albanese	12/04/2021 Cleaned up the original location hierarchy implmentation with the 
--                             new table to provide one row of location details per idfsLocation
-- Doug Albanese	02/10/2022 Correction of Site Name
-- Doug Albanese	03/28/2022 Added the string value for Campaign ID
-- Doug Albanese	06/30/2022 Corrected the last field from strCampaignName to strCampaignID
-- Stephen Long     05/23/2023 Fix for 4597 and 4598.
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_HAS_MONITORING_SESSION_GETDetail]
(
    @LanguageID NVARCHAR(50),
    @MonitoringSessionID BIGINT,
    @ApplyFiltrationIndicator BIT = 1,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT
)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        DECLARE @FiltrationSiteAdministrativeLevelID AS BIGINT,
                @LanguageCode AS BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID),
                @SiteID BIGINT = (
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

        IF @UserSiteID = @SiteID OR @ApplyFiltrationIndicator = 0
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
            DECLARE @RuleActiveStatus INT = 0;
            DECLARE @AdministrativeLevelTypeID INT;
            DECLARE @OrganizationAdministrativeLevelNode HIERARCHYID;
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
            (
                AccessRuleID,
                ActiveIndicator,
                ReadPermissionIndicator,
                AccessToPersonalDataPermissionIndicator,
                AccessToGenderAndAgeDataPermissionIndicator,
                WritePermissionIndicator,
                DeletePermissionIndicator,
                AdministrativeLevelTypeID
            )
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
            WHERE AccessRuleID = 10537006;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537006;

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
                (
                    ID,
                    ReadPermissionIndicator,
                    AccessToPersonalDataPermissionIndicator,
                    AccessToGenderAndAgeDataPermissionIndicator,
                    WritePermissionIndicator,
                    DeletePermissionIndicator
                )
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
                        ON a.AccessRuleID = 10537006
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

                -- Administrative level specified in the rule of the patient's current residence address
                INSERT INTO @FilteredResults
                (
                    ID,
                    ReadPermissionIndicator,
                    AccessToPersonalDataPermissionIndicator,
                    AccessToGenderAndAgeDataPermissionIndicator,
                    WritePermissionIndicator,
                    DeletePermissionIndicator
                )
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tlbHuman h
                        ON h.idfMonitoringSession = ms.idfMonitoringSession
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = h.idfCurrentResidenceAddress
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537006
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
            WHERE AccessRuleID = 10537007;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                (
                    ID,
                    ReadPermissionIndicator,
                    AccessToPersonalDataPermissionIndicator,
                    AccessToGenderAndAgeDataPermissionIndicator,
                    WritePermissionIndicator,
                    DeletePermissionIndicator
                )
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tlbHumanCase hc
                        ON hc.idfParentMonitoringSession = ms.idfMonitoringSession
                           AND hc.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537007
                WHERE ms.idfMonitoringSession = @MonitoringSessionID
                      AND hc.idfsSite = @UserSiteID;
            END;

            --
            -- Session data shall be available to all sites' organizations connected to the particular 
            -- session where samples were transferred out.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537008;

            IF @RuleActiveStatus = 0
            BEGIN
                -- Samples transferred collected by and sent to organizations
                INSERT INTO @FilteredResults
                (
                    ID,
                    ReadPermissionIndicator,
                    AccessToPersonalDataPermissionIndicator,
                    AccessToGenderAndAgeDataPermissionIndicator,
                    WritePermissionIndicator,
                    DeletePermissionIndicator
                )
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
                        ON a.AccessRuleID = 10537008
                WHERE ms.idfMonitoringSession = @MonitoringSessionID
                      AND tout.idfSendToOffice = @UserOrganizationID;

                INSERT INTO @FilteredResults
                (
                    ID,
                    ReadPermissionIndicator,
                    AccessToPersonalDataPermissionIndicator,
                    AccessToGenderAndAgeDataPermissionIndicator,
                    WritePermissionIndicator,
                    DeletePermissionIndicator
                )
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
                        ON a.AccessRuleID = 10537008
                WHERE ms.idfMonitoringSession = @MonitoringSessionID
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          );
            END

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
            (
                ID,
                ReadPermissionIndicator,
                AccessToPersonalDataPermissionIndicator,
                AccessToGenderAndAgeDataPermissionIndicator,
                WritePermissionIndicator,
                DeletePermissionIndicator
            )
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
            (
                ID,
                ReadPermissionIndicator,
                AccessToPersonalDataPermissionIndicator,
                AccessToGenderAndAgeDataPermissionIndicator,
                WritePermissionIndicator,
                DeletePermissionIndicator
            )
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
            (
                ID,
                ReadPermissionIndicator,
                AccessToPersonalDataPermissionIndicator,
                AccessToGenderAndAgeDataPermissionIndicator,
                WritePermissionIndicator,
                DeletePermissionIndicator
            )
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
            (
                ID,
                ReadPermissionIndicator,
                AccessToPersonalDataPermissionIndicator,
                AccessToGenderAndAgeDataPermissionIndicator,
                WritePermissionIndicator,
                DeletePermissionIndicator
            )
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
            (
                ID,
                ReadPermissionIndicator,
                AccessToPersonalDataPermissionIndicator,
                AccessToGenderAndAgeDataPermissionIndicator,
                WritePermissionIndicator,
                DeletePermissionIndicator
            )
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
            (
                ID,
                ReadPermissionIndicator,
                AccessToPersonalDataPermissionIndicator,
                AccessToGenderAndAgeDataPermissionIndicator,
                WritePermissionIndicator,
                DeletePermissionIndicator
            )
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
            (
                ID,
                ReadPermissionIndicator,
                AccessToPersonalDataPermissionIndicator,
                AccessToGenderAndAgeDataPermissionIndicator,
                WritePermissionIndicator,
                DeletePermissionIndicator
            )
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
            (
                ID,
                ReadPermissionIndicator,
                AccessToPersonalDataPermissionIndicator,
                AccessToGenderAndAgeDataPermissionIndicator,
                WritePermissionIndicator,
                DeletePermissionIndicator
            )
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
            (
                ID,
                ReadPermissionIndicator,
                AccessToPersonalDataPermissionIndicator,
                AccessToGenderAndAgeDataPermissionIndicator,
                WritePermissionIndicator,
                DeletePermissionIndicator
            )
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
                            INNER JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                                   AND msd.intRowStatus = 0
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
        (
            ID,
            ReadPermissionIndicator,
            AccessToPersonalDataPermissionIndicator,
            AccessToGenderAndAgeDataPermissionIndicator,
            WritePermissionIndicator,
            DeletePermissionIndicator
        )
        SELECT ms.idfMonitoringSession,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbMonitoringSession ms
            INNER JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                   AND msd.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = msd.idfsDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND ms.idfMonitoringSession = @MonitoringSessionID
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = res.ID
            INNER JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                   AND msd.intRowStatus = 0
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
        (
            ID,
            ReadPermissionIndicator,
            AccessToPersonalDataPermissionIndicator,
            AccessToGenderAndAgeDataPermissionIndicator,
            WritePermissionIndicator,
            DeletePermissionIndicator
        )
        SELECT ms.idfMonitoringSession,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbMonitoringSession ms
            INNER JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                   AND msd.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = msd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND ms.idfMonitoringSession = @MonitoringSessionID
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID;

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT ms.idfMonitoringSession
                        FROM dbo.tlbMonitoringSession ms
                            INNER JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                                   AND msd.intRowStatus = 0
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
        -- as all records have been pulled above with or without site filtration rules applied.
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
        (
            ID,
            ReadPermissionIndicator,
            AccessToPersonalDataPermissionIndicator,
            AccessToGenderAndAgeDataPermissionIndicator,
            WritePermissionIndicator,
            DeletePermissionIndicator
        )
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
        (
            ID,
            ReadPermissionIndicator,
            AccessToPersonalDataPermissionIndicator,
            AccessToGenderAndAgeDataPermissionIndicator,
            WritePermissionIndicator,
            DeletePermissionIndicator
        )
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

        -- Copy filtered results to final results
        INSERT INTO @FinalResults
        SELECT ID,
               MAX(res.ReadPermissionIndicator),
               MAX(res.AccessToPersonalDataPermissionIndicator),
               MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
               MAX(res.WritePermissionIndicator),
               MAX(res.DeletePermissionIndicator)
        FROM @Results res
        GROUP BY ID;

        SELECT ms.idfMonitoringSession AS HumanMonitoringSessionID,
               ms.strMonitoringSessionID AS EIDSSSessionID,
               ms.idfsMonitoringSessionStatus AS SessionStatusTypeID,
               monitoringSessionStatus.name AS SessionStatusTypeName,
               msd.idfsDiagnosis AS DiseaseID,
               disease.name AS DiseaseName,
               ms.datEnteredDate AS EnteredDate,
               ms.datStartDate AS StartDate,
               ms.datEndDate AS EndDate,
               lh.AdminLevel1Name,
               lh.AdminLevel1ID,
               lh.AdminLevel2Name,
               lh.AdminLevel2ID,
               lh.AdminLevel3Name,
               lh.AdminLevel3ID,
               lh.AdminLevel4Name,
               lh.AdminLevel4ID,
               lh.AdminLevel5Name,
               lh.AdminLevel5ID,
               lh.AdminLevel6Name,
               lh.AdminLevel6ID,
               lh.AdminLevel7Name,
               lh.AdminLevel7ID,
               ms.idfPersonEnteredBy AS EnteredByPersonID,
               ISNULL(p.strFamilyName, N'') + ISNULL(', ' + p.strFirstName, '') + ISNULL(' ' + p.strSecondName, '') AS EnteredByPersonName,
               ms.idfsSite AS SiteID,
               s.strSiteName AS SiteName,
               c.idfCampaign AS CampaignID,
               c.strCampaignName AS CampaignName,
               c.idfsCampaignType AS CampaignTypeID,
               campaignType.name AS CampaignTypeName,
               c.strCampaignID AS strCampaignID,
               CASE
                   WHEN ReadPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN ReadPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, ReadPermissionIndicator)
               END AS ReadPermissionindicator,
               CASE
                   WHEN AccessToPersonalDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToPersonalDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToPersonalDataPermissionIndicator)
               END AS AccessToPersonalDataPermissionIndicator,
               CASE
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToGenderAndAgeDataPermissionIndicator)
               END AS AccessToGenderAndAgeDataPermissionIndicator,
               CASE
                   WHEN WritePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN WritePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, WritePermissionIndicator)
               END AS WritePermissionIndicator,
               CASE
                   WHEN DeletePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN DeletePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, DeletePermissionIndicator)
               END AS DeletePermissionIndicator
        FROM @FinalResults res
            INNER JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = res.ID
            INNER JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                   AND msd.intRowStatus = 0
            LEFT JOIN dbo.tlbCampaign c
                ON c.idfCampaign = ms.idfCampaign
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000116) campaignType
                ON c.idfsCampaignType = campaignType.idfsReference
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000117) monitoringSessionStatus
                ON monitoringSessionStatus.idfsReference = ms.idfsMonitoringSessionStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) disease
                ON disease.idfsReference = MSD.idfsDiagnosis
            INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                ON lh.idfsLocation = ms.idfsLocation
            LEFT JOIN dbo.tlbPerson p
                ON p.idfPerson = ms.idfPersonEnteredBy
            INNER JOIN dbo.tstSite s
                ON s.idfsSite = ms.idfsSite;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_VET_DISEASE_REPORT_GETDetail]...';


GO
-- ================================================================================================
-- Name: USP_VET_DISEASE_REPORT_GETDetail
--
-- Description:	Get disease detail (one record) for the veterinary edit/enter and other use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/18/2019 Initial release.
-- Stephen Long     04/29/2019 Added connected disease report fields for use case VUC11 and VUC12.
-- Stephen Long     05/26/2019 Added farm epidemiological observation ID to select list.
-- Stephen Long     10/02/2019 Adjusted for changes to the person select list function.
-- Ann Xiong		12/05/2019 Added YNTestConducted, OIECode, ReportCategoryTypeID, 
--                             ReportCategoryTypeName to select list.
-- Stephen Long     02/14/2020 Added connected disease report ID and EIDSS report ID to the query.
-- Stephen Long     11/29/2021 Removed return code and message for POCO.
-- Stephen Long     12/07/2021 Added farm and farm owner fields.
-- Stephen Long     01/12/2022 Added street and postal code ID's to the query.
-- Stephen Long     01/19/2022 Added farm master ID and farm owner ID to the query.
-- Stephen Long     01/24/2022 Changed country ID and name to administrative level 0 to match use 
--                             case.
-- Stephen Long     04/28/2022 Added received by organization and person identifiers.
-- Doug Albanese    07/26/2022 Add field FarmEpidemiologicalTemplateID, to correctly identify a 
--                             form that has been answered
-- Stephen Long     05/16/2023 Fix for item 5584.
-- Stephen Long     06/07/2023 Fix for 4597 and 4598.
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_VET_DISEASE_REPORT_GETDetail]
(
    @LanguageID AS NVARCHAR(50),
    @DiseaseReportID AS BIGINT,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplyFiltrationIndicator BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SiteID BIGINT = (
                                     SELECT idfsSite
                                     FROM dbo.tlbVetCase
                                     WHERE idfVetCase = @DiseaseReportID
                                 );
    DECLARE @RelatedToIdentifiers TABLE 
    (
        ID BIGINT NOT NULL, 
        ReportID NVARCHAR(200) NOT NULL
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

    DECLARE @CaseOutbreakSessionImportedIndicator INT = (
                                                            SELECT CASE
                                                                       WHEN idfOutbreak IS NOT NULL
                                                                            AND (strCaseID IS NOT NULL OR LegacyCaseID IS NOT NULL) THEN
                                                                           1
                                                                       ELSE
                                                                           0
                                                                   END
                                                            FROM dbo.tlbVetCase
                                                            WHERE idfVetCase = @DiseaseReportID
                                                        );

    BEGIN TRY
    IF @UserSiteID = @SiteID OR @ApplyFiltrationIndicator = 0
        BEGIN
            INSERT INTO @Results
            SELECT @DiseaseReportID,
                   1,
                   1,
                   1,
                   1,
                   1;
        END
        ELSE
        BEGIN
            DECLARE @FilteredResults TABLE
            (
                ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL
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

            -- =======================================================================================
            -- DEFAULT CONFIGURABLE FILTRATION RULES
            --
            -- Apply active default filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0,
                    @AdministrativeLevelTypeID INT,
                    @OrganizationAdministrativeLevelID BIGINT,
                    @LanguageCode BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID);
            DECLARE @DefaultAccessRules TABLE
            (
                AccessRuleID BIGINT NOT NULL,
                ActiveIndicator INT NOT NULL,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL,
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
            -- Report data shall be available to all sites of the same administrative level 
            -- specified in the rule.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537009;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537009;

                SELECT @OrganizationAdministrativeLevelID = CASE
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
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                WHERE o.intRowStatus = 0
                      AND o.idfOffice = @UserOrganizationID;

                -- Administrative level specified in the rule of the site where the report was created.
                INSERT INTO @FilteredResults
                SELECT v.idfVetCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVetCase v
                    INNER JOIN dbo.tstSite s
                        ON v.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537009
                WHERE v.idfVetCase = @DiseaseReportID                  
                      AND (
                              g.Level1ID = @OrganizationAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          );

                -- Administrative level specified in the rule of the farm address.
                INSERT INTO @FilteredResults
                SELECT v.idfVetCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVetCase v
                    INNER JOIN dbo.tlbFarm f
                        ON f.idfFarm = v.idfFarm
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = f.idfFarmAddress
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537009
                WHERE v.idfVetCase = @DiseaseReportID                  
                      AND (
                              g.Level1ID = @OrganizationAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          );
            END;

            --
            -- Report data shall be available to all sites' organizations connected to the particular report.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537010;

            IF @RuleActiveStatus = 0
            BEGIN
                -- Investigated and reported by organizations
                INSERT INTO @FilteredResults
                SELECT v.idfVetCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVetCase v
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537010
                WHERE v.idfVetCase = @DiseaseReportID                  
                      AND (
                              v.idfInvestigatedByOffice = @UserOrganizationID
                              OR v.idfReportedByOffice = @UserOrganizationID
                          );

                -- Sample collected by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfVetCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbVetCase v
                        ON v.idfVetCase = m.idfVetCase
                           AND v.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537010
                WHERE m.intRowStatus = 0
                      AND m.idfVetCase = @DiseaseReportID
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          )
                GROUP BY m.idfVetCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;

                -- Sample transferred to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfVetCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbVetCase v
                        ON v.idfVetCase = m.idfVetCase
                           AND v.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial tom
                        ON m.idfMaterial = tom.idfMaterial
                           AND tom.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT t
                        ON tom.idfTransferOut = t.idfTransferOut
                           AND t.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537010
                WHERE m.intRowStatus = 0
                      AND m.idfVetCase = @DiseaseReportID
                      AND t.idfSendToOffice = @UserOrganizationID
                GROUP BY m.idfVetCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;
            END;

            --
            -- Report data shall be available to the sites with the connected outbreak, if the report 
            -- is the primary report/session for an outbreak.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537011;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT v.idfVetCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVetCase v
                    INNER JOIN dbo.tlbOutbreak o
                        ON v.idfVetCase = o.idfPrimaryCaseOrSession
                           AND o.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537011
                WHERE v.idfVetCase = @DiseaseReportID                  
                      AND o.idfsSite = @UserSiteID
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
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
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
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
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
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND sgs.idfsSite = v.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND a.GrantingActorSiteID = v.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
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
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND a.GrantingActorSiteID = v.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
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
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND a.GrantingActorSiteID = v.idfsSite;

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
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @Results
        WHERE ID IN (
                        SELECT v.idfVetCase
                        FROM dbo.tlbVetCase v
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE oa.intPermission = 1
                              AND oa.idfActor = -506 -- Default role
                    );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT v.idfVetCase,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbVetCase v
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND v.idfVetCase = @DiseaseReportID
              AND oa.idfActor = egm.idfEmployeeGroup;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVetCase v
                ON v.idfVetCase = res.ID
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT v.idfVetCase,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbVetCase v
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND v.idfVetCase = @DiseaseReportID
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID;

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT v.idfVetCase
                        FROM dbo.tlbVetCase v
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE oa.intPermission = 1 -- Deny permission
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
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT vc.idfVetCase
            FROM dbo.tlbVetCase vc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = vc.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE vc.idfVetCase = @DiseaseReportID
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
        SELECT vc.idfVetCase,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbVetCase vc
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = vc.idfsSite
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE vc.idfVetCase = @DiseaseReportID
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = vc.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVetCase vc
                ON vc.idfVetCase = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = vc.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT vc.idfVetCase,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbVetCase vc
        WHERE vc.idfVetCase = @DiseaseReportID
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = vc.idfsSite
        );

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT vc.idfVetCase
            FROM dbo.tlbVetCase vc
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = vc.idfsSite
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
        GROUP BY ID;

        IF @CaseOutbreakSessionImportedIndicator = 1
        BEGIN
            DECLARE @RelatedToDiseaseReportID BIGINT = @DiseaseReportID,
                    @ConnectedDiseaseReportID BIGINT;

            INSERT INTO @RelatedToIdentifiers
            SELECT idfVetCase, 
                   strCaseID
            FROM dbo.tlbVetCase 
            WHERE idfVetCase = @DiseaseReportID;

            WHILE EXISTS (SELECT * FROM dbo.VetDiseaseReportRelationship WHERE VetDiseaseReportID = @RelatedToDiseaseReportID)
            BEGIN
                INSERT INTO @RelatedToIdentifiers
                SELECT RelatedToVetDiseaseReportID, 
                       strCaseID
                FROM dbo.VetDiseaseReportRelationship  
                     INNER JOIN dbo.tlbVetCase ON idfVetCase = RelatedToVetDiseaseReportID
                WHERE VetDiseaseReportID = @RelatedToDiseaseReportID;

                SET @RelatedToDiseaseReportID = (SELECT RelatedToVetDiseaseReportID FROM dbo.VetDiseaseReportRelationship WHERE VetDiseaseReportID = @RelatedToDiseaseReportID);
            END
        END

        SELECT vc.idfVetCase AS DiseaseReportID,
               vc.idfFarm AS FarmID,
               f.idfFarmActual AS FarmMasterID,
               f.strFarmCode AS EIDSSFarmID,
               CASE
                   WHEN f.strNationalName IS NULL THEN
                       f.strInternationalName
                   WHEN f.strNationalName = '' THEN
                       f.strInternationalName
                   ELSE
                       f.strNationalName
               END AS FarmName,
               lh.AdminLevel1ID AS FarmAddressAdministrativeLevel0ID,
               lh.AdminLevel1Name AS FarmAddressAdministrativeLevel0Name,
               lh.AdminLevel2ID AS FarmAddressAdministrativeLevel1ID,
               lh.AdminLevel2Name AS FarmAddressAdministrativeLevel1Name,
               lh.AdminLevel3ID AS FarmAddressAdministrativeLevel2ID,
               lh.AdminLevel3Name AS FarmAddressAdministrativeLevel2Name,
               lh.AdminLevel4ID AS FarmAddressAdministrativeLevel3ID,
               lh.AdminLevel4Name AS FarmAddressAdministrativeLevel3Name,
               farmSettlementType.idfsReference AS FarmAddressSettlementTypeID,
               farmSettlementType.name AS FarmAddressSettlementTypeName,
               farmSettlement.idfsReference AS FarmAddressSettlementID,
               farmSettlement.name AS FarmAddressSettlementName,
               st.idfStreet AS FarmAddressStreetID,
               glFarm.strStreetName AS FarmAddressStreetName,
               glFarm.strBuilding AS FarmAddressBuilding,
               glFarm.strApartment AS FarmAddressApartment,
               glFarm.strHouse AS FarmAddressHouse,
               pc.idfPostalCode AS FarmAddressPostalCodeID,
               glFarm.strPostCode AS FarmAddressPostalCode,
               glFarm.dblLatitude AS FarmAddressLatitude,
               glFarm.dblLongitude AS FarmAddressLongitude,
               h.idfHuman AS FarmOwnerID,
               h.strPersonID AS EIDSSFarmOwnerID,
               h.strFirstName AS FarmOwnerFirstName,
               h.strLastName AS FarmOwnerLastName,
               h.strSecondName AS FarmOwnerSecondName,
               f.strContactPhone AS Phone,
               f.strEmail AS Email,
               vc.idfsFinalDiagnosis AS DiseaseID,
               disease.name AS DiseaseName,
               vc.idfPersonEnteredBy AS EnteredByPersonID,
               dbo.FN_GBL_ConcatFullName(
                                            personEnteredBy.strFamilyName,
                                            personEnteredBy.strFirstName,
                                            personEnteredBy.strSecondName
                                        ) AS EnteredByPersonName,
               vc.idfPersonReportedBy AS ReportedByPersonID,
               dbo.FN_GBL_ConcatFullName(
                                            personReportedBy.strFamilyName,
                                            personReportedBy.strFirstName,
                                            personReportedBy.strSecondName
                                        ) AS ReportedByPersonName,
               vc.idfPersonInvestigatedBy AS InvestigatedByPersonID,
               dbo.FN_GBL_ConcatFullName(
                                            personInvestigatedBy.strFamilyName,
                                            personInvestigatedBy.strFirstName,
                                            personInvestigatedBy.strSecondName
                                        ) AS InvestigatedByPersonName,
               f.idfObservation AS FarmEpidemiologicalObservationID,
               vc.idfObservation AS ControlMeasuresObservationID,
               vc.idfsSite AS SiteID,
               s.strSiteName AS SiteName,
               vc.datReportDate AS ReportDate,
               vc.datAssignedDate AS AssignedDate,
               vc.datInvestigationDate AS InvestigationDate,
               vc.datFinalDiagnosisDate AS DiagnosisDate,
               vc.strFieldAccessionID AS EIDSSFieldAccessionID,
               vc.idfsYNTestsConducted AS TestsConductedIndicator,
               vc.intRowStatus AS RowStatus,
               vc.idfReportedByOffice AS ReportedByOrganizationID,
               reportedByOrganization.name AS ReportedByOrganizationName,
               vc.idfInvestigatedByOffice AS InvestigatedByOrganizationID,
               investigatedByOrganization.name AS InvestigatedByOrganizationName,
               vc.idfReceivedByOffice AS ReceivedByOrganizationID, 
               vc.idfReceivedByPerson AS ReceivedByPersonID, 
               vc.idfsCaseReportType AS ReportTypeID,
               reportType.name AS ReportTypeName,
               vc.idfsCaseClassification AS ClassificationTypeID,
               classificationType.name AS ClassificationTypeName,
               vc.idfOutbreak AS OutbreakID,
               o.strOutbreakID AS EIDSSOutbreakID,
               vc.datEnteredDate AS EnteredDate,
               vc.strCaseID AS EIDSSReportID,
               vc.LegacyCaseID AS LegacyID,
               vc.idfsCaseProgressStatus AS ReportStatusTypeID,
               reportStatusType.name AS ReportStatusTypeName,
               vc.datModificationForArchiveDate AS ModifiedDate,
               vc.idfParentMonitoringSession AS ParentMonitoringSessionID,
               ms.strMonitoringSessionID AS EIDSSParentMonitoringSessionID,
               relatedTo.RelatedToVetDiseaseReportID AS RelatedToVeterinaryDiseaseReportID,
               relatedToReport.strCaseID AS RelatedToVeterinaryDiseaseEIDSSReportID,
               connectedTo.VetDiseaseReportID AS ConnectedDiseaseReportID,
               connectedToReport.strCaseID AS ConnectedDiseaseEIDSSReportID,
               testConductedType.name AS YNTestConducted,
               d.strOIECode AS OIECode,
               vc.idfsCaseType AS ReportCategoryTypeID,
               caseType.name AS ReportCategoryTypeName,
			   ffo.idfsFormTemplate AS FarmEpidemiologicalTemplateID, 
               (SELECT STRING_AGG(ID, ', ') WITHIN GROUP (ORDER BY ReportID) AS Result
               FROM @RelatedToIdentifiers) AS RelatedToIdentifiers,
               (SELECT STRING_AGG(ReportID, ', ') WITHIN GROUP (ORDER BY ReportID) AS Result
               FROM @RelatedToIdentifiers) AS RelatedToReportIdentifiers,
                              CASE
                   WHEN ReadPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN ReadPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, ReadPermissionIndicator)
               END AS ReadPermissionindicator,
               CASE
                   WHEN AccessToPersonalDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToPersonalDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToPersonalDataPermissionIndicator)
               END AS AccessToPersonalDataPermissionIndicator,
               CASE
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToGenderAndAgeDataPermissionIndicator)
               END AS AccessToGenderAndAgeDataPermissionIndicator,
               CASE
                   WHEN WritePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN WritePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, WritePermissionIndicator)
               END AS WritePermissionIndicator,
               CASE
                   WHEN DeletePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN DeletePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, DeletePermissionIndicator)
               END AS DeletePermissionIndicator
        FROM @FinalResults res
            INNER JOIN dbo.tlbVetCase vc 
                ON vc.idfVetCase = res.ID 
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = vc.idfFarm
            INNER JOIN dbo.tstSite s
                ON s.idfsSite = vc.idfsSite
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000012) caseType
                ON caseType.idfsReference = vc.idfsCaseType
            LEFT JOIN dbo.tlbHuman h
                ON h.idfHuman = f.idfHuman
                   AND h.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation glFarm
                ON glFarm.idfGeoLocation = f.idfFarmAddress
                   AND glFarm.intRowStatus = 0
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = glFarm.idfsLocation
            LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                ON lh.idfsLocation = glFarm.idfsLocation
            LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000004) AS farmSettlement
                ON g.node.IsDescendantOf(farmSettlement.node) = 1
            LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000005) farmSettlementType
                ON farmSettlementType.idfsReference = farmSettlement.idfsType
            LEFT JOIN dbo.tlbStreet st
                ON st.strStreetName = glFarm.strStreetName
            LEFT JOIN dbo.tlbPostalCode pc
                ON pc.strPostCode = glFarm.strPostCode
            LEFT JOIN dbo.tlbPerson personInvestigatedBy
                ON personInvestigatedBy.idfPerson = vc.idfPersonInvestigatedBy
            LEFT JOIN dbo.tlbPerson personEnteredBy
                ON personEnteredBy.idfPerson = vc.idfPersonEnteredBy
            LEFT JOIN dbo.tlbPerson personReportedBy
                ON personReportedBy.idfPerson = vc.idfPersonReportedBy
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) disease
                ON disease.idfsReference = vc.idfsFinalDiagnosis
            LEFT JOIN dbo.trtDiagnosis d
                ON d.idfsDiagnosis = vc.idfsFinalDiagnosis
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000011) classificationType
                ON classificationType.idfsReference = vc.idfsCaseClassification
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000111) reportStatusType
                ON reportStatusType.idfsReference = vc.idfsCaseProgressStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000144) reportType
                ON reportType.idfsReference = vc.idfsCaseReportType
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000100) testConductedType
                ON testConductedType.idfsReference = vc.idfsYNTestsConducted
            LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) reportedByOrganization
                ON reportedByOrganization.idfOffice = vc.idfReportedByOffice
            LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) investigatedByOrganization
                ON investigatedByOrganization.idfOffice = vc.idfInvestigatedByOffice
            LEFT JOIN dbo.tlbOutbreak o
                ON o.idfOutbreak = vc.idfOutbreak
                   AND o.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = vc.idfParentMonitoringSession
                   AND ms.intRowStatus = 0
            LEFT JOIN dbo.VetDiseaseReportRelationship relatedTo
                ON relatedTo.VetDiseaseReportID = vc.idfVetCase
                   AND relatedTo.intRowStatus = 0
                   AND relatedTo.RelationshipTypeID = 10503001
            LEFT JOIN dbo.tlbVetCase relatedToReport
                ON relatedToReport.idfVetCase = relatedTo.RelatedToVetDiseaseReportID
                   AND relatedToReport.intRowStatus = 0
            LEFT JOIN dbo.VetDiseaseReportRelationship connectedTo
                ON connectedTo.RelatedToVetDiseaseReportID = vc.idfVetCase
                   AND connectedTo.intRowStatus = 0
                   AND connectedTo.RelationshipTypeID = 10503001
            LEFT JOIN dbo.tlbVetCase connectedToReport
                ON connectedToReport.idfVetCase = connectedTo.VetDiseaseReportID
                   AND connectedToReport.intRowStatus = 0
			LEFT JOIN dbo.tlbObservation ffo
				ON ffo.idfObservation = f.idfObservation
        WHERE vc.idfVetCase = @DiseaseReportID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
GO
