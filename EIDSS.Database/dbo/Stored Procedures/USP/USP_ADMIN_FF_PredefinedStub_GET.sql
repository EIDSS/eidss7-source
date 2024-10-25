

-- ================================================================================================
-- Name: USP_ADMIN_FF_PredefinedStub_GET
-- Description: Returns the List of Parameter Editors
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Kishore Kodru   11/28/2018 Initial release for new API.
-- Stephen Long    08/20/2019 Commented call to actual template get.  Currently set to never return
--                            any data.  Also the insert/exec call are more than one deep causing 
--                            SQL to throw an error.
-- Stephen Long    09/24/2019 Fixed to COALESCE null values (IDC10, OIE and action codes).  This 
--                            was throwing off the matrix prestub lists on the summary reports. 
-- ================================================================================================
/*
exec dbo.spFFGetPredefinedStub 71090000000, 6750110000000, 'en'
*/
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_PredefinedStub_GET] (
	@MatrixID BIGINT,
	@VersionList VARCHAR(600),
	@LangID NVARCHAR(50) = NULL,
	@idfsFormTemplate BIGINT = NULL
	/*    
    VetCase = 71090000000
    DiagnosticAction = 71460000000
    ProphylacticAction = 71300000000
    HumanCase = 71190000000
    SanitaryAction = 71260000000
    FormN1= 82350000000 HumanCase
    */
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF (@LangID IS NULL)
		SET @LangID = 'en';

	DECLARE @langid_int BIGINT,
		@idfVersion BIGINT,
		@returnCode BIGINT,
		@returnMsg NVARCHAR(MAX),
		@idfRow BIGINT,
		@idfsParameter BIGINT,
		@strDefaultParameterName NVARCHAR(600),
		@idfsParameterValue NVARCHAR(MAX),
		@strNameValue NVARCHAR(600),
		@idfRowCurrent BIGINT,
		@NumRowCurrent INT,
		@NumRowTemp INT,
		@currentVersion BIGINT,
		@VetCaseMTX BIGINT,
		@ProphylacticMTX BIGINT,
		@DiagnosticMTX BIGINT,
		@HumanCaseMTX BIGINT,
		@SanitaryMTX BIGINT,
		-- VetCaseMTX
		@vac_SpeciesColumn BIGINT,
		@vac_SpeciesColumnName NVARCHAR(2000),
		@vac_SpeciesColumnOrder INT,
		@vac_DiagnosisColumn BIGINT,
		@vac_DiagnosisColumnName NVARCHAR(2000),
		@vac_DiagnosisColumnOrder INT,
		@vac_OIECodeColumn BIGINT,
		@vac_OIECodeColumnName NVARCHAR(2000),
		@vac_OIECodeColumnOrder INT,
		--ProphylacticMTX
		@p_SpeciesColumn BIGINT,
		@p_SpeciesColumnName NVARCHAR(2000),
		@p_SpeciesColumnOrder INT,
		@p_DiagnosisColumn BIGINT,
		@p_DiagnosisColumnName NVARCHAR(2000),
		@p_DiagnosisColumnOrder INT,
		@p_OIECodeColumn BIGINT,
		@p_OIECodeColumnName NVARCHAR(2000),
		@p_OIECodeColumnOrder INT,
		@p_ProphylacticColumn BIGINT,
		@p_ProphylacticColumnName NVARCHAR(2000),
		@p_ProphylacticColumnOrder INT,
		@p_ProphylacticCodeColumn BIGINT,
		@p_ProphylacticCodeColumnName NVARCHAR(2000),
		@p_ProphylacticCodeColumnOrder INT,
		--DiagnosticMTX
		@d_SpeciesColumn BIGINT,
		@d_SpeciesColumnName NVARCHAR(2000),
		@d_SpeciesColumnOrder INT,
		@d_DiagnosisColumn BIGINT,
		@d_DiagnosisColumnName NVARCHAR(2000),
		@d_DiagnosisColumnOrder INT,
		@d_OIECodeColumn BIGINT,
		@d_OIECodeColumnName NVARCHAR(2000),
		@d_OIECodeColumnOrder INT,
		@d_DiagnosticColumn BIGINT,
		@d_DiagnosticColumnName NVARCHAR(2000),
		@d_DiagnosticColumnOrder INT,
		--HumanCaseMTX
		@hc_DiagnosisColumn BIGINT,
		@hc_DiagnosisColumnName NVARCHAR(2000),
		@hc_DiagnosisColumnOrder INT,
		@hc_ICD10CodeColumn BIGINT,
		@hc_ICD10CodeColumnName NVARCHAR(2000),
		@hc_ICD10CodeColumnOrder INT,
		--SanitaryMTX
		@s_SanitaryActionColumn BIGINT,
		@s_SanitaryActionColumnName NVARCHAR(2000),
		@s_SanitaryActionColumnOrder INT,
		@s_SanitaryActionCodeColumn BIGINT,
		@s_SanitaryActionCodeColumnName NVARCHAR(2000),
		@s_SanitaryActionCodeColumnOrder INT,
		@idfsSection BIGINT,
		@idfsMatrixType BIGINT,
		@idfsFormType BIGINT
	DECLARE @StubTable AS TABLE (
		idfVersion BIGINT,
		idfRow BIGINT,
		idfsParameter BIGINT,
		strDefaultParameterName NVARCHAR(400),
		idfsParameterValue NVARCHAR(MAX),
		NumRow INT,
		[strNameValue] NVARCHAR(200),
		[idfsSection] BIGINT
		)
	DECLARE @VersionTable TABLE ([idfVersion] BIGINT)
	DECLARE @tlbAggrMatrixVersion TABLE (
		idfAggrMatrixVersion BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		idfVersion BIGINT NOT NULL,
		intNumRow INT NULL,
		intColumnOrder INT NOT NULL,
		idfRow BIGINT NOT NULL,
		idfsParameter BIGINT,
		strParameterName NVARCHAR(2000),
		varValue NVARCHAR(MAX),
		strParameterRefValue NVARCHAR(2000)
		)

	BEGIN TRY
		SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangID);

		IF (LEN(@VersionList) = 0)
		BEGIN
			SELECT TOP 1 @idfVersion = [idfVersion]
			FROM dbo.tlbAggrMatrixVersionHeader
			WHERE idfsMatrixType = @MatrixID
				AND [blnIsActive] = 1
			ORDER BY CAST(ISNULL(blnIsDefault, 0) AS INT) + CAST(ISNULL(blnIsActive, 0) AS INT) DESC,
				datStartDate DESC

			SET @VersionList = CAST(@idfVersion AS VARCHAR(600));
		END;

		INSERT INTO @VersionTable ([idfVersion])
		SELECT CAST([Value] AS BIGINT)
		FROM [dbo].[fnsysSplitList](@VersionList, NULL, NULL)

		IF (@idfVersion IS NULL)
		BEGIN
			IF EXISTS (
					SELECT TOP 1 1
					FROM @VersionTable
					HAVING COUNT([idfVersion]) = 1
					)
				SELECT TOP 1 @idfVersion = [idfVersion]
				FROM @VersionTable
		END

		SET @VetCaseMTX = 71090000000 --Vet Aggregate Case
		SET @ProphylacticMTX = 71300000000 --Treatment-prophylactics and vaccination measures
		SET @DiagnosticMTX = 71460000000 --Diagnostic investigations
		SET @HumanCaseMTX = 71190000000 --Human Aggregate Case
		SET @SanitaryMTX = 71260000000 --Veterinary-sanitary measures
			-- VetCaseMTX		
		SET @vac_SpeciesColumn = 239010000000
		SET @vac_DiagnosisColumn = 226910000000
		SET @vac_OIECodeColumn = 234410000000
		--ProphylacticMTX
		SET @p_SpeciesColumn = 239050000000
		SET @p_DiagnosisColumn = 226950000000
		SET @p_OIECodeColumn = 234450000000
		SET @p_ProphylacticColumn = 245270000000
		SET @p_ProphylacticCodeColumn = 233170000000
		--DiagnosticMTX
		SET @d_SpeciesColumn = 239030000000
		SET @d_DiagnosisColumn = 226930000000
		SET @d_OIECodeColumn = 234430000000
		SET @d_DiagnosticColumn = 231670000000
		--HumanCaseMTX
		SET @hc_DiagnosisColumn = 226890000000
		SET @hc_ICD10CodeColumn = 229630000000
		--SanitaryMTX
		SET @s_SanitaryActionColumn = 233190000000
		SET @s_SanitaryActionCodeColumn = 233150000000

		-- VetCaseMTX
		SELECT @vac_SpeciesColumnName = ref_MatrixColumn.[name],
			@vac_SpeciesColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @vac_SpeciesColumn

		SELECT @vac_DiagnosisColumnName = ref_MatrixColumn.[name],
			@vac_DiagnosisColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @vac_DiagnosisColumn

		SELECT @vac_OIECodeColumnName = ref_MatrixColumn.[name],
			@vac_OIECodeColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @vac_OIECodeColumn

		--ProphylacticMTX
		SELECT @p_SpeciesColumnName = ref_MatrixColumn.[name],
			@p_SpeciesColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @p_SpeciesColumn

		SELECT @p_DiagnosisColumnName = ref_MatrixColumn.[name],
			@p_DiagnosisColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @p_DiagnosisColumn

		SELECT @p_OIECodeColumnName = ref_MatrixColumn.[name],
			@p_OIECodeColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @p_OIECodeColumn

		SELECT @p_ProphylacticColumnName = ref_MatrixColumn.[name],
			@p_ProphylacticColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @p_ProphylacticColumn

		SELECT @p_ProphylacticCodeColumnName = ref_MatrixColumn.[name],
			@p_ProphylacticCodeColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @p_ProphylacticCodeColumn

		--DiagnosticMTX
		SELECT @d_SpeciesColumnName = ref_MatrixColumn.[name],
			@d_SpeciesColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @d_SpeciesColumn

		SELECT @d_DiagnosisColumnName = ref_MatrixColumn.[name],
			@d_DiagnosisColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @d_DiagnosisColumn

		SELECT @d_OIECodeColumnName = ref_MatrixColumn.[name],
			@d_OIECodeColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @d_OIECodeColumn

		SELECT @d_DiagnosticColumnName = ref_MatrixColumn.[name],
			@d_DiagnosticColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @d_DiagnosticColumn

		--HumanCaseMTX
		SELECT @hc_DiagnosisColumnName = ref_MatrixColumn.[name],
			@hc_DiagnosisColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @hc_DiagnosisColumn

		SELECT @hc_ICD10CodeColumnName = ref_MatrixColumn.[name],
			@hc_ICD10CodeColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @hc_ICD10CodeColumn

		--SanitaryMTX
		SELECT @s_SanitaryActionColumnName = ref_MatrixColumn.[name],
			@s_SanitaryActionColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @s_SanitaryActionColumn

		SELECT @s_SanitaryActionCodeColumnName = ref_MatrixColumn.[name],
			@s_SanitaryActionCodeColumnOrder = mc.intColumnOrder
		FROM dbo.trtMatrixColumn mc
		INNER JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000152 /*rftMatrixColumn*/) ref_MatrixColumn
			ON ref_MatrixColumn.idfsReference = mc.idfsMatrixColumn
		WHERE mc.idfsMatrixColumn = @s_SanitaryActionCodeColumn

		IF @MatrixID = @VetCaseMTX --Vet Aggregate Case
		BEGIN
			INSERT @tlbAggrMatrixVersion (
				idfVersion,
				intNumRow,
				intColumnOrder,
				idfRow,
				idfsParameter,
				strParameterName,
				varValue,
				strParameterRefValue
				)
			SELECT idfVersion,
				intNumRow,
				intColumnOrder,
				idfRow,
				idfsParameter,
				strParameterName,
				varValue,
				strParameterRefValue
			FROM (
				SELECT mtx.idfVersion AS idfVersion,
					mtx.intNumRow AS intNumRow,
					mtx.idfAggrVetCaseMTX AS idfRow,
					@vac_SpeciesColumnOrder AS intColumnOrder1,
					@vac_SpeciesColumn AS idfsParameter1,
					@vac_SpeciesColumnName AS strParameterName1,
					CAST(mtx.idfsSpeciesType AS NVARCHAR(MAX)) AS varValue1,
					CAST(ref_Species.[name] AS NVARCHAR(2000)) AS strParameterRefValue1,
					@vac_DiagnosisColumnOrder AS intColumnOrder2,
					@vac_DiagnosisColumn AS idfsParameter2,
					@vac_DiagnosisColumnName AS strParameterName2,
					CAST(mtx.idfsDiagnosis AS NVARCHAR(MAX)) AS varValue2,
					CAST(ref_Diagnosis.[name] AS NVARCHAR(2000)) AS strParameterRefValue2,
					@vac_OIECodeColumnOrder AS intColumnOrder3,
					@vac_OIECodeColumn AS idfsParameter3,
					@vac_OIECodeColumnName AS strParameterName3,
					CAST(COALESCE(d.strOIECode, '') AS NVARCHAR(MAX)) AS varValue3,
					CAST('' COLLATE Cyrillic_General_CI_AS AS NVARCHAR(2000)) AS strParameterRefValue3
				FROM dbo.tlbAggrVetCaseMTX mtx
				INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000086 /*rftSpeciesList*/) ref_Species
					ON ref_Species.idfsReference = mtx.idfsSpeciesType
				INNER JOIN dbo.trtDiagnosis d
					ON d.idfsDiagnosis = mtx.idfsDiagnosis
				INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019 /*rftDiagnosis*/) ref_Diagnosis
					ON ref_Diagnosis.idfsReference = d.idfsDiagnosis
				WHERE EXISTS (
						SELECT *
						FROM @VersionTable
						WHERE mtx.idfVersion = [idfVersion]
						)
					AND mtx.intRowStatus = 0
				) AS s
			UNPIVOT(intColumnOrder FOR intColumnOrders IN (
						intColumnOrder1,
						intColumnOrder2,
						intColumnOrder3
						)) AS unpvt_ColumnOrders
			UNPIVOT(idfsParameter FOR idfsParameters IN (
						idfsParameter1,
						idfsParameter2,
						idfsParameter3
						)) AS unpvt_idfsParameters
			UNPIVOT(strParameterName FOR strParameterNames IN (
						strParameterName1,
						strParameterName2,
						strParameterName3
						)) AS unpvt_strParameterNames
			UNPIVOT(varValue FOR varValues IN (
						varValue1,
						varValue2,
						varValue3
						)) AS unpvt_varValues
			UNPIVOT(strParameterRefValue FOR strParameterRefValues IN (
						strParameterRefValue1,
						strParameterRefValue2,
						strParameterRefValue3
						)) AS unpvt_strParameterRefValues
			WHERE RIGHT(intColumnOrders, 1) = RIGHT(idfsParameters, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(strParameterNames, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(varValues, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(strParameterRefValues, 1)
		END
		ELSE IF @MatrixID = @ProphylacticMTX --Treatment-prophylactics and vaccination measures
		BEGIN
			INSERT @tlbAggrMatrixVersion (
				idfVersion,
				intNumRow,
				intColumnOrder,
				idfRow,
				idfsParameter,
				strParameterName,
				varValue,
				strParameterRefValue
				)
			SELECT idfVersion,
				intNumRow,
				intColumnOrder,
				idfRow,
				idfsParameter,
				strParameterName,
				varValue,
				strParameterRefValue
			FROM (
				SELECT mtx.idfVersion AS idfVersion,
					mtx.intNumRow AS intNumRow,
					mtx.idfAggrProphylacticActionMTX AS idfRow,
					@p_SpeciesColumnOrder AS intColumnOrder1,
					@p_SpeciesColumn AS idfsParameter1,
					@p_SpeciesColumnName AS strParameterName1,
					CAST(mtx.idfsSpeciesType AS NVARCHAR(MAX)) AS varValue1,
					ref_Species.[name] AS strParameterRefValue1,
					@p_DiagnosisColumnOrder AS intColumnOrder2,
					@p_DiagnosisColumn AS idfsParameter2,
					@p_DiagnosisColumnName AS strParameterName2,
					CAST(mtx.idfsDiagnosis AS NVARCHAR(MAX)) AS varValue2,
					ref_Diagnosis.[name] AS strParameterRefValue2,
					@p_OIECodeColumnOrder AS intColumnOrder3,
					@p_OIECodeColumn AS idfsParameter3,
					@p_OIECodeColumnName AS strParameterName3,
					CAST(COALESCE(d.strOIECode, '') AS NVARCHAR(MAX)) AS varValue3,
					CAST('' COLLATE Cyrillic_General_CI_AS AS NVARCHAR(2000)) AS strParameterRefValue3,
					@p_ProphylacticColumnOrder AS intColumnOrder4,
					@p_ProphylacticColumn AS idfsParameter4,
					@p_ProphylacticColumnName AS strParameterName4,
					CAST(mtx.idfsProphilacticAction AS NVARCHAR(MAX)) AS varValue4,
					ref_ProphilacticAction.[name] AS strParameterRefValue4,
					@p_ProphylacticCodeColumnOrder AS intColumnOrder5,
					@p_ProphylacticCodeColumn AS idfsParameter5,
					@p_ProphylacticCodeColumnName AS strParameterName5,
					CAST(COALESCE(pa.strActionCode, '') AS NVARCHAR(MAX)) AS varValue5,
					CAST('' COLLATE Cyrillic_General_CI_AS AS NVARCHAR(2000)) AS strParameterRefValue5
				FROM dbo.tlbAggrProphylacticActionMTX mtx
				INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000086 /*rftSpeciesList*/) ref_Species
					ON ref_Species.idfsReference = mtx.idfsSpeciesType
				INNER JOIN dbo.trtDiagnosis d
					ON d.idfsDiagnosis = mtx.idfsDiagnosis
				INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019 /*rftDiagnosis*/) ref_Diagnosis
					ON ref_Diagnosis.idfsReference = d.idfsDiagnosis
				INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000074 /*rftProphilacticActionList*/) ref_ProphilacticAction
					ON ref_ProphilacticAction.idfsReference = mtx.idfsProphilacticAction
				INNER JOIN dbo.trtProphilacticAction pa
					ON pa.idfsProphilacticAction = mtx.idfsProphilacticAction
				WHERE EXISTS (
						SELECT *
						FROM @VersionTable
						WHERE mtx.idfVersion = [idfVersion]
						)
					AND mtx.intRowStatus = 0
				) AS s
			UNPIVOT(intColumnOrder FOR intColumnOrders IN (
						intColumnOrder1,
						intColumnOrder2,
						intColumnOrder3,
						intColumnOrder4,
						intColumnOrder5
						)) AS unpvt_ColumnOrders
			UNPIVOT(idfsParameter FOR idfsParameters IN (
						idfsParameter1,
						idfsParameter2,
						idfsParameter3,
						idfsParameter4,
						idfsParameter5
						)) AS unpvt_idfsParameters
			UNPIVOT(strParameterName FOR strParameterNames IN (
						strParameterName1,
						strParameterName2,
						strParameterName3,
						strParameterName4,
						strParameterName5
						)) AS unpvt_strParameterNames
			UNPIVOT(varValue FOR varValues IN (
						varValue1,
						varValue2,
						varValue3,
						varValue4,
						varValue5
						)) AS unpvt_varValues
			UNPIVOT(strParameterRefValue FOR strParameterRefValues IN (
						strParameterRefValue1,
						strParameterRefValue2,
						strParameterRefValue3,
						strParameterRefValue4,
						strParameterRefValue5
						)) AS unpvt_strParameterRefValues
			WHERE RIGHT(intColumnOrders, 1) = RIGHT(idfsParameters, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(strParameterNames, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(varValues, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(strParameterRefValues, 1)
		END
		ELSE IF @MatrixID = 71460000000 --Diagnostic investigations
		BEGIN
			INSERT @tlbAggrMatrixVersion (
				idfVersion,
				intNumRow,
				intColumnOrder,
				idfRow,
				idfsParameter,
				strParameterName,
				varValue,
				strParameterRefValue
				)
			SELECT idfVersion,
				intNumRow,
				intColumnOrder,
				idfRow,
				idfsParameter,
				strParameterName,
				varValue,
				strParameterRefValue
			FROM (
				SELECT mtx.idfVersion AS idfVersion,
					mtx.intNumRow AS intNumRow,
					mtx.idfAggrDiagnosticActionMTX AS idfRow,
					@d_SpeciesColumnOrder AS intColumnOrder1,
					@d_SpeciesColumn AS idfsParameter1,
					@d_SpeciesColumnName AS strParameterName1,
					CAST(mtx.idfsSpeciesType AS NVARCHAR(MAX)) AS varValue1,
					ref_Species.[name] AS strParameterRefValue1,
					@d_DiagnosisColumnOrder AS intColumnOrder2,
					@d_DiagnosisColumn AS idfsParameter2,
					@d_DiagnosisColumnName AS strParameterName2,
					CAST(mtx.idfsDiagnosis AS NVARCHAR(MAX)) AS varValue2,
					ref_Diagnosis.[name] AS strParameterRefValue2,
					@d_OIECodeColumnOrder AS intColumnOrder3,
					@d_OIECodeColumn AS idfsParameter3,
					@d_OIECodeColumnName AS strParameterName3,
					CAST(COALESCE(d.strOIECode, '') AS NVARCHAR(MAX)) AS varValue3,
					CAST('' COLLATE Cyrillic_General_CI_AS AS NVARCHAR(2000)) AS strParameterRefValue3,
					@d_DiagnosticColumnOrder AS intColumnOrder4,
					@d_DiagnosticColumn AS idfsParameter4,
					@d_DiagnosticColumnName AS strParameterName4,
					CAST(mtx.idfsDiagnosticAction AS NVARCHAR(MAX)) AS varValue4,
					ref_DiagnosticAction.[name] AS strParameterRefValue4
				FROM dbo.tlbAggrDiagnosticActionMTX mtx
				INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000086 /*rftSpeciesList*/) ref_Species
					ON ref_Species.idfsReference = mtx.idfsSpeciesType
				INNER JOIN dbo.trtDiagnosis d
					ON d.idfsDiagnosis = mtx.idfsDiagnosis
				INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019 /*rftDiagnosis*/) ref_Diagnosis
					ON ref_Diagnosis.idfsReference = d.idfsDiagnosis
				INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000021 /*rftDiagnosticActionList*/) ref_DiagnosticAction
					ON ref_DiagnosticAction.idfsReference = mtx.idfsDiagnosticAction
				WHERE EXISTS (
						SELECT *
						FROM @VersionTable
						WHERE mtx.idfVersion = [idfVersion]
						)
					AND mtx.intRowStatus = 0
				) AS s
			UNPIVOT(intColumnOrder FOR intColumnOrders IN (
						intColumnOrder1,
						intColumnOrder2,
						intColumnOrder3,
						intColumnOrder4
						)) AS unpvt_ColumnOrders
			UNPIVOT(idfsParameter FOR idfsParameters IN (
						idfsParameter1,
						idfsParameter2,
						idfsParameter3,
						idfsParameter4
						)) AS unpvt_idfsParameters
			UNPIVOT(strParameterName FOR strParameterNames IN (
						strParameterName1,
						strParameterName2,
						strParameterName3,
						strParameterName4
						)) AS unpvt_strParameterNames
			UNPIVOT(varValue FOR varValues IN (
						varValue1,
						varValue2,
						varValue3,
						varValue4
						)) AS unpvt_varValues
			UNPIVOT(strParameterRefValue FOR strParameterRefValues IN (
						strParameterRefValue1,
						strParameterRefValue2,
						strParameterRefValue3,
						strParameterRefValue4
						)) AS unpvt_strParameterRefValues
			WHERE RIGHT(intColumnOrders, 1) = right(idfsParameters, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(strParameterNames, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(varValues, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(strParameterRefValues, 1)
		END
		ELSE IF @MatrixID = 71190000000 --Human Aggregate Case
		BEGIN
			INSERT @tlbAggrMatrixVersion (
				idfVersion,
				intNumRow,
				intColumnOrder,
				idfRow,
				idfsParameter,
				strParameterName,
				varValue,
				strParameterRefValue
				)
			SELECT idfVersion,
				intNumRow,
				intColumnOrder,
				idfRow,
				idfsParameter,
				strParameterName,
				varValue,
				strParameterRefValue
			FROM (
				SELECT mtx.idfVersion AS idfVersion,
					mtx.intNumRow AS intNumRow,
					mtx.idfAggrHumanCaseMTX AS idfRow,
					@hc_DiagnosisColumnOrder AS intColumnOrder1,
					@hc_DiagnosisColumn AS idfsParameter1,
					@hc_DiagnosisColumnName AS strParameterName1,
					CAST(mtx.idfsDiagnosis AS NVARCHAR(MAX)) AS varValue1,
					ref_Diagnosis.[name] AS strParameterRefValue1,
					@hc_ICD10CodeColumnOrder AS intColumnOrder2,
					@hc_ICD10CodeColumn AS idfsParameter2,
					@hc_ICD10CodeColumnName AS strParameterName2,
					CAST(COALESCE(d.strIDC10, '') AS NVARCHAR(MAX)) AS varValue2,
					CAST('' COLLATE Cyrillic_General_CI_AS AS NVARCHAR(2000)) AS strParameterRefValue2
				FROM dbo.tlbAggrHumanCaseMTX mtx
				INNER JOIN dbo.trtDiagnosis d
					ON d.idfsDiagnosis = mtx.idfsDiagnosis
				INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019 /*rftDiagnosis*/) ref_Diagnosis
					ON ref_Diagnosis.idfsReference = d.idfsDiagnosis
				WHERE EXISTS (
						SELECT *
						FROM @VersionTable
						WHERE mtx.idfVersion = [idfVersion]
						)
					AND mtx.intRowStatus = 0
				) AS s
			UNPIVOT(intColumnOrder FOR intColumnOrders IN (
						intColumnOrder1,
						intColumnOrder2
						)) AS unpvt_ColumnOrders
			UNPIVOT(idfsParameter FOR idfsParameters IN (
						idfsParameter1,
						idfsParameter2
						)) AS unpvt_idfsParameters
			UNPIVOT(strParameterName FOR strParameterNames IN (
						strParameterName1,
						strParameterName2
						)) AS unpvt_strParameterNames
			UNPIVOT(varValue FOR varValues IN (
						varValue1,
						varValue2
						)) AS unpvt_varValues
			UNPIVOT(strParameterRefValue FOR strParameterRefValues IN (
						strParameterRefValue1,
						strParameterRefValue2
						)) AS unpvt_strParameterRefValues
			WHERE RIGHT(intColumnOrders, 1) = RIGHT(idfsParameters, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(strParameterNames, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(varValues, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(strParameterRefValues, 1)
		END
		ELSE IF @MatrixID = 71260000000 --Veterinary-sanitary measures
		BEGIN
			INSERT @tlbAggrMatrixVersion (
				idfVersion,
				intNumRow,
				intColumnOrder,
				idfRow,
				idfsParameter,
				strParameterName,
				varValue,
				strParameterRefValue
				)
			SELECT idfVersion,
				intNumRow,
				intColumnOrder,
				idfRow,
				idfsParameter,
				strParameterName,
				varValue,
				strParameterRefValue
			FROM (
				SELECT mtx.idfVersion AS idfVersion,
					mtx.intNumRow AS intNumRow,
					mtx.idfAggrSanitaryActionMTX AS idfRow,
					@s_SanitaryActionColumnOrder AS intColumnOrder1,
					@s_SanitaryActionColumn AS idfsParameter1,
					@s_SanitaryActionColumnName AS strParameterName1,
					CAST(mtx.idfsSanitaryAction AS NVARCHAR(MAX)) AS varValue1,
					ref_SanitaryAction.[name] AS strParameterRefValue1,
					@s_SanitaryActionCodeColumnOrder AS intColumnOrder2,
					@s_SanitaryActionCodeColumn AS idfsParameter2,
					@s_SanitaryActionCodeColumnName AS strParameterName2,
					CAST(COALESCE(sa.strActionCode, '') AS NVARCHAR(MAX)) AS varValue2,
					CAST('' COLLATE Cyrillic_General_CI_AS AS NVARCHAR(2000)) AS strParameterRefValue2
				FROM dbo.tlbAggrSanitaryActionMTX mtx
				INNER JOIN trtSanitaryAction sa
					ON sa.idfsSanitaryAction = mtx.idfsSanitaryAction
				INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000079 /*rftSanitaryActionList*/) ref_SanitaryAction
					ON ref_SanitaryAction.idfsReference = sa.idfsSanitaryAction
				WHERE EXISTS (
						SELECT *
						FROM @VersionTable
						WHERE mtx.idfVersion = [idfVersion]
						)
					AND mtx.intRowStatus = 0
				) AS s
			UNPIVOT(intColumnOrder FOR intColumnOrders IN (
						intColumnOrder1,
						intColumnOrder2
						)) AS unpvt_ColumnOrders
			UNPIVOT(idfsParameter FOR idfsParameters IN (
						idfsParameter1,
						idfsParameter2
						)) AS unpvt_idfsParameters
			UNPIVOT(strParameterName FOR strParameterNames IN (
						strParameterName1,
						strParameterName2
						)) AS unpvt_strParameterNames
			UNPIVOT(varValue FOR varValues IN (
						varValue1,
						varValue2
						)) AS unpvt_varValues
			UNPIVOT(strParameterRefValue FOR strParameterRefValues IN (
						strParameterRefValue1,
						strParameterRefValue2
						)) AS unpvt_strParameterRefValues
			WHERE RIGHT(intColumnOrders, 1) = RIGHT(idfsParameters, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(strParameterNames, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(varValues, 1)
				AND RIGHT(intColumnOrders, 1) = RIGHT(strParameterRefValues, 1)
		END

		DECLARE curs CURSOR
		FOR
		--Select
		--	  AMV.[idfRow]
		--	  ,AMV.[idfsParameter]
		--	  ,Isnull(R1.[name], R1.[strDefault])
		--	  ,AMV.[varValue]
		--	  ,Isnull(SNT.[strTextString], BR1.[strDefault])
		--	  ,AMV.idfVersion
		--From dbo.tlbAggrMatrixVersion AMV
		--		Inner Join dbo.fnReference(@LangID, 19000066) R1 On AMV.idfsParameter = R1.idfsReference	
		--		Left Join dbo.trtBaseReference BR1 On AMV.varValue = BR1.idfsBaseReference --And BR1.intRowStatus = 0	
		--		Left Join dbo.trtStringNameTranslation SNT On SNT.idfsBaseReference = BR1.idfsBaseReference And SNT.idfsLanguage = @langid_int --And SNT.intRowStatus = 0	 					
		--Where AMV.idfVersion In (Select [idfVersion] From @VersionTable) And AMV.intRowStatus = 0						 
		--Order By AMV.intNumRow, AMV.idfRow, AMV.idfVersion, AMV.intColumnOrder
		SELECT idfRow,
			idfsParameter,
			strParameterName,
			varValue,
			strParameterRefValue,
			idfVersion
		FROM @tlbAggrMatrixVersion
		WHERE idfVersion IN (
				SELECT [idfVersion]
				FROM @VersionTable
				)
		ORDER BY intNumRow,
			idfRow,
			idfVersion,
			intColumnOrder

		OPEN curs

		FETCH NEXT
		FROM curs
		INTO @idfRow,
			@idfsParameter,
			@strDefaultParameterName,
			@idfsParameterValue,
			@strNameValue,
			@currentVersion

		SET @idfRowCurrent = @idfRow;

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SET @NumRowTemp = NULL;

			SELECT DISTINCT @NumRowTemp = [NumRow]
			FROM @StubTable
			WHERE [idfRow] = @idfRow

			IF (@NumRowTemp IS NULL)
			BEGIN
				--Set  @NumRowCurrent =  @NumRowCurrent + 1 
				SELECT @NumRowCurrent = ISNULL(MAX([NumRow]), - 1) + 1
				FROM @StubTable
			END
			ELSE
			BEGIN
				SET @NumRowCurrent = @NumRowTemp;
			END;

			IF NOT EXISTS (
					SELECT TOP 1 1
					FROM @StubTable
					WHERE idfRow = @idfRow
						AND idfsParameter = @idfsParameter
					)
			BEGIN
				INSERT INTO @StubTable (
					idfVersion,
					idfRow,
					idfsParameter,
					strDefaultParameterName,
					idfsParameterValue,
					strNameValue,
					NumRow
					)
				VALUES (
					@currentVersion,
					@idfRow,
					@idfsParameter,
					@strDefaultParameterName,
					@idfsParameterValue,
					ISNULL(@strNameValue, CAST(@idfsParameterValue AS NVARCHAR(600))),
					@NumRowCurrent
					)
			END

			FETCH NEXT
			FROM curs
			INTO @idfRow,
				@idfsParameter,
				@strDefaultParameterName,
				@idfsParameterValue,
				@strNameValue,
				@currentVersion --,@intColumnOrder
		END

		CLOSE curs

		DEALLOCATE curs

		IF (@idfsFormTemplate IS NOT NULL)
			SELECT @idfsFormType = idfsFormType
			FROM dbo.ffFormTemplate
			WHERE idfsFormTemplate = @idfsFormTemplate

		DECLARE @idfsCountry BIGINT

		SELECT @idfsCountry = dbo.FN_GBL_CURRENTCOUNTRY_GET()

		IF @idfsFormTemplate IS NULL
		BEGIN
			DECLARE @TempTable AS TABLE (
				idfsFormTemplate BIGINT,
				isUNITemplate BIT
				)

			-- SHL commented out.  The last parameter of 0 causes no data to be returned.
			-- TODO:  determine why this was needed.  If needed, this insert/exec call 
			-- will need to be re-written as this is called from another stored procedure 
			-- USP_ADMIN_FF_PREDEFINEDSTUB_GET via an insert/exec call.  SQL does not allow 
			-- for this.
			--INSERT INTO @TempTable
			--EXEC dbo.USP_ADMIN_FF_ActualTemplate_GET @idfsCountry, NULL, @idfsFormType, 0
			SET @idfsFormTemplate = (
					SELECT TOP 1 idfsFormTemplate
					FROM @TempTable
					)
		END

		IF (@idfsFormTemplate IS NOT NULL)
		BEGIN
			SELECT @idfsFormType = idfsFormType
			FROM dbo.ffFormTemplate
			WHERE idfsFormTemplate = @idfsFormTemplate

			SELECT TOP 1 @idfsSection = S.idfsSection,
				@idfsMatrixType = S.idfsMatrixType
			FROM dbo.ffSection S
			INNER JOIN dbo.trtMatrixType MT
				ON S.idfsMatrixType = MT.idfsMatrixType
					AND MT.idfsFormType = @idfsFormType
					AND MT.intRowStatus = 0
			INNER JOIN dbo.ffSectionForTemplate ST
				ON S.idfsSection = ST.idfsSection
					AND ST.idfsFormTemplate = @idfsFormTemplate
					AND ST.intRowStatus = 0
			WHERE S.idfsParentSection IS NULL
		END

		SELECT idfVersion,
			idfRow,
			idfsParameter,
			strDefaultParameterName,
			idfsParameterValue,
			NumRow,
			[strNameValue]
			--,@MatrixID As [idfsSection]
			,
			@idfsSection AS [idfsSection],
			@LangID AS [langid]
		FROM @StubTable
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
