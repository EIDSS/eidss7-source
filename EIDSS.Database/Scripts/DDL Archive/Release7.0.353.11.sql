
/*
The type for column SchoolName in table [dbo].[HumanActualAddlInfo] is currently  NVARCHAR (200) NULL but is being changed to  VARCHAR (200) NULL. Data loss could occur and deployment may fail if the column contains data that is incompatible with type  VARCHAR (200) NULL.
*/

IF EXISTS (select top 1 1 from [dbo].[HumanActualAddlInfo])
    RAISERROR (N'Rows were detected. The schema update is terminating because data loss might occur.', 16, 127) WITH NOWAIT

GO
PRINT N'Rename refactoring operation with key f64901e9-400d-4414-9e3b-500acf982e3e is skipped, element [dbo].[OutbreakCaseReport].[IX_OutbreakCaseReport_idfVetCaseID] (SqlIndex) will not be renamed to [IX_OutbreakCaseReport_idfVetCase]';


GO
PRINT N'Altering Table [dbo].[HumanActualAddlInfo]...';


GO
ALTER TABLE [dbo].[HumanActualAddlInfo] ALTER COLUMN [SchoolName] VARCHAR (200) NULL;


GO
PRINT N'Refreshing Function [dbo].[FN_VET_FARM_MASTER_GETList]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[FN_VET_FARM_MASTER_GETList]';


GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_FF_Copy_Template]...';


