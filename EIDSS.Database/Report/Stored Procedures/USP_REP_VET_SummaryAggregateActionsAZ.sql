
--*************************************************************************
-- Name 				: report.USP_REP_VET_SummaryAggregateActionsAZ
-- Description			: Used in Summary Veterinary Report For Aggregate Actions
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_VET_SummaryAggregateActionsAZ 
'en', 
N'2016-01-01 00:00:00.000',
N'2016-11-30 00:00:00.000',
51740350000000,
'7722440000000', --List
51740620000000
*/ 


CREATE PROCEDURE [Report].[USP_REP_VET_SummaryAggregateActionsAZ]
(
	 @LangID			AS NVARCHAR(50),
	 @SD				AS DATETIME, 
	 @ED				AS DATETIME,
	 @Diagnosis			AS BIGINT,
	 @SpeciesType		AS NVARCHAR(MAX),
	 @InvestigationOrMeasureType BIGINT
)
AS

	DECLARE @InvestigationOrMeasure AS BIT
	DECLARE @SDDate AS DATETIME
	DECLARE @EDDate AS DATETIME
	DECLARE @CountryID BIGINT
	DECLARE @iSpeciesType INT
	
	DECLARE @idfsRegionBaku BIGINT,
		@idfsRegionOtherRayons BIGINT,
		@idfsRegionNakhichevanAR BIGINT
		
		
	DECLARE @sql AS NVARCHAR (MAX) = ''

	
	SET @SDDate=report.FN_GBL_MinMaxTime_GET(CAST(@SD AS DATETIME),0)
	SET @EDDate=report.FN_GBL_MinMaxTime_GET(CAST(@ED AS DATETIME),1)
	
	SET @CountryID = 170000000
	
	SELECT 
		@InvestigationOrMeasure =
			CASE tbr.idfsReferenceType
				WHEN 19000021 /*Diagnostic Investigation List*/ THEN 0
				WHEN 19000074 /*Prophylactic Measure List*/ THEN 1
			END
	FROM trtBaseReference tbr
	WHERE tbr.intRowStatus = 0
		AND tbr.idfsBaseReference = @InvestigationOrMeasureType
				

	DECLARE @SpeciesTypeTABLE	TABLE
		(
			[key]  NVARCHAR(300)			
		)	
	
	INSERT INTO @SpeciesTypeTABLE 
 	SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@SpeciesType,1,',')
 	

	--1344330000000 --Baku
	SELECT
		@idfsRegionBaku = fgr.idfsReference
	FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) fgr
	WHERE fgr.name = N'Baku'

	--1344340000000 --Other rayons
	SELECT
		@idfsRegionOtherRayons = fgr.idfsReference
	FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) fgr
	WHERE fgr.name = N'Other rayons'

	--1344350000000 --Nakhichevan AR
	SELECT
		@idfsRegionNakhichevanAR = fgr.idfsReference
	FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) fgr
	WHERE fgr.name = N'Nakhichevan AR'  
	
	
	
	DECLARE @idfsCurrentCountry	BIGINT
	SELECT @idfsCurrentCountry = ISNULL(dbo.FN_GBL_CURRENTCOUNTRY_GET(), 170000000) /*Azerbaijan*/

	DECLARE	@drop_cmd	NVARCHAR(4000)

	-- Drop temporary TABLEs
	IF Object_ID('tempdb..#AggrCase') IS NOT NULL
	BEGIN
		SET	@drop_cmd = N'drop TABLE #AggrCase'
		EXECUTE sp_executesql @drop_cmd
	END

	IF Object_ID('tempdb..#TestedCnt') IS NOT NULL
	BEGIN
		SET	@drop_cmd = N'drop TABLE #TestedCnt'
		EXECUTE sp_executesql @drop_cmd
	END

	IF Object_ID('tempdb..#PositiveCnt') IS NOT NULL
	BEGIN
		SET	@drop_cmd = N'drop TABLE #PositiveCnt'
		EXECUTE sp_executesql @drop_cmd
	END

	IF Object_ID('tempdb..#ActionTakenCnt') IS NOT NULL
	BEGIN
		SET	@drop_cmd = N'drop TABLE #ActionTakenCnt'
		EXECUTE sp_executesql @drop_cmd
	END

	DECLARE	@NotDeletedDiagnosis TABLE
	(	idfsDiagnosis		BIGINT NOT NULL PRIMARY KEY,
		[name]				NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS null,
		idfsActualDiagnosis	BIGINT NOT NULL
	)
	
	INSERT INTO	@NotDeletedDiagnosis
	(	idfsDiagnosis,
		[name],
		idfsActualDiagnosis
	)
	SELECT
		r_d.idfsReference AS idfsDiagnosis
		, r_d.[name] AS [name]
		, ISNULL(actual_diagnosis.idfsDiagnosis, r_d.idfsReference) AS idfsActualDiagnosis
	FROM report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) r_d
	LEFT JOIN	(
		SELECT	d_actual.idfsDiagnosis,
				r_d_actual.[name],
				ROW_NUMBER() OVER (PARTITION BY r_d_actual.[name] ORDER BY d_actual.idfsDiagnosis) AS rn
		FROM		trtDiagnosis d_actual
		INNER JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) r_d_actual
		ON			r_d_actual.idfsReference = d_actual.idfsDiagnosis
		WHERE		d_actual.idfsUsingType = 10020002	/*Aggregate Case*/
					AND d_actual.intRowStatus = 0
				) actual_diagnosis
		ON		actual_diagnosis.[name] = r_d.[name] COLLATE Cyrillic_General_CI_AS
				AND actual_diagnosis.rn = 1
	WHERE	ISNULL(actual_diagnosis.idfsDiagnosis, r_d.idfsReference) = @Diagnosis

	DECLARE	@NotDeletedSpecies TABLE
	(	idfsSpeciesType			BIGINT NOT NULL PRIMARY KEY,
		[name]					NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS null,
		idfsActualSpeciesType	BIGINT NOT NULL
	)

	INSERT INTO	@NotDeletedSpecies
	(	idfsSpeciesType,
		[name],
		idfsActualSpeciesType
	)
	SELECT
		r_sp.idfsReference AS idfsSpeciesType
		, CAST(r_sp.[name] AS NVARCHAR(2000)) AS [name]
		, ISNULL(actual_SpeciesType.idfsSpeciesType, r_sp.idfsReference) AS idfsActualSpeciesType
	FROM report.FN_GBL_ReferenceRepair_GET(@LangID, 19000086) r_sp
	LEFT JOIN	(
		SELECT	st_actual.idfsSpeciesType,
				r_st_actual.[name],
				ROW_NUMBER() OVER (PARTITION BY r_st_actual.[name] ORDER BY st_actual.idfsSpeciesType) AS rn
		FROM		trtSpeciesType st_actual
		INNER JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000086) r_st_actual
		ON			r_st_actual.idfsReference = st_actual.idfsSpeciesType
		WHERE		st_actual.intRowStatus = 0
			) actual_SpeciesType
	ON		actual_SpeciesType.[name] = r_sp.[name] COLLATE Cyrillic_General_CI_AS
			AND actual_SpeciesType.rn = 1
	INNER JOIN	@SpeciesTypeTABLE stt
	ON			stt.[key] = ISNULL(actual_SpeciesType.idfsSpeciesType, r_sp.idfsReference)

	DECLARE	@NotDeletedProphylacticAction TABLE
	(	idfsProphylacticAction			BIGINT NOT NULL PRIMARY KEY,
		[name]							NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
		idfsActualProphylacticAction	BIGINT NOT NULL
	)

	IF @InvestigationOrMeasure = 1
	INSERT INTO	@NotDeletedProphylacticAction
	(	idfsProphylacticAction,
		[name],
		idfsActualProphylacticAction
	)
	SELECT
		r_pm.idfsReference AS idfsProphylacticAction
		, CAST(r_pm.[name] AS NVARCHAR(2000)) AS [name]
		, ISNULL(actual_ProphylacticAction.idfsProphylacticAction, r_pm.idfsReference) AS idfsActualProphylacticAction
	FROM report.FN_GBL_ReferenceRepair_GET(@LangID, 19000074) r_pm
	LEFT JOIN	(
		SELECT	pa_actual.idfsProphilacticAction as idfsProphylacticAction,
				r_pa_actual.[name],
				ROW_NUMBER() OVER (PARTITION BY r_pa_actual.[name] ORDER BY pa_actual.idfsProphilacticAction) AS rn
		FROM		trtProphilacticAction pa_actual
		INNER JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000074) r_pa_actual
		ON			r_pa_actual.idfsReference = pa_actual.idfsProphilacticAction
		WHERE		pa_actual.intRowStatus = 0
			) actual_ProphylacticAction
	ON		actual_ProphylacticAction.[name] = r_pm.[name] COLLATE Cyrillic_General_CI_AS
			AND actual_ProphylacticAction.rn = 1
	WHERE	ISNULL(actual_ProphylacticAction.idfsProphylacticAction, r_pm.idfsReference) = @InvestigationOrMeasureType

	DECLARE	@NotDeletedDiagnosticAction TABLE
	(	idfsDiagnosticAction			BIGINT NOT NULL PRIMARY KEY,
		[name]							NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS null,
		idfsActualDiagnosticAction	BIGINT NOT NULL
	)

	IF @InvestigationOrMeasure = 0
	INSERT INTO	@NotDeletedDiagnosticAction
	(	idfsDiagnosticAction,
		[name],
		idfsActualDiagnosticAction
	)
	SELECT
		r_di.idfsReference AS idfsDiagnosticAction
		, CAST(r_di.[name] AS NVARCHAR(2000)) AS [name]
		, ISNULL(actual_DiagnosticAction.idfsDiagnosticAction, r_di.idfsReference) AS idfsActualDiagnosticAction
	FROM report.FN_GBL_ReferenceRepair_GET(@LangID, 19000021	/*Diagnostic Investigation List*/) r_di
	LEFT JOIN	(
		SELECT	r_di_actual.idfsReference as idfsDiagnosticAction,
				r_di_actual.[name],
				ROW_NUMBER() OVER (PARTITION BY r_di_actual.[name] ORDER BY r_di_actual.idfsReference) AS rn
		FROM		report.FN_GBL_ReferenceRepair_GET(@LangID, 19000021	/*Diagnostic Investigation List*/) r_di_actual
			) actual_DiagnosticAction
	ON		actual_DiagnosticAction.[name] = r_di.[name] COLLATE Cyrillic_General_CI_AS
			AND actual_DiagnosticAction.rn = 1
	WHERE	ISNULL(actual_DiagnosticAction.idfsDiagnosticAction, r_di.idfsReference) = @InvestigationOrMeasureType

		
	CREATE TABLE #AggrCase
	(
		idfAggrCase BIGINT
		, idfObservation BIGINT
		, idfAggrActionMTX BIGINT
		, idfsSpeciesType BIGINT
		, idfsRegion BIGINT
		, idfsRayon BIGINT
		, idfsAdministrativeUnit BIGINT
		, datStartDate DATETIME
		, datFinishDate DATETIME
	)
	
	
	INSERT INTO #AggrCase
	SELECT
		tac.idfAggrCase
		, tac.idfDiagnosticObservation
		, tadam.idfAggrDiagnosticActionMTX
		, Actual_Species_Type.idfsActualSpeciesType
		, COALESCE(s.idfsRegion, rr.idfsRegion, r.idfsRegion, NULL) AS idfsRegion
		, COALESCE(s.idfsRayon, rr.idfsRayon, NULL) AS idfsRayon
		, tac.idfsAdministrativeUnit
		, tac.datStartDate
		, tac.datFinishDate
	FROM tlbAggrCase tac

	-- Matrix version
	INNER JOIN	tlbAggrMatrixVersionHeader h
	ON			h.idfsMatrixType = 71460000000	-- Diagnostic investigations
				AND (	-- Get matrix version selected by the user in aggregate action
						h.idfVersion = tac.idfDiagnosticVersion
						-- IF matrix version is not selected by the user in aggregate case, 
						-- then select active matrix with the latest date activation that is earlier than aggregate action start date
						OR (	tac.idfProphylacticVersion IS NULL 
								AND	h.datStartDate <= tac.datStartDate
								AND	h.blnIsActive = 1
								AND NOT EXISTS	(
											SELECT	*
											FROM	tlbAggrMatrixVersionHeader h_later
											WHERE	h_later.idfsMatrixType = 71460000000	-- Diagnostic investigations
													AND	h_later.datStartDate <= tac.datStartDate
													AND	h_later.blnIsActive = 1
													AND h_later.intRowStatus = 0
													AND	h_later.datStartDate > h.datStartDate
												)
							)
					)
				AND h.intRowStatus = 0
				
	-- Matrix row
	INNER JOIN	tlbAggrDiagnosticActionMTX tadam
	ON			tadam.idfVersion = h.idfVersion
				AND tadam.intRowStatus = 0
	
	JOIN @NotDeletedDiagnosticAction AS Actual_Diagnostic_Action ON
		Actual_Diagnostic_Action.idfsDiagnosticAction = tadam.idfsDiagnosticAction
		
	JOIN @NotDeletedDiagnosis AS Actual_Diagnosis ON
		Actual_Diagnosis.idfsDiagnosis = tadam.idfsDiagnosis
		
	JOIN @NotDeletedSpecies AS Actual_Species_Type ON
		Actual_Species_Type.idfsSpeciesType = tadam.idfsSpeciesType
		
	LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
	ON			c.idfsReference = tac.idfsAdministrativeUnit
	LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
	ON			r.idfsRegion = tac.idfsAdministrativeUnit 
	LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
	ON			rr.idfsRayon = tac.idfsAdministrativeUnit
	LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
	ON			s.idfsSettlement = tac.idfsAdministrativeUnit
		
	WHERE @InvestigationOrMeasure = 0
		AND tac.intRowStatus = 0
		AND tac.idfsAggrCaseType = 10102003 /*Vet Aggregate Action*/
		AND tac.datStartDate >= @SDDate
		AND tac.datFinishDate < @EDDate
	UNION ALL
	SELECT
		tac.idfAggrCase
		, tac.idfProphylacticObservation
		, tapam.idfAggrProphylacticActionMTX
		, Actual_Species_Type.idfsActualSpeciesType
		, COALESCE(s.idfsRegion, rr.idfsRegion, r.idfsRegion, NULL) AS idfsRegion
		, COALESCE(s.idfsRayon, rr.idfsRayon, NULL) AS idfsRayon
		, tac.idfsAdministrativeUnit
		, tac.datStartDate
		, tac.datFinishDate
	FROM tlbAggrCase tac

	-- Matrix version
	INNER JOIN	tlbAggrMatrixVersionHeader h
	ON			h.idfsMatrixType = 71300000000	-- Treatment-prophylactics AND vaccination measures
				AND (	-- Get matrix version selected by the user in aggregate action
						h.idfVersion = tac.idfProphylacticVersion
						-- If matrix version is not selected by the user in aggregate case, 
						-- then select active matrix with the latest date activation that is earlier than aggregate action start date
						OR (	tac.idfProphylacticVersion IS NULL 
								AND	h.datStartDate <= tac.datStartDate
								AND	h.blnIsActive = 1
								AND NOT EXISTS	(
											SELECT	*
											FROM	tlbAggrMatrixVersionHeader h_later
											WHERE	h_later.idfsMatrixType = 71300000000	-- Treatment-prophylactics AND vaccination measures
													AND	h_later.datStartDate <= tac.datStartDate
													AND	h_later.blnIsActive = 1
													AND h_later.intRowStatus = 0
													AND	h_later.datStartDate > h.datStartDate
												)
							)
					)
				AND h.intRowStatus = 0
				
	-- Matrix row
	INNER JOIN	tlbAggrProphylacticActionMTX tapam
	ON			tapam.idfVersion = h.idfVersion
				AND tapam.intRowStatus = 0
	
	JOIN @NotDeletedProphylacticAction Actual_Prophylactic_Action ON
		Actual_Prophylactic_Action.idfsProphylacticAction = tapam.idfsProphilacticAction
		
	JOIN @NotDeletedDiagnosis AS Actual_Diagnosis ON
		Actual_Diagnosis.idfsDiagnosis = tapam.idfsDiagnosis
		
	JOIN @NotDeletedSpecies AS Actual_Species_Type ON
		Actual_Species_Type.idfsSpeciesType = tapam.idfsSpeciesType
	
	LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
	ON			c.idfsReference = tac.idfsAdministrativeUnit
	LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
	ON			r.idfsRegion = tac.idfsAdministrativeUnit 
	LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
	ON			rr.idfsRayon = tac.idfsAdministrativeUnit
	LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
	ON			s.idfsSettlement = tac.idfsAdministrativeUnit
		
	WHERE @InvestigationOrMeasure = 1
		AND tac.intRowStatus = 0
		AND tac.idfsAggrCaseType = 10102003 /*Vet Aggregate Action*/
		AND tac.datStartDate >= @SDDate
		AND tac.datFinishDate < @EDDate
		
		
	DECLARE @MinAdminLevel BIGINT
	DECLARE @MinTimeInterval BIGINT

	SELECT	
		@MinAdminLevel = idfsStatisticAreaType
		, @MinTimeInterval = idfsStatisticPeriodType
	FROM report.FN_AggregateSettings_GET (10102003 /*Vet Aggregate Action*/)
	

	DELETE FROM #AggrCase
	WHERE idfAggrCase IN (
		SELECT
			idfAggrCase
		FROM (
			SELECT 
				COUNT(*) OVER (PARTITION BY ac.idfAggrCase) cnt
				, ac2.idfAggrCase
				, CASE 
					WHEN DATEDIFF(YEAR, ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(QUARTER, ac2.datStartDate, ac2.datFinishDate) > 1 
						THEN 10091005 --sptYear
					WHEN DATEDIFF(quarter, ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(MONTH, ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091003 --sptQuarter
					WHEN DATEDIFF(MONTH, ac2.datStartDate, ac2.datFinishDate) = 0 AND report.FN_GBL_WeekDateDiff_GET(ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091001 --sptMonth
					WHEN report.FN_GBL_WeekDateDiff_GET(ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(DAY, ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091004 --sptWeek
					WHEN DATEDIFF(DAY, ac2.datStartDate, ac2.datFinishDate) = 0
						THEN 10091002 --sptOnday
				END AS TimeInterval
				, CASE
					WHEN ac2.idfsAdministrativeUnit = c2.idfsReference THEN 10089001 --satCountry
					WHEN ac2.idfsAdministrativeUnit = r2.idfsRegion THEN 10089003 --satRegion
					WHEN ac2.idfsAdministrativeUnit = rr2.idfsRayon THEN 10089002 --satRayon
					WHEN ac2.idfsAdministrativeUnit = s2.idfsSettlement THEN 10089004 --satSettlement
				END AS AdminLevel
			FROM #AggrCase ac
			LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
			ON			c.idfsReference = ac.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
			ON			r.idfsRegion = ac.idfsAdministrativeUnit 
			LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
			ON			rr.idfsRayon = ac.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
			ON			s.idfsSettlement = ac.idfsAdministrativeUnit
				
			JOIN #AggrCase ac2 ON
				(
					ac2.datStartDate BETWEEN ac.datStartDate AND ac.datFinishDate
					OR ac2.datFinishDate BETWEEN ac.datStartDate AND ac.datFinishDate
				)
				
			LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c2
			ON			c2.idfsReference = ac2.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r2
			ON			r2.idfsRegion = ac2.idfsAdministrativeUnit 
			LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr2
			ON			rr2.idfsRayon = ac2.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s2
			ON			s2.idfsSettlement = ac2.idfsAdministrativeUnit
			
			WHERE COALESCE(s2.idfsRayon, rr2.idfsRayon) = ac.idfsAdministrativeUnit
				OR COALESCE(s2.idfsRegion, rr2.idfsRegion, r2.idfsRegion) = ac.idfsAdministrativeUnit
				OR COALESCE(s2.idfsCountry, rr2.idfsCountry, r2.idfsCountry, c2.idfsReference) = ac.idfsAdministrativeUnit
		) a
		WHERE cnt > 1	
			AND CASE WHEN TimeInterval = @MinTimeInterval AND AdminLevel = @MinAdminLevel THEN 1 ELSE 0 END = 0
	)

	

	CREATE TABLE #TestedCnt
	(
		idfAggrCase BIGINT
		, idfsSpeciesType BIGINT
		, idfsRegion BIGINT
		, idfsRayon BIGINT
		, idfTestedCount INT
	)
	
	INSERT INTO #TestedCnt
	SELECT
		ag.idfAggrCase
		, ag.idfsSpeciesType
		, ag.idfsRegion
		, ag.idfsRayon
		, CAST(tap.varValue AS INT)
	FROM #AggrCase ag 
	JOIN tlbActivityParameters tap ON
		tap.idfObservation = ag.idfObservation
		AND tap.idfRow = ag.idfAggrActionMTX
		AND tap.intRowStatus = 0
	JOIN ffParameter fp ON
		fp.idfsParameter = tap.idfsParameter
		AND fp.idfsFormType = 10034023	/*Diagnostic investigations*/
		AND fp.intRowStatus = 0
	JOIN trtBaseReference tbr2 ON
		tbr2.idfsBaseReference = fp.idfsParameter
		AND tbr2.idfsReferenceType = 19000066 /*Flexible Form Parameter Tooltip*/
		AND tbr2.strDefault = 'Tested'
		AND tbr2.intRowStatus = 0
	WHERE @InvestigationOrMeasure = 0
		AND SQL_VARIANT_PROPERTY(tap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
	
	
	CREATE TABLE #PositiveCnt
	(
		idfAggrCase BIGINT
		, idfsSpeciesType BIGINT
		, idfsRegion BIGINT
		, idfsRayon BIGINT
		, idfPositiveCount INT
	)
	
	INSERT INTO #PositiveCnt
	SELECT
		ag.idfAggrCase
		, ag.idfsSpeciesType
		, ag.idfsRegion
		, ag.idfsRayon
		, CAST(tap.varValue AS INT)
	FROM #AggrCase ag 
	JOIN tlbActivityParameters tap ON
		tap.idfObservation = ag.idfObservation
		AND tap.idfRow = ag.idfAggrActionMTX
		AND tap.intRowStatus = 0
	JOIN ffParameter fp ON
		fp.idfsParameter = tap.idfsParameter
		AND fp.idfsFormType = 10034023	/*Diagnostic investigations*/
		AND fp.intRowStatus = 0
	JOIN trtBaseReference tbr2 ON
		tbr2.idfsBaseReference = fp.idfsParameter
		AND tbr2.idfsReferenceType = 19000066 /*Flexible Form Parameter Tooltip*/
		AND tbr2.strDefault = 'Positive reaction taken (ea)'
		AND tbr2.intRowStatus = 0
	WHERE @InvestigationOrMeasure = 0
		AND SQL_VARIANT_PROPERTY(tap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
		AND EXISTS (SELECT TOP 1 1 FROM #TestedCnt tc WHERE tc.idfAggrCase = ag.idfAggrCase)
	
	CREATE TABLE #ActionTakenCnt
	(
		idfAggrCase BIGINT
		, idfsSpeciesType BIGINT
		, idfsRegion BIGINT
		, idfsRayon BIGINT
		, idfActionTakenCount INT
	)
	
	INSERT INTO #ActionTakenCnt
	SELECT
		ag.idfAggrCase
		, ag.idfsSpeciesType
		, ag.idfsRegion
		, ag.idfsRayon
		, CAST(tap.varValue AS INT)
	FROM #AggrCase ag 
	JOIN tlbActivityParameters tap ON
		tap.idfObservation = ag.idfObservation
		AND tap.idfRow = ag.idfAggrActionMTX
		AND tap.intRowStatus = 0
	JOIN ffParameter fp ON
		fp.idfsParameter = tap.idfsParameter
		AND fp.idfsFormType = 10034024	/*Treatment-prophylactics AND vaccination measures*/
		AND fp.intRowStatus = 0
	JOIN trtBaseReference tbr2 ON
		tbr2.idfsBaseReference = fp.idfsParameter
		AND tbr2.idfsReferenceType = 19000066 /*Flexible Form Parameter Tooltip*/
		AND tbr2.strDefault = 'Action taken (ea)'
		AND tbr2.intRowStatus = 0
	WHERE @InvestigationOrMeasure = 1
		AND SQL_VARIANT_PROPERTY(tap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
	
	
	CREATE TABLE #AggrCaseFinal
	(
		idfsRegion BIGINT
		, idfsRayon BIGINT
		, idfsSpeciesType BIGINT
		, CntTested INT
		, CntPositive INT
		, CntActionTaken INT
	)	

	
		INSERT INTO #AggrCaseFinal
		SELECT
			  ISNULL(tc1.idfsRegion,atc.idfsRegion)
			, ISNULL(tc1.idfsRayon, atc.idfsRayon)
			, ISNULL(tc1.idfsSpeciesType,atc.idfsSpeciesType)
			, SUM(ISNULL(tc1.idfTestedCount,0))
			, SUM(ISNULL(tc1.idfPositiveCount, 0))
			, SUM(ISNULL(atc.idfActionTakenCount,0))
		FROM (
		SELECT 
			tc.idfsRegion
			, tc.idfsRayon
			, tc.idfsSpeciesType
			, SUM(ISNULL(idfTestedCount,0)) AS idfTestedCount
			, SUM(ISNULL(pc.idfPositiveCount,0)) AS idfPositiveCount
		FROM #TestedCnt tc
		LEFT JOIN #PositiveCnt pc ON
			pc.idfAggrCase = tc.idfAggrCase
			AND pc.idfsSpeciesType = tc.idfsSpeciesType
		GROUP BY tc.idfsRegion
			, tc.idfsRayon
			, tc.idfsSpeciesType
			) tc1
		FULL OUTER JOIN #ActionTakenCnt atc ON 
		tc1.idfsRegion=atc.idfsRegion
		AND tc1.idfsRayon= atc.idfsRayon
		AND tc1.idfsSpeciesType=atc.idfsSpeciesType
		GROUP BY 
			  ISNULL(tc1.idfsRegion,atc.idfsRegion)
			, ISNULL(tc1.idfsRayon, atc.idfsRayon)
			, ISNULL(tc1.idfsSpeciesType,atc.idfsSpeciesType)


		SELECT
			CASE ray.idfsRegion 
				WHEN @idfsRegionBaku THEN 1 
				WHEN @idfsRegionOtherRayons THEN 2
				WHEN @idfsRegionNakhichevanAR THEN 3
				ELSE 0
			END AS intRegionOrder
			, refReg.[name] AS strRegion
			, refRay.[name] AS strRayon
			, ref_spec.[name] AS strSpecies
			,CASE WHEN @InvestigationOrMeasure = 0 THEN 2
			 ELSE  1 END AS intSubcolumnCount
			,MAX(ISNULL(ag.CntTested,0)) AS CntTested
			,MAX(ISNULL(ag.CntPositive,0)) AS CntPositive
			,MAX(ISNULL(ag.CntActionTaken,0)) AS CntActionTaken
			,@InvestigationOrMeasure AS InvestigationOrMeasure
		FROM report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) AS reg
		JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003 /*rftRegion*/) AS refReg ON
			reg.idfsRegion = refReg.idfsReference			
			AND reg.idfsCountry = @CountryID
		JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) AS ray ON 
			ray.idfsRegion = reg.idfsRegion	
		JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002 /*rftRayon*/) AS refRay ON
			ray.idfsRayon = refRay.idfsReference
		LEFT JOIN @SpeciesTypeTABLE stt ON 1=1
		LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID, 19000086) ref_spec ON
			stt.[key] = ref_spec.idfsReference	
		LEFT JOIN #AggrCaseFinal ag ON
			ag.idfsRegion = ray.idfsRegion
			AND ag.idfsRayon = ray.idfsRayon
			AND ag.idfsSpeciesType = ref_spec.idfsReference 
	
		GROUP BY CASE ray.idfsRegion 
					WHEN @idfsRegionBaku THEN 1 
					WHEN @idfsRegionOtherRayons THEN 2
					WHEN @idfsRegionNakhichevanAR THEN 3
					ELSE 0
				END
				, refReg.[name]
				, refRay.[name]
				, ref_spec.[name]
		ORDER BY intRegionOrder, strRayon
	
		
	
	-- Drop temporary TABLEs
	IF Object_ID('tempdb..#AggrCase') IS NOT NULL
	BEGIN
		SET	@drop_cmd = N'drop TABLE #AggrCase'
		EXECUTE sp_executesql @drop_cmd
	END

	IF Object_ID('tempdb..#TestedCnt') IS NOT NULL
	BEGIN
		SET	@drop_cmd = N'drop TABLE #TestedCnt'
		EXECUTE sp_executesql @drop_cmd
	END

	IF Object_ID('tempdb..#PositiveCnt') IS NOT NULL
	BEGIN
		SET	@drop_cmd = N'drop TABLE #PositiveCnt'
		EXECUTE sp_executesql @drop_cmd
	END

	IF Object_ID('tempdb..#ActionTakenCnt') IS NOT NULL
	BEGIN
		SET	@drop_cmd = N'drop TABLE #ActionTakenCnt'
		EXECUTE sp_executesql @drop_cmd
	END
	
	IF Object_ID('tempdb..#AggrCaseFinal') IS NOT NULL
	BEGIN
		SET	@drop_cmd = N'drop TABLE #AggrCaseFinal'
		EXECUTE sp_executesql @drop_cmd
	END

