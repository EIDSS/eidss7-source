
--*************************************************************************
-- Name 				: USP_REP_HUM_SummaryRayonDiseaseAge
-- Description			: Human Cases by Rayon and Disease Summary Report 
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
EXEC report.USP_REP_HUM_CasesByRayonAndDiseaseSummary 
'en', 
N'2011-04-29T00:00:00',
N'2018-05-29T00:00:00',
'7718050000000,7720340000000,7721290000000'

EXEC report.USP_REP_HUM_CasesByRayonAndDiseaseSummary 
N'en',
N'2011-04-29T00:00:00',
N'2018-05-29T00:00:00',
'57972080000000,56161350000000,57972090000000,9842410000000,9842610000000'

EXEC report.USP_REP_HUM_CasesByRayonAndDiseaseSummary 
N'EN',
N'',
N'',
'9844170000000,9843850000000'
*/
--*************************************************************************

CREATE PROCEDURE  [Report].[USP_REP_HUM_CasesByRayonAndDiseaseSummary]
(
	 @LangID		AS NVARCHAR(50),
	 @SD			AS DATETIME, 
	 @ED			AS DATETIME,
	 @Diagnosis		AS NVARCHAR(MAX)
)
AS

--EXEC [report].[USP_GBL_FirstDay_SET]
IF(ltrim(isnull(@SD,'')) !='Jan  1 1900 12:00AM' OR ltrim(isnull(@ED,'')) !='Jan  1 1900 12:00AM' OR @Diagnosis !='')
BEGIN
	DECLARE 
		@SDDate_agr AS DATETIME,
		@EDDate_agr AS DATETIME,

		@CountryID BIGINT,
		@iDiagnosis	INT,
		@idfsLanguage BIGINT,
		
		@MinAdminLevel BIGINT,
		@MinTimeInterval BIGINT,
		@AggrCaseType BIGINT,

		@idfsSummaryReportType BIGINT,		
		@FFP_Total BIGINT,
		@FFP_Age_0_17 BIGINT		,
		@sql NVARCHAR(MAX)			 ,
		@select NVARCHAR(MAX) ,
		@from NVARCHAR(MAX),
		
		@idfsRegionBaku BIGINT,
		@idfsRegionOtherRayons BIGINT,
		@idfsRegionNakhichevanAR BIGINT

	DECLARE @DiagnosisTable	TABLE
		(
			idfsDiagnosis BIGINT			
		)	
	
	INSERT INTO @DiagnosisTable 
 	SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@Diagnosis,1,',')

	DECLARE  @ReportDiagnosisTable TABLE
	(	  idfsDiagnosis		BIGINT NOT NULL,
		  blnIsAggregate	BIT,
		  intTotal			INT NOT NULL,
		  intAge_0_17		INT NOT NULL,
		  idfsRegion		BIGINT NOT NULL,
		  idfsRayon			BIGINT NOT NULL,
		PRIMARY KEY (idfsDiagnosis, idfsRegion, idfsRayon)
	)
				
	IF OBJECT_ID('tempdb.dbo.#ReportTable') IS NOT NULL 
	DROP TABLE #ReportTable
				
	CREATE	TABLE #ReportTable	
	(	  idfsDiagnosis		BIGINT NOT NULL
		, strDiagnosis		NVARCHAR (300) collate database_default NOT NULL 
		, blnIsTransportCHE BIT
		, idfsRegion		BIGINT NOT NULL
		, idfsRayon			BIGINT NOT NULL
		, strRegion			NVARCHAR (2000) collate database_default NOT NULL 
		, strRayon			NVARCHAR (2000) collate database_default NOT NULL      	
		, intTotal			INT NOT NULL
		, intAge_0_17		INT NOT NULL
		, intRegionOrder	INT NOT NULL
		, PRIMARY KEY (idfsDiagnosis, idfsRegion, idfsRayon)
	)				

	
	SELECT 
	@SDDate_agr =	CASE 
						WHEN @SD <> dateadd(day,1-day(@SD),@SD) 
						THEN dateadd(day,1-day(dateadd(mm, 1,@SD)),dateadd(mm, 1,@SD))
						ELSE @SD
					END,
	@EDDate_agr =	CASE
						WHEN @ED <> dateadd(month,1,dateadd(day,1-day(@ED),@ED))-1
						THEN dateadd(month,1,dateadd(day,1-day(dateadd(mm, -1, @ED)),dateadd(mm, -1, @ED)))-1
						ELSE @ED
					END
	
	
	
	SET @CountryID = 170000000

	--SET @idfsLanguage = dbo.fnGetLanguageCode (@LangID)		  
	SET @idfsLanguage = dbo.FN_GBL_LanguageCode_GET (@LangID)

	SET @idfsSummaryReportType = 10290002 /*Summary Report*/

	SELECT @FFP_Total = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Total'
	AND intRowStatus = 0


	SELECT @FFP_Age_0_17 = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Age_0_17'
	AND intRowStatus = 0
	
 
 	--1344330000000 --Baku
	SELECT @idfsRegionBaku = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Baku'

	--1344340000000 --Other rayons
	SELECT @idfsRegionOtherRayons = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Other rayons'


	--1344350000000 --Nakhichevan AR
	SELECT @idfsRegionNakhichevanAR = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Nakhichevan AR'    
	
		
 	--Transport CHE
 	DECLARE @TransportCHE BIGINT
 
 	SELECT @TransportCHE = frr.idfsReference
 	FROM report.FN_GBL_GIS_ReferenceRepair_GET('en', 19000020) frr
 	WHERE frr.name =  'Transport CHE'
 	--print @TransportCHE
 			

		
	INSERT INTO #ReportTable
	(
		  idfsDiagnosis
		, strDiagnosis
		, blnIsTransportCHE
		, idfsRegion
		, idfsRayon
		, strRegion
		, strRayon 	
		, intTotal
		, intAge_0_17
		, intRegionOrder
	)
	SELECT
	trtd.idfsDiagnosis,
	IsNull(c.strTextString, br.strDefault) as strDefault,
	0,
	ray.idfsRegion,
	ray.idfsRayon,
	ISNULL(gsnt_reg.strTextString, gbr_reg.strDefault),
	ISNULL(gsnt_ray.strTextString, gbr_ray.strDefault),
	0,
	0,
	CASE ray.idfsRegion
	  WHEN @idfsRegionBaku --Baku
	  THEN 1
	  
	  WHEN @idfsRegionOtherRayons --Other rayons
	  THEN 2
	  
	  WHEN @idfsRegionNakhichevanAR --Nakhichevan AR
	  THEN 3
	  
	  ELSE 0
	 END 
  
  FROM @DiagnosisTable dt
    INNER JOIN trtDiagnosis trtd
    ON trtd.idfsDiagnosis = dt.idfsDiagnosis 
       AND trtd.intRowStatus = 0
      
    INNER JOIN trtBaseReference br
    ON br.idfsBaseReference = trtd.idfsDiagnosis
    AND br.intRowStatus = 0
    
    LEFT JOIN dbo.trtStringNameTranslation as c with (nolock) 
    on br.idfsBaseReference = c.idfsBaseReference and c.idfsLanguage = @idfsLanguage 
      
    JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) ray
      INNER JOIN report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) reg
      ON ray.idfsRegion = reg.idfsRegion
      AND reg.intRowStatus = 0
      AND reg.idfsCountry = @CountryID
      
      INNER JOIN gisBaseReference gbr_reg
      ON gbr_reg.idfsGISBaseReference = reg.idfsRegion
      AND gbr_reg.intRowStatus = 0
      
      INNER JOIN dbo.gisStringNameTranslation gsnt_reg
      ON gsnt_reg.idfsGISBaseReference = gbr_reg.idfsGISBaseReference
      AND gsnt_reg.idfsLanguage = @idfsLanguage
      AND gsnt_reg.intRowStatus = 0
      
      INNER JOIN gisBaseReference gbr_ray
      ON gbr_ray.idfsGISBaseReference = ray.idfsRayon
      AND gbr_ray.intRowStatus = 0
      
      INNER JOIN dbo.gisStringNameTranslation gsnt_ray
      ON gsnt_ray.idfsGISBaseReference = gbr_ray.idfsGISBaseReference
      AND gsnt_ray.idfsLanguage = @idfsLanguage
      AND gsnt_ray.intRowStatus = 0
    ON ray.intRowStatus = 0
      
  INSERT INTO #ReportTable
  (
	  idfsDiagnosis
	, strDiagnosis
	, blnIsTransportCHE
	, idfsRegion
	, idfsRayon
	, strRegion
	, strRayon 	
	, intTotal
	, intAge_0_17
	, intRegionOrder
  )
  SELECT
    trtd.idfsDiagnosis,
    IsNull(c.strTextString, br.strDefault) as strDefault,
    1,
    reg.idfsGISBaseReference,
    ray.idfsSite,
    ISNULL(gsnt_reg.strTextString, reg.strDefault),
    i.[name],
    0,
    0,
    4
  
	FROM @DiagnosisTable dt
	INNER JOIN trtDiagnosis trtd
	on trtd.idfsDiagnosis = dt.idfsDiagnosis
	   AND trtd.intRowStatus = 0
	  
	INNER JOIN trtBaseReference br
	ON br.idfsBaseReference = trtd.idfsDiagnosis
	AND br.intRowStatus = 0
	 
	LEFT JOIN dbo.trtStringNameTranslation as c with (nolock) 
    on br.idfsBaseReference = c.idfsBaseReference and c.idfsLanguage = @idfsLanguage 
     
	JOIN tstSite ray
		JOIN gisBaseReference reg
		ON reg.idfsGISBaseReference = @TransportCHE

		INNER JOIN dbo.gisStringNameTranslation gsnt_reg
		ON gsnt_reg.idfsGISBaseReference = reg.idfsGISBaseReference
		AND gsnt_reg.idfsLanguage = @idfsLanguage
		AND gsnt_reg.intRowStatus = 0

		INNER JOIN	report.FN_REP_InstitutionRepair(@LangID) AS i  
		ON	ray.idfOffice = i.idfOffice  

	ON ray.intRowStatus = 0		
	AND ray.intFlags = 1				
							
	INSERT INTO @ReportDiagnosisTable (
		idfsDiagnosis,
		blnIsAggregate,
		intTotal,
		intAge_0_17,
		idfsRegion,
		idfsRayon
	) 
	SELECT distinct
		rt.idfsDiagnosis,
		CASE WHEN  trtd.idfsUsingType = 10020002  --dutAggregatedCase
		THEN 1
		ELSE 0
		END,
		0,
		0,
		rt.idfsRegion,
		rt.idfsRayon

	FROM #ReportTable rt
	INNER JOIN trtDiagnosis trtd
	ON trtd.idfsDiagnosis = rt.idfsDiagnosis
	   AND trtd.intRowStatus = 0
						