GO
-- ================================================================================================
-- Name: USP_ADMIN_FF_Copy_Template
-- Description: Copies the base structure of a template and its components to prevent historical damage.
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albanese	01/12/2021	Initial release for use by other SPs.
-- Doug Albanese	01/19/2021	Fixed the return to provide the new Form Template id
-- Doug Albanese	01/21/2021	Change of business rule to allow older templates to still be modified.
-- Doug Albanese	01/21/2021	Disabled UNI for the old template being copied.
-- Doug Albanese	07/02/2021	Altered the procedure to ignore blank idfsSections
-- Doug Albanese	07/06/2021	Refactored for use with a user initiated copy.
-- Doug Albanese	07/09/2021	Added language parameter
-- Doug Albanese	07/09/2021	Removed supression
-- Doug Albanese	07/12/2021	Corrected return aliases
-- Doug Albanese	07/12/2021	Corrections to remove copying of Sections and Parameters, and replace with association to the new template
-- Doug Albanese	07/14/2021	Turning off content to make this process a successor procedure only
-- Doug Albanese	07/14/2021	Created translation for SP generated "Copy"
-- Doug Albanese	07/14/2021	Added ordering from original template
-- Doug Albanese	07/14/2021	Added Edit Mode for Mandatory/Ordinary settings
--	Doug Albanese	05/12/2022	Adjusting for copying to another formtype
--	Doug Albanese	06/02/2022	Changed the functioncall parameter for USP_ADMIN_FF_ParameterTemplate_SET, to work with USP_ADMIN_FF_ParameterDesignOptions_SET
--	Doug Albanese	06/07/2022	Changed USP_ADMIN_FF_ParameterTemplate_SET, to call as a function
--	Doug Albanese	06/08/2022	Corrected the Determinants value copy. Was in the wrong place
--	Doug Albanese	06/10/2022	Making use of USP_ADMIN_FF_ParameterTemplateForCopy_SET, instead of USP_ADMIN_FF_ParameterTemplate_SET for EF Generation purposes
--								Realigned call to USP_Admin_FF_Rule_GetDetails for new changes
--	Doug Albanese	06/30/2022	Correcting the process of copying Determinants
--	Doug Albanese	07/01/2022	Removed rollback
--	Doug Albanese	07/21/2022	Re-aligned to work with changes made on USP_ADMIN_FF_Template_SET
--	Doug Albanese	08/04/2022	Added a secondary "intRowStatus"
--	Doug Albanese	08/04/2022	Corrected a call to USP_ADMIN_FF_Determinant_SET, because it was remotely set for Event logging.
--	Doug Albanese	08/04/2022	Corrected "Template Details" to coalesce the blnUNI value, when it was null
--  Doug Albanese	01/26/2023	Correction to allow Copying of templates to create Outbreak assigned flex forms.
-- Doug Albanese	03/22/2023	Changed SP to make use of UserId, instead of User...so that event logging will not break.
-- Doug Albanese	04/14/2023	Changed size of "Name" fields from 200 to 2000
-- Doug Albanese   04/25/2023	Added SourceSystemNameID and SourceSystemKeyValue to the "Rule Constant" insert statement
-- Doug Albanese  05/04/2023	Brought the determinant SQL, directly into this SP. The Event Logging was breaking in this "Auto Copy", done when a template is altered.
-- Doug Albanese  05/26/2023	Correction to the new creation of a Template, when using Flex Form Desinger from Outbreak.
-- Doug Albanese  05/31/2023	Stopped the deletion of Determinants when copying a flex form from the disease report side for replication.
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_FF_Copy_Template] (
	@LangId									NVARCHAR(50),
	@idfsFormTemplate						BIGINT,
	@User									NVARCHAR(50),
	@idfsSite								BIGINT = NULL,
	@idfsNewFormType						BIGINT = NULL
)
AS
BEGIN
	DECLARE @returnCode						INT = 0;
	DECLARE @returnMsg						NVARCHAR(MAX) = 'SUCCESS';
	
	Declare @SupressSelect TABLE
	(	
		retrunCode							INT,
		returnMessage						VARCHAR(200)
	) 

	DECLARE @Supress_USP_ADMIN_FF_Parameters_SET TABLE (
		ReturnCode							INT,
		ReturnMessage						VARCHAR(200),
		idfsParameter						BIGINT,
		idfsParameterCaption				BIGINT
	)
	
	DECLARE @Supress_USP_ADMIN_FF_ParameterTemplate_SET TABLE(
		ReturnData							VARCHAR(200)
	)

	DECLARE @iObservations					INT = 0


	BEGIN TRY
		
		--Changes that have the potential to trigger copying of a template
		--Template details
		--Parameter addition, moving, or deleting from a template
		--Section addition, moving, or deleting from a template
		--Parameter Editor changes
		--Section Editor Changes
		--Updating "Mandatory" status
		--Adding, Editing, or Removing a Rule

		DECLARE @FormTemplate				NVARCHAR(2000)
		DECLARE @NationalName				NVARCHAR(2000)
		DECLARE @NationalLongName			NVARCHAR(2000)
		DECLARE @idfsFormType				BIGINT
		DECLARE @strNote					NVARCHAR(MAX)
		DECLARE @blnUNI						BIT

		DECLARE @idfsSection				BIGINT
		DECLARE @idfsParameter				BIGINT
		DECLARE @idfsParentSection			BIGINT 
		DECLARE @DefaultName				NVARCHAR(2000)
		DECLARE @DefaultLongName			NVARCHAR(2000)
		DECLARE @intOrder					INT
		DECLARE @blnGrid					BIT
		DECLARE @blnFixedRowset				BIT
		DECLARE @idfsMatrixType				BIGINT
		DECLARE @intRowStatus				INT
		DECLARE @idfsSectionNew				BIGINT
		DECLARE @idfsFormTemplateNew		BIGINT

		DECLARE @idfsParameterNew			BIGINT
		DECLARE	@idfsParameterCaption		BIGINT
		DECLARE @idfsParameterType			BIGINT
		DECLARE @idfsEditor					BIGINT
		DECLARE @intHACode					INT
		DECLARE @langid_int					BIGINT
		DECLARE @idfsRule					BIGINT
		DECLARE @idfsEditMode				BIGINT

		DECLARE @idfsRuleMessage			BIGINT
		DECLARE @idfsRuleFunction			BIGINT
		DECLARE @idfsRuleAction				BIGINT
		DECLARE	@idfsFunctionParameter		BIGINT
		DECLARE @idfsActionParameter		BIGINT
		DECLARE	@idfsFunctionParameterNew	BIGINT
		DECLARE @idfsActionParameterNew		BIGINT
		DECLARE @intNumberOfParameters		INT
		DECLARE @idfsCheckPoint				BIGINT
		DECLARE @MessageText				NVARCHAR(MAX)
		DECLARE @MessageNationalText		NVARCHAR(MAX)
		DECLARE @blnNot						BIT
		DECLARE	@idfsRuleNew				BIGINT
		DECLARE	@strFillValue				NVARCHAR(MAX)
		DECLARE	@strCompareValue			NVARCHAR(MAX)

		DECLARE @DefaultRuleName			NVARCHAR(MAX)
		DECLARE @NationalRuleName			NVARCHAR(MAX)
		DECLARE @DefaultRuleMessage			NVARCHAR(MAX)
		DECLARE @NationalRuleMessage		NVARCHAR(MAX)
		DECLARE @strActionParameters		NVARCHAR(MAX)

		DECLARE @idfRuleConstant			BIGINT
		DECLARE @idfRuleConstantNew			BIGINT
		DECLARE @varConstant				SQL_VARIANT

		DECLARE @idfDeterminantValue		BIGINT
		DECLARE @idfDeterminant				BIGINT
		DECLARE @idfsBaseReference			BIGINT
		DECLARE @idfsGISBaseReference		BIGINT

		DECLARE @strResourceString			NVARCHAR(200) = 'Copy'
		DECLARE @UserId						BIGINT

		SET NOCOUNT ON

		SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangID);

		SELECT @UserId = userInfo.UserId,
		  @idfsSite = userInfo.SiteId
		   FROM dbo.FN_UserSiteInformation(@User) userInfo;

		
		--Are any observations made for the given active (intRowStatus = 0) template?
		--SELECT
		--	@iObservations = COUNT(idfObservation)
		--FROM
		--	tlbObservation O
		--INNER JOIN ffFormTemplate FT
		--	ON FT.idfsFormTemplate = O.idfsFormTemplate
		--	AND FT.intRowStatus = 0
		--WHERE
		--	O.idfsFormTemplate = @idfsFormTemplate

		--IF @iObservations > 0
		--	BEGIN
				----------------------------------------------------------------------------------------
				--Create table structures for collecting up items to enumerate and tag,				  --
				--and capture EXEC results                                                            --
				----------------------------------------------------------------------------------------
				DECLARE @Sections TABLE (
					idfsSection			BIGINT NULL,
					idfsSectionNew		BIGINT NULL
				)

				DECLARE @Parameters TABLE (
					idfsParameter		BIGINT,
					idfsParameterNew	BIGINT,
					idfsSection			BIGINT,
					idfsSectionNew		BIGINT
				)

				DECLARE @ActionParameters TABLE (
					idfsParameter		BIGINT
				)

				DECLARE @FunctionParameters TABLE (
					idfsParameter		BIGINT
				)

				DECLARE @TemplateDetails TABLE (
					idfsFormTemplate	BIGINT,
					FormTemplate		NVARCHAR(2000),
					DefaultName			NVARCHAR(2000),
					NationalName		NVARCHAR(2000),
					idfsFormType		BIGINT,
					strNote				NVARCHAR(MAX),
					blnUNI				BIT
				)

				DECLARE @SectionSetResults TABLE (
					returnCode			BIGINT,
					returnMsg			NVARCHAR(MAX),
					idfsSection			BIGINT
				)

				DECLARE @SectionDetailResults TABLE (
					idfsParentSection	BIGINT,
					idfsFormType		BIGINT,
					intOrder			INT,
					blnGrid				BIT,
					blnFixedRowset		BIT,
					idfsMatrixType		BIGINT,
					strDefault			NVARCHAR(MAX),
					NationalName		NVARCHAR(MAX)
				)

				DECLARE @TemplateDetailsResults TABLE (
					returnCode			BIGINT,
					returnMsg			NVARCHAR(MAX),
					idfsFormTemplate	BIGINT
				)

				DECLARE	@Rules	TABLE (
					idfsRule			BIGINT,
					idfsRuleNew			BIGINT
				)

				DECLARE @RuleDetailResults TABLE (
					idfsRule				BIGINT,
					defaultRuleName			NVARCHAR(MAX),
					RuleName				NVARCHAR(MAX),
					idfsRuleMessage			BIGINT,
					defaultRuleMessage		NVARCHAR(MAX),
					RuleMessage				NVARCHAR(MAX),
					idfsCheckPoint			BIGINT,
					idfsRuleFunction		BIGINT,
					blnNot					BIT,
					idfsRuleAction			BIGINT,
					strActionParameters		NVARCHAR(MAX),
					idfsFunctionParameter	BIGINT,
					FillValue				NVARCHAR(MAX)
				)

				DECLARE @RuleConstants TABLE (
					idfRuleConstant		BIGINT,
					idfsRule			BIGINT,
					varConstant			SQL_VARIANT
				)

				DECLARE @Functions TABLE (
					idfParameterForFunction	BIGINT,
					idfsParameter			BIGINT,
					idfsFormTemplate		BIGINT,
					idfsRule				BIGINT,
					intOrder				INT,
					strCompareValue			NVARCHAR(MAX)
				)

				DECLARE @Actions TABLE (
					idfParameterForAction	BIGINT,
					idfsParameter			BIGINT,
					idfsFormTemplate		BIGINT,
					idfsRuleAction			BIGINT,
					idfsRule				BIGINT,
					strFillValue			NVARCHAR(MAX)
				)

				DECLARE @GlobalReference TABLE (
					idfs					BIGINT,
					idfsNew					BIGINT
				)

				DECLARE @Determinants TABLE (
					idfDeterminantValue		BIGINT,
					idfsBaseReference		BIGINT
				)

				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Make a copy of the base Template													  --
				----------------------------------------------------------------------------------------
				INSERT INTO @TemplateDetails
				EXEC USP_ADMIN_FF_Template_GetDetail @LangID = @LangId, @idfsFormTemplate = @idfsFormTemplate

				SELECT
					@idfsFormTemplate = idfsFormTemplate,
					@FormTemplate = FormTemplate,
					@DefaultName = DefaultName,
					@NationalName = NationalName,
					@idfsFormType = idfsFormType,
					@strNote = strNote,
					@blnUNI = COALESCE(blnUNI,0)
				FROM
					@TemplateDetails

				if @idfsNewFormType IS NOT NULL
					BEGIN
						SET @idfsFormType = @idfsNewFormType
						SET @blnUNI = 0
					END
				
				--Generate new idfsFormTemplate with existing names, having "Copy" appended to it
				SELECT
					@strResourceString = strResourceString
				FROM
					trtResourceTranslation
				WHERE 
					idfsResource = 744 and 
					idfsLanguage = @langid_int

				SET @DefaultName = CONCAT(@DefaultName,' (', @strResourceString , ')')
				SET @NationalName = CONCAT(@NationalName,' (', @strResourceString , ')')

				INSERT INTO @SupressSelect
				EXEC dbo.USSP_GBL_BaseReference_SET @idfsFormTemplateNew OUTPUT, 19000033/*'rftParameter'*/,@LangID, @DefaultName, @NationalName, 0

				--Create Global Reference for use by subsequential steps
				INSERT INTO @GlobalReference (idfs, idfsNew) VALUES (@idfsFormTemplate, @idfsFormTemplateNew)

				--Create the new Template
				INSERT INTO @SupressSelect
				EXEC USP_ADMIN_FF_Template_SET 
					@idfsFormType = @idfsFormType, 
					@DefaultName = @DefaultName,
					@NationalName = @NationalName, 
					@strNote = @strNote, 
					@LangId = @LangID, 
					@blnUNI = @blnUNI,
					@idfsFormTemplate = @idfsFormTemplateNew,
					@User = @User,
					@FunctionCall = 1,
					@CopyOnly = 1,
					@EventTypeId =10025120,
					@SiteId = @idfsSite,
					@UserId = @UserId,
					@LocationId = -1
					
			   IF @idfsNewFormType IS NULL
				  BEGIN
					  --Turn off UNI on old Template, since the newer on is the primary one now
					  UPDATE
						  ffFormTemplate
					  SET
						  blnUNI = 0
					  WHERE
						  idfsFormTemplate = @idfsFormTemplate
				  END

				--Disable existing Template
				--UPDATE
				--	ffFormTemplate
				--SET
				--	intRowStatus = 1
				--WHERE
				--	idfsFormTemplate = @idfsFormTemplate
				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Obtain a collection of Sections													  --
				----------------------------------------------------------------------------------------
				INSERT INTO @Sections (idfsSection)
				SELECT
					SFT.idfsSection
				FROM
					ffSectionForTemplate SFT
				INNER JOIN ffSection S
					ON S.idfsSection = SFT.idfsSection AND
						SFT.intRowStatus = 0
				WHERE
					SFT.idfsFormTemplate = @idfsFormTemplate AND
					S.intRowStatus = 0

				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Obtain a collection of Parameters and their associated Sections					  --
				----------------------------------------------------------------------------------------
				INSERT INTO @Parameters (idfsParameter, idfsSection)
				SELECT
					PFT.idfsParameter,
					P.idfsSection
				FROM
					ffParameterForTemplate PFT
				INNER JOIN ffParameter P
					ON P.idfsParameter = PFT.idfsParameter AND
						PFT.intRowStatus = 0
				WHERE
					PFT.idfsFormTemplate = @idfsFormTemplate AND
					P.intRowStatus = 0
				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Obtain a collection of Rules														  --
				----------------------------------------------------------------------------------------
				INSERT INTO @Rules (idfsRule)
				SELECT
					idfsRule
				FROM
					ffRule
				WHERE
					idfsFormTemplate = @idfsFormTemplate AND
					intRowStatus = 0
				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Obtain a collection of Rules														  --
				----------------------------------------------------------------------------------------
				--INSERT INTO @Rules (idfsRule)
				--SELECT
				--	idfsRule
				--FROM
				--	ffRule
				--WHERE
				--	idfsFormTemplate = @idfsFormTemplate
				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Obtain a collection of Rule Constants												  --
				----------------------------------------------------------------------------------------
				INSERT INTO @RuleConstants (idfRuleConstant, idfsRule, varConstant)
				SELECT
					RC.idfRuleConstant,
					RC.idfsRule,
					RC.varConstant
				FROM
					ffRuleConstant RC
				INNER JOIN ffRule R
					ON R.idfsRule = RC.idfsRule
				WHERE
					R.idfsFormTemplate = @idfsFormTemplate AND
					R.intRowStatus = 0
				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Obtain a collection of Template Determinants										  --
				--------------------------------------------------------------------------------------
				INSERT INTO @Determinants (idfDeterminantValue, idfsBaseReference)
				SELECT
					 DISTINCT
					idfDeterminantValue,
					idfsBaseReference
				FROM
					ffDeterminantValue
				WHERE
					idfsFormTemplate = @idfsFormTemplate and 
					intRowStatus = 0 and 
					idfsBaseReference is not null
				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Make a copy of each Section and its Template association							  --
				----------------------------------------------------------------------------------------
				WHILE EXISTS(SELECT TOP 1 idfsSection FROM @Sections WHERE idfsSectionNew IS NULL)
					BEGIN
						--Get another recored that hasn't been converted yet
						SELECT TOP 1 @idfsSection = idfsSection FROM @Sections WHERE idfsSectionNew IS NULL
						SELECT @intOrder = intOrder FROM ffSectionDesignOption WHERE idfsFormTemplate = @idfsFormTemplate AND idfsSection = @idfsSection
						
						--SELECT
						--	@idfsParentSection	= idfsParentSection,
						--	@idfsFormType		= idfsFormType,
						--	@intOrder			= S.intOrder,
						--	@blnGrid			= blnGrid,
						--	@blnFixedRowset		= blnFixedRowset,
						--	@idfsMatrixType		= idfsMatrixType,
						--	@DefaultName		= B.strDefault,
						--	@NationalName		= ISNULL(SNT.[strTextString], B.[strDefault]) 
						--FROM
						--	ffSection S
						--INNER JOIN dbo.trtBaseReference B
						--ON B.[idfsBaseReference] = S.[idfsSection]
						--   AND B.[intRowStatus] = 0  
						--LEFT JOIN dbo.trtStringNameTranslation SNT
						--ON SNT.[idfsBaseReference] = S.[idfsSection]
						--   AND SNT.idfsLanguage = @langid_int
						--   AND SNT.[intRowStatus] = 0
						--WHERE
						--	idfsSection = @idfsSection
							
						--Reset to grab a new id each iteration
						--SET @idfsSectionNew = NULL

						--Create another Section, based off of the details obtained from the previous step
						--INSERT INTO @SupressSelect
						--EXEC dbo.USSP_GBL_BaseReference_SET @idfsSectionNew OUTPUT,19000101,@LangID,@DefaultName,@NationalName,0

						--IF @idfsSectionNew IS NOT NULL 
						--	BEGIN
								--Create Global Reference for use by subsequential steps
								--INSERT INTO @GlobalReference (idfs, idfsNew) VALUES (@idfsSection, @idfsSectionNew)
								----INSERT INTO @SectionSetResults
								--INSERT INTO @SupressSelect
								--EXEC USP_ADMIN_FF_Sections_SET 
								--	@idfsSection		= @idfsSectionNew, 
								--	@idfsParentSection	= @idfsParentSection, 
								--	@idfsFormType		= @idfsFormType,
								--	@intOrder			= @intOrder,
								--	@blnGrid			= @blnGrid,
								--	@blnFixedRowset		= @blnFixedRowset,
								--	@idfsMatrixType		= @idfsMatrixType,
								--	@intRowStatus		= @intRowStatus,
								--	@User				= @User,
								--	@CopyOnly			= 1

								--Create entry for the association of this new Section against the new Template
								INSERT INTO @SupressSelect
								EXEC USP_ADMIN_FF_SectionTemplate_SET 
									@LangId = @LangID, 
									@idfsSection = @idfsSection, 
									@idfsFormTemplate = @idfsFormTemplateNew,
									@User = @User

								UPDATE
									ffSectionDesignOption
								SET
									intOrder = @intOrder
								WHERE
									idfsFormTemplate = @idfsFormTemplate AND
									idfsSection = @idfsSection

								--Update the temporary table, to mark it as converted
								UPDATE
									@Sections
								SET
									idfsSectionNew = @idfsSection
								WHERE
									idfsSection = @idfsSection

								UPDATE
									@Parameters
								SET
									idfsSectionNew = @idfsSection
								WHERE
									idfsSection = @idfsSection
									
								--Soft delete the old section, from the ffSection table
								--UPDATE 
								--	ffSection
								--SET
								--	intRowStatus = 1
								--WHERE
								--	idfsSection = @idfsSection
							--END
					END
				----------------------------------------------------------------------------------------

				----------------------------------------------------------------------------------------
				--Make a copy of each Parameter and its Template association						  --
				----------------------------------------------------------------------------------------
				WHILE EXISTS(SELECT TOP 1 idfsParameter FROM @Parameters WHERE idfsParameterNew IS NULL)
					BEGIN
						--Get another record that hasn't been converted yet
						SELECT TOP 1 @idfsParameter = idfsParameter FROM @Parameters WHERE idfsParameterNew IS NULL
						SELECT @intOrder = intOrder FROM ffParameterDesignOption WHERE idfsFormTemplate = @idfsFormTemplate AND idfsParameter = @idfsParameter
						SELECT @idfsEditMode = idfsEditMode FROM ffParameterForTemplate WHERE idfsFormTemplate = @idfsFormTemplate AND idfsParameter = @idfsParameter

						--Grab the details for the current parameter
						--SELECT
						--	@idfsSection			= P.idfsSection,
						--	@idfsParameterCaption	= P.idfsParameterCaption,
						--	@idfsParameterType		= P.idfsParameterType,
						--	@idfsFormType			= P.idfsFormType,
						--	@idfsEditor				= P.idfsEditor,
						--	@strNote				= P.strNote,
						--	@intOrder				= P.intOrder,
						--	@intHACode				= P.intHACode,
						--	@DefaultName			= ISNULL(B2.[strDefault], ''),
						--	@DefaultLongName		= ISNULL(B1.[strDefault], ''),
						--	@NationalName			= ISNULL(SNT2.[strTextString], B2.[strDefault]),
						--	@NationalLongName		= ISNULL(SNT1.[strTextString], B1.[strDefault])
						--FROM
						--	ffParameter P
						--INNER JOIN dbo.trtBaseReference B1
						--ON B1.[idfsBaseReference] = P.[idfsParameter]
						--	AND B1.[intRowStatus] = 0
						--LEFT JOIN dbo.trtBaseReference B2
						--ON B2.[idfsBaseReference] = P.[idfsParameterCaption]
						--	AND B2.[intRowStatus] = 0
						--LEFT JOIN dbo.trtStringNameTranslation SNT1
						--ON (SNT1.[idfsBaseReference] = P.[idfsParameter]
						--	AND SNT1.[idfsLanguage] = @langid_int)
						--	AND SNT1.[intRowStatus] = 0
						--LEFT JOIN dbo.trtStringNameTranslation SNT2
						--ON (SNT2.[idfsBaseReference] = P.[idfsParameterCaption]
						--	AND SNT2.[idfsLanguage] = @langid_int)
						--	AND SNT2.[intRowStatus] = 0
						--WHERE
						--	P.idfsParameter = @idfsParameter
							
						--Reset to grab a new id each iteration
						--SET @idfsParameterNew = NULL

						----Create another parameter, based off of the details obtained from the previous step
						--INSERT INTO @SupressSelect
						--EXEC dbo.USSP_GBL_BaseReference_SET @idfsParameterNew OUTPUT, 19000066/*'rftParameter'*/,@LangID, @DefaultLongName, @NationalLongName, 0

						--INSERT INTO @SupressSelect
						--EXEC dbo.USSP_GBL_BaseReference_SET @idfsParameterCaption OUTPUT, 19000070 /*'rftParameterToolTip'*/,@LangID, @DefaultName, @NationalName, 0

						----Create Global Reference for use by subsequential steps
						--INSERT INTO @GlobalReference (idfs, idfsNew) VALUES (@idfsParameter, @idfsParameterNew)

						--Obtain the id for the newly copied section
						--SELECT
						--	@idfsSectionNew = idfsSectionNew
						--FROM
						--	@Parameters
						--WHERE
						--	idfsParameter = @idfsParameter

						--Create the copy of the existing Parameter
						--INSERT INTO @Supress_USP_ADMIN_FF_Parameters_SET
						--EXEC USP_ADMIN_FF_Parameters_SET 
						--	@LangID					= @LangID,
						--	@idfsSection			= @idfsSectionNew, 
						--	@idfsFormType			= @idfsFormType,
						--	@idfsParameterType		= @idfsParameterType,
						--	@idfsEditor				= @idfsEditor,
						--	@intHACode				= @intHACode,
						--	@intOrder				= @intOrder,
						--	@strNote				= @strNote,
						--	@DefaultName			= @DefaultName,
						--	@NationalName			= @NationalName,
						--	@DefaultLongName		= @DefaultLongName,
						--	@NationalLongName		= @NationalLongName,
						--	@idfsParameter			= @idfsParameterNew,
						--	@idfsParameterCaption	= @idfsParameterCaption,
						--	@User					= @User,
						--	@intRowStatus			= 0,
						--	@CopyOnly				= 1

						--Create entry for the association of this new Section against the new Template
						--INSERT INTO @Supress_USP_ADMIN_FF_ParameterTemplate_SET
						EXEC USP_ADMIN_FF_ParameterTemplateForCopy_SET
							@LangID= @LangID,
							@idfsParameter = @idfsParameter, 
							@idfsFormTemplate = @idfsFormTemplateNew,
							@User = @User,
							@CopyOnly = 1,
							@FunctionCall = 1

						--Apply ordering settings
						UPDATE
							ffParameterDesignOption
						SET
							intOrder = @intOrder
						WHERE
							idfsFormTemplate = @idfsFormTemplateNew AND
							idfsParameter = @idfsParameter

						--Apply Edit Mode (Mandatory or Ordinary)
						UPDATE
							ffParameterForTemplate
						SET
							idfsEditMode = @idfsEditMode
						WHERE
							idfsFormTemplate = @idfsFormTemplateNew AND
							idfsParameter = @idfsParameter

						--Update the temporary table, to mark it as converted
						UPDATE
							@Parameters
						SET
							idfsParameterNew = @idfsParameter
						WHERE
							idfsParameter = @idfsParameter


						--Soft delete the old section, from the ffSection table
						--UPDATE 
						--	ffParameter
						--SET
						--	intRowStatus = 1
						--WHERE
						--	idfsParameter = @idfsParameter

					END
				----------------------------------------------------------------------------------------

				
				--Enumerate through all determinants that are related to the Template
				WHILE EXISTS (SELECT idfDeterminantValue FROM @Determinants)
					BEGIN
						--Grab the first items in the list
						SELECT
							TOP 1
							@idfDeterminantValue = idfDeterminantValue,
							@idfsBaseReference = idfsBaseReference
						FROM
							@Determinants

						INSERT INTO @SupressSelect
						EXEC dbo.USP_GBL_NEXTKEYID_GET 'ffDeterminantValue', @idfDeterminant OUTPUT;

						INSERT INTO dbo.ffDeterminantValue
						(
							  idfDeterminantValue,
							  idfsFormTemplate,
							  idfsBaseReference,
							  intRowStatus,
							  AuditCreateUser,
							  AuditCreateDTM,
							  SourceSystemNameID,
							  SourceSystemKeyValue
						)
						VALUES
						(@idfDeterminant,
						   @idfsFormTemplateNew,
						   @idfsBaseReference,
						   0,
						   @User,
						   GETDATE(),
						   10519001,
						   '[{"idfDeterminantValue":' + CAST(@idfDeterminant AS NVARCHAR(300)) + '}]'
						);

						--Disable, if a normal Flex Form Designer copy
						if @idfsNewFormType IS NULL
						   BEGIN
							  UPDATE
								  ffDeterminantValue
							  SET
								  intRowStatus = 1
							  WHERE
								  idfDeterminantValue = @idfDeterminantValue
						   END

						DELETE
						FROM
							@Determinants
						WHERE
							idfDeterminantValue = @idfDeterminantValue
					END

				----------------------------------------------------------------------------------------
				--Make a copy of each Rule															  --
				----------------------------------------------------------------------------------------
				WHILE EXISTS(SELECT TOP 1 idfsRule FROM @Rules WHERE idfsRuleNew IS NULL)
					BEGIN
						--Get another record that hasn't been converted yet
						SELECT
							TOP 1 @idfsRule = idfsRule
						FROM
							@Rules
						WHERE
							idfsRuleNew IS NULL

						--Reset @RuleDetailResults, so that it will only have one row at a time in it
						DELETE FROM @RuleDetailResults

						--Grab the details for the current Rule
						INSERT INTO @RuleDetailResults
						EXEC USP_ADMIN_FF_Rule_GetDetails @langid=@LangId, @idfsRule = @idfsRule

						SELECT
							@idfsRule = idfsRule,
							@DefaultRuleName = defaultRuleName,
							@NationalRuleName = RuleName,
							@DefaultRuleMessage = defaultRuleMessage,
							@NationalRuleMessage = RuleMessage,
							@idfsRuleMessage = idfsRuleMessage,
							@idfsCheckPoint = idfsCheckPoint,
							@idfsRuleFunction = idfsRuleFunction,
							@blnNot = blnNot,
							@idfsRuleAction = idfsRuleAction,
							@strActionParameters = strActionParameters,
							@idfsFunctionParameter = idfsFunctionParameter,
							@strFillValue = FillValue
						FROM
							@RuleDetailResults
						
						--Reset to grab a new id each iteration
						--SET @idfsRuleNew = -1

						--Create another Rule, based off of the details obtained from the previous step
						--INSERT INTO @SupressSelect
						EXEC dbo.USSP_GBL_BaseReference_SET @ReferenceID = @idfsRuleNew OUTPUT, @ReferenceType = 19000029, @LangId = @LangID, @DefaultName = @DefaultName, @NationalName = @NationalName, @System = 0

						INSERT INTO @SupressSelect
						EXEC dbo.USSP_GBL_BaseReference_SET @idfsRuleMessage OUTPUT, 19000032, @LangID, @MessageText, @MessageNationalText, 0
						
						--Create Global Reference for use by subsequential steps
						INSERT INTO @GlobalReference (idfs, idfsNew) VALUES (@idfsRule, @idfsRuleNew)

						--Reset the Action Parameters Table
						DELETE FROM @ActionParameters
						
						--Create table from string "Parameters" of the current rule details
						INSERT INTO @ActionParameters (idfsParameter)
						SELECT
							CAST(L.value AS BIGINT) AS idfsParameter
						FROM
							[dbo].[FN_GBL_SYS_SplitList](@strActionParameters, 0, ',') L

						--Get the conversion of the idfsParameter from its old value for the Function that the parameter is using.
						SELECT
							@idfsFunctionParameterNew = idfsNew
						FROM
							@GlobalReference
						WHERE
							idfs = @idfsFunctionParameter

						
						--Enumerate through all Action Parameters, that are associated with the rule
						WHILE EXISTS(SELECT idfsParameter FROM @ActionParameters)
							BEGIN
								SELECT 
									TOP 1 @idfsActionParameter = idfsParameter
								FROM
									@ActionParameters
									
								--Get the conversion of the idfsParameter from its old value for the Action that the parameter is using.
								SELECT
									@idfsActionParameterNew = idfsNew
								FROM
									@GlobalReference
								WHERE
									idfs = @idfsActionParameter

								--Create the copy of the existing Parameter
								--INSERT INTO @SupressSelect
								EXEC USP_ADMIN_FF_Rules_SET
									@idfsRule = @idfsRuleNew,
									@idfsFormTemplate = @idfsFormTemplateNew,
									@idfsCheckPoint = @idfsCheckPoint,
									@idfsRuleFunction = @idfsRuleFunction,
									@idfsRuleAction = @idfsRuleAction,
									@DefaultName = @DefaultName,
									@NationalName = @NationalName,
									@MessageText = @MessageText,
									@MessageNationalText = @MessageNationalText,
									@blnNot = @blnNot,
									@LangID = @LangID,
									@idfsRuleMessage = @idfsRuleMessage,
									@idfsFunctionParameter = @idfsFunctionParameterNew,
									@idfsActionParameter = @idfsActionParameterNew,
									@User = @User,
									@strFillValue = @strFillValue,
									@strCompareValue = @strCompareValue,
									@intRowStatus = 0,
									@FunctionCall = 1,
									@CopyOnly = 1

								DELETE FROM @ActionParameters WHERE idfsParameter = @idfsActionParameter
							END

						--Enumerate through all Constants, that are related to the Rule
						WHILE EXISTS(SELECT idfRuleConstant FROM @RuleConstants)
							BEGIN
								SELECT
									TOP 1
									@idfRuleConstant = idfRuleConstant,
									@idfsRule = idfsRule,
									@varConstant = varConstant
								FROM
									@RuleConstants

								--Get a new row id
								INSERT INTO @SupressSelect
								EXEC dbo.USP_GBL_NEXTKEYID_GET 'ffRuleConstant', @idfRuleConstantNew OUTPUT;

								--Get the newly created id for the old entry.
								SELECT
									@idfRuleConstantNew = idfsNew
								FROM
									@GlobalReference
								WHERE
									idfs = @idfRuleConstant

								--Get the newly created id for the old entry.
								SELECT
									@idfsRuleNew = idfsNew
								FROM
									@GlobalReference
								WHERE
									idfs = @idfsRuleNew

								--Create the new Record
								INSERT INTO ffRuleConstant (
									idfRuleConstant, 
									idfsRule, 
									varConstant, 
									intRowStatus,
									AuditCreateDTM,
									AuditCreateUser,
									SourceSystemNameID,
									SourceSystemKeyValue
								)
								VALUES (
									@idfRuleConstantNew,
									@idfsRuleNew,
									@varConstant,
									0,
									GETDATE(),
									@User,
									10519001,
									'[{"idfRuleConstant":13663030001100}]'
								)
								
								--Delete the top record so that continous looping doesn't occur to produce records over and over
								DELETE 
								FROM 
									@RuleConstants
								WHERE
									idfRuleConstant = @idfRuleConstant
							END
						
						--Update the temporary table, to mark it as converted
						UPDATE
							@Rules
						SET
							idfsRuleNew = @idfsRuleNew
						WHERE
							idfsRule = @idfsRule
						
						--Soft delete the old section, from the ffSection table
						UPDATE 
							ffRule
						SET
							intRowStatus = 1
						WHERE
							idfsRule= @idfsRule

					END
				----------------------------------------------------------------------------------------

				--USP_ADMIN_FF_Parameter_Copy
				--USP_ADMIN_FF_Section_Copy
				--SELECT * FROM @SectionsParameters
				--USP_ADMIN_FF_TemplateSectionOrder_Set
				--USP_ADMIN_FF_RequiredParameter_SET
				--USP_ADMIN_FF_ParameterDesignOptions_SET
				--USP_ADMIN_FF_Parameters_SET
				--USP_ADMIN_FF_ParameterFixedPresetValue_SET
				--USP_ADMIN_FF_ParameterTypes_SET
				--USP_ADMIN_FF_ParameterTemplate_SET
				--USP_ADMIN_FF_RuleConstant_SET
				--USP_ADMIN_FF_RuleParameterForAction_SET
				--USP_ADMIN_FF_RuleParameterForFunction_SET
				--USP_ADMIN_FF_Rules_SET
				--USP_ADMIN_FF_SectionDesignOptions_SET
				--USP_ADMIN_FF_Sections_SET
				--USP_ADMIN_FF_SectionTemplate_SET
				--USP_ADMIN_FF_SectionTemplateRecursive_SET ????????????????
				--USP_ADMIN_FF_Template_SET
				--USP_ADMIN_FF_TemplateDeterminantValues_SET
				--USP_ADMIN_FF_TemplateParameterOrder_Set
				--USP_ADMIN_FF_Determinant_SET

			--END
		
		--If any observations are made, then the following must be copied
		--select * from ffDeterminantValue where idfsFormTemplate = 9871670000000 

		IF @idfsFormTemplateNew IS NULL
			BEGIN
				SET @idfsFormTemplateNew = @idfsFormTemplate
			END

		SELECT	@returnCode as ReturnCode, @returnMsg as ReturnMessage, @idfsFormTemplateNew As idfsFormTemplate
	END TRY

	BEGIN CATCH

		SET @returnCode = ERROR_NUMBER();
		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();;

		throw;
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_FF_ParameterTemplate_SET]...';


