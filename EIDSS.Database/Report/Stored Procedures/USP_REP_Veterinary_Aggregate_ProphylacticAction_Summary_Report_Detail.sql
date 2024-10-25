-- ================================================================================================
-- Name: USP_REP_Veterinary_Aggregate_ProphylacticAction_Summary_Report_Detail
-- Description: PrintedForm Veterinary Aggregate Report
--          
-- Revision History:
-- Name				Date			Change
-- ---------------	----------	--------------------------------------------------------------------
-- Mark Wilson		10/11/2022  initial cut.
-- Mike Kornegay	10/17/2022	Remove temp table (not compatible with EF Power Tools)
-- Mike Kornegay	10/25/2022  Separate numerical results from string results
-- Mike Kornegay	03/27/2023	Change numeric values from int to float.
--
/*

EXEC    [Report].[USP_REP_Veterinary_Aggregate_ProphylacticAction_Summary_Report_Detail]
        @LangID = N'en-US',
        @idfAggrCaseList = '128822070001294;127398630001294;121195250001294'

*/
-- ================================================================================================
CREATE PROCEDURE [Report].[USP_REP_Veterinary_Aggregate_ProphylacticAction_Summary_Report_Detail] 
(
	@LangID AS NVARCHAR(50),
	@idfAggrCaseList AS  NVARCHAR(MAX)= NULL
)
AS
BEGIN
	DROP TABLE IF EXISTS #tmpDetails;

	DECLARE @idfsCountry AS BIGINT,
			@idfsLanguage BIGINT = dbo.FN_GBL_LanguageCode_GET(@LangID);

	DECLARE @returnCode INT = 0;
	DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';

	DECLARE @AggrCaseTable TABLE (
		[idfAggrCase] BIGINT,
		[intRowNumber] INT
		)

	--Get Selected Agg Cases
	INSERT INTO @AggrCaseTable (
			[idfAggrCase],
			[intRowNumber]
			)
	SELECT CAST([Value] AS BIGINT),
		ROW_NUMBER() OVER (
			ORDER BY [Value]
			)
	FROM [dbo].[FN_GBL_SYS_SplitList](@idfAggrCaseList, NULL, NULL)

	DECLARE @tmpMatrix AS TABLE (
		intNumRow INT
		,idfAggrVetCaseMTX BIGINT
		,idfsDiagnosis BIGINT
		,idfsSpeciesType BIGINT
		,strDefault NVARCHAR(2000)
		,strOIECode NVARCHAR(100)
		,strActionCode NVARCHAR(200)
		,strAction NVARCHAR(300)
		)

   DECLARE @tempFlexForm TABLE (
		idfsParentSection BIGINT
		,idfsSection BIGINT
		,idfsParameter BIGINT
		,SectionName NVARCHAR(2000)
		,ParameterName NVARCHAR(500)
		,parameterType NVARCHAR(100)
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

	DECLARE @observationsTable TABLE (
		[idfProphylacticObservation] BIGINT,
		[idfProphylacticVersion] BIGINT,
		[idfsCaseFormTemplate] BIGINT,
		[intRowNumber] INT
		)

	DECLARE @tmpActivityParameters TABLE (
		[idfActivityParameters] BIGINT,
		[idfObservation] BIGINT,
		[idfsFormTemplate] BIGINT,
		[idfsParameter] BIGINT,
		[idfsSection] BIGINT,
		[idfRow] BIGINT,
		[Type] BIGINT,
		[fltValue] FLOAT,
		[varValue] sql_variant, --NVARCHAR(MAX),
		[numRow] INT,
		[ParameterType]  BIGINT
		)

	DECLARE @tmpSpeciesList TABLE (
		[idfBaseReference] BIGINT,
		strDefault NVARCHAR(2000),
		strSpecies NVARCHAR(100),
		[intRowNumber] INT
		)

	DECLARE @tmpDetails TABLE (
		idfProphylacticObservation BIGINT,
		idfsCaseFormTemplate BIGINT,
		idfProphylacticVersion BIGINT
	)

	DECLARE @FinalReportTable TABLE 
	(
		ParameterName NVARCHAR(300),
		strSpecies NVARCHAR(300),
		idfsParameter BIGINT,
		ParameterOrder INT,
		idfsDiagnosis BIGINT,
		strDefault NVARCHAR(300),
		strOIECode NVARCHAR(300),
		numRow INT,
		fltValue FLOAT,
		varValue SQL_VARIANT,
		strActionCode NVARCHAR(300),
		strAction NVARCHAR(300)
	)

	BEGIN TRY

			BEGIN


				--Get this SQl from [dbo].[USP_AGG_CASE_GETDETAIL]
				INSERT INTO @tmpDetails
				SELECT 
					a.idfProphylacticObservation
					,CaseObs.idfsFormTemplate AS idfsCaseFormTemplate
					,a.idfProphylacticVersion
				--INTO #tmpDetails
				FROM dbo.tlbAggrCase a	
				LEFT JOIN dbo.tlbObservation CaseObs ON a.idfProphylacticObservation = CaseObs.idfObservation
				WHERE a.intRowStatus = 0
				AND a.idfAggrCase IN (SELECT idfAggrCase FROM @AggrCaseTable)

				DECLARE @idfsFormTemplate BIGINT,
						@idfVersion BIGINT

				INSERT INTO @observationsTable (
					[idfProphylacticObservation],
					[idfProphylacticVersion],
					[idfsCaseFormTemplate],
					[intRowNumber]
					)
				SELECT [idfProphylacticObservation],
					idfProphylacticVersion,
					idfsCaseFormTemplate,
					ROW_NUMBER() OVER (
						ORDER BY [idfProphylacticObservation]
						)
				FROM @tmpDetails

				SELECT @idfsFormTemplate=idfsCaseFormTemplate, 
						@idfVersion= idfProphylacticVersion
				FROM @observationsTable
				--SELECT * FROM @observationsTable

				--Get this SQL from USP_CONF_ADMIN_AggregateVetCaseMatrixReport_GET -- dbo.USP_CONF_ADMIN_AggregateHumanCaseMatrixReport_GET
				INSERT INTO @tmpMatrix
				SELECT	 
					mtx.intNumRow as intNumRow,
					mtx.idfAggrProphylacticActionMTX,
					mtx.idfsDiagnosis,
					mtx.idfsSpeciesType,
					D.name AS strDefault,
					D.strOIECode,
					PAC.strActionCode,
					PA.name AS strAction

				FROM dbo.tlbAggrProphylacticActionMTX mtx
				INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000074) PA ON PA.idfsReference = mtx.idfsProphilacticAction
				INNER JOIN dbo.trtProphilacticAction PAC ON PAC.idfsProphilacticAction = PA.idfsReference
				INNER JOIN dbo.FN_GBL_DiagnosisRepair(@LangID, 96, 10020002) D ON D.idfsDiagnosis = mtx.idfsDiagnosis  -- 2 = Human, use 10020002 for Aggregate cases

				WHERE mtx.intRowStatus = 0 AND  mtx.idfVersion = @idfVersion
				ORDER BY mtx.intNumRow ASC

