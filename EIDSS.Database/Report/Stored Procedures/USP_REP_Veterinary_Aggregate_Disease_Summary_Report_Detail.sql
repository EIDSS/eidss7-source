-- ================================================================================================
-- Name: USP_REP_Veterinary_Aggregate_Disease_Summary_Report_Detail
-- Description: PrintedForm Veterinary Aggregate Report
--          
-- Revision History:
-- Name				Date			Change
-- ---------------	----------	--------------------------------------------------------------------
-- Srini Goli		08/10/2022	Initial release for Veterinary Aggregate Report.
-- Srini Goli		10/07/2022  used Sql Veriant data type.
-- Srini Goli		10/12/2022  Without Templete also have to display Report.
-- Mike Kornegay	10/17/2022	Remove temp table (not compatible with EF Power Tools) and correct final query
-- Mark Wilson		10/18/2022	updated to concatenate string fields
-- Mike Kornegay	10/18/2022	Change intNumRow field in final query to intNumRow
-- Mike Kornegay	02/02/2023	Correct quoted identifiers and ansi_null settings
-- Mike Kornegay	03/13/2023	Correct @tempFlexForm table to match new flex form results
-- Mike Kornegay	04/07/2023	Change group by to remove extra rows where there are note fields.
-- Mike Kornegay	04/11/2023	Change numRow to intNumRow to match human side.
-- Stephen Long     07/12/2023  Fix to use varValue instead of intValue; floating point values.
--
/*

EXEC    [Report].[USP_REP_Veterinary_Aggregate_Disease_Summary_Report_Detail]
        @LangID = N'en-US',
        @idfsAggrCaseType = 10102002,
        @idfAggrCaseList = N'155564770002071;155564770002070'

*/
-- ================================================================================================
CREATE PROCEDURE [Report].[USP_REP_Veterinary_Aggregate_Disease_Summary_Report_Detail] (
	@LangID AS NVARCHAR(50)
	,@idfsAggrCaseType AS  BIGINT= NULL
	,@idfAggrCaseList AS  NVARCHAR(MAX)= NULL
	)
AS
BEGIN
	DECLARE @returnCode INT = 0;
	DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';

	DECLARE @AggrCaseTable TABLE (
		[idfAggrCase] BIGINT,
		[intRowNumber] INT
		)

	DECLARE @tmpMatrix AS TABLE (
		intNumRow INT
		,idfAggrVetCaseMTX BIGINT
		,idfsDiagnosis BIGINT
		,idfsSpeciesType BIGINT
		,strDefault NVARCHAR(2000)
		,strOIECode NVARCHAR(100)
		)

   DECLARE @tempFlexForm TABLE (
		idfsParentSection BIGINT
		,idfsSection BIGINT
		,idfsParameter BIGINT
		,ParentSectionName NVARCHAR(2000)
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
		,DecorElementText NVARCHAR(2000)
		)

	DECLARE @observationsTable TABLE (
		[idfObservation] BIGINT,
		[idfVersion] BIGINT,
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
		fltValue FLOAT,
		[varValue] sql_variant, --NVARCHAR(MAX),
		[intNumRow] INT,
		[ParameterType]  BIGINT
		)

	DECLARE @tmpSpeciesList TABLE (
		[idfBaseReference] BIGINT,
		strDefault NVARCHAR(2000),
		strSpecies NVARCHAR(100),
		[intRowNumber] INT
		--idfsReferenceType BIGINT
		)
	
	DECLARE @tmpDetails TABLE (
		idfCaseObservation BIGINT,
		idfsCaseFormTemplate BIGINT,
		idfVersion BIGINT
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
		intNumRow INT,
		fltValue FLOAT,
		varValue SQL_VARIANT
	)

	DECLARE @GroupByFinalReportTable TABLE 
	(
		ParameterName NVARCHAR(300),
		strSpecies NVARCHAR(300),
		idfsParameter BIGINT,
		ParameterOrder INT,
		idfsDiagnosis BIGINT,
		strDefault NVARCHAR(300),
		strOIECode NVARCHAR(300),
		intNumRow INT,
		intValue INT,
		varValue NVARCHAR(300)
	)

	BEGIN TRY
			BEGIN

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

				--Get this SQl from [dbo].[USP_AGG_CASE_GETDETAIL]
				INSERT INTO @tmpDetails
				SELECT 
					a.idfCaseObservation
					,CaseObs.idfsFormTemplate AS idfsCaseFormTemplate
					,a.idfVersion
				--INTO #tmpDetails
				FROM dbo.tlbAggrCase a	
				LEFT JOIN dbo.tlbObservation CaseObs ON idfCaseObservation = CaseObs.idfObservation
				WHERE a.intRowStatus = 0
				AND a.idfAggrCase IN (SELECT idfAggrCase FROM @AggrCaseTable)
				
				DECLARE @idfsFormTemplate BIGINT,
						@idfVersion BIGINT

				INSERT INTO @observationsTable (
					[idfObservation],
					[idfVersion],
					[idfsCaseFormTemplate],
					[intRowNumber]
					)
				SELECT [idfCaseObservation],
					[idfVersion],
					[idfsCaseFormTemplate],
					ROW_NUMBER() OVER (
						ORDER BY [idfCaseObservation]
						)
				FROM @tmpDetails

				SELECT @idfsFormTemplate=idfsCaseFormTemplate, 
						@idfVersion= idfVersion
				FROM @observationsTable
				--SELECT * FROM @observationsTable

				--Get this SQL from USP_CONF_ADMIN_AggregateVetCaseMatrixReport_GET -- dbo.USP_CONF_ADMIN_AggregateHumanCaseMatrixReport_GET
				INSERT INTO @tmpMatrix
				SELECT	 
					mtx.intNumRow as intNumRow,
					mtx.idfAggrVetCaseMTX,
					mtx.idfsDiagnosis,
					mtx.idfsSpeciesType,
					D.name AS strDefault,
					D.strOIECode

				FROM dbo.tlbAggrVetCaseMTX mtx
				INNER JOIN dbo.FN_GBL_DiagnosisRepair(@LangID, 96, 10020002) D ON D.idfsDiagnosis = mtx.idfsDiagnosis  -- 2 = Human, use 10020002 for Aggregate cases

				WHERE mtx.intRowStatus = 0 AND  mtx.idfVersion = @idfVersion
				--ORDER BY mtx.intNumRow ASC

				--SpicesList
				INSERT INTO @tmpSpeciesList
				EXEC dbo.USP_CONF_GetSpeciesList_GET 
						@idfsBaseReference= 19000086,
						@intHACode=96,
						@strLanguageID=@LangID --@idfVersion=19000086
				
				--Get Flex Form header details
				IF @idfsFormTemplate IS NOT NULL 
				BEGIN
					INSERT INTO @tempFlexForm
					EXEC [dbo].[USP_ADMIN_FF_FlexForm_Get] 
							@LangID =@LangID, 
							@idfsDiagnosis= NULL, 
							@idfsFormType = 10034012, 
							@idfsFormTemplate=@idfsFormTemplate
				END 

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
						[intNumRow],
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
		
				WHERE AP.idfObservation IN (SELECT idfObservation FROM @observationsTable)
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
						[intNumRow],
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
		
				WHERE AP.idfObservation IN (SELECT idfObservation FROM @observationsTable)
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
				    intNumRow,
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
						,SUM(fltValue)
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
				    intNumRow,
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
						,ap.varValue
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
					intNumRow,
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
					t.intNumRow,
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