GO
-- ================================================================================================
-- Name: USP_ADMIN_FF_ParameterTemplate_SET
-- Description: Save the Parameter Template
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru    11/28/2018	Initial release for new API.
-- Doug Albanese	4/3/2020	Changes to get it inline with the new designer
-- Doug Albanese	4/27/2020	Changes to correct errors with commit transaction
-- Doug Albanese	10/20/2020	Added Auditing information
-- Doug Albanese	01/19/2021	Added the psuedo function call parameter for use by other SPs
-- Mark Wilson		03/02/2022	Added the INSERT INTO @SuppressSelect, removed unneeded PRINT
--	Doug Albanese	06/02/2022	Remove the Suppress to allow functioncall = 0 to work correctly.
--	Doug Albanese	06/06/2022	Not sure how this was missed, but set the CopyOnly and FunctionCall to 0
--	Doug Albanese	06/07/2022	Rearranged the functioncall supression for USP_ADMIN_FF_ParameterDesignOptions_SET
--	Doug Albanese	06/10/2022	Corrected to prevent EF from blowing up the repository call for this SP
-- Doug Albanese	09/14/2022	 Further correction on USP_ADMIN_FF_ParameterDesignOptions_SET to remove supression for fucntion calling.
-- Doug Albanese	 10/06/2022	 Converted over to a API Call SP only, rather than being used from multiple locations
-- Doug Albanese	 05/31/2023	 Removed supression on USP_ADMIN_FF_ParameterDesignOptions_SET
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_FF_ParameterTemplate_SET] 
(
	@idfsParameter BIGINT
	,@idfsFormTemplate BIGINT
	,@LangID NVARCHAR(50) = NULL
	,@idfsEditMode BIGINT = NULL
	,@intLeft INT = NULL
	,@intTop INT = NULL
	,@intWidth INT = NULL
	,@intHeight INT = NULL
	,@intScheme INT = NULL
	,@intLabelSize INT = NULL
	,@intOrder INT = NULL
	,@blnFreeze BIT = NULL
	,@User NVARCHAR(50) = ''
	,@CopyOnly INT = 0
	,@FunctionCall INT = 0
)
AS
BEGIN
	SET NOCOUNT ON;	
	
	DECLARE 
		@returnCode BIGINT = 0,
		@returnMsg  NVARCHAR(MAX) = 'Success' 

	BEGIN TRY
		DECLARE @SupressSelect TABLE
		( 
			retrunCode INT,
			returnMsg NVARCHAR(200)
		)

		IF (@idfsEditMode IS NULL) SET @idfsEditMode = 10068001
		IF (@intLeft IS NULL) SET @intLeft = 0
		IF (@intTop IS NULL) SET @IntTop = 0
		IF (@intWidth IS NULL) SET @intWidth = 0
		IF (@intHeight IS NULL) SET @intHeight = 0
		IF (@intScheme IS NULL)	 SET @intScheme = 0
		IF (@blnFreeze IS NULL) SET @blnFreeze = 0
		
		IF (@intLabelSize IS NULL)
			BEGIN 
				IF (@intScheme = 0 OR @intScheme = 1)
					BEGIN
						SET @intLabelSize = @intWidth / 2
					END
			END
		ELSE
			BEGIN
				SET @intLabelSize = @intWidth
			END

		IF (@intOrder IS NULL) SET @intOrder = 0
			
		IF NOT EXISTS (SELECT TOP 1 1
					   FROM [dbo].[ffParameterForTemplate]
					   WHERE [idfsParameter] = @idfsParameter
							 AND [idfsFormTemplate] = @idfsFormTemplate)
			BEGIN
				INSERT INTO [dbo].[ffParameterForTemplate]
					(
           				[idfsParameter]
           				,[idfsFormTemplate]			  	   
						,[idfsEditMode]		
						,[blnFreeze]
						,AuditCreateDTM
						,AuditCreateUser
					)
				VALUES
					(
           				@idfsParameter
           				,@idfsFormTemplate
						,@idfsEditMode	
						,@blnFreeze	
						,GETDATE()
						,@User	
					)          
			END
		ELSE
			BEGIN
				UPDATE [dbo].[ffParameterForTemplate]
				SET [idfsEditMode] = @idfsEditMode
					,[blnFreeze] = @blnFreeze
					,[intRowStatus] = 0
					,AuditUpdateDTM = GETDATE()
					,AuditUpdateUser = @User
 				WHERE [idfsParameter] = @idfsParameter
					  AND [idfsFormTemplate] = @idfsFormTemplate 						
			END

			--INSERT INTO @SupressSelect
			EXEC dbo.[USP_ADMIN_FF_ParameterDesignOptions_SET] 
			   @idfsParameter
			   ,@idfsFormTemplate
			   ,@intLeft
			   ,@intTop
			   ,@intWidth
			   ,@intHeight			
			   ,@intScheme
			   ,@intLabelSize
			   ,@intOrder
			   ,@LangID
			   ,@User
			   ,1

		 SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage

	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_ORG_GETList]...';


