


-- ================================================================================================
-- Name: USP_REP_LiveStock_FF_ActivityParameters_GET
-- Description: LiveStock Report
--          
-- Revision History:
-- Name				Date			Change
-- ---------------	----------	--------------------------------------------------------------------
-- Srini Goli		08/15/2022	Initial release for LiveStock Report.
-- Srini Goli		08/25/2022	Added Distinct Clause.
/*
		--Use below codes for idfsFormType
        LivestockAnimalClinicalSigns = 10034013,
        LivestockControlMeasures = 10034014,
        LivestockFarmFarmEpidemiologicalInfo = 10034015,
        LivestockSpeciesClinicalInvestigation = 10034016

--AnimalClinicalSigns
EXEC    [Report].[USP_REP_LiveStock_FF_ActivityParameters_GET]
        @LangID = N'en-US',  --ka-GE
        @idfsFormType = 10034013,
        @ObjID = '5604'

--ControlMeasures
EXEC    [Report].[USP_REP_LiveStock_FF_ActivityParameters_GET]
        @LangID = N'en-US',  --ka-GE
        @idfsFormType = 10034014,
        @ObjID = '5604'

--EPI
EXEC    [Report].[USP_REP_LiveStock_FF_ActivityParameters_GET]
        @LangID = N'ka-GE',  --ka-GE,
        @idfsFormType = 10034015,
        @ObjID = '5604'

--Species
EXEC    [Report].[USP_REP_LiveStock_FF_ActivityParameters_GET]
        @LangID = N'en-US',  --ka-GE,
        @idfsFormType = 10034016,
        @ObjID = '5604'
*/
-- ================================================================================================
CREATE PROCEDURE [Report].[USP_REP_LiveStock_FF_ActivityParameters_GET] (
	@LangID AS NVARCHAR(50)
	,@idfsFormType AS  BIGINT= NULL
	,@ObjID AS BIGINT= NULL --idfVetCase
	)
