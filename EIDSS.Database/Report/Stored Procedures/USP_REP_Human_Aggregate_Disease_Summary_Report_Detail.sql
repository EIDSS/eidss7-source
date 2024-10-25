
-- ================================================================================================
-- Name: USP_REP_Human_Aggregate_Disease_Summary_Report_Detail
-- Description: PrintedForm Human Aggregate Report
--          
-- Revision History:
-- Name				Date			Change
-- ---------------	----------	--------------------------------------------------------------------
-- Srini Goli		08/24/2022	Initial release for Human Aggregate Report.
-- Srini Goli		10/07/2022  used Sql Veriant data type.
-- Mike Kornegay	10/17/2022	Remove temp table (not compatible with EF Power Tools)
-- Mark Wilson  	03/30/2023	added two new fields to @tempFlexForm to support changes to USP_ADMIN_FF_FlexForm_Get
/*

EXEC    [Report].[USP_REP_Human_Aggregate_Disease_Summary_Report_Detail]
        @LangID = N'en-US',
        @idfsAggrCaseType = 10102001,
        @idfAggrCaseList = '155564770001958;155564770001956'

*/
-- ================================================================================================
CREATE PROCEDURE [Report].[USP_REP_Human_Aggregate_Disease_Summary_Report_Detail] (
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
		,idfAggrHumanCaseMTX BIGINT
		,idfsDiagnosis BIGINT
		,strDefault NVARCHAR(2000)
		,strIDC10 NVARCHAR(100)
		)

   DECLARE @tempFlexForm TABLE (
		idfsParentSection BIGINT
		,idfsSection BIGINT
		,idfsParameter BIGINT
		,ParentSectionName NVARCHAR(2000) -- added by MCW
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
		,DecorElementText NVARCHAR(200) -- added by MCW
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
		--[intNumRow] INT,
		[Type] BIGINT,
		[varValue] sql_variant,
		--[strNameValue] NVARCHAR(200),
		[numRow] INT,
		--[FakeField ] INT,
		[ParameterType]  BIGINT
		)

	DECLARE @tmpDetails TABLE (
		idfCaseObservation BIGINT,
		idfsCaseFormTemplate BIGINT,
		idfVersion BIGINT
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
				--AND (@idfAggrCase IS NULL OR a.idfAggrCase = @idfAggrCase)
				--	AND (
				--		CASE 
				--			WHEN @idfsAggrCaseType IS NULL
				--				THEN 1
				--			WHEN ISNULL(a.idfsAggrCaseType, '') = @idfsAggrCaseType
				--				THEN 1
				--			ELSE 0
				--			END = 1
				--		)
				--	AND (
				--		CASE 
				--			WHEN @idfAggrCase IS NULL
				--				THEN 1
				--			WHEN ISNULL(a.idfAggrCase, '') = @idfAggrCase
				--				THEN 1
				--			ELSE 0
				--			END = 1
				--		);
				
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


				--Get this SQL from dbo.USP_CONF_ADMIN_AggregateHumanCaseMatrixReport_GET
				INSERT INTO @tmpMatrix
				SELECT	 
					mtx.intNumRow as intNumRow,
					mtx.idfAggrHumanCaseMTX,
					mtx.idfsDiagnosis,
					D.name AS strDefault,
					D.strIDC10

				FROM dbo.tlbAggrHumanCaseMTX mtx
				INNER JOIN dbo.FN_GBL_DiagnosisRepair(@LangID, 2, 10020002) D ON D.idfsDiagnosis = mtx.idfsDiagnosis  -- 2 = Human, use 10020002 for Aggregate cases
		
				WHERE mtx.intRowStatus = 0 AND mtx.idfVersion = @idfVersion

				--Get Flex Form header details
				INSERT INTO @tempFlexForm
				EXEC [dbo].[USP_ADMIN_FF_FlexForm_Get] 
						@LangID =@LangID, 
						@idfsDiagnosis= NULL, 
						@idfsFormType = 10034012, 
						@idfsFormTemplate=@idfsFormTemplate

				--Get Activity Parameters
				--INSERT INTO @tmpActivityParameters
				--EXEC dbo.USP_ADMIN_FF_ActivityParameters_GET
				--		@observationList = @observationList, 
				--		@LangID = @LangID
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
					--CAST(AP.varValue AS NVARCHAR(MAX)),
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
				AND AP.intRowStatus = 0
				AND O.intRowStatus = 0
				ORDER BY 
					AP.idfObservation,
					P.idfsSection,
					AP.idfRow


				--Report
				SELECT	ff.ParameterName
						,ff.idfsParameter
						,ff.ParameterOrder
						,m.idfsDiagnosis
						,m.strDefault
						,m.strIDC10
						,m.intNumRow
						,ap.varValue as varValue--ap.idfRow,m.idfAggrHumanCaseMTX as idfRow
				FROM @tempFlexForm ff 
				CROSS JOIN @tmpMatrix m 
				LEFT JOIN @tmpActivityParameters ap ON ff.idfsParameter=ap.idfsParameter and m.idfAggrHumanCaseMTX=ap.idfRow
				ORDER BY intNumRow

				--Test
				--Dynamic Pivot
				--DECLARE @ColumnToPivot  NVARCHAR(255),
				--		@ListToPivot    NVARCHAR(255),
				--		@SqlStatement NVARCHAR(MAX)
				--SET @ColumnToPivot='ParameterName'
				--SELECT @ListToPivot= COALESCE(@ListToPivot + ',','') +  N'[' + CAST(ff.ParameterName AS varchar(100)) + ']'
				--FROM @tempFlexForm ff
				--ORDER BY ParameterOrder

				----SELECT @ListToPivot
				----EXEC dbo.USP_ADMIN_DynamicPivotTableInSql @ColumnToPivot,@ListToPivot

				--  SET @SqlStatement = N'
				--	SELECT * FROM (
				--	  SELECT
				--	    [intNumRow],
				--		[strDefault],
				--		[strIDC10],
				--		[ParameterName],
				--		[varValue]
				--	  FROM #tempReport
				--	) Results
				--	PIVOT (
				--	  MAX([varValue])
				--	  FOR ['+@ColumnToPivot+']
				--	  IN (
				--		'+@ListToPivot+'
				--	  )
				--	) AS PivotTable
				--	ORDER BY intNumRow
				--  ';

			END

		--DROP TABLE IF EXISTS #tmpDetails;

	END TRY

	BEGIN CATCH
		--IF @@TRANCOUNT = 1
			--ROLLBACK;

		SET @returnCode = ERROR_NUMBER();
		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();;

		THROW;
	END CATCH
END
GO