GO
-- ================================================================================================
-- Name:USP_ADMIN_ORG_GETList
--
-- Description: Returns a list of organizations.
--          
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		06/09/2019 Created a temp table to store string query for POCO
-- Ricky Moss		06/14/2019 Added Organization Type ID
-- Ricky Moss		09/13/2019 Added AuditCreateDTM field for descending order
-- Ricky Moss		11/14/2019 Added paging paging parameters
-- Doug Albanese	11/19/2019 Corrected the HACode usage
-- Lamont Mitchell	04/13/2020 ADDED NULL Check for pagesize,maxpageperfetch and paginationset
-- Ricky Moss	    05/12/2020 Added Translated Values of name and full name
-- Mark Wilson		06/05/2020 used INTERSECT function to compare @intHACode with intHACode of org
-- Ricky Moss		06/15/2020 Used intOrder and strDefaut as original search fields
-- Doug Albanese	12/22/2020 Added idfsCountry for searching.	
-- Doug Albanese	02/01/2021 Corrected the use of NULL, in the where clause
-- Doug Albanese	02/08/2021 Changed the WHERE clause to detect filter searches properly.
-- Stephen Long     04/21/2021 Changed for updated pagination and location hierarchy.
-- Stephen Long     06/07/2021 Fixed address string to include additional fields for postal code, 
--                             street, building, apartment and house.
-- Stephen Long     06/24/2021 Added is null check on create address string.
-- Stephen Long     06/30/2021 Fix to order by column name on abbreviated and full names.
-- Stephen Long     08/03/2021 Added default sort order by order then organization full name; 
--                             national or default.
-- Leo Tracchia		08/17/2021 Changed intHACode to pull from tlbOffice	
-- Stephen Long     10/15/2021 Fix on total pages calculation.
-- Stephen Long     12/06/2021 Changed over to location hierarchy flattened for admin levels.
-- Stephen Long     03/14/2022 Changed over to pull from institution repair function to match 
--                             organization lookup procedure.
-- Stephen Long     05/05/2023 Correction to use proper joins on abbreviated and full names.
-- Stephen Long     05/25/2023 Fixed location hierarchy joins.
--
-- Testing Code:
-- EXEC USP_ADMIN_ORG_GETList 'en', null, null, null, null, 2, null, null, null, 1, 10
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_ORG_GETList]
(
    @LanguageID NVARCHAR(50),
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'Order',
    @SortOrder NVARCHAR(4) = 'ASC',
    @OrganizationKey BIGINT = NULL,
    @OrganizationID NVARCHAR(100) = NULL,
    @AbbreviatedName NVARCHAR(100) = NULL,
    @FullName NVARCHAR(100) = NULL,
    @AccessoryCode INT = NULL,
    @SiteID BIGINT = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @OrganizationTypeID BIGINT = NULL,
    @ShowForeignOrganizationsIndicator BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @AdministrativeLevelNode AS HIERARCHYID,
                @firstRec INT = (@PageNumber - 1) * @PageSize,
                @lastRec INT = (@PageNumber * @PageSize + 1),
                @TotalRowCount INT = (
                                         SELECT COUNT(*) FROM dbo.tlbOffice WHERE intRowStatus = 0
                                     ), 
                @LanguageCode AS BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID);

        SELECT OrganizationKey,
               OrganizationID,
               AbbreviatedName,
               FullName,
               [Order],
               AddressString,
               OrganizationTypeName,
               AccessoryCode,
               SiteID,
               RowStatus,
               [RowCount],
               TotalRowCount,
               CurrentPage,
               TotalPages
        FROM
        (
            SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'AbbreviatedName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ISNULL(abbreviatedName.name, abbreviatedName.strDefault)
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AbbreviatedName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ISNULL(abbreviatedName.name, abbreviatedName.strDefault)
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'FullName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ISNULL(fullName.name, fullName.strDefault)
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'FullName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ISNULL(fullName.name, fullName.strDefault)
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'OrganizationID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       o.strOrganizationID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'OrganizationID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       o.strOrganizationID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AddressString'
                                                        AND @SortOrder = 'ASC' THEN
                                                       dbo.FN_GBL_CreateAddressString(
                                                                                         ISNULL(g.Level1Name, ''),
                                                                                         ISNULL(g.Level2Name, ''),
                                                                                         ISNULL(g.Level3Name, ''),
                                                                                         ISNULL(gls.strPostCode, ''),
                                                                                         '',
                                                                                         '',
                                                                                         ISNULL(gls.strStreetName, ''),
                                                                                         ISNULL(gls.strHouse, ''),
                                                                                         ISNULL(gls.strBuilding, ''),
                                                                                         ISNULL(gls.strApartment, ''),
                                                                                         gls.blnForeignAddress,
                                                                                         ISNULL(
                                                                                                   gls.strForeignAddress,
                                                                                                   ''
                                                                                               )
                                                                                     )
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AddressString'
                                                        AND @SortOrder = 'DESC' THEN
                                                       dbo.FN_GBL_CreateAddressString(
                                                                                         ISNULL(g.Level1Name, ''),
                                                                                         ISNULL(g.Level2Name, ''),
                                                                                         ISNULL(g.Level3Name, ''),
                                                                                         ISNULL(gls.strPostCode, ''),
                                                                                         '',
                                                                                         '',
                                                                                         ISNULL(gls.strStreetName, ''),
                                                                                         ISNULL(gls.strHouse, ''),
                                                                                         ISNULL(gls.strBuilding, ''),
                                                                                         ISNULL(gls.strApartment, ''),
                                                                                         gls.blnForeignAddress,
                                                                                         ISNULL(
                                                                                                   gls.strForeignAddress,
                                                                                                   ''
                                                                                               )
                                                                                     )
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'OrganizationTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       organizationType.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'OrganizationTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       organizationType.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'Order'
                                                        AND @SortOrder = 'ASC' THEN
                                                       abbreviatedName.intOrder
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'Order'
                                                        AND @SortOrder = 'DESC' THEN
                                                       abbreviatedName.intOrder
                                               END DESC,
                                               IIF(@SortColumn = 'Order',
                                                   ISNULL(abbreviatedName.name, abbreviatedName.strDefault),
                                                   NULL) ASC
                                     ) AS RowNum,
                   o.idfOffice AS OrganizationKey,
                   o.strOrganizationID AS OrganizationID,
                   abbreviatedName.name AS AbbreviatedName,
                   fullName.name AS FullName,
                   abbreviatedName.intOrder AS [Order],
                   dbo.FN_GBL_CreateAddressString(
                                                     ISNULL(g.Level1Name, ''),
                                                     ISNULL(g.Level2Name, ''),
                                                     ISNULL(g.Level3Name, ''),
                                                     ISNULL(gls.strPostCode, ''),
                                                     '',
                                                     '',
                                                     ISNULL(gls.strStreetName, ''),
                                                     ISNULL(gls.strHouse, ''),
                                                     ISNULL(gls.strBuilding, ''),
                                                     ISNULL(gls.strApartment, ''),
                                                     gls.blnForeignAddress,
                                                     ISNULL(gls.strForeignAddress, '')
                                                 ) AS AddressString,
                   organizationType.name AS OrganizationTypeName,
                   o.intHACode AS AccessoryCode,
                   o.idfsSite AS SiteID,
                   o.intRowStatus AS RowStatus,
                   COUNT(*) OVER () AS [RowCount],
                   @TotalRowCount AS TotalRowCount,
                   CurrentPage = @PageNumber,
                   TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
            FROM dbo.tlbOffice o
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000046) fullName
                    ON fullName.idfsReference = o.idfsOfficeName
                       AND fullName.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000045) abbreviatedName
                    ON abbreviatedName.idfsReference = o.idfsOfficeAbbreviation
                       AND abbreviatedName.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocationShared gls
                    ON o.idfLocation = gls.idfGeoLocationShared
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = gls.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000504) organizationType
                    ON o.OrganizationTypeID = organizationType.idfsReference
            WHERE o.intRowStatus = 0
                  AND (
                          o.idfOffice = @OrganizationKey
                          OR @OrganizationKey IS NULL
                      )
                  AND (
                          o.strOrganizationID LIKE '%' + @OrganizationID + '%'
                          OR @OrganizationID IS NULL
                      )
                  AND (
                          (
                              abbreviatedName.strDefault LIKE '%' + @AbbreviatedName + '%'
                              OR abbreviatedName.name LIKE '%' + @AbbreviatedName + '%'
                          )
                          OR @AbbreviatedName IS NULL
                      )
                  AND (
                          (
                              fullName.strDefault LIKE '%' + @FullName + '%'
                              OR fullName.name LIKE '%' + @FullName + '%'
                          )
                          OR @FullName IS NULL
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
                  AND EXISTS
            (
                SELECT *
                FROM dbo.FN_GBL_SplitHACode(@AccessoryCode, 510)
                INTERSECT
                SELECT *
                FROM dbo.FN_GBL_SplitHACode(ISNULL(o.intHACode, 1), 510)
            )
                  AND (
                          o.idfsSite = @SiteID
                          OR @SiteID IS NULL
                      )
                  AND (
                          organizationType.idfsReference = @OrganizationTypeID
                          OR @OrganizationTypeID IS NULL
                      )
                  AND gls.blnForeignAddress = @ShowForeignOrganizationsIndicator
            GROUP BY o.idfOffice,
                     o.idfsSite,
                     o.intRowStatus,
                     abbreviatedName.intOrder,
                     o.intHACode,
                     abbreviatedName.strDefault,
                     fullName.strDefault,
                     abbreviatedName.name,
                     fullName.name,
                     o.strOrganizationID,
                     organizationType.name,
                     g.Level1Name,
                     g.Level2Name,
                     g.Level3Name,
                     gls.strApartment,
                     gls.blnForeignAddress,
                     gls.strForeignAddress,
                     gls.strBuilding,
                     gls.strHouse,
                     gls.strStreetName,
                     gls.strPostCode
        ) AS x
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec
        ORDER BY RowNum;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
GO
PRINT N'Altering Procedure [dbo].[USP_CONF_TESTTOTESTRESULTMATRIX_SET]...';


GO
-- ================================================================================================
-- Name: USP_CONF_TESTTOTESTRESULTMATRIX_SET
--
-- Description:	Creates a test to test result matrix
--                      
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		03/11/2018 Initial release.
-- Stephen Long     07/13/2022 Added site alert logic.
--
-- exec USP_CONF_TESTTOTESTRESULTMATRIX_SET 803960000000, '807830000000, 807990000000, 808040000000', 0
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_CONF_TESTTOTESTRESULTMATRIX_SET]
(
    @idfsTestResultRelation BIGINT,
    @idfsTestName BIGINT,
    @idfsTestResult BIGINT,
    @blnIndicative BIT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @ReturnCode BIGINT = 0,
        @EventId BIGINT = -1,
        @EventSiteId BIGINT = @SiteId,
        @EventUserId BIGINT = @UserId,
        @EventDiseaseId BIGINT = NULL,
        @EventLocationId BIGINT = @LocationId,
        @EventInformationString NVARCHAR(MAX) = NULL,
        @EventLoginSiteId BIGINT = @SiteId;
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);
Declare @isAvail bit

--Data Audit--
BEGIN
declare @idfUserId BIGINT =NULL;
declare @idfSiteId BIGINT = NULL;
declare @idfsDataAuditEventType bigint =NULL;
declare @idfsObjectType bigint = 10017055;
declare @idfObject bigint = NULL;
declare @idfObjectTable_tlbTestMatrix bigint = 76020000000;
declare @idfDataAuditEvent bigint= NULL; 

DECLARE @tlbTestMatrix_BeforeEdit TABLE
(
	blnIndicative BIT,
	idfsTestResult BIGINT,
	idfsTestName BIGINT,
	intRowStatus INT
)
DECLARE @tlbTestMatrix_AfterEdit TABLE
(
	blnIndicative BIT,
	idfsTestResult BIGINT,
	idfsTestName BIGINT,
	intRowStatus INT
)

-- Get and Set UserId and SiteId
select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation(@AuditUserName) userInfo
END