AS
BEGIN
	DECLARE @idfsCountry AS BIGINT,
			@idfsLanguage BIGINT = dbo.FN_GBL_LanguageCode_GET(@LangID),
			@idfsEnglish BIGINT = dbo.FN_GBL_LanguageCode_GET('en-US')
	DECLARE @tmpTemplate AS TABLE (
		idfsFormTemplate BIGINT
		,IsUNITemplate BIT
		)

	DECLARE @returnCode INT = 0;
	DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';

   DECLARE @tempFlexForm TABLE (
		idfsParentSection BIGINT
		,idfsSection BIGINT
		,idfsParameter BIGINT
		,SectionNameDefault NVARCHAR(2000)
		,SectionName NVARCHAR(2000)
		,ParameterName NVARCHAR(2000)
		,parameterType NVARCHAR(1000)
		,idfsParameterType BIGINT
		,idfsReferenceType BIGINT
		,idfsEditor BIGINT
		,SectionOrder INT
		,ParameterOrder INT
		,blnGrid BIT
		,blnFixedRowSet BIT
		,idfsEditMode BIGINT
		,idfsFormTemplate BIGINT
		)

	DECLARE @tmpActivityParameters TABLE (
		[idfActivityParameters] BIGINT,
		[idfObservation] BIGINT,
		[idfsFormTemplate] BIGINT,
		[idfsParameter] BIGINT,
		[idfsSection] BIGINT,
		[idfRow] BIGINT,
		[Type] BIGINT,
		[varValue] sql_variant,
		[numRow] INT,
		[ParameterType]  BIGINT
		)

	DECLARE @observationsTable TABLE (
		[idfsFormType] BIGINT,
		[idfObservation] BIGINT
		)

	BEGIN TRY
			BEGIN
				DECLARE @idfsFormTemplate BIGINT,
						@idfObservation BIGINT

				--Get this logic from dbo.USP_ADMIN_FF_FlexForm_Get
				IF @idfsFormTemplate IS NULL
					BEGIN
						--Obtain idfsFormTemplate, via given parameters of idfsDiagnosis and idfsFormType
						---------------------------------------------------------------------------------
						SET @idfsCountry = dbo.FN_GBL_CurrentCountry_GET()

						INSERT INTO @tmpTemplate
						EXECUTE dbo.USP_ADMIN_FF_ActualTemplate_GET 
							@idfsCountry,
							@ObjID,
							@idfsFormType

						SELECT TOP 1 @idfsFormTemplate = idfsFormTemplate
						FROM @tmpTemplate

						IF @idfsFormTemplate = - 1
							SET @idfsFormTemplate = NULL

						---------------------------------------------------------------------------------
					END

				--Get Flex Form header details
				INSERT INTO @tempFlexForm
				SELECT 
					s.idfsParentSection
					,COALESCE(p.idfsSection,0) AS idfsSection
					,p.idfsParameter
					,RF.strDefault AS SectionNameDefault
					,RF.Name AS SectionName
					,PN.Name AS ParameterName
					,PTR.Name AS parameterType
					,p.idfsParameterType
					,pt.idfsReferenceType
					,p.idfsEditor
					,sdo.intOrder	AS SectionOrder
					,ISNULL(PDO.intOrder,PDOE.intOrder)	AS ParameterOrder
					,s.blnGrid
					,s.blnFixedRowSet
					,PFT.idfsEditMode
					,pft.idfsFormTemplate
				FROM dbo.ffParameter p
				LEFT JOIN dbo.ffParameterForTemplate PFT ON PFT.idfsParameter = p.idfsParameter AND PFT.intRowStatus = 0
				LEFT JOIN dbo.ffSection s ON s.idfsSection = p.idfsSection
				LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000101) RF ON S.idfsSection = RF.idfsReference
				LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000071) PTR ON PTR.idfsReference = P.idfsParameterType
				LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000066) PN ON PN.idfsReference = P.idfsParameter
				LEFT JOIN dbo.ffParameterDesignOption PDO ON PFT.idfsParameter = PDO.idfsParameter
					AND PFT.idfsFormTemplate = PDO.idfsFormTemplate
					AND PDO.idfsLanguage = @idfsLanguage
					AND PDO.intRowStatus = 0
				LEFT JOIN dbo.ffParameterDesignOption PDOE ON PFT.idfsParameter = PDOE.idfsParameter
					AND PFT.idfsFormTemplate = PDOE.idfsFormTemplate
					AND PDOE.idfsLanguage = @idfsEnglish
					AND PDOE.intRowStatus = 0
				LEFT JOIN dbo.ffSectionDesignOption sdo ON sdo.idfsSection = s.idfsSection 
					AND sdo.idfsFormTemplate = @idfsFormTemplate 
					AND sdo.idfsLanguage = @idfsLanguage
					AND sdo.intRowStatus = 0
				LEFT JOIN dbo.ffParameterType PT
					ON pt.idfsParameterType = p.idfsParameterType
				WHERE PFT.idfsFormTemplate = @idfsFormTemplate
				ORDER BY  sdo.intOrder
					,pdo.intOrder
				
				--To Get Correct ObservationID	
				INSERT INTO @observationsTable(idfsFormType,idfObservation)
				SELECT 
					@idfsFormType as idfsFormType,
					CASE WHEN @idfsFormType=10034013 THEN ani.idfObservation --For AnimalClinicalSigns
						 WHEN @idfsFormType=10034014 THEN a.idfObservation --For ControlMeasures
						 WHEN @idfsFormType=10034015 THEN f.idfObservation --For EPI
						 WHEN @idfsFormType=10034016 THEN s.idfObservation --For SpeciesClinicalInvestigation
					END as idfObservation
				FROM dbo.tlbVetCase a	
				LEFT JOIN dbo.tlbFarm f ON a.idfFarm=f.idfFarm --EPI
				LEFT JOIN dbo.tlbHerd h ON h.idfFarm=f.idfFarm
				LEFT JOIN dbo.tlbMaterial m on m.idfVetCase=a.idfVetCase
				LEFT JOIN dbo.tlbSpecies s on s.idfHerd =h.idfHerd   --Mutiple rows(more than one idfObservation for Species)
				LEFT JOIN dbo.tlbAnimal ani ON ani.idfSpecies=s.idfSpecies --Mutiple rows(more than one idfObservation for Animal)
				WHERE a.intRowStatus = 0
				AND a.idfVetCase = @ObjID

				--Get Activity Parameters (dbo.USP_ADMIN_FF_ActivityParameters_GET)
				INSERT INTO @tmpActivityParameters  (
						[idfActivityParameters],
						[idfObservation],
						[idfsFormTemplate],
						[idfsParameter],
						[idfsSection],
						[idfRow],
						[varValue],
						[Type],
						[numRow],
						[ParameterType]  
				)
				SELECT 
					AP.idfActivityParameters,
					AP.idfObservation,
					O.idfsFormTemplate,
					AP.idfsParameter,
					P.idfsSection,
					AP.idfRow,
					AP.varValue,
					dbo.FN_ADMIN_FF_TypeActivityParameters_GET(AP.idfsParameter),
					ROW_NUMBER() OVER (
						PARTITION BY AP.idfObservation ORDER BY AP.idfRow
						), 
					P.idfsParameterType
				FROM dbo.tlbActivityParameters AP
				LEFT JOIN dbo.ffParameter P	ON P.idfsParameter = AP.idfsParameter AND P.intRowStatus = 0
				INNER JOIN dbo.tlbObservation O ON AP.idfObservation = O.idfObservation
				
				WHERE AP.idfObservation IN (SELECT DISTINCT idfObservation FROM @observationsTable WHERE idfsFormType=@idfsFormType)
				AND AP.intRowStatus = 0
				AND O.intRowStatus = 0
				ORDER BY 
					AP.idfObservation,
					P.idfsSection,
					AP.idfRow

				--Report
				SELECT	DISTINCT 
						ff.ParameterName
						,ff.SectionName
						,ff.SectionNameDefault
						,ap.idfActivityParameters
						,ap.idfRow
						--,SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') AS varValueType
						,ff.idfsParameter
						,ap.Type
						,ff.ParameterOrder
						,ap.varValue AS varValue
						,CASE SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') 
							WHEN 'nvarchar' THEN CAST(ap.varValue AS NVARCHAR(300)) 
							ELSE ISNULL(SNT.strTextString, BR.strDefault) END AS strNameValue
						,@idfsFormType AS idfsFormType
						,ot.idfObservation
				FROM @tempFlexForm ff 
				CROSS JOIN @observationsTable ot 
				LEFT JOIN @tmpActivityParameters ap ON ff.idfsParameter=ap.idfsParameter AND ot.idfObservation=ap.idfObservation
				LEFT JOIN dbo.ffParameter P ON ap.idfsParameter = P.idfsParameter AND P.idfsEditor = 10067002 AND P.intRowStatus = 0
				--LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000066) FFP ON FFP.idfsReference = CASE WHEN CAST(SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') AS NVARCHAR(10)) = 'bigint'																			 
				--																							 THEN CAST(ap.varValue AS BIGINT)
				--																								--ELSE -1
				--																								END 
				
				LEFT JOIN dbo.trtBaseReference BR ON BR.idfsBaseReference = CASE WHEN CAST(SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') AS NVARCHAR(10)) = 'bigint'																			 
																				 THEN CAST(ap.varValue AS BIGINT)
																			--ELSE - 1
																			END 
				LEFT JOIN dbo.trtStringNameTranslation SNT ON SNT.idfsBaseReference = CASE WHEN (SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') = 'bigint')																				 
																				 THEN CAST(ap.varValue AS BIGINT)
																			--ELSE - 1
																			END 
															AND SNT.idfsLanguage = @idfsLanguage AND SNT.intRowStatus = 0

				ORDER BY 12,8 --ap.idfObservation,ff.ParameterOrder

			END

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT = 1
			ROLLBACK;

		SET @returnCode = ERROR_NUMBER();
		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();;

		THROW;
	END CATCH
END