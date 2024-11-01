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
-- Doug Albanese	06/07/2023	Added a routine to refresh the design options, in case they are missing for a particular language being used (non-english).
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
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_FlexForm_Get] (
	@LangID						NVARCHAR(50) = NULL
	,@idfsDiagnosis				BIGINT = NULL
	,@idfsFormType				BIGINT = NULL
	,@idfsFormTemplate			BIGINT = NULL
	,@idfObservation			BIGINT = NULL
	)
AS
BEGIN
	DECLARE @idfsCountry AS BIGINT,
			@idfsLanguage BIGINT = dbo.FN_GBL_LanguageCode_GET(@LangID),
			@idfsEnUS BIGINT = dbo.FN_GBL_LanguageCode_GET('en-us')
	DECLARE @tmpTemplate AS TABLE (
		idfsFormTemplate BIGINT PRIMARY KEY
		,IsUNITemplate BIT
		)
	DECLARE @intMaxChildLevel int = 4 /*maximum level of embeded sections*/

	declare	@ControlsInTemplate as table
	(	idfsFormTemplate					bigint not null,
		idfsControl							bigint not null,
		idfControlDesignOption				bigint null,
		idfsSection							bigint null,
		idfsParentSection					bigint null,
		intControlChildLevel				int not null default(0),
		idfsControlParentSection			bigint null,
		idfsControlRootGridSection			bigint null,
		idfsControlParentForRootGridSection	bigint null,
		idfsParameter						bigint null,
		strParentSectionName				nvarchar(2000) collate Cyrillic_General_CI_AS null,
		strSectionName						nvarchar(2000) collate Cyrillic_General_CI_AS null,
		strParameterName					nvarchar(2000) collate Cyrillic_General_CI_AS null,
		strDecorElementText					nvarchar(2000) collate Cyrillic_General_CI_AS null,
		strParameterType					nvarchar(2000) collate Cyrillic_General_CI_AS null,
		idfsParameterType					bigint null,
		idfsReferenceType					bigint null,
		idfsEditor							bigint null,
		blnParentGrid						bit not null default(0),
		blnGrid								bit not null default(0),
		blnFixedRowSet						bit not null default(0),
		idfsEditMode						bigint null,
		intRelativeOrder					int not null default(0),
		intRelativeTop						int not null default(0),
		intRelativeLeft						int not null default(0),
		intAbsoluteOrder					bigint not null default(0),
		primary key
		(	idfsFormTemplate asc,
			idfsControl asc
		)
	)

	declare @GoOn int = 1
	declare @intChildLevel int = 0



	DECLARE @returnCode INT = 0;
	DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';

	BEGIN TRY
		IF @idfsFormTemplate IS NULL
		BEGIN
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
			END
		-- Retrieve controls for the selected template

		-- Retrieve sections for the selected template	
		insert into	@ControlsInTemplate
		(	idfsFormTemplate,
			idfsControl,
			idfControlDesignOption,
			intControlChildLevel,
			idfsControlParentSection,
			idfsControlRootGridSection,
			idfsControlParentForRootGridSection,
			idfsSection,
			idfsParentSection,
			idfsParameter,
			strParentSectionName,
			strSectionName,
			strParameterName,
			strDecorElementText,
			strParameterType,
			idfsParameterType,
			idfsReferenceType,
			idfsEditor,
			blnParentGrid,
			blnGrid,
			blnFixedRowSet,
			idfsEditMode,
			intRelativeOrder,
			intRelativeTop,
			intRelativeLeft,
			intAbsoluteOrder
		)
		select		@idfsFormTemplate,
					s.idfsSection,
					sdo_en.idfSectionDesignOption,
					case when s.idfsParentSection is null then 0 else @intMaxChildLevel+1 end,
					s.idfsParentSection,
					case when s.blnGrid = 1 and (s_parent.blnGrid = 0 or s_parent.blnGrid is null) then s.idfsSection else null end,
					case when s.blnGrid = 1 and (s_parent.blnGrid = 0 or s_parent.blnGrid is null) then s.idfsParentSection else null end,
					s.idfsSection,
					s.idfsParentSection,
					-1,
					coalesce(s_parent_snt.strTextString, s_parent_br.strDefault, N''),
					coalesce(s_snt.strTextString, s_br.strDefault, N''),
					null,
					null,
					null,
					null,
					null,
					null,
					isnull(s_parent.blnGrid, 0),
					s.blnGrid,
					s.blnFixedRowSet,
					null,
					isnull(sdo_en.intOrder, 0),
					isnull(sdo_en.intTop, 0),
					isnull(sdo_en.intLeft, 0),
					0

		from		dbo.ffSectionForTemplate sft
		inner join	dbo.ffSection s
		on			s.idfsSection = sft.idfsSection
					and s.intRowStatus = 0
					--and s.idfsFormType = @idfsFormType

		inner join	dbo.trtBaseReference s_br
		on			s_br.idfsBaseReference = s.idfsSection
					--and s_br.intRowStatus = 0
		left join	trtStringNameTranslation s_snt
		on			s_snt.idfsBaseReference = s.idfsSection
					and s_snt.idfsLanguage = @idfsLanguage

		left join	dbo.ffSection s_parent
		on			s_parent.idfsSection = s.idfsParentSection

		left join	dbo.trtBaseReference s_parent_br
		on			s_parent_br.idfsBaseReference = s.idfsParentSection
					--and s_parent_br.intRowStatus = 0
		left join	trtStringNameTranslation s_parent_snt
		on			s_parent_snt.idfsBaseReference = s.idfsParentSection
					and s_parent_snt.idfsLanguage = @idfsLanguage

		outer apply
		(	select	top 1
					sdo.idfSectionDesignOption, sdo.intTop, sdo.intLeft, sdo.intOrder
			from	dbo.ffSectionDesignOption sdo
			where	sdo.idfsFormTemplate = @idfsFormTemplate
					and sdo.idfsSection = sft.idfsSection
					and sdo.idfsLanguage = @idfsEnUS
					and sdo.intRowStatus = 0
			order by
					sdo.idfSectionDesignOption
		) sdo_en
		where		sft.idfsFormTemplate = @idfsFormTemplate
					and sft.intRowStatus = 0

		-- Retrieve parameters for the selected template	
		insert into	@ControlsInTemplate
		(	idfsFormTemplate,
			idfsControl,
			idfControlDesignOption,
			intControlChildLevel,
			idfsControlParentSection,
			idfsControlRootGridSection,
			idfsControlParentForRootGridSection,
			idfsSection,
			idfsParentSection,
			idfsParameter,
			strParentSectionName,
			strSectionName,
			strParameterName,
			strDecorElementText,
			strParameterType,
			idfsParameterType,
			idfsReferenceType,
			idfsEditor,
			blnParentGrid,
			blnGrid,
			blnFixedRowSet,
			idfsEditMode,
			intRelativeOrder,
			intRelativeTop,
			intRelativeLeft,
			intAbsoluteOrder
		)
		select		@idfsFormTemplate,
					p.idfsParameter,
					pdo_en.idfParameterDesignOption,
					isnull(s.intControlChildLevel+1, 0),
					s.idfsSection,
					s.idfsControlRootGridSection,
					s.idfsControlParentForRootGridSection,
					s.idfsSection,
					s.idfsParentSection,
					p.idfsParameter,
					isnull(s.strParentSectionName, N''),
					isnull(s.strSectionName, N''),
					coalesce(pc_snt.strTextString, pc_br.strDefault, N''),
					null,
					coalesce(pt_snt.strTextString, pt_br.strDefault, N''),
					p.idfsParameterType,
					pt.idfsReferenceType,
					p.idfsEditor,
					isnull(s.blnGrid, 0),
					isnull(s.blnGrid, 0),
					isnull(s.blnFixedRowSet, 0),
					pft.idfsEditMode,
					isnull(pdo_en.intOrder, 0),
					isnull(pdo_en.intTop, 0),
					isnull(pdo_en.intLeft, 0),
					0

		from		dbo.ffParameterForTemplate pft
		inner join	dbo.ffParameter p
		on			p.idfsParameter = pft.idfsParameter
					and p.intRowStatus = 0
					--and p.idfsFormType = @idfsFormType
		inner join	dbo.ffParameterType pt
		on			pt.idfsParameterType = p.idfsParameterType
					--and pt.intRowStatus = 0

		inner join	dbo.trtBaseReference p_br
		on			p_br.idfsBaseReference = p.idfsParameter
					--and p_br.intRowStatus = 0
		inner join	dbo.trtBaseReference pc_br
		on			pc_br.idfsBaseReference = p.idfsParameterCaption
					--and pc_br.intRowStatus = 0
		inner join	dbo.trtBaseReference pt_br
		on			pt_br.idfsBaseReference = p.idfsParameterType
					--and pt_br.intRowStatus = 0

		left join	trtStringNameTranslation pc_snt
		on			pc_snt.idfsBaseReference = p.idfsParameterCaption
					and pc_snt.idfsLanguage = @idfsLanguage
		left join	trtStringNameTranslation pt_snt
		on			pt_snt.idfsBaseReference = p.idfsParameterType
					and pt_snt.idfsLanguage = @idfsLanguage


		left join	@ControlsInTemplate s
		on			s.idfsFormTemplate = @idfsFormTemplate
					and s.idfsControl = p.idfsSection

		outer apply
		(	select	top 1
					pdo.idfParameterDesignOption, pdo.intTop, pdo.intLeft, pdo.intOrder
			from	dbo.ffParameterDesignOption pdo
			where	pdo.idfsFormTemplate = @idfsFormTemplate
					and pdo.idfsParameter = pft.idfsParameter
					and pdo.idfsLanguage = @idfsEnUS
					and pdo.intRowStatus = 0
			order by
					pdo.idfParameterDesignOption
		) pdo_en

		left join	@ControlsInTemplate cit
		on			cit.idfsFormTemplate = @idfsFormTemplate
					and cit.idfsControl = p.idfsParameter

		where		pft.idfsFormTemplate = @idfsFormTemplate
					and pft.intRowStatus = 0
					and (p.idfsSection is null or s.idfsSection is not null)
					and cit.idfsControl is null


		-- Retrieve labels for the selected template	
		insert into	@ControlsInTemplate
		(	idfsFormTemplate,
			idfsControl,
			idfControlDesignOption,
			intControlChildLevel,
			idfsControlParentSection,
			idfsControlRootGridSection,
			idfsControlParentForRootGridSection,
			idfsSection,
			idfsParentSection,
			idfsParameter,
			strParentSectionName,
			strSectionName,
			strParameterName,
			strDecorElementText,
			strParameterType,
			idfsParameterType,
			idfsReferenceType,
			idfsEditor,
			blnParentGrid,
			blnGrid,
			blnFixedRowSet,
			idfsEditMode,
			intRelativeOrder,
			intRelativeTop,
			intRelativeLeft,
			intAbsoluteOrder
		)
		select		@idfsFormTemplate,
					det_br.idfsBaseReference,
					det.idfDecorElement,
					isnull(s.intControlChildLevel+1, 0),
					s.idfsSection,
					s.idfsControlRootGridSection,
					s.idfsControlParentForRootGridSection,
					s.idfsSection,
					s.idfsParentSection,
					det_br.idfsBaseReference,
					isnull(s.strParentSectionName, N''),
					isnull(s.strSectionName, N''),
					coalesce(det_snt.strTextString, det_br.strDefault, N''),
					coalesce(det_snt.strTextString, det_br.strDefault, N''),
					coalesce(pt_snt.strTextString, pt_br.strDefault, N''),
					de.idfsDecorElementType,
					null,
					null,
					isnull(s.blnGrid, 0),
					isnull(s.blnGrid, 0),
					isnull(s.blnFixedRowSet, 0),
					null,
					0,
					isnull(det.intTop, 0),
					isnull(det.intLeft, 0),
					0

		from		dbo.ffDecorElementText det
		inner join	dbo.ffDecorElement de
		on			de.idfDecorElement = det.idfDecorElement
					and de.idfsLanguage = @idfsEnUS
					and de.intRowStatus = 0
					--and p.idfsFormType = @idfsFormType

		inner join	dbo.trtBaseReference det_br
		on			det_br.idfsBaseReference = det.idfsBaseReference
					--and p_br.intRowStatus = 0
		left join	dbo.trtBaseReference pt_br
		on			pt_br.idfsBaseReference = de.idfsDecorElementType
					--and pt_br.intRowStatus = 0

		left join	trtStringNameTranslation det_snt
		on			det_snt.idfsBaseReference = det.idfsBaseReference
					and det_snt.idfsLanguage = @idfsLanguage
		left join	trtStringNameTranslation pt_snt
		on			pt_snt.idfsBaseReference = de.idfsDecorElementType
					and pt_snt.idfsLanguage = @idfsLanguage


		left join	@ControlsInTemplate s
		on			s.idfsFormTemplate = @idfsFormTemplate
					and s.idfsControl = de.idfsSection

		left join	@ControlsInTemplate cit
		on			cit.idfsFormTemplate = @idfsFormTemplate
					and cit.idfsControl = det.idfsBaseReference

		where		de.idfsFormTemplate = @idfsFormTemplate
					and det.intRowStatus = 0
					and (de.idfsSection is null or s.idfsSection is not null)
					and cit.idfsControl is null
					and not exists
						(	select	1
							from	dbo.ffDecorElementText det_other
							join	dbo.ffDecorElement de_other
							on		de_other.idfDecorElement = det_other.idfDecorElement
									and de_other.intRowStatus = 0
							where	det_other.idfsBaseReference = det.idfsBaseReference
									and det_other.intRowStatus = 0
									and de_other.idfsFormTemplate = @idfsFormTemplate
									and de_other.idfsLanguage = @idfsEnUS
									and de_other.idfDecorElement > de.idfDecorElement
						)

		-- Calculate absolute order of the controls in the selected template based on relative positions (top/left) within parent sections/template
		while @GoOn > 0 and @intChildLevel < @intMaxChildLevel /*maximum level of embeded sections*/
		begin
			update		cit
			set			cit.intAbsoluteOrder = isnull(cit_parent.intAbsoluteOrder, 0) + order_within_same_level.intOrder * POWER(cast(100 as bigint), @intMaxChildLevel - @intChildLevel) 
			from		@ControlsInTemplate cit
			cross apply
			(	select	COUNT(cit_order.idfsControl) as intOrder
				from	@ControlsInTemplate cit_order
				where	cit_order.idfsFormTemplate = cit.idfsFormTemplate
						and cit_order.intControlChildLevel = @intChildLevel
						and (	cit_order.idfsControlParentSection = cit.idfsControlParentSection
								or	(	cit_order.idfsControlParentSection is null
										and cit.idfsControlParentSection is null
									)
							)
						and (	(	cit_order.blnParentGrid = 0
									and (	cit_order.intRelativeTop < cit.intRelativeTop
											or	(	cit_order.intRelativeTop = cit.intRelativeTop
													and	(	cit_order.intRelativeLeft < cit.intRelativeLeft
															or	(	cit_order.intRelativeLeft = cit.intRelativeLeft
																	and	(	cit_order.intRelativeOrder < cit.intRelativeOrder
																			or	(	cit_order.intRelativeOrder = cit.intRelativeOrder
																					and (	cit_order.idfControlDesignOption <= cit.idfControlDesignOption
																							or	(	cit_order.idfControlDesignOption is null 
																									and cit.idfControlDesignOption is not null
																								)
																							or	(	cit_order.idfControlDesignOption is null and cit.idfControlDesignOption is null
																									and cit_order.idfsControl <= cit.idfsControl
																								)
																						)
																				)
																		)
																)
														)
												)
										)
								)
								or	(	cit_order.blnParentGrid = 1
										and	(	cit_order.intRelativeLeft < cit.intRelativeLeft
												or	(	cit_order.intRelativeLeft = cit.intRelativeLeft
														and	(	cit_order.intRelativeOrder < cit.intRelativeOrder
																or	(	cit_order.intRelativeOrder = cit.intRelativeOrder
																		and (	cit_order.idfControlDesignOption <= cit.idfControlDesignOption
																				or	(	cit_order.idfControlDesignOption is null 
																						and cit.idfControlDesignOption is not null
																					)
																				or	(	cit_order.idfControlDesignOption is null and cit.idfControlDesignOption is null
																						and cit_order.idfsControl <= cit.idfsControl
																					)
																			)
																	)
															)
													)
											)
									)
							)
			) order_within_same_level

			left join	@ControlsInTemplate cit_parent
			on			cit_parent.idfsControl = cit.idfsControlParentSection

			where	cit.intControlChildLevel = @intChildLevel


			update	cit
			set		cit.intControlChildLevel = @intChildLevel + 1,
					/*Replace parent sub-sections of grids with root grid section*/
					cit.idfsControlRootGridSection = case when cit.blnGrid = 1 and cit.blnParentGrid = 1 then cit_current_level.idfsControlRootGridSection else cit.idfsControlRootGridSection end,
					cit.idfsControlParentForRootGridSection = case when cit.blnGrid = 1 and cit.blnParentGrid = 1 then cit_current_level.idfsControlParentForRootGridSection else cit.idfsControlParentForRootGridSection end,
					cit.strParentSectionName = case when cit.blnGrid = 1 and cit.blnParentGrid = 1 then cit_current_level.strParentSectionName else cit.strParentSectionName end,
					cit.strSectionName = case when cit.blnGrid = 1 and cit.blnParentGrid = 1 then cit_current_level.strSectionName else cit.strSectionName end
			from	@ControlsInTemplate cit
			join	@ControlsInTemplate cit_current_level
			on		cit_current_level.idfsControl = cit.idfsControlParentSection
					and cit_current_level.intControlChildLevel = @intChildLevel

			set @GoOn = @@ROWCOUNT
			set @intChildLevel = @intChildLevel + 1
		end

		select		/*Replace parent sub-sections of grids with root grid section*/
					case when cit.blnGrid = 1 then cit.idfsControlParentForRootGridSection else cit.idfsParentSection end AS idfsParentSection,
					case when cit.blnGrid = 1 then isnull(cit.idfsControlRootGridSection, 0) else isnull(cit.idfsSection, 0) end AS idfsSection,

					cit.idfsControl AS idfsParameter,
					cit.strParentSectionName AS ParentSectionName,
					cit.strSectionName AS SectionName,
					cit.strParameterName AS ParameterName,
					cit.strParameterType AS parameterType,
					cit.idfsParameterType AS idfsParameterType,
					cit.idfsReferenceType AS idfsReferenceType,
					cit.idfsEditor AS idfsEditor,
					cast(2147483646 as int) AS SectionOrder,
					cast((ROW_NUMBER() OVER(PARTITION BY cit.idfsFormTemplate ORDER BY cit.intAbsoluteOrder ASC)) as int) as ParameterOrder,
					cit.blnGrid,
					cit.blnFixedRowSet,
					cit.idfsEditMode,
					cit.idfsFormTemplate,
					cit.strDecorElementText AS DecoreElementText
		from		@ControlsInTemplate cit
		where		/*Remove parent sub-sections of grids with root grid section*/
					(	cit.idfsParameter <> -1 /*Parameter or label*/
						or	(	cit.idfsParameter = -1 /*Section*/
								and (	cit.blnGrid = 0 /*Not table*/
										or	(	cit.blnGrid = 1 /*Table*/
												and cit.blnParentGrid = 0 /*Parent is not table*/
											)
									)
							)
					)
		order by	cit.intAbsoluteOrder


	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT = 1
			ROLLBACK;

		SET @returnCode = ERROR_NUMBER();
		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();;

		THROW;
	END CATCH
END