BEGIN
    BEGIN TRY 
        IF @idfsTestResultRelation = 19000097
        BEGIN 
            IF NOT EXISTS
            (
                SELECT idfsTestResult
                FROM dbo.trtTestTypeToTestResult
                WHERE idfsTestResult = @idfsTestResult
                      AND idfsTestName = @idfsTestName
            )
            BEGIN
                INSERT INTO dbo.trtTestTypeToTestResult
                (
                    idfsTestName,
                    idfsTestResult,
                    blnIndicative,
                    intRowStatus,
                    AuditCreateDTM,
                    AuditCreateUser
                )
                VALUES
                (@idfsTestName, @idfsTestResult, @blnIndicative, 0, GETDATE(), @AuditUserName);
				
				--Data Audit--
				-- tauDataAuditEvent Event Type - Create 
				set @idfObject = @idfsTestName;
				set @idfObjectTable_tlbTestMatrix =76020000000;
				set @idfsDataAuditEventType =10016001;
						-- insert record into tauDataAuditEvent - 
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbTestMatrix, @idfDataAuditEvent OUTPUT

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
					values ( @idfDataAuditEvent, @idfObjectTable_tlbTestMatrix, @idfObject)
				--Data Audit--
            END
            ELSE IF EXISTS
            (
                SELECT idfsTestResult
                FROM dbo.trtTestTypeToTestResult
                WHERE idfsTestResult = @idfsTestResult
                      AND idfsTestName = @idfsTestName
            )
            BEGIN 		
                SET @isAvail = (SELECT count(*)
                FROM dbo.trtTestTypeToTestResult
                WHERE idfsTestResult = @idfsTestResult
                      AND idfsTestName = @idfsTestName
					  AND intRowStatus = 0
					  AND blnIndicative = @blnIndicative) 

				insert into @tlbTestMatrix_BeforeEdit (idfsTestName, idfsTestResult, blnIndicative, intRowStatus)
				select idfsTestName, idfsTestResult, blnIndicative, intRowStatus 
					from trtTestTypeToTestResult WHERE idfsTestResult = @idfsTestResult AND idfsTestName = @idfsTestName

                UPDATE dbo.trtTestTypeToTestResult
                SET intRowStatus = 0,
                    blnIndicative = @blnIndicative,
                    AuditUpdateDTM = GETDATE(), 
                    AuditUpdateUser = @AuditUserName
                WHERE idfsTestResult = @idfsTestResult
                      AND idfsTestName = @idfsTestName;
				insert into @tlbTestMatrix_AfterEdit (idfsTestName, idfsTestResult, blnIndicative, intRowStatus)
				select idfsTestName, idfsTestResult, blnIndicative, intRowStatus 
					from trtTestTypeToTestResult WHERE idfsTestResult = @idfsTestResult AND idfsTestName = @idfsTestName
					
				set @ReturnCode = 6
				set @ReturnMessage = Case When @isAvail = 0 Then 'SUCCESS' Else 'EXISTS' End

				--DataAudit-- 
				insert into @tlbTestMatrix_AfterEdit (idfsTestName, idfsTestResult, blnIndicative, intRowStatus)
				select idfsTestName, idfsTestResult, blnIndicative, intRowStatus 
					from trtTestTypeToTestResult WHERE idfsTestResult = @idfsTestResult AND idfsTestName = @idfsTestName

				IF EXISTS 
				(
					select *
					from @tlbTestMatrix_BeforeEdit a  inner join @tlbTestMatrix_AfterEdit b on a.idfsTestResult = b.idfsTestResult and a.idfsTestName = b.idfsTestName 
					where (ISNULL(a.blnIndicative,'') <> ISNULL(b.blnIndicative,'')) OR (ISNULL(a.intRowStatus,'') <> ISNULL(b.intRowStatus,''))
				)
				BEGIN
					--  tauDataAuditEvent  Event Type- Edit 
					set @idfsDataAuditEventType = 10016003;
					Set @idfObject = @idfsTestName
					-- insert record into tauDataAuditEvent - 
					INSERT INTO @SuppressSelect
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbTestMatrix, @idfDataAuditEvent OUTPUT

					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, idfObjectTable, idfColumn, 
						idfObject, idfObjectDetail, 
						strOldValue, strNewValue)
					select @idfDataAuditEvent,@idfObjectTable_tlbTestMatrix, 4578170000000,
						@idfObject,null,
						a.blnIndicative,b.blnIndicative 
					from @tlbTestMatrix_BeforeEdit a  inner join @tlbTestMatrix_AfterEdit b on a.idfsTestResult = b.idfsTestResult and a.idfsTestName = b.idfsTestName 
					where (ISNULL(a.blnIndicative,'') <> ISNULL(b.blnIndicative,''))  
				END

            END
        END
        ELSE
        BEGIN		
            --creates new test for disease
            IF NOT EXISTS
            (
                SELECT idfsPensideTestResult
                FROM dbo.trtPensideTestTypeToTestResult
                WHERE idfsPensideTestResult = @idfsTestResult
                      AND idfsPensideTestName = @idfsTestName
            )
            BEGIN	 
                INSERT INTO dbo.trtPensideTestTypeToTestResult
                (
                    idfsPensideTestName,
                    idfsPensideTestResult,
                    blnIndicative,
                    intRowStatus,
                    AuditCreateDTM,
                    AuditCreateUser
                )
                VALUES
                (@idfsTestName, @idfsTestResult, @blnIndicative, 0, GETDATE(), @AuditUserName);

				--Data Audit--
				-- tauDataAuditEvent Event Type - Create 
				set @idfObject = @idfsTestName;
				set @idfObjectTable_tlbTestMatrix =75910000000;
				set @idfsDataAuditEventType =10016001;
						-- insert record into tauDataAuditEvent - 
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbTestMatrix, @idfDataAuditEvent OUTPUT

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
					values ( @idfDataAuditEvent, @idfObjectTable_tlbTestMatrix, @idfObject)
				--Data Audit--
            END
            ELSE IF EXISTS
            (
                SELECT idfsPensideTestResult
                FROM dbo.trtPensideTestTypeToTestResult
                WHERE idfsPensideTestResult = @idfsTestResult
                      AND idfsPensideTestName = @idfsTestName
            )
            BEGIN		
                SET @isAvail = (SELECT count(*)
                FROM dbo.trtPensideTestTypeToTestResult
                WHERE idfsPensideTestResult = @idfsTestResult
                      AND idfsPensideTestName = @idfsTestName
					  AND intRowStatus = 0
					  AND blnIndicative = @blnIndicative) 
			
				insert into @tlbTestMatrix_BeforeEdit (idfsTestName, idfsTestResult, blnIndicative, intRowStatus)
				select idfsPensideTestName, idfsPensideTestResult, blnIndicative, intRowStatus 
					from trtPensideTestTypeToTestResult WHERE idfsPensideTestResult = @idfsTestResult AND idfsPensideTestName = @idfsTestName
		 
                UPDATE dbo.trtPensideTestTypeToTestResult
                SET intRowStatus = 0,
                    blnIndicative = @blnIndicative, 
                    AuditUpdateDTM = GETDATE(), 
                    AuditUpdateUser = @AuditUserName 
                WHERE idfsPensideTestResult = @idfsTestResult
                      AND idfsPensideTestName = @idfsTestName;

				set @ReturnCode = 6
				set @ReturnMessage = Case When @isAvail = 0 Then 'SUCCESS' Else 'EXISTS' End
			 
				insert into @tlbTestMatrix_AfterEdit (idfsTestName, idfsTestResult, blnIndicative, intRowStatus)
				select idfsPensideTestName, idfsPensideTestResult, blnIndicative, intRowStatus 
					from trtPensideTestTypeToTestResult WHERE idfsPensideTestResult = @idfsTestResult AND idfsPensideTestName = @idfsTestName

				--DataAudit-- 
				IF EXISTS 
				(
					select *
					from @tlbTestMatrix_BeforeEdit a  inner join @tlbTestMatrix_AfterEdit b on a.idfsTestResult = b.idfsTestResult and a.idfsTestName = b.idfsTestName 
					where (ISNULL(a.blnIndicative,'') <> ISNULL(b.blnIndicative,'')) OR (ISNULL(a.intRowStatus,'') <> ISNULL(b.intRowStatus,''))
				)
				BEGIN
					--  tauDataAuditEvent  Event Type- Edit 
					set @idfsDataAuditEventType = 10016003;
					Set @idfObject = @idfsTestName
					-- insert record into tauDataAuditEvent - 
					INSERT INTO @SuppressSelect
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbTestMatrix, @idfDataAuditEvent OUTPUT

					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, idfObjectTable, idfColumn, 
						idfObject, idfObjectDetail, 
						strOldValue, strNewValue)
					select @idfDataAuditEvent,@idfObjectTable_tlbTestMatrix, 4578170000000,
						@idfObject,null,
						a.blnIndicative,b.blnIndicative 
					from @tlbTestMatrix_BeforeEdit a  inner join @tlbTestMatrix_AfterEdit b on a.idfsTestResult = b.idfsTestResult and a.idfsTestName = b.idfsTestName 
					where (ISNULL(a.blnIndicative,'') <> ISNULL(b.blnIndicative,''))  
				END
            END
        END

        INSERT INTO @SuppressSelect 
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfsTestName,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfsTestName AS 'idfsTestName';
    END TRY
    BEGIN CATCH
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
				ISNULL((SELECT TOP 1 ISNULL(sg.strTextString, brg.strDefault)FROM trtDiagnosisToDiagnosisGroup dg
				INNER Join dbo.trtBaseReference brg ON dg.idfsDiagnosisGroup = brg.idfsBaseReference
				LEFT JOIN dbo.trtStringNameTranslation AS sg ON brg.idfsBaseReference = sg.idfsBaseReference AND sg.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LangID)
				WHERE dg.idfsDiagnosis = br.idfsBaseReference AND brg.strDefault IS NOT NULL),'Not Defined')
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
PRINT N'Altering Procedure [dbo].[USP_HAS_MONITORING_SESSION_GETList]...';


GO
-- ================================================================================================
-- Name: USP_HAS_MONITORING_SESSION_GETList
--
-- Description: Gets a list of human monitoring sessions based on search criteria provided.
--                      
-- Revision History:
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long		12/31/2018 Initial release.
-- Stephen Long		07/06/2019 Fixed category code, and added campaign ID.
-- Stephen Long		01/26/2020 Added site list parameter for site filtration.
-- Stephen Long		02/24/2020 Added non-configurable site filtration rules.
-- Stephen Long		03/25/2020 Added if/else for first-level and second-level site types to 
--                             bypass non-configurable rules.
-- Stephen Long		04/20/2020 Changed join from FN_GBL_INSTITUTION to tstSite as not all sites 
--                             have organizations.
-- Stephen Long		05/18/2020 Added disease filtration rules from use case SAUC62.
-- Stephen Long		06/18/2020 Added where criteria to the query when no site filtration is 
--                             required.
-- Stephen Long		07/07/2020 Added trim to EIDSS identifier like criteria.
-- Stephen Long		11/18/2020 Added site ID to the query.
-- Stephen Long		11/27/2020 Added configurable site filtration rules.
-- Stephen Long		12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long		12/24/2020 Modified join on disease filtration default role rule.
-- Stephen Long		12/29/2020 Changed function call on reference data for inactive records.
-- Stephen Long		04/04/2021 Added updated pagination and location hierarchy.
-- Mark Wilson		08/18/2021 joined tlbMonitoringSessionToDiagnosis to get disease
-- Doug Albanese	11/23/2021 Refactored for use with new HAS module
-- Stephen Long     01/26/2022 Added the disease identifiers and names fields to the query.
-- Doug Albanese	01/27/2022 Completely removed "node" searches and put in full hierarchy 
--                             location joins
-- Stephen Long     03/29/2022 Fix to site filtration to pull back a user's own site records.
-- Doug Albanese	03/30/2022 Refactored to align with Stephen's changes to combine Diseases into 
--                             one row.
-- Doug Albanese	04/01/2022 Creating HAS's on the first o a month exposed an incorrect BETWEEN 
--                             statement use. Adding one day to ending date.
-- Doug Albanese	05/16/2022 Added Admin Level 4 for return of Settlement in Campaign's use
-- Stephen Long     06/03/2022 Updated to point default access rules to base reference.
-- Mike Kornegay	06/14/2022 Fixed filtration rule that was pointing to SessionCategoryID for vet
--                             instead of human.
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Stephen Long     01/09/2023 Updated for site filtration queries.
-- Stephen Long     05/23/2023 Fix on location hierarchy for default filtration rules.
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_HAS_MONITORING_SESSION_GETList]
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

    DECLARE @FiltrationSiteAdministrativeLevelID AS BIGINT,
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
                LEFT JOIN dbo.tlbCampaign c
                    ON c.idfCampaign = ms.idfCampaign
                       AND c.intRowStatus = 0
                INNER JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = ms.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
            WHERE ms.intRowStatus = 0
                  AND ms.SessionCategoryID = 10502001 -- Human Active Surveillance Session
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
                          (ms.datEnteredDate
                  BETWEEN @DateEnteredFrom AND DATEADD(DAY, 1, @DateEnteredTo)
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
                      );
        END
        ELSE
        BEGIN
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
                LEFT JOIN dbo.tlbCampaign c
                    ON c.idfCampaign = ms.idfCampaign
                       AND c.intRowStatus = 0
                INNER JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = ms.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
            WHERE ms.intRowStatus = 0
                  AND ms.idfsSite = @UserSiteID
                  AND ms.SessionCategoryID = 10502001 -- Human Active Surveillance Session
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
                          (ms.datEnteredDate
                  BETWEEN @DateEnteredFrom AND DATEADD(DAY, 1, @DateEnteredTo)
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
                      );

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
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID = 10502001 -- Human Active Surveillance Session
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
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID = 10502001 -- Human Active Surveillance Session
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
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID = 10502001 -- Human Active Surveillance Session
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
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID = 10502001 -- Human Active Surveillance Session
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
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID = 10502001 -- Human Active Surveillance Session
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
            WHERE ms.intRowStatus = 0
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
            WHERE ms.intRowStatus = 0
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
            WHERE ms.intRowStatus = 0
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
            WHERE ms.intRowStatus = 0
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
            WHERE ms.intRowStatus = 0
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
            WHERE ms.intRowStatus = 0
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
            WHERE ms.intRowStatus = 0
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
            WHERE ms.intRowStatus = 0
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
                INNER JOIN dbo.tlbMonitoringSession ms
                    ON ms.idfMonitoringSession = ID
                INNER JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                    ON msd.idfMonitoringSession = ms.idfMonitoringSession
                       AND msd.intRowStatus = 0
                LEFT JOIN dbo.tlbCampaign c
                    ON c.idfCampaign = ms.idfCampaign
                       AND c.intRowStatus = 0
                INNER JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = ms.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
            WHERE ms.SessionCategoryID = 10502001 -- Human Active Surveillance Session
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
                          (ms.datEnteredDate
                  BETWEEN @DateEnteredFrom AND DATEADD(DAY, 1, @DateEnteredTo)
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 AND @DateEnteredTo IS NULL
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
              AND ms.intRowStatus = 0
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
              AND ms.intRowStatus = 0
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
            INNER JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                   AND msd.intRowStatus = 0
            LEFT JOIN dbo.tlbCampaign c
                ON c.idfCampaign = ms.idfCampaign
                   AND c.intRowStatus = 0
            INNER JOIN dbo.gisLocationDenormalized g
                ON g.idfsLocation = ms.idfsLocation
                   AND g.idfsLanguage = @LanguageCode
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
              AND ms.SessionCategoryID = 10502001 -- Human Active Surveillance Session
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
                      (ms.datEnteredDate
              BETWEEN @DateEnteredFrom AND DATEADD(DAY, 1, @DateEnteredTo)
                      )
                      OR (
                             @DateEnteredFrom IS NULL
                             AND @DateEnteredTo IS NULL
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
        GROUP BY ID;

        WITH paging
        AS (SELECT ID,
                   c = COUNT(*) OVER ()
            FROM @FinalResults res
                INNER JOIN dbo.tlbMonitoringSession ms
                    ON ms.idfMonitoringSession = res.ID
                INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = ms.idfsLocation
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000117) sessionStatus
                    ON sessionStatus.idfsReference = ms.idfsMonitoringSessionStatus
            ORDER BY CASE
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
                             lh.AdminLevel1Name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'AdministrativeLevel1Name'
                              AND @SortOrder = 'DESC' THEN
                             lh.AdminLevel1Name
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'AdministrativeLevel2Name'
                              AND @SortOrder = 'ASC' THEN
                             lh.AdminLevel2Name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'AdministrativeLevel2Name'
                              AND @SortOrder = 'DESC' THEN
                             lh.AdminLevel2Name
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'AdministrativeLevel3Name'
                              AND @SortOrder = 'ASC' THEN
                             lh.AdminLevel2Name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'AdministrativeLevel3Name'
                              AND @SortOrder = 'DESC' THEN
                             lh.AdminLevel2Name
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'AdministrativeLevel4Name'
                              AND @SortOrder = 'ASC' THEN
                             lh.AdminLevel2Name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'AdministrativeLevel4Name'
                              AND @SortOrder = 'DESC' THEN
                             lh.AdminLevel2Name
                     END DESC OFFSET @PageSize * (@PageNumber - 1) ROWS FETCH NEXT @PageSize ROWS ONLY
           )
        SELECT res.ID AS SessionKey,
               ms.strMonitoringSessionID AS SessionID,
               ms.idfCampaign AS CampaignKey,
               c.strCampaignID AS CampaignID,
               sessionStatus.name AS SessionStatusTypeName,
               ms.datStartDate AS StartDate,
               ms.datEndDate AS EndDate,
               diseaseIDs.diseaseIDs AS DiseaseIdentifiers,
               diseaseNames.diseaseNames AS DiseaseNames,
               lh.AdminLevel1Name AS AdministrativeLevel1Name,
               lh.AdminLevel2Name AS AdministrativeLevel2Name,
               lh.AdminLevel3Name AS AdministrativeLevel3Name,
               lh.AdminLevel4Name AS AdministrativeLevel4Name,
               ms.datEnteredDate AS EnteredDate,
               ISNULL(p.strFirstName, '') + ' ' + ISNULL(p.strFamilyName, '') AS EnteredByPersonName,
               ms.idfsSite AS SiteKey,
               siteName.strSiteName AS SiteName,
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
               c AS RecordCount,
               (
                   SELECT COUNT(*)
                   FROM dbo.tlbMonitoringSession
                   WHERE intRowStatus = 0
                         AND SessionCategoryID = 10502001 -- Human Active Surveillance Session
               ) AS TotalCount,
               CurrentPage = @PageNumber,
               TotalPages = (c / @PageSize) + IIF(c % @PageSize > 0, 1, 0)
        FROM @FinalResults res
            INNER JOIN paging
                ON paging.ID = res.ID
            INNER JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = paging.ID
            CROSS APPLY
        (
            SELECT dbo.FN_GBL_SESSION_DISEASEIDS_GET(ms.idfMonitoringSession) diseaseIDs
        ) diseaseIDs
            CROSS APPLY
        (
            SELECT dbo.FN_GBL_SESSION_DISEASE_NAMES_GET(ms.idfMonitoringSession, @LanguageID) diseaseNames
        ) diseaseNames
            INNER JOIN dbo.tstSite siteName
                ON siteName.idfsSite = ms.idfsSite
            LEFT JOIN dbo.tlbCampaign c
                ON c.idfCampaign = ms.idfCampaign
                   AND c.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000117) sessionStatus
                ON sessionStatus.idfsReference = ms.idfsMonitoringSessionStatus
            INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                ON lh.idfsLocation = ms.idfsLocation
            LEFT JOIN dbo.tlbPerson p
                ON p.idfPerson = ms.idfPersonEnteredBy;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