--------------------------------------------------------------------------------------------------------------------------------
				--SpeiciesList
				INSERT INTO @tmpSpeciesList
				EXEC dbo.USP_CONF_GetSpeciesList_GET 
						@idfsBaseReference= 19000086,
						@intHACode=96,
						@strLanguageID=@LangID --@idfVersion=19000086
				
				--Get Flex Form for Prophylactic Actions details
				INSERT INTO @tempFlexForm
				SELECT 
					s.idfsParentSection
					,COALESCE(p.idfsSection,0) AS idfsSection
					,p.idfsParameter
					,RF.Name AS SectionName
					,PN.Name AS ParameterName
					,PTR.Name AS parameterType
					,p.idfsParameterType
					,pt.idfsReferenceType
					,p.idfsEditor
					,sdo.intOrder	AS SectionOrder
					,PDO.intOrder	AS ParameterOrder
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
				LEFT JOIN dbo.ffSectionDesignOption sdo ON sdo.idfsSection = s.idfsSection 
					AND sdo.idfsFormTemplate = @idfsFormTemplate 
					AND sdo.idfsLanguage = @idfsLanguage
					AND sdo.intRowStatus = 0
				LEFT JOIN dbo.ffParameterType PT
					ON pt.idfsParameterType = p.idfsParameterType
				WHERE PFT.idfsFormTemplate = @idfsFormTemplate


				--EXEC [dbo].[USP_ADMIN_FF_FlexForm_Get] 
				--		@LangID =@LangID, 
				--		@idfsDiagnosis= NULL, 
				--		@idfsFormType = 10034023, 
				--		@idfsFormTemplate=@idfsFormTemplate