/*
19000091	rftStatisticPeriodType:
    10091001	sptMonth	Month
    10091002	sptOnday	Day
    10091003	sptQuarter	Quarter
    10091004	sptWeek	Week
    10091005	sptYear	Year
19000089	rftStatisticAreaType
    10089001	satCountry	Country
    10089002	satRayon	Rayon
    10089003	satRegion	Region
    10089004	satSettlement	Settlement
19000102	rftAggregateCaseType:
    10102001  Aggregate Case
*/



	SET @AggrCaseType = 10102001

	SELECT	@MinAdminLevel = idfsStatisticAreaType,
			@MinTimeInterval = idfsStatisticPeriodType
	FROM report.FN_GBL_AggregateSettings_GET (@AggrCaseType)--@AggrCaseType


	DECLARE	@ReportHumanAggregateCase	table
	(	idfAggrCase	BIGINT NOT NULL PRIMARY KEY,
	  idfCaseObservation BIGINT,
	  datStartDate DATETIME,
	  idfVersion BIGINT,
	  idfsRegion BIGINT NOT NULL,
	  idfsRayon BIGINT NOT NULL
	)


	INSERT INTO	@ReportHumanAggregateCase
	( idfAggrCase,
	  idfCaseObservation,
	  datStartDate,
	  idfVersion,
	  idfsRegion,
	  idfsRayon
	)
	SELECT		
		a.idfAggrCase,
		a.idfCaseObservation,
		a.datStartDate,
		a.idfVersion,
		CASE WHEN ts.idfsSite is NOT NULL THEN @TransportCHE ELSE  ISNULL(rr.idfsRegion, s.idfsRegion) END,
		CASE WHEN ts.idfsSite is NOT NULL THEN ts.idfsSite ELSE  ISNULL(rr.idfsRayon, s.idfsRayon) END
	FROM		tlbAggrCase a
		LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
		ON			rr.idfsRayon = a.idfsAdministrativeUnit
					AND rr.idfsCountry = @CountryID
		LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
		ON			s.idfsSettlement = a.idfsAdministrativeUnit
					AND s.idfsCountry = @CountryID
		LEFT JOIN tstSite ts
			JOIN tstCustomizationPackage tcpac 
		ON			tcpac.idfCustomizationPackage = ts.idfCustomizationPackage
				AND tcpac.idfsCountry = @CountryID
		ON			ts.idfsSite = a.idfsAdministrativeUnit
					AND ts.intRowStatus = 0
					AND ts.intFlags = 1	
	WHERE 			
				a.idfsAggrCaseType = @AggrCaseType
				AND (	@SDDate_agr <= a.datStartDate
						AND a.datFinishDate <  DATEADD(day, 1, @EDDate_agr) 
					)
				AND (	(	@MinTimeInterval = 10091005 --'sptYear'
							AND DATEDIFF(year, a.datStartDate, a.datFinishDate) = 0
							AND DATEDIFF(quarter, a.datStartDate, a.datFinishDate) > 1
						)
						OR	(	@MinTimeInterval = 10091003 --'sptQuarter'
								AND DATEDIFF(quarter, a.datStartDate, a.datFinishDate) = 0
								AND DATEDIFF(month, a.datStartDate, a.datFinishDate) > 1
							)
						OR (	@MinTimeInterval = 10091001 --'sptMonth'
								AND DATEDIFF(month, a.datStartDate, a.datFinishDate) = 0
								AND report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) > 1
							)
						OR (	@MinTimeInterval = 10091004 --'sptWeek'
								AND report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) = 0
								AND DATEDIFF(day, a.datStartDate, a.datFinishDate) > 1
							)
						OR (	@MinTimeInterval = 10091002--'sptOnday'
							AND DATEDIFF(day, a.datStartDate, a.datFinishDate) = 0)
					)    AND		
			(	
        
		    		(	@MinAdminLevel = 10089002 --'satRayon' 
						AND a.idfsAdministrativeUnit = rr.idfsRayon

					)
				OR	(	@MinAdminLevel = 10089004 --'satSettlement' 
						AND a.idfsAdministrativeUnit = s.idfsSettlement
					)
				OR 
					(	
						a.idfsAdministrativeUnit = ts.idfsSite
					)
			  )
			  AND ISNULL(ISNULL(rr.idfsRegion, s.idfsRegion), ts.idfsSite) is NOT NULL
			  AND ISNULL(ISNULL(rr.idfsRayon, s.idfsRayon),   ts.idfsSite) is NOT NULL
			  AND a.intRowStatus = 0



	DECLARE	@ReportAggregateDiagnosisValuesTable TABLE
	(	idfsBaseReference	BIGINT NOT NULL,
		intTotal			INT NOT NULL,
		intAge_0_17			INT NOT NULL,
		idfsRegion			BIGINT NOT NULL,
		idfsRayon			BIGINT NOT NULL
		PRIMARY KEY	(idfsBaseReference ASC,
				  idfsRegion ASC,
				  idfsRayon ASC)
	)
	

	INSERT INTO	@ReportAggregateDiagnosisValuesTable
	(	idfsBaseReference,
		intTotal,
		intAge_0_17,
		idfsRegion,
		idfsRayon
	)
	SELECT		
			fdt.idfsDiagnosis,
			sum(ISNULL(CAST(agp_Total.varValue AS INT), 0)),
			sum(ISNULL(CAST(agp_Age_0_17.varValue AS INT), 0)),
			fdt.idfsRegion,
			fdt.idfsRayon

	FROM		@ReportHumanAggregateCase fhac
	-- Updated for version 6
			
	-- Matrix version
	INNER JOIN	tlbAggrMatrixVersionHeader h
	ON			h.idfsMatrixType = 71190000000	-- Human Aggregate Case
				AND (	-- Get matrix version selected by the user in aggregate case
						h.idfVersion = fhac.idfVersion 
						-- If matrix version is not selected by the user in aggregate case, 
						-- then select active matrix with the latest date activation that is earlier than aggregate case start date
						or (	fhac.idfVersion is null 
								AND	h.datStartDate <= fhac.datStartDate
								AND	h.blnIsActive = 1
								AND not exists	(
											SELECT	*
											FROM	tlbAggrMatrixVersionHeader h_later
											WHERE	h_later.idfsMatrixType = 71190000000	-- Human Aggregate Case
													AND	h_later.datStartDate <= fhac.datStartDate
													AND	h_later.blnIsActive = 1
													AND h_later.intRowStatus = 0
													AND	h_later.datStartDate > h.datStartDate
					)
							))
				AND h.intRowStatus = 0
			
	-- Matrix row
	INNER JOIN	tlbAggrHumanCaseMTX mtx
	ON			mtx.idfVersion = h.idfVersion
				AND mtx.intRowStatus = 0
	INNER JOIN	@ReportDiagnosisTable fdt
	ON			fdt.idfsDiagnosis = mtx.idfsDiagnosis            
	AND ISNULL(fdt.idfsRegion,0) = ISNULL(fhac.idfsRegion,0)
	AND ISNULL(fdt.idfsRayon,0) = ISNULL(fhac.idfsRayon,0)        
        
	--	Total		
	LEFT JOIN	dbo.tlbActivityParameters agp_Total
	ON			agp_Total.idfObservation= fhac.idfCaseObservation
				AND	agp_Total.idfsParameter = @FFP_Total
				AND agp_Total.idfRow = mtx.idfAggrHumanCaseMTX
				AND agp_Total.intRowStatus = 0
				AND SQL_VARIANT_PROPERTY(agp_Total.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')

	--	Age_0_17		
	LEFT JOIN	dbo.tlbActivityParameters agp_Age_0_17
	ON			agp_Age_0_17.idfObservation= fhac.idfCaseObservation
				AND	agp_Age_0_17.idfsParameter = @FFP_Age_0_17
				AND agp_Age_0_17.idfRow = mtx.idfAggrHumanCaseMTX
				AND agp_Age_0_17.intRowStatus = 0
				AND SQL_VARIANT_PROPERTY(agp_Age_0_17.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')

	GROUP BY	fdt.idfsDiagnosis, fdt.idfsRegion, fdt.idfsRayon




	DECLARE	@ReportCaseTable TABLE
	(	idfsDiagnosis	BIGINT  NOT NULL,
		idfCase			BIGINT NOT NULL PRIMARY KEY,
		intYear			INT NULL,
		idfsHumanGender BIGINT,
		idfsRegion		BIGINT NULL,
		idfsRayon		BIGINT NULL
	)


	INSERT INTO	@ReportCaseTable
	(	idfsDiagnosis,
		idfCase,
		intYear,
		idfsHumanGender,
		idfsRegion,
		idfsRayon
	)
	SELECT DISTINCT
				fdt.idfsDiagnosis,
				hc.idfHumanCase AS idfCase,
				CASE
					WHEN	ISNULL(hc.idfsHumanAgeType, -1) = 10042003	-- Years 
							AND (ISNULL(hc.intPatientAge, -1) >= 0 AND ISNULL(hc.intPatientAge, -1) <= 200)
						THEN	hc.intPatientAge
					WHEN	ISNULL(hc.idfsHumanAgeType, -1) = 10042002	-- Months
							AND (ISNULL(hc.intPatientAge, -1) >= 0 AND ISNULL(hc.intPatientAge, -1) <= 60)
						THEN	CAST(hc.intPatientAge / 12 AS INT)
					WHEN	ISNULL(hc.idfsHumanAgeType, -1) = 10042001	-- Days
							AND (ISNULL(hc.intPatientAge, -1) >= 0)
						THEN	0
					ELSE	null
				END,			
				h.idfsHumanGender, /*gender*/
				CASE WHEN ts.idfsSite is NOT NULL THEN @TransportCHE /*Transport CHE*/ ELSE  gl.idfsRegion END,  /*region CR*/
				CASE WHEN ts.idfsSite is NOT NULL THEN ts.idfsSite ELSE gl.idfsRayon  END /*rayon CR*/
			
	FROM tlbHumanCase hc
     
		INNER JOIN tlbHuman h
			LEFT  JOIN tlbGeoLocation gl
			ON h.idfCurrentResidenceAddress = gl.idfGeoLocation AND gl.intRowStatus = 0
		  ON hc.idfHuman = h.idfHuman AND
			 h.intRowStatus = 0

		INNER JOIN	@ReportDiagnosisTable fdt
		ON			fdt.blnIsAggregate = 0
				AND fdt.idfsDiagnosis = COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
				AND fdt.idfsRegion = gl.idfsRegion
				AND fdt.idfsRayon = gl.idfsRayon
			
		LEFT JOIN tstSite ts
		ON ts.idfsSite = hc.idfsSite
		AND ts.intRowStatus = 0
		AND ts.intFlags = 1
    			
	WHERE		hc.datFinalCaseClassificationDate is NOT NULL AND
				(	@SD <= hc.datFinalCaseClassificationDate
						AND hc.datFinalCaseClassificationDate < DATEADD(day, 1, @ED)				
				) 
				AND ((gl.idfsRegion is NOT NULL AND gl.idfsRayon is NOT NULL) or (ts.idfsSite is NOT NULL))

			AND hc.intRowStatus = 0 
			 -- Cases should only be seleced for the report Final Case Classification = Confirmed
			 -- updated 22.05.2012 by Romasheva S.
			 AND hc.idfsFinalCaseStatus = 350000000 /*Confirmed Case*/

	DELETE FROM @ReportCaseTable WHERE idfsRegion is NOT NULL OR idfsRayon is NOT NULL


	--Total
	DECLARE	@ReportCaseDiagnosisTotalValuesTable TABLE
	(	idfsDiagnosis	BIGINT NOT NULL,
		intTotal		INT NOT NULL,
		idfsRegion		BIGINT NOT NULL,
		idfsRayon		BIGINT NOT NULL,
		PRIMARY KEY	(idfsDiagnosis ASC,
				  idfsRegion ASC,
				  idfsRayon ASC)
	)

	INSERT INTO	@ReportCaseDiagnosisTotalValuesTable
	(	idfsDiagnosis,
		intTotal,
		idfsRegion,
		idfsRayon
	)
	SELECT fct.idfsDiagnosis,
		   count(fct.idfCase),
		   idfsRegion,
		   idfsRayon
	FROM @ReportCaseTable fct
	GROUP BY fct.idfsDiagnosis, fct.idfsRegion, fct.idfsRayon



	--Total Age_0_17
	DECLARE	@ReportCaseDiagnosis_Age_0_17_TotalValuesTable TABLE
	(	idfsDiagnosis	BIGINT NOT NULL,
		intAge_0_17		INT NOT NULL,
		idfsRegion		BIGINT NOT NULL,
		idfsRayon		BIGINT NOT NULL,
		PRIMARY KEY	(idfsDiagnosis ASC,
				  idfsRegion ASC,
				  idfsRayon ASC)
	)

	INSERT INTO	@ReportCaseDiagnosis_Age_0_17_TotalValuesTable
	(	idfsDiagnosis,
		intAge_0_17,
		idfsRegion,
		idfsRayon
	)
	SELECT fct.idfsDiagnosis,
		   count(fct.idfCase),
		   idfsRegion,
		   idfsRayon
			
	FROM @ReportCaseTable fct
	WHERE (fct.intYear >= 0 AND fct.intYear <= 17)
	GROUP BY fct.idfsDiagnosis, 	fct.idfsRegion,	fct.idfsRayon


	--aggregate cases
	UPDATE fdt
	SET				
		fdt.intAge_0_17 = fadvt.intAge_0_17,
		fdt.intTotal = fadvt.intTotal
	FROM @ReportDiagnosisTable fdt
		INNER JOIN @ReportAggregateDiagnosisValuesTable fadvt
		ON fadvt.idfsBaseReference = fdt.idfsDiagnosis
		AND fadvt.idfsRegion = fdt.idfsRegion
		AND fadvt.idfsRayon = fdt.idfsRayon
	WHERE fdt.blnIsAggregate = 1	


	--standard cases
	UPDATE fdt
	SET fdt.intTotal = ISNULL(fdt.intTotal, 0) + fcdvt.intTotal
	FROM @ReportDiagnosisTable fdt
	INNER JOIN @ReportCaseDiagnosisTotalValuesTable fcdvt
	ON fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
		AND fcdvt.idfsRegion = fdt.idfsRegion
		AND fcdvt.idfsRayon = fdt.idfsRayon
	WHERE fdt.blnIsAggregate = 0		

	UPDATE fdt
		SET fdt.intAge_0_17 = ISNULL(fdt.intAge_0_17, 0) +  fcdvt.intAge_0_17
	FROM @ReportDiagnosisTable fdt
	INNER JOIN @ReportCaseDiagnosis_Age_0_17_TotalValuesTable fcdvt
	ON fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
		AND fcdvt.idfsRegion = fdt.idfsRegion
		AND fcdvt.idfsRayon = fdt.idfsRayon
	WHERE fdt.blnIsAggregate = 0
						

	-- update Report Table
	UPDATE rt
	SET	
	  rt.intTotal = rdt.intTotal,	
	  rt.intAge_0_17 = rdt.intAge_0_17 

	FROM #ReportTable rt
	INNER JOIN	@ReportDiagnosisTable rdt
	ON rdt.idfsDiagnosis = rt.idfsDiagnosis	
		AND rdt.idfsRegion = rt.idfsRegion
		AND rdt.idfsRayon = rt.idfsRayon				
						
	SELECT 
		intRegionOrder,
		strRegion,
		strRayon,
		strDiagnosis,
		intTotal,
		intAge_0_17
	FROM #ReportTable rt 			
	ORDER BY intRegionOrder

	IF OBJECT_ID('tempdb.dbo.#ReportTable') IS NOT NULL 
	  DROP TABLE #ReportTable
  	
END --if end	