GO
PRINT N'Creating Procedure [dbo].[USP_HUM_DISEASE_REPORT_GETList_original]...';


GO

-- ================================================================================================
-- Name: USP_HUM_DISEASE_REPORT_GETList_original
--
-- Description: Get a list of human disease reports for the human module.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mandar Kulkarni             Initial release.
-- Stephen Long     03/26/2018 Added the person reported by name for the farm use case.
-- JWJ	            04/17/2018 Added extra col to return:  tlbHuman.idfHumanActual. Added alias 
--                             for region rayon to make them unique in results added report status 
--                             to results 
-- Harold Pryor     10/22/2018 Added input search parameters SearchStrPersonFirstName, 
--                             SearchStrPersonMiddleName, and SearchStrPersonLastName
-- Harold Pryor     10/31/2018 Added input search parameters SearchLegacyCaseID and	
--                             added strLocation (region, rayon) field to list result set
-- Harold Pryor     11/12/2018 Changed @SearchLegacyCaseID parameter from BIGINT to NVARCHAR(200)
-- Stephen Long     12/19/2018 Added pagination logic.
-- Stephen Long     07/07/2019 Added monitoring session ID to parameters and where clause.
-- Stephen Long     07/10/2019 Changed address join from exposure location to patient's current 
--                             residence address.
-- Stephen Long     07/19/2019 Corrected patient name and person entered by name ', '.
-- Stephen Long     02/26/2020 Added non-configurable site filtration rules.
-- Lamont Mitchell  03/03/2020 Modified all joins on human case and human to join on human actual.
-- Stephen Long     04/01/2020 Added if/else for first-level and second-level site types to bypass 
--                             non-configurable rules.
-- Stephen Long     05/18/2020 Added disease filtration rules from use case SAUC62.
-- Stephen Long     06/18/2020 Corrected the join on the rayon of the report current residence 
--                             address (human ID to human ID instead of human ID to human actual 
--                             ID).
-- Stephen Long     06/18/2020 Added where criteria to the query when no site filtration is 
--                             required.
-- Stephen Long     07/07/2020 Added trim to EIDSS identifier like criteria.
-- Doug Albanese	11/16/2020 Added Outbreak Tied filtering
-- Stephen Long     11/18/2020 Added site ID to the query.
-- Stephen Long     11/28/2020 Added configurable site filtration rules.
-- Stephen Long     12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long     12/24/2020 Modified join on disease filtration default role rule.
-- Stephen Long     12/29/2020 Changed function call on reference data for inactive records.
-- Stephen Long     01/04/2020 Added option recompile due to number of optional parameters for 
--                             better execution plan.
-- Stephen Long     04/04/2021 Added updated pagination and location hierarchy.
-- Mike Kornegay	09/23/2021 Added HospitalizationStatus field
-- Stephen Long     11/03/2021 Added disease ID field.
-- Mike Kornegay	11/16/2021 Fix hospitalization field for translations
-- Mike Kornegay	12/07/2021 Added back EnteredByPersonName 
-- Mike Kornegay	12/08/2021 Swapped out FN_GBL_GIS_ReferenceRepair for new flat hierarchy
-- Mike Kornegay	12/23/2021 Fixed YN hospitalization where clause
-- Manickandan Govindarajan 03/21/2022  Rename Param PageNumber to Page
-- Stephen Long     03/29/2022 Fix to site filtration to pull back a user's own site records.
-- Stephen Long     06/03/2022 Updated to point default access rules to base reference.
-- Mike Kornegay    06/06/2022 Added parameter OutcomeID.
-- Mike Kornegay	06/13/2022 Changed inner joins to left joins in final query because result set 
--                             was incorrect.
-- Stephen Long     08/14/2022 Added additional criteria for outbreak cases for laboratory module.
--                             TODO: replace filter outbreak cases parameter, and just filter in 
--                             the initial query to avoid getting extra unneeded records; also just 
--                             make it a boolean value.
--
-- Testing code:
-- EXEC USP_HUM_DISEASE_REPORT_GETList_original 'en'
-- EXEC USP_HUM_DISEASE_REPORT_GETList_original 'en', @EIDSSReportID = 'H'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HUM_DISEASE_REPORT_GETList_original]
    @LanguageID NVARCHAR(50),
    @ReportKey BIGINT = NULL,
    @ReportID NVARCHAR(200) = NULL,
    @LegacyReportID NVARCHAR(200) = NULL,
    @SessionKey BIGINT = NULL,
    @PatientID BIGINT = NULL,
    @PersonID NVARCHAR(200) = NULL,
    @DiseaseID BIGINT = NULL,
    @ReportStatusTypeID BIGINT = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @DateEnteredFrom DATETIME = NULL,
    @DateEnteredTo DATETIME = NULL,
    @ClassificationTypeID BIGINT = NULL,
    @HospitalizationYNID BIGINT = NULL,
    @PatientFirstName NVARCHAR(200) = NULL,
    @PatientMiddleName NVARCHAR(200) = NULL,
    @PatientLastName NVARCHAR(200) = NULL,
    @SentByFacilityID BIGINT = NULL,
    @ReceivedByFacilityID BIGINT = NULL,
    @DiagnosisDateFrom DATETIME = NULL,
    @DiagnosisDateTo DATETIME = NULL,
    @LocalOrFieldSampleID NVARCHAR(200) = NULL,
    @DataEntrySiteID BIGINT = NULL,
    @DateOfSymptomsOnsetFrom DATETIME = NULL,
    @DateOfSymptomsOnsetTo DATETIME = NULL,
    @NotificationDateFrom DATETIME = NULL,
    @NotificationDateTo DATETIME = NULL,
    @DateOfFinalCaseClassificationFrom DATETIME = NULL,
    @DateOfFinalCaseClassificationTo DATETIME = NULL,
    @LocationOfExposureAdministrativeLevelID BIGINT = NULL,
    @OutcomeID BIGINT = NULL,
    @FilterOutbreakTiedReports INT = 0,
    @OutbreakCasesIndicator BIT = 0,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplySiteFiltrationIndicator BIT = 0,
    @SortColumn NVARCHAR(30) = 'ReportID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @Page INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AdministrativeLevelNode AS HIERARCHYID,
            @LocationOfExposureLevelNode AS HIERARCHYID;
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL, INDEX IDX_ID (ID
                                                             ));
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL
    );

    BEGIN TRY
        IF @AdministrativeLevelID IS NOT NULL
        BEGIN
            SELECT @AdministrativeLevelNode = node
            FROM dbo.gisLocation
            WHERE idfsLocation = @AdministrativeLevelID;
        END;

        IF @LocationOfExposureAdministrativeLevelID IS NOT NULL
        BEGIN
            SELECT @LocationOfExposureLevelNode = node
            FROM dbo.gisLocation
            WHERE idfsLocation = @LocationOfExposureAdministrativeLevelID;
        END;

        -- ========================================================================================
        -- NO SITE FILTRATION RULES APPLIED
        --
        -- For first and second level sites, do not apply any site filtration rules.
        -- ========================================================================================
        IF @ApplySiteFiltrationIndicator = 0
        BEGIN
            INSERT INTO @Results
            SELECT hc.idfHumanCase,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                       AND h.intRowStatus = 0
                INNER JOIN dbo.tlbGeoLocation currentAddress
                    ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = currentAddress.idfsLocation
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation exposure
                    ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                LEFT JOIN dbo.gisLocation gExposure
                    ON gExposure.idfsLocation = exposure.idfsLocation
            WHERE hc.intRowStatus = 0
                  AND hc.idfsFinalDiagnosis IS NOT NULL
                  AND (
                          hc.idfHumanCase = @ReportKey
                          OR @ReportKey IS NULL
                      )
                  AND (
                          hc.idfParentMonitoringSession = @SessionKey
                          OR @SessionKey IS NULL
                      )
                  AND (
                          h.idfHumanActual = @PatientID
                          OR @PatientID IS NULL
                      )
                  AND (
                          h.strPersonId = @PersonID
                          OR @PersonID IS NULL
                      )
                  AND (
                          idfsFinalDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          idfsCaseProgressStatus = @ReportStatusTypeID
                          OR @ReportStatusTypeID IS NULL
                      )
                  AND (
                          g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          (CAST(hc.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datFinalDiagnosisDate AS DATE)
                  BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                          )
                          OR (
                                 @DiagnosisDateFrom IS NULL
                                 OR @DiagnosisDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datNotificationDate AS DATE)
                  BETWEEN @NotificationDateFrom AND @NotificationDateTo
                          )
                          OR (
                                 @NotificationDateFrom IS NULL
                                 OR @NotificationDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datOnSetDate AS DATE)
                  BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                          )
                          OR (
                                 @DateOfSymptomsOnsetFrom IS NULL
                                 OR @DateOfSymptomsOnsetTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datFinalCaseClassificationDate AS DATE)
                  BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                          )
                          OR (
                                 @DateOfFinalCaseClassificationFrom IS NULL
                                 OR @DateOfFinalCaseClassificationTo IS NULL
                             )
                      )
                  AND (
                          hc.idfReceivedByOffice = @ReceivedByFacilityID
                          OR @ReceivedByFacilityID IS NULL
                      )
                  AND (
                          hc.idfSentByOffice = @SentByFacilityID
                          OR @SentByFacilityID IS NULL
                      )
                  AND (
                          idfsFinalCaseStatus = @ClassificationTypeID
                          OR @ClassificationTypeID IS NULL
                      )
                  AND (
                          idfsYNHospitalization = @HospitalizationYNID
                          OR @HospitalizationYNID IS NULL
                      )
                  AND (
                          gExposure.node.IsDescendantOf(@LocationOfExposureLevelNode) = 1
                          OR @LocationOfExposureAdministrativeLevelID IS NULL
                      )
                  AND (
                          (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                            WHEN '' THEN
                                                                ISNULL(h.strFirstName, '')
                                                            ELSE
                                                                @PatientFirstName
                                                        END
                          )
                          OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                             WHEN '' THEN
                                                                 ISNULL(h.strSecondName, '')
                                                             ELSE
                                                                 @PatientMiddleName
                                                         END
                          )
                          OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                           WHEN '' THEN
                                                               ISNULL(h.strLastName, '')
                                                           ELSE
                                                               @PatientLastName
                                                       END
                          )
                          OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                      )
                  AND (
                          hc.idfsSite = @DataEntrySiteID
                          OR @DataEntrySiteID IS NULL
                      )
                  AND (
					(
						hc.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						hc.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
                  AND (
                          hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                          OR @ReportID IS NULL
                      )
                  AND (
                          hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                          OR @LegacyReportID IS NULL
                      )
                  AND (
                          m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                          OR @LocalOrFieldSampleID IS NULL
                      )
                 AND  (
                          hc.idfsOutcome = @OutcomeID
                          OR @OutcomeID IS NULL
                      )
            GROUP BY hc.idfHumanCase
            OPTION (RECOMPILE);
        END
        ELSE
        BEGIN
            INSERT INTO @Results
            SELECT hc.idfHumanCase,
            1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                       AND h.intRowStatus = 0
                INNER JOIN dbo.tlbGeoLocation currentAddress
                    ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = currentAddress.idfsLocation
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation exposure
                    ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                LEFT JOIN dbo.gisLocation gExposure
                    ON gExposure.idfsLocation = exposure.idfsLocation
            WHERE hc.intRowStatus = 0
                  AND hc.idfsSite = @UserSiteID
                  AND hc.idfsFinalDiagnosis IS NOT NULL
                  AND (
                          hc.idfHumanCase = @ReportKey
                          OR @ReportKey IS NULL
                      )
                  AND (
                          hc.idfParentMonitoringSession = @SessionKey
                          OR @SessionKey IS NULL
                      )
                  AND (
                          h.idfHumanActual = @PatientID
                          OR @PatientID IS NULL
                      )
                  AND (
                          h.strPersonId = @PersonID
                          OR @PersonID IS NULL
                      )
                  AND (
                          idfsFinalDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          idfsCaseProgressStatus = @ReportStatusTypeID
                          OR @ReportStatusTypeID IS NULL
                      )
                  AND (
                          g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          (CAST(hc.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datFinalDiagnosisDate AS DATE)
                  BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                          )
                          OR (
                                 @DiagnosisDateFrom IS NULL
                                 OR @DiagnosisDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datNotificationDate AS DATE)
                  BETWEEN @NotificationDateFrom AND @NotificationDateTo
                          )
                          OR (
                                 @NotificationDateFrom IS NULL
                                 OR @NotificationDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datOnSetDate AS DATE)
                  BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                          )
                          OR (
                                 @DateOfSymptomsOnsetFrom IS NULL
                                 OR @DateOfSymptomsOnsetTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datFinalCaseClassificationDate AS DATE)
                  BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                          )
                          OR (
                                 @DateOfFinalCaseClassificationFrom IS NULL
                                 OR @DateOfFinalCaseClassificationTo IS NULL
                             )
                      )
                  AND (
                          hc.idfReceivedByOffice = @ReceivedByFacilityID
                          OR @ReceivedByFacilityID IS NULL
                      )
                  AND (
                          hc.idfSentByOffice = @SentByFacilityID
                          OR @SentByFacilityID IS NULL
                      )
                  AND (
                          idfsFinalCaseStatus = @ClassificationTypeID
                          OR @ClassificationTypeID IS NULL
                      )
                  AND (
                          idfsYNHospitalization = @HospitalizationYNID
                          OR @HospitalizationYNID IS NULL
                      )
                  AND (
                          gExposure.node.IsDescendantOf(@LocationOfExposureLevelNode) = 1
                          OR @LocationOfExposureAdministrativeLevelID IS NULL
                      )
                  AND (
                          (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                            WHEN '' THEN
                                                                ISNULL(h.strFirstName, '')
                                                            ELSE
                                                                @PatientFirstName
                                                        END
                          )
                          OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                             WHEN '' THEN
                                                                 ISNULL(h.strSecondName, '')
                                                             ELSE
                                                                 @PatientMiddleName
                                                         END
                          )
                          OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                           WHEN '' THEN
                                                               ISNULL(h.strLastName, '')
                                                           ELSE
                                                               @PatientLastName
                                                       END
                          )
                          OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                      )
                  AND (
                          hc.idfsSite = @DataEntrySiteID
                          OR @DataEntrySiteID IS NULL
                      )
                  AND (
					(
						hc.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						hc.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
                  AND (
                          hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                          OR @ReportID IS NULL
                      )
                  AND (
                          hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                          OR @LegacyReportID IS NULL
                      )
                  AND (
                          m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                          OR @LocalOrFieldSampleID IS NULL
                      )
                 AND  (
                          hc.idfsOutcome = @OutcomeID
                   OR @OutcomeID IS NULL
                      )
            GROUP BY hc.idfHumanCase
            OPTION (RECOMPILE);

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
            -- Apply active default site filtration rules for third level sites.
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

            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537000;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537000;
				
                SELECT @AdministrativeLevelNode = g.node.GetAncestor(g.node.GetLevel() - @AdministrativeLevelTypeID)
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared AS l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.gisLocation g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.intRowStatus = 0
                WHERE o.idfOffice = @UserOrganizationID
                      AND g.node.GetLevel() >= @AdministrativeLevelTypeID;

                -- Administrative level specified in the rule of the site where the report was created.
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tstSite s
                        ON h.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                           AND o.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocation g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1;

                -- Administrative level specified in the rule of the report current residence address.
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbHuman hu
                        ON hu.idfHuman = h.idfHuman
                           AND hu.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = hu.idfCurrentResidenceAddress
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocation g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1;

                -- Administrative level specified in the rule of the report location of exposure, 
                -- if corresponding field was filled in.
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = h.idfPointGeoLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocation g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1;
            END;

            -- Report data shall be available to all sites' organizations connected to the particular report.
            -- Notification sent by, notification received by, facility where the patient first sought 
            -- care, hospital, and the conducting investigation organizations.
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 10537001;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE h.intRowStatus = 0
                      AND (
                              h.idfSentByOffice = @UserOrganizationID
                              OR h.idfReceivedByOffice = @UserOrganizationID
                              OR h.idfSoughtCareFacility = @UserOrganizationID
                              OR h.idfHospital = @UserOrganizationID
                              OR h.idfInvestigatedByOffice = @UserOrganizationID
                          )
                ORDER BY h.idfHumanCase;

                -- Sample collected by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfHumanCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbHumanCase h
                        ON h.idfHumanCase = m.idfHumanCase
                           AND h.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE m.intRowStatus = 0
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          )
                GROUP BY m.idfHumanCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;

                -- Sample transferred to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfHumanCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbHumanCase h
                        ON h.idfHumanCase = m.idfHumanCase
                           AND h.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial tom
                        ON m.idfMaterial = tom.idfMaterial
                           AND tom.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT t
                        ON tom.idfTransferOut = t.idfTransferOut
                           AND t.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE m.intRowStatus = 0
                      AND t.idfSendToOffice = @UserOrganizationID
                GROUP BY m.idfHumanCase,
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
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 10537002;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbOutbreak o
                        ON h.idfHumanCase = o.idfPrimaryCaseOrSession
                           AND o.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537002
                WHERE h.intRowStatus = 0
                      AND o.idfsSite = @UserSiteID;
            END;

            -- =======================================================================================
            -- CONFIGURABLE SITE FILTRATION RULES
            -- 
            -- Apply configurable site filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the default rules.
            -- =======================================================================================
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
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
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
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
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND sgs.idfsSite = h.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                 AND a.GrantingActorSiteID = h.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
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
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteID = h.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
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
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteID = h.idfsSite;

            -- Copy filtered results to results and use search criteria
            INSERT INTO @Results
            SELECT ID,
                   ReadPermissionIndicator,
                   AccessToPersonalDataPermissionIndicator,
                   AccessToGenderAndAgeDataPermissionIndicator,
                   WritePermissionIndicator,
                   DeletePermissionIndicator
            FROM @FilteredResults
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = ID
                INNER JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                       AND h.intRowStatus = 0
                INNER JOIN dbo.tlbHumanActual ha
                    ON ha.idfHumanActual = h.idfHumanActual
                       AND ha.intRowStatus = 0
                INNER JOIN dbo.tlbGeoLocation currentAddress
                    ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = currentAddress.idfsLocation
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation exposure
                    ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                LEFT JOIN dbo.gisLocation gExposure
                    ON gExposure.idfsLocation = exposure.idfsLocation
            WHERE hc.intRowStatus = 0
                  AND hc.idfsFinalDiagnosis IS NOT NULL
                  AND (
                          hc.idfHumanCase = @ReportKey
                          OR @ReportKey IS NULL
                      )
                  AND (
                          hc.idfParentMonitoringSession = @SessionKey
                          OR @SessionKey IS NULL
                      )
                  AND (
                          ha.idfHumanActual = @PatientID
                          OR @PatientID IS NULL
                      )
                  AND (
                          h.strPersonId = @PersonID
                          OR @PersonID IS NULL
                      )
                  AND (
                          idfsFinalDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          idfsCaseProgressStatus = @ReportStatusTypeID
                          OR @ReportStatusTypeID IS NULL
                      )
                  AND (
                          g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          (CAST(hc.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datFinalDiagnosisDate AS DATE)
                  BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                          )
                          OR (
                                 @DiagnosisDateFrom IS NULL
                                 OR @DiagnosisDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datNotificationDate AS DATE)
                  BETWEEN @NotificationDateFrom AND @NotificationDateTo
                          )
                          OR (
                                 @NotificationDateFrom IS NULL
                                 OR @NotificationDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datOnSetDate AS DATE)
                  BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                          )
                          OR (
                                 @DateOfSymptomsOnsetFrom IS NULL
                                 OR @DateOfSymptomsOnsetTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datFinalCaseClassificationDate AS DATE)
                  BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                          )
                          OR (
                                 @DateOfFinalCaseClassificationFrom IS NULL
                                 OR @DateOfFinalCaseClassificationTo IS NULL
                             )
                      )
                  AND (
                          hc.idfReceivedByOffice = @ReceivedByFacilityID
                          OR @ReceivedByFacilityID IS NULL
                      )
                  AND (
                          hc.idfSentByOffice = @SentByFacilityID
                          OR @SentByFacilityID IS NULL
                      )
                  AND (
                          idfsFinalCaseStatus = @ClassificationTypeID
                          OR @ClassificationTypeID IS NULL
                      )
                  AND (
                          idfsYNHospitalization = @HospitalizationYNID
                          OR @HospitalizationYNID IS NULL
                      )
                  AND (
                          gExposure.node.IsDescendantOf(@LocationOfExposureLevelNode) = 1
                          OR @LocationOfExposureAdministrativeLevelID IS NULL
                      )
                  AND (
                          (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                            WHEN '' THEN
                                                                ISNULL(h.strFirstName, '')
                                                            ELSE
                                                                @PatientFirstName
                                                        END
                          )
                          OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                             WHEN '' THEN
                                                                 ISNULL(h.strSecondName, '')
                                                             ELSE
                                                                 @PatientMiddleName
                                                         END
                          )
                          OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                           WHEN '' THEN
                                                               ISNULL(h.strLastName, '')
                                                           ELSE
                                                               @PatientLastName
                                                       END
                          )
                          OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                      )
                  AND (
                          hc.idfsSite = @DataEntrySiteID
                          OR @DataEntrySiteID IS NULL
                      )
                  AND (
					(
						hc.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						hc.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
                  AND (
                          hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                          OR @ReportID IS NULL
                      )
                  AND (
                          hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                          OR @LegacyReportID IS NULL
                      )
                  AND (
                          m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                          OR @LocalOrFieldSampleID IS NULL
                      )
                 AND  (
                          hc.idfsOutcome = @OutcomeID
                          OR @OutcomeID IS NULL
                      )
            GROUP BY ID,
                     ReadPermissionIndicator,
                     AccessToPersonalDataPermissionIndicator,
                     AccessToGenderAndAgeDataPermissionIndicator,
                     WritePermissionIndicator,
                     DeletePermissionIndicator
            OPTION (RECOMPILE);
        END;


        -- =======================================================================================
        -- Remove "Outbreak" tied disease reports, if filtering is needed
        -- =======================================================================================
        IF @FilterOutbreakTiedReports = 1
        BEGIN
            DELETE I
            FROM @Results I
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = I.ID
            WHERE hc.idfOutbreak IS NOT NULL;
        END;

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
        WHERE EXISTS
        (
            SELECT h.idfHumanCase
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = h.idfsFinalDiagnosis
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 1
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = -506 -- Default role
        );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbHumanCase hc
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tlbHuman h
                ON h.idfHuman = hc.idfHuman
                   AND h.intRowStatus = 0
            INNER JOIN dbo.tlbGeoLocation currentAddress
                ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = currentAddress.idfsLocation
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfHumanCase = hc.idfHumanCase
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation exposure
                ON exposure.idfGeoLocation = hc.idfPointGeoLocation
            LEFT JOIN dbo.gisLocation gExposure
                ON gExposure.idfsLocation = exposure.idfsLocation
        WHERE oa.intPermission = 2 -- Allow permission
              AND hc.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup
              AND hc.idfsFinalDiagnosis IS NOT NULL
              AND (
                      hc.idfHumanCase = @ReportKey
                      OR @ReportKey IS NULL
                  )
              AND (
                      hc.idfParentMonitoringSession = @SessionKey
                      OR @SessionKey IS NULL
                  )
              AND (
                      h.idfHumanActual = @PatientID
                      OR @PatientID IS NULL
                  )
              AND (
                      h.strPersonId = @PersonID
                      OR @PersonID IS NULL
                  )
              AND (
                      idfsFinalDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      idfsCaseProgressStatus = @ReportStatusTypeID
                      OR @ReportStatusTypeID IS NULL
                  )
              AND (
                      g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                      OR @AdministrativeLevelID IS NULL
                  )
              AND (
                      (CAST(hc.datEnteredDate AS DATE)
              BETWEEN @DateEnteredFrom AND @DateEnteredTo
                      )
                      OR (
                             @DateEnteredFrom IS NULL
                             OR @DateEnteredTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datFinalDiagnosisDate AS DATE)
              BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                      )
                 OR (
                             @DiagnosisDateFrom IS NULL
                             OR @DiagnosisDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datNotificationDate AS DATE)
              BETWEEN @NotificationDateFrom AND @NotificationDateTo
                      )
                      OR (
                             @NotificationDateFrom IS NULL
                             OR @NotificationDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datOnSetDate AS DATE)
              BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                      )
                      OR (
                             @DateOfSymptomsOnsetFrom IS NULL
                             OR @DateOfSymptomsOnsetTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datFinalCaseClassificationDate AS DATE)
              BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                      )
                      OR (
                             @DateOfFinalCaseClassificationFrom IS NULL
                             OR @DateOfFinalCaseClassificationTo IS NULL
                         )
                  )
              AND (
                      hc.idfReceivedByOffice = @ReceivedByFacilityID
                      OR @ReceivedByFacilityID IS NULL
                  )
              AND (
                      hc.idfSentByOffice = @SentByFacilityID
                      OR @SentByFacilityID IS NULL
                  )
              AND (
                      idfsFinalCaseStatus = @ClassificationTypeID
                      OR @ClassificationTypeID IS NULL
                  )
              AND (
                      idfsYNHospitalization = @HospitalizationYNID
                      OR @HospitalizationYNID IS NULL
                  )
              AND (
                      g.node.IsDescendantOf(@LocationOfExposureLevelNode) = 1
                      OR @LocationOfExposureAdministrativeLevelID IS NULL
                  )
              AND (
                      (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                        WHEN '' THEN
                                                            ISNULL(h.strFirstName, '')
                                                        ELSE
                                                            @PatientFirstName
                                                    END
                      )
                      OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                  )
              AND (
                      (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                         WHEN '' THEN
                                                             ISNULL(h.strSecondName, '')
                                                         ELSE
                                                             @PatientMiddleName
                                                     END
                      )
                      OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                  )
              AND (
                      (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                       WHEN '' THEN
                                                           ISNULL(h.strLastName, '')
                                                       ELSE
                                                           @PatientLastName
                                                   END
                      )
                      OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                  )
              AND (
                      hc.idfsSite = @DataEntrySiteID
                      OR @DataEntrySiteID IS NULL
                  )
              AND (
					(
						hc.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						hc.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
              AND (
                      hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                      OR @ReportID IS NULL
                  )
              AND (
                      hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                      OR @LegacyReportID IS NULL
                  )
              AND (
                      m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                      OR @LocalOrFieldSampleID IS NULL
                  )
             AND  (
                     hc.idfsOutcome = @OutcomeID
                     OR @OutcomeID IS NULL
                  )
        GROUP BY hc.idfHumanCase
        OPTION (RECOMPILE);

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbHumanCase hc
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbHuman h
                ON h.idfHuman = hc.idfHuman
                   AND h.intRowStatus = 0
            INNER JOIN dbo.tlbGeoLocation currentAddress
                ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = currentAddress.idfsLocation
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfHumanCase = hc.idfHumanCase
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation exposure
                ON exposure.idfGeoLocation = hc.idfPointGeoLocation
            LEFT JOIN dbo.gisLocation gExposure
                ON gExposure.idfsLocation = exposure.idfsLocation
        WHERE oa.intPermission = 2 -- Allow permission
              AND hc.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID
              AND hc.idfsFinalDiagnosis IS NOT NULL
              AND (
                      hc.idfHumanCase = @ReportKey
                      OR @ReportKey IS NULL
                  )
              AND (
                      hc.idfParentMonitoringSession = @SessionKey
                      OR @SessionKey IS NULL
                  )
              AND (
                      h.idfHumanActual = @PatientID
                      OR @PatientID IS NULL
                  )
              AND (
                      h.strPersonId = @PersonID
                      OR @PersonID IS NULL
                  )
              AND (
                      idfsFinalDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      idfsCaseProgressStatus = @ReportStatusTypeID
                      OR @ReportStatusTypeID IS NULL
                  )
              AND (
                      g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                      OR @AdministrativeLevelID IS NULL
                  )
              AND (
                      (CAST(hc.datEnteredDate AS DATE)
              BETWEEN @DateEnteredFrom AND @DateEnteredTo
                      )
                      OR (
                             @DateEnteredFrom IS NULL
                             OR @DateEnteredTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datFinalDiagnosisDate AS DATE)
              BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                      )
                      OR (
                             @DiagnosisDateFrom IS NULL
                             OR @DiagnosisDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datNotificationDate AS DATE)
              BETWEEN @NotificationDateFrom AND @NotificationDateTo
                      )
                      OR (
                             @NotificationDateFrom IS NULL
                             OR @NotificationDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datOnSetDate AS DATE)
              BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                      )
                      OR (
                             @DateOfSymptomsOnsetFrom IS NULL
                             OR @DateOfSymptomsOnsetTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datFinalCaseClassificationDate AS DATE)
              BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                      )
                      OR (
                             @DateOfFinalCaseClassificationFrom IS NULL
                             OR @DateOfFinalCaseClassificationTo IS NULL
                         )
                  )
              AND (
                      hc.idfReceivedByOffice = @ReceivedByFacilityID
                      OR @ReceivedByFacilityID IS NULL
                  )
              AND (
                      hc.idfSentByOffice = @SentByFacilityID
                      OR @SentByFacilityID IS NULL
                  )
              AND (
                      idfsFinalCaseStatus = @ClassificationTypeID
                      OR @ClassificationTypeID IS NULL
                  )
              AND (
                      idfsYNHospitalization = @HospitalizationYNID
                      OR @HospitalizationYNID IS NULL
                  )
              AND (
                      g.node.IsDescendantOf(@LocationOfExposureLevelNode) = 1
                      OR @LocationOfExposureAdministrativeLevelID IS NULL
                  )
              AND (
                      (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                        WHEN '' THEN
                                                            ISNULL(h.strFirstName, '')
                                                        ELSE
                                                            @PatientFirstName
                                                    END
                      )
                      OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                  )
              AND (
                      (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                         WHEN '' THEN
                                                             ISNULL(h.strSecondName, '')
                                                         ELSE
                                                             @PatientMiddleName
                                                     END
                      )
                      OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                  )
       AND (
                      (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                       WHEN '' THEN
                                                           ISNULL(h.strLastName, '')
                                                       ELSE
                                                           @PatientLastName
                                                   END
                      )
                      OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                  )
              AND (
                      hc.idfsSite = @DataEntrySiteID
                      OR @DataEntrySiteID IS NULL
                  )
              AND (
					(
						hc.idfOutbreak IS NULL
						AND @OutbreakCasesIndicator = 0
						)
					OR (
						hc.idfOutbreak IS NOT NULL
						AND @OutbreakCasesIndicator = 1
						)
					OR (@OutbreakCasesIndicator IS NULL)
					)
              AND (
                      hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                      OR @ReportID IS NULL
                  )
              AND (
                      hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                      OR @LegacyReportID IS NULL
                  )
              AND (
                      m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                      OR @LocalOrFieldSampleID IS NULL
                  )
             AND  (
                      hc.idfsOutcome = @OutcomeID
                      OR @OutcomeID IS NULL
                  )
        GROUP BY hc.idfHumanCase
        OPTION (RECOMPILE);

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                       AND oa.intRowStatus = 0
            WHERE intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND idfActor = @UserEmployeeID
        );
		
        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        INSERT INTO @FinalResults
        SELECT ID,
               ReadPermissionIndicator,
               AccessToPersonalDataPermissionIndicator,
               AccessToGenderAndAgeDataPermissionIndicator,
               WritePermissionIndicator,
               DeletePermissionIndicator
        FROM @Results res
        WHERE res.ReadPermissionIndicator = 1
        GROUP BY ID,
                 ReadPermissionIndicator,
                 AccessToPersonalDataPermissionIndicator,
                 AccessToGenderAndAgeDataPermissionIndicator,
                 WritePermissionIndicator,
                 DeletePermissionIndicator;

		
        WITH paging
        AS (SELECT ID,
                   c = COUNT(*) OVER ()
            FROM @FinalResults res
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = res.ID
                INNER JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                       AND h.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = h.idfCurrentResidenceAddress
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = gl.idfsLocation
                LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                    ON LH.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                    ON disease.idfsReference = hc.idfsFinalDiagnosis
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) finalClassification
                    ON finalClassification.idfsReference = hc.idfsFinalCaseStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus
                    ON reportStatus.idfsReference = hc.idfsCaseProgressStatus
            ORDER BY CASE
                         WHEN @SortColumn = 'ReportID'
                              AND @SortOrder = 'ASC' THEN
                             hc.strCaseID
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'ReportID'
                              AND @SortOrder = 'DESC' THEN
                             hc.strCaseID
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'EnteredDate'
                              AND @SortOrder = 'ASC' THEN
                             hc.datEnteredDate
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'EnteredDate'
                              AND @SortOrder = 'DESC' THEN
                             hc.datEnteredDate
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'DiseaseName'
                              AND @SortOrder = 'ASC' THEN
                             disease.name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'DiseaseName'
                              AND @SortOrder = 'DESC' THEN
                             disease.name
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'PersonName'
                              AND @SortOrder = 'ASC' THEN
                             ISNULL(h.strLastName, N'') + ISNULL(', ' + h.strFirstName, N'')
                             + ISNULL(' ' + h.strSecondName, N'')
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'PersonName'
                              AND @SortOrder = 'DESC' THEN
                             ISNULL(h.strLastName, N'') + ISNULL(', ' + h.strFirstName, N'')
                             + ISNULL(' ' + h.strSecondName, N'')
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'PersonLocation'
                              AND @SortOrder = 'ASC' THEN
                     (LH.AdminLevel1Name + ', ' + LH.AdminLevel2Name)
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'PersonLocation'
                              AND @SortOrder = 'DESC' THEN
                     (LH.AdminLevel1Name + ', ' + LH.AdminLevel2Name)
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'ClassificationTypeName'
                              AND @SortOrder = 'ASC' THEN
                             finalClassification.name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'ClassificationTypeName'
                              AND @SortOrder = 'DESC' THEN
                             finalClassification.name
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'ReportStatusTypeName'
                              AND @SortOrder = 'ASC' THEN
                             reportStatus.name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'ReportStatusTypeName'
                              AND @SortOrder = 'DESC' THEN
                             reportStatus.name
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'LegacyReportID'
                              AND @SortOrder = 'ASC' THEN
                             hc.LegacyCaseID
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'LegacyReportID'
                              AND @SortOrder = 'DESC' THEN
                             hc.LegacyCaseID
                     END DESC OFFSET @PageSize * (@Page - 1) ROWS FETCH NEXT @PageSize ROWS ONLY
     )
        SELECT res.ID AS ReportKey,
               hc.strCaseId AS ReportID,
               hc.LegacyCaseID AS LegacyReportID,
               reportStatus.name AS ReportStatusTypeName,
               reportType.name AS ReportTypeName,
               hc.datTentativeDiagnosisDate AS TentativeDiagnosisDate,
               hc.datFinalDiagnosisDate AS FinalDiagnosisDate,
               ISNULL(finalClassification.name, initialClassification.name) AS ClassificationTypeName,
               finalClassification.name AS FinalClassificationTypeName,
               hc.datOnSetDate AS DateOfOnset,
               hc.idfsFinalDiagnosis AS DiseaseID,
               disease.Name AS DiseaseName,
               h.idfHumanActual AS PersonMasterID,
               hc.idfHuman AS PersonKey,
               haai.EIDSSPersonID AS PersonID,
               h.strPersonID AS PersonalID,
               dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) AS PersonName,
               ISNULL(LH.AdminLevel1Name, '') + IIF(LH.AdminLevel2Name IS NULL, '', ', ')
               + ISNULL(LH.AdminLevel2Name, '') AS PersonLocation,
               ha.strEmployerName AS EmployerName,
               hc.datEnteredDate AS EnteredDate,
               ISNULL(p.strFamilyName, N'') + ISNULL(', ' + p.strFirstName, N'') + ISNULL(' ' + p.strSecondName, N'') AS EnteredByPersonName,
               hc.datModificationDate AS ModificationDate,
               ISNULL(hospitalization.name, hospitalization.strDefault) AS HospitalizationStatus,
               hc.idfsSite AS SiteID,
               res.ReadPermissionIndicator,
               res.AccessToPersonalDataPermissionIndicator,
               res.AccessToGenderAndAgeDataPermissionIndicator,
               res.WritePermissionIndicator,
               res.DeletePermissionIndicator,
               c AS RecordCount,
               (
                   SELECT COUNT(*) FROM dbo.tlbHumanCase hc WHERE hc.intRowStatus = 0
               ) AS TotalCount,
               TotalPages = (c / @PageSize) + IIF(c % @PageSize > 0, 1, 0),
               CurrentPage = @Page,
               LH.AdminLevel2Name Region,
			   LH.AdminLevel3Name Rayon
        FROM @FinalResults res
            INNER JOIN paging
                ON paging.ID = res.ID
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN dbo.tlbHuman h
                ON h.idfHuman = hc.idfHuman
                   AND h.intRowStatus = 0
            INNER JOIN dbo.tlbHumanActual ha
                ON ha.idfHumanActual = h.idfHumanActual
                   AND ha.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation gl
                ON gl.idfGeoLocation = h.idfCurrentResidenceAddress
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = gl.idfsLocation
            LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                ON LH.idfsLocation = gl.idfsLocation
            LEFT JOIN dbo.HumanActualAddlInfo haai
                ON haai.HumanActualAddlInfoUID = ha.idfHumanActual
                   AND haai.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                ON disease.idfsReference = hc.idfsFinalDiagnosis
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) initialClassification
                ON initialClassification.idfsReference = hc.idfsInitialCaseStatus
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) finalClassification
                ON finalClassification.idfsReference = hc.idfsFinalCaseStatus
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus
                ON reportStatus.idfsReference = hc.idfsCaseProgressStatus
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000144) reportType
                ON reportType.idfsReference = hc.DiseaseReportTypeID
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000041) hospitalization
                ON hospitalization.idfsReference = idfsHospitalizationStatus
            LEFT JOIN dbo.tlbPerson p
                ON p.idfPerson = hc.idfPersonEnteredBy
                   AND p.intRowStatus = 0
        OPTION (RECOMPILE);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