--				SELECT * FROM @tempFlexForm

				--Get Activity Parameters
				--INSERT INTO @tmpActivityParameters
				--EXEC dbo.USP_ADMIN_FF_ActivityParameters_GET
				--		@observationList = @observationList, 
				--		@LangID = @LangID

				--Get numeric values activity parameters
				INSERT INTO @tmpActivityParameters  (
						[idfActivityParameters],
						[idfObservation],
						[idfsFormTemplate],
						[idfsParameter],
						[idfsSection],
						[idfRow],
						[fltValue],
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
					SUM(CAST(AP.varValue AS FLOAT)),
					--CAST(AP.varValue AS NVARCHAR(MAX)),
					dbo.FN_ADMIN_FF_TypeActivityParameters_GET(AP.idfsParameter),
					ROW_NUMBER() OVER (
						PARTITION BY AP.idfObservation ORDER BY AP.idfRow
						), 
					P.idfsParameterType
				FROM dbo.tlbActivityParameters AP
				LEFT JOIN dbo.ffParameter P	ON P.idfsParameter = AP.idfsParameter AND P.intRowStatus = 0
				INNER JOIN dbo.tlbObservation O ON AP.idfObservation = O.idfObservation
		
				WHERE AP.idfObservation IN (SELECT idfProphylacticObservation FROM @observationsTable)
				AND ISNUMERIC(CAST(AP.varValue AS NVARCHAR)) = 1
				AND AP.intRowStatus = 0
				AND O.intRowStatus = 0

				GROUP BY
					AP.idfActivityParameters,
					AP.idfObservation,
					O.idfsFormTemplate,
					AP.idfsParameter,
					P.idfsSection,
					AP.idfRow,
					dbo.FN_ADMIN_FF_TypeActivityParameters_GET(AP.idfsParameter),
					P.idfsParameterType
				ORDER BY 
					AP.idfObservation,
					P.idfsSection,
					AP.idfRow

				--Get non-numeric values activity parameters
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
		
				WHERE AP.idfObservation IN (SELECT idfProphylacticObservation FROM @observationsTable)
				AND ISNUMERIC(CAST(AP.varValue AS NVARCHAR)) = 0
				AND AP.intRowStatus = 0
				AND O.intRowStatus = 0

				ORDER BY 
					AP.idfObservation,
					P.idfsSection,
					AP.idfRow

				--Report
				INSERT INTO @FinalReportTable
				(
					ParameterName,
				    strSpecies,
				    idfsParameter,
				    ParameterOrder,
				    idfsDiagnosis,
				    strDefault,
				    strOIECode,
				    numRow,
				    strActionCode,
					strAction,
					fltValue
				)

				SELECT	ff.ParameterName
						,sl.strSpecies
						,ff.idfsParameter
						,ff.ParameterOrder
						,m.idfsDiagnosis
						,m.strDefault
						,m.strOIECode
						,m.intNumRow
						,m.strActionCode
						,m.strAction
						,SUM(fltValue)
						--,SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType')

				FROM @tempFlexForm ff 
				CROSS JOIN @tmpMatrix m 
				LEFT JOIN @tmpActivityParameters ap ON ff.idfsParameter=ap.idfsParameter AND m.idfAggrVetCaseMTX=ap.idfRow
				LEFT JOIN @tmpSpeciesList sl ON sl.idfBaseReference=m.idfsSpeciesType
				GROUP BY
					ff.ParameterName
					,sl.strSpecies
					,ff.idfsParameter
					,ff.ParameterOrder
					,m.idfsDiagnosis
					,m.strDefault
					,m.strOIECode
					,m.intNumRow
					,m.strActionCode
					,m.strAction
					--,SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType')
				ORDER BY intNumRow

				--non numeric items
				INSERT INTO @FinalReportTable
				(
					ParameterName,
				    strSpecies,
				    idfsParameter,
				    ParameterOrder,
				    idfsDiagnosis,
				    strDefault,
				    strOIECode,
				    numRow,
				    strActionCode,
					strAction,
					varValue
				)

				SELECT	ff.ParameterName
						,sl.strSpecies
						,ff.idfsParameter
						,ff.ParameterOrder
						,m.idfsDiagnosis
						,m.strDefault
						,m.strOIECode
						,m.intNumRow
						,m.strActionCode
						,m.strAction
						,ap.varValue
						--,SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType')

				FROM @tempFlexForm ff 
				CROSS JOIN @tmpMatrix m 
				LEFT JOIN @tmpActivityParameters ap ON ff.idfsParameter=ap.idfsParameter AND m.idfAggrVetCaseMTX=ap.idfRow
				LEFT JOIN @tmpSpeciesList sl ON sl.idfBaseReference=m.idfsSpeciesType
				WHERE ap.varValue IS NOT NULL
				
				ORDER BY intNumRow

				--final query
				SELECT 
					ParameterName,
					strSpecies,
					idfsParameter,
					ParameterOrder,
					idfsDiagnosis,
					strDefault,
					strOIECode,
					numRow AS intNumRow,
					strAction,
					strActionCode,
					CAST(fltValue AS NVARCHAR(300)) AS varValue
					
				FROM @FinalReportTable
				WHERE varValue IS NULL

				UNION ALL 

				SELECT
					DISTINCT t.ParameterName,
					t.strSpecies,
					t.idfsParameter,
					t.ParameterOrder,
					t.idfsDiagnosis,
					t.strDefault,
					t.strOIECode,
					t.numRow AS intNumRow,
					strAction,
					strActionCode,
					STUFF((SELECT distinct ', ' + CAST(t1.varValue AS NVARCHAR(300))
						 FROM @FinalReportTable t1
						 WHERE t.ParameterName = t1.ParameterName
						 AND t.strSpecies = t1.strSpecies
						 AND t.idfsParameter = t1.idfsParameter
						 AND t.ParameterOrder = t1.ParameterOrder
						 AND t.idfsDiagnosis = t1.idfsDiagnosis
						 AND t.strDefault = t1.strDefault
						 AND t.strOIECode = t1.strOIECode
						 FOR XML PATH(''), TYPE
							).value('.', 'NVARCHAR(MAX)') 
						,1,2,'') varValue
				from @FinalReportTable t
				WHERE t.varValue IS NOT NULL;				
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
