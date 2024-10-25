
--*************************************************************************
-- Name 				: report.USP_REP_VET_LabReportAZ
-- DescriptiON			: Select data for Vet Lab report.
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_VET_LabReportAZ @LangID=N'az-L', @SD = '20140101', @ED = '20141231'
EXEC report.USP_REP_VET_LabReportAZ 'ru','20120101','20131231'
EXEC report.USP_REP_VET_LabReportAZ 'ru','20160101','20160630'
*/

CREATE PROCEDURE [Report].[USP_REP_VET_LabReportAZ]
    (
        @LangID AS NVARCHAR(10)
        , @SD AS NVARCHAR(20)
 		, @ED AS NVARCHAR(20)
		, @RegionID AS BIGINT = NULL
		, @RayonID AS BIGINT = NULL
		, @OrganizationEntered AS BIGINT = NULL
		, @UserId AS BIGINT = NULL
    )
AS
BEGIN

	IF @OrganizationEntered=0  
		SET @OrganizationEntered = NULL
	IF @RegionID=0
		SET @RegionID = NULL
	IF @RayonID=0
		SET @RayonID = NULL
		
	DECLARE @FromDate DATETIME 
		, @ToDate DATETIME
		
	DECLARE
	  @sql AS NVARCHAR (MAX)
	  , @case AS NVARCHAR(MAX) = ''
	  , @case2 AS NVARCHAR(MAX) = ''

	SET @FromDate = dbo.fn_SetMinMaxTime(CAST(@SD AS DATETIME),0)
	SET @ToDate = dbo.fn_SetMinMaxTime(CAST(@ED AS DATETIME),1)
	
	DECLARE @strUserOrganization NVARCHAR(500) = ''
	SELECT
		@strUserOrganization = tp.strFirstName + ' ' + tp.strFamilyName + '(' + fr.name + ')'
	FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000046 /*Organization Name*/) fr
	JOIN tlbOffice to1 ON
		to1.idfsOfficeName = fr.idfsReference
	JOIN tlbPerson tp ON
		tp.idfInstitution = to1.idfOffice
	JOIN tstUserTable tut ON
		tut.idfPerson = tp.idfPerson
	WHERE tut.idfUserID = @UserId

	DECLARE @Country BIGINT = 170000000 /*AZ*/

	DECLARE @FilteredRayons AS TABLE (idfsRayon BIGINT PRIMARY KEY)

	INSERT INTO @FilteredRayons (idfsRayon)
	SELECT 
		gr.idfsRayon
	FROM report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) gr 
	WHERE gr.idfsRegion = ISNULL(@RegionID, idfsRegion)
		AND gr.idfsRayon = ISNULL(@RayonID, idfsRayon)
		AND gr.idfsCountry = @Country


	DECLARE @idfsSummaryReportType BIGINT
		
	SET @idfsSummaryReportType = 10290026 /*AZ RepVetLabReportAZ*/

	IF OBJECT_ID('tempdb..##TempVetCase') IS NOT NULL
	DROP TABLE ##TempVetCase

	CREATE TABLE ##TempVetCase
	(
		idfsDiagnosis BIGINT
		, idfsSpeciesType BIGINT
		, blnIndicative INT
		, TestName NVARCHAR(500) COLLATE database_default
		, idfMaterial BIGINT
		, x INT
	)


	DECLARE @NotDeletedDiagnosis AS TABLE (
		idfsDiagnosis BIGINT
		, idfsActualDiagnosis BIGINT
	)

	INSERT INTO @NotDeletedDiagnosis
	SELECT
		idfsDiagnosis
		, idfsActualDiagnosis
	FROM (
		SELECT
			ISNULL(r_d.idfsReference,d_actual.idfsDiagnosis) AS idfsDiagnosis
			, ISNULL(d_actual.idfsDiagnosis, r_d.idfsReference) AS idfsActualDiagnosis
			, ROW_NUMBER() OVER (PARTITION BY ISNULL(r_d.idfsReference,d_actual.idfsDiagnosis) ORDER BY ISNULL(d_actual.idfsDiagnosis, r_d.idfsReference)) AS rn
		FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) r_d
		LEFT JOIN trtDiagnosis d_actual
			JOIN FN_GBL_Reference_GETList(@LangID, 19000019) r_d_actual ON
				r_d_actual.idfsReference = d_actual.idfsDiagnosis
		ON r_d_actual.[name] = r_d.[name] COLLATE Cyrillic_General_CI_AS
			AND d_actual.idfsUsingType = 10020001	/*Case-based*/
			AND d_actual.intRowStatus = 0
	) tt
	WHERE tt.rn = 1



	/*собираем кейсы, подпадающие под условия*/
	INSERT INTO ##TempVetCase
	SELECT
		tt.idfsDiagnosis
		, ts.idfsSpeciesType
		, CAST(ISNULL(tttttr.blnIndicative, 0) AS INT) AS blnIndicative
		, tnr.name AS TestName
		, CASE WHEN tm.idfRootMaterial = tm.idfMaterial 
				THEN tm.idfMaterial ELSE NULL END /*Only originally collected Samples (not Aliquots and/or Derivatives) shall be counted for the report*/
		, 1
	FROM tlbTesting tt 
	JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000097) tnr ON /*Test Name*/
		tnr.idfsReference = tt.idfsTestName
		and tnr.[name] is not null
	LEFT JOIN trtTestTypeToTestResult tttttr ON
		tttttr.idfsTestName = tt.idfsTestName
		AND tttttr.idfsTestResult = tt.idfsTestResult
		AND tttttr.intRowStatus = 0
		
	JOIN tlbMaterial tm ON
		tm.idfMaterial = tt.idfMaterial
		AND tm.intRowStatus = 0
		AND COALESCE(tm.idfSpecies, tm.idfAnimal, -1) <> -1 /*samples taken from Species or Animal*/
		AND tm.idfsSampleType <> 10320001 /*Unknown*/
	LEFT JOIN tlbAnimal ta ON
		ta.idfAnimal = tm.idfAnimal
		AND ta.intRowStatus = 0
	JOIN tlbSpecies ts ON
		ts.idfSpecies = ISNULL(tm.idfSpecies, ta.idfSpecies)
		AND ts.intRowStatus = 0
	JOIN tlbHerd th ON
		th.idfHerd = ts.idfHerd
		AND th.intRowStatus = 0
	JOIN tlbFarm tf ON
		tf.idfFarm = th.idfFarm
		AND tf.intRowStatus = 0
	LEFT JOIN tlbGeoLocation tgl ON
		tgl.idfGeoLocation = tf.idfFarmAddress
		AND tgl.intRowStatus = 0
	LEFT JOIN @FilteredRayons fr ON
		fr.idfsRayon = tgl.idfsRayon
		
	LEFT JOIN tlbVetCase tvc ON
		tvc.idfVetCase = tm.idfVetCase
		AND tvc.intRowStatus = 0
	LEFT JOIN tlbHumanCase thc ON
		thc.idfHumanCase = tm.idfHumanCase
		AND thc.intRowStatus = 0
	LEFT JOIN tlbMonitoringSession tms ON	
		tms.idfMonitoringSession = tm.idfMonitoringSession
		AND tms.intRowStatus = 0
	LEFT JOIN @FilteredRayons fr2 ON
		fr2.idfsRayon = tms.idfsRayon
		
	JOIN tstSite tsite ON
		tsite.idfsSite = COALESCE(tvc.idfsSite, thc.idfsSite, tms.idfsSite)
		AND tsite.intRowStatus = 0
		
	WHERE tt.intRowStatus = 0
		AND (tm.blnAccessioned = 1 OR tm.idfsSampleKind = 12675430000000 /*Tranferred In*/)
														/*The only Samples, which were accessioned in (Accession In procedure were 
														performed for the Sample) or transferred in (Transfer In procedure were performed 
														for the Sample), shall be counted for the report*/
		
		AND (tt.idfsTestStatus = 10001001 /*Completed*/ OR tt.idfsTestStatus = 10001006 /*Amended*/)
		AND tt.blnNonLaboratoryTest = 0
		
		AND tt.datConcludedDate >= @FromDate /*фильтр по дате*/
		AND tt.datConcludedDate < @ToDate
		
		AND tt.blnReadOnly = 0 /*Samples and Laboratory Tests included in Livestock Case, which are the copies of Samples and Laboratory Tests 
								included in Active Surveillance Session, from which Livestock Case was created, shall not be counted for the report. */
		
		AND (/*фильтр по району, если это материал кейса - то району фермы, если материал сессии - по району сессии*/
				(tm.idfMonitoringSession IS NULL AND fr.idfsRayon IS NOT NULL) 
				OR (tm.idfMonitoringSession IS NOT NULL AND fr2.idfsRayon IS NOT NULL) 
			)

		AND tt.idfTestedByOffice = ISNULL(@OrganizationEntered, tt.idfTestedByOffice)


	INSERT INTO	##TempVetCase
	(	idfsDiagnosis,
		idfsSpeciesType,
		blnIndicative,
		TestName,
		idfMaterial,
		x
	)
	SELECT	tvc.idfsDiagnosis,
				tvc.idfsSpeciesType,
				CAST(0 AS INT),
				tnr.[name],
				NULL,
				NULL
	FROM		FN_GBL_Reference_GETList(@LangID, 19000097) tnr /*Test Name*/
	INNER JOIN	##TempVetCase tvc
	ON			tvc.TestName IS NOT NULL
	--left join	##TempVetCase tvc_min
	--on			tvc_min.TestName is not null and
	--			tvc_min.idfsDiagnosis = tvc.idfsDiagnosis
	--			and tvc_min.idfsSpeciesType = tvc.idfsSpeciesType
	--			and (	ISNULL(tvc_min.idfMaterial, -1) < ISNULL(tvc.idfMaterial, -1)
	--					or	(	ISNULL(tvc_min.idfMaterial, -1) = ISNULL(tvc.idfMaterial, -1)
	--							and tvc_min.TestName < tvc.TestName COLLATE Cyrillic_General_CI_AS
	--						)
	--			)
				
	OUTER APPLY	(
				SELECT TOP 1 tvc_min.x 
				FROM ##TempVetCase tvc_min
				WHERE
				tvc_min.TestName IS NOT NULL and
				tvc_min.idfsDiagnosis = tvc.idfsDiagnosis
				AND tvc_min.idfsSpeciesType = tvc.idfsSpeciesType
				AND (	ISNULL(tvc_min.idfMaterial, -1) < ISNULL(tvc.idfMaterial, -1)
						OR	(	ISNULL(tvc_min.idfMaterial, -1) = ISNULL(tvc.idfMaterial, -1)
								and tvc_min.TestName < tvc.TestName COLLATE Cyrillic_General_CI_AS
							)
				)	
	) AS oa	
	WHERE		(	tnr.intHACode & 32 = 32	-- Livestock
					OR	tnr.intHACode & 64 = 64	-- Avian
				)
				AND NOT EXISTS	(
							SELECT	*
							FROM	##TempVetCase tvc_ex
							WHERE	tvc_ex.TestName = tnr.[name] COLLATE Cyrillic_General_CI_AS
								)
				AND oa.x IS NULL -- tvc_min.x is null


	INSERT INTO	##TempVetCase
	(	idfsDiagnosis,
		idfsSpeciesType,
		blnIndicative,
		TestName,
		idfMaterial,
		x
	)
	SELECT		-1,
				-1,
				CAST(0 AS INT),
				tnr.[name],
				NULL,
				NULL
	FROM		FN_GBL_Reference_GETList(@LangID, 19000097) tnr /*Test Name*/
	WHERE		(	tnr.intHACode & 32 = 32	-- Livestock
					OR	tnr.intHACode & 64 = 64	-- Avian
				)
				AND NOT EXISTS	(
							SELECT	*
							FROM	##TempVetCase tvc_ex
								)


	IF OBJECT_ID('tempdb..##TempVetCase1') IS NOT NULL
	DROP TABLE ##TempVetCase2

	CREATE TABLE ##TempVetCase1
	(
		idfsDiagnosis BIGINT
		, idfsSpeciesType BIGINT
		, blnIndicative INT
		, TestName NVARCHAR(500) COLLATE database_default
		, idfMaterial BIGINT
		, x INT
	)

	INSERT INTO ##TempVetCase1
	SELECT
		ndd.idfsActualDiagnosis
		, vc.idfsSpeciesType
		, vc.blnIndicative
		, vc.TestName
		, vc.idfMaterial
		, vc.x
	FROM ##TempVetCase vc
	JOIN @NotDeletedDiagnosis ndd ON
		ndd.idfsDiagnosis = vc.idfsDiagnosis




	IF OBJECT_ID('tempdb..##TempVetCase2') IS NOT NULL
	DROP TABLE ##TempVetCase2

	CREATE TABLE ##TempVetCase2
	(
		idfsDiagnosis BIGINT
		, idfsSpeciesType BIGINT
		, CntSamples INT
		, SumPositive INT
	)

	INSERT INTO ##TempVetCase2
	SELECT
		ndd.idfsActualDiagnosis
		, vc.idfsSpeciesType
		, COUNT(DISTINCT idfMaterial) AS CntSamples
		, CASE WHEN SUM(blnIndicative) = 0 THEN NULL ELSE SUM(blnIndicative) END AS SumPositive
	FROM ##TempVetCase vc
	JOIN @NotDeletedDiagnosis ndd ON
		ndd.idfsDiagnosis = vc.idfsDiagnosis
	WHERE vc.idfMaterial IS NOT NULL
	GROUP BY ndd.idfsActualDiagnosis
		, vc.idfsSpeciesType

	IF	NOT EXISTS	(	SELECT	*
						FROM	##TempVetCase tvc_ex
						WHERE	 ISNULL(tvc_ex.idfsDiagnosis, -1) <> -1
					)
	BEGIN
		INSERT INTO ##TempVetCase2
		SELECT
			-1
			, -1
			, NULL AS CntSamples
			, NULL AS SumPositive
	end

	IF EXISTS (SELECT * FROM ##TempVetCase tvc WHERE ISNULL(tvc.idfsDiagnosis, -1) <> -1)
	BEGIN
		SELECT @sql = N'
		SELECT @case=@case+''[''+CONVERT(NVARCHAR(MAX), TestName)+''], '''+
		' FROM ##TempVetCase GROUP BY TestName ORDER BY TestName'

		EXEC sp_executesql @sql,N'@case NVARCHAR(MAX) out', @case = @case OUT
		SET @case = LEFT(@case, LEN(@case) - 1)


		SELECT @sql = N'
		SELECT @case2=@case2+''[''+CONVERT(NVARCHAR(MAX), TestName)+'']  AS intTest_'' + CAST(row_number() over (order by TestName) AS NVARCHAR(10)) + '', N''''''+CONVERT(NVARCHAR(500), TestName)+'''''' as strTestName_'' + CAST(row_number() over (order by TestName) AS NVARCHAR(10)) + '', '''+
		' FROM ##TempVetCase GROUP BY TestName ORDER BY TestName'

		EXEC sp_executesql @sql, N'@case2 NVARCHAR(MAX) out', @case2 = @case2 OUT
		SET @case2 = LEFT(@case2, LEN(@case2) - 1)
		

		SELECT @sql = N'
		SELECT 
			CAST(idfsDiagnosis AS NVARCHAR(50)) + ''_'' + CAST(idfsSpeciesType AS NVARCHAR(50))		AS strDiagnosisSpeciesKey
			, idfsDiagnosis
			, strDiagnosisName
			, strOIECode
			, idfsSpeciesType
			, strSpecies
			, AmountOfSpecimenTaken
			, ' + @case2 + ' 
			, PositiveResults
			
			, DiagniosisOrder
			, SpeciesOrder
			, N''' + @strUserOrganization + ''' as strUserOrganization
			
		FROM (
			SELECT 
				tt.TestName AS y
				, frr.name AS strSpecies
				, fdr.name AS strDiagnosisName
				, td.strOIECode	AS strOIECode
				, tt2.CntSamples AS AmountOfSpecimenTaken
				, tt2.SumPositive AS PositiveResults
				, tt.idfsDiagnosis
				, tt.idfsSpeciesType
				, fdr.intOrder AS DiagniosisOrder
				, frr.intOrder AS SpeciesOrder
				, x 
			FROM ##TempVetCase1 tt
			JOIN dbo.FN_GBL_ReferenceRepair(''' + @LangID + ''', 19000086) frr ON /*Species List*/
				frr.idfsReference = tt.idfsSpeciesType
			JOIN dbo.FN_GBL_ReferenceRepair(''' + @LangID + ''', 19000019) fdr ON /*Diagnosis*/
				fdr.idfsReference = tt.idfsDiagnosis
			JOIN trtDiagnosis td ON
				td.idfsDiagnosis = tt.idfsDiagnosis
			JOIN ##TempVetCase2 tt2 ON
				tt2.idfsDiagnosis = tt.idfsDiagnosis
				AND tt2.idfsSpeciesType = tt.idfsSpeciesType
		) as s 
		PIVOT
		(SUM(x) for y in ('+@case+')) as pv
		ORDER BY DiagniosisOrder, strDiagnosisName, SpeciesOrder, strSpecies'
		PRINT @sql
		EXECUTE (@sql)
	END
	ELSE BEGIN
		SELECT @sql = N'
		SELECT @case=@case+''[''+REPLACE(CONVERT(NVARCHAR(MAX), [name]), '''''''', '''''''''''')+''], '''+
		' FROM FN_GBL_Reference_GETList(''' + @LangID + N''', 19000097) WHERE (intHACode & 96 > 0) and name <>'''' GROUP BY [name] ORDER BY [name]'	-- Test Name

		EXEC sp_executesql @sql,N'@case NVARCHAR(MAX) out', @case = @case OUT
		SET @case = LEFT(@case, LEN(@case) - 1)
		
		SELECT @sql = N'
		SELECT @case2=@case2+''null  AS intTest_'' + CAST(row_number() over (order by [name]) AS NVARCHAR(10)) + '', N''''''+REPLACE(CONVERT(NVARCHAR(MAX), [name]), '''''''', '''''''''''')+'''''' as strTestName_'' + CAST(row_number() over (order by [name]) AS NVARCHAR(10)) + '', '''+
		' FROM FN_GBL_Reference_GETList(''' + @LangID + N''', 19000097) WHERE (intHACode & 96 > 0) GROUP BY [name] ORDER BY [name]'	-- Test Name

		EXEC sp_executesql @sql, N'@case2 NVARCHAR(MAX) out', @case2 = @case2 OUT
		SET @case2 = LEFT(@case2, LEN(@case2) - 1)


		SELECT @sql = N'
		SELECT
			CAST(1 AS NVARCHAR(50)) + ''_'' + CAST(1 AS NVARCHAR(50))		AS strDiagnosisSpeciesKey
			, idfsDiagnosis
			, strDiagnosisName
			, strOIECode
			, idfsSpeciesType
			, strSpecies
			, AmountOfSpecimenTaken
			, ' + @case2 + ' 
			, PositiveResults
			
			, DiagniosisOrder
			, SpeciesOrder
			, N''' + @strUserOrganization + ''' as strUserOrganization
			
		FROM (
			SELECT 
				tt.TestName AS y
				, null AS strSpecies
				, null AS strDiagnosisName
				, null	AS strOIECode
				, tt2.CntSamples AS AmountOfSpecimenTaken
				, tt2.SumPositive AS PositiveResults
				, tt.idfsDiagnosis
				, tt.idfsSpeciesType
				, 0 AS DiagniosisOrder
				, 0 AS SpeciesOrder
				, x 
			FROM ##TempVetCase1 tt
			JOIN ##TempVetCase2 tt2 ON
				ISNULL(tt2.idfsDiagnosis, -1) = ISNULL(tt.idfsDiagnosis, -1)
				AND ISNULL(tt2.idfsSpeciesType, -1) = ISNULL(tt.idfsSpeciesType, -1)
		) as s 
		PIVOT
		(SUM(x) for y in ('+@case+')) as pv
		'
		PRINT @sql
		EXECUTE (@sql)
	END


	DROP TABLE ##TempVetCase
	DROP TABLE ##TempVetCase1
	DROP TABLE ##TempVetCase2
	
END