GO
PRINT N'Creating Procedure [dbo].[usp_SearchFK]...';


GO
CREATE PROC dbo.usp_SearchFK 
  @table VARCHAR(256) -- use two part name convention
, @lvl INT=0 -- do not change
, @ParentTable VARCHAR(256)='' -- do not change
, @debug BIT = 1
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @dbg BIT;
	SET @dbg=@debug;
	IF OBJECT_ID('tempdb..#tbl', 'U') IS NULL
		CREATE TABLE  #tbl  (id INT IDENTITY, tablename VARCHAR(256), lvl INT, ParentTable VARCHAR(256));
	declare @curS cursor;
	if @lvl = 0
		insert into #tbl (tablename, lvl, ParentTable)
		select @table, @lvl, Null;
	else
		insert into #tbl (tablename, lvl, ParentTable)
		select @table, @lvl,@ParentTable;
	if @dbg=1	
		print replicate('----', @lvl) + 'lvl ' + cast(@lvl as varchar(10)) + ' = ' + @table;
	
	if not exists (select * from sys.foreign_keys where referenced_object_id = object_id(@table))
		return;
	else
	begin -- else
		set @ParentTable = @table;
		set @curS = cursor for
		select tablename=object_schema_name(parent_object_id)+'.'+object_name(parent_object_id)
		from sys.foreign_keys 
		where referenced_object_id = object_id(@table)
		and parent_object_id <> referenced_object_id; -- add this to prevent self-referencing which can create a indefinitive loop;

		open @curS;
		fetch next from @curS into @table;

		while @@fetch_status = 0
		begin --while
			set @lvl = @lvl+1;
			-- recursive call
			exec dbo.usp_SearchFK @table, @lvl, @ParentTable, @dbg;
			set @lvl = @lvl-1;
			fetch next from @curS into @table;
		end --while
		close @curS;
		deallocate @curS;
	end -- else
	if @lvl = 0
		select * from #tbl;
	return;
end
GO
