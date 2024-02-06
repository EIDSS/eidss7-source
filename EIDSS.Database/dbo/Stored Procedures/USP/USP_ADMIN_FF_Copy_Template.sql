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
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Copy_Template] (
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
